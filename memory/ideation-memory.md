# Ideation Memory

Last Updated: 2026-11-26
Total Cycles: 1

## Feasible Directions

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

_None yet — first cycle; no direction has reached experimental validation._

## Archive

_Nothing archived yet._
