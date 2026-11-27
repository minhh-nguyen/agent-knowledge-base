# Ideation Memory

Last Updated: 2026-11-26
Total Cycles: 2

## Index

- Tier-Aware Fetch Planning Across Azure Blob Price Structures | selected by user | `### [Cycle 2] Tier-Aware Fetch Planning Across Azure Blob Price Structures`
- Column-Granular Storage Tiering + Local-Cache Break-Even | feasible | `### [Cycle 2] Column-Granular Storage Tiering + Local-Cache Break-Even`
- io_uring Guidelines Re-validated on Cloud Ephemeral NVMe (Azure L-series) | feasible-conditional | `### [Cycle 2] io_uring Guidelines Re-validated on Cloud Ephemeral NVMe (Azure L-series)`
- Telemetry-Driven Adaptive I/O-Path Controller for OLTP Storage Engines | selected by user for proposal expansion | `### Telemetry-Driven Adaptive I/O-Path Controller for OLTP Storage Engines`
- Minimal-Attack-Surface, Portable io_uring Storage Engines | feasible | `### Minimal-Attack-Surface, Portable io_uring Storage Engines`
- io_uring-Native Cloud WAL with Placement-Aware Batching | feasible | `### io_uring-Native Cloud WAL with Placement-Aware Batching`
- io_uring experiments on macOS host | fundamental failure | `### io_uring experiments on macOS host`
- Cross-cloud price comparison as main contribution | fundamental failure | `### Cross-cloud price comparison as main contribution`
- Learned column-tiering policy | implementation-level prune | `### Learned column-tiering policy`

## Feasible Directions

### [Cycle 2] Tier-Aware Fetch Planning Across Azure Blob Price Structures

- **Summary**: Extends RQ1 (price/concurrency-aware coalescing for Parquet scans) — validate one cost model c_req·R + c_byte·Y + λ·T against 5 real price structures in one provider (Azure Premium/Hot/Cool/Cold/HNS + egress). Predicts the optimal gap ranges ~6 KiB→7.7 MiB while the latency-only L·B rule (DuckDB v2.0, Arrow) gives ~1.5 MiB everywhere.
- **Why Promising**: Runs fully on Mac (GET/bytes/$ deterministic from logs); Azure trial only for cheap calibration; single-provider multi-tier design removes cross-cloud confounds; Azure prices verified via prices.azure.com 2026-11-26.
- **Requirements**: moto/Garage + delay proxy, DuckDB v2.0.1, PyArrow, one Azure storage account (4 tiers) + Premium account, small in-region Linux VM for TTFB calibration.
- **Validation Plan**: Mac sweep σ × clustering × TTFB × N × gap; compute $ per tier; measure per-tier TTFB/BW on Azure; check measured-optimal g vs predicted g*; verify HNS read billing granularity (per-4MiB? unverified).
- **Evidence**: Cycle 2 ELO winner, 1531 (N7 F9 R9 C9). Details: `~/.claude/research-report/direction-summary-2026-11-26-mac-azure.md`.
- **Status**: selected by user (2026-11-27); reading list at `~/.claude/research-report/idea1-reading-list.md`; next = Step 7 proposal
- **Related Entries**: RQ1 remote fetch planning (repo report); Column-Granular Tiering
- **Retrieval Tags**: object storage, range GET coalescing, Parquet, Azure Blob tiers, request pricing, MacBook-feasible
- **Date Added**: 2026-11-26
- **Last Updated**: 2026-11-26

### [Cycle 2] Column-Granular Storage Tiering + Local-Cache Break-Even

