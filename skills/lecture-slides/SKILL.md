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

This skill is a single live workspace whose course state is dynamic. Read these before writing
anything:

- `MISSION.md` — why the learner studies, deadline, grade target, constraints.
- `NOTES.md` — learner preferences, format overrides, course plan, working notes.
- `RESOURCES.md` — trusted sources with versions and dates.

All three start as fill-in templates. If any `<...>` placeholder remains, or a file is missing,
run the setup interview before generating material. `templates/` keeps pristine copies for resetting
a workspace; `examples/fomo/` holds one representative lesson and its cheat sheet. Never copy an
example's facts into a new course.

Generated material:

```
lessons/NNNN-<slug>.html        one self-contained lesson per deck
cheat-sheets/lNN-<slug>.html    one cheat sheet per deck
assets/style.css                shared stylesheet — reuse, never fork per lesson
assets/quiz.js                  MCQ reveal behaviour — no other script
```

One course per workspace. To switch course, archive the current state first; see
[`references/workspace-format.md`](references/workspace-format.md#switching-course).

## Course setup

Run this once per course, or whenever a state file is still a template. Ask one question at a time,
then write the answers into the three files:

1. Course name, university, term; exam date and grade target.
2. Where the slides, exercises, and past exams live (path or URL).
3. Current position: which lectures are already covered, which are behind.
4. Time per week and preferred style (lesson then questions, Socratic, both).
5. Language rule (prompt language → answer language; which terms stay English).
6. Constraints: labs that forbid AI help, topics explicitly out of scope.

Do not generate a lesson while the mission still contains placeholders.

## Workflow

1. **Read the state.** `MISSION.md`, `NOTES.md`, `RESOURCES.md`. If a placeholder remains, run the
   setup interview first. If the course or deck is unclear, ask before generating.
2. **Locate the deck and its exam slide.** Use the paths recorded in `RESOURCES.md`. Read only the
   pages the lesson cites; never load a whole PDF. Note the page number for every fact.
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

## References

| Task                                                           | Load                                                                   |
| -------------------------------------------------------------- | ---------------------------------------------------------------------- |
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
- [ ] `NOTES.md` has a dated entry for this session.
- [ ] The three state files describe this course, with no leftover `<...>` placeholder.
