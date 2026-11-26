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
- Keep shared, language-independent principles only in
  `skills/agentic-coder/references/principles.md`.
- Keep language-specific guidance in its own file: `references/{cpp,python,rust,cuda}.md`.
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
- Skills must not overlap: when two could apply, each names the other and the handover rule.
