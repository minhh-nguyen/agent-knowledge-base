# Knowledge Base Verification

**Date:** 2026-11-26
**Scope:** role-based skill routing; rename safety; skill set under `skills/`
**Result:** Role tags, frontmatter names, line limits, relative links, and symlinks checked by hand
after the install script was removed. Language-guide coverage and code verification live with the
two code skills; see [Code skills](#code-skills).

## Role Registry

Roles are the stable identifiers. Skill names live only in the folder name and the frontmatter
`name`. Current mapping:

| Role                   | Skill             | Mode        | Origin                  | State                                                  |
| ---------------------- | ----------------- | ----------- | ----------------------- | ------------------------------------------------------ |
| `study.tutor`          | tutor-tuda        | learn       | own                     | active                                                 |
| `study.lecture`        | lecture-slides    | do          | own                     | active                                                 |
| `study.workspace`      | teach             | do (manual) | mattpocock/skills       | active                                                 |
| `code.tutor`           | tutor-code        | learn       | own                     | active                                                 |
| `code.build`           | vibe-coder        | do          | own                     | active                                                 |
| `research.mentor`      | tutor-research    | learn       | own                     | active                                                 |
| `research.find`        | paper-navigator   | do          | EvoScientist/EvoSkills  | active                                                 |
| `research.survey`      | research-survey   | do          | EvoScientist/EvoSkills  | active                                                 |
| `research.lineage`     | paper-graph       | do          | EvoScientist/EvoSkills  | active                                                 |
| `research.ideate`      | research-ideation | do          | EvoScientist/EvoSkills  | active                                                 |
| `research.memory`      | evo-memory        | do          | EvoScientist/EvoSkills  | active                                                 |
| `research.self-review` | paper-review      | do          | EvoScientist/EvoSkills  | active                                                 |
| `research.figures`     | paper-figures     | do          | EvoScientist/EvoSkills  | active                                                 |
| `util.audit`           | improve           | do          | shadcn/improve          | active                                                 |
| `util.find-skills`     | find-skills       | do          | vercel-labs/skills      | active                                                 |
| `util.pdf`             | pdf               | do          | anthropics/skills       | duplicate of synced `anthropic-skills:pdf`; not linked |
| `study.drill`          | socratic-tutor    | learn       | janestreet/agent_skills | duplicate of `study.tutor`; not linked                 |

## Defects Fixed

| Defect                                                                                             | Effect before                                                                   | Fix                                                                                                                 |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `tutor-code` frontmatter said `name: agentic-coder` with a production-coding description           | The lab tutor told the agent to write full solutions; name did not match folder | Rewritten as a learn-mode tutor with a hard no-solution rule                                                        |
| Handovers named retired skills (`personal-ta`, `agentic-coder`, `docs-pro`)                        | Handovers pointed nowhere                                                       | All skill-to-skill references converted to role tags                                                                |
| 10 repository skills were not linked into `~/.claude/skills`                                       | Claude Code never saw the research or tutor skills                              | Linked once by hand                                                                                                 |
| `/memory/...` paths in `evo-memory`, `research-ideation`, `tutor-code`                             | Pointed at the filesystem root, which does not exist                            | `~/.claude/kb-memory/`, a manual symlink to `memory/`                                                               |
| `tutor-tuda` linked `references/paper-summary.md`, which exists only in `tutor-research`           | Broken reference                                                                | Research sections moved out of `tutor-tuda`; that role owns them                                                    |
| `tutor-tuda` and `tutor-research` both contained teaching, coding, research, and lecture retrieval | Three skills competing for the same requests                                    | Each reduced to its role; duplicate `lecture-materials.md` removed from `tutor-research` (identical, `cmp`-checked) |
| `socratic-tutor` triggered on the same phrases as `tutor-tuda`                                     | Arbitrary choice between them                                                   | Disabled with reason                                                                                                |
| `templates/paper-summary.md` symlinked into the removed `personal-ta` folder                       | Broken symlink                                                                  | Repointed; broken symlinks checked by hand                                                                          |
| Unquoted descriptions starting with `[role: …]` (pdf, teach, improve, find-skills)                 | YAML parses `[` as a list: invalid frontmatter                                  | Quoted; all 15 frontmatters parse as YAML                                                                           |
| Stale `agentic-coder` and `personal-ta` links in `~/.claude/skills`                                | Dangling skill entries                                                          | Removed by hand                                                                                                     |

## Checks Performed

| Check                     | Method                                                         | Result                                             |
| ------------------------- | -------------------------------------------------------------- | -------------------------------------------------- |
| Role and name consistency | Manual check: frontmatter `name` vs folder, one skill per role | 17 skills, 17 roles, 0 mismatches                  |
| Frontmatter validity      | Ruby `YAML.safe_load` on all 17 `SKILL.md`                     | All parse; every description is a string           |
| Role references           | `grep` for `[role: …]` compared against declared roles         | 0 unresolved                                       |
| Agent sees role tags      | Available-skills list in the live session                      | All active repository skills listed with their tag |
| Relative links            | Script over every `*.md`, code blocks excluded                 | 0 broken                                           |
| Symlinks                  | `find` for links whose target is missing                       | 0 broken                                           |
| Retired names             | `grep` for `personal-ta`, `agentic-coder`, `docs-pro`          | None outside this history table                    |
| `SKILL.md` length         | `wc -l`                                                        | Longest 416 (`paper-graph`); limit 500             |
| Lecture index             | Earlier session: 347 PDFs, all semesters                       | Retrieval loop verified to page level              |

## Known Gaps

- EvoSkills descriptions hand over to skills not installed here: `experiment-pipeline`,
  `experiment-craft`, `paper-writing`, `paper-planning`, `paper-rebuttal`. They are plain names,
  not role tags, so no automated check flags them. Install them from EvoSkills and assign roles,
  or the agent will be told to use a skill that does not exist.
- External skills (`code-review`, `simplify`, `docs-pro`, …) cannot carry role tags; repository
  skills therefore never hand over to them.
- Routing accuracy is verified structurally, not behaviorally: no evaluation set of real prompts
  with expected skills exists yet.

## Code skills

Verification of the language guides and the checklists for verifying code now live with the skills
that use them:

- [`skills/tutor-code/references/verification.md`](skills/tutor-code/references/verification.md)
- [`skills/vibe-coder/references/verification.md`](skills/vibe-coder/references/verification.md)

