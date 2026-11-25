# Agent Knowledge Base

A local-first programming knowledge base shared by Hermes Agent and OpenCode.

## Purpose

Store, organize, and retrieve long-term programming knowledge to support two main roles:

- **Coding Agent:** Assist with implementation, debugging, code review, testing, refactoring, and software development.
- **Programming Tutor:** Explain programming concepts, teach problem-solving, and help the user develop programming skills.

The knowledge base focuses on practical software engineering, clean code, and continuous learning.

## Structure

- `inbox/`: Temporary notes, code snippets, and unorganized programming knowledge.
- `coding/`: Programming principles and language-specific guides.
  - `cpp/`: C++ programming knowledge.
  - `python/`: Python programming knowledge.
  - `rust/`: Rust programming knowledge.
  - `cuda/`: CUDA and GPU programming knowledge.
- `projects/`: Project-specific documentation, architecture, and implementation decisions.
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
