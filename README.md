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
skills.json                      # which skills are active on this machine, and why
install.sh                       # reconciles ~/.claude/skills with skills.json
tools/
└── index-lectures.sh            # builds the page-level search index for lecture material
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
    ├── SKILL.md                 # teaching loop, mastery tracking, research mentorship
    └── references/
        ├── lecture-materials.md # token-cheap retrieval from university course material
        └── paper-summary.md     # response template for paper summaries and reviews
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
./install.sh --dry-run    # show the plan
./install.sh              # apply
```

`install.sh` reconciles `~/.claude/skills/` with [`skills.json`](skills.json), the single
declaration of what is active on this machine. It is idempotent: run it again any time.

Every project on the machine then sees the active skills. No per-project copies.

### What the manifest controls

- **owned** — the skills in this repository. Linked to `skills/<name>`, so editing a `SKILL.md`
  here is the only step needed to change behavior. Nothing to reinstall.
- **external** — third-party skills managed by the installer in `~/.agents/skills`. They are
  **not** copied into this repository, so they keep receiving upstream updates. Only their
  active state and their boundary against the owned skills are decided here.
- **disabled** — an external skill whose triggers collide with an owned skill. `install.sh`
  removes its link from `~/.claude/skills`; the source stays in `~/.agents/skills`, so flipping
  `active` back to `true` restores it. Every disabled entry carries a mandatory `reason`.
- **unmanaged_ignore** — directories in the target that the script reports as expected and never
  touches. `synced` is Claude's own account-synced skill cache.

An unmanaged copy found in the target is moved to `.install-backups/` rather than deleted, then
replaced with a link. A real directory there is exactly how skills drift out of sync.

### Avoiding trigger collisions

Two skills whose `description` fields match the same request make the agent pick arbitrarily.
Rules:

- An owned skill states what it does **not** cover and names the skill that does.
- Where an external skill is genuinely complementary, record the boundary in its manifest entry
  and in the owned skill's handover table.
- Where it is a duplicate, disable it. Do not fix a collision by editing a third-party
  `SKILL.md`: the next upstream update overwrites the edit.

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

## Lecture material

`personal-ta` teaches from the user's own course material in `~/Documents/tuda/lectures`,
organized by semester. Reading those PDFs whole would exhaust the context before the lesson
starts, so retrieval is indexed:

```sh
tools/index-lectures.sh ~/Documents/tuda/lectures/4.ws2627
```

For each PDF the script writes a page-tagged text sidecar under `lectures/.search/`, where every
line is `p<N>\t<text>`. One `grep` then returns the exact page a topic appears on, and only that
page is read from the PDF. Measured on this material: a 519-page textbook resolves to page 274,
a 30-page lecture deck to page 23.

The script never writes into the course directories — several are git repositories. It is
incremental, skipping PDFs older than their sidecar, and needs poppler (`brew install poppler`).

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
