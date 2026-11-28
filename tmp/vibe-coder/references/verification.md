# Verification (code.build)

What has been verified about the language guides, and the checklist for verifying a change. Load
this before reporting a part as done.

## Verifying the change

Run the check before reporting a part as done. Use the project's own commands when they exist.

| Check | What to run |
| --- | --- |
| Build | The project's build command; it must exit 0. |
| Tests | The existing suite. Add a test only when the repo already tests that area or the behaviour is easy to get wrong. |
| Lint / format | The repo's linter and formatter if configured; do not introduce a new one. |
| Behaviour | Run the changed path end to end, not just the compiler. |
| Edge cases | Empty input, one element, boundary size, error path. |
| Diff | Re-read it: only the requested change, and every planned part is represented. |

Report the exact command and result for each check. If a check cannot run, say so and name the
command the user should run.

## Claims

- Never claim code compiles, passes, or is fast unless the check ran in this session.
- Distinguish verified facts, the user's reports, and your suspicions.
- If a tool is unavailable, say so explicitly.

## Language guide coverage

| Topic | C++ | Python | Rust | CUDA |
| --- | --- | --- | --- | --- |
| Fundamentals | yes | yes | yes | yes |
| Memory and ownership | yes | yes | yes | yes |
| Type system | yes | yes | yes | — |
| Error handling | yes | yes | yes | yes |
| Concurrency | yes | yes | yes | streams, atomics |
| Performance | yes | yes | yes | yes |
| Testing | yes | yes | yes | debugging, profiling |
| Anti-patterns | yes | yes | yes | implicit |
| Project layout | yes | yes | yes | — |

CUDA has no separate concurrency section by design: kernels are parallel execution, and the guide
covers synchronization, atomics, and streams instead.

## Consistency

- Shared principles (correctness first, explicit errors, clear ownership, profile before
  optimizing, verify before claiming) appear only in [`principles.md`](principles.md) and are
  referenced, not restated.
- Every language guide ends with official documentation links and links back to
  [`principles.md`](principles.md) and [`../SKILL.md`](../SKILL.md).
- Authority order: specification > repository conventions > language guide > general principles.

## Known limitations

- Examples are condensed; helper types and imports are sometimes elided (noted inline).
- No runtime benchmarks are claimed; performance guidance is qualitative.
- Language coverage is C++, Python, Rust, CUDA by design. C, SQL, and others are out of scope.
- The guide samples are not compiled or executed; treat them as guidance, not tested code.
