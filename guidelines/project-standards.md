# Project Rust Standards

**Purpose:** These are your team's agreed-upon coding standards. Update this file as your standards evolve.

**Context Window Impact:** ~10KB (~2,500 tokens, <2% of Claude's 200K context)
**Referenced by:** `/standards`, `/docs`, `/tests`, `/perf`, `/review`

---

## 🚨 Critical Rules (Zero Tolerance)

### 1. No unwrap() or expect() in Production Code

❌ **Never do this:**
```rust
fn get_user(id: UserId) -> User {
    let user = db.find(id).unwrap();  // Will panic on None!
    user
}
```

✅ **Always do this:**
```rust
fn get_user(id: UserId) -> Result<User, Error> {
    let user = db.find(id)
        .ok_or(Error::UserNotFound(id))?;
    Ok(user)
}

// Or with context
use anyhow::Context;
fn get_user(id: UserId) -> anyhow::Result<User> {
    db.find(id)
        .context(format!("User {} not found", id))
}
```

**Exception:** Tests can use unwrap()
```rust
#[test]
fn test_user_creation() {
    let user = create_user(data).unwrap();  // OK in tests
    assert_eq!(user.name, "Alice");
}
```

### 2. All unsafe Must Have SAFETY Comments

❌ **Missing justification:**
```rust
unsafe {
    ptr::write(dest, value);
}
```

✅ **Proper documentation:**
```rust
// SAFETY: `dest` is a valid pointer obtained from Box::into_raw(),
// and we have exclusive access as guaranteed by the borrow checker.
// The value being written matches the expected type and alignment.
unsafe {
    ptr::write(dest, value);
}
```

### 3. Public Items Must Be Documented

❌ **No documentation:**
```rust
pub fn process_payment(amount: f64) -> Result<Receipt> {
    // ...
}
```

✅ **Properly documented:**
```rust
/// Processes a payment transaction.
///
/// This function validates the amount, charges the payment method,
/// and generates a receipt upon successful completion.
///
/// # Arguments
/// * `amount` - The payment amount in USD. Must be positive.
///
/// # Returns
/// A `Receipt` containing the transaction details.
///
/// # Errors
/// * `Error::InvalidAmount` - If amount is zero or negative
/// * `Error::PaymentFailed` - If the payment processor rejects the transaction
///
/// # Examples
/// ```
/// let receipt = process_payment(99.99)?;
/// println!("Transaction ID: {}", receipt.id);
/// ```
pub fn process_payment(amount: f64) -> Result<Receipt> {
    // ...
}
```

---

## 📋 Error Handling Standards

### Use anyhow for Applications, thiserror for Libraries

**Application code** (binaries):
```rust
use anyhow::{Context, Result, bail};

fn load_config(path: &Path) -> Result<Config> {
    let contents = fs::read_to_string(path)
        .context("Failed to read config file")?;
    
    let config: Config = toml::from_str(&contents)
        .context("Failed to parse config")?;
    
    if config.port == 0 {
        bail!("Port cannot be zero");
    }
    
    Ok(config)
}
```

**Library code**:
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ConfigError {
    #[error("Failed to read config file: {0}")]
    ReadError(#[from] std::io::Error),
    
    #[error("Failed to parse config: {0}")]
    ParseError(#[from] toml::de::Error),
    
    #[error("Invalid port number: {0}")]
    InvalidPort(u16),
}
```

### Always Provide Context

❌ **No context:**
```rust
let data = fs::read_to_string(path)?;
let config = serde_json::from_str(&data)?;
```

✅ **With context:**
```rust
let data = fs::read_to_string(path)
    .with_context(|| format!("Failed to read config from {}", path.display()))?;

let config = serde_json::from_str(&data)
    .context("Failed to parse JSON config")?;
```

---

## 🧪 Testing Standards

### Every Public Function Needs Tests

**Minimum requirements:**
1. ✅ Happy path test (normal case works)
2. ✅ Error case test (handles errors correctly)
3. ✅ Edge case test (boundary conditions)

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_user_success() {
        // Happy path
        let user = create_user("alice@example.com", "Alice").unwrap();
        assert_eq!(user.email, "alice@example.com");
    }

    #[test]
    fn test_create_user_invalid_email() {
        // Error case
        let result = create_user("not-an-email", "Alice");
        assert!(matches!(result, Err(Error::InvalidEmail(_))));
    }

    #[test]
    fn test_create_user_empty_name() {
        // Edge case
        let result = create_user("alice@example.com", "");
        assert!(matches!(result, Err(Error::EmptyName)));
    }
}
```

### Use Descriptive Test Names

❌ **Vague:**
```rust
#[test]
fn test_user() { }

