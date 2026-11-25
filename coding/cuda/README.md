# CUDA Programming Guide

**Location:** `cuda/cuda-guide.md`

**Target:** NVIDIA CUDA on modern GPUs (Ampere, Ada architectures)

**Key Concept:** GPU architecture and execution model fundamentally differ from CPUs; understanding both is essential for performance.

## When to Consult This Guide

Use this guide when:
- **GPU programming:** implementing CUDA kernels and host code
- **Performance optimization:** understanding memory access patterns, occupancy
- **Debugging GPU code:** profiling and finding bottlenecks
- **Teaching GPU concepts:** explaining threads, blocks, memory hierarchy
- **Reviewing CUDA code:** assessing correctness, efficiency, memory usage
- **Interoperability:** integrating CUDA with C++ or Python

## Key Concepts

### GPU vs. CPU

**GPUs have fundamentally different architecture:**

- **Many cores:** Thousands of small cores (not fast individual execution)
- **Massive parallelism:** Thousands of threads run simultaneously
- **Data parallelism:** One operation on many data elements
- **Memory bandwidth:** Extremely high throughput (at cost of latency)

**GPUs excel at:**
- Data-parallel algorithms
- High arithmetic intensity (compute per memory access)
- Batch processing of independent tasks

**GPUs struggle with:**
- Sequential code
- Complex control flow
- Low arithmetic intensity

### Memory Hierarchy

| Memory | Latency | Bandwidth | Use |
|--------|---------|-----------|-----|
| Registers | ~4 cycles | Unlimited | Local variables |
| Shared Memory | ~20 cycles | Very high | Communication within block |
| Global Memory | ~300 cycles | High | Main GPU memory |

**Key insight:** Shared memory is 10-100x faster than global memory.

## Quick Reference

| Topic | Use Case |
|-------|----------|
| [GPU Architecture](#gpu-architecture-and-execution-model) | Understanding GPU capabilities |
| [Kernels](#kernels-and-gridblock-organization) | Writing and launching kernels |
| [Memory Hierarchy](#memory-hierarchy) | Understanding memory access speed |
| [Memory Coalescing](#memory-access-patterns) | Optimizing memory performance |
| [Shared Memory](#shared-memory) | Cooperative thread data sharing |
| [Synchronization](#synchronization-and-atomics) | Thread coordination |
| [Profiling](#debugging-and-profiling) | Measuring performance |

## Best Practices

### Kernel Design

1. **Maximize coalesced memory access** — Consecutive threads should access consecutive memory
2. **Use shared memory effectively** — Cooperative loading and processing
3. **Balance occupancy** — Not too many registers per thread, allowing more blocks
4. **Minimize divergence** — Threads in a warp should follow same code path

### Memory Management

1. **Minimize H2D/D2H transfers** — Largest bottleneck in many applications
2. **Use unified memory when appropriate** — Simplifies code at potential performance cost
3. **Overlap computation and transfer** — Use streams for async operations
4. **Align memory** — Ensure coalesced access

### Error Handling

**Always check CUDA error codes:**

```cpp
cudaError_t err = cudaMalloc(&data, bytes);
if (err != cudaSuccess) {
    fprintf(stderr, "Error: %s\n", cudaGetErrorString(err));
}
```

## Standards and Versions

- **Minimum supported:** CUDA 11.0
- **Recommended:** CUDA 12.0+
- **GPU architectures:** Ampere (A100, RTX 3000-series), Ada (H100, RTX 4000-series)
- **Compute capability:** sm_80+ recommended
- **Profiling tools:** NSight Systems, NSight Compute

## Common Mistakes to Avoid

1. **Not checking error codes** — Silent failures hide problems
2. **Uncoalesced memory access** — Poor memory patterns destroy performance
3. **Excessive host-device transfers** — Move data once, compute many times
4. **Insufficient occupancy** — Use too many registers, only fraction of GPU active
5. **Synchronizing on host** — Prevents overlapping computation and transfer
6. **Ignoring memory hierarchy** — Shared memory 10-100x faster than global

## Related Documents

- See [`../CODING_PRINCIPLES.md`](../CODING_PRINCIPLES.md) for language-independent principles
- See [`../README.md`](../README.md) for navigation and when to consult each guide

## References

- [CUDA Documentation](https://docs.nvidia.com/cuda/) — Official NVIDIA documentation
- [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/) — Comprehensive reference
- [GPU Architecture (Ampere)](https://www.nvidia.com/en-us/data-center/ampere-architecture/) — Architecture details
- [NVIDIA Developer Blog](https://developer.nvidia.com/blog/) — Practical tutorials

---

**Start with:** Understand GPU architecture and thread organization. Kernel design and memory coalescing are the keys to performance.
