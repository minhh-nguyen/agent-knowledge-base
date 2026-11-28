# CUDA Guide

CUDA 11+ (12 recommended) on NVIDIA GPUs (Ampere sm_80+, Ada sm_89+). GPU performance comes from
matching the algorithm to the execution model: many threads, wide memory transactions, few stalls.

Consult for: kernel design, memory-hierarchy decisions, occupancy and coalescing problems, profiling,
review, teaching.

## Contents

- [Execution Model](#execution-model)
- [Host and Device Code](#host-and-device-code)
- [Kernels, Grids, Blocks](#kernels-grids-blocks)
- [Memory Hierarchy](#memory-hierarchy)
- [Memory Management](#memory-management)
- [Access Patterns](#access-patterns)
- [Synchronization and Atomics](#synchronization-and-atomics)
- [Streams](#streams)
- [Error Handling](#error-handling)
- [Performance](#performance)
- [Debugging and Profiling](#debugging-and-profiling)
- [Common Patterns](#common-patterns)

## Execution Model

| Aspect | CPU | GPU |
|--------|-----|-----|
| Cores | 8-32, deep out-of-order | Thousands, simple, in-order |
| Optimized for | Latency, branchy control flow | Throughput, data parallelism |
| Memory | Large coherent cache | Small caches, huge bandwidth |
| Best at | Sequential logic | Same operation over many elements |

Good GPU work: independent elements, high arithmetic intensity, coalesced access. Bad GPU work: heavy
branching, sequential dependencies, memory-bound pointer chasing.

Hardware facts to design around: a streaming multiprocessor (SM) holds 128 FP32 cores and executes warps
of 32 threads; max block size is 1024 threads; shared memory is 48-96+ KB per block; ~255 registers per
thread; grid limits are 2^31-1 blocks per dimension.

Threads in a warp execute in lockstep — divergence serializes the paths. Keep the common case uniform.

## Host and Device Code

```cpp
#include <cuda_runtime.h>
#include <cstdio>

__global__ void add(const float* a, const float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) c[i] = a[i] + b[i];           // guard every access
}

int main() {
    const int n = 1 << 20;
    const size_t bytes = n * sizeof(float);

    float *h_a, *h_b, *h_c;                              // host buffers, allocated and filled by the caller
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

    int block = 256;
    int grid = (n + block - 1) / block;
    add<<<grid, block>>>(d_a, d_b, d_c, n);
    cudaDeviceSynchronize();                               // cudaMemcpy below also synchronizes

    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
}
```

`__global__` = kernel (host call, device execution), `__device__` = device-only function,
`__host__` = CPU function. Kernel launches are asynchronous with respect to the host.

## Kernels, Grids, Blocks

```cpp
kernel<<<gridDim, blockDim, sharedBytes, stream>>>(args);
```

- `gridDim`, `blockDim` are `dim3` (default `.y = .z = 1`).
- **Global thread index (1D):** `blockIdx.x * blockDim.x + threadIdx.x`.
- **2D:** `x = blockIdx.x * blockDim.x + threadIdx.x`, `y = blockIdx.y * blockDim.y + threadIdx.y`, then `idx = y * width + x`.

Sizing: 128-512 threads per block is a good default (256 usual). Grid = ceil(n / block). Small blocks
raise scheduling overhead; oversized blocks limit occupancy through register and shared-memory pressure.

```cpp
int block = 256;
int grid  = (n + block - 1) / block;      // ceiling division
kernel<<<grid, block>>>(data, n);
```

## Memory Hierarchy

| Memory | Scope | Latency | Bandwidth | Use |
|--------|-------|---------|-----------|-----|
| Registers | Thread | ~4 cycles | Highest | Locals, accumulators |
| Shared / L1 | Block | ~20-30 cycles | Very high | Tiles, block cooperation |
| L2 | Device | ~100-200 cycles | High | Reused global data |
| Global (VRAM) | Grid | ~300-600 cycles | High but easy to waste | Inputs/outputs |
| Constant | Grid, read-only | Cached, broadcast | Medium | Kernel parameters, LUTs |
| Texture | Grid, read-only | Cached, interpolated | High | 2D/3D spatial reads |

Shared memory is roughly 10-100x cheaper than an uncached global access — it is the main lever for
matrix, stencil, and reduction kernels.

```cpp
__global__ void stencil(const float* in, float* out, int n) {
    __shared__ float tile[256];
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int t = threadIdx.x;

    tile[t] = (i < n) ? in[i] : 0.0f;
    __syncthreads();                        // tile fully populated

    if (i > 0 && i < n - 1) out[i] = 0.25f * (tile[t-1] + 2*tile[t] + tile[t+1]);
}
```

Use separate input and output buffers: in-place updates race with neighbouring blocks still loading `in`.

Bank conflicts: 32 banks, 4 bytes wide. `tile[t]` with `t = threadIdx.x` is conflict-free; a stride of 32
puts every thread in the same bank and serializes. Pad 2D tiles (`tile[32][33]`) to avoid it.

## Memory Management

```cpp
float* d;
cudaMalloc(&d, bytes);                                   // device allocation
cudaMemcpy(d, h, bytes, cudaMemcpyHostToDevice);         // H2D
cudaMemcpy(h, d, bytes, cudaMemcpyDeviceToHost);         // D2H
cudaMemcpy(d2, d, bytes, cudaMemcpyDeviceToDevice);      // D2D
cudaFree(d);
```

- Use `cudaMallocAsync`/pools for allocation-heavy code; `cudaMalloc` in a loop is a synchronization point.
- Transfers are the classic bottleneck: move data once, run many kernels, move results back once.
- Pin host memory (`cudaHostAlloc`/`cudaMallocHost`) for faster, truly async copies.
- Unified memory:

```cpp
float* data;
cudaMallocManaged(&data, bytes);      // migrates pages on demand
kernel<<<grid, block>>>(data, n);
cudaDeviceSynchronize();              // required before host reads
cudaFree(data);
```

Managed memory simplifies code but page faults cost performance; prefer explicit buffers for hot loops,
or `cudaMemAdvise`/prefetch to control placement.

## Access Patterns

**Coalescing is the single biggest win.** Consecutive threads must touch consecutive addresses so the
memory system can merge them into full 32/128-byte transactions.

```cpp
float v = data[blockIdx.x * blockDim.x + threadIdx.x];        // coalesced: 1 transaction per warp
float w = data[(blockIdx.x * blockDim.x + threadIdx.x) * 8]; // strided: up to 8x transactions
```

Strided or transposed access patterns: stage through shared memory (tile, transpose in shared, write
coalesced). Align allocations to 16+ bytes and size structs so fields used together stay together
(structure-of-arrays beats array-of-structs for per-field passes).

## Synchronization and Atomics

`__syncthreads()` is a block-wide barrier — all threads must reach it; never place it in divergent code.

```cpp
__global__ void count(int* counter) {
    atomicAdd(counter, 1);        // read-modify-write without a race
}
```

- Atomics work on global and shared memory; they serialize when many threads target one address.
- Prefer per-block/shared accumulation and one global atomic per block (see reduction).
- `atomicAdd`, `atomicCAS`, `atomicMax`, ... ; use `atomicCAS` loops for custom types.
- Warp-level primitives (`__shfl_down_sync`, `__ballot_sync`) reduce shared-memory traffic.
- No grid-wide barrier in a normal launch — split into kernels instead.

## Streams

Streams overlap copies and kernels; the default (null) stream serializes.

```cpp
cudaStream_t s1, s2;
cudaStreamCreate(&s1);
cudaStreamCreate(&s2);

cudaMemcpyAsync(d_a, h_a, bytes, cudaMemcpyHostToDevice, s1);
kernel<<<grid, block, 0, s1>>>(d_a);
cudaMemcpyAsync(h_c, d_c, bytes, cudaMemcpyDeviceToHost, s2);

cudaStreamSynchronize(s1);
cudaStreamDestroy(s1);
```

Rules: async copies need pinned host memory; only four streams are needed to saturate most GPUs; use
`cudaEventRecord`/`cudaEventSynchronize` for cross-stream dependencies; avoid `cudaDeviceSynchronize()`
in hot paths.

## Error Handling

Every runtime call returns `cudaError_t`; kernel faults surface only at the next synchronization.

```cpp
#define CUDA_CHECK(call)                                                     \
    do {                                                                     \
        cudaError_t err_ = (call);                                           \
        if (err_ != cudaSuccess) {                                           \
            std::fprintf(stderr, "%s:%d %s -> %s\n", __FILE__, __LINE__,     \
                         #call, cudaGetErrorString(err_));                   \
            std::exit(EXIT_FAILURE);                                         \
        }                                                                    \
    } while (0)

kernel<<<grid, block>>>(args);
CUDA_CHECK(cudaGetLastError());          // launch/config errors
CUDA_CHECK(cudaDeviceSynchronize());     // execution errors
```

Build debug variants with `-lineinfo` (and `compute-sanitizer`) so races and out-of-bounds accesses are
reported with source locations.

## Performance

1. **Measure** with `nsys` (timeline, transfers) and `ncu` (per-kernel metrics). Never guess.
2. **Occupancy:** active warps / maximum warps per SM. Limited by registers, shared memory, block count.
   50% is usually enough to hide latency; more only helps latency-bound kernels.
3. **Coalesce** all global accesses; verify with `ncu` (`gld_efficiency`, `gst_efficiency`).
4. **Use shared memory** for reused tiles and block reductions; avoid bank conflicts.
5. **Minimize transfers and synchronizations**; overlap with streams; keep data resident on the device.
6. **Reduce divergence** inside warps; hoist uniform work out of the divergent branch.
7. **Increase arithmetic intensity** — the GPU is throughput-oriented; memory-bound kernels waste it.
8. **Bound-check once**, outside tight loops; use `__restrict__` and `const` to help the compiler.
9. Consider `float4` vectorized loads, `__ldg` for read-only data, and `-use_fast_math` only with
   validated numerics.

```cpp
cudaEvent_t start, stop;
cudaEventCreate(&start); cudaEventCreate(&stop);
cudaEventRecord(start);
kernel<<<grid, block>>>(data, n);
cudaEventRecord(stop);
cudaEventSynchronize(stop);
float ms = 0.0f;
cudaEventElapsedTime(&ms, start, stop);
```

## Debugging and Profiling

```bash
compute-sanitizer --tool memcheck ./app      # out-of-bounds, misaligned, races (--tool racecheck)
cuda-gdb ./app                                # break kernel, inspect threads: cuda thread 0 block 0
nsys profile --stats=true ./app               # timeline: transfers, kernels, gaps
ncu --set full --kernel-name my_kernel ./app  # per-kernel occupancy, memory, stalls
```

Typical symptoms: low achieved occupancy → register/shared pressure; high `stall_long_scoreboard` →
uncoalesced or latency-bound loads; serialized warps → divergence; idle GPU between kernels → host
synchronization or transfer stalls.

## Common Patterns

**Reduction (block sum):**

```cpp
__global__ void reduce(const float* in, float* out, int n) {
    __shared__ float s[256];
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int t = threadIdx.x;

    s[t] = (i < n) ? in[i] : 0.0f;
    __syncthreads();

    for (int stride = blockDim.x / 2; stride > 0; stride >>= 1) {
        if (t < stride) s[t] += s[t + stride];
        __syncthreads();
    }
    if (t == 0) atomicAdd(out, s[0]);
}
```

**Tiled matrix multiply** (one 16x16 tile per block, two shared tiles, reuse across the k dimension):

```cpp
#define TILE 16

__global__ void matmul(const float* A, const float* B, float* C, int n) {
    __shared__ float As[TILE][TILE];
    __shared__ float Bs[TILE][TILE];

    int row = blockIdx.y * TILE + threadIdx.y;
    int col = blockIdx.x * TILE + threadIdx.x;
    float sum = 0.0f;

    for (int t = 0; t < (n + TILE - 1) / TILE; ++t) {
        int ac = t * TILE + threadIdx.x;
        int br = t * TILE + threadIdx.y;
        As[threadIdx.y][threadIdx.x] = (row < n && ac < n) ? A[row * n + ac] : 0.0f;
        Bs[threadIdx.y][threadIdx.x] = (br < n && col < n) ? B[br * n + col] : 0.0f;
        __syncthreads();

        for (int k = 0; k < TILE; ++k) sum += As[threadIdx.y][k] * Bs[k][threadIdx.x];
        __syncthreads();
    }
    if (row < n && col < n) C[row * n + col] = sum;
}
```

For production GEMM, use cuBLAS; hand-written tiles are for learning and special cases.

## References

- [CUDA C++ Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
- [CUDA Runtime API](https://docs.nvidia.com/cuda/cuda-runtime-api/)
- [CUDA Best Practices Guide](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/)
- [NVIDIA Nsight documentation](https://docs.nvidia.com/nsight-systems/)

Related: [`principles.md`](principles.md), [`../SKILL.md`](../SKILL.md)
