# Evolution Report — Cycle 3 (IDE)

- **Date**: 2026-11-27
- **Trigger**: research-ideation tournament on few-shot prompting and RAG for semantic operators (TU Darmstadt AIDM Part 2, SemBench).
- **Source**: `~/.claude/research-report/direction-summary-fewshot-rag-semantic-operators-2026-11-27.md`

## Added (feasible)

1. Strong-model-labeled, cache-friendly demonstrations for semantic operators (Elo 1531).
2. Retrieve-then-select semantic joins (Elo 1500).
3. Prompting strategy as a physical-operator choice in a cost-accuracy optimizer (Elo 1469).

## Added (unsuccessful)

1. External-knowledge RAG for self-contained semantic query benchmarks: fundamental (task fit).
2. Benchmark ground truth as few-shot demonstrations: fundamental (label leakage).
3. Per-row kNN-retrieved demonstrations as main contribution: implementation-level prune (breaks prompt caching; well studied).

## Why

Few-shot helps quality but costs input tokens (SemBench); retrieval is only useful inside the database (candidates, demos), not for outside knowledge. Labels must come from a strong model, never from the benchmark answers. (Palimpzest)

## Expected impact

Future cycles on LLM query processing should start from "where do labels come from, and how is the demo cost cached", and skip external-knowledge RAG. No earlier directions (storage / io_uring) were affected.

## Caveat

Literature search ran without a Semantic Scholar API key; only 4 of 12 queries succeeded (49 papers). Multimodal few-shot and batch-prompting literature is under-covered; re-search once a key is available.
