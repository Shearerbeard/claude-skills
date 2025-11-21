---
name: type-check
description: Check type-driven design and ADT modeling patterns (45 seconds)
---

# Type-Driven Design Check

## Task
Verify code follows type-driven design patterns, ADT modeling, and protected concrete type standards.

## Standards Reference

**Source:** `.claude/guidelines/type-driven-design.md`

This skill checks compliance with type-driven design patterns from Scott Wlaschin's "Domain Modeling Made Functional":
- Protected concrete types (smart constructors)
- No primitive obsession
- Making illegal states unrepresentable
- Railway-Oriented Programming
- Event sourcing patterns

## Steps

### 1. Find Recent Changes

```bash
# Get files modified in last 30 minutes
find src -name "*.rs" -mmin -30 -type f 2>/dev/null || echo "No recent changes"
```

### 2. Check Anti-Patterns

Scan for violations of type-driven design principles:

#### A. Public Mutable Fields (Protected Types)
```bash
# Find pub fields on structs (potential violation)
rg "pub\s+\w+:\s+(String|usize|i32|i64|f32|f64|Uuid|bool)" src/ --type rust
```

**What to check:**
- Domain types should have private fields
- Only allow `pub` fields if it's a simple tuple struct or deliberately public API
- Exception: DTOs and API payload structs can have public fields

#### B. Primitive Obsession in Function Signatures
```bash
# Find functions accepting raw primitives for domain concepts
rg "fn\s+\w+\([^)]*\b(String|Uuid|usize|i32|i64)\b[^)]*\)" src/domain/ --type rust
```

**What to check:**
- Functions in `domain/` should use newtype wrappers
- `TruckId` not `Uuid`
- `UserEmail` not `String`
- `ExpenseAmount` not `usize`

#### C. Unwrap/Expect in Business Logic
```bash
# Find unwrap/expect outside of tests
rg "(\.unwrap\(\)|\.expect\()" src/ --type rust | grep -v "^src/.*test" | grep -v "^tests/"
```

**What to check:**
- Business logic should use `?` operator
- Exception: Evolvers can use `unwrap()` (events guaranteed valid)
- Exception: Test code can use `unwrap()`

#### D. Boolean State Flags
```bash
# Find boolean flags that might represent state
rg "is_\w+:\s+bool" src/ --type rust
```

**What to check:**
- Pairs like `is_created`, `is_deleted` suggest state machine needed
- Single booleans are often fine (e.g., `reefer: bool` for true/false property)
- State machines should use enums instead

#### E. Missing Result Types
```bash
# Find validation functions not returning Result
rg "fn\s+validate_\w+.*->\s+(?!Result)" src/ --type rust
```

**What to check:**
- Validation functions should return `Result`
- Parsing functions should return `Result`
- Functions named `new()` for domain types should return `Result`

### 3. Check Required Implementations

#### A. Smart Constructors
```bash
# Find domain type structs
rg "pub struct (User|Truck|Expense)\w+" src/domain/ --type rust
```

**For each domain type, verify:**
- Has private fields (not `pub`)
- Has `new()` or `from()` method returning `Result`
- Has `value()` accessor method
- Validation happens in constructor

#### B. Error Types Using thiserror
```bash
# Find error enums
rg "pub enum \w+Error" src/ --type rust
```

**Verify:**
- Uses `#[derive(Error)]`
- Has `#[error("...")]` on variants
- Includes context (IDs, values) in error messages

#### C. Event Naming (Past Tense)
```bash
# Find event enums
rg "pub enum \w+Event" src/ --type rust
```

**Verify:**
- Event variants use past tense: `UserAdded`, `TruckUpdated`
- Not present tense: `AddUser`, `UpdateTruck`

### 4. Output Format

