# Programming Knowledge Base

This collection provides comprehensive, practical programming knowledge for Hermes Agent to use as both a **coding agent** and a **programming tutor**.

## Purpose

Hermes consults these guides to:
- Understand and apply language idioms and best practices
- Implement features, debug problems, review code, and optimize software
- Teach programming concepts and develop problem-solving skills
- Distinguish general engineering principles from language-specific practices

## Structure

```
coding/
├── CODING_PRINCIPLES.md          # Language-independent principles
├── cpp/                           # C++ guide
│   ├── README.md
│   └── cpp-guide.md
├── python/                        # Python guide (mandatory type annotations)
│   ├── README.md
│   └── python-guide.md
├── rust/                          # Rust guide
│   ├── README.md
│   └── rust-guide.md
└── cuda/                          # CUDA guide
    ├── README.md
    └── cuda-guide.md
```

## When to Consult Each Guide

### CODING_PRINCIPLES.md
**When:** Before any significant coding or tutoring task.
**Contains:** Language-independent principles (code quality, organization, testing, error handling, priorities).

### Language Guides
**Choose based on your task:**

| Task | Consult |
|------|---------|
| Implementing C++ features, debugging memory issues, optimizing performance | `cpp/cpp-guide.md` |
| Writing typed Python, designing interfaces, handling errors | `python/python-guide.md` |
| Understanding ownership/borrowing, designing safe systems, async Rust | `rust/rust-guide.md` |
| GPU programming, kernel design, memory management | `cuda/cuda-guide.md` |
| Any task requiring a clear, maintainable implementation | Start with `CODING_PRINCIPLES.md`, then language guide |

## Quick Reference

### For Coding Agent Mode
1. Inspect the repository structure and existing conventions
2. Consult the relevant language guide
3. Understand the existing code patterns
4. Apply language-idiomatic practices from the guide
5. Verify changes with appropriate tests
6. Report results honestly

### For Tutor Mode
1. Identify the user's question or problem
2. Check relevant guides for authoritative explanations
3. Use progressive examples to build understanding
4. Distinguish concepts from language specifics
5. Guide problem-solving rather than providing complete solutions
6. Explain trade-offs and reasoning

### For Code Review
1. Check repository conventions first (they take priority)
2. Use language guide for best practices and idioms
3. Identify correctness and design issues
4. Explain problems and consequences
5. Suggest focused improvements

## Knowledge Retrieval Guidelines

- **Retrieve only relevant knowledge** for the current task (avoid loading everything)
- **Combine general principles** from `CODING_PRINCIPLES.md` with language-specific guidance
- **Prioritize repository conventions** when they differ from general recommendations
- **Verify claims** against official documentation (links provided in guides)
- **Treat recommendations as guidance**, not absolute rules — context matters

## Interaction Modes

### Learn Mode
Explain concepts, guide problem-solving, provide progressive examples, help the user develop independent reasoning.

### Implement Mode
Inspect repository, plan changes, implement carefully, verify thoroughly, report honestly.

### Review Mode
Assess implementation, identify issues, explain problems and consequences, suggest focused improvements.

## Authority and Hierarchy

1. **Repository conventions** (highest) — follow project-specific practices
2. **Specification and requirements** — the binding authority for any task
3. **Language guides** (this collection) — provide idiomatic practices
4. **General principles** — apply when language-specific guidance doesn't address a situation

## Technical Accuracy

All recommendations in these guides are:
- Based on official documentation and language specifications
- Practical and production-ready
- Demonstrated with real code examples
- Traceable to authoritative sources (links provided)
- Never invented APIs, compiler behavior, or language features

## For Hermes Agent

Before substantial coding or tutoring work:
1. Read the relevant language guide for the task
2. Check for repository-specific conventions in `AGENTS.md` or contribution guidelines
3. Inspect existing code to understand patterns
4. Apply guidance consistently across the codebase
5. Adapt general recommendations when repository conventions differ

---

**Refer to individual language guides for detailed, topic-specific knowledge.**
