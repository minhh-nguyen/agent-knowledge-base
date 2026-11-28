---
name: lecture-slides
description: "[role: study.lecture] Produce self-contained HTML lessons and quiz banks from lecture slides, including keyword cards, MCQs, written questions, and a cheat sheet. Mode: do. Use for lecture lessons or exam-prep material. Do NOT use for interactive tutoring ([role: study.tutor]), mastery drilling ([role: study.drill]), or workspace lessons ([role: study.workspace])."
---

# Lecture Slides

Mode: **do** — produce the material. Teaching the learner with it happens in another skill.

## Role boundary

| Request                                                                         | Skill                     |
| ------------------------------------------------------------------------------- | ------------------------- |
| "Write the lesson for lecture 04", "make a quiz bank", "update the cheat sheet" | this skill                |
| "Teach me lecture 04", "quiz me", "explain this slide"                          | `[role: study.tutor]`     |
| "Drill me to mastery", spaced review, final assessment                          | `[role: study.drill]`     |
| A generic on-disk teaching workspace, invoked by name                           | `[role: study.workspace]` |
| Review or debug lab code                                                        | `[role: code.tutor]`      |

If the user wants to be taught rather than handed material, say so and hand over; do not blend
both jobs in one response.

## Workspace

Course state and generated material are the deliverable itself: they live **outside this skill
folder**, in the user's public course-site repo, one folder per course:
`~/repo/minhh-nguyen.github.io/ws26-27/<course>/` (`<course>` = the short course code, e.g.
`fomo`, `pmpp`). Never write state or output into this skill folder or into the project you are
working in. If that repo does not exist, tell the user and stop.

Read these in the course folder before writing anything:

- `MISSION.md` — why the learner studies, deadline, grade target, constraints.
- `NOTES.md` — learner preferences, format overrides, course plan, working notes.
- `RESOURCES.md` — trusted sources with versions and dates.