```
🏗️  TYPE-DRIVEN DESIGN CHECK

Files checked: X

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚨 ANTI-PATTERNS FOUND

❌ src/domain/users.rs:23 - Public field on domain type
   pub struct UserEmail {
       pub str: String,  // Should be private
   }

   Fix: Make field private, add smart constructor
   ```rust
   pub struct UserEmail {
       str: String,  // Private
   }

   impl UserEmail {
       pub fn new(str: &str) -> Result<Self, UserFieldError> {
           // Validation logic
       }

       pub fn value(&self) -> String {
           self.str.clone()
       }
   }
   ```

   Guideline: type-driven-design.md → "Protected Concrete Types"

❌ src/domain/truck.rs:45 - Primitive obsession in function signature
   fn add_truck(id: Uuid, name: String) -> Result<(), Error>

   Fix: Use domain types
   ```rust
   fn add_truck(id: &TruckId, name: &TruckName) -> Result<TruckEvent, TruckError>
   ```

   Guideline: type-driven-design.md → "No Primitive Obsession"

❌ src/event_sourcing/users.rs:67 - unwrap() in business logic
   let email = UserEmail::new(str).unwrap();

   Fix: Use ? operator
   ```rust
   let email = UserEmail::new(str)
       .map_err(UserError::UserField)?;
   ```

   Guideline: type-driven-design.md → "Railway-Oriented Programming"

❌ src/domain/truck.rs:12 - Boolean state flags
   pub struct Truck {
       pub is_created: bool,
       pub is_deleted: bool,
   }

   Fix: Use state machine enum
   ```rust
   pub enum TruckState {
       NotCreated,
       Exists(Truck),
       Deleted { id: TruckId, deleted_at: DateTime<Utc> },
   }
   ```

   Guideline: type-driven-design.md → "Making Illegal States Unrepresentable"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  POTENTIAL ISSUES

⚠️  src/domain/expense.rs:89 - Function may need Result return type
   pub fn validate_amount(amount: &ExpenseAmount) -> bool

   Consider: Return Result for better error context
   ```rust
   pub fn validate_amount(amount: &ExpenseAmount) -> Result<(), ExpenseError>
   ```

⚠️  src/domain/users.rs:156 - Missing smart constructor
   pub struct UserId { uuid: Uuid }

   Verify has: new(), from(), value() methods

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ GOOD PATTERNS FOUND

✅ src/domain/truck.rs:34 - Proper smart constructor
   impl TruckName {
       pub fn new(name: &str) -> Result<Self, TruckFieldError> {
           // Validation with Result
       }
   }

✅ src/event_sourcing/trucks.rs:45 - Type-safe state machine
   enum TruckState {
       NotCreated,
       Exists(Truck),
   }

✅ src/domain/expense.rs:23 - No primitive obsession
   fn add_expense(
       truck_id: &TruckId,      // Newtype wrapper
       amount: &ExpenseAmount,  // Not raw usize
   )

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 SUMMARY

Type Safety Score: 8/10

Violations by Category:
  - Public fields: 2 instances
  - Primitive obsession: 1 instance
  - unwrap/expect: 1 instance
  - Boolean flags: 1 instance

Recommendations:
1. Make UserEmail fields private, add smart constructor
2. Replace Uuid/String with TruckId/TruckName in signatures
3. Replace unwrap() with ? operator
4. Consider state machine enum for Truck lifecycle

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Steps:
- Fix critical violations (public fields, unwrap)
- Refactor functions to use domain types
- Add smart constructors where missing

See: .claude/guidelines/type-driven-design.md for complete patterns
```

If no violations:
```
✅ No type-driven design violations found in recent changes.

All code follows protected concrete type patterns.
```

## Standards Checked

### 1. Protected Concrete Types
**Guideline:** `type-driven-design.md` → "Protected Concrete Types"

**Checks:**
- No public fields on domain types
- Smart constructors return `Result`
- Controlled access via `value()` methods

### 2. No Primitive Obsession
**Guideline:** `type-driven-design.md` → "No Primitive Obsession"

**Checks:**
- Function signatures use domain types, not primitives
- IDs wrapped in newtype pattern
- No raw `String`, `Uuid`, `usize` for domain concepts

### 3. Making Illegal States Unrepresentable
**Guideline:** `type-driven-design.md` → "Making Illegal States Unrepresentable"

