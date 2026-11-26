# Knowledge Base Verification

**Scope:** repository restructured into self-contained skill bundles under `skills/`
**Result:** Structure, links, line limits, and consistency checked. Code samples are not compiled
or executed.

## Structure

```
skills/
├── agentic-coder/
│   ├── SKILL.md                      # router (92 lines)
│   └── references/
│       ├── principles.md             # language-independent principles (93 lines)
│       ├── code-review.md            # review checklists (63 lines)
│       ├── cpp.md                    # C++17/20 guide (324 lines)
│       ├── python.md                 # Python 3.10+ guide (323 lines)
│       ├── rust.md                   # Rust 1.70+ guide (334 lines)
│       └── cuda.md                   # CUDA 11+ guide (326 lines)
└── personal-ta/
    └── SKILL.md                      # teaching and research mentorship (194 lines)
```

Every `SKILL.md` is under the 500-line limit. All reference paths are relative to their own
`SKILL.md` and stay inside the skill directory, so a skill works by symlink, plugin, or
submodule without path rewriting.

The former `coding/` tree was moved into `skills/agentic-coder/references/` with `git mv`, so the
history of every guide is preserved. `CODING_PRINCIPLES.md` became `references/principles.md`; its
workflow section moved into `SKILL.md` and its tutoring section into the `personal-ta` skill.

## Checks Performed

| Check                     | Method                          | Result                                           |
| ------------------------- | ------------------------------- | ------------------------------------------------ |
| File tree and line counts | `wc -l`, `git status`           | Match table above                                |
| Internal links            | Script over every `*.md` link   | 0 broken (3 hits are code snippets, not links)   |
| `SKILL.md` line limit     | `wc -l` on every `SKILL.md`     | 92 and 194 lines; limit is 500                   |
| Skill path isolation      | `grep` for `../../` in skills   | None; no path escapes a skill directory          |
| Skill trigger overlap     | Read both `description` fields  | Disjoint; each names the other for handover      |
| Section anchors           | TOC entries match headings      | Consistent                                       |
| Duplicate content         | Read-through of all guides      | Shared principles only in `principles.md`        |
| Version claims            | Spot-check against known specs  | C++17, Python 3.10, Rust 1.70, CUDA 11 unchanged |
| Python typing rules       | Read-through                    | All recommended examples annotated               |

Not performed: compiling the C++/CUDA samples, running the Rust or Python samples, and any test of
how a specific agent runtime resolves a symlinked skill directory. Treat examples as illustrative
patterns verified by reading, not as tested code.

## Coverage

| Topic                | C++ | Python | Rust | CUDA                 |
| -------------------- | --- | ------ | ---- | -------------------- |
| Fundamentals         | yes | yes    | yes  | yes                  |
| Memory and ownership | yes | yes    | yes  | yes                  |
| Type system          | yes | yes    | yes  | —                    |
| Error handling       | yes | yes    | yes  | yes                  |
| Concurrency          | yes | yes    | yes  | streams, atomics     |
| Performance          | yes | yes    | yes  | yes                  |
| Testing              | yes | yes    | yes  | debugging, profiling |
| Anti-patterns        | yes | yes    | yes  | implicit             |
| Project layout       | yes | yes    | yes  | —                    |

CUDA has no separate concurrency section by design: kernels are parallel execution, and the guide covers
synchronization, atomics, and streams instead.

## Consistency

- Shared principles (correctness first, explicit errors, clear ownership, profile before optimizing,
  verify before claiming) appear only in `references/principles.md` and are referenced, not restated.
- Every language guide ends with references to official documentation and links back to
  `principles.md`, `code-review.md`, and its `SKILL.md`.
- Authority order is stated once in each entry point: specification, repository conventions, language
  guide, general principles.

## Known Limitations

- Examples are condensed for clarity; helper types and imports are sometimes elided (noted inline where
  relevant).
- No runtime benchmarks are claimed anywhere; performance guidance is qualitative.
- Language coverage is C++, Python, Rust, CUDA by design. C, SQL, and others are out of scope.
