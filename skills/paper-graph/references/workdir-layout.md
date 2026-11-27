# Scratch Directory Layout

One directory per run at `~/.claude/research-report/.work/paper-graph/<basename>/`. Each runbook
step in `SKILL.md` names the files it reads and writes; this is the full map.

```
~/.claude/research-report/.work/paper-graph/<basename>/
├── query.txt                user query (verbatim)
├── seed.json                resolve_seed_papers
├── seed_block.txt           format_seed_block
├── parsed_query.json        LLM: parse_query output
├── goal_block.txt           build_goal_block (reused in steps 8, 10, 11)
├── papers.json              fetch_papers → prefetch_sections → classify-merged
├── papers_input.txt         format_papers (full set)
├── classify_raw.json        LLM: classify output (consumed by merge_classifications)
├── core_filter.json         compute_core_filter (+ core_filter.json.allowed.txt)
├── papers_input_core.txt    format_papers (CORE-only; + papers_input_core.txt.allowed.txt)
├── outline_raw.md           LLM: outline output
├── outline.json             parse_outline summary
├── outline_mermaid.json     render_outline_mermaid
├── solutions/<key>.json     per-solution context (one file per solution)
├── parsed/<key>.json        parse_detail output (used by step 11 audit)
├── details/
│   ├── <key>_input.txt      format_papers (optional: same content as papers_input_core.txt; + .allowed.txt sibling)
│   ├── <key>_raw.md         LLM: detail output
│   └── <key>.json           render_detail_mermaid (consumed by assemble)
├── verdicts/<key>.json      [{source_n, target_n, verdict, source_quote, target_quote, reason}] from audit ([] when no edges)
└── <run>.log.jsonl files    one next to each subcommand output, default-on
```

Filenames are agent-chosen — these are recommendations to match what the runbook below references. `<key>` is the solution key string `<s_major>.<s_minor>` (e.g. `1.1`). Every `format_papers` call writes a sibling `<out>.allowed.txt` containing the `(N), (N), ...` form ready to drop into a `{allowed_numbers}` placeholder.