**Checks:**
- State represented with enums, not boolean flags
- State transitions use `assert_*` methods
- Pattern matching on state/event tuples

### 4. Railway-Oriented Programming
**Guideline:** `type-driven-design.md` → "Railway-Oriented Programming"

**Checks:**
- No `unwrap()` or `expect()` in business logic
- Validation functions return `Result`
- Error types use `thiserror::Error`
- Composable validation with `?` operator

### 5. Algebraic Data Types
**Guideline:** `type-driven-design.md` → "Algebraic Data Types"

**Checks:**
- Commands use enum variants
- Events use past tense naming
- Sum types for choices (enum)
- Product types for data (struct)

### 6. Event Sourcing Patterns
**Guideline:** `type-driven-design.md` → "Event Sourcing Patterns"

**Checks:**
- Deciders are pure (no `async` in signature)
- Evolvers return `State`, not `Result`
- Context types use `HashSet` for efficient lookups
- Events use past tense

## Best Practices

**Only report actual violations with:**
- Specific file and line number
- Which pattern is violated
- Concrete fix with code example
- Reference to type-driven-design.md section

**When to warn vs error:**
- **Error**: Public fields, primitive obsession, unwrap() in deciders
- **Warn**: Missing smart constructor, boolean flags, validation returning bool

**Be helpful, not pedantic:**
- Focus on type safety violations
- Acknowledge good patterns found
- Provide context for why the pattern matters

**Context matters:**
- DTOs and API payloads can have public fields
- Test code can use `unwrap()`
- Evolvers can use `unwrap()` (events guaranteed valid)
- Simple boolean properties (not state flags) are fine

## Special Cases

### Acceptable unwrap() Usage
```rust
// ✅ OK: In Evolver (events guaranteed valid)
impl Evolver for TrucksDecider {
    fn evolve(state: Self::State, event: &Self::Evt) -> Self::State {
        let truck_id = event.truck_id;  // Known valid
        TruckState::Exists(truck)
    }
}

// ✅ OK: In tests
#[test]
fn test_user_creation() {
    let user = create_user().unwrap();  // Acceptable in tests
}

// ❌ WRONG: In Decider
fn decide(/* ... */) -> Result<Vec<Event>, Error> {
    let id = TruckId::from(str).unwrap();  // Should use ?
}
```

### Acceptable Public Fields
```rust
// ✅ OK: DTO/Payload types
#[derive(Deserialize)]
pub struct CreateUserPayload {
    pub email: String,  // Will be validated before use
    pub name: String,
}

// ✅ OK: Simple tuple struct
pub struct UserId(Uuid);

// ❌ WRONG: Domain type with business rules
pub struct UserEmail {
    pub str: String,  // Should be private with validation
}
```

### Boolean Flags vs State Machines
```rust
// ✅ OK: Simple property
pub struct FuelExpense {
    pub reefer: bool,  // True/false property, not state
}

// ❌ WRONG: State represented as booleans
pub struct Truck {
    pub is_created: bool,   // These are actually state
    pub is_deleted: bool,   // Use enum instead
}

// ✅ CORRECT: State machine
pub enum TruckState {
    NotCreated,
    Exists(Truck),
    Deleted { id: TruckId, deleted_at: DateTime<Utc> },
}
```

---

## Advanced Checks (Optional)

For thorough review, also check:

### Missing Hash/PartialEq on IDs
```bash
# IDs should derive Hash, PartialEq, Eq for use in HashSet
rg "pub struct \w+Id" src/ | while read line; do
    # Check if derives include Hash and PartialEq
done
```

### Missing Display Implementation
```bash
# IDs should implement Display for string representation
rg "impl.*Display.*for.*Id" src/
```

### Context Type Efficiency
```bash
# Context types should use HashSet, not Vec, for O(1) lookups
rg "pub struct \w+Context" src/ -A 5 | grep "Vec<"
```

---

**Focus:** Type safety, domain modeling, and making illegal states unrepresentable through Rust's type system.
