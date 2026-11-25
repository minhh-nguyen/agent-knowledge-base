# Agent Knowledge Base

A local-first programming knowledge base shared by Hermes Agent and OpenCode.

## Purpose

Store, organize, and retrieve long-term programming knowledge to support two main roles:

- **Coding Agent:** Assist with implementation, debugging, code review, testing, refactoring, and software development.
- **Programming Tutor:** Explain programming concepts, teach problem-solving, and help the user develop programming skills.

The knowledge base focuses on practical software engineering, clean code, and continuous learning.

## Structure

- `AGENTS.md`: operating rules for agents working in this knowledge base.
- `CODING_PRINCIPLES.md`: language-independent principles (repository root).
- `VERIFICATION.md`: what has and has not been verified.
- `inbox/`: Temporary notes, code snippets, and unorganized programming knowledge.
- `coding/`: Programming principles and language-specific guides.
  - `cpp/`: C++ programming knowledge.
  - `python/`: Python programming knowledge.
  - `rust/`: Rust programming knowledge.
  - `cuda/`: CUDA and GPU programming knowledge.
- `references/`: External documentation, useful resources, and technical references.
- `templates/`: Reusable templates for programming notes and documentation.
- `skills/`: OpenCode skill wrappers that expose this knowledge base to agents.

## Workflows

### Adding Programming Knowledge

1. Identify the relevant programming language or topic.
2. Search existing documentation before creating a new file.
3. Add or update the appropriate Markdown document.
4. Include practical examples and explanations.
5. Add reliable references when relevant.
6. Link related concepts and documents.

### Learning a Programming Concept

1. Identify the concept the user wants to understand.
2. Consult the relevant language guide.
3. Explain the underlying problem and mechanism.
4. Use small, practical examples.
5. Explain important trade-offs and common mistakes.
6. Provide exercises when appropriate.

### Working on a Project

1. Inspect the project structure and existing documentation.
2. Understand its architecture, dependencies, and conventions.
3. Record important project-specific decisions in `projects/`.
4. Keep documentation synchronized with implementation.
5. Link relevant programming concepts and references.

### Recording Useful Knowledge

1. Store temporary information in `inbox/`.
2. Review and organize it into the appropriate directory.
3. Keep explanations concise and reusable.
4. Avoid duplicating existing knowledge.
5. Preserve useful source links and technical context.

## Reuse Across Projects

This repository is **one source of truth installed into many projects**, never copied per project.
Copies drift: a principle fixed here would stay stale everywhere else, with no path back.

Install it, in order of preference:

| Situation | Mechanism |
| --- | --- |
| One machine, personal use | Symlink the skill into the global skills directory (below). Every project sees it. |
| Several machines, or shared with others | Package `skills/agent-knowledge-base` as a plugin and install it per machine. Versioned and updatable. |
| A project must pin a specific revision, or work offline | Add this repository as a `git submodule` and symlink the skill from there. |
| A project genuinely needs different rules | Only then fork or copy — and treat the copy as a separate knowledge base. |

### Symlink install

```sh
ln -sfn "$PWD/skills/agent-knowledge-base" ~/.claude/skills/agent-knowledge-base
```

The skill resolves every path relative to itself (`../../`), so it works from any checkout
location regardless of how it was installed.

### Per-project usage

A consuming project does not copy knowledge. It adds a short `AGENTS.md` that delegates:

```markdown
# AGENTS.md

Load the `agent-knowledge-base` skill before any coding, review, or documentation task.

## Project-specific overrides

- <only rules that genuinely differ from the knowledge base>
```

Precedence: project overrides > knowledge base > generic agent habits.
Project-specific decisions are recorded in `projects/<project>.md` here, or in the project itself
when they are implementation details rather than reusable knowledge.

## Principles

- Markdown is the primary format for written knowledge.
- Prioritize correctness, readability, and maintainability.
- Prefer practical examples over generic explanations.
- Explain why and when a programming technique should be used.
- Keep language-independent principles separate from language-specific knowledge.
- Preserve original source documents and distinguish them from generated explanations.
- Prefer links between related documents over duplicated content.
- Use reliable references and never invent technical claims.
- Keep temporary information in `inbox/` until reviewed.
- Follow `AGENTS.md` when managing or modifying the knowledge base.
