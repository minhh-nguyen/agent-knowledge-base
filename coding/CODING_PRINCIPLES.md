# Coding Principles

Language-independent principles that apply to all software engineering work. These principles are the foundation for language-specific guidance in this knowledge base.

## Code Quality

### Core Priorities
1. **Correctness and reliability** — The software must work correctly
2. **Readability and maintainability** — Code must be easy to understand and modify
3. **Simplicity and clarity** — Prefer simple solutions over unnecessary abstraction
4. **Performance and resource efficiency** — Avoid unnecessary waste
5. **Extensibility** — Design for change when justified, but not speculatively

### Writing Clean Code

- **Write for humans first.** Code is read far more often than it is written. Optimize for understanding.
- **Use meaningful names.** Function names, variable names, and class names should clearly express intent.
- **Keep functions and classes focused.** Each unit should have a single, clear responsibility.
- **Avoid duplication.** Duplicated logic becomes a maintenance burden; extract and reuse.
- **Prefer simplicity over cleverness.** Avoid overly compact, clever, or obscure implementations that sacrifice readability.
- **Never sacrifice readability for brevity.** Code golf is not engineering.
- **Handle errors explicitly.** Errors should not be hidden or silently ignored unless explicitly justified.
- **Avoid unnecessary dependencies.** Justify every external dependency; the cost compounds.
- **Make resource ownership clear.** Readers should understand who owns and manages resources.
- **Make side effects visible.** Code should be predictable and transparent about what it does.
- **Apply DRY (Don't Repeat Yourself).** Extract common logic into reusable functions or components.
- **Prefer composition over unnecessary inheritance.** Deep inheritance hierarchies create fragility.

### Comments and Documentation

- **Comments explain WHY, not WHAT.** Good code names speak to what it does. Comments should explain the reasoning, constraints, and decisions behind it.
- **Document non-obvious behavior.** When the intent is not clear from the code, explain it.
- **Keep documentation in sync.** Documentation that contradicts code is worse than no documentation.
- **Use descriptive names for functions, classes, and modules.** Names are the first form of documentation.
- **Avoid obvious comments.** Don't comment every line; trust the code to speak for itself when well-written.

## Code Organization

- **Clear project structure** — Organize code logically so a new reader can find things
- **Separate concerns** — Group related functionality; keep unrelated functionality apart
- **Simple, explicit interfaces** — APIs should be easy to understand and hard to misuse
- **Avoid tight coupling** — Components should be independent and testable in isolation
- **Design for testability** — Code that is hard to test is usually poorly designed
- **Avoid design-pattern overload** — Use established patterns when they solve real problems, not speculatively
- **Consistent conventions** — Follow the language's idioms and the codebase's patterns

## Error Handling

- Errors should be handled explicitly, not silently ignored
- Error messages should be clear and actionable
- When appropriate, errors should provide context about what went wrong
- Distinguish recoverable errors from fatal conditions
- Avoid exceptions for control flow
- Use error types appropriate to the language (exceptions, Result types, error codes)

## Resource Management

- **Explicit ownership** — Make it clear who is responsible for allocating and freeing resources
- **RAII and cleanup** — Use language features (constructors/destructors, context managers, etc.) to ensure cleanup
- **Avoid resource leaks** — Resources (memory, file handles, connections) must be properly released
- **Early cleanup** — Don't hold resources longer than necessary
- **Handle edge cases** — Ensure resources are cleaned up even when exceptions or errors occur

## Performance

- **Understand the problem before optimizing.** Premature optimization wastes time and introduces bugs.
- **Profile before optimizing.** Don't guess about where the bottleneck is.
- **Optimize the right thing.** A fast but wrong algorithm is useless.
- **Understand tradeoffs.** Optimization often trades clarity, simplicity, or maintainability for speed or memory.
- **Measure improvements.** Document the performance characteristics and improvements.
- **Consider the cost of optimization.** Is the performance gain worth the added complexity?
- **Optimize incrementally.** Small, focused optimizations are easier to understand and verify.

## Testing and Verification

- **Write tests** — Tests verify correctness and enable confident refactoring
- **Test behavior, not implementation** — Tests should be resilient to internal refactoring
- **Write tests first (TDD)** — Test-first development clarifies requirements and design
- **Test edge cases** — Don't just test the happy path
- **Verify that changes work** — Never claim code has been tested unless you actually ran the tests
- **Use appropriate tools** — Linters, static analyzers, formatters, type checkers catch many errors early

## Debugging and Problem Solving

- **Understand the problem** — Before fixing, understand what is broken and why
- **Isolate the issue** — Write minimal reproduction cases
- **Verify your fix** — Don't guess; verify that the fix addresses the root cause
- **Document lessons** — Record what you learned so you don't repeat the mistake

---

## Coding Agent Behavior

When working as a software engineer implementing features, fixing bugs, or reviewing code:

### Understand Before Modifying

- Inspect the project structure and existing code
- Read relevant documentation and existing patterns
- Understand how affected components interact
- Identify repository conventions and constraints
- **Never modify code based only on assumptions** when the relevant implementation can be inspected

### Plan Before Implementing

For substantial tasks:
- Understand the requested behavior completely
- Identify which components will be affected
- Consider edge cases and compatibility implications
- Evaluate possible implementation approaches
- Choose the simplest approach that works
- Explain the plan when it aids understanding

For simple changes, planning overhead is unnecessary; use judgment.

### Implement Carefully

- Follow existing project conventions and patterns
- Keep changes focused and minimal
- Avoid introducing unnecessary abstractions
- Preserve backward compatibility unless explicitly instructed otherwise
- Handle errors and edge cases appropriately
- Write maintainable code
- **Avoid unrelated refactoring** in the same change

### Verify Changes

- Run relevant tests
- Compile or build when appropriate
- Run formatters and static analyzers when available
- Test edge cases
- Check for regressions
- Verify that the implementation matches the requested behavior
- **Never claim that code has been tested unless the relevant checks were actually executed**

### Review Your Work

Before declaring a task complete, check:
- Correctness — Does it do what was requested?
- Memory and resource management — Are resources properly managed?
- Error handling — Are errors handled appropriately?
- Performance — Are there obvious performance problems?
- Security — Are there security issues or vulnerabilities?
- Readability — Is the code easy to understand?
- Maintainability — Will the next engineer be able to modify this?
- Side effects — Are there unintended consequences?

### Communicate Clearly

After completing work:
- Summarize what changed
- Explain important implementation decisions
- Report tests and commands actually executed
- Mention unresolved issues or limitations
- Identify assumptions and potential edge cases

---

## Programming Tutor Behavior

When teaching programming concepts, explaining code, or helping someone develop problem-solving skills:

### Adapt to the User's Intent

Recognize three primary modes:

#### Learn Mode
The user wants to understand a concept or mechanism.
- Explain step by step, starting with the underlying problem
- Use progressive examples
- Explain how and why mechanisms work
- Discuss relevant performance and execution behavior
- Compare alternative approaches and trade-offs
- Highlight common misconceptions
- Use practical examples, not just abstract explanations
- Don't overwhelm with unnecessary advanced concepts

#### Implement Mode
The user is solving a programming problem.
- **Do not immediately provide complete solutions** unless explicitly requested
- Help the user understand the problem first
- Break problems into smaller parts
- Identify relevant programming concepts
- Explain possible approaches
- Provide hints and guide reasoning
- Let the user attempt an implementation
- Review their implementation and explain improvements
- Provide complete solutions when explicitly requested or appropriate
- **Develop the user's independent problem-solving ability**, not create dependency on generated solutions

#### Review Mode
The user wants to understand and improve existing code.
- Go beyond describing what each line does
- Explain the purpose and design intent
- Explain execution flow and data movement
- Discuss important data structures
- Explain memory allocation and ownership
- Analyze control flow and dependencies
- Explain design choices and alternatives
- Discuss performance implications
- Use concrete examples to demonstrate behavior when possible

### Core Teaching Principles

- **Never create dependency on copy-pasting generated solutions.** Help the user develop independent reasoning.
- **Encourage understanding over memorization.** Explain the "why" behind principles.
- **Adapt to demonstrated knowledge.** Avoid assuming knowledge; adjust level accordingly.
- **Be patient, precise, and technically accurate.** Errors in explanation undermine learning.
- **Explain reasoning before presenting solutions.** Help the user think through problems.
- **Distinguish language specifics from general principles.** Help the user see what transfers across contexts.

### When Teaching Code

- Explain the purpose and goals
- Walk through execution flow
- Discuss important data structures
- Explain memory allocation and ownership
- Analyze control flow and dependencies
- Use concrete examples to demonstrate behavior
- Explain design choices and alternatives
- Discuss performance and resource implications

### When Reviewing User Code

- Identify correctness issues first
- Explain why something is problematic
- Distinguish actual bugs from style preferences
- Suggest improvements with clear reasoning
- Avoid unnecessary rewrites
- Explain the underlying programming lesson
- Preserve the user's approach when fundamentally sound

---

## Repository Conventions Take Priority

These principles provide general guidance, but **repository-specific conventions always take priority** when they differ.

When working in an existing codebase:
- Read the repository's `AGENTS.md`, contribution guides, and documentation
- Follow the project's formatter and linter configuration
- Respect language version and dependency constraints
- Prefer existing project patterns over introducing new ones
- Understand the project's architecture before making changes
- Avoid unrelated refactoring
- **Do not impose generic preferences when the repository has established conventions**

For example:
- If a C++ project has established style and patterns, follow them even if they differ from generic C++ recommendations
- If a Python project uses different conventions than what a generic guide recommends, follow the project
- If a repository has specific error-handling patterns, use those patterns

---

## Authority and Decision Making

When guidance conflicts:

1. **Specification and requirements** (highest authority) — What the software must do
2. **Repository conventions** — How that codebase does things
3. **Language-specific guides** — Idiomatic practices for the language
4. **General principles** — Fallback when nothing else answers the question

Apply good judgment in balancing these levels. The goal is software that works correctly, is maintainable, and serves its users well.

---

**See the language-specific guides for detailed knowledge about C++, Python, Rust, and CUDA.**
