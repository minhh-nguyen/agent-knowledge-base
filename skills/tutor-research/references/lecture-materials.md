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

## Then teach

Retrieval is not the answer. Once the material is in hand, return to the teaching loop in
[`../SKILL.md`](../SKILL.md): assess what the user already knows, then explain from the
underlying problem. Ground the explanation in what the slides actually say, and name the
document and page so the user can look at the figure.

When the slides are wrong, outdated, or unclear, say so explicitly rather than teaching the
error. Distinguish what the course claims from what is generally true.
