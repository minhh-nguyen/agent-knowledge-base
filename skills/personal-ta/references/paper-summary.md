# Paper Summary and Review

Response skeleton for `personal-ta` when the user asks to summarize, review, or critique a paper.

## Usage

1. Read the paper (or the sections the user supplied) before filling any section.
2. Copy the section order below. Do not reorder or merge sections.
3. Replace every `<...>` placeholder. Delete a bullet only when the paper genuinely has nothing
   to say about it, and write `Not reported` instead of guessing.
4. Match the user's language. Translate headings; keep technical terms in their original form.
5. Default length: 600–900 words total. Expand only when the user asks for a deep review.

## Evidence rules

- Mark each claim as one of: **paper's claim**, **measured result**, **my inference**.
- Cite the location for every number or strong claim: section, figure, table, or page.
- Never invent results, baselines, citations, or venue details. If metadata is missing, say so.
- If only the abstract is available, say that once at the top and keep the critique to what the
  abstract supports.
- Separate what the paper demonstrates from what it merely asserts.

---

# <Paper Title>

**Authors:** <authors> · **Venue/Year:** <venue, year> · **Link:** <DOI or URL>
**One-line verdict:** <what the paper achieves and how far the evidence supports it>

## 1. Motivation

- **Problem:** <the concrete problem the paper addresses>
- **Why it matters:** <cost, scale, or limitation that makes the problem worth solving>
- **Prior state:** <how existing work handles it, and where it falls short>
- **Claimed gap:** <the gap the paper says it closes — as the authors state it>
- **Assumptions:** <conditions the motivation depends on>

## 2. Solution

- **Core idea:** <the single mechanism or insight in one or two sentences>
- **How it works:** <design, components, data or control flow — enough to re-explain it>
- **Key design choices:** <the choices that carry the contribution, and the alternative rejected>
- **Novelty:** <what is new relative to the cited prior work, as claimed>
- **Scope:** <what the solution does not attempt to handle>

## 3. Evaluation

- **Setup:** <hardware, software, datasets or workloads, scale>
- **Baselines:** <what it is compared against, and whether they are the strongest available>
- **Metrics:** <what is measured; note throughput, latency, tail behavior, cost where relevant>
- **Main results:** <headline numbers with the table or figure they come from>
- **Ablations / sensitivity:** <which component is shown to matter, and how>
- **Threats to validity:** <workload bias, tuned baselines, missing configurations, unreported variance>

## 4. Critique

- **Strengths:** <what is genuinely well done — problem choice, method, or evidence>
- **Weaknesses:** <what is unsupported, underspecified, or overstated>
- **Evidence check:** <do the results actually support the headline claim? where does the chain break?>
- **Reproducibility:** <artifacts, parameters, and detail needed to repeat the work>
- **Missing comparisons:** <baselines or conditions a reviewer would require>

## 5. Conclusion

<Three to five sentences: what the paper establishes, what remains unproven, and who should care.
No new claims here — only synthesis of the sections above.>

## 6. Research Gap

- **Gaps left open:** <questions the paper does not answer, ordered by importance>
- **Why they are tractable:** <data, tooling, or method that now makes them attackable>
- **Candidate research question:** <one falsifiable question>
- **Sketch of an experiment:** <workload, baseline, metric, and the result that would count as
  evidence for or against>
- **Risks:** <what could invalidate the direction>