#[test]
fn test1() { }
```

✅ **Clear:**
```rust
#[test]
fn test_user_creation_with_valid_email_succeeds() { }

#[test]
fn test_user_creation_with_duplicate_email_fails() { }
```

---

## ⚡ Performance Guidelines

### Avoid Unnecessary Clones

❌ **Wasteful:**
```rust
fn process_items(items: Vec<String>) {
    for item in items.clone() {  // Unnecessary clone!
        println!("{}", item);
    }
    // Original items still available
}
```

✅ **Efficient:**
```rust
// Option 1: Borrow
fn process_items(items: &[String]) {
    for item in items {
        println!("{}", item);
    }
}

// Option 2: Consume if you don't need original
fn process_items(items: Vec<String>) {
    for item in items {  // No clone
        println!("{}", item);
    }
}
```

### Use Appropriate String Types

```rust
// ✅ Good: Accept &str for flexibility
fn validate_email(email: &str) -> bool {
    email.contains('@')
}

// ❌ Bad: Forces allocation
fn validate_email(email: String) -> bool {
    email.contains('@')
}

// ✅ Good: Return String only when creating new data
fn format_name(first: &str, last: &str) -> String {
    format!("{} {}", first, last)
}
```

### Pre-allocate Collections When Size is Known

❌ **Less efficient:**
```rust
let mut items = Vec::new();
for i in 0..1000 {
    items.push(i);  // Multiple reallocations
}
```

✅ **Better:**
```rust
let mut items = Vec::with_capacity(1000);  // Single allocation
for i in 0..1000 {
    items.push(i);
}
```

---

## 📐 Code Organization

### Module Structure

```
src/
├── main.rs           # Application entry point
├── lib.rs            # Library root (if applicable)
├── api/              # HTTP handlers
│   ├── mod.rs
│   ├── users.rs
│   └── auth.rs
├── services/         # Business logic
│   ├── mod.rs
│   ├── user_service.rs
│   └── auth_service.rs
├── models/           # Data structures
│   ├── mod.rs
│   ├── user.rs
│   └── error.rs
├── db/               # Database layer
│   ├── mod.rs
│   ├── queries.rs
│   └── migrations/
└── utils/            # Shared utilities
    ├── mod.rs
    └── validation.rs
```

### File Size Guidelines

- **Modules:** < 500 lines (split if larger)
- **Functions:** < 50 lines (refactor if larger)
- **Test files:** < 1000 lines

---

## 🔒 Security Standards

### Input Validation

**Always validate user input at entry points:**

```rust
// ✅ Validate at API boundary
pub async fn create_user(
    Json(payload): Json<CreateUserRequest>,
) -> Result<Json<User>> {
    // Validate immediately
    if payload.email.is_empty() {
        return Err(Error::InvalidEmail("Email cannot be empty"));
    }
    
    if !payload.email.contains('@') {
        return Err(Error::InvalidEmail("Invalid email format"));
    }
    
    // Now safe to process
    let user = user_service.create(payload).await?;
    Ok(Json(user))
}
```

### No Hardcoded Secrets

❌ **Never:**
```rust
const API_KEY: &str = "sk_live_1234567890";  // Exposed in binary!
const DB_PASSWORD: &str = "supersecret";
```

✅ **Use environment variables:**
```rust
use std::env;