- **Summary**: Store hot vs cold Parquet column chunks as separate blobs on different tiers (Hot vs Cool/Cold) plus optional local cache; closed-form per-column break-even extending the cloud five-minute rule to tier choice.
- **Why Promising**: Column-level tiering for analytics not found in search; Mac-feasible via trace-driven simulator.
- **Requirements**: query traces (TPC-H/DS, ClickBench), simulator, small Azure lifecycle validation.
- **Validation Plan**: simulate storage+op+retrieval $ vs latency per policy; validate on Azure small scale.
- **Evidence**: Cycle 2 ELO rank 2, 1500 (N8 F7 R7 C6). Threats: Five-Minute Rule for Data Analytics in the Cloud (2026); Cache Replacement in Direct-Access Cloud OLAP (arXiv 2611.33977).
- **Status**: feasible
- **Retrieval Tags**: storage tiering, column chunks, five-minute rule, caching, Azure Cool/Cold
- **Date Added**: 2026-11-26
- **Last Updated**: 2026-11-26

### [Cycle 2] io_uring Guidelines Re-validated on Cloud Ephemeral NVMe (Azure L-series)

- **Summary**: Re-test Jasny et al. (PVLDB 19) io_uring guidelines on virtualised Azure local NVMe; derive cloud corrections; revives cycle-1 adaptive controller on real Linux NVMe.
- **Why Promising**: Only route to credible io_uring numbers without bare metal.
- **Requirements**: L-series VM (free-trial vCPU quota/SKU availability unverified — likely blocker), liburing.
- **Evidence**: Cycle 2 ELO rank 3, 1469 (N6 F5 R8 C7).
- **Status**: feasible-conditional (needs quota check)
- **Retrieval Tags**: io_uring, Azure Lsv3, ephemeral NVMe, reproducibility
- **Date Added**: 2026-11-26
- **Last Updated**: 2026-11-26

### Telemetry-Driven Adaptive I/O-Path Controller for OLTP Storage Engines

