---
name: perf
description: Quick performance anti-pattern check (30 seconds)
---

# Performance Quick Scan

## Task
Flag obvious performance issues in recent changes.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md` → "⚡ Performance Guidelines"

This skill checks for performance anti-patterns defined in the project guidelines.

## Steps

1. **Find recent files:**
```bash
find src -name "*.rs" -mmin -30 -type f
```

2. **Scan for common anti-patterns:**
   - `.clone()` calls inside loops
   - String allocations in hot paths (`String::from`, `.to_string()` in loops)
   - Collecting iterators unnecessarily (`.collect()` then `.iter()`)
   - Blocking operations in async functions
   - `Vec::new()` with repeated `push()` (use `with_capacity`)
   - Repeated allocations that could be reused

3. **Output format:**
```
⚡ PERFORMANCE SCAN

Potential issues:

❌ src/api/handler.rs:89 - clone() inside loop
   Current:
   ```rust
   for item in items {
       let copy = item.clone();  // Unnecessary clone every iteration
       process(copy);
   }
   ```
   Better:
   ```rust
   for item in &items {  // Borrow instead
       process(item);
   }
   ```

❌ src/db/query.rs:123 - Inefficient iterator usage
   Current:
   ```rust
   let results = query.collect::<Vec<_>>();
   for item in results.iter() { ... }
   ```
   Better:
   ```rust
   for item in query { ... }  // Use iterator directly
   ```

Tips:
- Consider using `&str` instead of `String` in function parameters
- Use `Vec::with_capacity()` when size is known
- Profile with `cargo flamegraph` if unsure

✅ No obvious performance issues found
```

**Focus on easy-to-fix issues, not premature optimization.**
