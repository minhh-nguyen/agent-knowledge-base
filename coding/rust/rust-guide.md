# Rust Programming Guide

Comprehensive guide to modern Rust (1.70+) for writing safe, concurrent, and efficient systems. Rust's type system and ownership model eliminate entire classes of bugs at compile time.

## Table of Contents

1. [Rust Philosophy and Core Concepts](#rust-philosophy-and-core-concepts)
2. [Ownership and Borrowing](#ownership-and-borrowing)
3. [Lifetimes](#lifetimes)
4. [Type System and Traits](#type-system-and-traits)
5. [Structs, Enums, and Pattern Matching](#structs-enums-and-pattern-matching)
6. [Error Handling with Result and Option](#error-handling-with-result-and-option)
7. [Collections and Iterators](#collections-and-iterators)
8. [Concurrency and Async Rust](#concurrency-and-async-rust)
9. [Smart Pointers and Interior Mutability](#smart-pointers-and-interior-mutability)
10. [Generics and Traits](#generics-and-traits)
11. [Performance and Memory](#performance-and-memory)
12. [Testing and Debugging](#testing-and-debugging)
13. [Common Mistakes and Anti-Patterns](#common-mistakes-and-anti-patterns)
14. [Project Organization](#project-organization)

---

## Rust Philosophy and Core Concepts

### Three Core Principles

**Memory Safety Without Garbage Collection** — The Rust compiler prevents data races, use-after-free errors, and buffer overflows at compile time.

**Zero-Cost Abstractions** — High-level constructs compile to efficient machine code without runtime overhead.

**Fearless Concurrency** — Rust's type system makes many concurrent programming bugs impossible.

### The Compiler Is Your Friend

**Rust's compiler is unusually strict because it catches bugs early:**

```rust
fn main() {
    let x = 5;
    let y = &x;
    let z = &x;    // Multiple readers: OK
    println!("{} {} {}", x, y, z);
}
```

**After moving, the original variable is inaccessible:**

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;        // s1's data moves to s2
    println!("{}", s1); // ERROR: s1 no longer owns the data
}
```

The compiler prevents use-after-move errors that would cause crashes or memory corruption in C/C++.

---

## Ownership and Borrowing

### Ownership Rules

**Every value has exactly one owner** — When the owner goes out of scope, the value is dropped (deallocated).

```rust
{
    let s = String::from("hello");  // s owns the string
    println!("{}", s);
}  // s goes out of scope; memory is freed automatically
```

### Moving

**Moving transfers ownership:**

```rust
fn take_ownership(s: String) {
    println!("{}", s);
}  // s goes out of scope and is dropped

fn main() {
    let s = String::from("hello");
    take_ownership(s);               // Ownership moves into function
    // println!("{}", s);            // ERROR: s no longer owns the string
}
```

**Copy types (small primitives) are copied automatically:**

```rust
fn main() {
    let x = 5;
    let y = x;                  // x is copied (not moved)
    println!("{} {}", x, y);    // Both x and y are valid
}
```

### Borrowing

**Borrow (reference) a value instead of taking ownership:**

```rust
fn borrow_string(s: &String) {
    println!("Borrowed: {}", s);
}  // Reference goes out of scope, but string is not dropped

fn main() {
    let s = String::from("hello");
    borrow_string(&s);              // Borrow a reference
    println!("Still own: {}", s);   // s is still valid
}
```

#### Immutable Borrowing

**Multiple readers are allowed simultaneously:**

```rust
fn main() {
    let s = String::from("hello");
    let r1 = &s;
    let r2 = &s;
    let r3 = &s;
    println!("{}, {}, {}", r1, r2, r3);  // All valid
}
```

#### Mutable Borrowing

**At most one mutable borrow can exist at a time:**

```rust
fn main() {
    let mut s = String::from("hello");
    let r1 = &mut s;    // Mutable borrow
    r1.push_str(" world");
    // let r2 = &mut s; // ERROR: cannot have two mutable borrows
    println!("{}", r1);
}
```

**You cannot borrow immutably if a mutable borrow exists:**

```rust
fn main() {
    let mut s = String::from("hello");
    let r1 = &mut s;
    // let r2 = &s;    // ERROR: cannot borrow immutably while mutably borrowed
    r1.push_str(" world");
    println!("{}", r1);
}
```

### Why Borrowing Rules Matter

The compiler prevents:
- Use-after-free: accessing memory after it's freed
- Double-free: freeing memory twice
- Data races: multiple threads modifying data simultaneously

---

## Lifetimes

### Lifetime Annotations

**Lifetimes track how long references are valid:**

```rust
// This function's return reference must be valid as long as both inputs
fn longest<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() { s1 } else { s2 }
}

fn main() {
    let s1 = String::from("short");
    let s2 = String::from("very long string");
    let result = longest(&s1, &s2);
    println!("Longest: {}", result);  // Result is valid while s1 and s2 are
}
```

### Lifetime Elision

**Rust infers lifetimes in common cases (you don't need to annotate):**

```rust
// Lifetime annotations not needed here
fn first(s: &str) -> &str {
    &s[0..1]
}

// Rust infers: fn first<'a>(s: &'a str) -> &'a str
```

### Struct Lifetimes

**Structs containing references need lifetime annotations:**

```rust
struct Document<'a> {
    title: &'a str,
    body: &'a str,
}

impl<'a> Document<'a> {
    fn summary(&self) -> &'a str {
        self.title
    }
}

fn main() {
    let title = String::from("My Document");
    let body = String::from("Content here");
    let doc = Document { title: &title, body: &body };
    println!("{}", doc.summary());
}
```

---

## Type System and Traits

### Traits

**Traits define shared behavior:**

```rust
trait Reader {
    fn read(&mut self) -> std::io::Result<Vec<u8>>;
    fn close(&mut self) -> std::io::Result<()>;
}

struct FileReader {
    path: String,
}

impl Reader for FileReader {
    fn read(&mut self) -> std::io::Result<Vec<u8>> {
        std::fs::read(&self.path)
    }

    fn close(&mut self) -> std::io::Result<()> {
        // Close file logic
        Ok(())
    }
}
```

### Trait Bounds

**Use trait bounds to constrain generic types:**

```rust
use std::fmt::Display;

fn print_it<T: Display>(val: T) {
    println!("Value: {}", val);
}

fn main() {
    print_it(42);           // OK: i32 implements Display
    print_it("hello");      // OK: &str implements Display
    // print_it(vec![1, 2]); // ERROR: Vec doesn't implement Display
}
```

### Associated Types

**Traits can have associated types:**

```rust
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}

impl Iterator for CountUp {
    type Item = u32;
    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;
        Some(self.count)
    }
}
```

---

## Structs, Enums, and Pattern Matching

### Structs

**Named collections of related data:**

```rust
#[derive(Clone, Debug)]
struct Person {
    name: String,
    age: u32,
    email: String,
}

impl Person {
    fn new(name: String, age: u32) -> Self {
        Person {
            name,
            age,
            email: String::new(),
        }
    }

    fn is_adult(&self) -> bool {
        self.age >= 18
    }
}

fn main() {
    let person = Person::new(String::from("Alice"), 30);
    println!("Is adult: {}", person.is_adult());
}
```

### Enums

**Types with multiple variants:**

```rust
enum Status {
    Pending,
    Running(u32),              // Variant with data
    Complete { result: i32 },  // Named fields
    Failed(String),
}

fn process_status(status: Status) {
    match status {
        Status::Pending => println!("Waiting to start"),
        Status::Running(id) => println!("Running task {}", id),
        Status::Complete { result } => println!("Completed with result: {}", result),
        Status::Failed(msg) => println!("Failed: {}", msg),
    }
}
```

### Pattern Matching

**Pattern matching is powerful and exhaustive:**

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}

fn main() {
    let result: Result<i32, String> = Ok(42);

    match result {
        Ok(value) => println!("Success: {}", value),
        Err(e) => println!("Error: {}", e),
    }  // Compiler ensures both cases are handled

    // Using if let for single pattern
    if let Ok(value) = result {
        println!("Got value: {}", value);
    }
}
```

---

## Error Handling with Result and Option

### Result for Recoverable Errors

**`Result<T, E>` represents success or error:**

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;  // ? propagates error
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn main() {
    match read_file("data.txt") {
        Ok(contents) => println!("File contents: {}", contents),
        Err(e) => eprintln!("Error reading file: {}", e),
    }
}
```

### Option for Optional Values

**`Option<T>` represents presence or absence:**

```rust
fn find_user(id: u32, users: &[User]) -> Option<&User> {
    users.iter().find(|u| u.id == id)
}

fn main() {
    if let Some(user) = find_user(42, &users) {
        println!("Found user: {}", user.name);
    } else {
        println!("User not found");
    }
}
```

### Error Propagation

**Use `?` operator to propagate errors:**

```rust
fn process_data(path: &str) -> Result<u32, Box<dyn std::error::Error>> {
    let contents = std::fs::read_to_string(path)?;  // If error, return early
    let count: u32 = contents.lines().count() as u32;
    Ok(count)
}
```

---

## Collections and Iterators

### Common Collections

**Choose containers by use case:**

```rust
// Vec: dynamic array
let mut v: Vec<i32> = vec![1, 2, 3];
v.push(4);
println!("{:?}", v[0]);

// HashMap: key-value store
use std::collections::HashMap;
let mut map = HashMap::new();
map.insert("key", "value");
map.get("key");

// HashSet: unique values
use std::collections::HashSet;
let mut set = HashSet::new();
set.insert(1);
set.insert(2);
set.contains(&1);
```

### Iterators

**Iterators are lazy and composable:**

```rust
fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    // Map: transform each element
    let squared: Vec<_> = numbers.iter().map(|x| x * x).collect();

    // Filter: keep matching elements
    let evens: Vec<_> = numbers.iter().filter(|x| *x % 2 == 0).collect();

    // Chain: combine multiple operations
    let result: Vec<_> = numbers
        .iter()
        .filter(|x| *x % 2 == 0)
        .map(|x| x * 2)
        .collect();
}
```

**Iterating efficiently:**

```rust
fn main() {
    let v = vec![1, 2, 3];

    // Borrowing immutably
    for item in &v {
        println!("{}", item);
    }

    // Moving (consumes the vector)
    for item in v {
        println!("{}", item);
    }
}
```

---

## Concurrency and Async Rust

### Threads

**Spawn threads for parallel work:**

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("Hello from a thread");
    });

    handle.join().unwrap();  // Wait for thread to finish
}
```

**Share data between threads with `Arc` and `Mutex`:**

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", counter.lock().unwrap());
}
```

### Async/Await

**Async for concurrent I/O without threads:**

```rust
async fn fetch_url(url: &str) -> String {
    // Simulated async I/O
    format!("Content from {}", url)
}

async fn main() {
    let url1 = fetch_url("http://a.com");
    let url2 = fetch_url("http://b.com");

    // Run concurrently
    futures::join!(url1, url2);
}
```

---

## Smart Pointers and Interior Mutability

### Box for Heap Allocation

**`Box<T>` for single ownership on the heap:**

```rust
fn main() {
    let b = Box::new(5);  // Allocates on heap
    println!("b = {}", b);
}  // b is freed when it goes out of scope
```

### Rc for Reference Counting

**`Rc<T>` for multiple ownership (single-threaded):**

```rust
use std::rc::Rc;

fn main() {
    let a = Rc::new(5);
    let b = Rc::clone(&a);  // Increment reference count
    let c = Rc::clone(&a);
    println!("Reference count: {}", Rc::strong_count(&a));  // 3
}
```

### Interior Mutability

**Use `Cell` or `RefCell` to mutate data behind an immutable reference:**

```rust
use std::cell::RefCell;

struct Counter {
    count: RefCell<u32>,
}

impl Counter {
    fn increment(&self) {
        *self.count.borrow_mut() += 1;  // Mutate through shared reference
    }

    fn get(&self) -> u32 {
        *self.count.borrow()
    }
}
```

---

## Generics and Traits

### Generic Functions

**Functions that work with many types:**

```rust
fn max<T: PartialOrd>(a: T, b: T) -> T {
    if a > b { a } else { b }
}

fn main() {
    println!("{}", max(3, 5));           // T = i32
    println!("{}", max(3.5, 2.5));       // T = f64
}
```

### Generic Structs

```rust
struct Pair<T> {
    first: T,
    second: T,
}

impl<T: PartialOrd + Copy> Pair<T> {
    fn max(&self) -> T {
        if self.first > self.second {
            self.first
        } else {
            self.second
        }
    }
}
```

---

## Performance and Memory

### Zero-Cost Abstractions

**High-level constructs compile to efficient code:**

```rust
// Abstractions don't add runtime cost
let v = vec![1, 2, 3];
let result: i32 = v.iter().map(|x| x * 2).sum();

// Compiles to efficient machine code (similar to manual loop)
```

### Memory Layout

**Understand how data is laid out in memory:**

```rust
#[repr(C)]
struct Packed {
    a: u8,
    b: u32,  // May have padding
    c: u8,
}

#[repr(C, packed)]
struct Tight {
    a: u8,
    b: u32,
    c: u8,
}
```

### Stack vs. Heap

**Small, fixed-size data goes on the stack; dynamically-sized data goes on the heap:**

```rust
let x = 42;              // Stack: fast
let v = vec![1, 2, 3];   // Heap: flexible but slower access
```

---

## Testing and Debugging

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 2), 4);
    }

    #[test]
    #[should_panic]
    fn test_panic() {
        panic!("This test expects a panic");
    }

    #[test]
    fn test_result() -> Result<(), String> {
        if 2 + 2 == 4 {
            Ok(())
        } else {
            Err(String::from("Math is broken"))
        }
    }
}

fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

**Run tests:**

```bash
cargo test                   # Run all tests
cargo test -- --nocapture   # Print output from passing tests
```

---

## Common Mistakes and Anti-Patterns

### Unnecessary Clones

```rust
// BAD: unnecessary clone
fn process(v: &Vec<i32>) {
    let v_copy = v.clone();
    for x in v_copy { println!("{}", x); }
}

// GOOD: use reference or iterator
fn process(v: &[i32]) {
    for x in v { println!("{}", x); }
}
```

### Fighting the Borrow Checker

**When the compiler rejects your code, restructure rather than add complexity:**

```rust
// BAD: trying to work around borrow checker
let mut data = vec![1, 2, 3];
let r1 = &data[0];
data.push(4);           // ERROR: cannot borrow mutably
// println!("{}", r1); // r1 is no longer valid anyway

// GOOD: reorganize code
let r1 = {
    let data = vec![1, 2, 3];
    data[0]
};
// Use r1 here, data is gone
```

### Generic Over-Engineering

```rust
// BAD: overly generic
fn process<T: Trait1 + Trait2 + Trait3>(x: T) -> T {
    // Generic complexity without clear benefit
}

// GOOD: concrete type or necessary genericity
fn process(x: ConcreteType) -> ConcreteType {
    // Clear and maintainable
}
```

---

## Project Organization

### Cargo Project Structure

```
myproject/
├── Cargo.toml
├── src/
│   ├── lib.rs           # Library root
│   ├── main.rs          # Binary root
│   ├── module1.rs       # Module
│   └── module2/
│       ├── mod.rs       # Submodule root
│       └── submod.rs    # Submodule
├── tests/               # Integration tests
│   └── integration_test.rs
└── examples/            # Example binaries
    └── example.rs
```

### Cargo.toml

```toml
[package]
name = "myproject"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }

[dev-dependencies]
criterion = "0.5"
```

---

## References

- [The Rust Programming Language](https://doc.rust-lang.org/book/) — Official book
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) — Practical examples
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) — Best practices
- [std library documentation](https://doc.rust-lang.org/std/) — Standard library reference