- **Summary**: Runtime controller that routes each storage-engine I/O (sync pread/pwrite, io_uring buffered, io_uring+O_DIRECT) per request class using live completion-latency/queue-depth telemetry instead of a static hand-picked policy.
- **Why Promising**: Highest relevance (targets a gap Oracle's own production io_uring integration paper documents but leaves unsolved — sync reads, the dominant OLTP I/O, see no io_uring benefit) and highest feasibility (software-only policy layer, no exotic hardware).
- **Requirements**: An open storage engine to instrument (LeanStore/Umbra-class or a Postgres io_uring build), eBPF/uringscope-style telemetry hooks, TPC-C/TPC-H-class benchmarks, mixed on-prem + cloud block-storage test environments.
- **Validation Plan**: (1) Reproduce the Oracle paper's finding that sync reads don't benefit from io_uring on a target engine; (2) instrument per-path completion latency; (3) build a simple hysteresis-based router; (4) compare against the static hybrid baseline and against an oracle (offline-optimal) policy.
- **Evidence**: Research-ideation cycle 2026-11-26; ELO tournament winner, Elo 1531 (Novelty 7, Feasibility 8, Relevance 9, Clarity 8). User selected this direction (Idea 1) for full proposal expansion.
- **Status**: selected by user for proposal expansion (2026-11-26); proposal write-up (Step 7) deferred by user to a later session
- **Related Entries**: Minimal-Attack-Surface, Portable io_uring Storage Engines; io_uring-Native Cloud WAL with Placement-Aware Batching
- **Retrieval Tags**: io_uring, adaptive I/O scheduling, OLTP storage engine, kernel write-back stalls, buffer manager, eBPF telemetry
- **Date Added**: 2026-11-26
- **Last Updated**: 2026-11-26

### Minimal-Attack-Surface, Portable io_uring Storage Engines

- **Summary**: Analyze a storage engine's actual io_uring call-site patterns to synthesize a minimal io_uring_restrictions()/BPF sandbox profile plus an xNVMe-style portability shim, reducing both io_uring's kernel attack surface and interface fragmentation as adoption barriers.
- **Why Promising**: Highest novelty — no DB-side paper addresses io_uring's security/adoption cost despite active OS-security research disclosing new io_uring kernel exploits.
- **Requirements**: Static/dynamic call-site analysis tooling, a target storage engine, io_uring_restrictions()/seccomp-BPF test harness, reproduction of at least one known io_uring CVE/exploit class for attack-surface measurement.
- **Validation Plan**: (1) Catalog the io_uring opcodes/features a real storage engine actually uses; (2) synthesize a minimal restriction profile; (3) measure attack-surface reduction against known vulnerability classes; (4) measure runtime overhead of the sandbox.
- **Evidence**: Research-ideation cycle 2026-11-26; ELO tournament rank 2, Elo 1501 (Novelty 9, Feasibility 8, Relevance 6, Clarity 8).
- **Status**: feasible
- **Related Entries**: Telemetry-Driven Adaptive I/O-Path Controller
- **Retrieval Tags**: io_uring security, attack surface reduction, io_uring_restrictions, xNVMe portability, DBMS adoption barriers
- **Date Added**: 2026-11-26
- **Last Updated**: 2026-11-26

### io_uring-Native Cloud WAL with Placement-Aware Batching

- **Summary**: Fuse quorum-replicated SSD-backed log nodes (BtrLog-style) with io_uring's own batching primitives (linked SQEs/multishot) to implement the greedy-pipelined optimal group-commit policy natively in the ring, attaching NVMe FDP placement hints per physical write burst.
- **Why Promising**: First combination of ring-native batching + FDP placement + quorum log replication; strong fit to the WAL/commit sub-focus of this cycle.
- **Requirements**: A quorum log-replication service (or BtrLog-like reference), io_uring linked-SQE/multishot support, FDP-capable NVMe hardware (specialized, harder to source) or an FDP emulator.
- **Validation Plan**: (1) Build/adapt a BtrLog-style log node with io_uring linked-SQE batching; (2) validate the greedy-pipelined policy's self-clocking claim holds when implemented ring-natively; (3) add FDP Reclaim-Unit hints and measure write-amplification change; (4) end-to-end OLTP commit-latency/throughput comparison.
- **Evidence**: Research-ideation cycle 2026-11-26; ELO tournament rank 3, Elo 1468 (Novelty 8, Feasibility 6, Relevance 8, Clarity 7).
- **Status**: feasible
- **Related Entries**: Telemetry-Driven Adaptive I/O-Path Controller
- **Retrieval Tags**: io_uring, write-ahead log, group commit, NVMe FDP, cloud OLTP, quorum replication
- **Date Added**: 2026-11-26
- **Last Updated**: 2026-11-26

### Seeds for a future cycle (not pursued this cycle — recorded, not scored)

- **GPU-resident analytical storage engines via GPU io_uring**: cross-domain transfer of the GPU-direct io_uring pattern from LLM KV-cache serving (Tutti, arXiv:2605.03375) into GPU-accelerated OLAP buffer pools. Not scored — judged less feasible/aligned for this cycle's storage-engine/WAL focus; worth a dedicated cycle if the user's next goal shifts toward GPU-accelerated analytics.
- **TEE/confidential-computing DBMS storage engines bridged by io_uring**: cross-domain transfer from Ringmaster (arXiv:2601.16448), which uses io_uring to let TrustZone TEEs access untrusted OS services asynchronously. Not scored — same reason as above.

## Unsuccessful Directions

### io_uring experiments on macOS host

- **Failure type**: fundamental (hardware/OS) — XNU has no io_uring; POSIX AIO = 4 kernel threads doing sync reads; Linux VM disks = virtio over APFS RAW image. Cycle-1 io_uring directions are NOT Mac-feasible; need Linux NVMe (cloud VM or bare metal).
- **Date**: 2026-11-26

### Cross-cloud price comparison as main contribution

- **Failure type**: fundamental (novelty/confounds) — differing networks confound timing; price comparison alone not research.
- **Date**: 2026-11-26

### Learned column-tiering policy

- **Failure type**: implementation-level prune — crowded learned-cache space; keep closed-form rule instead.
- **Date**: 2026-11-26

## Archive

_Nothing archived yet._
