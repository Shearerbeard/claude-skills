---
name: review
description: Comprehensive review before committing (2-3 minutes)
---

# Full Quality Review

## Task
Complete quality check before you commit or end your coding session.

## Steps

1. **Load guidelines:**
   - Read `.claude/guidelines/microsoft-rust.txt` (if exists)
   - Read `.claude/guidelines/project-standards.md` (if exists)
   - Read `CLAUDE.md` for project context

2. **Analyze changes:**
```bash
# Show uncommitted changes
echo "=== Staged Changes ==="
git diff --cached --stat 2>/dev/null || echo "No staged changes"

echo "=== Unstaged Changes ==="
git diff --stat 2>/dev/null || echo "No unstaged changes"

# Run quality tools
echo "=== Running Clippy ==="
cargo clippy --all-targets -- -D warnings 2>&1 | head -n 20

echo "=== Running Tests ==="
cargo test --quiet 2>&1 | tail -n 10

echo "=== Format Check ==="
cargo fmt --check 2>&1 || echo "Needs formatting"
```

3. **Review against all criteria:**
   - **Safety**: unwrap, unsafe, panics, error handling
   - **Documentation**: public items documented with proper sections
   - **Testing**: coverage for new code (happy path + errors)
   - **Performance**: obvious inefficiencies
   - **Error handling**: proper propagation with context
   - **Idiomatic Rust**: clippy suggestions, standard patterns

4. **Output comprehensive report:**
```
# 🔍 FULL QUALITY REVIEW - [timestamp]

## Summary
- Files modified: X
- Staged changes: +Y lines, -Z lines
- Critical issues: N (must fix)
- Warnings: M (should fix)
- Suggestions: K (nice to have)

## Critical Issues 🚨
[Must fix before committing]

1. **src/auth.rs:89** - Missing error handling for token validation
   ```rust
   // Current (bad):
   let token = decode_token(value).unwrap();
   
   // Fix:
   let token = decode_token(value)
       .map_err(|e| Error::InvalidToken(e.to_string()))?;
   ```
   Guideline: M-PANIC-IS-STOP - panics are program termination

2. **src/db/query.rs:156** - unsafe block without SAFETY comment
   ```rust
   // Add before unsafe block:
   // SAFETY: Buffer is guaranteed to be properly initialized
   // by check_buffer_size() above. Length is verified to be
   // within bounds.
   unsafe { ... }
   ```

## Warnings ⚠️
[Should fix soon]

1. **src/api/users.rs:23** - Function create_user missing doc comment
   Add:
   ```rust
   /// Creates a new user account.
   ///
   /// # Errors
   /// Returns `Error::DuplicateEmail` if email already exists.
   pub fn create_user(...)
   ```

2. **src/api/users.rs:45** - No test for error case
   Add test for duplicate email scenario

[... more warnings ...]

## Suggestions 💡
[Nice to have improvements]

1. **src/handlers/mod.rs** - Consider splitting large module
   Current: 450 lines
   Suggest: Split into handler_auth.rs, handler_users.rs

2. **Performance**: String allocations in loop (src/parser.rs:67)
   Not critical but could use `&str` for better performance

## Quality Checks Status

✅ Tests passing: 23 tests, 0 failures
✅ Clippy clean: No warnings
⚠️ Format needed: Run `cargo fmt`
✅ Documentation: 8/8 public items documented
⚠️ Test coverage: 2 new functions without tests

## Positive Feedback ✅

Great work on:
- Error handling in authentication module (proper context)
- Comprehensive tests for user validation
- Clear documentation with examples

## Next Steps

**Before committing:**
1. ❌ Fix 2 critical issues (unsafe, unwrap)
2. ❌ Run `cargo fmt`

**Can commit, but address soon:**
3. ⚠️ Add missing documentation
4. ⚠️ Write tests for error cases

**Optional improvements:**
5. 💡 Consider module refactoring
6. 💡 Performance optimization opportunities

---

**Ready to commit?** 
- Fix critical issues first
- Run: `cargo fmt && cargo clippy && cargo test`
- Then: `git commit -m "Your message"`
```

**Be thorough but constructive. Acknowledge good practices too.**
