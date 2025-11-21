---
name: tests
description: Verify test coverage for new functions (60 seconds)
---

# Test Coverage Check

## Task
Ensure recently added/modified public functions have tests.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md` → "🧪 Testing Standards"

This skill checks the testing requirements defined in the project guidelines.

## Steps

1. **Find modified files:**
```bash
# If git available, use git diff
git diff --name-only HEAD~1 '*.rs' 2>/dev/null || find src -name "*.rs" -mmin -30 -type f
```

2. **For each modified file:**
   - List all public functions
   - Check if corresponding test module exists
   - Verify tests cover both success and error cases

3. **Run existing tests:**
```bash
cargo test --quiet 2>&1
```

4. **Output format:**
```
🧪 TEST COVERAGE CHECK

Modified files: X
Test results: Y passed, Z failed

New/Modified functions without tests:
- src/api/users.rs::create_user() - no test found
  Needs tests for:
  ✓ Happy path (valid user creation)
  ✓ Error case (duplicate email)
  ✓ Error case (invalid email format)

- src/services/auth.rs::validate_token() - test exists but no error case
  Add test for expired token scenario

Suggested test structure:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_user_success() {
        // Arrange
        let user = User::new("test@example.com");
        
        // Act
        let result = create_user(user);
        
        // Assert
        assert!(result.is_ok());
    }

    #[test]
    fn test_create_user_duplicate_email() {
        // Test error case
        let result = create_user(existing_user);
        assert_eq!(result.unwrap_err(), Error::DuplicateEmail);
    }
}
```

✅ All new functions have adequate tests!
```

**Focus on missing tests for new functions, not historical debt.**
