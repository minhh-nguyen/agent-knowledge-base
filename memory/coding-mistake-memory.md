# Coding Mistake Memory

Append-only log of **the tutor's own mistakes**, written by `[role: code.tutor]`. It never records
the user's errors. Read it at the start of every session so the same mistake is not repeated.

This file lives only in the knowledge-base repository and is reached as
`~/.claude/memory/coding-mistake-memory.md` from any project.

## Entry format

```markdown
## <language> · <title stating the lesson>
- **Mistake:** what the tutor got wrong, in one sentence.
- **Correct:** the right explanation or rule.
- **Caught by:** user | compiler | test | documentation.
- **Revisit:** what to do differently next time.
```

Rules:

- No date. The heading carries only the language and the title.
- Append only; never rewrite or delete an earlier entry.
- One mistake per entry. Do not bundle unrelated errors.
- Record the rule, not the full solution or the graded code.

## Log

## C++ / unexplained term "vòng phần dư"
- **Type:** tutor
- **Mistake:** Used the phrase "vòng phần dư" (remainder loop) without defining it for a SIMD beginner.
- **Correct:** Define it first: a second, ordinary one-element-at-a-time `for` loop after the SIMD loop that handles the last `n % W` elements. Some technical words are too abstract in vietnamese, they should be kept in English, specially for beginner.
- **Caught by:** student
- **Revisit:** Define every new term in plain words with a small example before using it.
