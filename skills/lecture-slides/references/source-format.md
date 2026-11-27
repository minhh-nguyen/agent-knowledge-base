# Source Format

The agent writes a compact source file; `scripts/render.py` turns it into the exact HTML that
[`lesson-format.md`](lesson-format.md), [`quiz-format.md`](quiz-format.md), and
[`cheat-sheet-format.md`](cheat-sheet-format.md) specify. Those files stay the contract for
content and counts; this file is only the syntax. Never write lesson or cheat-sheet HTML by hand.

## Files

```
~/repo/minhh-nguyen.github.io/ws26-27/<course>/src/NNNN-<slug>.md   → lessons/NNNN-<slug>.html
~/repo/minhh-nguyen.github.io/ws26-27/<course>/src/lNN-<slug>.md    → cheat-sheets/lNN-<slug>.html
```

Render (uv installs the `markdown` dependency on first run):

```sh
uv run ~/.claude/skills/lecture-slides/scripts/render.py \
  ~/repo/minhh-nguyen.github.io/ws26-27/<course>/src/NNNN-<slug>.md
```

Exit `0` = written and all counts pass; `1` = written but `check:` lines list count violations to
fix in the source; `2` = `error:` in the source, nothing written. `--check` validates without
writing. To change a lesson later, edit the source and re-render; never patch the HTML.

## Front matter

```yaml
---
kind: lesson                # lesson | cheat
course: FOMO                # short name in the breadcrumb
lecture: 01
topic: Storage
deck: Storage               # citation label: [[p.6]] → "Storage p.6" (default "Deck")
lesson: 0001                # lesson only; default: first 4 chars of the file name
title: Storage, in 16 keywords   # lesson: the h1 claim; cheat: the topic in <title>
subtitle: Learn the keywords, then estimate HDD vs SSD read time.
win: You can answer the exam question on p.61 …   # lesson only
minutes: 30                 # lesson only
cheat: l01-storage.html     # lesson only: link to the cheat sheet
next: 0002-ssd.html         # optional
next_title: SSD internals   # optional
lesson_file: 0001-storage-latency-math.html   # cheat only: link back to the lesson
---
```

The script generates the breadcrumb, `<title>`, `.win`, the `.kw-strip` (from every keyword in
order), the footer, and the stylesheet/script links. Cheat sheets get no script.

## Body

Plain Markdown for headings (`## 1 · Hierarchy`, numbers written literally), paragraphs, lists,
links, `**strong**`, `*em*`, `` `code` ``, and tables (wrapped in `.table-wrap` automatically).
Citations: `[[p.12]]`, `[[pp.27, 29]]`, `[[pp.20–30]]`. A paragraph that is only a citation (under
a table) becomes `<p class="cite">`.

Fenced blocks, one per component. Fields are separated by `|`; multi-line items by a blank line.

| Block | One line / item | Renders |
| --- | --- | --- |
| `keywords` | `slug \| term \| alt \| definition [[p.N]] \| why it matters` (alt may be empty) | `dl.kw` with `#k-<slug>` |
| `mcq` | `Q:` question, three `- ` options, `A:` 1–3, `Why:` explanation | `.quiz` |
| `steps` | `Step 1: what to compute \| answer`, optional last line `Key: pattern` | `<details>` + `.key` |
| `recall` | `term \| one-sentence answer`; **leave empty** to generate one per keyword | `.recall` |
| `tf` | `T` or `F` `\| statement \| explanation [[p.N]]` | `.qbank` of `.item.quiz` |
| `whatis` | `the thing \| answer [[p.N]]` | `.qbank`, answer in `<details>` |
| `calc` | `Q:` problem, `S:` worked solution | `.qbank`, solution in `<details>` |
| `exam` | `Explain why \| question` (verb first) | `ol.examq` + the closing line |
| `math` | one formula per line | `span.math` |

Example of one keyword section:

````markdown
## 2 · Hard disks

```keywords
seek | seek time | 1–20 ms | Time for the arm to move the head to the right track [[p.20]]. | The biggest cost, and it is mechanical.
rot | rotational delay | ~4 ms | Waiting for the sector to rotate under the head [[p.20]]. | Halved by spinning faster.
```

```mcq
Q: Which part of a random HDD read dominates?
- Transfer time
- Seek time
- Controller overhead
A: 2
Why: Seek is 1–20 ms; transfer of 4 KB is ~0.1 ms [[p.21]].
```
````

## What the script checks

Counts from `SKILL.md`: 10–16 keywords, at least 10 MCQs, 8–10 True/False, 8 What-is,
5 calculations, 4 written questions; MCQ answers not all in one position; a citation on every
keyword; no script in a cheat sheet. It does not check content quality, page numbers, or coverage —
those stay in the finish checklist.
