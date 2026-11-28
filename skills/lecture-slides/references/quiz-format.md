# Quiz and Question-Bank Format

Every lesson ends with four banks, in this order. Counts are per lesson, not per section.

| Bank                   | Count | Answer visibility                     |
| ---------------------- | ----- | ------------------------------------- |
| True / False           | 8–10  | revealed on click, with explanation   |
| What is …?             | 8     | hidden in `<details>`                 |
| Calculations           | 5     | worked solution hidden in `<details>` |
| Written exam questions | 4     | withheld; graded in chat              |

Mid-lesson MCQs are separate: 2 per keyword section, about 9–10 per lesson.

## Shared rules

- Every question must be answerable from the deck; cite the page in the explanation.
- One concept per question. No compound True/False statements.
- Three options for MCQs, similar length, one unambiguously correct. Vary the position of the
  correct option across the lesson; never make it always `data-answer="1"`.
- Distractors must be plausible mistakes (a swapped term, a unit error, a reversed trade-off),
  not nonsense.
- The question text must not hint at the answer. The explanation must say why the wrong options
  are wrong when that is not obvious.
- Use `<code>` for identifiers and formulas, `<em>` for emphasis, `<span class="cite">Deck p.N</span>`
  for the source.
- No external scripts. `../assets/quiz.js` drives every `.quiz` block.

## Mid-lesson MCQ

Markup: `.quiz` with `data-answer` = 0-based index of the correct option.

```html
<div class="quiz" data-answer="2">
  <p class="q">
    An application logically writes 1 GB; the SSD physically writes 3 GB. What
    happened?
  </p>
  <button class="opt">
    The OS buffer cache wrote each page three separate times.
  </button>
  <button class="opt">
    NVMe split each write into three queue-pair submissions.
  </button>
  <button class="opt">
    Garbage collection relocated live data so blocks could be erased.
  </button>
  <p class="why">
    Write amplification = 3 GB ÷ 1 GB = 3. The extra writes came from GC copying
    still-valid pages before an erase <span class="cite">Deck p.23</span>.
  </p>
</div>
```

Place each pair immediately after the keyword group it tests, before the next `h2`.

## True / False

Wrap the bank in `.qbank`. Each item is `.item quiz` so `quiz.js` handles the reveal.

```html
<div class="qbank">
  <div class="item quiz" data-answer="1">
    <p class="q">
      <span class="qtype tf">T / F</span>AHCI/SATA supports thousands of queues,
      just like NVMe.
    </p>
    <button class="opt">True</button><button class="opt">False</button>
    <p class="why">
      False. AHCI has 1 queue of 32 commands; NVMe has 64 K queues of 64 K
      commands each <span class="cite">Deck pp.27, 29</span>.
    </p>
  </div>
</div>
```

- `data-answer="0"` = True, `data-answer="1"` = False.
- Mix true and false; do not let one dominate.
- Target the distinctions the deck stresses, not trivia.

## What is …?

Open questions answered aloud before revealing. No options.

```html
<div class="qbank">
  <div class="item">
    <p><span class="qtype">What is</span>the superblock?</p>
    <details>
      <summary>Show answer</summary>
      <p>
        Metadata about the file-system instance: bitmap size, number of inodes
        and file blocks, offsets of the components, file-system type
        <span class="cite">Deck p.51</span>.
      </p>
    </details>
  </div>
</div>
```

- One to three sentences per answer.
- Cover every keyword that has no True/False item, so the whole lesson is retrievable.
- Ask for the mechanism ("what does it do?"), not just the expansion of an acronym.

## Calculations

```html
<div class="qbank">
  <div class="item">
    <p>
      <span class="qtype calc">Compute</span>An HDD has 6 ms seek, 4 ms rotation
      and 0.1 ms transfer per 4 KB block. How long do 50 random reads take, and
      50 sequential reads? What is the speedup?
    </p>
    <details>
      <summary>Show solution</summary>
      <p>
        Random: 50 × (10 + 0.1) = <strong>505 ms</strong>. Sequential: 10 + 50 ×
        0.1 = <strong>15 ms</strong>. Speedup ≈ <strong>34×</strong>
        <span class="cite">Deck p.21</span>.
      </p>
    </details>
  </div>
</div>
```

- Use only formulas the lesson taught; state the formula, the substitution, the unit, the result.
- Five items: at least one unit conversion, one ratio or speedup, one bottleneck comparison.
- Round sensibly and keep the precision the deck uses.

## Written exam questions

```html
<ol class="examq">
  <li>
    <strong>Explain why.</strong> Why can an NVMe SSD at queue depth 1 deliver
    only a fraction of its rated bandwidth?
  </li>
  <li>
    <strong>Compare.</strong> FTL-managed SSD vs ZNS SSD: who does garbage
    collection, and what happens to write amplification and to latency?
  </li>
</ol>
```

- Exactly four: one explain, one compare, one argue or design, one transfer to a new situation.
- Verb first (`Explain`, `Compare`, `Argue`, `Design`), then the question.
- No answer in the file. End the section with: "Bring your answers to the chat and I'll grade them
  the way an examiner would."

## Coverage check

Before finishing, confirm:

- every keyword appears in at least one MCQ, True/False item, or What-is question;
- every formula used in the Calculations bank was derived or shown in the lesson;
- the four written questions together cover the whole deck, not one section;
- no answer appears in the question text and no option is a joke.
