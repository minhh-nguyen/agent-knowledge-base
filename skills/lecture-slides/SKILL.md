---
name: lecture-slides
description: "[role: study.lecture] Produce course lessons and question banks as self-contained HTML from lecture slides, following a fixed template: keyword cards, mid-lesson MCQs, True/False, What-is, calculation and written exam questions, plus one cheat sheet per lecture. Use when the user asks for a lesson, quiz, question bank, cheat sheet, or exam-prep material for a course lecture. Do not use for interactive tutoring or Socratic quizzing (use [role: study.tutor]), for mastery drilling (use [role: study.drill]), or for a generic on-disk teaching workspace (use [role: study.workspace])."
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

Course state and generated material live **outside this skill folder**, one folder per course:
`~/.claude/study/<course>/` (`<course>` = the short course code, e.g. `fomo`, `pmpp`). That path is
a symlink into the knowledge-base repository. Never write state or output into this skill folder or
into the project you are working in. If `~/.claude/study` does not exist, tell the user and stop.

Read these in the course folder before writing anything:

- `MISSION.md` — why the learner studies, deadline, grade target, constraints.
- `NOTES.md` — learner preferences, format overrides, course plan, working notes.
- `RESOURCES.md` — trusted sources with versions and dates.

A new course folder is created from `templates/` (see
[`references/workspace-format.md`](references/workspace-format.md#new-course)). If any `<...>`
placeholder remains, or a file is missing, run the setup interview before generating material.
`examples/fomo/` in this skill holds one representative lesson and its cheat sheet. Never copy an
example's facts into a new course.

Generated material, relative to the course folder:

```
lessons/NNNN-<slug>.html        one self-contained lesson per deck
cheat-sheets/lNN-<slug>.html    one cheat sheet per deck
assets/                         symlink to this skill's assets/: style.css, quiz.js — never fork
```

Each course has its own folder; switching course means switching folder, nothing is archived.

## Course setup

Run this once per course, or whenever a state file is still a template. First create the course
folder if it is missing ([`references/workspace-format.md`](references/workspace-format.md#new-course)).
Ask one question at a time, then write the answers into the course folder's three files:

1. Course name, university, term; exam date and grade target.
2. Where the slides, exercises, and past exams live (path or URL).
3. Current position: which lectures are already covered, which are behind.
4. Time per week and preferred style (lesson then questions, Socratic, both).
5. Language rule (prompt language → answer language; which terms stay English).
6. Constraints: labs that forbid AI help, topics explicitly out of scope.

Do not generate a lesson while the mission still contains placeholders.

## Workflow

1. **Read the state.** Resolve the course folder `~/.claude/study/<course>/`, then read its
   `MISSION.md`, `NOTES.md`, `RESOURCES.md`. If the folder is missing or a placeholder remains, run
   the setup interview first. If the course or deck is unclear, ask before generating.
2. **Retrieve the deck cheaply.** Follow
   [`references/lecture-materials.md`](references/lecture-materials.md): course index → the deck's
   page-tagged text sidecar → PDF pages only for figures and formulas. Never load a whole PDF; never
   read a textbook sidecar. Note the page number for every fact.
3. **Choose the next number.** List `lessons/` and continue from the highest `NNNN`; never reuse or
   overwrite an existing lesson.
4. **Extract the keywords.** 10–16 terms that carry the deck. If there are more, the lesson covers
   too much: split the deck into two lessons and say where the cut is.
5. **Write the lesson** exactly as [`references/lesson-format.md`](references/lesson-format.md)
   specifies, with the banks from [`references/quiz-format.md`](references/quiz-format.md).
6. **Write the cheat sheet** for the same deck as
   [`references/cheat-sheet-format.md`](references/cheat-sheet-format.md) specifies. The lesson and
   the cheat sheet link to each other.
7. **Update the workspace.** Append a dated entry to `NOTES.md` (what was produced, what the learner
   struggled with, what to review next). Add any newly checked source to `RESOURCES.md`.

## Hard rules

- Fixed section order: win → keyword strip → 5–6 keyword sections with MCQs → worked exam question →
  recall drill → True/False → What-is → Calculations → written exam → Read next.
- Counts per lesson: 2 MCQs per keyword section, 8–10 True/False, 8 What-is, 5 calculations,
  4 written questions.
- Every factual sentence carries `<span class="cite">Deck p.N</span>`. Never invent a number, page,
  or formula.
- Reuse `../assets/style.css` and `../assets/quiz.js`. No new CSS files, no external JS, no CDN.
- Written exam answers stay out of the HTML; they are graded in chat.
- No lab solutions. Respect the lab rules recorded in `MISSION.md`; concepts only.
- Match the learner's language in prose; keep technical terms in English with a short gloss.
- Never delete or renumber an existing lesson without asking.

## Design: simple, token-cheap

Every byte of HTML is output the model has to generate. The content is the product; the design
only has to be readable.

- Plain semantic HTML: headings, paragraphs, lists, `table`, `details`. Nothing else is needed.
- All styling comes from `../assets/style.css` through its existing classes. No inline `style=`,
  no `<style>` blocks, no new classes unless the format references require them.
- No decoration: no SVG drawings, icons, emoji, gradients, animations, or wrapper `div`s that
  carry no meaning. Reproduce a slide's figure as a short table or list, or cite its page.
- Short prose: one idea per sentence, no restating the slide around a question.
- Never re-read a lesson you just wrote to check it; check it against the finish list from what
  you generated. Never paste a full example file into context; open `examples/` only when the
  format references leave a question open, and read the part you need.
- Target size: the reference example — a lesson around 26 KB (of which ~15 KB is visible text,
  set by the required question counts), a cheat sheet around 6 KB. Well over that means the deck
  should be split, or the prose is padded. Never meet the target by dropping required questions.

## References

| Task                                                           | Load                                                                   |
| -------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Finding the deck and its pages without reading whole PDFs      | [`references/lecture-materials.md`](references/lecture-materials.md)   |
| Lesson skeleton, section order, keyword cards, citation rules  | [`references/lesson-format.md`](references/lesson-format.md)           |
| MCQ, True/False, What-is, calculation, written-question markup | [`references/quiz-format.md`](references/quiz-format.md)               |
| Cheat sheet structure and page-citation rules                  | [`references/cheat-sheet-format.md`](references/cheat-sheet-format.md) |
| MISSION/NOTES/RESOURCES structure, naming, state updates       | [`references/workspace-format.md`](references/workspace-format.md)     |

## Finish checklist

- [ ] File names follow `NNNN-<slug>.html` / `lNN-<slug>.html`; links resolve both ways.
- [ ] Every keyword has a card, a recall entry, and at least one question.
- [ ] Every citation points to a real deck page.
- [ ] The four banks have the required counts and no answer leaks into a question.
- [ ] The cheat sheet fits two pages and ends with the deck's exam-style questions.
- [ ] No inline styles, `<style>` blocks, SVG, icons, or emoji; sizes near the targets above.
- [ ] `NOTES.md` has a dated entry for this session.
- [ ] The three state files describe this course, with no leftover `<...>` placeholder.
- [ ] Everything was written under `~/.claude/study/<course>/`; nothing in the skill folder.
