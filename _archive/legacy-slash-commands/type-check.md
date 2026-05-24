---
name: type-check
description: Check Rust code for type-driven design and ADT modeling patterns. Use when reviewing code for type safety, after writing domain types, or when user mentions "type check", "ADT review", or "type safety audit". Can run on full codebase or just current changes.
---

# Type-Driven Design Check

Verify code follows type-driven design patterns, ADT modeling, and protected concrete type standards.

## Standards Reference

**Source:** `.claude/guidelines/type-driven-design.md`

Checks compliance with:
- Protected concrete types (smart constructors)
- No primitive obsession
- Making illegal states unrepresentable
- Railway-Oriented Programming
- Event sourcing patterns

## Step 1: Select Scope

First, ask what to check:

```json
{
  "questions": [
    {
      "question": "What scope should I check for type-driven design patterns?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Current changes", "description": "Check only staged/unstaged git changes (git diff)"},
        {"label": "Branch diff", "description": "Compare current branch against another branch (e.g., main)"},
        {"label": "Recent files", "description": "Check files modified in last 30 minutes"},
        {"label": "Full codebase", "description": "Check entire src/ directory"}
      ]
    }
  ]
}
```

If user selects "Branch diff", ask which branch:

```json
{
  "questions": [
    {
      "question": "Which branch should I compare against?",
      "header": "Base branch",
      "multiSelect": false,
      "options": [
        {"label": "main", "description": "Compare against main branch"},
        {"label": "develop", "description": "Compare against develop branch"},
        {"label": "Other", "description": "I'll specify the branch name"}
      ]
    }
  ]
}
```

### Get Files Based on Scope

**Current changes (git diff):**
```bash
# Get list of changed Rust files (staged + unstaged)
git diff --name-only HEAD -- '*.rs' 2>/dev/null
git diff --cached --name-only -- '*.rs' 2>/dev/null
```

**Branch diff (e.g., against main):**
```bash
# Get files changed between current branch and base branch
git diff --name-only main...HEAD -- '*.rs' 2>/dev/null

# Or for specific base branch:
git diff --name-only [BASE_BRANCH]...HEAD -- '*.rs' 2>/dev/null
```

**Recent files:**
```bash
find src -name "*.rs" -mmin -30 -type f 2>/dev/null
```

**Full codebase:**
```bash
find src -name "*.rs" -type f 2>/dev/null
```

## Step 2: Check Anti-Patterns

For each file in scope, scan for violations:

### A. Public Mutable Fields (Protected Types)

```bash
# Find pub fields on structs (potential violation)
rg "pub\s+\w+:\s+(String|usize|i32|i64|f32|f64|Uuid|bool)" [FILES] --type rust
```

**What to check:**
- Domain types should have private fields
- Only allow `pub` fields if it's a DTO/payload or simple tuple struct
- Exception: API payload structs can have public fields

### B. Primitive Obsession in Function Signatures

```bash
# Find functions accepting raw primitives for domain concepts
rg "fn\s+\w+\([^)]*\b(String|Uuid|usize|i32|i64)\b[^)]*\)" [FILES] --type rust
```

**What to check:**
- Functions in `domain/` should use newtype wrappers
- `TruckId` not `Uuid`
- `UserEmail` not `String`

### C. Unwrap/Expect in Business Logic

```bash
# Find unwrap/expect outside of tests
rg "(\.unwrap\(\)|\.expect\()" [FILES] --type rust | grep -v "test"
```

**What to check:**
- Business logic should use `?` operator
- Exception: Evolvers can use `unwrap()` (events guaranteed valid)
- Exception: Test code can use `unwrap()`

### D. Boolean State Flags

```bash
# Find boolean flags that might represent state
rg "is_\w+:\s+bool" [FILES] --type rust
```

**What to check:**
- Pairs like `is_created`, `is_deleted` suggest state machine needed
- Single booleans are often fine (e.g., `reefer: bool`)

### E. Missing Result Types

```bash
# Find validation functions not returning Result
rg "fn\s+(new|validate_|from)\w*.*->" [FILES] --type rust | grep -v Result
```

**What to check:**
- `new()` constructors should return `Result`
- Validation functions should return `Result`
- Parsing functions should return `Result`

## Step 3: Check Required Implementations

### A. Smart Constructors

For domain types found, verify:
- Has private fields (not `pub`)
- Has `new()` or `from()` returning `Result`
- Has `value()` accessor method

### B. Error Types

```bash
rg "pub enum \w+Error" [FILES] --type rust
```

Verify uses `#[derive(Error)]` from thiserror.

### C. Event Naming

```bash
rg "pub enum \w+Event" [FILES] --type rust
```

Verify variants use past tense: `UserAdded`, not `AddUser`.

## Step 4: Output Format

```
TYPE-DRIVEN DESIGN CHECK

Scope: [Current changes | Recent files | Full codebase | path]
Files checked: N

VIOLATIONS FOUND

[ERROR] src/domain/users.rs:23 - Public field on domain type
  pub struct UserEmail {
      pub str: String,  // Should be private
  }

  Fix: Make field private, add smart constructor
  Guideline: type-driven-design.md -> "Protected Concrete Types"

[ERROR] src/domain/truck.rs:45 - Primitive obsession
  fn add_truck(id: Uuid, name: String)

  Fix: Use domain types
  fn add_truck(id: &TruckId, name: &TruckName)

  Guideline: type-driven-design.md -> "No Primitive Obsession"

[WARN] src/domain/expense.rs:89 - Consider Result return type
  pub fn validate_amount(amount: &ExpenseAmount) -> bool

  Consider: Return Result for better error context

GOOD PATTERNS FOUND

[OK] src/domain/truck.rs:34 - Proper smart constructor
  impl TruckName {
      pub fn new(name: &str) -> Result<Self, TruckFieldError>
  }

SUMMARY

Violations: N errors, M warnings
- Public fields: X instances
- Primitive obsession: Y instances
- unwrap/expect: Z instances

Recommendations:
1. [Most critical fix]
2. [Second priority]

See: .claude/guidelines/type-driven-design.md
```

If no violations:
```
TYPE-DRIVEN DESIGN CHECK

Scope: [scope]
Files checked: N

No type-driven design violations found.
All code follows protected concrete type patterns.
```

## Context Rules

**When to error vs warn:**
- **Error**: Public fields on domain types, primitive obsession, unwrap() in deciders
- **Warn**: Missing smart constructor, boolean flags, validation returning bool

**Acceptable exceptions:**
- DTOs and API payloads can have public fields
- Test code can use `unwrap()`
- Evolvers can use `unwrap()` (events guaranteed valid)
- Simple boolean properties (not state flags) are fine

## Special Cases

### Acceptable unwrap() Usage

```rust
// OK: In Evolver (events guaranteed valid)
fn evolve(state: Self::State, event: &Self::Evt) -> Self::State {
    // Events are valid by construction
}

// OK: In tests
#[test]
fn test_user_creation() {
    let user = create_user().unwrap();
}

// WRONG: In Decider
fn decide(/* ... */) -> Result<Vec<Event>, Error> {
    let id = TruckId::from(str).unwrap();  // Should use ?
}
```

### Acceptable Public Fields

```rust
// OK: DTO/Payload types
#[derive(Deserialize)]
pub struct CreateUserPayload {
    pub email: String,  // Will be validated before use
}

// OK: Simple tuple struct
pub struct UserId(Uuid);

// WRONG: Domain type with business rules
pub struct UserEmail {
    pub str: String,  // Should be private with validation
}
```

---

**Focus:** Type safety, domain modeling, and making illegal states unrepresentable.
