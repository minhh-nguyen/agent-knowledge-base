# Cheat-Sheet Format

One cheat sheet per lecture, written alongside the lesson. It is the compressed version of the
deck, not a copy of the lesson: no quizzes, no win box, no recall drill.

## File and links

- File: `cheat-sheets/lNN-<kebab-slug>.html`, where `NN` is the lecture number.
- Same stylesheet: `../assets/style.css`. No JavaScript.
- Links back to the lesson: `../lessons/NNNN-<slug>.html`.
- The lesson links here from its breadcrumb and from "Read next".

## Structure

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>LNN <topic> · cheat sheet</title>
<link rel="stylesheet" href="../assets/style.css">
</head>
<body>
<main>
<nav class="crumbs"><course short name> · Reference · <a href="../lessons/NNNN-<slug>.html">Lesson NNNN</a></nav>
<h1>Lecture NN · <topic></h1>
<p class="subtitle">The whole deck on two pages. Page numbers refer to <code>lectures/Lecture_NN_<name>.pdf</code>.</p>

<h2><topic group></h2>
<ul>
<li><fact, number, or trade-off> <span class="cite">p.N</span></li>
</ul>

<div class="table-wrap"><table>
<tr><th></th><th><A></th><th><B></th></tr>
<tr><td><aspect></td><td><value></td><td><value></td></tr>
</table></div>
<p class="cite">pp.N–M</p>

<span class="math"><formula>      <second formula></span>

<h2>Exam-style questions from the deck <span class="cite">p.N</span></h2>
<ol>
<li><question as printed on the deck, or a one-line paraphrase></li>
</ol>
</main>
</body>
</html>
```

## Rules

- Two pages when printed. If it grows, cut prose, not facts.
- Group by concept, not by slide order; a reader should find a topic without the deck open.
- Every line carries a page number. Use `p.N` for one page, `pp.N–M` for a range, and a single
  `p.cite` under a table instead of one per cell.
- Prefer tables for comparisons (HDD vs SSD, CSV vs Parquet, coherence protocols) and `.math` for
  formulas.
- Keep numbers, units, and ranges exactly as the deck states them.
- The final section lists the deck's own "Exam-style questions" page verbatim or near-verbatim,
  with the page number, and links to the lesson that works them out.
- No new claims, no advice, no exercises.
