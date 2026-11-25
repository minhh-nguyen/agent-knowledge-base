# Coding Principles

Language-independent principles for all software work. Language-specific guidance lives in:

- [`cpp/`](coding/cpp/README.md)
- [`python/`](coding/python/README.md)
- [`rust/`](coding/rust/README.md)
- [`cuda/`](coding/cuda/README.md).

## Priorities

1. **Correctness** — it must do what the specification says.
2. **Readability and maintainability** — code is read far more often than written.
3. **Simplicity** — the simplest solution that works; no speculative abstraction.
4. **Efficiency** — avoid waste, but never trade correctness or clarity for unmeasured speed.
5. **Extensibility** — design for change only when a concrete need exists.

## Writing Code

- **Names carry meaning.** A good name removes the need for a comment.
- **One responsibility per function, module, class.** Split at the seams where behavior changes.
- **Avoid duplication.** Repeated logic is a bug farm; extract when the second use appears.
- **Prefer clarity over cleverness.** Code golf is not engineering.
- **Handle errors explicitly.** No silent failure, no swallowed exceptions.
- **Minimize dependencies.** Every dependency is a cost in audit, update, and supply-chain risk.
- **Make ownership and side effects visible.** A reader should know what allocates, mutates, and blocks.
- **Prefer composition over inheritance.** Deep hierarchies become fragile.
- **Follow established conventions** of the language and the codebase.

## Comments and Documentation

- Comments explain **why** (constraints, trade-offs, incidents), not **what** the code already says.
- Document non-obvious behavior, invariants, units, and ownership.
- Keep documentation in sync with code; stale docs are worse than none.
- No line-by-line narration.

## Structure and Interfaces

- Organize by domain so a newcomer can find things; mirror module and test layout.
- Keep interfaces small, explicit, and hard to misuse; hide representation.
- Avoid tight coupling; components should be testable in isolation.
- Use established patterns when they solve a real problem, not to look architectural.
- Design for testability — hard-to-test code signals tangled dependencies.

## Error Handling

- Distinguish **expected outcomes** (validation failure, missing key) from **programmer errors** (invariant
  violations) from **environmental failures** (I/O, network, allocation).
- Use the language's idiom: exceptions, `Result`/`Option`, error codes, or a typed error enum.
- Error messages must name the operation, the offending input, and the reason.
- Never use exceptions for ordinary control flow.
- Clean up on every path; never leave partially-updated state.

## Resource Management

- **Explicit ownership** — one clear owner per resource (memory, handles, sockets, locks).
- **Deterministic cleanup** — destructors, `with`, `defer`, `RAII`; not manual bookkeeping scattered across exits.
- Release resources as early as possible; don't hold locks or connections while doing unrelated work.
- Verify cleanup on error paths and early returns, not just the happy path.

## Performance

- Understand the problem and the workload before optimizing.
- **Profile, then optimize** the measured bottleneck; intuition is unreliable.
- Optimize the algorithm before the constant factor.
- Change one thing at a time and measure the delta; record the numbers and the machine.
- Weigh complexity against the gain; reject optimizations that hurt clarity for noise-level speedups.
- State uncertainty when a performance claim is not measured.

## Testing and Verification

- Tests prove behavior and enable refactoring; write them for behavior, not internals.
- Cover boundaries: empty, zero, maximum, duplicates, error paths, concurrent access.
- Prefer test-first when requirements are clear; it exposes design problems early.
- Run formatters, linters, type checkers, and sanitizers where available.
- **Never claim code was tested unless the checks actually ran.** Report commands and outcomes verbatim.

## Debugging

- Reproduce and isolate first: minimal case, binary search the change set, read the actual error.
- Verify the root cause; a fix that hides a symptom is not a fix.
- Add a regression test for every bug fixed.
- Record the lesson — in the code comment, the commit message, or here.

---

## Coding Agent Behavior

**Before modifying:** read the repository's instructions and conventions, inspect the affected code and
its callers, check dependencies and version constraints. Never change code based on assumptions when the
implementation can be inspected.

**Planning:** for substantial work, state the intended behavior, affected components, edge cases,
compatibility constraints, and the chosen approach. Skip the ceremony for small, obvious changes.

**Implementing:** follow existing patterns, keep the diff focused, no unrelated refactoring, no new
dependencies without justification, preserve behavior unless asked to change it.

**Verifying:** run the relevant build, tests, formatter, and static analysis; check edge cases and
regressions. Report what actually ran.

**Reviewing your own change:** correctness, resource ownership, error paths, performance, security
(untrusted input, injection, secrets, overflow), readability, maintainability, unintended side effects.

**Reporting:** what changed, why, what was verified, what remains unresolved, and any assumptions.

## Programming Tutor Behavior

Adapt to intent, and prefer developing the learner's reasoning over producing answers.

**Learn mode** — the user wants to understand a mechanism. Start from the underlying problem, build up
with small examples, explain how and why it works, compare alternatives and their trade-offs, name common
misconceptions. Skip advanced detail that doesn't serve the question.

**Implement mode** — the user is solving a problem. Do not hand over a full solution unless asked.
Clarify the problem, decompose it, identify the relevant concepts, sketch approaches, give hints, let the
user attempt it, then review. The goal is independence, not copy-paste.

**Review mode** — the user wants their code improved. Go beyond line-by-line description: explain design
intent, execution flow, data movement, ownership and lifetime, dependencies, performance implications, and
alternatives. Keep their approach when it is fundamentally sound.

Core rules: distinguish actual bugs from style preferences and say which is which; explain the lesson
behind a fix; adapt to demonstrated knowledge without assuming it; be precise — a wrong explanation
teaches a wrong model.

## Authority When Guidance Conflicts

1. **Specification and requirements** — what the software must do.
2. **Repository conventions** — how this codebase does things.
3. **Language guides** — idiomatic practice for the language.
4. **These general principles** — fallback.

Repository conventions always win: follow the project's formatter, linter, error-handling patterns, and
version constraints even where a general guide recommends otherwise. Do not import generic preferences
into a codebase that has settled on its own.
