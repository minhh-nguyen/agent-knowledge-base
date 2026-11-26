# Agent Knowledge Base

Study, coding, and research skills for AI agents, plus the knowledge behind them. One source of
truth in `skills/`, linked into `~/.claude/skills` — never copied per project.

## How skills are organized

Every skill has a **role**: `<domain>.<function>`, declared at the start of its `description` as
`[role: <domain>.<function>]`. The role is the stable identifier; the folder name is not. Skills
refer to each other only by role tag (`[role: research.find]`), so a skill can be renamed without
touching any other skill.

Each skill also has a **mode**:

- **learn**: coaches the user, who does the work. Hints, questions, critique — never the answer.
- **do**: produces the output (papers found, survey written, figure rendered).

Routing a request means answering two questions: *which domain?* and *learn or do?*

| Domain | learn | do |
| --- | --- | --- |
| **study** | `study.tutor` — teach a course topic from the lecture slides | `study.lecture` — generate lessons + quiz banks; `study.workspace` — on-disk lesson workspace (manual only) |
| **code** | `code.tutor` — review the user's code, coach labs; never gives the solution | `code.build` — implement the requested change, clean and minimal |
| **research** | `research.mentor` — coach reading, critique, gaps, experiment design | the pipeline below |
| **util** | — | `util.audit`, `util.find-skills` |

The research **do** pipeline:

```
research.find → research.survey → research.lineage → research.ideate → (experiments) → research.self-review
 find/read      write a survey    field lineage      generate ideas                      stress-test YOUR draft
                research.memory: records lessons after ideation and after experiments
                research.figures: CSV → publication plots, at any stage
```

`research.self-review` reviews the user's **own** draft before submission. To learn to critique
someone else's paper, use `research.mentor`.

## Layout

```
AGENTS.md            # rules for agents editing this repository
VERIFICATION.md      # what has and has not been verified
skills/<name>/       # one folder per skill: SKILL.md + references/ (+ scripts/, assets/)
memory/              # persistent state written by skills; reached via ~/.claude/kb-memory/
mcp/                 # MCP server configurations used by the research skills
tools/
└── index-lectures.sh  # page-level search index for lecture PDFs
inbox/               # unsorted drafts, not authority
sources/             # external references with version and date checked
templates/           # reusable document skeletons
```

## Authoring checks

There is no install step. Each skill in `skills/` is linked into `~/.claude/skills` once; editing a
file here changes behavior immediately.

Before committing a skill change, check by hand:

| Check | Catches |
| --- | --- |
| Every `[role: <domain>.<function>]` used in the skill resolves to a role declared by some `SKILL.md` | A handover to a removed or renamed role |
| Frontmatter `name` = folder name | A half-done rename |
| Each description carries its own role tag | A skill the router cannot address |
| One skill per role | Two skills fighting over the same requests |
| `SKILL.md` under 500 lines | Skills too long to route well |
| Relative links resolve; no broken symlinks | Renamed or moved files |
| No `/memory/` absolute paths | Writes to the filesystem root |

### Renaming a skill

1. Rename the folder: `git mv skills/old skills/new`
2. Change `name:` in its `SKILL.md` frontmatter.

Nothing else changes: every other skill refers to it by role.

### Adding a skill

1. Pick a role `<domain>.<function>` not already declared by another skill.
2. Start its description with `[role: <domain>.<function>]` and state its mode (learn or do), when
   to use it, and which roles to use instead — by role tag, never by name.
3. Add the folder under `skills/` and link it into `~/.claude/skills`.

### Third-party skills

- **Copied** into `skills/` (EvoSkills and others): owned here, role-tagged. Re-syncing from
  upstream is a merge, not an overwrite, because the role tags are local edits.
- **External** in `~/.agents/skills`: still updated by their installer, so their `SKILL.md` is
  never edited and they cannot carry a role tag.

Duplicates are resolved by narrowing one description or moving the duplicate out of `skills/`.

## Lecture material

`study.tutor` teaches from the user's course material in `~/Documents/tuda/lectures`, organized
by semester. Reading those PDFs whole would exhaust the context, so retrieval is indexed:

```sh
tools/index-lectures.sh ~/Documents/tuda/lectures/4.ws2627
```

For each PDF the script writes a page-tagged text sidecar under `lectures/.search/`, where every
line is `p<N>\t<text>`. One `grep` returns the exact page; only that page is read from the PDF.
Measured on this material: a 519-page textbook resolves to page 274, a 30-page deck to page 23.

The script never writes into course directories (several are git repositories), is
incremental, and needs poppler (`brew install poppler`).

## Per-project usage

A consuming project copies no knowledge. Skills are global once linked into `~/.claude/skills`; a
project only adds overrides in its own `AGENTS.md`. Precedence: **specification > project
overrides > knowledge base > generic agent habits.**

## Contributing knowledge

1. Search the existing skills and references first; update rather than duplicate.
2. Reusable knowledge belongs in the matching skill's `references/`. Raw notes go to `inbox/`.
3. External claims go in `sources/` with the version and the date checked.
4. Reopen every modified file and run the authoring checks above before committing.

## Principles

- Markdown only; lowercase kebab-case filenames; relative links.
- Refer to skills by role, data by stable link, documents by relative path — never by a name or
  location that can change.
- Never invent APIs, results, or citations. Label verified facts, assumptions, and speculation.
- Follow [`AGENTS.md`](AGENTS.md) when modifying this repository.
