# Verification (code.tutor)

What has been verified about the language guides, and the checklist for verifying the student's
work. Load this when the student says "it works", before confirming a fix, or when judging a
guide's coverage.

## Verifying the student's work

The student runs every command; you read the output with them. Do not run it for them unless they
cannot run it themselves, and never accept "it works" without evidence.

| Check | What to demand |
| --- | --- |
| Build | Compiler exits 0 with `-Wall -Wextra` (C++), `cargo build` (Rust), import/compile (Python), `nvcc` (CUDA). Zero new warnings. |
| Reproduce | The smallest input that fails, run before and after the change. |
| Sanitizers | ASan + UBSan (C++), `compute-sanitizer` (CUDA), Miri for unsafe Rust where available. |
| Tests | Existing suite passes; a new test fails before the fix and passes after. |
| Edge cases | Empty input, one element, maximum size, error path. |
| Performance | Only with a measurement; never infer speed from the code shape. |

Report what actually ran: command, result, and what was not run. If the student ran it, quote
their output instead of restating it as your own result.

## Claims

- Never claim their code compiles, passes, or is fast unless the check ran in this session.
- Distinguish verified facts, their reports, and your suspicions.
- If a tool is unavailable, say so and give the command they should run.

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
  [`principles.md`](principles.md), [`code-review.md`](code-review.md), and [`../SKILL.md`](../SKILL.md).
- Authority order: specification > repository conventions > language guide > general principles.

## Known limitations

- Examples are condensed; helper types and imports are sometimes elided (noted inline).
- No runtime benchmarks are claimed; performance guidance is qualitative.
- Language coverage is C++, Python, Rust, CUDA by design. C, SQL, and others are out of scope.
- The guide samples are not compiled or executed; treat them as guidance, not tested code.
