---
name: paper-graph
description: "[role: research.lineage] Map a field or model family's evolution with predecessors, follow-ups, and Mermaid diagrams in Markdown. Mode: do. Use for topic history or family trees. Do NOT use for paper search ([role: research.find]), one-paper summaries, comparisons, or dataset lists."
allowed-tools: "write_file edit_file read_file execute"
metadata:
  author: "EvoScientist - edited: Minh"
  version: "0.1.3"
  tags: [research, literature-review, graph, mermaid]
---

# Paper Graph

Build a Markdown report with embedded Mermaid diagrams showing how research on a user-specified topic (or paper) evolved — clustered into challenges → solutions and traced as per-solution evolution paths.

The skill has no outbound LLM dependency. The host agent provides all LLM calls; the skill provides deterministic data fetchers (S2 / DeepXiv), prompt templates, markdown parsers, and Mermaid renderers. Run the runbook below step-by-step.

**Execution requirement.** When the caller already provides `parsed_query.json`, `seed.json` and `papers.json` (wherever they are, for example in an `input/` directory), copy them into the workdir under those names, treat steps 1–5 as complete and start at step 6. Still run every deterministic CLI step from classify through assemble; do not replace parsing, edge audit, rendering, or assembly with hand-authored Mermaid. Before finishing, verify that every parsed solution has a detail render and an audit verdict file, even when that file is an empty JSON list. Treat `assemble_report` as the only final-report writer: do not edit or append hand-authored edges afterward, even when a caller asks to display uncertain relationships. Preserve uncertainty in verdict JSON.

## When to Use This Skill

The description already routed here. Stop and hand over if the request turns out to be a one-paper
summary, a single latest paper or keyword search (`[role: research.find]`), a plain bibliography,
an inventory of datasets / benchmarks / tools, or a head-to-head comparison.

---

## Inputs and Output

**Inputs:**

- A **research query**: a topic, a seed paper title/citation, or a hybrid. Free-form text.
- **Output path**: path for the final Markdown report. Default: `~/.claude/research-report/lineage-<topic>-<YYYY-MM-DD>.md` (see Output Location).
- _(Optional)_ number of papers to fetch (`--n` flag on `fetch_papers`). Default **10**.
- _(Optional)_ Mermaid theme `light` or `dark` (`--theme` on render steps, or `MERMAID_THEME` env). Default **light**.

**Output:** a single Markdown file at the user-specified path with these sections:

1. **Research goal** (extracted from the query)
2. **High-level taxonomy** — one Mermaid graph: root → challenges → solutions → paper references
3. **Per-solution evolution paths** — one Mermaid graph per solution, showing paper-to-paper "evolution from" edges, evolution points, open challenges
4. **Paper appendix** — the numbered list of papers with title / year / authors / abstract / conclusion excerpt

