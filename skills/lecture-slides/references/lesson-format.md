# Lesson Format

A lesson is one self-contained HTML file that teaches one lecture deck. It reuses
`../assets/style.css` and `../assets/quiz.js`; the only external asset is the pinned Mermaid bundle
that renders the mind map (`render.py` adds it). No other external CSS, JS, or CDN links.

## File naming and links

- File: `lessons/NNNN-<kebab-slug>.html`, numbered in teaching order (`0001`, `0002`, …).
- Stylesheet: `../assets/style.css`; script at the end: `../assets/quiz.js`.
- Cheat sheet: `../cheat-sheets/lNN-<kebab-slug>.html`.
- Previous/next lesson: relative file names in the breadcrumb and footer.
- One deck per lesson. Split a long deck only when it produces two genuinely separate wins.

## Section order

Keep this order. Numbers are literal (`1 ·`, `2 ·`, …).

| #    | Section                        | Content                                                                             |
| ---- | ------------------------------ | ----------------------------------------------------------------------------------- |
| —    | Breadcrumb                     | course · lecture · lesson · cheat sheet · next                                      |
| —    | Title + subtitle               | `<h1>` is a claim, subtitle says what the learner can do afterwards                 |
| —    | `.win`                         | one-sentence win tied to a real exam question, plus time budget                     |
| —    | Mind map                       | `.mm` Mermaid `mindmap`: root = lesson title, branches = keyword sections, leaves = keywords. Auto-generated; never hand-write. |
| —    | `.kw-strip`                    | every keyword, each linking to its card (`#k-<slug>`)                               |
| 1..N | Keyword sections               | 5–6 sections, each a `dl.kw` group of related keywords + 1–2 MCQs                   |
| N+1  | Use the keywords               | the deck's exam question worked step by step in `<details>` + `.key` answer pattern |
| N+2  | Keyword recall drill           | `.recall` with one `<details>` per keyword, one-sentence answer                     |
| N+3  | True / False                   | 8–10 items in `.qbank`                                                              |
| N+4  | What is …?                     | 8 items in `.qbank`, answer hidden                                                  |
| N+5  | Calculations                   | 5 items in `.qbank`, worked solution hidden                                         |
| N+6  | Exam-style questions (written) | 4 items in `ol.examq`, answers withheld                                             |
| —    | Read next + footer             | primary sources, cheat-sheet link, next lesson, "ask in chat" line                  |

## Keyword cards

Each keyword gets an anchor and a definition that can be said in one sentence, plus why it
matters:

```html
<dl class="kw">
  <div id="k-seek">
    <dt>seek time <span class="alt">1–20 ms</span></dt>
    <dd>
      Time for the arm to move the head to the right track
      <span class="cite">Deck p.20</span>.
      <span class="so">This is the biggest cost, and it is mechanical.</span>
    </dd>
  </div>
</dl>
```

- 10–16 keywords per lesson. More means the lesson is covering too much.
- `dt` = the term exactly as the deck uses it; `span.alt` = number, range, or expansion.
- `dd` = definition, then `span.so` = why it matters (the sentence that makes it exam-relevant).
- Every factual sentence ends with `<span class="cite">Deck p.N</span>`.
- Tables use `.table-wrap`; formulas use `<span class="math">`; emphasis uses `<em>`, not bold walls.

## Skeleton

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>NNNN · <title></title>
<link rel="stylesheet" href="../assets/style.css">
</head>
<body>
<main>
<nav class="crumbs"><course short name> · Lecture NN <topic> · Lesson NNNN · <a href="../cheat-sheets/lNN-<slug>.html">LNN cheat sheet</a> · next: <a href="NNNN-<slug>.html">NNNN</a></nav>
<h1><claim in plain words></h1>
<p class="subtitle"><what the learner can do after this lesson></p>

<div class="win"><strong>Your win today</strong>
<the exam question this lesson makes answerable>. About <N> minutes.</div>

<div class="mm"><strong>Mind map</strong>
<div class="mm-canvas">
<pre class="mermaid">
mindmap
  root["<lesson title>"]
    s1["1 · <section>"]
      k1_1["<keyword>"]
</pre>
</div>
</div>

<ul class="kw-strip">
<li><a href="#k-<slug>">keyword</a></li>
</ul>

<h2>1 · <topic></h2>
<dl class="kw">
<div id="k-<slug>"><dt>keyword <span class="alt">short form</span></dt>
<dd>definition <span class="cite">Deck p.N</span>.
<span class="so">why it matters.</span></dd></div>
</dl>

<div class="quiz" data-answer="1">
<p class="q"><question></p>
<button class="opt"><option A></button>
<button class="opt"><option B></button>
<button class="opt"><option C></button>
<p class="why"><why B is right> <span class="cite">Deck p.N</span>.</p>
</div>

<h2>N+1 · Use the keywords: the exam question</h2>
<p><em><exam question></em> <span class="cite">Deck p.N</span>. Try it on paper first, then open each step.</p>
<details><summary>Step 1: <what to compute></summary><p><answer></p></details>
<div class="key"><strong>Exam answer pattern</strong>
Formula → plug in numbers with units → result → name the bottleneck → one sentence on what would change it.</div>

<h2>N+2 · Keyword recall drill</h2>
<p>Cover the page. For each keyword, say a one-sentence definition <em>and</em> why it matters, then open it to check.</p>
<div class="recall">
<details><summary><keyword></summary><one-sentence answer></details>
</div>

<!-- True/False bank: 8–10 items, see quiz-format.md -->
<!-- What is bank: 8 items, see quiz-format.md -->
<!-- Calculations bank: 5 items, see quiz-format.md -->
<!-- Written exam: 4 items, see quiz-format.md -->

<h2>Read next</h2>
<p><primary sources and the cheat sheet></p>

<footer>Something unclear? Ask me in chat. Say “I don’t get X” and I’ll explain it again, starting from what X builds on.
Next: <a href="NNNN-<slug>.html">NNNN · <title></a>.</footer>
</main>
<!-- render.py inserts the Mermaid script here when a mind map exists -->
<script src="../assets/quiz.js"></script>
</body>
</html>
```

## Mind map

The mind map is an orientation aid, not a second table of contents. `render.py` derives it from the
lesson title and the keyword sections, so it is always consistent with the cards below:

- root: the lesson title;
- one branch per `## N · <section>` heading;
- one leaf per keyword in that section.

It is a Mermaid `mindmap` rendered client-side from the pinned bundle. Do not write Mermaid or SVG in
the source. If the map is unreadable, split the section or the deck — do not add deeper nesting.

## Writing rules

- Teach one idea per paragraph. Short sentences; no filler.
- Explain mechanism and trade-off, not feature lists.
- Prefer concrete numbers and units from the deck; never invent a number.
- Keep the learner's language for prose; keep technical terms in English with a short gloss when
  the prose is not English.
- Do not reveal answers in the question text, the option text, or a tooltip.
- Do not include lab solutions; the mission file forbids them.
