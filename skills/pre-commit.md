---
name: pre-commit
description: Comprehensive quality review before committing. Use before commits, at end of coding sessions, or when user mentions "pre-commit", "review changes", "quality check", or "ready to commit". Checks all guidelines and runs quality tools.
---

# Pre-Commit Quality Review

Complete quality check before committing or ending a coding session.

## Step 1: Select Scope

```json
{
  "questions": [
    {
      "question": "What should I review?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Staged changes", "description": "Review what's staged for commit (git diff --cached)"},
        {"label": "All uncommitted", "description": "Review all uncommitted changes (staged + unstaged)"},
        {"label": "Branch diff", "description": "Review all changes vs another branch"},
        {"label": "Specific files", "description": "I'll specify which files to review"}
      ]
    }
  ]
}
```

## Step 2: Load Guidelines

Read project guidelines if they exist:
- `.claude/guidelines/project-standards.md`
- `.claude/guidelines/type-driven-design.md`
- `.claude/guidelines/project-documentation-standards.md`
- `CLAUDE.md` for project context

## Step 3: Analyze Changes

```bash
# Show change statistics
echo "=== Staged Changes ==="
git diff --cached --stat 2>/dev/null || echo "No staged changes"

echo "=== Unstaged Changes ==="
git diff --stat 2>/dev/null || echo "No unstaged changes"

# Run quality tools
echo "=== Clippy ==="
cargo clippy --all-targets -- -D warnings 2>&1 | head -20

echo "=== Tests ==="
cargo test --quiet 2>&1 | tail -10

echo "=== Format Check ==="
cargo fmt --check 2>&1 || echo "Needs formatting"
```

## Step 4: Review Against Criteria

Check each file for:
- **Safety**: unwrap, unsafe, panics, error handling
- **Type safety**: primitive obsession, public fields, smart constructors
- **Documentation**: public items documented (but not over-documented)
- **Testing**: coverage for new code (happy path + errors)
- **Performance**: obvious inefficiencies
- **Code quality**: clippy suggestions, idiomatic patterns

## Step 5: Output Report

```
PRE-COMMIT REVIEW

Scope: [Staged changes | All uncommitted | Branch diff | files]
Files: N files, +X lines, -Y lines

CRITICAL ISSUES (must fix before commit)

[P1] src/auth.rs:89 - unwrap() in production code
  Code: let token = decode_token(value).unwrap();
  Fix: let token = decode_token(value)
           .map_err(|e| Error::InvalidToken(e.to_string()))?;
  Standard: project-standards.md -> Error Handling

[P1] src/db/query.rs:156 - unsafe block without SAFETY comment
  Fix: Add // SAFETY: comment explaining invariants
  Standard: project-standards.md -> Unsafe Code

WARNINGS (should fix soon)

[P2] src/api/users.rs:23 - Public function missing doc comment
  Fix: Add /// doc comment with # Errors section
  Standard: project-standards.md -> Documentation

[P2] src/api/users.rs:45 - No test for error case
  Fix: Add test for duplicate email scenario
  Standard: project-standards.md -> Testing

SUGGESTIONS (nice to have)

[P3] src/handlers/mod.rs - Consider splitting large module (450 lines)

[P3] src/parser.rs:67 - String allocations in loop could use &str

QUALITY CHECKS

Tests:      23 passed, 0 failed
Clippy:     Clean (no warnings)
Format:     Needs `cargo fmt`
Docs:       8/8 public items documented
Coverage:   2 new functions without tests

POSITIVE FEEDBACK

Good work on:
- Error handling in authentication module
- Comprehensive tests for user validation
- Clear documentation with examples

NEXT STEPS

Before committing:
1. [P1] Fix 2 critical issues
2. Run `cargo fmt`

Can commit, address soon:
3. [P2] Add missing tests
4. [P2] Improve documentation

Ready to commit?
  cargo fmt && cargo clippy && cargo test && git commit
```

If everything clean:
```
PRE-COMMIT REVIEW

Scope: [scope]
Files: N files

All checks passed:
- Tests: passing
- Clippy: clean
- Format: clean
- Documentation: complete

Ready to commit.
```

---

**Be thorough but constructive. Acknowledge good practices too.**
