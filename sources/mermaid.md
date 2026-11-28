# Mermaid

- Docs: <https://mermaid.js.org/syntax/mindmap.html>
- CDN bundle: <https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js>
- Checked: 2026-11-28, Mermaid 11 (`mindmap`, `root["..."]` labels, `mermaid.run({ querySelector })`).

Used by `skills/lecture-slides/scripts/render.py` to render the lesson mind map. The generated source
is a three-level `mindmap`: root = lesson title, branches = keyword sections, leaves = keywords.
