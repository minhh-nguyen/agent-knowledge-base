---
name: Agent Knowledge Base
description: Mandatory coding, review, tutoring, and knowledge-base conventions stored in ~/agent-knowledge-base. Load before any coding, code-review, documentation, or programming-tutoring task.
---

# Agent Knowledge Base

Repository root: `~/agent-knowledge-base` (absolute: `/Users/minhnguyen/agent-knowledge-base`).

This skill is authoritative for coding, code review, programming tutoring, and knowledge-base maintenance. Follow it before applying generic habits.

## 1. Load Context First

Read these before changing code or documentation:

1. `../../AGENTS.md` — operating rules for this knowledge base.
2. `../../README.md` — structure, workflows, principles.

If they are already present in the conversation, do not re-read them.

## 2. Coding Tasks

Apply, in this order:

1. The task's specification or the repository's own conventions.
2. The matching language guide:
   - `../../coding/cpp/README.md`
   - `../../coding/python/README.md`
   - `../../coding/rust/README.md`
   - `../../coding/cuda/README.md`
3. `../../coding/CODING_PRINCIPLES.md` for language-independent rules.
4. `../../coding/VERIFICATION.md` for what has and has not been verified.

Requirements:

- Inspect the project structure, relevant sources, and dependencies before editing.
- Keep changes focused and minimal; no unrelated refactors.
- Python: annotate every parameter and return value; prefer precise types over `Any`.
- Handle errors and edge cases explicitly; explain *why* in comments, not *what*.
- Never claim code was tested, built, or verified unless the check actually ran. Report the exact commands executed.
- Distinguish verified facts from assumptions; never invent APIs or version-dependent behavior.

## 3. Review Tasks

- Report correctness issues before style issues.
- Explain the defect and the improvement; do not rewrite everything.
- Flag unverified claims, missing error handling, and untested paths.
- Cite the relevant section of the language guide or `CODING_PRINCIPLES.md` when a rule is disputed.

## 4. Tutoring Tasks

- Start from the underlying problem, then the mechanism, then the code.
- Use small, practical examples.
- Explain trade-offs, memory, and performance when relevant.
- Prefer hints and guided reasoning over complete solutions unless the user asks for the solution.
- Adapt depth to the user's demonstrated knowledge.

## 5. Knowledge Base Maintenance

- Search existing files before creating new ones; update instead of duplicating.
- Use Markdown and lowercase kebab-case filenames; link with relative paths.
- Shared principles live only in `coding/CODING_PRINCIPLES.md`; language-specific guidance stays in its language directory.
- Preserve original sources and existing content; never delete or move without permission.
- Reopen every modified file to verify the change.

## 6. Project Work

- Record architecture decisions and project-specific conventions in `../../projects/`.
- Keep documentation synchronized with implementation.
- Link related concepts instead of copying them.

## Enforcement

If a request conflicts with these rules, state the conflict and follow the rules unless the user explicitly overrides them.
