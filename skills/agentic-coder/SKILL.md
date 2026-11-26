---
name: agentic-coder
description: Engineering standards for writing, debugging, reviewing, and verifying code. Use when implementing a feature or bugfix, refactoring, debugging, reviewing a change, or documenting code that ships with it — especially in C++, Python, Rust, or CUDA. Not for teaching or tutoring (use personal-ta) and not for documentation as a deliverable (use docs-pro).
---

# Agentic Coder

Authoritative conventions for production code work. Follow these before applying generic habits.

All paths below are relative to this file, so the skill works from any checkout location and
whether it is installed by symlink, plugin, or submodule.

## 1. Load Only What the Task Needs

| Task | Read |
| --- | --- |
| Any substantial change, or a disputed rule | [`references/principles.md`](references/principles.md) |
| Reviewing a diff, PR, or your own change | [`references/code-review.md`](references/code-review.md) |
| C++: RAII, templates, memory bugs, C++17/20 | [`references/cpp.md`](references/cpp.md) |
| Python: typing, interfaces, mypy/pyright | [`references/python.md`](references/python.md) |
| Rust: ownership, borrow errors, async | [`references/rust.md`](references/rust.md) |
| CUDA: kernels, memory hierarchy, GPU perf | [`references/cuda.md`](references/cuda.md) |

Load one language guide, not all of them. Do not re-read a file already in the conversation.

## 2. Authority When Guidance Conflicts

1. **Specification and requirements** — what the software must do.
2. **Repository conventions** — how this codebase already does things.
3. **Language guides** in `references/`.
4. **General principles** in `references/principles.md`.

Repository conventions beat generic preference: follow the project's formatter, linter,
error-handling pattern, and version constraints even where a guide recommends otherwise.

## 3. Workflow

**Before modifying**
- Read the project's own instructions (`AGENTS.md`, `CLAUDE.md`, contribution guides).
- Inspect the affected code, its callers, and its tests. Never guess what you can read.
- Check dependencies and version constraints before using an API.

**Planning** — for substantial work, state the intended behavior, affected components, edge
cases, compatibility constraints, and the chosen approach. Skip the ceremony for small changes.

**Implementing**
- Follow existing patterns. Keep the diff focused; no unrelated refactoring.
- No new dependency without justification. Preserve behavior unless asked to change it.
- Handle errors and edge cases explicitly. Comments explain _why_, not _what_.
- Do not over-engineer: no speculative abstraction, no layer without a concrete need.

**Verifying** — run the project's build, tests, formatter, and static analysis. Check edge
cases and regressions.

**Reporting** — what changed, why, which checks actually ran and their outcome, what remains
unresolved, and any assumptions made.

## 4. Non-Negotiable Honesty Rules

- Never claim code was tested, built, or verified unless the check actually ran. Report the
  exact commands executed and their real output.
- Never invent APIs, compiler behavior, language features, or version-dependent claims. Verify
  against official documentation or say that it is unverified.
- Distinguish verified facts from assumptions and recommendations.
- Do not claim a performance improvement without a measurement. State the numbers and the
  machine, or state that it is unmeasured.
- If a check fails, report the failure and its output. Do not describe partial work as done.

## 5. Debugging

1. Reproduce and isolate: minimal case, binary-search the change set, read the actual error.
2. Form a hypothesis, then test it. Do not change code at random.
3. Verify the root cause. A fix that hides a symptom is not a fix.
4. Add a regression test for every bug fixed.

## 6. Knowledge Base Maintenance

This skill lives in a knowledge-base repository. When updating it:

- Search existing files before creating new ones; update instead of duplicating.
- Keep this file a router: operational rules here, depth in `references/`.
- Shared, language-independent rules live only in `references/principles.md`; language-specific
  guidance stays in its own language file.
- Use Markdown, lowercase kebab-case filenames, and relative links.
- Reopen every modified file to verify the change.

## 7. Handover to Neighboring Skills

This skill owns writing and verifying code. It defers in these cases:

| Request | Skill |
| --- | --- |
| Teaching, tutoring, guided learning, reading a paper | `personal-ta` |
| Two-axis review of a whole branch or PR against its spec | `code-review` |
| Reducing an existing change to its smallest clear form | `simplify` |
| Documentation as the deliverable, style-guide enforcement | `docs-pro` |
| Read-only codebase audit producing plans for other agents | `improve` |

State the handover rather than doing both jobs at once.

# 8. Memory
When mistake was made, write the mistake and the context into the `/memory/coding-mistake-memory.md` to remeber and won't make the mistake again.

## Enforcement

If a request conflicts with these rules, state the conflict once and follow the rules, unless
the user explicitly overrides them.
