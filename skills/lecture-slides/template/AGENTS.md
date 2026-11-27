# template/

A scaffold for new `ws26-27/<course>/` sites, so every new course starts out
identical to the existing four (HCSD, PMPP, FOMO, Chinese I & II) instead of
each being designed from scratch by a different agent/chat.

This is a specialized copy of the course-site repo's own `template/`: `new-course.sh` here
additionally wires the new course for this skill's `scripts/render.py` pipeline — an owned
`assets/quiz.js` + `assets/style.css` (copied fresh from the skill, not symlinked), a `src/`
folder for Markdown sources, and `cheat-sheets/` as an alias for `reference/`. It also resolves
the course-site repo (`~/repo/minhh-nguyen.github.io`) by absolute path instead of assuming the
script's own location is the repo root, since it now lives inside this skill. The site repo's
own `template/new-course.sh` stays generic — for a course that will get bespoke tooling instead
(like HCSD/PMPP's `tools/lessongen/`), use that one, not this.

## What's here

- `skeleton/` — one course's starting files: `index.html` (with `{{COURSE_TITLE}}`,
  `{{COURSE_LABEL}}`, `{{COURSE_SLUG}}`, `{{COURSE_LEDE}}` placeholders), `assets/course.css` +
  `assets/components.css` (the same stylesheet pair HCSD and PMPP use — already
  wired for the site's palette, for the light/dark toggle via `--card` and the
  `:root[data-theme="dark"]` override, and for the `.site-header`/`.site-footer`/
  `.theme-toggle` cross-site nav chrome, using this file's own variables),
  `MISSION.md`/`NOTES.md`/`RESOURCES.md`, and empty `lessons/`/`reference/` folders.
- `new-course.sh` — copies `skeleton/` into `ws26-27/<slug>/` and fills in the
  placeholders.

## Using it (for an agent setting up a new course)

```
template/new-course.sh <slug> "<Course Title>" "<Badge Label>" ["<one-line lede>"]
```

Run it from the repo root. Then do the three steps it prints:

1. In the new course's own `<header>`, list the other current courses too
   (copy their `<a>` links from any existing `ws26-27/<course>/index.html`).
2. In every *existing* course's `<header>`, plus `index.html`/`blog/index.html`/
   `ws26-27/index.html`, add an `<a href="/ws26-27/<slug>/">` link for the new one.
3. Add a `.card` link to the new course inside `ws26-27/index.html`'s `.grid`
   (the script prints the exact markup to paste).

Steps 1-2 are plain HTML edits, same as adding a link anywhere else on this
no-build-step site — there's no shared nav script to update instead. This is a
deliberate tradeoff: the cross-site header/footer used to be injected by a
runtime script (`assets/site-nav.js`), but that only cost every page an extra
two requests and a visible empty-header flash to deliver markup that's
identical on every load; it was removed in favor of plain static HTML,
matching how the home page always did it. A handful of courses means a
handful of files to touch when adding one — accept that over reintroducing
the script.

Do not hand-write a new course's `index.html`/CSS from scratch, and do not
copy an _existing_ course folder (e.g. `ws26-27/hcsd/`) as a starting point —
always start from `template/skeleton/`, so new sites don't inherit one
course's course-specific JS/markup (progress bars, quiz widgets, etc.) by
accident. Lesson/exercise pages themselves are not templated here — each
course's content is still its own; only the shared chrome and palette are.

## Keeping the template in sync

If `assets/theme.js` changes in a way that affects how a course page should
reference it, no update is needed here — `skeleton/index.html` only links to
it by absolute path, it doesn't vendor a copy. The inline no-flash theme-init
`<script>` in `skeleton/index.html`'s `<head>`, however, is NOT referenced by
path — it's pasted inline (deliberately: it must run before first paint with
no extra request) and must stay byte-identical to the one in every other
page's `<head>` (home, blog, hub, and the four courses). If that snippet's
logic ever changes, update every copy, this one included — a shortened or
diverging copy is a bug, not a harmless variant (one shipped here before and
silently broke the toggle button's displayed state). If the _shared course_
stylesheet pair (`course.css`/`components.css`) gains a new widget that
should be available to every future course, or the dark-mode palette
changes, update `skeleton/assets/` to match, not just one course's copy.
