---
name: safety
description: Quick safety check for recent changes (30 seconds)
---

# Quick Safety Review

## Task
Check the most recently modified Rust files for critical safety issues.

## Steps

1. **Find recent changes:**
```bash
# Get files modified in last 30 minutes
find src -name "*.rs" -mmin -30 -type f 2>/dev/null || echo "No recent changes"
```

2. **For each file, check for:**
   - `unwrap()` or `expect()` calls (flag all occurrences)
   - `unsafe` blocks without SAFETY comments
   - `panic!()` outside of unreachable code paths
   - Missing error propagation (? operator usage)

3. **Run clippy for safety lints:**
```bash
cargo clippy --quiet -- -D warnings 2>&1 | grep -E "(warning|error)" || echo "Clippy clean"
```

4. **Output format:**
```
🔍 SAFETY CHECK - [timestamp]

Files checked: X

⚠️ ISSUES FOUND:
- src/api/auth.rs:42 - unwrap() call
  Fix: Replace with .ok_or(Error::NotFound)? or .context("message")?
  
- src/db/query.rs:156 - unsafe block missing SAFETY comment
  Fix: Add comment explaining why unsafe is necessary

✅ No issues found.
```

**Only report actual issues. If everything looks good, just say "✅ No safety issues found in recent changes."**

**Be specific with fixes - show actual code examples.**
