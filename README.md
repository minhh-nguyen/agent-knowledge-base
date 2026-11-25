# Personal Knowledge Base

A local-first knowledge base shared by Hermes Agent and OpenCode.

## Purpose

Store and organize long-term technical knowledge, research papers,
project documentation, experiments, and engineering notes.

## Structure

- `inbox/`: Unprocessed notes and documents.
- `papers/`: Academic papers organized by research area.
- `topics/`: Consolidated knowledge about technical subjects.
- `projects/`: Project-specific knowledge and decisions.
- `experiments/`: Benchmark configurations, results, and analysis.
- `references/`: Technical documentation and external references.
- `templates/`: Reusable templates for research and engineering notes.

## Workflows

### Adding a paper
1. Put the original PDF in the appropriate `papers/` subdirectory.
2. Create a Markdown review using `templates/paper-review.md`.
3. Record the paper's title, authors, publication, year, and URL or DOI.
4. Separate the paper's claims from your own interpretation.
5. Link related topics and research questions.

### Adding technical knowledge
1. Identify the appropriate topic.
2. Create or update a Markdown file in `topics/`.
3. Include references and source links.
4. Link related papers, projects, and experiments.

### Recording an experiment
1. Create an entry using `templates/experiment.md`.
2. Record hardware, software versions, workload, and configuration.
3. Preserve raw results separately when appropriate.
4. Document conclusions and limitations.

## Principles

- Markdown is the primary format for written knowledge.
- Keep original documents separate from generated summaries.
- Prefer links between related notes over duplicated content.
- Preserve source provenance.
- Keep temporary information in `inbox/` until reviewed.
