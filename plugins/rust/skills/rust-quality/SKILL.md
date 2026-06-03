---
name: rust-quality
description: |
  Load when writing, reviewing, or planning Rust code to self-correct against
  LLM-specific failure modes the model tends to repeat: clone escapes to satisfy
  the borrow checker, speculative fallbacks for failure modes that don't exist,
  god modules, verbose match chains, and weak error modeling. Provides concrete
  reference patterns (transpose, Arc::clone, newtypes, parse-don't-validate,
  sealed traits) and type modeling rules. For formal reviews, use rust-review;
  it applies these rules as a gate checklist.
compatibility: claude-code opencode
---

# Rust Quality — LLM Anti-Pattern Prevention

Reference patterns by name; do not re-explain them. For reviews, use `rust-review`; it loads these rules and applies the review gate checklist.

## Prefer (by name)

- `transpose()` for `Option<Result<T,E>>` → `Result<Option<T>,E>`
- `Arc::clone(&var)` over `var.clone()` on ref-counted types
- `if let` over single-arm `match` (`clippy::single_match`)
- `.to_owned()` over `.to_string()` on `&str` (`clippy::str_to_string`)
- `.map_err(Variant)` over `.map_err(|e| Variant(e))` when `#[from]` exists
- Explicit enum arms over `_ =>` (`clippy::wildcard_enum_match_arm`)
- Type aliases over `#[allow(clippy::type_complexity)]`
- `thiserror` for libraries, `anyhow` for applications (dtolnay split)
- Parse-don't-validate — reject at construction, not at use (corrode.dev)
- Newtype wrappers for stringly-typed parameters
- Sealed traits for public API stability

## Reject (LLM-specific anti-patterns)

**Sprawl**: adding a helper, trait, module, or abstraction for a single use site. Three similar lines beats a premature abstraction.

**God modules**: if a module exceeds ~500 lines, it's doing too many things. Split by domain concept, not by "utils."

**Speculative fallbacks**: don't write a fallback code path for a failure mode that hasn't manifested. Log warn, test first, add the fallback when a real model/runtime actually fails.

**Clone to satisfy the borrow checker**: restructure ownership instead. Move the clone into a let binding, use `Arc`, or redesign the data flow. `clone()` as a borrow checker escape hatch is the #1 LLM code smell.

**Verbose match chains**: if you're matching on the same value 3+ times in sequence, the data model is wrong. Refactor the enum or use combinators.

**Redundant closures**: `.map_err(|e| Error::Variant(e))` when `Error::Variant` is a function pointer via `#[from]`. The closure is noise.

**Transitive dependency assumptions**: if you `use` a crate, it must be in `[dependencies]`. Compiling via a transitive dep is fragile.

## Type Modeling

- **Newtypes as domain boundaries**: wrap primitives (`struct EmailAddress(String)`) with validation in `::new() -> Result<Self, Error>`. Constrained types sit between raw primitives and complex domain types — reject invalid values at construction, not at use.
- **Protected constructors**: private inner field, public `new()` that validates. No way to construct an invalid instance.
- **Making illegal states unrepresentable**: sum types for state machines — `enum Order { Draft, Submitted(Details), Shipped(TrackingId) }` instead of `status: String` + nullable fields. If it compiles, it's valid.
- **Railway-oriented programming**: `Result` chains with `?` as bind. `and_then()` for two-track composition. Errors compose via `#[from]`, not matched-and-rewrapped.
- **Types before logic**: define types and their transitions before writing business logic.

## After adding an enum variant

Run `cargo build --workspace` immediately. Fix ALL non-exhaustive match errors before any other change. Don't fix them one at a time across build cycles.

## Clippy baseline

Start with `[workspace.lints.clippy]` enabling category groups at warn. See [kristof-mattei/rust-seed](https://github.com/kristof-mattei/rust-seed/blob/main/Cargo.toml) for the most complete public config (127 restriction lints). Adopt progressively — don't dump all 127 at once.

## References

- [Rust API Guidelines](https://github.com/rust-lang/api-guidelines) — checklist for public API design
- [BurntSushi: Error Handling](https://burntsushi.net/rust-error-handling/) — when unwrap is okay
- [corrode.dev: Defensive Rust](https://corrode.dev/blog/defensive-programming/) — newtypes, parse-don't-validate
- [Rust Design Patterns: Anti-patterns](https://rust-unofficial.github.io/patterns/anti_patterns/index.html)
