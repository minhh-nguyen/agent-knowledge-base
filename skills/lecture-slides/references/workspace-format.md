# Workspace Format

The skill folder holds only the method: `SKILL.md`, `scripts/`, `references/`, `template/`,
`assets/`, and `examples/`. Course state and generated material are the deliverable itself, and
live in the user's public course-site repo, one folder per course:

```
~/repo/minhh-nguyen.github.io/ws26-27/<course>/
├── index.html               # course hub: lesson grid, links to MISSION/NOTES/RESOURCES
├── MISSION.md                # live state, filled per course
├── NOTES.md                  # live state, append-only
├── RESOURCES.md               # live state, filled per course
├── assets/                   # course.css, components.css (site chrome) + this skill's
│                              #   quiz.js, style.css (owned copies, not symlinks — see below)
├── src/                      # NNNN-<slug>.md, lNN-<slug>.md: what the agent writes
├── lessons/                  # NNNN-<slug>.html, rendered from src/
├── reference/                # lNN-<slug>.html, rendered from src/ (the cheat sheets)
└── cheat-sheets -> reference # alias so scripts/render.py's hardcoded output path still works

<skill>/
├── SKILL.md
├── scripts/render.py        # source → lesson / cheat-sheet HTML
├── template/                 # new-course.sh + skeleton/, scaffolds a new course folder above
├── assets/                   # style.css, quiz.js: copied (not symlinked) into each new course
├── examples/fomo/            # one reference lesson and cheat sheet (read-only)
└── references/               # format documentation
```

Rules:

- Never write state or generated material into the skill folder.
- `<course>` is the short course code used by the lecture folders (`fomo`, `pmpp`, …), lowercase.
- `assets/quiz.js` and `assets/style.css` are **owned copies**, not symlinks: a course may adapt
  its stylesheet (FOMO widened `main` and wired the site's light/dark toggle). Re-copy from the
  skill only when you want to reset a course back to the shared default.
- One deck per lesson, one cheat sheet per deck.
- A file still containing `<...>` is a template, not state: run the setup interview in `SKILL.md`
  before generating anything.

## New course

Run `template/new-course.sh <slug> "<Course Title>" "<Badge Label>" ["<lede>"]` (see
[`../template/AGENTS.md`](../template/AGENTS.md)). It creates
`~/repo/minhh-nguyen.github.io/ws26-27/<slug>/` from `template/skeleton/`, adds `src/`, the
`cheat-sheets -> reference` alias, and copies in `assets/quiz.js`/`assets/style.css`. It refuses
to run if the course-site repo is missing or the destination already exists — never fall back
to another location, and never overwrite an existing course folder.

Three manual steps the script prints afterward — plain static HTML edits, since the site has no
shared nav script (do them before the course is reachable from the rest of the site):

1. In the new course's own `<header>`, list the other current courses too.
2. In every *existing* course's `<header>`, plus `index.html`/`blog/index.html`/
   `ws26-27/index.html`, add an `<a href="/ws26-27/<slug>/">` link for the new one.
3. Add a `.card` link to the new course inside the site repo's `ws26-27/index.html`'s `.grid`.

Then run the setup interview in `SKILL.md` and fill `MISSION.md`/`NOTES.md`/`RESOURCES.md`.

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
`~/repo/minhh-nguyen.github.io/ws26-27/<course>/`. Nothing is archived or moved. Never delete a
course folder without asking.

## Output naming

- Lesson: `src/NNNN-<slug>.md` → `lessons/NNNN-<slug>.html`, numbered continuously within the course.
- Cheat sheet: `src/lNN-<slug>.md` → `cheat-sheets/lNN-<slug>.html` (physically `reference/`),
  where `NN` is the lecture number.
- Do not reuse a number after a lesson is written; if the deck splits, use the next two numbers.
