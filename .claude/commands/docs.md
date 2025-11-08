---
name: docs
description: Check documentation completeness (30 seconds)
---

# Documentation Completeness Check

## Task
Verify that recently modified public functions have proper documentation.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md` Section 3 (Documentation Guidelines)

This skill checks the documentation standards defined in the project guidelines.

## Steps

1. **Find recent changes:**
```bash
find src -name "*.rs" -mmin -30 -type f 2>/dev/null
```

2. **Check each file for:**
   - Public functions (`pub fn`) without doc comments (`///`)
   - Public structs/enums without doc comments
   - Functions returning Result without `# Errors` section
   - Functions that can panic without `# Panics` section
   - Complex functions without `# Examples`

3. **Output format:**
```
📚 DOCUMENTATION CHECK

Missing docs:
- src/api/users.rs:45 - `pub fn get_user()` needs doc comment
  Add:
  /// Retrieves a user by their ID.
  ///
  /// # Errors
  /// Returns `Error::NotFound` if user doesn't exist.

- src/models/user.rs:12 - `pub struct User` needs doc comment

Incomplete docs:
- src/services/auth.rs:78 - `login()` returns Result but missing # Errors section

✅ All documentation complete!
```

**Show examples of what the docs should look like.**
