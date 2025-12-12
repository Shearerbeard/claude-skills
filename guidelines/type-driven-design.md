# Type-Driven Design & ADT Modeling Standards

**Purpose:** Enforce type-driven design patterns, algebraic data types (ADT), and domain modeling practices inspired by Scott Wlaschin's "Domain Modeling Made Functional".

**Language:** Rust (patterns may apply to other languages with strong type systems)
**Context Window Impact:** ~12KB (~3,000 tokens, <2% of Claude's 200K context)
**Referenced by:** `/type-check`, `/review`
**Source:** Based on trucker_buddy coding practices

## When This Applies

Apply these standards when:
- Writing or reviewing Rust domain code
- Designing new types, structs, or enums
- Implementing command/event patterns
- Reviewing function signatures for type safety
- User mentions: "type safety", "ADT", "newtype", "smart constructor", "impossible states", "railway oriented"

---

## Philosophy

**Core Mantra**: "Make impossible states unrepresentable" - Yaron Minsky

**Guiding Principles**:
1. Type-driven design - Use the type system to enforce business rules
2. Railway-Oriented Programming - Explicit error handling with Result types
3. Protected concrete types - Smart constructors with validation
4. Algebraic Data Types - Precise domain modeling with enums and structs
5. Pure functions - Especially in business logic

---

## 1. Protected Concrete Types (Smart Constructors)

### Rule: Never Expose Public Mutable Fields

**Principle:** All domain types must have private fields with smart constructors for validation.

**WRONG: Public fields allow invalid states**
```rust
pub struct UserEmail {
    pub str: String,  // Anyone can set invalid email!
}

// Can create invalid state:
let email = UserEmail { str: "not-an-email".to_string() };
```

**CORRECT: Protected with validation**
```rust
#[derive(Debug, Clone, Serialize, Deserialize, Hash, PartialEq, Eq)]
pub struct UserEmail {
    #[validate(email)]
    str: String,  // Private - can't be modified externally
}

impl UserEmail {
    // Smart constructor - only way to create valid instance
    pub fn new(str: &str) -> Result<Self, UserFieldError> {
        let email = Self {
            str: str.to_owned(),
        };
        email
            .validate()
            .map_err(|_| UserFieldError::InvalidEmail(str.to_owned()))?;
        Ok(email)
    }

    // Controlled read access
    pub fn value(&self) -> String {
        self.str.to_owned()
    }
}
```

**Requirements:**
- All fields must be private
- Provide smart constructor: `new()`, `from()`, or `try_from()`
- Validate in constructor, return `Result<Self, Error>`
- Provide read-only accessor: `value()` or equivalent
- Never provide `&mut` access to inner fields

**Benefits:**
- **Type Safety**: Invalid instances cannot be created
- **Encapsulation**: Internal representation can change
- **Single Source of Truth**: Validation logic centralized
- **Refactoring Safety**: Breaking changes are compile-time errors

---

## 2. No Primitive Obsession

### Rule: Wrap All Domain Concepts in Newtype Pattern

**Principle:** Never use raw primitives (`String`, `usize`, `Uuid`, `f64`) for domain concepts.

**WRONG: Primitive obsession**
```rust
fn add_expense(
    truck_id: Uuid,          // Which UUID? Truck? User?
    amount: usize,           // Cents? Dollars? Gallons?
    gallons: f32             // Could pass amount here by mistake
) -> Result<(), Error>

// Easy to make mistakes:
add_expense(user_id, gallons_value, amount_value);  // Compiles but wrong!
```

**CORRECT: Domain types prevent mistakes**
```rust
fn add_expense(
    truck_id: &TruckId,      // Type-safe ID
    amount: &ExpenseAmount,  // Cannot confuse with gallons
    gallons: &ExpenseGallons // Cannot confuse with amount
) -> Result<ExpenseEvent, ExpenseError>

// Type errors prevent mistakes:
add_expense(&user_id, &gallons, &amount);  // Compile error!
```

**Newtype Pattern for IDs:**
```rust
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct UserId {
    uuid: Uuid,  // Private
}

impl UserId {
    pub fn new() -> Self {
        Self { uuid: Uuid::new_v4() }
    }

    pub fn from(str: &str) -> Result<Self, UserFieldError> {
        Ok(Self {
            uuid: Uuid::from_str(str)
                .map_err(|_| UserFieldError::InvalidUUID(str.to_owned()))?,
        })
    }

    pub fn value(&self) -> Uuid {
        self.uuid
    }
}

impl Display for UserId {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.uuid)
    }
}
```

**Required Implementations for IDs:**
- `new()` for generation
- `from(str)` for parsing with validation
- `value()` for controlled access
- `Display` for string representation
- Derive: `Hash`, `PartialEq`, `Eq` (for collections)
- Derive: `Copy` if small (≤ 16 bytes)
- Derive: `Serialize`, `Deserialize` (for persistence)

**Examples of Domain Types:**
- IDs: `UserId`, `TruckId`, `ExpenseId`
- Measurements: `ExpenseAmount`, `ExpenseGallons`, `ExpenseMiles`
- Identifiers: `UserEmail`, `TruckName`, `USState`
- Quantities: `ItemCount`, `Weight`, `Distance`

---

## 3. Making Illegal States Unrepresentable

### Rule: Use Enums to Model State Machines

**Principle:** Represent state explicitly with enums to prevent invalid state transitions.

**WRONG: Boolean flags create invalid states**
```rust
pub struct Truck {
    pub id: TruckId,
    pub name: TruckName,
    pub is_created: bool,    // Can be false with valid data
    pub is_deleted: bool,    // Both true? Both false?
}

// Invalid states possible:
let truck = Truck {
    id: TruckId::new(),
    name: TruckName::new("Red Truck")?,
    is_created: false,  // Not created but has data?
    is_deleted: true,   // Deleted and not created?
};
```

**CORRECT: Enum states are mutually exclusive**
```rust
#[derive(Debug)]
pub enum TruckState {
    NotCreated,
    Exists(Truck),
}

impl TruckState {
    // Type-safe state validation
    fn assert_not_created(&self) -> Result<(), TruckError> {
        match self {
            TruckState::NotCreated => Ok(()),
            TruckState::Exists(_) => Err(TruckError::AlreadyExists),
        }
    }

    fn assert_created(&self) -> Result<(), TruckError> {
        match self {
            TruckState::Exists(_) => Ok(()),
            TruckState::NotCreated => Err(TruckError::NotFound),
        }
    }

    // Type-safe access
    fn get_truck(&self) -> Result<&Truck, TruckError> {
        match self {
            TruckState::Exists(truck) => Ok(truck),
            TruckState::NotCreated => Err(TruckError::NotFound),
        }
    }
}
```

**Usage in Business Logic:**
```rust
fn decide(
    ctx: &TrucksContext,
    state: &TruckState,
    cmd: &TruckCommand,
) -> Result<Vec<TruckEvent>, TruckError> {
    match cmd {
        TruckCommand::AddTruck(_) => {
            state.assert_not_created()?;  // Compile-time enforced
            // Can only reach here if NotCreated
            Ok(vec![TruckEvent::TruckAdded { /* ... */ }])
        }
        TruckCommand::UpdateTruck(_) => {
            state.assert_created()?;
            let truck = state.get_truck()?;  // Type-safe access
            Ok(vec![TruckEvent::TruckUpdated { /* ... */ }])
        }
    }
}
```

**Benefits:**
- Cannot update non-existent entity (compile-time safety)
- Cannot create entity twice
- Explicit state transitions with exhaustive pattern matching
- Impossible to forget to check state

---

## 4. Algebraic Data Types for Domain Logic

### Rule: Model Domain with Sum Types (Enums) and Product Types (Structs)

**Principle:** Use Rust's type system to precisely model your domain.

**Sum Types (Choice of Variants):**
```rust
// User can be one of these roles (mutually exclusive)
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum UserRole {
    Trucker,
    Admin,
}

// Command is one of these actions
#[derive(Debug)]
pub enum TruckCommand {
    AddTruck(AddTruckCommand),
    UpdateTruck(UpdateTruckCommand),
    DeleteTruck(DeleteTruckCommand),
}

// Event is one of these facts
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TruckEvent {
    TruckAdded {
        truck_id: TruckId,
        name: TruckName,
    },
    TruckUpdated {
        truck_id: TruckId,
        name: Option<Audit<TruckName>>,
    },
    TruckDeleted {
        truck_id: TruckId,
    },
}

// Expense can be one of these types
#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub enum ExpenseEntry {
    Fuel(FuelLogEntry),
    Repair(RepairLogEntry),
    Lumper(LumperLogEntry),
}
```

**Product Types (Combination of Fields):**
```rust
// Fuel entry has all these fields (must have all)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct FuelLogEntry {
    pub id: ExpenseId,
    pub amount: ExpenseAmount,
    pub gallons: ExpenseGallons,
    pub state: USState,
    pub reefer: bool,
    pub date: DateTime<Utc>,
}
```

**Benefits:**
- Exhaustive pattern matching ensures all cases handled
- Type-safe variant access
- Self-documenting domain model
- Impossible to add invalid variants

**Pattern Matching:**
```rust
match expense_entry {
    ExpenseEntry::Fuel(fuel) => {
        // fuel is FuelLogEntry - type-safe access
        process_fuel(fuel.gallons, fuel.state)
    }
    ExpenseEntry::Repair(repair) => {
        // repair is RepairLogEntry
        process_repair(repair.description, repair.cost)
    }
    ExpenseEntry::Lumper(lumper) => {
        // lumper is LumperLogEntry
        process_lumper(lumper.amount)
    }
    // Compiler ensures all variants handled
}
```

---

## 5. Railway-Oriented Programming (Error Handling)

### Rule: All Fallible Operations Return Result

**Principle:** Never panic in business logic. Use `Result<T, E>` for all operations that can fail.

**WRONG: Panics on invalid input**
```rust
pub fn new(str: &str) -> Self {
    Self {
        str: str.to_owned(),
    }.validate().expect("valid email")  // Panics on invalid input!
}
```

**CORRECT: Explicit error handling**
```rust
pub fn new(str: &str) -> Result<Self, UserFieldError> {
    let email = Self {
        str: str.to_owned(),
    };
    email
        .validate()
        .map_err(|_| UserFieldError::InvalidEmail(str.to_owned()))?;
    Ok(email)
}
```

**Railway Metaphor:**
```
Input
  │
  ├─[parse]──────┐ (switch to error track)
  │              ↓ Error::ParseError
  ├─[validate]───┐
  │              ↓ Error::ValidationError
  ├─[process]────┐
  │              ↓ Error::ProcessError
  ↓
Output (Success)
```

**Composable Validation:**
```rust
fn decide(
    context: &UserContext,
    state: &UserState,
    cmd: &UserCommand,
) -> Result<Vec<UserEvent>, UserError> {
    // Each ? is a "switch" to error track if it fails
    let actor_id = UserId::from(&cmd.actor_id)
        .map_err(UserError::UserField)?;  // Switch point

    Self::is_admin(context, &actor_id)?;  // Switch point

    let email = UserEmail::new(&cmd.email)
        .map_err(UserError::UserField)?;  // Switch point

    Self::email_taken(context, &email)?;  // Switch point

    // Only reaches here if all validations passed
    Ok(vec![UserEvent::UserAdded { /* ... */ }])
}
```

**Custom Error Types with thiserror:**
```rust
use thiserror::Error;

#[derive(Debug, Error, Clone)]
pub enum UserError {
    #[error("User not found: {0}")]
    NotFound(UserId),

    #[error("Email already taken: {0}")]
    EmailTaken(String),

    #[error("User {0} is not an admin")]
    NotAdmin(UserId),

    #[error("User field error")]
    UserField(#[from] UserFieldError),  // Automatic conversion

    #[error("Repository error: {0}")]
    RepositoryError(String),
}
```

**Validation Helpers:**
```rust
// Small, composable validation functions
fn email_taken(
    ctx: &UserContext,
    email: &UserEmail,
) -> Result<UserEmail, UserError> {
    (!ctx.emails.contains(email))
        .then_some(email.to_owned())
        .ok_or_else(|| UserError::EmailTaken(email.value()))
}

fn is_admin(
    ctx: &UserContext,
    id: &UserId,
) -> Result<(), UserError> {
    ctx.admins
        .contains(id)
        .then_some(())
        .ok_or_else(|| UserError::NotAdmin(id.to_owned()))
}
```

**Error Propagation Patterns:**
```rust
// Map errors to domain error type
let user_id = UserId::from(str)
    .map_err(UserError::UserField)?;

// Automatic conversion with #[from]
let email = UserEmail::new(str)?;  // UserFieldError -> UserError

// Chain validations
Self::is_admin(context, &actor_id)?;
Self::email_taken(context, &email)?;

// Transform errors with context
context.validate_truck(truck_id)
    .map_err(|e| ExpenseError::InvalidTruck(truck_id.clone(), e))?;
```

**Exception:** `unwrap()` is acceptable in Evolvers where events are guaranteed valid by construction.

---

## 6. Event Sourcing Patterns

### 6.1 Decider Pattern (Pure Command Validation)

**Principle:** Deciders validate commands against current state and produce events. They are pure functions.

```rust
pub struct TrucksDecider;

impl DeciderWithContext for TrucksDecider {
    type Ctx = TrucksContext;
    type Cmd = TruckCommand;
    type Evt = TruckEvent;
    type Err = TruckError;

    fn decide(
        ctx: &Self::Ctx,
        state: &Self::State,
        cmd: &Self::Cmd,
    ) -> Result<Vec<Self::Evt>, Self::Err> {
        // 1. Validate state preconditions
        state.assert_not_created()?;

        // 2. Validate command with context
        let name = ctx.truck_name_taken(&cmd.name)?;

        // 3. Return events (never modify state)
        Ok(vec![TruckEvent::TruckAdded {
            truck_id: TruckId::new(),
            name,
        }])
    }
}
```

**Requirements for Deciders:**
- Pure function (no side effects, no I/O)
- Returns `Result<Vec<Event>, Error>`
- Never modifies state directly
- Validates all business rules
- Uses context for cross-aggregate validation

### 6.2 Evolver Pattern (Deterministic State Evolution)

**Principle:** Evolvers apply events to rebuild state. Must be pure and deterministic.

```rust
impl Evolver for TrucksDecider {
    type State = TruckState;
    type Evt = TruckEvent;

    fn evolve(state: Self::State, event: &Self::Evt) -> Self::State {
        match (state, event) {
            (TruckState::NotCreated, TruckEvent::TruckAdded { truck_id, name }) => {
                TruckState::Exists(Truck {
                    id: *truck_id,
                    name: name.to_owned(),
                })
            }
            (TruckState::Exists(truck), TruckEvent::TruckUpdated { name, .. }) => {
                TruckState::Exists(Truck {
                    name: name.as_ref()
                        .map(|audit| audit.new.clone())
                        .unwrap_or(truck.name),
                    ..truck
                })
            }
            // Invalid transitions return state unchanged
            (state, _) => state,
        }
    }
}
```

**Requirements for Evolvers:**
- Pure function (no I/O, no randomness)
- Deterministic (same inputs → same output)
- Never fails (events are valid by construction)
- Pattern match on `(state, event)` tuple
- Handle all state transitions explicitly

### 6.3 Context Pattern for Cross-Aggregate Validation

**Principle:** Use Context types to share read-only data for validation across aggregates.

```rust
#[derive(Debug, Default)]
pub struct UserContext {
    pub emails: HashSet<UserEmail>,  // All existing emails
    pub admins: HashSet<UserId>,     // All admin IDs
}

impl From<&UsersState> for UserContext {
    fn from(UsersState(users): &UsersState) -> Self {
        let emails = users.values()
            .map(|u| u.email.clone())
            .collect();

        let admins = users.values()
            .filter(|u| u.role == UserRole::Admin)
            .map(|u| u.id)
            .collect();

        UserContext { emails, admins }
    }
}
```

**Benefits:**
- Validates across aggregate boundaries (e.g., email uniqueness)
- Maintains bounded context boundaries
- Efficient (build once, use many times)
- Read-only (immutable)

---

## 7. Naming Conventions

### Value Objects
**Pattern:** `{Domain}{Property}`

Examples:
- `UserId`, `UserEmail`, `UserNameStr`
- `TruckId`, `TruckName`
- `ExpenseId`, `ExpenseAmount`, `ExpenseGallons`

### Commands
**Pattern:** `{Action}{Domain}Command`

Examples:
- `AddTruckCommand`, `UpdateUserCommand`, `DeleteExpenseCommand`
- Wrapped in enum: `TruckCommand::AddTruck(AddTruckCommand)`

### Events
**Pattern:** `{Domain}{PastTenseAction}` or `{Domain}Event` enum

Examples:
- `UserEvent::UserAdded { ... }`
- `TruckEvent::TruckUpdated { ... }`
- `ExpenseEvent::FuelExpenseAdded { ... }`

**Rules:**
- Past tense (describe facts, not intent)
- Named variants in enum
- Include all data needed to rebuild state

### Errors
**Pattern:** `{Domain}Error`

Examples:
- `UserError`, `TruckError`, `ExpenseError`
- Descriptive variants with context
- Use `thiserror::Error`

### State Types
**Pattern:** `{Domain}State`

Examples:
- `TruckState` (enum for state machine)
- `UserState` (struct for collection: `UserState(HashMap<UserId, User>)`)
- `ExpenseState`

### Deciders
**Pattern:** `{Domain}Decider`

Examples:
- `UserDecider`, `TrucksDecider`, `ExpenseDecider`
- Unit struct
- Implements `DeciderWithContext` or `Decider`

---

## 8. Anti-Patterns to Avoid

### Avoid: Public Mutable Fields
```rust
// WRONG
pub struct UserEmail {
    pub str: String,  // Can be modified to invalid value
}
```

### Avoid: Primitive Obsession
```rust
// WRONG
fn add_expense(truck_id: Uuid, amount: usize) -> Result<(), Error>
```

### Avoid: Unwrap/Expect in Business Logic
```rust
// WRONG
let email = UserEmail::new(str).unwrap();  // Panics!
```

### Avoid: Mixing Domain and Infrastructure
```rust
// WRONG
impl User {
    pub async fn save(&self, db: &Database) -> Result<(), Error> {
        db.insert_user(self).await
    }
}
```

### Avoid: Stringly-Typed Data
```rust
// WRONG
fn add_expense(truck_id: String, user_id: String) -> Result<(), Error>
```

### Avoid: Boolean State Flags
```rust
// WRONG
pub struct Truck {
    pub is_created: bool,
    pub is_deleted: bool,  // What if both true?
}
```

---

## 9. Code Organization

**Separation of Concerns:**
```
src/
├── domain/              # Pure domain logic
│   ├── users.rs        # User aggregate (types, commands, events)
│   ├── truck.rs        # Truck aggregate
│   └── expense.rs      # Expense aggregate
└── event_sourcing/     # Event sourcing implementations
    ├── users.rs        # User deciders, evolvers, state
    ├── trucks.rs       # Truck deciders, evolvers, state
    └── expenses.rs     # Expense deciders, evolvers, state
```

**Import Organization:**
```rust
// 1. Standard library
use std::{collections::HashSet, fmt::Display};

// 2. External crates
use serde::{Deserialize, Serialize};
use thiserror::Error;

// 3. Framework
use epoch::decider::{DeciderWithContext, Evolver};

// 4. Internal modules
use crate::domain::truck::TruckId;
```

---

## Summary: Checkable Patterns

**For automated checking:**

1. **Protected Types**
   - Check: No `pub` fields on domain types (except tuple structs)
   - Check: Domain types have `new()` or `from()` methods returning `Result`

2. **No Primitive Obsession**
   - Check: No function signatures with raw `String`, `usize`, `Uuid` for domain concepts
   - Check: Use newtype pattern for all domain IDs

3. **State Machines**
   - Check: State represented with enums, not boolean flags
   - Check: State transitions use `assert_*` methods returning `Result`

4. **Error Handling**
   - Check: No `unwrap()` or `expect()` in non-test code (except Evolvers)
   - Check: All public functions returning fallible operations use `Result`
   - Check: Error types use `thiserror::Error`

5. **Event Sourcing**
   - Check: Deciders are pure (no `async`, no I/O in signature)
   - Check: Evolvers return `Self::State`, not `Result`
   - Check: Events use past tense naming

6. **Naming Conventions**
   - Check: Commands end with `Command`
   - Check: Events use past tense or end with `Event`
   - Check: Errors end with `Error`
   - Check: Deciders end with `Decider`

---

**Last Updated:** 2025-12-11

**Note:** This guideline is based on trucker_buddy coding practices and Scott Wlaschin's "Domain Modeling Made Functional".