Mermaid is just text inside ` ```mermaid ` fences — the file renders directly in GitHub, Obsidian, VS Code with the Mermaid extension, etc.

---

## Setup

**Required env (the skill fails verbosely if missing):**

- `S2_API_KEY` — Semantic Scholar API key.

**Optional env:**

- `DEEPXIV_API_TOKEN` (or `DEEPXIV_TOKEN`) — DeepXiv arXiv search fallback. Install with `pip install deepxiv-sdk`; auto-provision with `deepxiv token`. Without it, S2 must fill the cite-number budget on its own.
- `MERMAID_THEME` — `light` (default) or `dark`. Overridden by `--theme` on each render call.

**LLM:** the host agent uses its own model and API key. The skill emits prompt templates and parses responses; it does not authenticate or call any LLM provider.

**Working directory:** create one dir per run at `~/.claude/research-report/.work/paper-graph/<basename>/`, never in the project you are working in (see Output Location). Resolve `~` once to the absolute home path (`echo $HOME`) and use that same absolute path in both the shell and the file tools, so both see the same directory. Avoid `/tmp/...`. If the shell or the file tools cannot reach that directory, stop and tell the user rather than falling back to the working directory.

The file each step reads and writes is named in the step itself; the full scratch-directory map
is in [`references/workdir-layout.md`](references/workdir-layout.md) (open it only when a path is unclear).

---

## Runbook

Each step is either a **CLI** call (`python scripts/cli.py <subcmd> …`) or an **LLM** call (the host agent reads a template from `references/`, substitutes the placeholders, and calls its model). All script and reference paths are relative to this skill's directory. CLI dependencies: `pip install deepxiv-sdk httpx python-dotenv` (also listed in `requirements.txt` at the skill root) — install into the environment the user is working in. Run sequentially; the detail step (step 10) and the audit step (step 11) can fan out per-solution / per-edge if the host supports concurrent tool calls.

**Placeholder syntax in `references/*.md`.** Single-brace `{name}` is a template slot the host must substitute. Double-brace `{{...}}` is an escaped literal brace — it appears in the prompt body when the example JSON the LLM is asked to emit contains braces. Substitute only single-brace slots; leave `{{` and `}}` alone (they're for the LLM to read as `{` and `}` in its output).

### Step 1 — Save the user query

Write the user's verbatim query to `<workdir>/query.txt`. Do not paraphrase. Multi-line queries are fine.

### Step 2 — `resolve_seed_papers` (CLI, deterministic)

```bash
python scripts/cli.py resolve_seed_papers \
    --query-file <workdir>/query.txt \
    --out <workdir>/seed.json
```

Outputs a JSON array of S2-shape paper records for any arxiv IDs detected in the query. Empty array when none are present or all lookups fail.

### Step 3 — `format_seed_block` (CLI, deterministic)

```bash
python scripts/cli.py format_seed_block \
    --seed <workdir>/seed.json \
    --out <workdir>/seed_block.txt
```

Renders the seed papers into the `{seed_block}` prompt fragment used in step 4. Empty input → empty output (the placeholder collapses cleanly).

### Step 4 — `parse_query` (LLM)

Read `references/parse_query.md`. Substitute `{seed_block}` with the contents of `<workdir>/seed_block.txt` and `{query}` with the contents of `<workdir>/query.txt`. Call the LLM (low temperature, ~0.1).

Parse the response as JSON with this exact shape:

```json
{
  "goal": "<one sentence>",
  "searches": ["<keyword phrase 1>", "<keyword phrase 2>", "..."],
  "definitions": { "<term>": "<one-sentence definition>", "...": "..." }
}
```

Per the prompt's own instructions, `searches` should contain 2–4 phrases each of 2–5 keywords (these are two different counts — phrases vs. keywords-per-phrase).

Strip code fences if the model added them. Validate that `goal` is non-empty and `searches` is a non-empty list of strings. If the response is malformed, re-prompt the LLM once; on second failure, abort with a clear error message.

Save the validated JSON to `<workdir>/parsed_query.json`.

### Step 5 — `fetch_papers` (CLI, deterministic)

```bash
python scripts/cli.py fetch_papers \
    --parsed-query <workdir>/parsed_query.json \
    --seed <workdir>/seed.json \
    --n 10 \
    --out <workdir>/papers.json
```

Uses S2 multi-search (one S2 query per `searches[]` entry) with DeepXiv fallback to top up to `--n` papers. Output is a JSON array of S2-shape paper dicts. If S2 returns nothing and DeepXiv is unavailable, exits non-zero — re-prompt step 4 with sharper search phrases.

### Step 6 — `classify` (LLM)

First build the full `{papers_input}` block:

```bash
python scripts/cli.py format_papers \
    --papers <workdir>/papers.json \
    --out <workdir>/papers_input.txt
```

Read `references/classify.md`. Substitute `{goal}` with the `goal_sentence` (the single-sentence string at `parsed_query.json["goal"]` — bare, no definitions block here) and `{papers_input}` with the text file above. Call the LLM (low temperature, no reasoning needed — it's a discrete cataloging decision). Strip any leading/trailing code fences if the model added them.

Save the raw response verbatim to `<workdir>/classify_raw.json`. Expected shape:

```json
{"classifications": [
  {"n": 1, "label": "CORE", "reason": "..."},
  {"n": 2, "label": "ADJACENT", "reason": "..."},
  {"n": 3, "label": "REJECT", "reason": "..."},
  ...
]}
```

Then merge into papers.json via the CLI (validates shape + applies failure-soft fallback to every-CORE if validation fails):

```bash
python scripts/cli.py merge_classifications \
    --classifications <workdir>/classify_raw.json \
    --papers <workdir>/papers.json \
    --out <workdir>/papers.json
```

`merge_classifications` always exits 0; on validation failure it applies an all-CORE safety-net and prints a `… (FALLBACK: <reason>)` suffix on the stdout success line. When you see that suffix, re-prompt the LLM once; if the second attempt also falls back, accept the all-CORE result and proceed — every paper just feeds the outline as CORE. On a clean run the success line shows the per-label counts and no FALLBACK suffix. Downstream subcommands (`parse_outline`, the renderers, `assemble_report`) read these labels via `_label_of`.

### Step 7 — `prefetch_sections` (CLI, deterministic, best-effort)

```bash
python scripts/cli.py prefetch_sections \
    --in <workdir>/papers.json \
    --out <workdir>/papers.json
```

Mutates each paper dict in place by setting `_conclusion_section`. REJECT-labeled papers are skipped to save quota. Failures are silent; a paper without an arxiv ID or without a fetchable section just gets `_conclusion_section: null`.

After this step, any subsequent `format_papers` call automatically embeds each paper's `_conclusion_section` into the formatted block (under a `Discussion/Conclusion excerpt:` header) — that's how the outline and detail prompts get the OC-source signal the prompt templates reference. No extra step required.

### Step 8 — `outline` (LLM)

Materialize the two prompt fragments that recur from here on — `goal_block` (the `{goal}` substitution) and `core_filter` (the CORE-only filter + its `{allowed_numbers}` sidecar) — as files on disk. Steps 10 and 11 read these files back, so the agent never has to carry them as conversation state.

```bash
python scripts/cli.py build_goal_block \
    --parsed-query <workdir>/parsed_query.json \
    --out <workdir>/goal_block.txt

python scripts/cli.py compute_core_filter \
    --papers <workdir>/papers.json \
    --out <workdir>/core_filter.json
```

`compute_core_filter` writes the index JSON to `--out` and the matching `(N), (N), ...` `{allowed_numbers}` form to a sibling `<out>.allowed.txt`. A paper without a classification counts as CORE, as everywhere else in this skill. On a no-CORE classifier outcome it falls back to every paper and prints `(FALLBACK: …)` — the run continues.

Build the CORE-only `{papers_input}` (also emits a sibling `.allowed.txt`, redundant here but consistent with Step 10):

```bash
python scripts/cli.py format_papers \
    --papers <workdir>/papers.json \
    --filter <workdir>/core_filter.json \
    --out <workdir>/papers_input_core.txt
```

Read `references/outline.md`. Substitute:

- `{goal}` — contents of `<workdir>/goal_block.txt`.
- `{papers_input}` — contents of `<workdir>/papers_input_core.txt`.
- `{allowed_numbers}` — contents of `<workdir>/core_filter.json.allowed.txt`.

Call the LLM (low temperature, ~0.2; allow ~8000 max tokens). Strip any leading/trailing code fences from the response — the prompt instructs the model to emit raw Markdown but a fence sometimes slips through. Save the cleaned Markdown to `<workdir>/outline_raw.md`.

### Step 9 — `parse_outline` (CLI, deterministic)

```bash
python scripts/cli.py parse_outline \
    --raw <workdir>/outline_raw.md \
    --papers <workdir>/papers.json \
    --out <workdir>/outline.json \
    --solutions-dir <workdir>/solutions
```

Writes the outline summary plus one `solutions/<key>.json` context file per solution. Schema of each context file (consumed in steps 10 and 12):

```json
{
  "challenge_idx": 1,
  "challenge_name": "Quality of random-projection targets",
  "solution_key": [1, 1],
  "solution_key_str": "1.1",
  "solution_name": "Optimization of the BEST-RQ pre-training objective",
  "paper_nums": [1, 3],
  "allowed": [1, 2, 3, 4]
}
```

`paper_nums` is the valid, de-duplicated primary taxonomy membership; when the outline repeats a paper, its first placement wins. `allowed` contains all CORE papers so detail generation can recover a canonical predecessor or successor without duplicating its primary taxonomy placement. `format_papers --filter <solutions/key.json>` and `parse_detail --context <solutions/key.json>` both read `allowed` automatically. Use `paper_nums` only for the `{primary_numbers}` prompt field.

A solution header that the outline restates reopens the same solution. A solution left without any valid paper (all its numbers were hallucinated or already placed elsewhere) is pruned: it gets no context file and no node in the taxonomy, and the success line on stdout names it. So every context file has a non-empty `paper_nums`.

Exits with code 4 and a stderr diagnostic if the outline contained no parseable `## Challenge N:` headers, or if no solution is left with a valid paper. Re-prompt step 8 once; on second failure, lower `--n` in step 5 or sharpen the query.

### Step 10 — `detail` (LLM, per solution)

> **CRITICAL — read "Fan-out task brief" below BEFORE delegating this step to subagents.** A subagent prompt that points at SKILL.md or asks to "run paper-graph for solution X" will restart the whole workflow from Step 1 in a separate workdir, and its output will be unusable by the parent run.

Read `references/detail.md` **once** at the start of this step; substitute per-solution in the orchestrator. The subagents you fan out to never read templates themselves.

For each `<workdir>/solutions/<key>.json` produced in step 9:

(a) The per-solution `{papers_input}` is the CORE pool: every solution context's `allowed` is the full CORE set, so the block is the same for every solution and identical to `<workdir>/papers_input_core.txt` from Step 8 (with its `.allowed.txt` sibling). Reuse those two files. Running `format_papers --filter <workdir>/solutions/<key>.json --out <workdir>/details/<key>_input.txt` per solution still works and writes the same content; it is only needed if Step 8's files are gone.

(b) Substitute into `references/detail.md`:

- `{goal}` — contents of `<workdir>/goal_block.txt` (the file built in Step 8).
- `{challenge_name}` — from the solution context (`challenge_name`).
- `{solution_name}` — from the solution context (`solution_name`).
- `{primary_numbers}` — comma-separated `(N)` values from the solution context's `paper_nums`.
- `{papers_input}` — contents of `<workdir>/papers_input_core.txt` (or the per-solution copy).
- `{allowed_numbers}` — contents of `<workdir>/papers_input_core.txt.allowed.txt`.

Call the LLM (temperature ~0.2; allow ~12000 max tokens to fit scratchpad + tree). Save the raw response to `<workdir>/details/<key>_raw.md`.

(c) Parse it (output goes to a sibling `parsed/` dir, not `details/`, so step 13's `assemble_report` doesn't pick up parse outputs as render outputs):

```bash
python scripts/cli.py parse_detail \
    --raw <workdir>/details/<key>_raw.md \
    --context <workdir>/solutions/<key>.json \
    --out <workdir>/parsed/<key>.json
```

The parsed JSON's `edges` list is the input to Step 11.

If the host supports concurrent tool calls, fan all per-solution LLM calls + their parse_detail follow-ups out in parallel.

**Fan-out task brief (when delegating step 10b to a subagent per solution).** The subagent's prompt must be self-contained: do **not** point the subagent at SKILL.md, do **not** instruct it to "run paper-graph for solution X," and do **not** give it any CLI invocation to run. The orchestrator does the substitution itself and hands the subagent only:

- The fully-substituted prompt string (already with `{goal}`, `{challenge_name}`, `{solution_name}`, `{primary_numbers}`, `{papers_input}`, `{allowed_numbers}` filled in).
- The expected response shape: raw Markdown evolution tree per `references/detail.md`'s output spec.
- An explicit instruction: _"Call your LLM with the prompt below and return only the raw Markdown response. Do not read any other file, do not run any shell command, do not invoke any other skill."_

Do **not** point the subagent at SKILL.md, do **not** instruct it to "run paper-graph for solution X", and do **not** give it any CLI invocation to run. The subagent returns the Markdown text; the orchestrator writes it to `<workdir>/details/<key>_raw.md` and runs `parse_detail` itself. **A subagent that re-reads SKILL.md will restart the whole workflow from step 1** — the fix is to keep the subagent prompt bounded as above.

### Step 11 — `audit_edge` (LLM, per edge)

> **CRITICAL — read "Fan-out task brief" below BEFORE delegating this step to subagents.** Same orchestration failure mode as Step 10: a subagent pointed at SKILL.md restarts the whole workflow.

Read `references/audit_edge.md` **once** at the start of this step; substitute per-edge in the orchestrator. The subagents you fan out to never read templates themselves.

For each `<workdir>/parsed/<key>.json`'s `edges` list, audit each edge against the source / target abstracts and conclusion excerpts.

For every `{source_n, target_n, gap}` edge in the solution:

- Look up source paper = `papers[source_n - 1]` and target = `papers[target_n - 1]` from `<workdir>/papers.json`.
- Substitute the placeholders in `references/audit_edge.md`: `{m_n}`, `{m_title}`, `{m_year}`, `{m_abstract}` (truncated to 1500 chars), `{m_excerpt}` (the `_conclusion_section` or `(no excerpt)`, truncated to 1500 chars), `{n_n}`, `{n_title}`, `{n_year}`, `{n_abstract}`, `{n_excerpt}`, `{gap_text}`.
- Call the LLM (low temperature ~0.1, reasoning off, ~1000 max tokens — enough for two quotes of up to 300 characters and the reason). Parse the response:

```json
{"verdict": "SUPPORTED_BY_ABSTRACT" | "SUPPORTED_BY_SECTION" | "INFERRED" | "REJECT",
 "source_quote": "<verbatim source evidence or NONE>",
 "target_quote": "<verbatim target evidence or NONE>",
 "reason": "<one sentence>"}
```

On parse failure, default the verdict to `REJECT`. Only `SUPPORTED_BY_ABSTRACT` and `SUPPORTED_BY_SECTION` become directed evolution edges. `INFERRED` records a possible relationship for the audit trail but is not rendered as a directed lineage claim.

**Fan-out task brief (when delegating per edge or per solution to subagents).** Same discipline as step 10: do **not** point the subagent at SKILL.md, do **not** instruct it to "run paper-graph audit," and do **not** give it any CLI invocation. The orchestrator does the substitution itself and hands the subagent only:

- The fully-substituted prompt string (already with `{m_n}`, `{m_title}`, `{m_year}`, `{m_abstract}`, `{m_excerpt}`, `{n_n}`, `{n_title}`, `{n_year}`, `{n_abstract}`, `{n_excerpt}`, `{gap_text}` filled in).
- The expected response shape: a JSON object with `verdict`, `source_quote`, `target_quote`, and `reason`.
- An explicit instruction: _"Call your LLM with the prompt below and return only the JSON verdict object. Do not read any other file, do not run any shell command, do not invoke any other skill."_

The subagent returns the verdict JSON; the orchestrator aggregates per-solution lists into `<workdir>/verdicts/<key>.json`. A subagent given a prompt that references SKILL.md will restart the workflow from step 1 — keep the brief bounded.

Collect all per-solution verdicts into `<workdir>/verdicts/<key>.json` as a flat list:

```json
[{"source_n": 1, "target_n": 3, "verdict": "SUPPORTED_BY_ABSTRACT",
  "source_quote": "<verbatim source evidence>",
  "target_quote": "<verbatim target evidence>", "reason": "..."}, ...]
```

Write one record per audited edge, and write the file even when the solution has no edges (`[]`): step 12 requires it. Copy each quote exactly as the audit returned it; do not repair or shorten quotes by hand.

The renderer in step 12 re-checks every record against `papers.json` and draws an edge only when all of the following hold; anything else is not rendered as directed lineage:

- the verdict is `SUPPORTED_BY_ABSTRACT` or `SUPPORTED_BY_SECTION`;
- each quote is at least 20 characters, is not `NONE`, and occurs inside that paper's title, abstract or excerpt — inside one of them, not across two (line breaks, repeated spaces and typographic quotes or dashes are normalized before matching; wording and case are not);
- the source is not newer than the target (when a year is missing the check is skipped and noted);
- source and target are different papers inside `papers.json`;
- if several records name the same edge, every one of them passes;
- the edge is not part of a cycle of supported edges (possible when years are equal or missing).

A malformed record (not an object, or without integer `source_n` / `target_n`) is ignored and reported; it does not stop the render.

### Step 12 — `render_outline_mermaid` + `render_detail_mermaid` (CLI, deterministic)

```bash
python scripts/cli.py render_outline_mermaid \
    --raw <workdir>/outline_raw.md \
    --papers <workdir>/papers.json \
    --out <workdir>/outline_mermaid.json \
    [--theme dark]
```

For each solution:

```bash
python scripts/cli.py render_detail_mermaid \
    --raw <workdir>/details/<key>_raw.md \
    --context <workdir>/solutions/<key>.json \
    --papers <workdir>/papers.json \
    --verdicts <workdir>/verdicts/<key>.json \
    --out <workdir>/details/<key>.json \
    [--theme dark]
```

`--verdicts` is required: a render without the audit would draw every claimed edge. The success line reports how many claimed edges were rendered, followed by one line per edge that was not (`not rendered (1)->(3): source_quote not found …`), per ignored verdict record, and per verdict that matches no edge of this detail output (a sign that the verdict file is stale or belongs to another solution). The same information is stored in the output JSON (`edges_rendered`, `edges_not_rendered`, `verdicts_unmatched`, `audit_downgrades`, `audit_notes`) next to `"audited": true`. An edge that is not rendered stays out of the graph; do not edit the verdict file to force it in.

### Step 13 — `assemble_report` (CLI, deterministic)

```bash
python scripts/cli.py assemble_report \
    --parsed-query <workdir>/parsed_query.json \
    --outline <workdir>/outline_mermaid.json \
    --details-dir <workdir>/details \
    --papers <workdir>/papers.json \
    --out <user-supplied output path>
```

Walks `details/` for every render JSON, sorts by `(challenge_idx, s_major, s_minor)`, writes the final Markdown report at the user-supplied output path. A render JSON without `"audited": true` (left over from a run without `--verdicts` or from an older version) stops the command with exit code 2 before anything is written; re-run step 12 for the files it names. Only `*.json` files containing a `mermaid` field are consumed — `*_raw.md`, `*_input.txt`, and any non-render JSON sitting alongside are skipped (and counted on stdout if any). This is why parse_detail outputs go to a sibling `parsed/` dir per the workdir layout, not into `details/`.

---

## Verification

After step 13 completes, read the first ~40 lines of the report to confirm:

- The taxonomy has at least 2 challenges and each has at least 1 solution.
- Each Mermaid block opens with ` ```mermaid ` and closes with ` ``` `.
- The paper appendix exists at the bottom of the file.

If any of those fail, the most likely cause is the outline LLM (step 8) returning malformed Markdown. Re-run step 8; if it fails twice, lower `--n` on step 5 or sharpen the query.

---

Editors of this skill: design notes are in [`references/design-notes.md`](references/design-notes.md); the runtime agent does not need them.

## Output Location

Everything this skill writes — answers, reports, summaries, syntheses, ideas, and scratch files —
is stored **only in the knowledge-base repository**, reached from any project through
`~/.claude/research-report/` (expand `~` to the absolute home path when a tool needs one).
Persistent memory goes to `~/.claude/memory/`, which also lives in that repository.

- Never write into the project you are working in: no `research-report/`, `memory/`, or scratch
  folder in the working directory.
- If `~/.claude/research-report` does not exist, do not fall back to the working directory:
  tell the user and stop before writing.
- Name reports `<type>-<topic-in-kebab-case>-<YYYY-MM-DD>.md`, with a short type such as `survey`,
  `lineage`, `review`, `summary`, `ideas`, `notes`. Never overwrite an existing report: add `-2`, `-3`.
- An output path given explicitly by the user wins.
- An answer given only in the chat needs no file.
- The final report defaults to `~/.claude/research-report/lineage-<topic>-<YYYY-MM-DD>.md`; do not ask for an
  output path. Its scratch directory is `~/.claude/research-report/.work/paper-graph/<basename>/`.
