---
name: test-coverage
description: Verify test coverage for new/modified functions. Use after writing code, before commits, or when user mentions "test coverage", "missing tests", "check coverage", or "untested code". Identifies functions without tests.
---

# Test Coverage Check

Ensure new/modified public functions have adequate tests.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md` -> Testing Standards

## Step 1: Select Scope

```json
{
  "questions": [
    {
      "question": "What should I check for test coverage?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Recent changes", "description": "Files modified in last 30 minutes"},
        {"label": "Last commit", "description": "Files changed in HEAD~1"},
        {"label": "Branch diff", "description": "Files changed vs another branch"},
        {"label": "Specific file", "description": "I'll specify which file to check"}
      ]
    }
  ]
}
```

## Step 2: Find Modified Files

```bash
# Based on scope selection
git diff --name-only HEAD~1 -- '*.rs' 2>/dev/null
# or
find src -name "*.rs" -mmin -30 -type f
# or
git diff --name-only main...HEAD -- '*.rs'
```

## Step 3: Analyze Coverage

For each modified file:
1. List all public functions
2. Check if corresponding test exists
3. Verify tests cover success AND error cases

```bash
# Find public functions
rg "pub (async )?fn \w+" [FILE] --no-heading

# Find test module
rg "#\[cfg\(test\)\]" [FILE] -A100
```

## Step 4: Run Tests

```bash
cargo test --quiet 2>&1
```

## Step 5: Output Format

```
TEST COVERAGE CHECK

Scope: [Recent changes | Last commit | Branch diff | file]
Files checked: N
Test results: X passed, Y failed

FUNCTIONS WITHOUT TESTS

[MISSING] src/api/users.rs::create_user()
  Needs tests for:
  - Happy path (valid user creation)
  - Error case (duplicate email)
  - Error case (invalid email format)

[PARTIAL] src/services/auth.rs::validate_token()
  Has: success case
  Missing: expired token error case

SUGGESTED TEST STRUCTURE

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_user_success() {
        // Arrange
        let cmd = CreateUserCommand::new("test@example.com", "Test")?;

        // Act
        let result = create_user(cmd);

        // Assert
        assert!(result.is_ok());
    }

    #[test]
    fn test_create_user_duplicate_email() {
        // Arrange: create user first
        // Act: try to create again
        // Assert
        assert!(matches!(result, Err(UserError::EmailTaken(_))));
    }
}
```

TEST REQUIREMENTS

Each public function needs:
- [x] Happy path test (normal case works)
- [x] Error case test (handles errors correctly)
- [ ] Edge case test (boundary conditions) - optional but recommended

SUMMARY

Functions checked: N
Fully tested: X
Partially tested: Y
Missing tests: Z

All new functions have adequate tests.
```

---

**Focus on missing tests for new functions, not historical debt.**
