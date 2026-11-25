# Knowledge Base Verification

**Date:** 2026-11-25
**Scope:** `coding/` collection after condensation
**Result:** Structure, links, and consistency checked. Code samples are not compiled or executed.

## Structure

```
coding/
├── README.md              # Navigation, working mode, authority (61 lines)
├── CODING_PRINCIPLES.md   # Language-independent principles (132 lines)
├── VERIFICATION.md        # This file
├── cpp/README.md          # C++17/20 guide (324 lines)
├── python/README.md       # Python 3.10+ guide (323 lines)
├── rust/README.md         # Rust 1.70+ guide (334 lines)
└── cuda/README.md         # CUDA 11+ guide (326 lines)
```

Seven files, about 1,570 lines total (previously 4,233 across ten files): a 63% reduction.

Each language directory now holds a single self-contained guide. The former `*-guide.md` files were
merged into the directory `README.md`; content deleted from a guide is recoverable from git history.

## Checks Performed

| Check | Method | Result |
|-------|--------|--------|
| File tree and line counts | `wc -l`, `git status` | Match table above |
| Internal links | Manual review of relative paths | All targets exist |
| Section anchors | TOC entries match headings | Consistent |
| Duplicate content | Read-through of all guides | Shared principles only in `CODING_PRINCIPLES.md` |
| Version claims | Spot-check against known specs | C++17, Python 3.10, Rust 1.70, CUDA 11 unchanged |
| Python typing rules | Read-through | All recommended examples annotated |

Not performed: compiling the C++/CUDA samples, running the Rust or Python samples, link checking with
an external tool. Treat examples as illustrative patterns verified by reading, not as tested code.

## Coverage

| Topic | C++ | Python | Rust | CUDA |
|-------|-----|--------|------|------|
| Fundamentals | yes | yes | yes | yes |
| Memory and ownership | yes | yes | yes | yes |
| Type system | yes | yes | yes | — |
| Error handling | yes | yes | yes | yes |
| Concurrency | yes | yes | yes | streams, atomics |
| Performance | yes | yes | yes | yes |
| Testing | yes | yes | yes | debugging, profiling |
| Anti-patterns | yes | yes | yes | implicit |
| Project layout | yes | yes | yes | — |

CUDA has no separate concurrency section by design: kernels are parallel execution, and the guide covers
synchronization, atomics, and streams instead.

## Consistency

- Shared principles (correctness first, explicit errors, clear ownership, profile before optimizing,
  verify before claiming) appear only in `CODING_PRINCIPLES.md` and are referenced, not restated.
- Every language guide ends with references to official documentation and links back to
  `CODING_PRINCIPLES.md` and `README.md`.
- Authority order is stated once in each entry point: specification, repository conventions, language
  guide, general principles.

## Known Limitations

- Examples are condensed for clarity; helper types and imports are sometimes elided (noted inline where
  relevant).
- No runtime benchmarks are claimed anywhere; performance guidance is qualitative.
- Language coverage is C++, Python, Rust, CUDA by design. C, SQL, and others are out of scope.
