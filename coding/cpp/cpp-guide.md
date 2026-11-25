# C++ Programming Guide

Comprehensive guide to modern C++ for writing safe, efficient, maintainable software. This guide focuses on **C++17 and later**, reflecting current best practices and language features.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Memory Management and RAII](#memory-management-and-raii)
3. [Type System and Const Correctness](#type-system-and-const-correctness)
4. [Ownership and Resource Management](#ownership-and-resource-management)
5. [Templates and Generic Programming](#templates-and-generic-programming)
6. [Error Handling and Exception Safety](#error-handling-and-exception-safety)
7. [STL Containers and Algorithms](#stl-containers-and-algorithms)
8. [Concurrency and Synchronization](#concurrency-and-synchronization)
9. [Performance Considerations](#performance-considerations)
10. [Testing and Debugging](#testing-and-debugging)
11. [Common Mistakes and Anti-Patterns](#common-mistakes-and-anti-patterns)
12. [Code Organization](#code-organization)
13. [Build Systems](#build-systems)

---

## Core Concepts

### Language Fundamentals

**Use modern C++ features:** C++17 introduced significant improvements (structured bindings, `std::optional`, `std::variant`). Use these instead of older patterns.

**Value semantics by default:** C++ emphasizes value semantics — objects are copied or moved rather than managed by pointers. Use references only when aliasing is intended.

**Explicit is better than implicit:** Avoid hidden conversions and magic behavior. Mark constructors `explicit` to prevent implicit conversions:

```cpp
class Size {
public:
    explicit Size(int pixels) : pixels_(pixels) {}
private:
    int pixels_;
};

Size s = 10;  // ERROR: cannot convert int to Size implicitly
Size s(10);   // OK
```

**Zero-overhead abstractions:** High-level C++ constructs compile down to efficient machine code. Use abstractions freely; they don't add runtime cost.

---

## Memory Management and RAII

### RAII (Resource Acquisition Is Initialization)

**RAII is the foundation of safe C++.** Every resource (memory, file handle, network connection) has an owner — typically a stack-allocated object whose destructor releases the resource.

**How RAII works:**
- Resource acquisition happens in a constructor
- Resource release happens in a destructor
- Objects are destroyed when they go out of scope
- Exceptions cannot bypass destructors

**Example — File handling:**

```cpp
class File {
public:
    explicit File(const std::string& path) {
        handle_ = ::open(path.c_str(), O_RDONLY);
        if (handle_ < 0) throw std::runtime_error("Cannot open file");
    }
    ~File() {
        if (handle_ >= 0) ::close(handle_);
    }
private:
    int handle_;
};

{
    File f("data.txt");  // Constructor opens file
    // Use file...
}  // Destructor closes file, even if exception was thrown
```

**RAII guarantees:**
- Resources are always cleaned up
- Cleanup happens even if exceptions occur
- No manual cleanup code needed
- Exception-safe by design

### Smart Pointers

**Never use raw `new` and `delete` in modern C++.** Use smart pointers to manage dynamic memory.

#### `std::unique_ptr` — Exclusive Ownership

Use when only one owner should hold the resource:

```cpp
class Logger {
private:
    std::unique_ptr<std::ofstream> file_;
public:
    Logger(const std::string& path) 
        : file_(std::make_unique<std::ofstream>(path)) {}
};
```

**Properties:**
- Cannot be copied (no two owners)
- Can be moved (transfer ownership)
- Zero overhead compared to raw pointers
- Automatically deleted when owner is destroyed

#### `std::shared_ptr` — Shared Ownership

Use when multiple owners share responsibility:

```cpp
std::shared_ptr<Texture> texture = std::make_shared<Texture>("sprite.png");
// Multiple parts of the code can hold references to the same texture
// Texture is deleted when the last reference is destroyed
```

**When to use:**
- Circular references (with `std::weak_ptr`)
- Observer patterns where lifetime is shared
- Thread-safe reference counting

**Avoid:** `std::shared_ptr` as a default; use `std::unique_ptr` unless shared ownership is required.

#### `std::weak_ptr` — Non-Owning Reference

Use to break cycles in `std::shared_ptr`:

```cpp
class Node {
    std::shared_ptr<Node> parent;    // ERROR: cycle
    std::weak_ptr<Node> parent;      // OK: doesn't prevent deletion
};
```

### Move Semantics

**Move semantics eliminate expensive copies.** When an object is temporary (about to be destroyed), move its resources rather than copy.

```cpp
std::vector<int> get_data() {
    std::vector<int> result;
    result.push_back(1);
    return result;  // Move constructor transfers ownership, no copy
}

std::vector<int> v = get_data();  // No copy, v receives moved data
```

**Implement move constructors for heavy objects:**

```cpp
class Data {
public:
    Data(Data&& other) noexcept 
        : buffer_(std::move(other.buffer_)), size_(other.size_) {
        other.size_ = 0;  // Source is now empty
    }
private:
    std::unique_ptr<char[]> buffer_;
    size_t size_;
};
```

**Guidelines:**
- Move constructor should be `noexcept` (exceptions during move are dangerous)
- Use `std::move()` when passing objects you're done with
- Prefer move semantics in function parameters when ownership is transferred
- Standard containers (vector, string) have move semantics

---

## Type System and Const Correctness

### Const Correctness

**Use `const` to express intent and enable compiler checking.**

```cpp
class Cache {
public:
    const Value& get(const Key& key) const {
        return data_.at(key);  // const method can't modify data_
    }
    void set(const Key& key, const Value& val) {
        data_[key] = val;  // non-const can modify
    }
private:
    std::map<Key, Value> data_;
};

const Cache& cache = get_cache();
cache.get("key");      // OK: calls const method
cache.set("key", val); // ERROR: cannot call non-const method on const object
```

**Const reference parameters prevent accidental modification:**

```cpp
void process(const std::vector<int>& data) {
    // data[0] = 10;  // ERROR: cannot modify const reference
}
```

**Const member functions enable const objects:**

```cpp
class Matrix {
public:
    double determinant() const;  // Can be called on const objects
    void normalize();             // Cannot be called on const objects
};
```

**Best practices:**
- Mark methods `const` if they don't modify state
- Use `const` for parameters and return types
- Understand `const` position: `const T` (const data), `T* const` (const pointer), `const T*` (pointer to const data)

### Type Safety

**Use strong types to prevent errors:**

```cpp
using UserId = int;    // Weak: just an int, easy to confuse with other ints
class UserId { /* explicit */ };  // Strong: different type, prevents confusion
```

**Leverage the type system:**

```cpp
struct Meters { double value; };
struct Seconds { double value; };

double speed(Meters distance, Seconds time) {
    return distance.value / time.value;  // Returns meters per second
}

speed(Seconds(5), Meters(10));  // ERROR: type mismatch prevents unit confusion
```

---

## Ownership and Resource Management

### Transfer of Ownership

**Make ownership transfer explicit with move semantics:**

```cpp
class ResourcePool {
public:
    void add(std::unique_ptr<Resource> r) {
        resources_.push_back(std::move(r));  // Pool now owns the resource
    }
private:
    std::vector<std::unique_ptr<Resource>> resources_;
};

{
    auto r = std::make_unique<Resource>();
    pool.add(std::move(r));
    // r is now empty; pool owns the resource
}
```

### RAII for Transactions

**Use RAII to ensure transaction cleanup:**

```cpp
class Transaction {
public:
    explicit Transaction(Database& db) : db_(db) {
        db_.begin();
    }
    ~Transaction() {
        if (!committed_) db_.rollback();
    }
    void commit() {
        db_.commit();
        committed_ = true;
    }
private:
    Database& db_;
    bool committed_ = false;
};

{
    Transaction tx(db);
    db.insert(data);
    tx.commit();  // If not called, destructor rolls back
}
```

---

## Templates and Generic Programming

### Template Basics

**Templates enable type-safe generic programming:**

```cpp
template<typename T>
T max(T a, T b) {
    return a > b ? a : b;
}

max(3, 5);           // T = int
max(3.5, 2.5);       // T = double
max("a", "b");       // T = const char*, lexicographic comparison
```

### Concepts (C++20 and Later)

**Concepts constrain template parameters to improve error messages and enable overloading:**

```cpp
template<std::integral T>
T sum(const std::vector<T>& v) {
    T result = 0;
    for (auto val : v) result += val;
    return result;
}

sum(std::vector{1, 2, 3});           // OK: int is integral
sum(std::vector{1.5, 2.5});          // ERROR: double is not integral (clear error)
```

### Template Specialization

**Specialize templates for specific types:**

```cpp
template<typename T>
class Serializer {
public:
    std::string serialize(const T& obj) { /* generic */ }
};

template<>
class Serializer<bool> {
public:
    std::string serialize(bool obj) { return obj ? "true" : "false"; }
};
```

**When to specialize:** Performance-critical code, fundamentally different algorithms, special handling for specific types.

---

## Error Handling and Exception Safety

### Exceptions vs. Error Codes

**Use exceptions for exceptional conditions (errors that shouldn't happen in normal operation):**

```cpp
class File {
public:
    explicit File(const std::string& path) {
        fd_ = open(path.c_str(), O_RDONLY);
        if (fd_ < 0) throw std::runtime_error("Cannot open file: " + path);
    }
};
```

**Use error codes or `std::optional` for expected variations:**

```cpp
class Cache {
public:
    std::optional<Value> lookup(const Key& k) const {
        auto it = data_.find(k);
        return it != data_.end() ? std::optional(it->second) : std::nullopt;
    }
};

if (auto val = cache.lookup(key)) {
    use_value(*val);
} else {
    handle_miss();
}
```

### Exception Safety Levels

#### No-throw guarantee
**Function never throws:**

```cpp
class Pool {
public:
    ~Pool() noexcept {
        for (auto& item : items_) delete item;  // Must not throw
    }
};
```

#### Strong guarantee
**Either succeeds completely or has no effect:**

```cpp
class Database {
public:
    void update(const Record& r) {
        auto backup = find_record(r.id);  // Copy old data
        try {
            write_to_disk(r);
        } catch (...) {
            restore_record(backup);         // Restore on failure
            throw;
        }
    }
};
```

#### Basic guarantee
**Object remains in valid state, but may be changed:**

```cpp
std::vector<int> v = {1, 2, 3};
try {
    v.push_back(allocate_memory());  // May throw mid-operation
} catch (...) {
    // v is in a valid state, but contents may have changed
}
```

#### No guarantee
**Exceptions may leave the program in an inconsistent state (avoid).**

---

## STL Containers and Algorithms

### Containers

**Choose containers based on access patterns:**

| Container | Use Case | Access | Insert | Remove |
|-----------|----------|--------|--------|--------|
| `vector` | Sequential, dynamic | O(1) | O(n) amortized | O(n) |
| `deque` | Front and back access | O(1) | O(1) ends | O(1) ends |
| `list` | Frequent inserts/removes | O(n) | O(1) | O(1) |
| `map` | Sorted key-value | O(log n) | O(log n) | O(log n) |
| `unordered_map` | Fast lookup | O(1) avg | O(1) avg | O(1) avg |
| `set` | Sorted unique values | O(log n) | O(log n) | O(log n) |

**Default to `std::vector` for most cases:**

```cpp
std::vector<int> v;      // Contiguous, cache-friendly, cheap copies
v.push_back(1);
v.push_back(2);
// Avoid std::list unless you have frequent removals in the middle
```

### Algorithms

**Use STL algorithms instead of manual loops:**

```cpp
// BAD: manual loop
int sum = 0;
for (auto val : v) sum += val;

// GOOD: std::accumulate with intent
int sum = std::accumulate(v.begin(), v.end(), 0);

// GOOD: std::transform for conversion
std::vector<int> squares;
std::transform(v.begin(), v.end(), std::back_inserter(squares),
    [](int x) { return x * x; });
```

**Algorithms benefit from:**
- Clear intent (name says what happens)
- Optimized implementations (compiler often inlines)
- Composability (chain multiple algorithms)

---

## Concurrency and Synchronization

### Thread Safety

**Protect shared mutable state:**

```cpp
class Counter {
public:
    void increment() {
        std::lock_guard<std::mutex> lock(mutex_);  // Lock acquired
        ++count_;                                   // Protected access
    }                                               // Lock released here
    int value() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return count_;
    }
private:
    int count_ = 0;
    mutable std::mutex mutex_;
};
```

### Synchronization Primitives

**`std::mutex` and `std::lock_guard`:**
- `std::lock_guard` acquires lock in constructor, releases in destructor (RAII)
- Automatic unlock prevents deadlock and lock leaks

**`std::unique_lock` for more control:**

```cpp
std::unique_lock<std::mutex> lock(mutex_);
// Can manually unlock or move ownership
lock.unlock();
// Do something without holding lock
lock.lock();
```

**`std::atomic` for simple values:**

```cpp
class Flag {
private:
    std::atomic<bool> ready_{false};
public:
    void set_ready() { ready_.store(true, std::memory_order_release); }
    bool is_ready() const { return ready_.load(std::memory_order_acquire); }
};
```

### Avoiding Deadlock

- Acquire locks in consistent order
- Use RAII (never manually lock/unlock)
- Avoid holding locks during blocking operations
- Prefer atomics to mutexes when possible

---

## Performance Considerations

### Memory Layout

**Understand data layout for cache efficiency:**

```cpp
// BAD: poor cache locality
struct Point {
    double x, y, z;
    int id;           // Padding waste
    char type;        // More padding
};

// GOOD: larger fields first
struct Point {
    double x, y, z;
    int id;
    char type;        // No padding after
};
```

**Use `std::vector` for cache-friendly access:**

```cpp
std::vector<Point> points;  // Contiguous memory, good cache behavior
// vs
std::list<Point> points;    // Fragmented, poor cache behavior (avoid unless needed)
```

### Optimization Principles

**Profile before optimizing:**

```cpp
// Measure before making changes
#include <chrono>
auto start = std::chrono::high_resolution_clock::now();
// ... code to measure ...
auto end = std::chrono::high_resolution_clock::now();
auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
```

**Avoid premature optimization:**
- Readable code is more valuable than "optimized" code
- Optimize bottlenecks identified by profiling
- Measure the improvement of any optimization

### Compiler Optimizations

**Use optimization flags during compilation:**

```bash
g++ -O2 -Wall -std=c++17 code.cpp      # -O2: good balance
g++ -O3 -march=native code.cpp         # -O3: aggressive optimization
clang++ -flto code.cpp                 # LTO: link-time optimization
```

---

## Testing and Debugging

### Unit Testing

**Use a testing framework like Google Test:**

```cpp
#include <gtest/gtest.h>

class StackTest : public ::testing::Test {
protected:
    Stack<int> stack;
};

TEST_F(StackTest, PushPopEmpty) {
    stack.push(42);
    EXPECT_EQ(stack.pop(), 42);
    EXPECT_TRUE(stack.empty());
}
```

### Debugging Tools

**Use sanitizers to catch memory errors:**

```bash
g++ -fsanitize=address -fsanitize=undefined code.cpp  # Address + UB sanitizer
```

**Use debuggers effectively:**

```bash
gdb ./program
(gdb) break main
(gdb) run
(gdb) step
(gdb) print variable
(gdb) backtrace
```

---

## Common Mistakes and Anti-Patterns

### Memory Errors

**Dangling pointers:**

```cpp
// BAD
int* ptr;
{
    int x = 10;
    ptr = &x;  // Dangling pointer after scope
}
*ptr;  // Undefined behavior

// GOOD
std::unique_ptr<int> ptr;
{
    auto x = std::make_unique<int>(10);
    ptr = std::move(x);  // Transfer ownership
}  // x's memory is NOT deleted (ptr owns it now)
```

**Use-after-free:**

```cpp
// BAD
std::string* p = new std::string("hello");
delete p;
std::cout << *p;  // Use-after-free

// GOOD
std::unique_ptr<std::string> p = std::make_unique<std::string>("hello");
std::cout << *p;
// No manual delete needed
```

### Implicit Conversions

**Unexpected implicit conversions can hide bugs:**

```cpp
// BAD
class Size {
public:
    Size(int pixels) : pixels_(pixels) {}  // Implicit conversion
private:
    int pixels_;
};

Size s = 10;  // Silently converts int to Size

// GOOD
class Size {
public:
    explicit Size(int pixels) : pixels_(pixels) {}  // No implicit conversion
};

Size s = 10;  // ERROR: catches mistake at compile time
```

### Resource Leaks

**Always use RAII to manage resources:**

```cpp
// BAD
void process_file(const std::string& path) {
    FILE* f = fopen(path.c_str(), "r");
    parse(f);
    // If parse throws, fclose is never called (leak)
    fclose(f);
}

// GOOD
void process_file(const std::string& path) {
    std::ifstream f(path);
    parse(f);
    // Destructor closes file, even if exception thrown
}
```

### Unnecessarily Complex Code

**Avoid clever code that sacrifices readability:**

```cpp
// BAD: too clever
auto result = std::accumulate(v.begin(), v.end(), 0,
    [](int acc, int x) { return acc + (x % 2 ? x : 0); });

// GOOD: clear intent
int result = 0;
for (auto x : v) {
    if (x % 2) result += x;  // Add odd numbers
}
```

---

## Code Organization

### Header Files

**Guidelines for headers:**

```cpp
// file.h
#pragma once  // or include guards: #ifndef FILE_H #define FILE_H

#include <vector>
#include <memory>

class MyClass {
public:
    void public_method();
private:
    std::vector<int> data_;
};
```

### Separation of Concerns

**Organize code by responsibility:**

```
include/
  network/
    client.h
    server.h
  storage/
    database.h
    cache.h
src/
  network/
    client.cpp
    server.cpp
  storage/
    database.cpp
    cache.cpp
tests/
  network_test.cpp
  storage_test.cpp
```

### Forward Declarations

**Use forward declarations to reduce dependencies:**

```cpp
// header.h
class Database;  // Forward declaration

class Service {
    void process(Database& db);  // Can use reference without full definition
};
```

---

## Build Systems

### CMake

**Use CMake for portable, maintainable builds:**

```cmake
cmake_minimum_required(VERSION 3.16)
project(MyProject)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS_DEBUG "-g -fsanitize=address")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

add_executable(myapp src/main.cpp src/util.cpp)
target_include_directories(myapp PRIVATE include)

enable_testing()
add_test(NAME MyTests COMMAND myapp_test)
```

---

## References

- [C++ Reference](https://en.cppreference.com/) — Authoritative language reference
- [C++ Standard](https://isocpp.org/std/the-standard) — Official C++ standard
- [Cpp Core Guidelines](https://github.com/isocpp/CppCoreGuidelines) — Best practices by C++ standards committee
- [Modern C++](https://www.youtube.com/playlist?list=PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf) — Herb Sutter talks on modern C++
