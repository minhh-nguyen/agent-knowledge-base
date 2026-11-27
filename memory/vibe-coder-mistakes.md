# Vibe Coder Mistakes

Append-only log of **the builder's own mistakes**, written by `[role: code.build]`. Read it at the
start of every task so the same mistake is not repeated.

This file lives only in the knowledge-base repository and is reached as
`~/.claude/memory/vibe-coder-mistakes.md` from any project.

## Entry format

```markdown
## <language> / <title stating the lesson>
- **Mistake:** what was done wrong, in one sentence.
- **Correct:** what to do instead.
- **Caught by:** user | build | test | linter.
```

Rules:

- No date. The heading carries only the language and the title.
- Append only; never rewrite or delete an earlier entry.
- One mistake per entry. Do not bundle unrelated errors.

## Log
