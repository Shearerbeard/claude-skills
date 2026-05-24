---
name: code-safety
description: Check Rust code for safety violations including unwrap/expect abuse, unsafe blocks, error handling, and documentation. Use after writing code, before commits, or when user mentions "code safety", "unwrap check", "error handling", or "unsafe audit". Can check full codebase or recent changes.
---

# Code Standards Check

Check Rust files for violations of project coding standards.

## Standards Reference

**Source:** `.claude/guidelines/project-standards.md`

## Step 1: Select Scope

```json
{
  "questions": [
    {
      "question": "What scope should I check for standards violations?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Recent changes", "description": "Files modified in last 30 minutes"},
        {"label": "Branch diff", "description": "Files changed vs another branch (e.g., main)"},
        {"label": "Staged files", "description": "Files staged for commit (git diff --cached)"},
        {"label": "Full codebase", "description": "Check entire src/ directory"}
      ]
    }
  ]
}
```

### Get Files Based on Scope

```bash
# Recent changes
find src -name "*.rs" -mmin -30 -type f 2>/dev/null

# Branch diff
git diff --name-only main...HEAD -- '*.rs' 2>/dev/null

# Staged files
git diff --cached --name-only -- '*.rs' 2>/dev/null

# Full codebase
find src -name "*.rs" -type f 2>/dev/null
```

## Step 2: Check Standards

### A. Error Handling

```bash
# Find unwrap/expect in production code
rg "(\.unwrap\(\)|\.expect\()" [FILES] --type rust | grep -v test
```

**Violations:**
- `unwrap()` or `expect()` in production code
- Missing `?` operator for error propagation
- Swallowed errors (ignoring Result)

**Exceptions:**
- Test code can use `unwrap()`
- Evolvers can use `unwrap()` (events guaranteed valid)

### B. Unsafe Code

```bash
# Find unsafe blocks
rg "unsafe\s*\{" [FILES] --type rust -B2
```

**Requirements:**
- Every `unsafe` block must have a `// SAFETY:` comment
- Comment must explain why unsafe is necessary and what invariants hold

### C. Documentation (see guidelines below)

```bash
# Find public items
rg "pub (fn|struct|enum|trait)" [FILES] --type rust
```

**Check for:**
- Public items without doc comments
- Functions returning `Result` without `# Errors` section
- Functions that can panic without `# Panics` section

### D. Code Quality

```bash
# Run clippy
cargo clippy --quiet -- -D warnings 2>&1 | head -20
```

**Check for:**
- `panic!()` in production code
- Hardcoded magic values
- Non-idiomatic patterns
- Emojis in code, logs, or error messages

## Step 3: Output Format

```
CODE STANDARDS CHECK

Scope: [Recent changes | Branch diff | Staged | Full]
Files checked: N

VIOLATIONS

[ERROR] src/api/auth.rs:42 - unwrap() in production code
  Code: let user = get_user(id).unwrap();
  Fix: let user = get_user(id)?;
  Standard: Error handling - use ? operator

[ERROR] src/db/query.rs:156 - unsafe block missing SAFETY comment
  Fix: Add // SAFETY: comment explaining invariants
  Standard: Unsafe code documentation

[WARN] src/api/users.rs:23 - Public function missing doc comment
  Fix: Add /// doc comment (see documentation guidelines below)
  Standard: Public item documentation

[ERROR] src/handler.rs:67 - Emoji in log message
  Code: tracing::info!("Request complete");
  Fix: Remove emoji from production logs
  Standard: No emojis in code

CLIPPY

[clippy] src/utils.rs:34 - unnecessary clone
  Fix: Remove .clone() - value is already owned

SUMMARY

Errors: N (must fix)
Warnings: M (should fix)
Clippy: K issues
```

If clean:
```
CODE STANDARDS CHECK

Scope: [scope]
Files checked: N

No standards violations found.
```

---

## Documentation Guidelines

### When to Document

**DO document:**
- **Why** something exists (purpose, context)
- **Constraints** not obvious from types (e.g., "must be called before X")
- **Side effects** (I/O, state changes, panics)
- **Error conditions** with `# Errors` section
- **Examples** for non-obvious usage

