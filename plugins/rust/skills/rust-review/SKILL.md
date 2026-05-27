---
name: rust-review
description: Use when reviewing Rust code, preparing PRs with .rs changes, running pre-commit checks on Rust code, or when the user asks to review a diff. Run gate-probes first for universal checks, then these Rust-specific probes. Always load before presenting Rust code review findings to the user.
---

# Rust Review Gates

Load `rust-quality` for the quality rules being checked. Run `gate-probes` first for universal checks. Then apply these Rust-specific probes against the diff.

## Rust probes

1. **Clone escape?** — Did we `clone()` to satisfy the borrow checker instead of restructuring ownership?
2. **Wildcard enum?** — Any `_ =>` that will silently absorb future enum variants?
3. **Transitive deps?** — Any `use` of a crate not in `[dependencies]`? Compiling via transitive dep is fragile.
4. **Redundant closure?** — Any `.map_err(|e| Variant(e))` where `Variant` has `#[from]` and `.map_err(Variant)` works?
5. **Type complexity suppressed?** — Any `#[allow(clippy::type_complexity)]` that should be a type alias?
6. **Single-arm match?** — Any `match` with one arm + `_ => {}` that should be `if let`?
7. **Nested match over combinators?** — Nested `match` on `Option`/`Result` where `.map()`, `.and_then()`, `.map_err()` would be flatter and clearer?