fn get_api_key() -> Result<String> {
    env::var("API_KEY")
        .context("API_KEY environment variable not set")
}
```

---

## 📝 Documentation Guidelines

### First Sentence Must Be < 15 Words

Follows Microsoft guideline M-FIRST-DOC-SENTENCE

❌ **Too long:**
```rust
/// This function takes a user ID and queries the database to retrieve
/// the corresponding user record if it exists, otherwise returning an error.
```

✅ **Concise:**
```rust
/// Retrieves a user by ID from the database.
///
/// Queries the user table and returns the matching record.
```

### Required Sections

For functions that:
- **Return Result:** Need `# Errors` section
- **Can panic:** Need `# Panics` section
- **Are complex:** Need `# Examples` section

```rust
/// Parses and validates a configuration file.
///
/// # Errors
/// * `Error::IoError` - If file cannot be read
/// * `Error::ParseError` - If TOML is malformed
/// * `Error::ValidationError` - If required fields are missing
///
/// # Panics
/// Panics if the file path contains invalid UTF-8 characters.
///
/// # Examples
/// ```
/// let config = parse_config("config.toml")?;
/// println!("Port: {}", config.port);
/// ```
pub fn parse_config(path: &Path) -> Result<Config> {
    // ...
}
```

---

## 📝 Emoji Usage Standards

### No Emojis in Production Code

Emojis should NOT appear in:
- Source code (comments, identifiers, strings)
- End-user facing logs
- Error messages
- API responses

❌ **Bad - Emojis in code:**
```rust
// 🚀 This function is super fast!
pub fn process_data(items: Vec<String>) -> Result<()> {
    tracing::info!("✅ Processing {} items", items.len());  // Bad: emoji in log

    if items.is_empty() {
        return Err(Error::EmptyInput("❌ No items provided".into()));  // Bad: emoji in error
    }

    Ok(())
}

// Variable with emoji (extremely bad!)
let result_✅ = compute();  // Will likely cause issues
```

✅ **Good - Plain text:**
```rust
/// This function processes data efficiently
pub fn process_data(items: Vec<String>) -> Result<()> {
    tracing::info!("Processing {} items", items.len());

    if items.is_empty() {
        return Err(Error::EmptyInput("No items provided".into()));
    }

    Ok(())
}
```

**Rationale:**
- Emojis break in many terminals and log aggregators
- Not searchable or parseable by standard tools
- Unprofessional in production systems
- Can cause encoding issues in databases/APIs
- Make logs harder to grep/filter

**Exception:** Documentation and developer-facing content
- ✅ README.md, ARCHITECTURE.md (for visual organization)
- ✅ Internal comments in examples/demos (sparingly)
- ✅ Development-only debug output (if helpful)
- ❌ Never in production logs or error messages

### Limited Emojis in Documentation

**Use sparingly in technical documentation:**

✅ **Acceptable use (visual organization):**
```markdown
## 🚨 Critical Issues
## ✅ Completed Features
## 🔧 Configuration
```

❌ **Overuse that reduces professionalism:**
```markdown
## 🎉🎊 Super Amazing Feature! 💯✨
The code is 🔥🔥🔥 and works like 🚀!!!
```

**Guidelines:**
- Max 1-2 emojis per heading
- Use standard, widely recognized emojis
- Be consistent (same emoji for same concept)
- Consider your audience (internal vs public docs)
- When in doubt, leave it out

---

## 🎯 Things We Care About Most

Priority order:

1. **Safety** - No panics, proper error handling
2. **Security** - Validate inputs, no secrets
3. **Documentation** - Clear, complete docs
4. **Testing** - Good coverage
5. **Performance** - Efficient code
6. **Style** - Idiomatic Rust

---

## 🔧 Tools We Use

**Required before commit:**
```bash
cargo fmt          # Format code
cargo clippy       # Lint
cargo test         # Run tests
```

**Recommended:**
```bash
cargo watch -x test              # Auto-run tests
cargo tarpaulin                  # Test coverage
cargo audit                      # Security audits
cargo bloat --release           # Binary size analysis
```

---

## 📚 Learning Resources

- [Microsoft Rust Guidelines](https://microsoft.github.io/rust-guidelines/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Effective Rust](https://www.lurklurk.org/effective-rust/)
- [Rust Performance Book](https://nnethercote.github.io/perf-book/)

---

**Last Updated:** [Add date when you modify this file]

**Note:** This is a living document. Update it as your team's practices evolve.
