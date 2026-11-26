# Agent Knowledge Base

Long-term engineering and teaching knowledge, packaged as **agent skills**. One source of truth,
installed into many projects — never copied per project.

## Skills

| Skill | Role | Triggers on |
| --- | --- | --- |
| [`agentic-coder`](skills/agentic-coder/SKILL.md) | Production code standards | implementing, refactoring, debugging, reviewing a diff, technical docs |
| [`personal-ta`](skills/personal-ta/SKILL.md) | Teaching and research mentorship | "teach me", "explain why", assignments, reading papers, experiment design |

The boundary is intent, not topic: **shipping code → `agentic-coder`; building understanding →
`personal-ta`.** Each skill names the other so the agent can hand over instead of blending both.

## Layout

```
AGENTS.md                        # rules for agents editing this repository
VERIFICATION.md                  # what has and has not been verified
skills/
├── agentic-coder/
│   ├── SKILL.md                 # router: workflow, authority, honesty rules
│   └── references/
│       ├── principles.md        # language-independent principles
│       ├── code-review.md       # review checklists and reporting
│       ├── cpp.md               # Modern C++ (C++17+, C++20)
│       ├── python.md            # Typed Python (3.10+)
│       ├── rust.md              # Rust (1.70+, edition 2021)
│       └── cuda.md              # CUDA (11+, Ampere/Ada)
└── personal-ta/
    └── SKILL.md                 # teaching loop, mastery tracking, research mentorship
inbox/                           # unsorted drafts, not authority
sources/                         # external references: links, versions, dates checked
templates/                       # reusable document skeletons
```

### Why skills are self-contained

Every skill reads only paths **relative to its own `SKILL.md`**. Nothing escapes the skill
directory with `../../`. That is what makes one checkout usable by symlink, plugin, or git
submodule without rewriting paths.

### Authoring rules

- `SKILL.md` is a router: triggers, workflow, hard rules, and a table of what to load when.
- Depth goes in `references/`, loaded only when the task needs it.
- Every `SKILL.md` stays **under 500 lines**. Overflow moves to `references/`.
- `description` in the frontmatter states **when to use the skill**, and when not to — that text
  is all an agent sees when deciding whether to load it.

## Install

```sh
ln -sfn "$PWD/skills/agentic-coder" ~/.claude/skills/agentic-coder
ln -sfn "$PWD/skills/personal-ta"   ~/.claude/skills/personal-ta
```

Every project on the machine then sees both skills. No per-project copies.

| Situation | Mechanism |
| --- | --- |
| One machine, personal use | Symlink, as above |
| Several machines, or shared with others | Package `skills/` as a plugin; install per machine |
| A project must pin a revision, or work offline | Add this repository as a `git submodule` |
| A project genuinely needs different rules | Only then fork, and treat the fork as a separate base |

Copies drift: a principle fixed here would stay stale everywhere else, with no path back.

## Per-project usage

A consuming project copies no knowledge. It adds a short `AGENTS.md` that delegates:

```markdown
# AGENTS.md

Load the `agentic-coder` skill before any coding, review, or documentation task.

## Project-specific overrides

- <only rules that genuinely differ from the knowledge base>
```

Precedence: **specification > project overrides > knowledge base > generic agent habits.**

## Contributing knowledge

1. Search the existing skills and references first; update rather than duplicate.
2. Reusable knowledge belongs in the matching `references/` file. Raw or half-formed notes go to
   `inbox/` until they are worth promoting.
3. External claims go in `sources/` with the version and the date checked.
4. Keep version-dependent statements traceable to official documentation.
5. Reopen every modified file to verify the change.

## Principles

- Markdown only; lowercase kebab-case filenames; relative links.
- Prefer links between documents over duplicated content.
- Practical examples over generic explanation; mechanisms and trade-offs over lists of features.
- Never invent APIs, results, or citations. Label verified facts, assumptions, and speculation.
- Follow [`AGENTS.md`](AGENTS.md) when modifying this repository.
