---
name: async-check
description: Check async/await code for common pitfalls. Use when writing Tokio code, reviewing async functions, or when user mentions "async check", "tokio issues", "blocking in async", or "Send + Sync". Identifies async anti-patterns.
---

# Async Code Check

Scan async/await code for common pitfalls that cause deadlocks, performance issues, or compile errors.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md` -> Async Code Standards

## Step 1: Select Scope

```json
{
  "questions": [
    {
      "question": "What should I check for async issues?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Recent changes", "description": "Files modified in last 30 minutes"},
        {"label": "Branch diff", "description": "Files changed vs another branch"},
        {"label": "Specific file", "description": "I'll specify which file to check"},
        {"label": "Full codebase", "description": "Scan all async code in src/"}
      ]
    }
  ]
}
```

## Step 2: Scan for Anti-Patterns

### A. Blocking Operations in Async

```bash
# std::thread::sleep in async functions
rg "std::thread::sleep" [FILES] --type rust

# Sync file I/O in async
rg "std::fs::(read|write|open)" [FILES] --type rust

# Blocking network calls
rg "std::net::" [FILES] --type rust
```

### B. Lock Issues

```bash
# std::sync::Mutex in async (potential deadlock)
rg "std::sync::Mutex" [FILES] --type rust

# Mutex guard held across await
rg -U "\.lock\(\).*\n.*\.await" [FILES] --type rust
```

### C. Send + Sync Issues

```bash
# Rc in async (not Send)
rg "Rc::<" [FILES] --type rust

# RefCell in spawned tasks
rg "RefCell" [FILES] --type rust
```

### D. block_on Inside Async

```bash
# Deadlock risk
rg "block_on\(" [FILES] --type rust
rg "futures::executor::block_on" [FILES] --type rust
```

### E. Unhandled Spawned Tasks

```bash
# tokio::spawn without await/handling
rg "tokio::spawn\(" [FILES] -A3 --type rust | grep -v "\.await"
```

## Step 3: Context Analysis

For each finding, check the surrounding context:
- Is it actually inside an async function?
- Is there a valid reason (e.g., spawn_blocking)?
- Is the mutex guard dropped before await?

## Step 4: Output Format

```
ASYNC CODE CHECK

Scope: [Recent changes | Branch diff | file | Full]
Files checked: N
Async functions found: M

CRITICAL ISSUES (will cause problems)

[DEADLOCK] src/handlers/stream.rs:89 - block_on inside async
  Code: futures::executor::block_on(inner_async());
  Fix: Replace with: inner_async().await;
  Ref: project-standards.md -> Never Use block_on Inside Async

[BLOCKING] src/services/cache.rs:45 - std::thread::sleep in async
  Code: std::thread::sleep(Duration::from_secs(1));
  Fix: Use tokio::time::sleep(Duration::from_secs(1)).await;
  Ref: project-standards.md -> Never Block in Async Context

[DEADLOCK] src/state.rs:23 - std::sync::Mutex held across await
  Code:
    let guard = self.state.lock().unwrap();
    expensive_op().await;  // Still holding lock!
  Fix: Use tokio::sync::Mutex or drop guard before await
  Ref: project-standards.md -> Use Async-Aware Synchronization

WARNINGS (potential issues)

[SEND] src/processor.rs:67 - Rc used in async context
  Code: let rc = Rc::new(data);
  Issue: Rc is !Send, cannot be used with tokio::spawn
  Fix: Use Arc::new(data) instead
  Ref: project-standards.md -> Send + Sync Requirements

[UNHANDLED] src/background.rs:34 - Spawned task errors ignored
  Code: tokio::spawn(async { might_fail().await });
  Issue: Errors from spawned task are silently dropped
  Fix: Await the JoinHandle or spawn error logging
  Ref: project-standards.md -> Handle Spawned Task Errors

SUGGESTIONS (improvements)

[PERF] src/api/handler.rs:56 - Consider spawn_blocking for CPU work
  Code: let hash = compute_expensive_hash(&data);
  Suggestion: Use tokio::task::spawn_blocking for CPU-bound operations

[STYLE] src/db/query.rs:89 - Prefer tokio::sync::RwLock
  Code: Arc<std::sync::RwLock<Cache>>
  Suggestion: Use tokio::sync::RwLock for async-friendly read-write locks

SAFE PATTERNS FOUND

[OK] src/main.rs:12 - block_on at program boundary (correct usage)
[OK] src/compute.rs:34 - spawn_blocking for CPU work (correct)
[OK] src/state.rs:78 - tokio::sync::Mutex (correct)

SUMMARY

Critical issues: X (must fix)
Warnings: Y (should review)
Suggestions: Z (optional improvements)

Async code health: [GOOD | NEEDS ATTENTION | CRITICAL]
```

## Common Fixes Reference

### Blocking Sleep
```rust
// WRONG
std::thread::sleep(Duration::from_secs(1));

// CORRECT
tokio::time::sleep(Duration::from_secs(1)).await;
```

### Sync File I/O
```rust
// WRONG
let content = std::fs::read_to_string("file.txt")?;

// CORRECT
let content = tokio::fs::read_to_string("file.txt").await?;
```

### Mutex in Async
```rust
// WRONG
let guard = std::sync::Mutex::new(data);

// CORRECT
let guard = tokio::sync::Mutex::new(data);
```

### CPU-Bound Work
```rust
// WRONG (blocks runtime thread)
let result = expensive_computation();

// CORRECT
let result = tokio::task::spawn_blocking(|| {
    expensive_computation()
}).await?;
```

---

**Focus on critical issues first. Warnings may have valid reasons in context.**
