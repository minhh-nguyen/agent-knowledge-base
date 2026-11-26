# Code Review

Checklists for reviewing a change — your own or someone else's. Load before any review task.
Related: [`principles.md`](principles.md), [`../SKILL.md`](../SKILL.md).

**Scope.** This file covers reviewing a change you can already see: a diff, a file, a patch.
A two-axis review of a whole branch or pull request against its originating spec belongs to
the separate `code-review` skill, which drives that as a workflow. Use that one for branch
scope, this one for the judgement applied inside it.

## Order of Reporting

1. **Correctness** — the change does the wrong thing, or breaks something that worked.
2. **Safety** — memory, concurrency, resource leaks, untrusted input.
3. **Maintainability** — structure, naming, duplication, test coverage.
4. **Style** — formatting and preference, last and clearly labeled as such.

Never lead with style. Say explicitly which findings are defects and which are preferences.

## Review Checklist

**Correctness**
- Does the change satisfy the stated requirement, including the cases the requirement implies?
- Boundaries: empty, zero, one, maximum, negative, duplicate, unsorted, unicode.
- Off-by-one, integer overflow, truncating conversion, mixed units.
- Concurrency: shared mutable state, lock ordering, atomicity of multi-step updates.

**Error paths**
- Every failure handled or deliberately propagated; nothing silently swallowed.
- Cleanup runs on early returns and exception paths, not only the happy path.
- Error messages name the operation, the offending input, and the reason.
- No partially-updated state left behind after a failure.

**Resources**
- One clear owner per resource; deterministic release (RAII, `with`, `defer`).
- No lock or connection held across unrelated work.
- No unbounded growth: caches, queues, retries, recursion depth.

**Security**
- Untrusted input validated at the boundary; injection (SQL, shell, path, template) closed off.
- No secrets in code, logs, or error messages.
- Overflow, deserialization, and TOCTOU paths considered where relevant.

**Tests**
- Does a test actually fail without this change?
- Behavior tested, not internals; boundaries and error paths covered.
- No test that passes for the wrong reason (unasserted mock, swallowed exception).

**Maintainability**
- Diff focused: no unrelated refactoring mixed in.
- Names carry meaning; no comment needed to explain the name.
- No duplicated logic introduced; no speculative abstraction.
- Documentation and comments updated with the behavior they describe.

## Reporting a Review

For each finding, give: the location, what is wrong, a concrete failing scenario, and the
smallest fix. Cite the relevant section of a language guide or [`principles.md`](principles.md)
when a rule is disputed.

Do not rewrite the author's approach when it is fundamentally sound. Improve it in place.

## Honesty Rules

- Flag unverified claims, missing error handling, and untested paths explicitly.
- Never state that a check passed unless it ran. Report the exact command and its outcome.
- Distinguish a defect you can demonstrate from a concern you suspect.
- If the change is correct and the only findings are preferences, say so plainly.
