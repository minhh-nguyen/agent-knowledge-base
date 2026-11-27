---
name: paper-navigator
description: "[role: research.find] Find and read academic papers from Semantic Scholar and arXiv, with relevance ranking and layered summaries. Mode: do. Use for paper search, literature discovery, and citation analysis. Do NOT use for surveys ([role: research.survey]), ideas ([role: research.ideate]), or Related Work sections."
allowed-tools: "write_file edit_file read_file think_tool execute"
metadata:
  author: "EvoScientist - edited: Minh"
  version: '3.4.2'
  tags: [core, research, literature, papers, search, rubric]
---

# Paper Navigator

Find and read academic papers. Route by **intent**, judge by **relevance**.

```
        User
         │
         ▼
   ┌── Router ──┐
   │            │
   ▼            ▼
 POINT      LIST/ITERATIVE
(1 paper)   (Probe + up to 3 paper rounds:
             R2 breadth / R3 deepen / R4 close)
```

The agent does relevance judgment — no LLM-as-judge is called, no numeric scoring. You author the rubric, you triage each paper, you rank by relevance.

## Setup

Script paths in this document are relative to this skill's directory. Resolve `scripts/<name>.py` against that directory, but keep the execution working directory at the task workspace; do not `cd` into the installed skill directory.

**Dependencies**: `pip install deepxiv-sdk httpx` (also listed in `requirements.txt` at the skill root). Install into the environment the user is working in.

arXiv access (`arxiv_monitor`, `scholar_search` fallback) uses the DeepXiv SDK: `pip install deepxiv-sdk`, then `deepxiv token` once to provision a **free** API token (saved to `~/.env`). The skill reads the token from `DEEPXIV_API_TOKEN`/`DEEPXIV_TOKEN` in the environment, or from `./.env` / `~/.env`.

| Env var                | Used by                                    | Notes                                                                                                                             |
| ---------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `S2_API_KEY`           | All S2 scripts                             | Without it: `scholar_search` falls back to arXiv (via DeepXiv); `citation_traverse` / `recommend` / `snippet_search` are disabled |
| `DEEPXIV_API_TOKEN`    | `arxiv_monitor`, `scholar_search` fallback | Get a free token: `deepxiv token` (writes `~/.env`). Also read from `DEEPXIV_TOKEN` and `./.env`/`~/.env`. ~10,000 req/day        |
| `JINA_API_KEY`         | `fetch_paper`                              | Free tier works without key                                                                                                       |
| `GITHUB_TOKEN`         | `github_search`, `find_code`               | Higher rate limits                                                                                                                |
| `PAPER_NAV_PAPERS_DIR` | `fetch_paper` full text                    | No default — set or pass `--metadata-only`                                                                                        |

Full env-var list: `references/env-vars.md`.

---

## Five Red Lines (always)

1. **Track history.** Don't re-run a query you already ran. Empty result → change angle, not synonyms.
2. **Search a gap, not a vibe.** Every query maps to one missing piece of information. No stacked-keyword bags.
3. **One query = one concept.** Split comparisons (`A vs B`), multi-property asks, and multi-year spans into separate calls.
4. **Never hallucinate.** Every fact (title, author, year, citation count, content) comes from a tool result.
5. **Quote-or-zero.** When you claim a paper meets a criterion, quote a ≤80-char span from its abstract / tldr / snippet. No quote → do not claim the paper meets that criterion. (This guards against hallucination; it does not drive a numeric score.)

---

## Router

| Branch             | User signal                                                                                         | Cadence                           | Output                                                            |
| ------------------ | --------------------------------------------------------------------------------------------------- | --------------------------------- | ----------------------------------------------------------------- |
| **POINT**          | Title quoted, URL, arXiv/DOI/PMID/S2 ID, "read this paper"                                          | 1 call                            | Paper Card                                                        |
| **LIST** (default) | "find papers about X", "is there a paper that …?", "papers satisfying A and B"                      | Probe + up to 3 rounds (R2/R3/R4) | Shortlist with per-criterion evidence                             |
| **ITERATIVE**      | "survey of X", "30+ papers on Y", called from `[role: research.survey]` / `[role: research.ideate]` | Probe + up to 3 rounds (R2/R3/R4) | Ranked table (hand off to [role: research.survey] for the report) |

