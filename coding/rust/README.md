# Rust Programming Guide

**Location:** `rust/rust-guide.md`

**Target:** Modern Rust (1.70+)

**Key Concept:** Ownership and the borrow checker enable memory safety without garbage collection.

## When to Consult This Guide

Use this guide when:
- **Learning Rust:** understanding ownership, borrowing, lifetimes
- **Writing Rust code:** safe and efficient systems programming
- **Debugging borrow checker errors:** understanding why the compiler rejected your code
- **Designing with ownership:** organizing code around Rust's memory model
- **Reviewing Rust code:** assessing safety, efficiency, and idiomatic practices
- **Concurrency:** understanding thread safety and async Rust

## Key Principles

### The Borrow Checker

**Rust's compiler prevents entire classes of bugs:**

- **Use-after-free:** Accessing memory after it's freed (impossible in Rust)
- **Data races:** Multiple threads modifying data unsafely (caught at compile time)
- **Buffer overflows:** Accessing out-of-bounds memory (bounds-checked)

### Ownership Rules

**Every value has exactly one owner:**

```rust
let s1 = String::from("hello");
let s2 = s1;        // s2 takes ownership
// println!("{}", s1);  // ERROR: s1 no longer owns the string
```

**Borrow values to avoid moving:**

```rust
let s = String::from("hello");
let r1 = &s;    // Immutable borrow
let r2 = &s;    // Multiple readers OK
// let r3 = &mut s;  // ERROR: cannot mutably borrow while immutably borrowed
```

## Quick Reference

| Topic | Use Case |
|-------|----------|
| [Ownership and Borrowing](#ownership-and-borrowing) | Understanding Rust's memory model |
| [Lifetimes](#lifetimes) | Tracking reference validity |
| [Type System](#type-system-and-traits) | Using traits and generics |
| [Error Handling](#error-handling-with-result-and-option) | Using Result and Option |
| [Pattern Matching](#structs-enums-and-pattern-matching) | Powerful matching constructs |
| [Concurrency](#concurrency-and-async-rust) | Safe multithreading |
| [Performance](#performance-and-memory) | Understanding memory layout |

## Standards and Versions

- **Minimum supported:** Rust 1.70
- **Edition:** 2021 (use in Cargo.toml)
- **Build tool:** Cargo
- **Testing:** `cargo test`
- **Package registry:** crates.io

## Common Mistakes to Avoid

1. **Fighting the borrow checker** — Restructure code rather than force it
2. **Unnecessary clones** — Use references and iterators instead
3. **Overly generic code** — Concrete types often clearer than generic
4. **Raw pointers** — Use safe alternatives (smart pointers, references)
5. **Panicking on recoverable errors** — Use `Result` for error handling

## Why Rust's Compiler Is Strict

**The compiler prevents bugs that surface as crashes or security issues in C/C++:**

- Memory safety: No manual memory management
- Thread safety: Prevents data races at compile time
- Exhaustive checking: Pattern matching must handle all cases
- Strong types: Type confusion bugs are impossible

**Initial frustration with the borrow checker is normal.** Once you understand ownership, Rust feels less restrictive than C++ or Java.

## Related Documents

- See [`../CODING_PRINCIPLES.md`](../CODING_PRINCIPLES.md) for language-independent principles
- See [`../README.md`](../README.md) for navigation and when to consult each guide

## References

- [The Rust Programming Language](https://doc.rust-lang.org/book/) — Official book
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) — Practical examples
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) — Best practices
- [std library documentation](https://doc.rust-lang.org/std/) — Standard library

---

**Start with:** Read about ownership and borrowing. Everything else makes sense once you understand them.
