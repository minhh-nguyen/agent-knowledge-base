# Rust Guide

Modern Rust (1.70+, edition 2021) for safe, concurrent, efficient systems code. The borrow checker
replaces a garbage collector: memory safety, no data races, no use-after-free — all checked at compile time.

Consult for: ownership/lifetime reasoning, borrow-checker errors, idiomatic API design, concurrency,
review, teaching.

## Contents

- [Core Ideas](#core-ideas)
- [Ownership and Borrowing](#ownership-and-borrowing)
- [Lifetimes](#lifetimes)
- [Traits and Generics](#traits-and-generics)
- [Structs, Enums, Pattern Matching](#structs-enums-pattern-matching)
- [Error Handling](#error-handling)
- [Collections and Iterators](#collections-and-iterators)
- [Concurrency and Async](#concurrency-and-async)
- [Smart Pointers](#smart-pointers)
- [Performance and Memory](#performance-and-memory)
- [Testing and Debugging](#testing-and-debugging)
- [Anti-Patterns](#anti-patterns)
- [Project Layout](#project-layout)

## Core Ideas

- **Memory safety without GC.** Compile-time ownership and borrowing, no runtime cost.
- **Zero-cost abstractions.** Iterators, generics, and traits compile to the same code as hand-written loops.
- **Fearless concurrency.** `Send`/`Sync` make data races unrepresentable.
- **Exhaustiveness.** `match` must cover every case; adding an enum variant breaks compilation instead of silently misbehaving.

The compiler is strict on purpose: fix the design it points at instead of working around it.

## Ownership and Borrowing

Three rules: every value has one owner; when the owner goes out of scope the value is dropped; ownership
moves on assignment or by-value passing. Small `Copy` types (`i32`, `bool`, `&T`, tuples of those) copy instead.

```rust
fn take(s: String) { println!("{s}"); }   // takes ownership, drops at end

let s = String::from("hello");
take(s);
// println!("{s}");   // error: value moved

let n = 5;
let m = n;            // Copy: both usable
```

Borrow instead of moving when the callee only reads:

```rust
fn len(s: &str) -> usize { s.len() }

let s = String::from("hello");
let r1 = &s;              // any number of shared (immutable) borrows
let r2 = &s;
println!("{} {}", r1, r2);

let mut t = String::from("hi");
let w = &mut t;           // exactly one mutable borrow, no shared borrows at the same time
w.push_str(" there");
```

Borrows end at their last use (NLL), so this is fine:

```rust
let mut v = vec![1, 2, 3];
let first = v[0];
v.push(4);               // no active borrow of v any more
println!("{first}");
```

The rules prevent use-after-free, double-free, iterator invalidation, and data races.

## Lifetimes

A lifetime is the region in which a reference is valid. Annotate only when the compiler cannot infer how
inputs and outputs relate.

```rust
fn longest<'a>(a: &'a str, b: &'a str) -> &'a str {   // result lives as long as both inputs
    if a.len() >= b.len() { a } else { b }
}

fn first_word(s: &str) -> &str {                     // elision: output borrows from `s`
    s.split_whitespace().next().unwrap_or("")
}

struct Document<'a> {                                // struct holding a reference
    title: &'a str,
}
```

Elision rules: one input reference → output gets its lifetime; `&self` → output gets `self`'s lifetime.
Prefer owned data (`String`, `Vec<T>`, `'static`) over threaded lifetimes when the plumbing dominates.

## Traits and Generics

```rust
trait Reader {
    type Item;                                       // associated type: one impl per type
    fn read(&mut self) -> Option<Self::Item>;
}

fn print_all<T: std::fmt::Display>(items: &[T]) {    // trait bound
    for item in items { println!("{item}"); }
}

fn max<T: PartialOrd>(a: T, b: T) -> T { if a >= b { a } else { b } }
```

- `impl Trait` in argument position for simple bounds; `<T: Trait>` when the type is named twice or needs a turbofish.
- `dyn Trait` (boxed or by reference) when you need heterogeneous collections or runtime dispatch.
- Derive common traits (`Debug`, `Clone`, `PartialEq`, `Default`) rather than hand-writing them.
- Bound only what the body uses; extra bounds make APIs harder to call.

## Structs, Enums, Pattern Matching

```rust
#[derive(Debug, Clone, PartialEq)]
struct Person { name: String, age: u32 }

impl Person {
    fn new(name: impl Into<String>, age: u32) -> Self {
        Self { name: name.into(), age }
    }
    fn is_adult(&self) -> bool { self.age >= 18 }
}

enum Status {
    Pending,
    Running { task_id: u32 },                        // struct variant
    Failed(String),                                  // tuple variant
}

fn label(s: &Status) -> &'static str {
    match s {
        Status::Pending => "pending",
        Status::Running { task_id } if *task_id == 0 => "starting",
        Status::Running { .. } => "running",
        Status::Failed(msg) => { eprintln!("{msg}"); "failed" }
    }
}
```

Enums with data replace boolean flags, stringly-typed states, and nullable fields. `if let`/`let else`
for one-pattern cases; `matches!` for predicates.

## Error Handling

- `Result<T, E>` for recoverable failure; `Option<T>` for absence.
- `?` propagates, converting via `From`; prefer a typed error enum with `thiserror`, `anyhow` at application boundaries.
- `panic!`/`unwrap` only for bugs and invariants that cannot be violated; never for user input.

```rust
fn read_config(path: &Path) -> Result<Config, ConfigError> {
    let text = std::fs::read_to_string(path)?;       // io::Error -> ConfigError via From
    let cfg = toml::from_str(&text)?;
    Ok(cfg)
}

fn find_user<'a>(id: u32, users: &'a [User]) -> Option<&'a User> {
    users.iter().find(|u| u.id == id)
}
```

Avoid `.unwrap()` in library code; in tests and prototypes it is fine.

## Collections and Iterators

`Vec<T>` (dynamic array), `HashMap<K, V>` / `HashSet<T>` (hashed), `BTreeMap`/`BTreeSet` (ordered),
`VecDeque<T>` (both ends), `String`/`&str` (owned/borrowed text).

```rust
let mut v = vec![1, 2, 3, 4, 5];
let doubled: Vec<i32> = v.iter().map(|x| x * 2).collect();
let evens: Vec<&i32> = v.iter().filter(|x| *x % 2 == 0).collect();
let total: i32 = v.iter().sum();
```

Iterators are lazy and fuse into a single loop. `iter()` borrows, `iter_mut()` mutably borrows,
`into_iter()` consumes. Use `entry` for map insert-or-update; `with_capacity` when the size is known.

## Concurrency and Async

```rust
use std::sync::{Arc, Mutex};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let handles: Vec<_> = (0..8).map(|_| {
    let counter = Arc::clone(&counter);
    thread::spawn(move || *counter.lock().unwrap() += 1)
}).collect();
for h in handles { h.join().unwrap(); }
```

- `Arc<T>` = shared ownership across threads; `Rc<T>` is single-threaded only.
- `Mutex`/`RwLock` guard data (not code); `atomic` types for simple counters and flags.
- Channels (`std::sync::mpsc`, `crossbeam`) often beat shared state for pipelines.
- `Send` = safe to transfer across threads, `Sync` = safe to share by reference; the compiler derives the rest.

Async (`tokio` or `async-std` runtime):

```rust
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let (a, b) = tokio::join!(fetch("http://a"), fetch("http://b"));   // concurrent, not parallel
    println!("{a} {b}");
    Ok(())
}
```

Don't hold a `MutexGuard` or other non-`Send` value across `.await`; use `tokio::sync::Mutex` when a lock
must span awaits. CPU-heavy work goes to `spawn_blocking` / `rayon`.

## Smart Pointers

| Type | Use |
|------|-----|
| `Box<T>` | Single owner on the heap; recursive types; trait objects |
| `Rc<T>` / `Arc<T>` | Shared ownership (single-threaded / thread-safe) |
| `RefCell<T>` / `Mutex<T>` | Interior mutability behind a shared reference |
| `Cow<'a, T>` | Borrow when possible, allocate on write |

```rust
use std::cell::RefCell;

struct Counter { count: RefCell<u32> }

impl Counter {
    fn increment(&self) { *self.count.borrow_mut() += 1; }   // runtime-checked borrow
    fn get(&self) -> u32 { *self.count.borrow() }
}
```

`RefCell` panics on conflicting borrows at runtime; reach for it only when the borrow structure cannot be
expressed statically.

## Performance and Memory

- Stack for fixed-size values, heap for growable/owned data; `Box` and `Vec` add an indirection.
- `#[repr(C)]` for FFI and layout guarantees; `#[repr(C, packed)]` only when you truly need no padding.
- `&[T]` parameters accept both arrays and `Vec` — avoid `&Vec<T>`.
- Iterators over index loops: bounds checks vanish and intent is clearer.
- Profile with `cargo flamegraph`, `perf`, or `criterion` before optimizing; use `--release` for any measurement.
- Prefer `&str`/slices, avoid needless `clone()`, reuse allocations, and consider `SmallVec`/`ArrayVec` for tiny collections.

## Testing and Debugging

```rust
fn add(a: i32, b: i32) -> i32 { a + b }

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn adds() { assert_eq!(add(2, 2), 4); }

    #[test]
    #[should_panic(expected = "overflow")]
    fn panics_on_overflow() { panic!("overflow"); }

    #[test]
    fn fallible() -> Result<(), String> {
        assert_eq!(add(2, 2), 4);
        Ok(())
    }
}
```

```bash
cargo test --all-features
cargo clippy -- -D warnings
cargo fmt --check
cargo miri test          # UB detection in unsafe code
```

`dbg!(x)` for quick inspection; `RUST_BACKTRACE=1` for panics.

## Anti-Patterns

| Anti-pattern | Fix |
|--------------|-----|
| `.clone()` to silence the borrow checker | Borrow, restructure, or split the function |
| Fighting the borrow checker with `unsafe` | Redesign ownership; `unsafe` needs a documented invariant |
| `Rc<RefCell<T>>` webs for everything | Plain ownership; `Arc`/locks only when sharing is real |
| `unwrap()` on external input | `?` with a typed error |
| Over-generic APIs with many bounds | Concrete types until a second use case exists |
| `String` everywhere | `&str` for parameters, `impl Into<String>` / `Cow` where flexible |
| `&Vec<T>` parameters | `&[T]` |
| Giant `match` with duplicated arms | Extract methods; use enum methods |
| Blocking work inside async | `spawn_blocking`, separate runtime, or sync code |
| Ignoring `RUSTFLAGS`/release for benchmarks | Always measure `--release` |

## Project Layout

```
myproject/
├── Cargo.toml
├── src/{lib.rs,main.rs,config.rs,store/mod.rs}
├── tests/integration.rs
├── benches/
└── examples/
```

```toml
[package]
name = "myproject"
version = "0.1.0"
edition = "2021"
rust-version = "1.70"

[dependencies]
serde = { version = "1", features = ["derive"] }
thiserror = "1"

[dev-dependencies]
criterion = "0.5"
```

`lib.rs` holds reusable logic (unit tests inline), `main.rs` is a thin binary wrapper, `tests/` holds
integration tests that use only the public API.

## References

- [The Rust Programming Language](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [std documentation](https://doc.rust-lang.org/std/)

Related: [`principles.md`](principles.md), [`code-review.md`](code-review.md), [`../SKILL.md`](../SKILL.md)
