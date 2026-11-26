# C++ Guide

Modern C++ (C++17 baseline, C++20 where noted) for safe, efficient, maintainable code.
Toolchain: GCC 10+, Clang 12+, MSVC 2019+; CMake + Ninja. Follow the repository's own style first.

Consult for: implementing C++ features, ownership and memory bugs, performance work, review, teaching.

## Contents

- [Core Concepts](#core-concepts)
- [RAII and Ownership](#raii-and-ownership)
- [Smart Pointers](#smart-pointers)
- [Move Semantics](#move-semantics)
- [Types and Const Correctness](#types-and-const-correctness)
- [Templates and Concepts](#templates-and-concepts)
- [Error Handling and Exception Safety](#error-handling-and-exception-safety)
- [Containers and Algorithms](#containers-and-algorithms)
- [Concurrency](#concurrency)
- [Performance](#performance)
- [Testing and Debugging](#testing-and-debugging)
- [Anti-Patterns](#anti-patterns)
- [Code Organization and Build](#code-organization-and-build)

## Core Concepts

- **Value semantics by default.** Objects are copied or moved; use references only for intentional aliasing.
- **Explicit over implicit.** Mark single-argument constructors `explicit`; avoid silent conversions.
- **Zero-overhead abstractions.** Templates, lambdas and inline functions compile to what hand-written code would.
- **Smallest sufficient feature.** Prefer the simplest construct that solves the problem.

```cpp
class Size {
public:
    explicit Size(int pixels) : pixels_(pixels) {}
private:
    int pixels_;
};

Size a(10);   // OK
// Size b = 10;  // error: no implicit int -> Size
```

## RAII and Ownership

Every resource (memory, file, lock, socket) is owned by an object whose destructor releases it.
Acquire in a constructor, release in a destructor. Destructors run during stack unwinding, so cleanup
is exception-safe: no manual `close`/`free`, no leaks on early return.

```cpp
class File {
public:
    explicit File(const std::string& path)
        : handle_(::open(path.c_str(), O_RDONLY)) {
        if (handle_ < 0) throw std::runtime_error("cannot open " + path);
    }
    ~File() { if (handle_ >= 0) ::close(handle_); }
    File(const File&) = delete;             // no double close
    File& operator=(const File&) = delete;
private:
    int handle_;
};

{
    File f("data.txt");   // may throw; destructor closes on success or exception
}                          // closed here
```

The same pattern covers locks (`std::lock_guard`), transactions (rollback in destructor unless
`commit()` was called), and scope guards.

## Smart Pointers

No raw `new`/`delete`. Ownership is expressed by the pointer type.

| Type | Ownership | Use |
|------|-----------|-----|
| `std::unique_ptr<T>` | Exclusive | Default choice for heap objects |
| `std::shared_ptr<T>` | Shared, ref-counted | Genuinely shared lifetime |
| `std::weak_ptr<T>` | None | Observe a `shared_ptr` without keeping it alive |

```cpp
class Logger {
public:
    explicit Logger(const std::string& path)
        : file_(std::make_unique<std::ofstream>(path)) {}
private:
    std::unique_ptr<std::ofstream> file_;
};

auto texture = std::make_shared<Texture>("sprite.png");  // shared only when needed
std::weak_ptr<Texture> cached = texture;                 // breaks cycles
```

- `unique_ptr` is non-copyable, movable, and costs nothing over a raw pointer.
- `shared_ptr` costs an atomic ref-count and a control block; don't use it by default.
- `weak_ptr` breaks reference cycles (parent/child, observer lists).

## Move Semantics

A move transfers resources from a temporary instead of copying them.

```cpp
std::vector<int> make_data() {
    std::vector<int> v(1'000'000, 0);
    return v;                 // NRVO / move, no copy
}
std::vector<int> v = make_data();

class Buffer {
public:
    Buffer(Buffer&& other) noexcept
        : data_(std::move(other.data_)), size_(std::exchange(other.size_, 0)) {}
    Buffer& operator=(Buffer&&) noexcept = default;
private:
    std::unique_ptr<char[]> data_;
    std::size_t size_ = 0;
};
```

- Mark move operations `noexcept`; `std::vector` reallocation uses moves only if they cannot throw.
- Use `std::move` only to transfer ownership into a parameter (by-value or `&&`), never to "help" the compiler on a local.
- After a move the source must be left valid but unspecified; reset scalars as needed.

## Types and Const Correctness

`const` documents intent and is enforced by the compiler.

```cpp
class Cache {
public:
    const Value& get(const Key& key) const { return data_.at(key); }  // callable on const Cache
    void set(const Key& key, const Value& value) { data_[key] = value; }
private:
    std::map<Key, Value> data_;
};

void process(const std::vector<int>& data);   // reads, cannot mutate
```

Rules: mark non-mutating members `const`; pass by `const&` for read-only, by value for cheap or
moveable types; `const T*` = pointer to const data, `T* const` = const pointer. `mutable` is for
caches and mutexes only.

Strong types prevent unit and ID mix-ups:

```cpp
struct Meters { double value; };
struct Seconds { double value; };
double speed(Meters d, Seconds t) { return d.value / t.value; }
// speed(Seconds{5}, Meters{10});  // error: argument order is checked
```

`std::optional`, `std::variant`, and `std::string_view` (non-owning, never outlive the buffer)
replace null pointers, tag unions, and `const std::string&` overloads respectively.

## Templates and Concepts

```cpp
template <typename T>
T max(T a, T b) { return a > b ? a : b; }

template <std::integral T>              // C++20 concept: clear errors, checked overloads
T sum(const std::vector<T>& v) {
    T total{};
    for (const auto& x : v) total += x;
    return total;
}
```

- Prefer concepts (`std::integral`, `std::ranges::range`, custom `requires`) over SFINAE tricks.
- Specialize only for real algorithmic differences or performance needs, not for convenience.
- Keep templates in headers, or explicitly instantiate in a `.cpp`.

## Error Handling and Exception Safety

- **Exceptions** for conditions that should not occur in normal operation (unopenable file, broken invariant).
- **`std::optional` / error codes / `std::expected` (C++23)** for expected outcomes (cache miss, parse failure).

Guarantees, strongest first:

| Guarantee | Meaning |
|-----------|---------|
| No-throw | Never throws (destructors, move ops, `swap`) |
| Strong | Either completes or leaves state unchanged (copy-then-swap) |
| Basic | Valid but unspecified state; no leaks |
| None | Avoid |

```cpp
std::optional<Value> lookup(const Key& k) const {
    auto it = data_.find(k);
    if (it == data_.end()) return std::nullopt;
    return it->second;
}

void update(const Record& r) {           // strong guarantee via copy-and-swap
    auto next = current_;                // copy
    next.apply(r);                       // may throw, current_ untouched
    current_ = std::move(next);          // noexcept commit
}
```

Give error messages the operation, the input, and the reason. Never throw from a destructor.

## Containers and Algorithms

| Container | Access | Insert/erase | Notes |
|-----------|--------|--------------|-------|
| `std::vector` | O(1) | O(n) | Default; contiguous, cache-friendly |
| `std::deque` | O(1) | O(1) at ends | Growable at both ends |
| `std::list` | O(n) | O(1) with iterator | Rarely worth it |
| `std::map` / `std::set` | O(log n) | O(log n) | Ordered, `std::less` |
| `std::unordered_map` / `set` | O(1) avg | O(1) avg | Hash-based, no order |

Prefer algorithms and ranges over hand-written loops; they state intent and optimize better.

```cpp
int total = std::accumulate(v.begin(), v.end(), 0);
std::vector<int> squares;
std::transform(v.begin(), v.end(), std::back_inserter(squares),
               [](int x) { return x * x; });
auto evens = v | std::views::filter([](int x) { return x % 2 == 0; });  // C++20 ranges
```

Reserve when the final size is known (`v.reserve(n)`) to avoid reallocation.

## Concurrency

- Protect shared mutable state; prefer message passing or per-thread data over sharing.
- Use RAII lock types (`std::lock_guard`, `std::scoped_lock`, `std::unique_lock` when manual control is needed).
- `std::atomic<T>` for single values; default memory order `seq_cst` unless profiling justifies weaker.
- Deadlock avoidance: consistent lock ordering, `std::scoped_lock` for multiple mutexes, never hold a lock across blocking I/O, never call unknown code while holding a lock.
- `std::jthread` (C++20) joins automatically; `std::thread` must be joined or detached.

```cpp
class Counter {
public:
    void increment() { std::lock_guard lock(mutex_); ++count_; }
    int value() const { std::lock_guard lock(mutex_); return count_; }
private:
    mutable std::mutex mutex_;
    int count_ = 0;
};

std::atomic<bool> ready{false};
ready.store(true, std::memory_order_release);
bool ok = ready.load(std::memory_order_acquire);
```

## Performance

- **Profile first** (`perf`, `valgrind --tool=callgrind`, `-ftime-trace`, `Tracy`). No optimization without a measurement.
- **Data layout beats instruction count.** `std::vector` over node-based containers; hot fields together; sort members by alignment to remove padding.

```cpp
struct Record {          // 16 bytes: 8 + 4 + 4, no padding
    std::uint64_t id;
    std::uint32_t flags;
    float score;
};
```

- Pass large types by `const&`; return by value and rely on RVO/move.
- Avoid allocations in hot loops; reuse buffers, use `std::pmr` or small-buffer types.
- Build with `-O2` (default balance), `-O3` + `-march=native` only with benchmark evidence, `-flto` for cross-TU inlining; keep DWARF (`-g`) in release builds.
- Measure again after every change and record the numbers.

## Testing and Debugging

```cpp
TEST(StackTest, PushPop) {          // Google Test / Catch2
    Stack<int> s;
    s.push(42);
    EXPECT_EQ(s.pop(), 42);
    EXPECT_TRUE(s.empty());
}
```

- Sanitizers in debug/test builds: `-fsanitize=address,undefined`; `-fsanitize=thread` for races (not combinable with ASan).
- `gdb`/`lldb`: `break`, `run`, `bt`, `frame`, `print`, `watch`.
- Test edge cases: empty ranges, zero sizes, self-assignment, move-from state, error paths.
- Never report "tested" unless the build and tests actually ran.

## Anti-Patterns

| Anti-pattern | Fix |
|--------------|-----|
| Raw `new`/`delete`, owning raw pointers | `unique_ptr` / `shared_ptr` |
| Manual `close`/`unlock`/`free` | RAII wrapper |
| Implicit single-arg conversions | `explicit` |
| Slicing by passing by value to a base type | Pass by reference |
| Dangling pointer/reference to a local or temporary | Return by value, or tie lifetimes together |
| `shared_ptr` everywhere | `unique_ptr` unless sharing is real |
| Copying in loops / pass-by-value of big objects | `const&`, moves, `reserve` |
| Clever one-liners | Named steps, readable loops |
| Catching `...` and swallowing | Catch specific types, rethrow or handle |
| Optimizing without profiling | Measure, change one thing, measure |

## Code Organization and Build

- Headers: `#pragma once`, include what you use, forward-declare to cut dependencies.
- Group by domain (e.g. `network/`, `storage/`), mirror headers and sources, keep tests parallel.
- Prefer composition and free functions over deep hierarchies; PImpl to stabilize ABI.

```cmake
cmake_minimum_required(VERSION 3.20)
project(myapp CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_library(core src/core.cpp)
target_include_directories(core PUBLIC include)
target_compile_options(core PRIVATE -Wall -Wextra -Wpedantic)   # MSVC: /W4
add_executable(myapp src/main.cpp)
target_link_libraries(myapp PRIVATE core)
enable_testing()
add_test(NAME core_tests COMMAND core_tests)
```

## References

- [cppreference](https://en.cppreference.com/) — language and library reference
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/) — authoritative best practices
- [C++ standard](https://isocpp.org/std/the-standard)

Related: [`principles.md`](principles.md), [`code-review.md`](code-review.md), [`../SKILL.md`](../SKILL.md)
