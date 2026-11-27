# Workspace Format

The skill folder holds only the method: `SKILL.md`, `references/`, `templates/`, `assets/`, and
`examples/`. Course state and generated material live in one folder per course under
`~/.claude/study/`, a symlink into the knowledge-base repository's `study/` folder:

```
~/.claude/study/<course>/
├── MISSION.md              # live state, filled per course
├── NOTES.md                # live state, append-only
├── RESOURCES.md            # live state, filled per course
├── assets -> ../../skills/lecture-slides/assets   # style.css, quiz.js
├── lessons/                # NNNN-<slug>.html
└── cheat-sheets/           # lNN-<slug>.html

<skill>/
├── SKILL.md
├── templates/              # pristine MISSION/NOTES/RESOURCES, copied into each new course
├── assets/                 # style.css, quiz.js: shared by every course
├── examples/fomo/          # one reference lesson and cheat sheet (read-only)
└── references/             # format documentation
```

Rules:

- Never write state or generated material into the skill folder or into the working project.
- `<course>` is the short course code used by the lecture folders (`fomo`, `pmpp`, …), lowercase.
- `templates/` holds the pristine skeletons. Never edit a template while working on a course.
- One deck per lesson, one cheat sheet per deck.
- A file still containing `<...>` is a template, not state: run the setup interview in `SKILL.md`
  before generating anything.

## New course

If `~/.claude/study` is missing, tell the user and stop; never fall back to another location.
Otherwise create the course folder once, from the skill folder:

```sh
c=~/.claude/study/<course>
mkdir -p "$c"/{lessons,cheat-sheets}
cp templates/MISSION.md templates/NOTES.md templates/RESOURCES.md "$c"/
ln -s ../../skills/lecture-slides/assets "$c/assets"   # relative: resolves inside the repository
```

Never overwrite an existing course folder. Then run the setup interview and fill the three files.

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

Switching course means switching folder: each course keeps its own state and output under
`~/.claude/study/<course>/`. Nothing is archived or moved. Never delete a course folder without
asking.

## Output naming

- Lesson: `lessons/NNNN-<slug>.html`, numbered continuously within the course.
- Cheat sheet: `cheat-sheets/lNN-<slug>.html`, where `NN` is the lecture number.
- Do not reuse a number after a lesson is written; if the deck splits, use the next two numbers.
