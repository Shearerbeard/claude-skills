---
name: standards
description: Quick code standards check (30 seconds)
---

# Code Standards Check

## Task
Check recently modified Rust files for violations of project coding standards.

## Steps

1. **Find recent changes:**
```bash
# Get files modified in last 30 minutes
find src -name "*.rs" -mmin -30 -type f 2>/dev/null || echo "No recent changes"
```

2. **Check for common violations:**
   - `unwrap()` or `expect()` calls in production code
   - `unsafe` blocks without SAFETY comments
   - `panic!()` outside of unreachable code paths
   - Missing error propagation (should use `?` operator)
   - Missing doc comments on public items
   - Non-idiomatic patterns
   - Emojis in source code, logs, or error messages

3. **Run clippy for additional lints:**
```bash
cargo clippy --quiet -- -D warnings 2>&1 | grep -E "(warning|error)" || echo "Clippy clean"
```

4. **Output format:**
```
🔍 CODE STANDARDS CHECK

Files checked: X

⚠️ STANDARDS VIOLATIONS:

❌ src/api/auth.rs:42 - unwrap() call
   Violates: Error handling standard
   Fix: Replace with .ok_or(Error::NotFound)? or .context("message")?
   
❌ src/db/query.rs:156 - unsafe block missing SAFETY comment
   Violates: Unsafe code documentation standard
   Fix: Add comment explaining why unsafe is necessary and what invariants hold

❌ src/api/users.rs:23 - Public function missing doc comment
   Violates: Documentation standard
   Fix: Add /// doc comment with description and examples

❌ src/api/handler.rs:67 - Emoji in production log
   Code: tracing::info!("✅ Request processed successfully");
   Violates: Emoji usage standard
   Fix: Remove emoji - use plain text: tracing::info!("Request processed successfully");

✅ No standards violations found.
```

## Standards Checked

**Source:** `.claude/guidelines/project-standards.md`

This skill implements checks from the project standards guideline:

### Error Handling Standards
**Guideline:** `project-standards.md` Section 1 & 2
- No `unwrap()` or `expect()` in production code (tests are OK)
- Use `?` operator for error propagation
- Provide context with errors using `.context()`

### Unsafe Code Standards
**Guideline:** `project-standards.md` Section 2
- Every `unsafe` block must have a SAFETY comment
- SAFETY comment must explain:
  - Why unsafe is necessary
  - What invariants are maintained
  - Why it's safe in this context

### Documentation Standards
**Guideline:** `project-standards.md` Section 3 & 9
- All public functions have doc comments (`///`)
- Functions returning `Result` have `# Errors` section
- Functions that can panic have `# Panics` section
- Complex functions have `# Examples` section

### Code Quality Standards
**Guideline:** `project-standards.md` Section 6 & 8
- No `panic!()` in production code
- No hardcoded magic values without explanation
- Follow clippy recommendations
- Use idiomatic Rust patterns

### Emoji Usage Standards
**Guideline:** `project-standards.md` Emoji Usage Standards section
- No emojis in source code (comments, identifiers)
- No emojis in production logs (tracing::info!, tracing::error!, println!)
- No emojis in error messages
- No emojis in API responses
- Exception: Documentation files (README.md, etc.)

## Best Practices

**Only report actual violations with:**
- Specific file and line number
- Which standard is violated
- Concrete fix with code example
- Reference to project-standards.md if applicable

**If everything is clean:**
Just say "✅ No standards violations found in recent changes."

**Be helpful, not pedantic:**
Focus on issues that actually matter for maintainability and correctness.
