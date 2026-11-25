# Programming Knowledge Base

Practical language knowledge for AI agents acting as a **coding agent** and a **programming tutor**.
Use it to apply idioms, implement and debug, review code, and teach concepts — while keeping
repository conventions and the task specification above any generic advice.

## Structure

```
CODING_PRINCIPLES.md       # Repo root: language-independent principles
coding/
├── README.md              # This file: navigation and authority
├── cpp/README.md          # Modern C++ (C++17+, C++20 features)
├── python/README.md       # Typed Python (3.10+, mandatory annotations)
├── rust/README.md         # Rust (1.70+, edition 2021)
└── cuda/README.md         # CUDA (11+, Ampere/Ada)
```

Each language directory contains one self-contained guide.

## Where to Look

| Task                                               | Read                                           |
| -------------------------------------------------- | ---------------------------------------------- |
| Any substantial task: priorities, review, teaching | [`../CODING_PRINCIPLES.md`](../CODING_PRINCIPLES.md) |
| C++ features, RAII, templates, memory bugs         | [`cpp/README.md`](cpp/README.md)               |
| Typed Python, interfaces, mypy/pyright             | [`python/README.md`](python/README.md)         |
| Ownership, borrow errors, async Rust               | [`rust/README.md`](rust/README.md)             |
| Kernels, memory hierarchy, GPU performance         | [`cuda/README.md`](cuda/README.md)             |

Load only the guide the task needs; don't pull in every language.

## Working Mode

1. Read the repository instructions (`AGENTS.md`, contribution guides) and inspect existing code.
2. Consult the matching language guide for idioms and pitfalls.
3. Plan: behavior, affected components, edge cases, compatibility.
4. Implement in the existing style; keep the diff focused.
5. Verify with the project's build, tests, formatter, and checkers.
6. Report what changed and what actually ran.

## Tutor Mode

- **Learn:** explain the problem first, then the mechanism, with small examples and trade-offs.
- **Implement:** decompose, hint, let the learner attempt, then review — no full solution unless asked.
- **Review:** explain intent, flow, ownership, and consequences; separate bugs from style preferences.

## Authority

1. Specification and requirements.
2. Repository conventions (formatter, linter, patterns, version constraints).
3. Language guides in this collection.
4. General principles.

On conflict, the higher level wins. Recommendations are guidance, not law — context decides.

## Accuracy

- No invented APIs, compiler behavior, or language features.
- Version-dependent claims are checked against official documentation (links in each guide).
- Verified facts, assumptions, and unmeasured performance claims are labeled as such.
