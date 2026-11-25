# CUDA Programming Guide

Comprehensive guide to CUDA for GPU programming. CUDA enables high-performance computing on NVIDIA GPUs through C/C++ and Python. Understanding both the programming model and GPU hardware characteristics is essential.

## Table of Contents

1. [GPU Architecture and Execution Model](#gpu-architecture-and-execution-model)
2. [Host and Device Programming](#host-and-device-programming)
3. [Kernels and Grid/Block Organization](#kernels-and-gridblock-organization)
4. [Memory Hierarchy](#memory-hierarchy)
5. [Memory Management](#memory-management)
6. [Memory Access Patterns](#memory-access-patterns)
7. [Synchronization and Atomics](#synchronization-and-atomics)
8. [Streams and Asynchronous Execution](#streams-and-asynchronous-execution)
9. [Error Handling](#error-handling)
10. [Performance Optimization](#performance-optimization)
11. [Debugging and Profiling](#debugging-and-profiling)
12. [Common Patterns](#common-patterns)

---

## GPU Architecture and Execution Model

### GPU vs. CPU

**GPUs are specialized for data parallelism:**

| Aspect | CPU | GPU |
|--------|-----|-----|
| Cores | Few (8-32) | Many (thousands) |
| Latency | Low (~nanoseconds) | Higher (~microseconds) |
| Throughput | Moderate | Very high |
| Memory bandwidth | Moderate | Extreme |
| Specialization | General purpose | Parallel compute |

**GPUs excel at:**
- Thousands of independent tasks
- Data-parallel algorithms
- High arithmetic intensity (compute per memory access)

**GPUs struggle with:**
- Sequential code
- Complex control flow
- Low arithmetic intensity

### NVIDIA GPU Architecture (Ampere, Ada)

**Key components:**

- **Stream Multiprocessor (SM):** Contains 128 CUDA cores, shared memory, registers
- **CUDA Core:** Executes one floating-point or integer operation per clock
- **Memory Controllers:** Manage bandwidth to VRAM
- **L1/L2 Caches:** Cache hierarchy for performance

**Key limits:**

- **Maximum block size:** 1024 threads (practical: 128-512)
- **Maximum grid dimensions:** 2^31 - 1 blocks per dimension (3D)
- **Registers per thread:** Typically 255 (varies by GPU)
- **Shared memory per block:** 48 KB - 96 KB (depends on configuration)

---

## Host and Device Programming

### Host Code (CPU)

**Host code runs on CPU and launches kernels:**

```cpp
#include <cuda_runtime.h>
#include <stdio.h>

__global__ void add_kernel(int *d_a, int *d_b, int *d_c, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        d_c[idx] = d_a[idx] + d_b[idx];
    }
}

int main() {
    int n = 1000;
    
    // Allocate device memory
    int *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, n * sizeof(int));
    cudaMalloc(&d_b, n * sizeof(int));
    cudaMalloc(&d_c, n * sizeof(int));
    
    // Copy data to device
    int h_a[1000] = {/* ... */};
    cudaMemcpy(d_a, h_a, n * sizeof(int), cudaMemcpyHostToDevice);
    
    // Launch kernel
    int threads_per_block = 256;
    int blocks = (n + threads_per_block - 1) / threads_per_block;
    add_kernel<<<blocks, threads_per_block>>>(d_a, d_b, d_c, n);
    
    // Copy result back
    int h_c[1000];
    cudaMemcpy(h_c, d_c, n * sizeof(int), cudaMemcpyDeviceToHost);
    
    // Free memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    
    return 0;
}
```

### Device Code (GPU)

**Device code runs on GPU with many threads in parallel:**

```cpp
// Kernel: executed by thousands of threads simultaneously
__global__ void process_kernel(float *data, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (idx < n) {
        data[idx] = data[idx] * 2.0f;  // Each thread processes one element
    }
}

// Called from host (CPU) with <<<grid, block>>> syntax
// Launches gridDim.x * gridDim.y * gridDim.z * blockDim.x * blockDim.y * blockDim.z threads
```

---

## Kernels and Grid/Block Organization

### Kernel Launches

**Kernel launch syntax:**

```cpp
kernel<<<gridDim, blockDim, sharedMemBytes, stream>>>(args);

// gridDim:       number of blocks in each dimension
// blockDim:      number of threads in each block
// sharedMemBytes: shared memory per block (optional)
// stream:        CUDA stream for async execution (optional)
```

### Thread Indexing

**Compute thread's work index from block/thread IDs:**

```cpp
__global__ void kernel_1d(float *data, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (idx < n) {
        data[idx] = data[idx] * 2.0f;
    }
}

__global__ void kernel_2d(float *data, int width, int height) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x < width && y < height) {
        int idx = y * width + x;
        data[idx] = data[idx] * 2.0f;
    }
}
```

### Choosing Grid and Block Size

**General guidelines:**

- **Block size:** 128, 256, or 512 threads (good for most architectures)
- **Grid size:** As many blocks as needed to process all data
- **Occupancy:** Balance between registers/shared memory per thread and blocks

**Compute grid dimensions for 1D data:**

```cpp
int n = 1000000;
int blockSize = 256;
int gridSize = (n + blockSize - 1) / blockSize;  // Ceiling division
kernel<<<gridSize, blockSize>>>(data, n);
```

---

## Memory Hierarchy

### Memory Types (Latency and Bandwidth)

| Memory | Access | Latency | Bandwidth | Use Case |
|--------|--------|---------|-----------|----------|
| Registers | Per-thread | ~4 cycles | Unlimited | Local variables |
| L1 Cache | Per-thread | ~20 cycles | Very high | Cache hit for local data |
| Shared Memory | Per-block | ~20 cycles | Very high | Communication within block |
| L2 Cache | Global | ~100 cycles | Very high | Cache hit for global data |
| Global Memory | All threads | ~300 cycles | High | Main GPU memory |
| Constant Memory | All threads | ~20 cycles (cached) | Medium | Read-only constants |
| Texture Memory | All threads | Cached | High | 2D/3D data, interpolation |

### Global Memory

**Global memory is the main GPU VRAM:**

```cpp
__global__ void global_memory_kernel(float *global_data) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    global_data[idx] = global_data[idx] * 2.0f;  // Accesses global memory
}
```

**Global memory is slow without good access patterns:**
- Poor memory coalescing → 10x slowdown
- Unaligned accesses → serialization

### Shared Memory

**Fast, on-chip memory shared by all threads in a block:**

```cpp
__global__ void shared_memory_kernel(float *global_data, int n) {
    __shared__ float shared_buffer[256];  // 256 floats per block
    
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int tid = threadIdx.x;
    
    // Load from global to shared memory
    if (idx < n) {
        shared_buffer[tid] = global_data[idx];
    }
    __syncthreads();  // Wait for all threads in block
    
    // Now all threads can access shared_buffer (fast)
    if (tid > 0) {
        shared_buffer[tid] += shared_buffer[tid - 1];
    }
    __syncthreads();
    
    // Write back to global memory
    if (idx < n) {
        global_data[idx] = shared_buffer[tid];
    }
}
```

### Registers

**Per-thread fast storage:**

```cpp
__global__ void register_kernel(float *data, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Local variables are stored in registers
    float a = 1.0f;
    float b = 2.0f;
    float c = a + b;  // Computed in register (very fast)
    
    if (idx < n) {
        data[idx] = c;
    }
}
```

---

## Memory Management

### Device Memory Allocation

```cpp
// Allocate
float *d_data;
size_t bytes = n * sizeof(float);
cudaMalloc(&d_data, bytes);

// Use
// kernel<<<grid, block>>>(d_data, n);

// Free
cudaFree(d_data);
```

### Host-Device Transfers

```cpp
float h_data[1000] = {/* ... */};
float *d_data;

// Host to Device
cudaMalloc(&d_data, 1000 * sizeof(float));
cudaMemcpy(d_data, h_data, 1000 * sizeof(float), cudaMemcpyHostToDevice);

// Device to Host
cudaMemcpy(h_data, d_data, 1000 * sizeof(float), cudaMemcpyDeviceToHost);

// Device to Device
float *d_other;
cudaMalloc(&d_other, 1000 * sizeof(float));
cudaMemcpy(d_other, d_data, 1000 * sizeof(float), cudaMemcpyDeviceToDevice);
```

### Unified Memory

**Unified memory simplifies data movement (at potential performance cost):**

```cpp
// Allocate memory accessible from both host and device
float *data;
cudaMallocManaged(&data, n * sizeof(float));

// Can access from both host and device
data[0] = 1.0f;  // Host

kernel<<<grid, block>>>(data, n);  // Device
cudaDeviceSynchronize();

float value = data[0];  // Host
cudaFree(data);
```

---

## Memory Access Patterns

### Memory Coalescing

**Coalesced access: threads access contiguous memory (fast):**

```cpp
// GOOD: coalesced
__global__ void coalesced_kernel(float *data) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    float value = data[idx];  // Consecutive threads access consecutive memory
}
```

**Uncoalesced access: threads access scattered memory (slow):**

```cpp
// BAD: uncoalesced
__global__ void uncoalesced_kernel(float *data, int stride) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    float value = data[idx * stride];  // Large gaps between accesses
}
```

### Cache Locality

**Use shared memory to improve cache behavior:**

```cpp
__global__ void tile_kernel(float *data, int n) {
    __shared__ float tile[32][32];
    
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    // Cooperatively load tile into shared memory
    tile[threadIdx.y][threadIdx.x] = data[y * n + x];
    __syncthreads();
    
    // Process from shared memory (fast)
    float sum = 0.0f;
    for (int i = 0; i < 32; i++) {
        sum += tile[threadIdx.y][i];
    }
    
    data[y * n + x] = sum;
}
```

---

## Synchronization and Atomics

### Block Synchronization

**`__syncthreads()` synchronizes threads within a block:**

```cpp
__global__ void sync_kernel(int *data) {
    int idx = threadIdx.x;
    
    // Each thread processes its data
    data[idx] = data[idx] * 2;
    
    // Wait for all threads in the block
    __syncthreads();
    
    // Now all threads have completed their work
    if (idx == 0) {
        printf("All threads done\n");
    }
}
```

### Atomic Operations

**Atomics safely update shared data from multiple threads:**

```cpp
__global__ void atomic_kernel(int *counter) {
    // Multiple threads incrementing same variable
    atomicAdd(counter, 1);  // Atomic add (no race condition)
}

// In host code
int *d_counter;
cudaMalloc(&d_counter, sizeof(int));
cudaMemset(d_counter, 0, sizeof(int));

atomic_kernel<<<1000, 32>>>(d_counter);  // 32,000 threads

int result;
cudaMemcpy(&result, d_counter, sizeof(int), cudaMemcpyDeviceToHost);
// result = 32000 (or close, depending on warp-level guarantees)
```

---

## Streams and Asynchronous Execution

### CUDA Streams

**Streams enable asynchronous kernel execution:**

```cpp
cudaStream_t stream1, stream2;
cudaStreamCreate(&stream1);
cudaStreamCreate(&stream2);

// Launch kernels on different streams
kernel1<<<grid, block, 0, stream1>>>(data1);
kernel2<<<grid, block, 0, stream2>>>(data2);

// Operations can proceed in parallel
cudaMemcpyAsync(h_data3, d_data3, bytes, cudaMemcpyDeviceToHost, stream1);

// Wait for all work to finish
cudaStreamSynchronize(stream1);
cudaStreamSynchronize(stream2);

cudaStreamDestroy(stream1);
cudaStreamDestroy(stream2);
```

---

## Error Handling

**Always check for CUDA errors:**

```cpp
cudaError_t err = cudaMalloc(&data, bytes);
if (err != cudaSuccess) {
    fprintf(stderr, "CUDA error: %s\n", cudaGetErrorString(err));
    return -1;
}

// Or use a helper macro
#define CUDA_CHECK(call) \
do { \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        fprintf(stderr, "CUDA error: %s\n", cudaGetErrorString(err)); \
        exit(EXIT_FAILURE); \
    } \
} while(0)

// Usage
CUDA_CHECK(cudaMalloc(&data, bytes));
CUDA_CHECK(cudaMemcpy(data, host_data, bytes, cudaMemcpyHostToDevice));
```

**Check kernel launches:**

```cpp
kernel<<<grid, block>>>(data, n);
CUDA_CHECK(cudaGetLastError());        // Check launch error
CUDA_CHECK(cudaDeviceSynchronize());   // Check kernel execution error
```

---

## Performance Optimization

### Occupancy

**Occupancy: percentage of GPU cores in use:**

- Higher occupancy → better utilization
- Register usage and shared memory limit occupancy
- Practical occupancy: 50-100%

**Improve occupancy:**

```cpp
// Use fewer registers per thread
__global__ void efficient_kernel(float *data) {
    // Minimize register usage
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    data[idx] *= 2.0f;
}

// Use smaller blocks with more blocks
kernel<<<many_blocks, 128>>>(data);  // Better than <<<few_blocks, 512>>>
```

### Profiling

**Use Nvidia profiling tools:**

```bash
# Terminal-based profiler
nsys profile --stats=true ./my_cuda_app

# Visual profiler (GUI)
nvvp
```

**Measure kernel performance programmatically:**

```cpp
cudaEvent_t start, stop;
cudaEventCreate(&start);
cudaEventCreate(&stop);

cudaEventRecord(start);
kernel<<<grid, block>>>(data, n);
cudaEventRecord(stop);
cudaEventSynchronize(stop);

float milliseconds = 0;
cudaEventElapsedTime(&milliseconds, start, stop);
printf("Kernel time: %.2f ms\n", milliseconds);

cudaEventDestroy(start);
cudaEventDestroy(stop);
```

### Common Optimizations

**Reduce memory transfers:**
```cpp
// BAD: multiple transfers
for (int i = 0; i < 1000; i++) {
    cudaMemcpy(d_data, h_data, bytes, cudaMemcpyHostToDevice);
    kernel<<<grid, block>>>(d_data);
}

// GOOD: single transfer
cudaMemcpy(d_data, h_data, bytes, cudaMemcpyHostToDevice);
for (int i = 0; i < 1000; i++) {
    kernel<<<grid, block>>>(d_data);
}
```

**Use maximum compute with minimum memory:**
- Maximize arithmetic intensity (operations per byte)
- Use shared memory effectively
- Minimize global memory accesses

---

## Debugging and Profiling

### CUDA-GDB Debugger

```bash
cuda-gdb ./my_cuda_app
(cuda-gdb) break kernel_name
(cuda-gdb) run
(cuda-gdb) cuda thread 0 block 0
(cuda-gdb) print variable_name
(cuda-gdb) continue
```

### Profiling Tools

**NVIDIA NSight Systems:**

```bash
nsys profile ./my_cuda_app
```

**NVIDIA NSight Compute (fine-grained profiling):**

```bash
ncu --set full ./my_cuda_app
```

---

## Common Patterns

### Parallel Reduction (Sum)

**Reduce array to single value:**

```cpp
__global__ void reduce_kernel(float *data, float *result, int n) {
    __shared__ float shared[256];
    
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int tid = threadIdx.x;
    
    // Load data into shared memory
    shared[tid] = (idx < n) ? data[idx] : 0.0f;
    __syncthreads();
    
    // Parallel reduction within block
    for (int s = blockDim.x / 2; s > 0; s /= 2) {
        if (tid < s) {
            shared[tid] += shared[tid + s];
        }
        __syncthreads();
    }
    
    // Write block result
    if (tid == 0) {
        atomicAdd(result, shared[0]);
    }
}
```

### Matrix Multiplication

**Efficiently multiply two matrices using shared memory:**

```cpp
#define TILE_SIZE 16

__global__ void matmul_kernel(float *A, float *B, float *C, int n) {
    __shared__ float A_tile[TILE_SIZE][TILE_SIZE];
    __shared__ float B_tile[TILE_SIZE][TILE_SIZE];
    
    int row = blockIdx.y * TILE_SIZE + threadIdx.y;
    int col = blockIdx.x * TILE_SIZE + threadIdx.x;
    
    float sum = 0.0f;
    
    for (int tile = 0; tile < (n + TILE_SIZE - 1) / TILE_SIZE; tile++) {
        // Load tiles
        A_tile[threadIdx.y][threadIdx.x] = A[row * n + tile * TILE_SIZE + threadIdx.x];
        B_tile[threadIdx.y][threadIdx.x] = B[(tile * TILE_SIZE + threadIdx.y) * n + col];
        __syncthreads();
        
        // Compute partial result
        for (int k = 0; k < TILE_SIZE; k++) {
            sum += A_tile[threadIdx.y][k] * B_tile[k][threadIdx.x];
        }
        __syncthreads();
    }
    
    C[row * n + col] = sum;
}
```

---

## References

- [CUDA Documentation](https://docs.nvidia.com/cuda/) — Official NVIDIA documentation
- [CUDA C++ Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/) — Comprehensive guide
- [CUDA Toolkit API Reference](https://docs.nvidia.com/cuda/cuda-runtime-api/) — API reference
- [GPU Architecture White Papers](https://www.nvidia.com/en-us/geforce/technology/) — Architecture details