A new course folder is created by `template/new-course.sh` (see
[`references/workspace-format.md`](references/workspace-format.md#new-course)). If any `<...>`
placeholder remains, or a file is missing, run the setup interview before generating material.
`examples/fomo/` in this skill holds one representative lesson and its cheat sheet. Never copy an
example's facts into a new course.

Generated material, relative to the course folder:

```
lessons/NNNN-<slug>.html        one self-contained lesson per deck
cheat-sheets/lNN-<slug>.html    one cheat sheet per deck (alias for reference/)
assets/                         owned copy of this skill's style.css, quiz.js — a course may adapt it
```

Each course has its own folder; switching course means switching folder, nothing is archived.

## Course setup

Run this once per course, or whenever a state file is still a template. First create the course
folder if it is missing: `template/new-course.sh <slug> "<Course Title>" "<Badge Label>" ["<lede>"]`
(see [`references/workspace-format.md`](references/workspace-format.md#new-course); it prints two
manual site-wide steps to do afterward). Ask one question at a time, then write the answers into
the course folder's three files:

1. Course name, university, term; exam date and grade target.
2. Where the slides, exercises, and past exams live (path or URL).
3. Current position: which lectures are already covered, which are behind.
4. Time per week and preferred style (lesson then questions, Socratic, both).
5. Language rule (prompt language → answer language; which terms stay English).
6. Constraints: labs that forbid AI help, topics explicitly out of scope.

Do not generate a lesson while the mission still contains placeholders.

## Workflow

1. **Read the state.** Resolve the course folder `~/repo/minhh-nguyen.github.io/ws26-27/<course>/`, then read its
   `MISSION.md`, `NOTES.md`, `RESOURCES.md`. If the folder is missing or a placeholder remains, run
   the setup interview first. If the course or deck is unclear, ask before generating.
2. **Retrieve the deck cheaply.** Follow
   [`references/lecture-materials.md`](references/lecture-materials.md): course index → the deck's
   page-tagged text sidecar → PDF pages only for figures and formulas. Never load a whole PDF; never
   read a textbook sidecar. Note the page number for every fact.
3. **Choose the next number.** List `src/` and `lessons/` and continue from the highest `NNNN`;
   never reuse or overwrite an existing lesson.
4. **Extract the keywords.** 10–16 terms that carry the deck. If there are more, the lesson covers
   too much: split the deck into two lessons and say where the cut is.
5. **Write the lesson source** `src/NNNN-<slug>.md` in the syntax of
   [`references/source-format.md`](references/source-format.md), following the section order and
   content rules of [`references/lesson-format.md`](references/lesson-format.md) and
   [`references/quiz-format.md`](references/quiz-format.md). Never write the HTML yourself.
6. **Write the cheat-sheet source** `src/lNN-<slug>.md` for the same deck, following
   [`references/cheat-sheet-format.md`](references/cheat-sheet-format.md). Front matter links the
   two (`cheat:` / `lesson_file:`).
7. **Render both:** `uv run ~/.claude/skills/lecture-slides/scripts/render.py <source>`. On exit
   `1` fix the reported counts in the source and render again; on exit `2` fix the source error.
   Do not open the HTML to check it.
8. **Update the workspace.** Append a dated entry to `NOTES.md` (what was produced, what the learner
   struggled with, what to review next). Add any newly checked source to `RESOURCES.md`.

## Hard rules

- Fixed section order: win → mind map → keyword strip → 5–6 keyword sections with MCQs → worked exam
  question → recall drill → True/False → What-is → Calculations → written exam → Read next.
- Counts per lesson: 2 MCQs per keyword section, 8–10 True/False, 8 What-is, 5 calculations,
  4 written questions.
- Every factual sentence carries a `[[p.N]]` citation. Never invent a number, page, or formula.
- Output HTML comes only from `scripts/render.py`; no hand-written HTML, CSS, or JS.
- The only external script is the pinned Mermaid bundle that renders the mind map; no other CDN or
  remote asset.
- Written exam answers stay out of the source; they are graded in chat.
- No lab solutions. Respect the lab rules recorded in `MISSION.md`; concepts only.
- All contents must be in English (user will mention in specific case); keep technical terms in English with a short gloss.
- Never delete or renumber an existing lesson without asking.

## Design: simple, token-cheap

The agent writes content only; the renderer adds every tag, class, and link. Keep the source lean:

- The mind map is derived, not written: `render.py` builds a Mermaid `mindmap` from the lesson title,
  the `##` section headings, and the `keywords` blocks. Never put Mermaid in the source; every
  keyword appears once as a leaf.
- Short prose: one idea per sentence, no restating the slide around a question.
- No decoration: no raw HTML, SVG, icons, or emoji in the source. Reproduce a slide's figure as a
  short Markdown table or list, or cite its page.
- Never re-read a source or rendered file you just wrote; the renderer's exit code and `check:` lines
  replace that. Open `examples/` only when the references leave a question open, and read only the
  part you need.
- Target size: a lesson source around 15 KB (the visible text the required question counts need),
  a cheat-sheet source around 4 KB. Well over that means the deck should be split, or the prose is
  padded. Never meet the target by dropping required questions.

## References

| Task                                                           | Load                                                                   |
| -------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Finding the deck and its pages without reading whole PDFs      | [`references/lecture-materials.md`](references/lecture-materials.md)   |
| Source syntax and render command (always, before writing)      | [`references/source-format.md`](references/source-format.md)           |
| Section order, keyword and writing rules (skip the HTML parts) | [`references/lesson-format.md`](references/lesson-format.md)           |
| MCQ, True/False, What-is, calculation, written-question rules  | [`references/quiz-format.md`](references/quiz-format.md)               |
| Cheat sheet structure and page-citation rules                  | [`references/cheat-sheet-format.md`](references/cheat-sheet-format.md) |
| MISSION/NOTES/RESOURCES structure, naming, state updates       | [`references/workspace-format.md`](references/workspace-format.md)     |
| Scaffolding a brand-new course folder                          | [`template/AGENTS.md`](template/AGENTS.md)                             |

## Finish checklist

- [ ] Sources are `src/NNNN-<slug>.md` / `src/lNN-<slug>.md`; both rendered with exit `0`.
- [ ] Every keyword has a card, a recall entry, and at least one question.
- [ ] Every citation points to a real deck page.
- [ ] No answer leaks into a question (counts are checked by the renderer).
- [ ] The cheat sheet fits two pages and ends with the deck's exam-style questions.
- [ ] No raw HTML, SVG, icons, or emoji in the sources; sizes near the targets above.
- [ ] The mind map is derived from the section headings and keywords; no Mermaid in the source.
- [ ] `NOTES.md` has a dated entry for this session.
- [ ] The three state files describe this course, with no leftover `<...>` placeholder.
- [ ] Everything was written under `~/repo/minhh-nguyen.github.io/ws26-27/<course>/`; nothing in
      the skill folder.
