# C++ Programming Guide

**Location:** `cpp/cpp-guide.md`

**Target:** Modern C++ (C++17 and later)

## When to Consult This Guide

Use this guide when:
- **Implementing C++ code:** features, design patterns, best practices
- **Debugging memory issues:** understanding ownership, smart pointers, RAII
- **Optimizing performance:** templates, STL, memory layout
- **Reviewing C++ code:** assessing design, exception safety, resource management
- **Learning:** teaching someone C++ concepts and idiomatic practices

## Quick Reference

### Core Topics

| Topic | Use Case |
|-------|----------|
| [Memory Management and RAII](#memory-management-and-raii) | Understanding safe memory handling |
| [Smart Pointers](#smart-pointers) | Using `unique_ptr`, `shared_ptr` safely |
| [Move Semantics](#move-semantics) | Avoiding expensive copies |
| [Type System and Const Correctness](#type-system-and-const-correctness) | Writing type-safe code |
| [Templates and Generic Programming](#templates-and-generic-programming) | Writing reusable code |
| [Error Handling](#error-handling-and-exception-safety) | Choosing exceptions vs. error codes |
| [Concurrency](#concurrency-and-synchronization) | Thread-safe programming |
| [Performance](#performance-considerations) | Profiling and optimization |

### Key Principles

- **RAII:** Every resource has an owner; destructors clean up automatically
- **Move semantics:** Transfer ownership instead of copying
- **Const correctness:** Mark methods and parameters `const` to express intent
- **Zero-cost abstractions:** High-level code compiles to efficient machine code
- **Minimal features:** Use the language feature appropriate to the problem

## Standards and Versions

- **Minimum supported:** C++17
- **Recommended:** C++20 or later for modern features
- **Build tools:** CMake, Ninja, or Make
- **Compilers:** GCC 10+, Clang 12+, MSVC 2019+

## Common Mistakes to Avoid

1. **Raw `new`/`delete`** — Use smart pointers instead
2. **Implicit conversions** — Mark constructors `explicit`
3. **Resource leaks** — Use RAII to ensure cleanup
4. **Unnecessary copies** — Use move semantics and references
5. **Fighting exception safety** — Design for it rather than around it

## Related Documents

- See [`../CODING_PRINCIPLES.md`](../CODING_PRINCIPLES.md) for language-independent principles
- See [`../README.md`](../README.md) for navigation and when to consult each guide

## References

- [C++ Reference](https://en.cppreference.com/) — Authoritative language reference
- [Cpp Core Guidelines](https://github.com/isocpp/CppCoreGuidelines) — Best practices
- [The Rust Book](https://doc.rust-lang.org/book/) — Comparison: how Rust enforces what C++ requires discipline for

---

**Start with:** Understand RAII and ownership. Everything else builds on this foundation.
