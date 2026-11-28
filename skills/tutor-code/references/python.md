# Python Guide

Modern Python (3.10+) for safe, maintainable, typed code. **All recommended code carries complete type
annotations.** Toolchain: mypy or pyright in strict mode, ruff/black, pytest.

Consult for: writing typed Python, designing interfaces, error handling, debugging, review, teaching.

## Contents

- [Fundamentals and Style](#fundamentals-and-style)
- [Type Annotations](#type-annotations)
- [Built-in Types](#built-in-types)
- [Functions and Signatures](#functions-and-signatures)
- [Classes](#classes)
- [Error Handling](#error-handling)
- [Comprehensions and Generators](#comprehensions-and-generators)
- [Decorators and Context Managers](#decorators-and-context-managers)
- [Concurrency](#concurrency)
- [Performance](#performance)
- [Testing](#testing)
- [Anti-Patterns](#anti-patterns)
- [Project Setup and Type Checking](#project-setup-and-type-checking)

## Fundamentals and Style

- Python 3.10+ syntax: `X | Y` unions, built-in generics (`list[str]`, `dict[str, int]`), `match`/`case`,
  positional-only (`/`) and keyword-only (`*`) parameters, `dataclass(slots=True)`.
- PEP 8: 4 spaces, 88 columns (black), two blank lines between top-level definitions, one between methods.
- Names state intent: `calculate_total_cost`, not `f`.
- Prefer plain functions and dataclasses; add classes only when behavior and state belong together.

## Type Annotations

Annotate every parameter and return value, and non-obvious locals. Types are the executable contract that
mypy/pyright, IDEs, and refactoring tools rely on.

```python
def add_user(name: str, age: int, email: str) -> None:
    users.append({"name": name, "age": age, "email": email})

user_ids: list[int] = []
age_by_name: dict[str, int] = {}
```

Core typing tools:

```python
from typing import Protocol, TypeVar, TypedDict

class UserDict(TypedDict):          # structured dict instead of dict[str, object]
    name: str
    age: int

class Drawable(Protocol):           # structural typing without inheritance
    def draw(self) -> None: ...

T = TypeVar("T")                    # generic function; or PEP 695: def first[T](items: list[T]) -> T
def first(items: list[T]) -> T:
    if not items:
        raise ValueError("empty sequence")
    return items[0]

def find_user(user_id: int) -> User | None:   # absence is explicit
    ...
```

Guidelines: `X | None` instead of `Optional[X]`; `TypedDict` or a dataclass instead of loose dicts;
`Protocol` for duck-typed interfaces; `Callable[[int], None]` for function types; avoid `Any` — if it is
unavoidable, confine it to a boundary and comment why.

## Built-in Types

- `int` is arbitrary precision; `float` is 64-bit IEEE-754 (money belongs in `Decimal` or integer cents).
- `str` is immutable Unicode; build long strings with `"".join(...)`.
- `list` mutable/ordered, `tuple` immutable/hashable, `set` unique/unordered, `dict` insertion-ordered map.
- Annotate element types: `list[str]`, `dict[str, int]`, `tuple[int, int]`. Bare `list`/`dict` hides bugs.

```python
coordinates: tuple[int, int] = (10, 20)
x, y = coordinates
unique_ids: set[int] = {1, 2, 2}          # {1, 2}
```

## Functions and Signatures

```python
from typing import Callable

def calculate_average(scores: list[float]) -> float:
    if not scores:
        raise ValueError("cannot average an empty list")
    return sum(scores) / len(scores)

def create_connection(host: str, port: int = 5432, *, timeout: float = 30.0) -> Connection:
    ...

UserId = int                                  # alias only when it adds meaning
Handler = Callable[[Request], Response]
```

- Defaults must be immutable; use `None` as the sentinel for "not provided".
- Keyword-only (`*`) for booleans and option-heavy APIs: prevents `f(True, False)` mistakes.
- Return early; keep one obvious exit path per branch; raise instead of returning error sentinels.

## Classes

```python
from dataclasses import dataclass

@dataclass(slots=True)
class User:
    name: str
    email: str
    age: int
    is_active: bool = True

    @property
    def is_adult(self) -> bool:
        return self.age >= 18

class MemoryStore(DataStore):                 # ABC for explicit interface contracts
    def __init__(self) -> None:
        self._data: dict[str, str] = {}

    def get(self, key: str) -> str | None:
        return self._data.get(key)
```

- Annotate attributes at class level so checkers see them.
- `@dataclass` removes `__init__` boilerplate; use `frozen=True` for value objects.
- Private state with a leading underscore; expose behavior, not raw fields.
- Inheritance for genuine substitutability; composition otherwise. `ABC` + `@abstractmethod` for contracts.

## Error Handling

- Raise specific exceptions with context; chain with `raise ... from e` to keep the cause.
- Catch only what you can handle; never `except Exception: pass`.
- Custom exceptions derive from a module-level base so callers can catch a family.
- Use `with` for anything needing cleanup; resources close even on exceptions.

```python
from types import TracebackType

class DatabaseError(Exception):
    """Base class for database failures."""

class QueryError(DatabaseError):
    """Raised when a query fails."""

def parse_port(raw: str) -> int:
    try:
        port = int(raw)
    except ValueError as exc:
        raise ValueError(f"invalid port: {raw!r}") from exc
    if not 1 <= port <= 65535:
        raise ValueError(f"port out of range: {port}")
    return port

with open("data.txt") as f:
    process(f.read())

class Connection:
    def __enter__(self) -> "Connection":
        self._socket = connect()
        return self
    def __exit__(self, exc_type: type[BaseException] | None,
                 exc: BaseException | None, tb: TracebackType | None) -> None:
        self._socket.close()          # returning None re-raises any exception
```

## Comprehensions and Generators

```python
squares = [x * x for x in range(10)]
by_id = {u.id: u.name for u in users}
evens = [x for x in range(20) if x % 2 == 0]
flattened = [x for row in matrix for x in row]     # keep nesting shallow

def fibonacci(limit: int) -> Iterator[int]:
    a, b = 0, 1
    while a < limit:
        yield a
        a, b = b, a + b

total = sum(x * x for x in range(1_000_000))       # lazy, constant memory
```

Generators stream data instead of materializing lists; comprehensions for short, single-purpose
transformations only.

## Decorators and Context Managers

```python
from contextlib import contextmanager
from functools import wraps
from typing import Callable, Any

def timed(func: Callable[..., Any]) -> Callable[..., Any]:
    @wraps(func)                                  # preserves __name__, __doc__
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            print(f"{func.__name__}: {time.perf_counter() - start:.3f}s")
    return wrapper

@contextmanager
def transaction(conn: Connection) -> Iterator[Connection]:
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
```

Always use `functools.wraps`; prefer `contextlib.contextmanager` over hand-written `__enter__`/`__exit__`.

## Concurrency

| Workload                                      | Tool                                                                   |
| --------------------------------------------- | ---------------------------------------------------------------------- |
| I/O-bound, many tasks                         | `asyncio`                                                              |
| I/O-bound, blocking libraries, threads needed | `threading` / `ThreadPoolExecutor`                                     |
| CPU-bound                                     | `multiprocessing` / `ProcessPoolExecutor` (the GIL serializes threads) |

```python
async def fetch_all(urls: list[str]) -> list[str]:
    async with httpx.AsyncClient() as client:
        results = await asyncio.gather(*(client.get(u) for u in urls))
    return [r.text for r in results]

with ThreadPoolExecutor(max_workers=8) as pool:
    results = list(pool.map(download, urls))
```

Never block the event loop (`time.sleep`, sync HTTP, heavy CPU) — use `asyncio.to_thread` or a worker.
Protect shared mutable state with `asyncio.Lock` / `threading.Lock`; prefer passing results back.

## Performance

- Profile before changing anything: `python -m cProfile -s cumulative prog.py`, `py-spy top --pid`,
  `timeit` for micro-benchmarks.
- Data structures first: `set`/`dict` lookups instead of list scans; `collections.Counter`, `defaultdict`, `deque`.
- Build text with `"".join(...)`; avoid repeated `+` in loops and needless `.copy()`.
- Push loops into C: comprehensions, `sum`, `any`, `all`, `str.join`, NumPy.
- Intern hot paths only with measured evidence; keep readability otherwise.

## Testing

```python
import pytest

def test_average_rejects_empty() -> None:
    with pytest.raises(ValueError):
        calculate_average([])

@pytest.mark.parametrize(("age", "expected"), [(15, False), (18, True)])
def test_is_adult(age: int, expected: bool) -> None:
    assert User("Test", "t@example.com", age).is_adult is expected
```

- Test behavior and boundaries, not internals; one logical assertion per test.
- Fixtures for setup, `tmp_path` for files, `monkeypatch` for environment.
- Debug with `breakpoint()` (pdb/pudb), `python -m pdb`, or `pytest --pdb`.
- Never claim tests passed unless they ran.

## Anti-Patterns

| Anti-pattern                                   | Fix                                                    |
| ---------------------------------------------- | ------------------------------------------------------ |
| Mutable default argument (shared across calls) | Default to `None`, then assign a fresh list inside     |
| Bare `except:` / `except Exception: pass`      | Catch specific types, handle or re-raise               |
| Untyped functions, bare `list`/`dict`          | Full annotations                                       |
| Loose dicts for records                        | `TypedDict` or dataclass                               |
| `Any` sprinkled through code                   | Precise types; `object` + narrowing at true boundaries |
| `is` for value comparison                      | `is` only for `None`/singletons                        |
| Late-binding closures in loops                 | Bind with a default argument                           |
| Wildcard imports                               | Explicit imports                                       |
| Catching `Exception` to return `None`          | Let errors propagate or translate them                 |

## Project Setup and Type Checking

```
myproject/
├── pyproject.toml
├── src/myproject/{__init__.py,core/,api/}
└── tests/
```

```toml
[project]
name = "myproject"
requires-python = ">=3.10"
dependencies = ["httpx>=0.27", "pydantic>=2"]

[tool.mypy]
python_version = "3.10"
strict = true

[tool.ruff]
line-length = 88
```

```bash
mypy --strict src/
pyright src/
ruff check src/ && ruff format src/
pytest -q
```

Mandatory rules: annotate parameters and returns; use built-in generics; handle `None` explicitly; no
unjustified `Any`; structured data gets `TypedDict`/dataclass; type checking configured in the project.

## References

- [Python documentation](https://docs.python.org/3/)
- [PEP 8](https://peps.python.org/pep-0008/), [PEP 484](https://peps.python.org/pep-0484/), [PEP 585](https://peps.python.org/pep-0585/)
- [typing reference](https://docs.python.org/3/library/typing.html)
- [mypy](https://mypy.readthedocs.io/), [pyright](https://microsoft.github.io/pyright/), [ruff](https://docs.astral.sh/ruff/)

Related: [`principles.md`](principles.md), [`code-review.md`](code-review.md), [`../SKILL.md`](../SKILL.md)
