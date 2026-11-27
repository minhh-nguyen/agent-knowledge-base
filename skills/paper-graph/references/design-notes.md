# Design Notes

For editors of this skill, not the runtime agent.

- **No outbound LLM dependency**: the skill exposes data fetchers, prompt templates (`references/*.md`), parsers, and renderers. The host agent is the LLM provider. This is why there's no `OPENROUTER_API_KEY` requirement and no `llm.py`.
- **The audit gate is code, not prose**: `scripts/audit.py` re-checks every verdict record (label, quotes found in the paper's own text, chronology, self-edges, duplicates, cycles). `render_detail_mermaid` cannot run without `--verdicts`, stamps its output `"audited": true`, and `assemble_report` refuses a render without the stamp. `mermaid.py` takes its set of edge-drawing labels from `audit.SUPPORTED_VERDICTS`.
- **Single source of truth for the detail parser**: `mermaid._parse_detail_markdown` is called by both `detail_to_mermaid` (rendering) and the `parse_detail` CLI subcommand. Any change to scratchpad stripping, paper/EP/OC extraction, or hallucination dropping propagates to both.
- **`references/seed_paper_block.md` is an internal template fragment** consumed by `format_seed_block`; the runtime agent never substitutes its placeholders directly. The prompt templates the runbook references are `parse_query.md`, `classify.md`, `outline.md`, `detail.md`, and `audit_edge.md`; `workdir-layout.md` and this file are documentation, not templates.
- **Themed Mermaid**: `mermaid.py` defines `LIGHT_THEME` and `DARK_THEME`. The renderer subcommands resolve the theme by name (CLI arg) → `MERMAID_THEME` env → `"light"`. Each render emits a self-contained Mermaid graph (init directive + classDefs + linkStyle).
- **JSONL logging is default-on**: every subcommand writes `<out>.log.jsonl` next to its output unless `--log none` is passed. These logs are for the human developer iterating on the skill — the runtime agent should not read them back.
- **`papers.json` is checked once per subcommand**: every step that reads it exits with code 2 and the offending entry numbers when the file is not an array of paper objects, instead of failing later on a missing field.
- **Failure mode preference**: loud over silent. Missing keys, malformed LLM output, zero papers from search — all abort with a printed reason rather than producing a degraded artifact.
- **English-only**: the upstream `paper-graph` prompts emitted bilingual labels; this skill strips Chinese and keeps English only.