**DON'T over-document:**
- **Type signatures** - the types already document themselves
- **Parameter names** - if `user_id: UserId` is clear, don't repeat it
- **Implementation details** that may change
- **Obvious behavior** - `/// Returns the user's name` on `fn name(&self) -> &str`

### Let Types Document Themselves

With good type-driven design, documentation becomes minimal:

**WRONG - Over-documented:**
```rust
/// Adds an expense to a truck.
///
/// # Arguments
/// * `truck_id` - The UUID of the truck (must be valid)
/// * `amount` - The expense amount in cents (must be positive)
/// * `gallons` - The number of gallons (for fuel expenses)
///
/// # Returns
/// Returns Ok with the expense event, or an error if validation fails.
pub fn add_expense(
    truck_id: Uuid,
    amount: usize,
    gallons: f32,
) -> Result<ExpenseEvent, Error>
```

**CORRECT - Types speak for themselves:**
```rust
/// Records a fuel expense for the truck.
///
/// # Errors
/// Returns `ExpenseError::InvalidTruck` if truck doesn't exist.
pub fn add_expense(
    truck_id: &TruckId,
    amount: &ExpenseAmount,
    gallons: &ExpenseGallons,
) -> Result<ExpenseEvent, ExpenseError>
```

The newtypes (`TruckId`, `ExpenseAmount`, `ExpenseGallons`) eliminate the need to document:
- What type of ID it is
- What units the amount is in
- That values are validated

### Avoid Documentation Maintenance Burden

**Problem:** Documenting input types creates maintenance burden when types change.

**WRONG - Will become stale:**
```rust
/// Creates a new user.
///
/// # Arguments
/// * `email` - Must be a valid email address
/// * `name` - Must be 1-100 characters
/// * `role` - Either "admin" or "user"
pub fn create_user(cmd: CreateUserCommand) -> Result<User, Error>
```

**CORRECT - Reference the type:**
```rust
/// Creates a new user from the validated command.
///
/// # Errors
/// Returns `UserError::EmailTaken` if email already exists.
pub fn create_user(cmd: CreateUserCommand) -> Result<User, UserError>
```

Validation rules live in `CreateUserCommand::new()` - single source of truth.

### Documentation Checklist

For public items, ask:

1. **Is this already clear from the type signature?** → Don't repeat it
2. **Does this have side effects?** → Document them
3. **Can this fail?** → Add `# Errors` section
4. **Can this panic?** → Add `# Panics` section (or better: don't panic)
5. **Is usage non-obvious?** → Add `# Examples`
6. **Will this documentation become stale?** → Keep it minimal

### Good Documentation Examples

```rust
/// A validated email address.
///
/// Use `UserEmail::new()` to create - validates format automatically.
pub struct UserEmail { /* private */ }

/// Processes the payment and updates account balance.
///
/// # Errors
/// - `PaymentError::InsufficientFunds` if balance too low
/// - `PaymentError::AccountLocked` if account is frozen
///
/// # Panics
/// Never panics - all error cases return Result.
pub fn process_payment(/* ... */) -> Result<Receipt, PaymentError>

/// Calculates shipping cost based on distance and weight.
///
/// # Examples
/// ```
/// let cost = calculate_shipping(&distance, &weight)?;
/// assert!(cost.cents() > 0);
/// ```
pub fn calculate_shipping(/* ... */) -> Result<Money, ShippingError>
```

---

## Standards Summary

| Category | Rule | Severity |
|----------|------|----------|
| Error Handling | No `unwrap()`/`expect()` in production | Error |
| Error Handling | Use `?` operator for propagation | Error |
| Unsafe | SAFETY comment required | Error |
| Documentation | Public items need doc comments | Warning |
| Documentation | Don't over-document types | Warning |
| Code Quality | No `panic!()` in production | Error |
| Code Quality | No emojis in code/logs | Warning |
| Code Quality | Follow clippy recommendations | Warning |

---

**Focus:** Correctness, maintainability, and letting the type system do the documentation work.
