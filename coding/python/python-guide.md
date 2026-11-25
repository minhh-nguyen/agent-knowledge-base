# Python Programming Guide

Comprehensive guide to modern Python (3.10+) for writing safe, maintainable, and correctly typed software. **Type annotations are mandatory in all recommended implementations.**

## Table of Contents

1. [Modern Python Fundamentals](#modern-python-fundamentals)
2. [Type Annotations and Typing](#type-annotations-and-typing)
3. [Built-in Types and Data Structures](#built-in-types-and-data-structures)
4. [Functions and Signatures](#functions-and-signatures)
5. [Classes and Object-Oriented Design](#classes-and-object-oriented-design)
6. [Error Handling](#error-handling)
7. [Iterators, Generators, and Comprehensions](#iterators-generators-and-comprehensions)
8. [Decorators and Context Managers](#decorators-and-context-managers)
9. [Concurrency and Async Programming](#concurrency-and-async-programming)
10. [Performance and Profiling](#performance-and-profiling)
11. [Testing and Debugging](#testing-and-debugging)
12. [Common Mistakes and Anti-Patterns](#common-mistakes-and-anti-patterns)
13. [Project Organization](#project-organization)
14. [Static Type Checking](#static-type-checking)

---

## Modern Python Fundamentals

### Python 3.10+ Features

**Use modern language features:**
- Structural pattern matching (`match`/`case`)
- Union types with `|` operator: `str | int` instead of `Union[str, int]`
- Positional-only and keyword-only parameters
- Type hints with built-in generics

**Use Python 3.10+ type syntax:**

```python
# OLD (Python 3.9): requires `from typing import List, Dict`
def process(items: List[str]) -> Dict[str, int]:
    pass

# NEW (Python 3.10+): built-in generic syntax
def process(items: list[str]) -> dict[str, int]:
    pass
```

### Code Style

**Follow PEP 8 conventions:**
- 4-space indentation
- Maximum line length: 88 characters (with black) or 79 (strict PEP 8)
- Two blank lines between top-level definitions
- One blank line between methods

**Use meaningful names:**

```python
# BAD
def f(x, y):
    return x + y

# GOOD
def calculate_total_cost(base_price: float, tax_amount: float) -> float:
    return base_price + tax_amount
```

---

## Type Annotations and Typing

### Mandatory Type Annotations

**Annotate all function parameters and return types:**

```python
# BAD: no type annotations
def add_user(name, age, email):
    users.append({"name": name, "age": age, "email": email})

# GOOD: complete type annotations
def add_user(name: str, age: int, email: str) -> None:
    users.append({"name": name, "age": age, "email": email})
```

**Annotate complex variables:**

```python
# GOOD: types are clear from annotation
user_ids: list[int] = []
age_by_name: dict[str, int] = {}
config: dict[str, str | int | bool] = {}
```

### Generic Types

**Use modern built-in generic syntax (Python 3.10+):**

```python
# GOOD: use built-in types directly
def filter_users(users: list[User]) -> list[User]:
    return [u for u in users if u.active]

def group_by_department(users: list[User]) -> dict[str, list[User]]:
    result: dict[str, list[User]] = {}
    for user in users:
        if user.department not in result:
            result[user.department] = []
        result[user.department].append(user)
    return result
```

### Optional and Union Types

**Use `| None` for optional types:**

```python
# GOOD: Python 3.10+ syntax
def find_user(user_id: int) -> User | None:
    for user in users:
        if user.id == user_id:
            return user
    return None

# GOOD: use in parameters
def set_description(description: str | None = None) -> None:
    pass
```

**Use union types for multiple possibilities:**

```python
# GOOD: pipe operator for unions
def parse_value(value: str | int | float) -> float:
    if isinstance(value, str):
        return float(value)
    return float(value)

# GOOD: or use Union when needed for complex types
from typing import Union
Result: type = Union[Success, Error]
```

### TypedDict for Structured Data

**Use `TypedDict` instead of loosely typed dictionaries:**

```python
# BAD: loosely typed
def create_user_dict(name: str, age: int) -> dict:
    return {"name": name, "age": age}

# GOOD: structured with TypedDict
from typing import TypedDict

class UserDict(TypedDict):
    name: str
    age: int
    email: str

def create_user_dict(name: str, age: int) -> UserDict:
    return {"name": name, "age": age, "email": "unknown"}
```

### Protocol for Duck Typing

**Use `Protocol` for structural subtyping:**

```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...
    def get_width(self) -> int: ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")
    def get_width(self) -> int:
        return 10

def render(obj: Drawable) -> None:
    obj.draw()
    print(f"Width: {obj.get_width()}")

# Circle satisfies Drawable protocol without explicit inheritance
render(Circle())
```

### Generics and TypeVar

**Use `TypeVar` for generic functions:**

```python
from typing import TypeVar

T = TypeVar('T')  # Generic type variable

def first_element(items: list[T]) -> T:
    if not items:
        raise ValueError("Cannot get first element of empty list")
    return items[0]

first_element([1, 2, 3])      # Returns int
first_element(["a", "b"])     # Returns str
```

---

## Built-in Types and Data Structures

### Basic Types

**Primitives and their characteristics:**

```python
# Integers: arbitrary precision
count: int = 42
large_number: int = 10**100  # No overflow

# Floats: 64-bit IEEE 754
price: float = 19.99
scientific: float = 1.5e-10

# Strings: immutable Unicode sequences
message: str = "Hello, world!"
multiline: str = """
This is a multiline
string"""

# Booleans: True, False
is_active: bool = True

# None: absence of value
result: str | None = None
```

### Collections

**Choose the right collection for the task:**

```python
# List: mutable, ordered, indexed
items: list[str] = ["apple", "banana", "cherry"]
items.append("date")
items[0]  # "apple"

# Tuple: immutable, ordered, indexed
coordinates: tuple[int, int] = (10, 20)
x, y = coordinates  # Tuple unpacking

# Set: unordered, unique values
unique_ids: set[int] = {1, 2, 3}
{1, 2, 2}  # Automatically deduplicates to {1, 2}

# Dictionary: key-value mapping
user: dict[str, str | int] = {
    "name": "Alice",
    "age": 30,
    "email": "alice@example.com"
}
```

**Type-hint collections precisely:**

```python
# GOOD: specific element type
names: list[str] = []
age_map: dict[str, int] = {}

# AVOID: untyped collections
items: list = []           # What's in the list?
mapping: dict = {}         # What are the keys and values?
```

---

## Functions and Signatures

### Complete Function Signatures

**All functions must have parameter and return type annotations:**

```python
# GOOD: complete signature
def calculate_average(scores: list[float]) -> float:
    if not scores:
        raise ValueError("Cannot average empty list")
    return sum(scores) / len(scores)

# GOOD: optional parameter
def greet(name: str, greeting: str = "Hello") -> str:
    return f"{greeting}, {name}!"

# GOOD: *args and **kwargs with types
def collect_args(*args: int, **kwargs: str) -> dict[str, int | list[int]]:
    return {"args": list(args), "kwargs_count": len(kwargs)}
```

### Default Values

**Use defaults for optional behavior:**

```python
def create_connection(
    host: str,
    port: int = 5432,
    timeout: float = 30.0,
    retry: bool = True
) -> Connection:
    pass
```

### Type Aliases

**Use type aliases for complex types:**

```python
# GOOD: makes code more readable
UserId = int
UserDict = dict[str, str | int]
Callback = callable[[int], None]

def register_callback(user_id: UserId, callback: Callback) -> None:
    pass
```

---

## Classes and Object-Oriented Design

### Class Definition with Type Annotations

```python
class User:
    # Annotate instance attributes
    name: str
    email: str
    age: int
    is_active: bool

    def __init__(self, name: str, email: str, age: int) -> None:
        self.name = name
        self.email = email
        self.age = age
        self.is_active = True

    def activate(self) -> None:
        self.is_active = True

    def get_display_name(self) -> str:
        return f"{self.name} ({self.email})"

    @property
    def is_adult(self) -> bool:
        return self.age >= 18

    @classmethod
    def from_dict(cls, data: dict[str, str | int]) -> User:
        return cls(
            name=str(data["name"]),
            email=str(data["email"]),
            age=int(data["age"])
        )

    @staticmethod
    def validate_email(email: str) -> bool:
        return "@" in email
```

### Inheritance

**Use inheritance judiciously:**

```python
class Person:
    def __init__(self, name: str) -> None:
        self.name = name

class Employee(Person):
    def __init__(self, name: str, employee_id: int) -> None:
        super().__init__(name)
        self.employee_id = employee_id
```

### Abstract Base Classes

**Use ABC for interface contracts:**

```python
from abc import ABC, abstractmethod

class DataStore(ABC):
    @abstractmethod
    def get(self, key: str) -> str | None:
        pass

    @abstractmethod
    def set(self, key: str, value: str) -> None:
        pass

class MemoryStore(DataStore):
    def __init__(self) -> None:
        self.data: dict[str, str] = {}

    def get(self, key: str) -> str | None:
        return self.data.get(key)

    def set(self, key: str, value: str) -> None:
        self.data[key] = value
```

---

## Error Handling

### Exceptions

**Use exceptions for exceptional conditions:**

```python
# GOOD: specific exception type
def parse_port(port_str: str) -> int:
    try:
        port = int(port_str)
        if not 1 <= port <= 65535:
            raise ValueError(f"Port must be 1-65535, got {port}")
        return port
    except ValueError as e:
        raise ValueError(f"Invalid port: {port_str}") from e
```

**Create custom exceptions:**

```python
class DatabaseError(Exception):
    """Base exception for database operations"""
    pass

class ConnectionError(DatabaseError):
    """Raised when connection fails"""
    pass

class QueryError(DatabaseError):
    """Raised when query fails"""
    pass

def query_database(sql: str) -> list[dict[str, str]]:
    if not sql:
        raise QueryError("SQL query cannot be empty")
    # Actual query logic...
```

### Context Managers for Cleanup

**Use context managers (`with` statement) for resource management:**

```python
# GOOD: file is closed automatically
with open("data.txt", "r") as f:
    contents = f.read()
    process(contents)

# GOOD: custom context manager
class Database:
    def __enter__(self) -> "Database":
        self.connection = self._create_connection()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> bool:
        self.connection.close()
        return False  # Don't suppress exceptions

# Usage
with Database() as db:
    db.query("SELECT * FROM users")
```

---

## Iterators, Generators, and Comprehensions

### Comprehensions

**Comprehensions are concise and efficient:**

```python
# List comprehension
squares: list[int] = [x**2 for x in range(10)]

# Set comprehension (removes duplicates)
unique_lengths: set[int] = {len(word) for word in ["apple", "app", "application"]}

# Dict comprehension
user_map: dict[int, str] = {user.id: user.name for user in users}

# Conditional comprehension
even_numbers: list[int] = [x for x in range(20) if x % 2 == 0]

# Nested comprehension (be careful with readability)
flattened: list[int] = [x for row in matrix for x in row]
```

### Generators

**Generators produce values lazily:**

```python
def fibonacci(limit: int) -> Generator[int, None, None]:
    a, b = 0, 1
    while a < limit:
        yield a
        a, b = b, a + b

# Generators don't consume memory upfront
for num in fibonacci(100):
    print(num)

# Generator comprehension
large_squares = (x**2 for x in range(1000000))  # Computed lazily
```

---

## Decorators and Context Managers

### Decorators

**Decorators modify function or class behavior:**

```python
def measure_time(func: Callable[..., Any]) -> Callable[..., Any]:
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        import time
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.2f}s")
        return result
    return wrapper

@measure_time
def slow_function(n: int) -> int:
    return sum(range(n))

slow_function(1000000)  # Prints execution time
```

**Use `functools.wraps` to preserve metadata:**

```python
from functools import wraps

def trace(func: Callable[..., Any]) -> Callable[..., Any]:
    @wraps(func)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@trace
def greet(name: str) -> str:
    return f"Hello, {name}!"

greet("Alice")  # Prints: "Calling greet", then returns greeting
```

---

## Concurrency and Async Programming

### Threading

**Use `threading` for I/O-bound tasks:**

```python
import threading
from typing import Callable

def download_all(urls: list[str]) -> list[str]:
    results: list[str] = []
    lock = threading.Lock()

    def download(url: str) -> None:
        content = fetch_url(url)
        with lock:
            results.append(content)

    threads: list[threading.Thread] = []
    for url in urls:
        t = threading.Thread(target=download, args=(url,))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

    return results
```

### Async/Await

**Use async/await for concurrent I/O:**

```python
import asyncio

async def fetch_all(urls: list[str]) -> list[str]:
    tasks = [fetch_url(url) for url in urls]
    return await asyncio.gather(*tasks)

async def fetch_url(url: str) -> str:
    # Simulate async request
    await asyncio.sleep(1)
    return f"Content from {url}"

# Run async code
results = asyncio.run(fetch_all(["http://a.com", "http://b.com"]))
```

---

## Performance and Profiling

### Profiling

**Profile before optimizing:**

```python
import cProfile
import pstats

def expensive_function() -> int:
    total = 0
    for i in range(1000000):
        total += i
    return total

# Profile a function
profiler = cProfile.Profile()
profiler.enable()
result = expensive_function()
profiler.disable()

stats = pstats.Stats(profiler)
stats.sort_stats("cumulative")
stats.print_stats(10)  # Print top 10 functions
```

### Common Bottlenecks

**Avoid string concatenation in loops:**

```python
# BAD: creates new string each time
result = ""
for item in large_list:
    result += str(item) + ", "

# GOOD: single join operation
result = ", ".join(str(item) for item in large_list)
```

**Avoid unnecessary list copies:**

```python
# BAD: unnecessary copy
def process(items: list[int]) -> int:
    items_copy = items.copy()
    return sum(items_copy)

# GOOD: work with original
def process(items: list[int]) -> int:
    return sum(items)
```

---

## Testing and Debugging

### Unit Testing with pytest

```python
import pytest

def test_addition() -> None:
    assert 2 + 2 == 4

def test_user_creation() -> None:
    user = User("Alice", "alice@example.com", 30)
    assert user.name == "Alice"
    assert user.is_adult is True

@pytest.mark.parametrize("age,expected", [(15, False), (18, True), (65, True)])
def test_is_adult(age: int, expected: bool) -> None:
    user = User("Test", "test@example.com", age)
    assert user.is_adult == expected

def test_invalid_port() -> None:
    with pytest.raises(ValueError):
        parse_port("99999")
```

### Debugging

**Use the Python debugger:**

```python
import pdb

def buggy_function(items: list[int]) -> int:
    result = 0
    for item in items:
        pdb.set_trace()  # Execution pauses here
        result += item
    return result

# In debugger:
# (Pdb) print item
# (Pdb) next
# (Pdb) continue
```

---

## Common Mistakes and Anti-Patterns

### Mutable Default Arguments

```python
# BAD: mutable default is shared across calls
def add_item(item: str, items: list[str] = []) -> list[str]:
    items.append(item)
    return items

list1 = add_item("a")
list2 = add_item("b")
print(list1)  # ["a", "b"] — surprise!

# GOOD: use None as default
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

### Type Ambiguity

```python
# BAD: unclear what type user is
def get_user(user_id):
    return database.find(user_id)

# GOOD: explicit types
def get_user(user_id: int) -> User | None:
    return database.find(user_id)
```

### Catching Too Broad Exceptions

```python
# BAD: catches everything, including programming errors
try:
    value = int(user_input)
except Exception:
    print("Invalid input")

# GOOD: catch only expected exceptions
try:
    value = int(user_input)
except ValueError:
    print("Invalid input: not a number")
```

---

## Project Organization

### Module and Package Structure

```
myproject/
├── pyproject.toml          # Project metadata
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── core/
│       │   ├── __init__.py
│       │   └── models.py
│       ├── api/
│       │   ├── __init__.py
│       │   └── endpoints.py
│       └── utils/
│           ├── __init__.py
│           └── helpers.py
├── tests/
│   ├── test_models.py
│   ├── test_api.py
│   └── test_helpers.py
└── README.md
```

### pyproject.toml

```toml
[project]
name = "myproject"
version = "1.0.0"
description = "A Python project"
dependencies = [
    "requests>=2.28.0",
    "pydantic>=2.0",
]

[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.mypy]
python_version = "3.10"
strict = true

[tool.black]
line-length = 88
```

---

## Static Type Checking

### mypy

**Run mypy to catch type errors:**

```bash
mypy src/              # Check all files
mypy --strict src/     # Strict mode (recommended)
```

**mypy configuration:**

```ini
[mypy]
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True      # All functions must have types
disallow_incomplete_defs = True   # All types must be complete
```

### pyright

**pyright is fast and strict:**

```bash
pyright                # Check project
pyright --outputjson   # Machine-readable output
```

**pyrightconfig.json:**

```json
{
    "pythonVersion": "3.10",
    "typeCheckingMode": "strict",
    "reportMissingTypeStubs": "warning"
}
```

---

## References

- [Python Documentation](https://docs.python.org/3/) — Official Python docs
- [PEP 8](https://www.python.org/dev/peps/pep-0008/) — Style guide
- [PEP 484](https://www.python.org/dev/peps/pep-0484/) — Type hints specification
- [Python typing module](https://docs.python.org/3/library/typing.html) — Typing reference
- [mypy documentation](https://mypy.readthedocs.io/) — Type checker documentation
- [pyright documentation](https://github.com/microsoft/pyright) — Fast type checker
