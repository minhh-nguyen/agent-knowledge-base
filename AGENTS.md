# Agent Instructions

These rules apply to every AI agent working in this knowledge base.

## 1. General Behavior

- Read `AGENTS.md` and `README.md` before modifying the knowledge base.
- Inspect existing files and search for relevant content before creating new ones.
- Reuse and update existing documents when appropriate.
- Keep documentation concise, structured, and technically accurate.
- Avoid unnecessary duplication, abstractions, and restructuring.

## 2. Coding Standards

- Write clean, readable, maintainable, and idiomatic code.
- Prefer simple solutions over unnecessary complexity.
- Use meaningful names and keep functions and modules focused.
- Handle errors and edge cases appropriately.
- Prioritize correctness, readability, and maintainability over premature optimization.
- Use comments to explain why, not simply what the code does.
- Follow language-specific conventions and existing project standards.

## 3. Coding Agent

Before modifying code:

- Inspect the project structure, relevant source files, and dependencies.
- Read applicable project instructions and understand existing conventions.
- Understand the problem before choosing an implementation.

When implementing:

- Keep changes focused and minimal.
- Avoid unrelated refactoring and unnecessary dependencies.
- Consider edge cases, compatibility, and error handling.

Before reporting completion:

- Run relevant tests, builds, or static checks when available.
- Report which checks were actually executed.
- Never claim something was tested or verified if it was not.

## 4. Programming Tutor

Help the user understand programming, not just obtain solutions.

- Explain concepts step by step, starting with the underlying problem.
- Explain how and why code works.
- Use small, practical examples.
- Discuss trade-offs, memory, and performance when relevant.
- When helping solve problems, prefer hints and guided reasoning over immediately giving complete solutions, unless requested.
- When reviewing code, explain correctness issues and improvements without unnecessarily rewriting everything.
- Adapt explanations to the user's demonstrated knowledge.

## 5. Technical Accuracy

- Never invent APIs, language features, or technical claims.
- Verify version-dependent behavior using reliable documentation.
- Distinguish verified facts from assumptions and recommendations.
- State uncertainty when information is incomplete.
- Do not claim performance improvements without sufficient evidence.

## 6. Knowledge Base Management

- Use Markdown and descriptive lowercase kebab-case filenames.
- Use relative links between documents.
- Knowledge is delivered as skills under `skills/`. Read `README.md` for the layout.
- Keep shared, language-independent coding principles only in `references/principles.md` of the
  code skills (`[role: code.tutor]` and `[role: code.build]`). The two copies must stay identical
  apart from links to references a skill does not bundle (for example `code-review.md`): change
  both in the same commit.
- Keep language-specific guidance in its own file next to it: `references/{cpp,python,rust,cuda}.md`,
  mirrored the same way.
- Keep `references/verification.md` mirrored between the two code skills: the coverage,
  consistency, and limitations sections stay identical apart from links to references a skill does
  not bundle, while the checklist differs by mode (tutor vs builder).
- Keep `references/lecture-materials.md` mirrored between `[role: study.tutor]` and
  `[role: study.lecture]`: everything before the final section stays identical; only the final
  section ("Then teach" / "Then write") differs. Change both in the same commit.
- Check for existing content before creating documentation.
- Preserve original files and do not delete or move existing content without permission.
- Reopen modified files to verify changes.

## 7. Skill Authoring

- A `SKILL.md` is a router: when to trigger, the workflow, hard rules, and a table of which
  reference to load for which task. Depth belongs in `references/`.
- Every `SKILL.md` stays under 500 lines. Move overflow into `references/`.
- Write skills in English, including skills intended for non-English conversations.
- The frontmatter `description` must state when to use the skill and when not to, because it is
  the only text an agent sees when deciding whether to load it.
- Reference paths must be relative to the `SKILL.md` and must not escape the skill directory.
  No `../../` into the repository root.
- Skills must not overlap: when two could apply, each points to the other and states the handover rule.
- **Refer to other skills by role tag, never by name.** Every repository skill declares its stable
  role at the start of its `description` as `[role: <domain>.<function>]`. Handovers say
  "use `[role: research.find]`", so renaming a skill touches only its folder and its frontmatter
  `name`.
- **Only this repository stores data.** Skills write memory to `~/.claude/memory/`, reports,
  ideas, and scratch files to `~/.claude/research-report/`, and course study material to
  `~/.claude/study/<course>/`: symlinks named exactly like the repository's `memory/`,
  `research-report/`, and `study/` folders. A skill folder holds method only, never state. Never write a `memory/`, report, or
  scratch folder into the project the skill runs in, and never fall back to it when a link is
  missing: tell the user instead.
- Mistake logs record only the skill's own mistakes, never the user's. Entries carry the language
  and a title, no date.
- Each description states its mode: **learn** (coach the user, who does the work) or **do**
  (produce the output). Two skills in the same domain must differ in mode or function.
- Before committing a skill change, check by hand that every role tag resolves to a declared role,
  every `name` matches its folder, and no `SKILL.md` exceeds 500 lines.
- A skill that reads large external material must define a retrieval protocol that reads
  fragments, not whole documents, and must state the cost rules that enforce it.
- A third-party skill is either **external** (left in `~/.agents/skills`, receives upstream updates,
  cannot carry a role tag) or **copied** into `skills/` and owned here: it gets a role tag and
  follows every rule above. Re-syncing it from upstream is a merge, not an overwrite.
- Resolve a trigger collision by narrowing a repository skill's `description`, or by moving one of
  the colliding skills out of `skills/`. Never edit an external skill's `SKILL.md`: the next
  upstream update overwrites the edit.
