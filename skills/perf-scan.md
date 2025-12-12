---
name: perf-scan
description: Quick performance anti-pattern scan. Use after writing code, when optimizing, or when user mentions "perf scan", "performance check", "slow code", "clone abuse", or "optimization". Flags obvious inefficiencies.
---

# Performance Quick Scan

Flag obvious performance issues in code.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md` -> Performance Guidelines

## Step 1: Select Scope

```json
{
  "questions": [
    {
      "question": "What should I scan for performance issues?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Recent changes", "description": "Files modified in last 30 minutes"},
        {"label": "Branch diff", "description": "Files changed vs another branch"},
        {"label": "Specific file", "description": "I'll specify which file to check"},
        {"label": "Full codebase", "description": "Scan entire src/ directory"}
      ]
    }
  ]
}
```

## Step 2: Scan for Anti-Patterns

Common performance issues to check:

### A. Clones in Loops
```bash
rg "for .* in .+" [FILES] -A5 | grep -E "\.clone\(\)"
```

### B. String Allocations in Hot Paths
```bash
rg "(String::from|\.to_string\(\)|format!)" [FILES] --type rust
```

### C. Inefficient Iterator Usage
```bash
rg "\.collect::<Vec" [FILES] -A2 | grep "\.iter\(\)"
```

### D. Missing Pre-allocation
```bash
rg "Vec::new\(\)" [FILES] -A5 | grep "\.push\("
```

## Step 3: Output Format

```
PERFORMANCE SCAN

Scope: [Recent changes | Branch diff | file | Full]
Files checked: N

POTENTIAL ISSUES

[PERF] src/api/handler.rs:89 - clone() inside loop
  Code:
    for item in items {
        let copy = item.clone();
        process(copy);
    }
  Fix:
    for item in &items {
        process(item);
    }

[PERF] src/db/query.rs:123 - Inefficient iterator usage
  Code:
    let results = query.collect::<Vec<_>>();
    for item in results.iter() { ... }
  Fix:
    for item in query { ... }

[PERF] src/parser.rs:45 - Vec without pre-allocation
  Code:
    let mut items = Vec::new();
    for i in 0..known_size { items.push(i); }
  Fix:
    let mut items = Vec::with_capacity(known_size);

TIPS

- Use `&str` instead of `String` in function parameters
- Use `Vec::with_capacity()` when size is known
- Avoid `.clone()` when borrowing is possible
- Profile with `cargo flamegraph` if unsure

No obvious performance issues found.
```

---

**Focus on easy-to-fix issues, not premature optimization.**
