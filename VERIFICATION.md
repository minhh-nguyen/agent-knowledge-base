# Knowledge Base Verification

**Date:** 2026-11-27
**Scope:** role-based skill routing; frontmatter validity; mirrored references; lecture retrieval
**Result:** All checks below were run by hand on this date. Language-guide coverage and code
verification live with the two code skills; see [Code skills](#code-skills).

## Role Registry

Roles are the stable identifiers. Skill names live only in the folder name and the frontmatter
`name`. Skills are installed as **copies** in `~/.claude/skills/` (see Known Gaps).

| Role                   | Skill             | Mode        | Origin                  | State                                                   |
| ---------------------- | ----------------- | ----------- | ----------------------- | ------------------------------------------------------- |
| `study.tutor`          | tutor-tuda        | learn       | own                     | installed                                               |
| `study.lecture`        | lecture-slides    | do          | own                     | installed                                               |
| `study.workspace`      | teach             | do (manual) | mattpocock/skills       | installed                                               |
| `study.drill`          | socratic-tutor    | learn       | janestreet/agent_skills | installed; trigger overlap with `study.tutor`           |
| `code.tutor`           | tutor-code        | learn       | own                     | installed                                               |
| `code.build`           | vibe-coder        | do          | own                     | installed                                               |
| `research.mentor`      | tutor-research    | learn       | own                     | installed                                               |
| `research.find`        | paper-navigator   | do          | EvoScientist/EvoSkills  | installed                                               |
| `research.survey`      | research-survey   | do          | EvoScientist/EvoSkills  | installed                                               |
| `research.lineage`     | paper-graph       | do          | EvoScientist/EvoSkills  | installed                                               |
| `research.ideate`      | research-ideation | do          | EvoScientist/EvoSkills  | installed                                               |
| `research.memory`      | evo-memory        | do          | EvoScientist/EvoSkills  | installed                                               |
| `research.self-review` | paper-review      | do          | EvoScientist/EvoSkills  | installed                                               |
| `research.figures`     | paper-figures     | do          | EvoScientist/EvoSkills  | installed                                               |
| `util.audit`           | improve           | do          | shadcn/improve          | installed                                               |
| `util.find-skills`     | find-skills       | do          | vercel-labs/skills      | installed                                               |
| `util.pdf`             | pdf               | do          | anthropics/skills       | installed; duplicate of synced `anthropic-skills:pdf`   |

## Defects Fixed

| Defect                                                                                             | Effect before                                                                   | Fix                                                                                                                 |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `tutor-code` frontmatter said `name: agentic-coder` with a production-coding description           | The lab tutor told the agent to write full solutions; name did not match folder | Rewritten as a learn-mode tutor with a hard no-solution rule                                                        |
| Handovers named retired skills (`personal-ta`, `agentic-coder`, `docs-pro`)                        | Handovers pointed nowhere                                                       | All skill-to-skill references converted to role tags                                                                |
| `/memory/...` paths in `evo-memory`, `research-ideation`, `tutor-code`                             | Pointed at the filesystem root, which does not exist                            | `~/.claude/kb-memory/`, a manual symlink to `memory/`                                                               |
| Report paths `/artifacts/…`, `/direction-summary.md`, `/research-proposal.md` in research skills   | Reports written to the filesystem root                                          | `research-report/` under the working directory; every research skill has an Output Location section                 |
| `tutor-tuda` and `tutor-research` both contained teaching, coding, research, and lecture retrieval | Three skills competing for the same requests                                    | Each reduced to its role; duplicate `lecture-materials.md` removed from `tutor-research` (identical, `cmp`-checked) |
| `templates/paper-summary.md` symlinked into the removed `personal-ta` folder                       | Broken symlink                                                                  | Repointed                                                                                                           |
| Unquoted descriptions starting with `[role: …]` (pdf, teach, improve, find-skills)                 | YAML parses `[` as a list: invalid frontmatter                                  | Quoted                                                                                                              |
| Unquoted `author: EvoScientist - edited: Minh` in 6 EvoSkills frontmatters                         | The `: ` inside the value made the frontmatter invalid YAML                     | Value quoted                                                                                                        |
| `lecture-slides` said "read only cited pages" with no way to find them                             | Finding the pages meant reading the whole deck as page images                   | Mirrored the lecture retrieval protocol; deck sidecar read once, PDF pages only for figures                         |
| `lecture-slides` had no design budget                                                              | Decorative HTML is output tokens with no learning value                         | "Design: simple, token-cheap" rules and a size target taken from the reference example                              |

## Checks Performed

| Check                     | Method                                                              | Result                                                    |
| ------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------- |
| Role and name consistency | Script: frontmatter `name` vs folder, one skill per role            | 17 skills, 17 roles, 0 mismatches, 0 duplicate roles      |
| Frontmatter validity      | Ruby `YAML.safe_load` on all 17 `SKILL.md`                          | All parse; `description` is a string; `name` = folder     |
| Role references           | Every `[role: …]` in every skill file against declared roles        | 0 unresolved                                              |
| Relative links            | Script over every `*.md`, code blocks excluded                      | 0 broken                                                  |
| Symlinks                  | `find` for links whose target is missing                            | 0 broken; `examples/fomo/assets` → `../../assets` intended |
| `SKILL.md` length         | `wc -l`                                                             | Longest 442 (`paper-graph`); limit 500                    |
| Lecture protocol mirror   | `diff` of everything before the final section, study.tutor vs study.lecture | Identical                                         |
| Code reference mirror     | `diff` of `principles`, `cpp`, `python`, `rust`, `cuda`             | 2 lines each: the `code-review.md` link only (allowed)    |
| Deck sidecar threshold    | `wc -c` over all 322 non-empty sidecars                             | 262 ≤ 40 KB; lecture decks 25–31 KB; textbooks 0.6–2.3 MB |
| Lesson size target        | Bytes of `examples/fomo` lesson and cheat sheet                     | 26 KB (15.5 KB visible text), 5.8 KB                      |

## Known Gaps

- **Installed as copies, not symlinks.** All 17 entries in `~/.claude/skills/` are real directories.
  Edits in this repository do not reach Claude until the copy is refreshed; the copy of
  `lecture-slides` is already behind (`SKILL.md` and `references/` differ).
- **Missing skills.** Five `SKILL.md` files still hand over by plain name to skills not installed
  here: `experiment-pipeline`, `experiment-craft`, `paper-writing`, `paper-planning`,
  `paper-rebuttal`. No automated check flags plain names.
- **Trigger overlaps.** `study.drill` and `study.tutor` both claim "teach me" and "quiz me"; neither
  points to the other. `util.pdf` duplicates Claude's synced `anthropic-skills:pdf`.
- **Mode not in descriptions.** 13 of 17 descriptions do not state `Mode: learn|do`, which
  `AGENTS.md` §7 requires; the mode is only in this registry.
- External skills cannot carry role tags; repository skills therefore never hand over to them.
- Routing accuracy is verified structurally, not behaviorally: no evaluation set of real prompts
  with expected skills exists yet.

## Code skills

Verification of the language guides and the checklists for verifying code now live with the skills
that use them:

- [`skills/tutor-code/references/verification.md`](skills/tutor-code/references/verification.md)
- [`skills/vibe-coder/references/verification.md`](skills/vibe-coder/references/verification.md)
