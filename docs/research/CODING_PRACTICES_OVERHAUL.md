# Rust Coding Practices Overhaul

<!--toc:start-->

- [Sources of Coding Guidelines (scattered)](#sources-of-coding-guidelines-scattered)
- [Gates](#gates)
- [Steering Tools](#steering-tools)
- [Prior claude web research doc](#prior-claude-web-research-doc)
<!--toc:end-->

## Sources of Coding Guidelines (scattered)

- `~/dev/trucker_buddy_rs/` - has CODING_PRACTICES.md covering many things,
  some only relevant to event sourcing/ddd - we can leave those ones out

- `~/dev/agent-driver-rs/` - hand written by me with strong rust type use opinions
  even though it's on a much older version of rust. This repo is LLM generated
  not hand written by me but it has some good types guidance in the Claude.md

- `~/dev/Epoch/` - heavy type only framework for event sourcing - lots to learn
  about how I like to code types even though it's definitely older work
  (older rust, older cargo)

- `~/dev/claude-skills/` - use this one with caution - there are some of my
  hand written nuggets about how I like to code rust but also an overly heavy
  handed attempt at integrating Microsofts rust guidelines for agents which
  caused me problems especially in the verbose unmaintained comments

- `~/workspace/aura-orchestration-mode/` - our main repo but this is highly
  LLM coded and misses some good principles to avoid sprawl. We should analyze
  this for pain points that could have been prevented by rules - especially in
  the orchestration module which is a huge god module with a lot of code sprawl
  and verbose match statements.

## Gates

- I've had good luck recently with adding quality gates to my plans including
  decent times to reach out to and contact the user (me) for manual review but
  only after pre review gates - some of these are coding style agnostic but
  worked well

  - The code quality self-probes at each gate were:

    1. Are we sprawling code unnecessarily?
    2. Did we heavily duplicate functionality we already had?
    3. Are we building "god classes" or "god modules"?
    4. Will a developer be able to review and follow what we wrote?

## Steering Tools

- Rust seed - while I feel like some of these rules are overly pedantic and
  heavy handed there is some merit in heavy handed linting steering agents:
  <https://github.com/kristof-mattei/rust-seed/blob/main/Cargo.toml>. This is my
  buddy Kristofs config - it would be nice to use a subset of that to enforce
  what I want. My only problem with it is the overly pedantic clone and memory
  management - I like to value readability over premature clone optimizations
  but maybe we can't have both here. Maybe take this config and enhance it? I
  was actually able to use that in ~/dev/agent-driver-rs/ to do a test
  conversion to clean up the code in a worktree
  ~/dev/agent-driver-rs/.claude/worktrees/progressive-lints/ - you be the judge
  on how well that went based on whats in main. Surprisingly claude made short
  work of it by progressive-lints in a Ralph loop. Maybe we find a happy medium
  that works here.

## Prior claude web research doc

- RustTypeSafetyBenchmarks.md is in this repo - it's a prior work downloaded
  from claude desktop on benchmarking and driving rust coding agents into
  better code and evaluating it. This might be useful in some of our guidelines
  and skills design and might be even more interesting to measure this across
  models and coding agent harnesses

---

## Case Study: SSE Transport Re-Enablement in Aura (May 2026)

_OpenCode DeepSeek planner — K2.6 Rust coding session with exceptional planning_

This was a well-executed workflow that I want to preserve. The task was to
re-enable legacy SSE MCP transport in Aura after rmcp removed it upstream.
The model demonstrated strong Rust domain knowledge (visibility rules,
`transpose()`, trait system) and, more importantly, the discipline to verify
assumptions against actual API surfaces before writing code.

### Phase 0: Spec Interview — Don't Jump to Implementation

Before any code was written, the agent:

1. **Launched 4 parallel background agents** to explore different facets:

   - SSE transport in Aura's codebase (what existed, what was removed)
   - RMCP's SSE feature flags and API surface across versions (0.7, 0.12, 0.14)
   - Documentation references to SSE across the repo
   - All `pub(crate)` visibility and `#[cfg(feature)]` gate checks

2. **Asked clarifying questions** rather than assuming the goal. The initial
   assumption was "RMCP put SSE behind a feature flag" but research revealed it
   was _removed entirely_. This changed the approach from "flip a flag" to
   "re-implement the transport."

3. **Cross-referenced alternative designs** — I presented a proxy-based
   approach document and the agent systematically analyzed tradeoffs:

   - Both approaches needed the same SSE transport re-implementation
   - The proxy added caching value but also operational complexity
   - The native approach was chosen as Phase 1, proxy deferred to Phase 2

4. **Rejected forks** — I didn't want to fork rmcp. The agent correctly
   identified that rmcp 0.12's `client-side-sse` module still contains the
   building blocks (`BoxedSseResponse`, `SseRetryPolicy` types) even though
   the standalone `SseTransport` type was removed.

### Phase 1: Type System Verification (Pre-Code Gate)

Before writing a single line of implementation, the agent:

1. **Proved `SseAutoReconnectStream` is truly inaccessible** — not just by
   reading the `pub(crate)` annotation, but by checking:

   - Every `pub use` in rmcp's `lib.rs`, `transport.rs`, `common.rs`
   - Every `pub mod` with `#[cfg(feature)]` gates
   - Whether `streamable_http_client` re-exports anything
   - Whether `from_transport()` or any trait exposes the type indirectly
   - Result: confirmed inaccessible across both rmcp 0.12 AND 0.14

2. **Verified no hidden feature flags** — checked both `Cargo.toml` and
   `Cargo.toml.orig` for both rmcp 0.12 and 0.14. No `transport-sse`,
   `transport-sse-client`, or `transport-sse-client-reqwest` exist.

3. **Read the actual rmcp `Transport` trait** (only 3 methods: `send`, `receive`,
   `close`) and confirmed `serve_client()` is generic over any transport.

4. **Read the old rmcp 0.7.0 SSE transport source** (extracted from cached
   `.crate` files) to understand the protocol flow: GET SSE endpoint → parse
   `endpoint` event → POST to resolved message endpoint.

This pre-verification meant the implementation plan was based on _actual API
surface_, not assumptions. The critical Rust skill here: understanding that
`pub(crate)` items can still be accessible via `pub use` re-exports from parent
modules — and systematically checking all re-export chains before concluding
they're inaccessible.

### Phase 2: Staged Implementation with Gates

The plan was split into 5 stages, each with explicit gates:

| Stage             | What                                                         | Gate                                      |
| ----------------- | ------------------------------------------------------------ | ----------------------------------------- |
| 1 — Rename        | `StreamableHttpMcpClient` → `McpClient` (35 refs, 7 files)   | build + clippy + test                     |
| 2 — Core types    | `SseTransportError`, `SseTransport`, `mcp_sse.rs`            | build + clippy + agent code-quality probe |
| 3 — Constructor   | `McpClient::from_transport()` transport-agnostic constructor | build + test + clippy                     |
| 4 — Config+Wiring | Config variants, McpManager dispatch, tool registration      | build + clippy + fmt                      |
| 5 — Tests+Docs    | Unit tests, README/CLAUDE.md fixes, final gate               | workspace build+test+clippy+fmt           |

**Code quality probes at each gate** (background agent self-reflection):

1. Are we sprawling code unnecessarily?
2. Did we heavily duplicate functionality we already had?
3. Are we building "god classes" or "god modules"?
4. Will a developer be able to review and follow what we wrote?

### Key Rust Patterns Demonstrated

**1. `Option::transpose()` for `Option<Result<T, E>>` → `Result<Option<T>, E>`**

Before (double `??` — hard to read):

```rust
let sse = stream.next().await
    .ok_or(SseTransportError::MissingEndpointEvent)??;
```

After (semantic clarity):

```rust
let sse = stream.next().await
    .transpose()
    .map_err(SseTransportError::SseStream)?
    .ok_or(SseTransportError::MissingEndpointEvent)?;
```

Each `?` now handles exactly one concern: stream error vs missing event.

**2. Pattern matching on tuples to combine conditions**

Before (sequential checks, each needing `continue`):

```rust
if sse.event.as_deref() != Some("message") { continue; }
let data = match sse.data { Some(data) => data, None => continue };
match serde_json::from_str(&data) { ... }
```

After (one pattern, one branch):

```rust
if let (Some("message"), Some(data)) = (sse.event.as_deref(), sse.data) {
    match serde_json::from_str(&data) { ... }
}
```

**3. Match with guard for type discrimination (no `unwrap_or(false)`)**

Before (conflates missing and unexpected into one variant):

```rust
let content_type: Option<String> = ...;
if !content_type.as_deref().map(|ct| ct.starts_with("text/event-stream")).unwrap_or(false) {
    return Err(UnexpectedContentType(content_type)); // None becomes "got None" error
}
```

After (concrete types, proper discrimination):

```rust
match response.headers().get(CONTENT_TYPE).and_then(|v| v.to_str().ok()) {
    Some(ct) if ct.starts_with("text/event-stream") => {}
    Some(ct) => return Err(UnexpectedContentType(ct.to_string())),
    None => return Err(MissingContentType),
}
```

**4. No `unwrap()`/`expect()` in business logic** — every fallible operation
uses `?` propagation through `Result`. Error types compose via `#[from]`
derives.

**5. Protocol constants** — `"message"` and `"endpoint"` are magic strings in
the SSE protocol. Extracted as `const SSE_EVENT_MESSAGE: &str` and
`const SSE_EVENT_ENDPOINT: &str` at module scope.

### Design Decision: Avoid Client Type Duplication

The biggest sprawl-avoidance decision: NOT creating a separate `SseMcpClient`
type. `StreamableHttpMcpClient` (renamed to `McpClient`) already wraps a
`RunningService<RoleClient, ProgressEnabledHandler>`. All 11 of its methods
(`call_tool`, `call_tool_tracked`, `call_tool_with_progress`,
`call_tool_with_cancellation`, `cancel_all_for_request`, `cancel_and_close`,
`discover_tools`, etc.) are transport-agnostic — they only call `self.client`
which is the `RunningService`. Creating a parallel `SseMcpClient` would have
duplicated ~450 lines of identical method bodies.

Instead: added a single `from_transport<T: Transport<RoleClient>>()` constructor
that accepts ANY transport. Both HTTP streamable and SSE connect through it.
`HttpMcpToolAdaptor` was renamed to `McpToolAdaptor` (transport-agnostic, no
duplicate adaptor needed). `execute_http_mcp_tool` → `execute_mcp_tool`. Net
new logic was ~200 lines in `mcp_sse.rs` + `error.rs`, with ~120 lines of
config wiring following existing patterns.

### Post-Implementation Audit

After staging was complete, a background agent audited the entire MCP request
ID / tool call ID pipeline to verify the SSE transport didn't introduce any
correlation bugs. Confirmed: `ToolEventBroker` (FIFO queue), `InFlightRequests`
(tracker), `ProgressEnabledHandler`, and `call_tool_tracked()` are all
completely transport-agnostic. No bypass paths exist.

### Rust Friction Points — Feedback from OpenCode DeepSeek K2.6 Session

Concrete mistakes the model made during implementation that could have been
avoided with better upfront instructions or workflow discipline. These are
preserved as agent-instruction enhancements for future sessions.

**1. Non-exhaustive match when adding an enum variant (4 missed locations)**

When `Sse` was added to `McpServerConfig`, the compiler rejected the build
because match statements in 4 files didn't cover the new variant:
`builder.rs`, `debug_config.rs`, `architecture_diagram.rs`, `config_test.rs`.
Each required a separate fix cycle (build → error → grep → edit → rebuild).

**Prevention**: After adding an enum variant, immediately `cargo build` to
let the compiler surface _all_ non-exhaustive matches in one pass. Better:
run `cargo clippy --workspace` which also checks test targets and binaries
that `cargo build` alone might skip.

> **Agent instruction**: "When adding a variant to an enum that appears in
> `match` statements across the workspace, run `cargo build --workspace`
> immediately after the addition and fix ALL non-exhaustive match errors
> before proceeding to the next change."

**2. Redundant closure in `.map_err(|e| Error::Variant(e))`**

Original:

```rust
.map_err(|e| BuilderError::SseTransport(e))?
```

Should be:

```rust
.map_err(BuilderError::SseTransport)?
```

The `#[from]` derive on `BuilderError::SseTransport(SseTransportError)`
generates a `From<SseTransportError> for BuilderError` implementation. Passing
the variant directly as a function pointer is idiomatic Rust — the compiler
auto-coerces. The closure was redundant and clippy flagged it.

**Prevention**: clippy caught this, but it's a pattern agents should know.
When a variant has `#[from]`, `.map_err(TheVariant)` works without wrapping
in a closure.

> **Agent instruction**: "When an error variant uses `#[from]` to derive
> `From<InnerError>`, prefer `.map_err(OuterError::Variant)` over
> `.map_err(|e| OuterError::Variant(e))`. The former is zero-cost and
> clippy-clean."

**3. `match` on a single pattern instead of `if let`**

```rust
// Clippy rejected:
match (sse.event.as_deref(), sse.data) {
    (Some("message"), Some(data)) => { ... }
    _ => {}
}

// Clippy accepted:
if let (Some("message"), Some(data)) = (sse.event.as_deref(), sse.data) {
    ...
}
```

**Prevention**: `clippy::single_match` catches this reliably. The real issue
was that the agent wrote `match` first and clippy forced a rewrite — wasting
a build cycle. Agents should default to `if let` for single-arm patterns.

> **Agent instruction**: "When destructuring an enum/tuple with only one
> interesting arm, start with `if let`. Use `match` only when handling
> multiple arms or when exhaustiveness checking is semantically important."

**4. Missing direct dependency (transitive dependency assumption)**

`mcp_sse.rs` uses `http::Uri` and `url::Url`, but neither was listed as a
direct dependency in `Cargo.toml`. They compiled because rmcp transitively
depends on `http` and another crate depends on `url`. This is fragile — a
future rmcp version could drop the `http` dependency and break the build
without warning.

**Prevention**: Rust allows using transitive dependencies at compile time,
but they are not guaranteed. Any type used in a public API or struct
definition should be behind an explicit dependency.

> **Agent instruction**: "Before using a crate in `use` statements or type
> signatures, verify it appears in `[dependencies]` of the current crate's
> `Cargo.toml`. If it's only transitively available, add it as a direct
> dependency to the workspace or crate."

**5. Type complexity without a type alias**

The stream field:

```rust
#[allow(clippy::type_complexity)]
stream: Option<Pin<Box<dyn Stream<Item = Result<Sse, SseError>> + Send>>>
```

The `#[allow(...)]` suppresses `clippy::type_complexity` rather than solving
it. A type alias would be cleaner:

```rust
type BoxedSseStream = Pin<Box<dyn Stream<Item = Result<Sse, SseError>> + Send>>;
```

rmcp already defines `BoxedSseResponse` (a public type alias for this exact
pattern), but it's `BoxStream<'static, Result<Sse, SseError>>` — slightly
different from `Pin<Box<dyn Stream<...>>>`. Creating a local alias is
preferable to suppressing the lint.

> **Agent instruction**: "When clippy flags `type_complexity`, define a
> type alias at module scope. Only use `#[allow(...)]` when the complexity
> is intentional and a rename would obscure meaning."

**6. Double `??` without `transpose()` (not a bug, but hard to read)**

Original:

```rust
let sse = stream.next().await
    .ok_or(SseTransportError::MissingEndpointEvent)??;
```

`stream.next().await` returns `Option<Result<Sse, SseError>>`. The `.ok_or()`
wraps the `Option` into `Result<Result<Sse, SseError>, SseTransportError>`.
The first `?` unwraps the outer `Result`, the second `?` unwraps the inner.
This is correct but obscures which `?` handles which failure.

`Option::transpose()` converts `Option<Result<T, E>>` into `Result<Option<T>, E>`,
making each `?` handle exactly one concern.

**Prevention**: This is a Rust-specific API knowledge gap. `transpose()` is
stable since Rust 1.33 and is the idiomatic tool for this pattern.

> **Agent instruction**: "When working with `Option<Result<T, E>>`, prefer
> `.transpose()` followed by two single-concern `?` operators over a nested
> `.ok_or()??` pattern. This makes error propagation intent explicit."

### Friction from PR on SSE MCP tools

Both code guidance suggestions and lint rules are provided: ~/workspace/aura-session-docs/docs/code-quality-guide.md

### Audit how to best leverage training vs direction for rust quality

Our own rust architecture guidelines are very important but whenever possible
we should be pointing our claude.md instructions and skills to architectural concepts
that exist in an agents training. Its a lot more efficient to reference trained data
than it is to verbosely explain architectural concepts and certain factions of rust dev
from scratch.
