# Workspace Format

The skill is one workspace with a **dynamic course state**. The same checkout is reused for any
course: only the three state files and the generated output change.

```
lecture-slides/
├── SKILL.md
├── MISSION.md              # live state — filled per course
├── NOTES.md                # live state — append-only
├── RESOURCES.md            # live state — filled per course
├── templates/              # pristine copies, used to reset for a new course
│   ├── MISSION.md
│   ├── NOTES.md
│   └── RESOURCES.md
├── assets/
│   ├── style.css           # shared by lessons and cheat sheets
│   └── quiz.js
├── lessons/                # active course: NNNN-<slug>.html
├── cheat-sheets/           # active course: lNN-<slug>.html
├── examples/               # archived courses (read-only reference)
│   └── fomo/
└── references/             # format documentation
```

Rules:

- `MISSION.md`, `NOTES.md`, `RESOURCES.md` at the root describe the **active** course only.
- `templates/` holds the pristine skeletons. Never edit a template while working on a course.
- `lessons/` and `cheat-sheets/` hold the active course only. One deck per lesson, one cheat sheet
  per deck.
- `examples/<slug>/` is an archived course, with its own `assets` symlink so its HTML keeps working.
- A file still containing `<...>` is a template, not state: run the setup interview in `SKILL.md`
  before generating anything.

## MISSION.md

```markdown
# Mission: <course name> — <university>, <term>

## Why
<exam date, grade target, what is currently behind>

## Success looks like
- <observable ability tied to the exam or project>
- <an ability to compute or compare, not just recall>

## Constraints
- <time per week>
- <preferred study style>
- <rules that forbid certain help, e.g. individual labs>

## Out of scope
- <what the learner explicitly does not want>
```

Change it only when the goal changes, and say why in `NOTES.md`.

## NOTES.md

```markdown
# Notes (teacher's scratchpad)

## Learner preferences (<YYYY-MM-DD>)
- Goal, time budget, current position.
- Style: <lesson then questions | Socratic | both>.
- Language rule.
- Format overrides, if any.

## Lesson format defaults
- <the baseline counts and components for every lesson>

## Course plan (≈<N> min per unit)
1. <lecture number and topic> — <queued | written>

## Working notes
- <deck-specific observations>
```

Append dated entries after each lesson: what was produced, what confused the learner, what to
review next. Never rewrite an older entry.

## RESOURCES.md

```markdown
# Resources

## Primary (highest trust — the exam is built from these)
- **Course slides**, <path or URL> — cite as *deck p.N*.
- **Exercises / projects**, <path or URL>.
- **Previous year**, <path or URL> — may be revised.

## Books / chapters
- <author>, *<title>*, <chapter and topic> — <URL>

## Papers cited in slides
- <authors>, "<title>" (<venue, year>) — <URL> (<deck p.N>)

## Community
- <forum, Q&A sessions, office hours>
```

Add a source only after checking it; record the version or date checked. Lesson citations use the
`deck p.N` form for slides and a normal link for everything else.

## Switching course

Archive the finished course, then reset the live state from the templates:

```sh
slug=<new-course-slug>          # name of the course being archived
mkdir -p "examples/$slug"/{lessons,cheat-sheets}
git mv MISSION.md NOTES.md RESOURCES.md "examples/$slug"/
git mv lessons/*.html "examples/$slug/lessons/"
git mv cheat-sheets/*.html "examples/$slug/cheat-sheets/"
ln -s ../../assets "examples/$slug/assets"
cp templates/MISSION.md templates/NOTES.md templates/RESOURCES.md .
```

Then run the setup interview and fill the three root files for the new course. Keep `.gitkeep` in
the emptied `lessons/` and `cheat-sheets/`.

Rules for the archive:

- The archived HTML must keep working: `examples/<slug>/assets` points at the shared `assets/`.
- Do not edit an archived course while the new one is active.
- Never delete an archive without asking.

## Output naming

- Lesson: `lessons/NNNN-<slug>.html`, numbered continuously within the active course.
- Cheat sheet: `cheat-sheets/lNN-<slug>.html`, where `NN` is the lecture number.
- Do not reuse a number after a lesson is written; if the deck splits, use the next two numbers.