**Default to LIST when unsure.** Don't add `survey` / `review` to LIST queries — it down-ranks the canonical research papers the user wants.

**Output format follows the caller:** the Output column above is the structured form (skill callers). Direct user calls default to **Narrative** — see Step 6 "Output mode" in `references/list-workflow.md`.

Ambiguous query (project nickname, codename, single capitalized word with zero hits) → run `scholar_search` exact + web/GitHub search first to resolve identifiers, then re-route.

---

## POINT branch (known paper)

| Input                                 | Command                                                                                        | Output                                                                         |
| ------------------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| URL                                   | `python scripts/fetch_paper.py --url <URL>`                                                    | Paper Card + reading notes (see `references/reading-strategy.md` for L1/L2/L3) |
| Title quoted                          | `python scripts/match_paper_by_title.py --title "<title>"` (add `--fallback-search` for typos) | Paper Card                                                                     |
| Bare ID (arXiv / DOI / S2 / CorpusId) | `python scripts/fetch_paper.py --paper-id <ID> --metadata-only`                                | Paper Card                                                                     |

**Paper Card:**

```
📄 **<Title>**
Authors: <First Author> et al. | Year: <Y> | Venue: <V>
Citations: <N> | ID: <ArXiv:xxxx.xxxxx> | DOI: <...>
TLDR: <one sentence>
```

Stop here. Do not chain to citation expansion unless asked.

---

## LIST / ITERATIVE branch — 6 steps

**Load [`references/list-workflow.md`](references/list-workflow.md) before Step 2** — it holds the
full procedure, query rules, triage format, gate conditions, output templates, the tool cheat
sheet, and rate limits. In short:

1. **Parse intent:** research object + constraints in one sentence; confirm the branch. A bare noun
   means "trace the lineage".
2. **Author the RUBRIC** (2–4 atomic criteria marked `[core]`/`[secondary]`, named entities, angle
   tags, recency signal, disqualifiers) before any search.
3. **Search:** Probe (2 queries), then up to 3 rounds R2 breadth / R3 deepen / R4 close, every call
   appending to `~/.claude/research-report/.work/paper-navigator/<run-id>/pool.jsonl`.
4. **Triage** each new paper into All-core / Partial / Irrelevant with a per-criterion mask and
   ≤80-char quotes.
5. **Saturation gate** after Probe and each round: STOP only when the gap conditions hold.
6. **Rank and output** by relevance, K soft cap, Rank-1 bar; narrative for users, structured for
   skill callers; run the pre-output checklist.

Without `S2_API_KEY`: use `scholar_search` (arXiv fallback) and `arxiv_monitor` only; skip
`citation_traverse`, `recommend`, `snippet_search`.

## References

| File                                 | Read when                                                                                   |
| ------------------------------------ | ------------------------------------------------------------------------------------------- |
| `references/list-workflow.md`        | **Always** for LIST / ITERATIVE: steps 1–6, tool cheat sheet, rate limits                   |
| `references/env-vars.md`             | Setting environment variables                                                               |
| `references/search-principles.md`    | Per-query rules, gap diagnosis, rate-limit recovery                                         |
| `references/iterative-collection.md` | ITERATIVE corpus collection (30+ papers): phase mapping, citation expansion, escape hatches |
| `references/disambiguation.md`       | Query is a project nickname / codename                                                      |
| `references/reading-strategy.md`     | L1 / L2 / L3 reading framework                                                              |
| `references/api-reference.md`        | S2 / arXiv / Jina / HF / GitHub endpoint details                                            |
| `references/arxiv-categories.md`     | arXiv category codes                                                                        |
| `references/output-formats.md`       | Baseline / Disambiguation / Reading-Notes / Citation-Graph templates                        |

References are self-contained. Don't chain between them — return here to re-route.

---

## Hand off to

| Goal                  | Skill                     |
| --------------------- | ------------------------- |
| Survey report         | `[role: research.survey]` |
| Idea generation       | `[role: research.ideate]` |
| Related Work section  | none installed: tell the user |
| Baseline + experiment | none installed: tell the user |

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
- Scratch data such as `~/.claude/research-report/.work/paper-navigator/<run-id>/pool.jsonl` is working state, not a report, and
  stays where the workflow puts it. Reading notes and paper cards saved to a file go to `~/.claude/research-report/`.
