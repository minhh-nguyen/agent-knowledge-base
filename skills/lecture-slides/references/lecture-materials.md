# Lecture Materials

How to answer a question from the user's university material **without reading whole documents**.
Load this when the user names a course, a lecture, an exercise sheet, or an exam topic.

## Where the material lives

```
~/Documents/tuda/lectures/
├── 4.ws2627/          # current semester (semester 4)
│   ├── aidm/          # AI & Data Management
│   ├── chinesischI:II/
│   ├── eib/
│   ├── fomo/          # Foundations of Modeling
│   ├── hcsd/
│   ├── ite/
│   └── pmpp/          # Programming Massively Parallel Processors
├── 3.ss26/  2.ws2526/  1.ss26/   # earlier semesters
├── 0.other-modules/
└── .search/           # generated index — never edit by hand
```

Directories are numbered by semester. **Default to the highest-numbered one** unless the user
names another. Course directories may be git repositories; never write into them.

## The retrieval loop

Four steps. Do not skip ahead, and do not substitute "read the PDF".

**1. Find the course index** (a few hundred bytes):

```sh
cat ~/Documents/tuda/lectures/.search/4.ws2627/INDEX.md          # semester: course list
cat ~/Documents/tuda/lectures/.search/4.ws2627/pmpp/INDEX.md     # course: documents + page counts
```

**2. Locate which documents mention the topic** — filenames only, no content:

```sh
cd ~/Documents/tuda/lectures/.search/4.ws2627/pmpp
grep -ril "bank conflict" .
```

**3. Get the exact pages** from the page-tagged sidecar. Every line is `p<N>\t<text>`:

```sh
grep -i "bank conflict" "slides/05-...-Scans_Sorting_and_Synopsis.pdf.txt"
# p23  BANK CONFLICTS Source: NVIDIA C++ Programming Guide, Figure 35
# p23  Strided access can induce bank conflicts

grep -i "bank conflict" "<sidecar>" | cut -f1 | sort -u -V    # just the page list
```

**4. Read only those pages** from the real PDF, for the figures and layout:

```
Read(file_path="~/Documents/tuda/lectures/4.ws2627/pmpp/slides/05-....pdf", pages="23")
```

Widen to `pages="22-24"` only when the hit sits at a page boundary.

## Cost rules

- **Never** read a PDF without a page range. A 519-page textbook collapses to one page through
  this loop; reading it whole is the single most expensive mistake available here.
- **Never** `cat` a sidecar. They run to megabytes. Only `grep` them.
- Cap a single answer at roughly 10 pages across all documents. If a topic needs more, the
  question is too broad: narrow it with the user first.
- Prefer the lecture slides over the textbook. Use the textbook only when the slides are thin,
  or when the user asks for depth.
- Grep with the shortest distinctive phrase. Try a synonym before widening to more documents.

## Reading the results

- `p<N>` is the **PDF page index**, not the slide number printed on the slide. A deck with a
  title page is usually offset by one. Cite what the slide itself shows, and pass the `p<N>`
  value to the `pages` parameter.
- Sidecars have running headers and footers stripped, so a grep hit is real content, not a
  repeated banner.
- Sidecars hold text only. Figures, diagrams, and formula images exist only in the PDF — that
  is what step 4 is for. If a grep hit reads like a figure caption, read the page.
- A scanned PDF yields an empty or near-empty sidecar. Say so, then read its pages directly.

## When the index is missing or stale

```sh
~/agent-knowledge-base/tools/index-lectures.sh ~/Documents/tuda/lectures/4.ws2627
```

It is incremental: only PDFs newer than their sidecar are rebuilt. Add `--force` to rebuild all.
Run it when the user adds new material, or when `INDEX.md` lacks a document they mention.

If `pdftotext` is missing, the script says so; `brew install poppler` fixes it. Until then, fall
back to reading PDF pages directly and tell the user the index is unavailable.

## Then write

This section is specific to `[role: study.lecture]`; everything above mirrors the copy in
`[role: study.tutor]` and must stay identical.

A lesson covers one whole deck, not one topic, so the loop above changes at step 3:

1. Steps 1–2 as above: course `INDEX.md`, then find the deck.
2. **Size the deck's sidecar first:** `wc -c "<deck>.pdf.txt"`.
3. **Under 40 KB** (a normal lecture deck): read that one sidecar in full. Its text is far cheaper
   than page images and gives every page number for the citations. This is the only exception to
   "never `cat` a sidecar", and it applies to lecture decks only, never to textbooks.
4. **Over 40 KB:** it is not a single lecture. Grep it per keyword, as in step 3 above.
5. Open PDF pages (step 4 above) **only** where the sidecar shows a figure, diagram, table, or
   formula the lesson needs to reproduce, and only those pages.
6. Find the deck's exam-style questions with one grep (`grep -inE "exam|question|aufgabe"`), not
   by reading pages in order.

Cite `Deck p.N` from the sidecar's `p<N>`; when the printed slide number differs, use the one the
learner sees on the slide.
