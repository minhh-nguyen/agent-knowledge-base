# Python Programming Guide

**Location:** `python/python-guide.md`

**Target:** Modern Python (3.10+)

**Key Requirement:** All code must include complete type annotations.

## When to Consult This Guide

Use this guide when:
- **Writing Python code:** functions, classes, modules with proper typing
- **Adding type annotations:** understanding `TypedDict`, `Protocol`, generics
- **Debugging:** understanding Python's object model, mutability, exceptions
- **Reviewing Python code:** assessing type safety, error handling, design
- **Setting up static type checking:** configuring mypy or pyright
- **Learning:** teaching Python concepts and idiomatic practices

## Key Principles

### Type Annotations (Mandatory)

**All recommended Python code must include complete type annotations:**

```python
# GOOD: complete types
def calculate_average(scores: list[float]) -> float:
    return sum(scores) / len(scores)

# GOOD: optional parameter with type
def greet(name: str, greeting: str = "Hello") -> str:
    return f"{greeting}, {name}!"
```

**Use modern syntax (Python 3.10+):**

```python
# GOOD: pipe operator for unions
def parse_value(value: str | int) -> float:
    return float(value)

# GOOD: built-in generics
def process(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}
```

### Avoid Untyped Code

**Never present untyped functions as recommended Python.**

Untyped code hides bugs and makes refactoring dangerous. Type annotations:
- Document function contracts
- Enable IDE tooling and autocomplete
- Allow static type checkers to catch errors
- Make refactoring safer and more confident

## Quick Reference

| Topic | Use Case |
|-------|----------|
| [Type Annotations](#type-annotations-and-typing) | Adding correct type hints |
| [Built-in Types](#built-in-types-and-data-structures) | Using str, list, dict, set, tuple |
| [Functions and Signatures](#functions-and-signatures) | Defining typed functions |
| [Classes](#classes-and-object-oriented-design) | Writing object-oriented code |
| [Error Handling](#error-handling) | Using exceptions and context managers |
| [Iterators and Generators](#iterators-generators-and-comprehensions) | Efficient iteration |
| [Decorators](#decorators-and-context-managers) | Extending function behavior |
| [Concurrency](#concurrency-and-async-programming) | Threading and async/await |
| [Testing](#testing-and-debugging) | pytest and unit tests |

## Standards and Versions

- **Minimum supported:** Python 3.10
- **Recommended:** Python 3.11+ (better performance, more features)
- **Type checkers:** mypy or pyright (use `--strict` mode)
- **Formatter:** black (88-character lines)
- **Linter:** pylint, flake8, or ruff

## Mandatory Rules

1. **Function signatures must have type annotations** for parameters and return values
2. **Use modern built-in generics:** `list[str]`, not `List[str]`
3. **Handle None explicitly:** Use `str | None`, not ambiguous nullable types
4. **Avoid `Any` without justification** — Type precisely
5. **Use `TypedDict` or dataclasses** for structured data, not loose dicts
6. **Configure static type checking** in your project (mypy/pyright)

## Common Anti-Patterns to Avoid

1. **Mutable default arguments** — Use `None` as default
2. **Catching too broad exceptions** — Catch specific exception types
3. **Loose dictionaries** — Use `TypedDict` for structured data
4. **Untyped functions** — Add type annotations always
5. **Implicit conversions** — Be explicit about type transformations

## Related Documents

- See [`../CODING_PRINCIPLES.md`](../CODING_PRINCIPLES.md) for language-independent principles
- See [`../README.md`](../README.md) for navigation and when to consult each guide

## References

- [Python Documentation](https://docs.python.org/3/) — Official Python docs
- [PEP 484](https://www.python.org/dev/peps/pep-0484/) — Type hints specification
- [mypy Documentation](https://mypy.readthedocs.io/) — Static type checker
- [pyright Documentation](https://github.com/microsoft/pyright) — Fast type checker

---

**Start with:** Understand type annotations. Properly typed Python catches bugs before runtime and enables powerful refactoring.
