# Coding Mistake Memory

Append-only log written by `[role: code.tutor]`. One entry per mistake that was corrected, so a
later session can probe the same gap instead of rediscovering it.

Read this file at the start of any session that touches the same language, then pick the first
probe from the "Revisit" lines.

## Entry format

```markdown
## YYYY-MM-DD · <language> · <short title>

- **Type:** student | tutor
- **Mistake:** what was wrong, in one sentence.
- **Correct:** the correct rule, idiom, or mechanism.
- **Caught by:** the question, test, or compiler output that exposed it.
- **Revisit:** the question to ask next time this topic comes up.
```

Rules:

- Append only; never rewrite or delete an earlier entry.
- One mistake per entry. Do not bundle unrelated errors.
- Record the rule, not the full solution or the graded code.
- Skip typos and one-off syntax slips the compiler already explains.

## Log
