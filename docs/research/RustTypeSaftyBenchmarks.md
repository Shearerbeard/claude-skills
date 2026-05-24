# A Type-Safety Benchmark and Skill for Rust Coding LLMs

## TL;DR

- **Build the benchmark on three layers stacked together**: (1) functional correctness via `cargo test` + hidden integration tests, (2) machine-checkable type-safety signals from `cargo clippy --message-format=json` (with a strict `[lints.clippy]` block that bans `unwrap`, `panic`, `dbg!`, `allow_attributes`, etc.) plus AST analysis of submitted code with the `syn` crate (counting newtypes, custom error enums, exhaustive matches, `#[non_exhaustive]`, `PhantomData`/typestate markers, `const` items), and (3) an LLM-as-judge rubric that scores design-level qualities like "encodes invariants in types" and "parses, doesn't validate." Drive everything from `inspect-ai` (Python harness, agent-friendly, supports Claude Code / Codex CLI / opencode as external agents), with `promptfoo` as a lighter alternative for prompt-only comparisons.
- **Use a three-stage agent protocol per task** — *Plan* (LLM produces only a `types.rs` file with type signatures and an `ARCHITECTURE.md`, no implementations), *Execute* (LLM implements against its own plan, must compile clean under strict clippy), *Review* (a fresh LLM session sees only the diff and a checklist and must produce a structured JSON critique). Score each stage independently; the headline score is a weighted blend (correctness 40%, static type-safety signals 35%, judge rubric 15%, review-stage detection-rate 10%). Tasks should be deliberately rigged with primitive-obsession traps, illegal-state traps, and stringly-typed traps (e.g., "implement a payment processor with currency, amount, and order state") so that idiomatic and naive solutions diverge sharply on the static metrics.
- **Ship a single companion `rust-types` skill (~250–400 lines of SKILL.md) using progressive disclosure**: the SKILL.md contains six imperative-with-rationale principles, a decision tree for "should this be a newtype, an enum, or a typestate?", a `Cargo.toml` `[lints]` snippet, and references to subfiles (`references/error-handling.md`, `references/typestate.md`, `examples/`). Follow Anthropic's authoring guidance — be terse, "explain the why, not the what," avoid all-caps `MUST`/`NEVER` in favor of reasoning, front-load triggering keywords in `description:`, and keep the in-context body under ~200 lines so it fits both Claude Code (`.claude/skills/`) and opencode (`.opencode/skills/` or `.claude/skills/`) without burning context.

---

## Key Findings

### 1. The Rust-specific benchmark gap is real and unfilled
Existing major code benchmarks evaluate Rust only at the *correctness* level and largely on isolated Exercism-style problems or repository patches:
- **Aider Polyglot** uses 225 Exercism problems across 6 languages including Rust, scored purely on `cargo test` pass-rate over two attempts.
- **Multi-SWE-bench** (ByteDance, 2025) and **Rust-SWE-bench** (500 tasks, 34 repos) measure issue-resolution PR patches with hidden test suites.
- **RustEvo²** (588 API changes from std + 15 crates) evaluates version-aware API usage, finding behavioral-change tasks score only ~38%.
- **CRUST-Bench** is the closest existing analogue: 100 C-to-safe-Rust transpilation tasks where authors hand-wrote *Rust interface files* that pin down idiomatic, memory-safe signatures. It demonstrates that authored type signatures are a viable harness for measuring "idiomaticity," but it is transpilation-only.
- The **RACE** benchmark and the "Static Analysis as a Feedback Loop" paper (arXiv 2508.14419) show that *coupling LLM coding evals to static-analysis tools* (Pylint/Bandit for Python) significantly differentiates models that pass tests but produce poor-quality code. No public benchmark currently does this for Rust's type system.
- **DevQualityEval v1.1** (Symflower) reports that even strong models stumble on idiomatic `Result` for error handling in Rust — a direct empirical signal that type-driven design quality is *not* captured by today's benchmarks.

This gap is the opportunity: a Rust benchmark that grades on *how* the type system was used, not just whether tests pass.

### 2. The type-driven principles you specified map cleanly onto compiler-checkable artifacts

| Principle | Detection signal |
|---|---|
| Make impossible states unrepresentable | Sum types (`enum`) per domain concept; absence of `Option<X>, Option<Y>` pairs that should be a single enum; presence of `PhantomData` typestate markers; `#[non_exhaustive]` on public enums |
| Newtype over primitives | Tuple struct wrappers (`struct Foo(u64)`) as field types; ratio of domain fields typed as `String`/`u64`/`bool` vs. as named newtypes |
| Proper error typing | Presence of `#[derive(thiserror::Error)]` enums; `Box<dyn Error>` or `String` in public `Err` types is a negative; clippy lints `unwrap_used`/`expect_used`/`panic`/`unwrap_in_result` count |
| Reduce invariants / parse-don't-validate | Constructors named `parse`/`try_new`/`try_from` returning `Result<Self, _>`; private inner fields with public smart constructors; `TryFrom` impls |
| Enums and consts over stringly-typed | Count of `&str`/`String` parameters representing enumerable choices; `const`/`static` definitions vs. magic literals; clippy `disallowed_types` config disallowing chosen primitives |
| Exhaustive pattern matching | Absence of `_ =>` wildcards on owned enums; `non_exhaustive_omitted_patterns` warnings; clippy `wildcard_enum_match_arm` |

These map neatly to programmatic checkers: `cargo clippy --message-format=json` for the lint signals (with the `clippy::restriction` group selectively enabled), and the `syn` crate (run inside a small Rust-based judge) for structural AST checks like "count tuple-struct newtypes used as field types."

### 3. Rust API Guidelines and the canonical authorities

The benchmark and skill should anchor authority in well-established sources:
- **Rust API Guidelines, "Type Safety" chapter** (`rust-lang.github.io/api-guidelines/type-safety.html`) — explicitly endorses newtypes (C-NEWTYPE), enums over flag-collections, and "deliberate types … to convey interpretation and invariants."
- **Yaron Minsky's "Make Illegal States Unrepresentable"** (2010 Effective ML talk) is the originating slogan, often paired with Scott Wlaschin's F# elaboration.
- **Alexis King, "Parse, Don't Validate"** (2019). King later clarified in "Names are not type safety" that simple newtypes are weaker than fully-parsed refined types; the benchmark should reward genuine parsing constructors (returning `Result`) over name-only wrappers.
- **corrode.dev "Make Illegal States Unrepresentable"** and **howtocodeit.com "Ultimate Guide to Rust Newtypes"** are the most cited practical Rust write-ups.
- **Microsoft's RustTraining patterns book** documents the typestate / `PhantomData` pattern with the connection-state and traffic-light examples that translate well into benchmark tasks.
- **Luca Palmieri, "Error Handling In Rust — A Deep Dive"** and Nick Groenen's "Structuring and handling errors in 2020" together establish the consensus framing: `thiserror` for *handleable* errors (libraries, when callers will branch on the variant), `anyhow`/`eyre` for *reportable* errors (apps, when the caller will only log/exit). Palmieri specifically warns against the simplistic "library vs application" framing — the right axis is "do you expect the caller to programmatically branch?"

### 4. Clippy is already a usable type-safety scoring engine

The Rust ecosystem has mature lints that align almost one-to-one with the principles in scope. A `Cargo.toml` `[lints.clippy]` table (a 2024-stable feature) lets the benchmark force-deny the following without modifying source:

```toml
[lints.clippy]
pedantic = { level = "warn", priority = -1 }
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
panic_in_result_fn = "deny"
unwrap_in_result = "deny"
allow_attributes = "deny"   # crucial: prevents the model from silencing lints
allow_attributes_without_reason = "deny"
dbg_macro = "deny"
todo = "deny"
print_stdout = "deny"
exhaustive_enums = "warn"     # forces conscious choice via #[non_exhaustive]
exhaustive_structs = "warn"
wildcard_enum_match_arm = "deny"
match_wildcard_for_single_variants = "deny"
string_slice = "warn"
```

Plus a `clippy.toml`:
```toml
disallowed-types = [
    { path = "std::collections::HashMap", reason = "use a typed wrapper or BTreeMap"},
]
cognitive-complexity-threshold = 15
type-complexity-threshold = 200
```

The `vicnaum/rust-magic-linter` repo on GitHub is a working example of exactly this approach distributed as a skill ("Turn 'taste' into compiler errors" — `allow_attributes = "deny"` is highlighted as the load-bearing lint that prevents AI agents from `#[allow]`-bypassing.) The benchmark should adopt this approach essentially verbatim. Output is consumed via `cargo clippy --message-format=json` and parsed (existing tools: `clippy-sarif`, `sarif-fmt`).

### 5. Eval-harness landscape

- **`inspect-ai`** (UK AI Security Institute) is the strongest fit. It is Python-native, treats evaluations as `Task = Dataset + Solver + Scorer`, supports Docker/K8s sandboxes (essential for executing untrusted LLM-generated Rust), has first-class agent support including running external CLI agents like Claude Code, Codex CLI, and Gemini CLI as solvers, and the `aisi-inspect` package on PyPI ships a web log viewer. Its scorer composition (`model_graded_qa`, custom Python scorers) makes it natural to combine the three signal layers.
- **`promptfoo`** (now part of OpenAI) is YAML-driven, lighter, and excellent for the prompt-only comparison phase (system-prompt bake-offs); its `llm-rubric` assertion type is convenient for the judge layer but it lacks first-class agent/sandbox primitives.
- **EleutherAI `lm-evaluation-harness`** is for outcome benchmarks and lacks rubric infrastructure.
- **Aider's polyglot harness** is itself runnable and worth using as the *baseline* correctness harness; the new benchmark can extend it by adding the static-analysis post-pass.

The recommended split: `inspect-ai` for the production benchmark (it can drive Claude Code, opencode, aider, and any OpenAI/Anthropic-compatible API model uniformly through its `bridge` interface and Docker sandboxes); `promptfoo` for rapid skill iteration where the LLM is just answering "design this type" questions without tool use.

### 6. LLM-as-judge for the design-quality signal

The "RACE" and "Static Analysis as a Feedback Loop" papers, plus established LLM-judge methodology (Eugene Yan's survey, Webflow case study, AWS Nova rubric judge), converge on a few rules that the design-quality scorer must follow:
- **Score per criterion, then aggregate deterministically** — don't ask the judge for a single 1-10. Ask binary or 1-3 ratings on each principle (newtype usage, error typing, etc.) and sum. This dramatically reduces position/verbosity bias.
- **Always provide a reference solution** in the judge prompt. King's, Palmieri's, and corrode.dev's worked examples can serve as reference solutions for the canonical traps.
- **Use a different model family as judge** than the one being evaluated (self-preference bias is well-documented).
- **Run pairwise both orderings** when comparing two solutions (position bias).
- **Validate the judge against ~30 hand-graded examples** before scaling — aim for ≥80% agreement with human grading, the threshold from Arize/Langfuse practitioner consensus.

### 7. Skill / system-prompt design constraints

Anthropic's official Skill authoring guide and the broader community best practices (HumanLayer's "Writing a good CLAUDE.md," Generative Programmer's "Skill Authoring Patterns," obra/superpowers) converge on these rules, and the Rust skill should follow them:
- **Frontier reasoning models reliably attend to ~150–200 instructions; smaller models, fewer.** (HumanLayer.) Therefore a Rust-style skill should ship as ≤30 high-density imperatives with rationale, not 200 micro-rules.
- **Default assumption: Claude is smart.** Cut anything the model already knows (the meaning of `Result<T, E>` doesn't need explaining).
- **Description field is a trigger, not a summary** — front-load keywords like "Rust, type-driven, newtype, typestate, error handling" so progressive-disclosure activation fires.
- **"Explain the why, not the what."** Replace "MUST use newtypes for IDs" with "Use newtypes for IDs because raw `u64` lets a `UserId` be passed where an `OrderId` is expected; the compiler should catch that, not code review."
- **Progressive disclosure is real and free.** Anything specialized (a long discussion of `PhantomData` variance, a typestate state-machine recipe, an error-handling decision tree) goes in `references/<topic>.md` files that the agent loads only on demand.
- **Skills are filesystem-portable.** Both Claude Code (`.claude/skills/<name>/SKILL.md`) and opencode (`.opencode/skills/...` and Claude-compatible `.claude/skills/...`) consume the same `SKILL.md` format with YAML frontmatter (`name`, `description`); Codex CLI uses `.agents/skills/`. A single skill directory works across all three with no changes.

---

## Details

### A. Benchmark architecture

#### Task taxonomy (target ~80–120 tasks, distributed)

1. **Newtype-trap tasks (~25)** — The prompt looks innocent (e.g., "function `transfer(from: u64, to: u64, amount: u64)`") but hidden tests pass mismatched arguments to detect whether the LLM introduced `AccountId` and `Cents` newtypes. A correct solution refuses the primitive signature.
2. **Illegal-state tasks (~20)** — Domain models with implicit invariants: `Contact` that must have at least an email *or* a phone (Wlaschin's example), `Connection` whose `send` is only meaningful after `connect`, `Order` whose `tracking_number` only exists after `Shipped`. The reference solution uses sum types or typestate; flat structs with `Option<T>` everywhere score lower.
3. **Stringly-typed tasks (~15)** — Configuration/state input arrives as JSON or `&str`; the model must parse it into `enum`s with `serde` `#[serde(rename_all = "snake_case")]` rather than carrying `String` around.
4. **Error-typing tasks (~15)** — A library function with three failure modes (IO, parse, business-rule). Hidden tests check that callers can pattern-match on a public error enum (so `Box<dyn Error>` and `anyhow::Error` in the public API fail). Application-style tasks invert this — `anyhow` is correct for the binary, but library extractions must export a `thiserror` enum.
5. **Exhaustive-match tasks (~10)** — Tasks where a new enum variant will be added in a "v2" hidden test. A solution using `_ => ...` silently swallows the new variant; a solution using exhaustive matches forces a compile error and hence "passes" the v2 test only after the model reacts.
6. **Const-generic / typestate tasks (~10)** — Bounded array sizes, fixed-precision numbers, state-machine APIs (e.g., `Builder` that requires `with_url()` before `build()`).
7. **Refactor-for-types tasks (~10)** — Take an existing primitive-obsessed function and refactor; the score is delta in type-safety signals between input and output.
8. **Repository-level tasks (~10)** — Drawn from Multi-SWE-bench Rust slice; longer agent runs that test whether the agent maintains type discipline across a real codebase.

For each task ship: `prompt.md`, `Cargo.toml` with the strict `[lints.clippy]` block, `src/lib.rs` skeleton, `tests/public.rs` (visible to the model), `tests/hidden.rs` (used only by the harness), `reference/` (canonical solution + design notes used by the judge), and `metadata.toml` declaring which principles the task primarily exercises (so per-principle scores can be computed).

#### Three-stage execution

**Stage 1 — Plan.** The model is given the prompt and *must* produce only `src/types.rs` (type and trait declarations, no bodies — `unimplemented!()` is allowed) and a `ARCHITECTURE.md` (≤300 words). The harness compiles `types.rs` (with `cargo check`) and runs `syn`-based AST analysis to count: newtypes introduced, enums introduced, exhaustive vs. non-exhaustive enums, typestate markers, error enums. **Plan score** = principle-weighted sum of these counts vs. a per-task expected baseline.

**Stage 2 — Execute.** The model now writes implementations. Three sub-scores:
- *Functional* = fraction of public + hidden tests passing under `cargo nextest run` (machine-readable JSON output via `cargo nextest --message-format libtest-json`).
- *Static* = scaled inverse of clippy diagnostic count under the strict `[lints.clippy]` block, parsed from `cargo clippy --message-format=json`. Critical lints (`unwrap_used`, `panic`, `wildcard_enum_match_arm`, `allow_attributes`) get higher weight. Use `clippy-sarif` to normalize output.
- *Structural* = `syn`-based AST checks on the *implementation* (e.g., did the public API actually take `UserId` rather than `u64`?).

**Stage 3 — Review.** A fresh agent session receives only the *diff* from a primitive-obsessed strawman to the model's solution, plus a structured rubric ("List up to N type-safety improvements that could still be made"). The harness scores the model's review against a hand-curated list of "remaining issues" the strawman has — high recall on real issues + high precision (no hallucinated issues) gives the review score. This is what tests the model's ability to *recognize* type-safety problems, not just produce them.

#### Final aggregation

```
overall = 0.40 * functional
        + 0.20 * static
        + 0.15 * structural
        + 0.15 * llm_judge_rubric
        + 0.10 * review_stage
```

Per-principle subscores are also exposed (newtype, error-typing, exhaustive-match, etc.), so a leaderboard can show, e.g., "Model X is great at newtypes but routinely uses `_ =>` wildcards."

### B. Concrete tooling stack

- **Harness:** `inspect-ai` (Python). Each task is an `inspect_ai.Task` whose solver is either an OpenAI/Anthropic chat call or an external-agent bridge to Claude Code / opencode / aider; the scorer is a custom Python function that orchestrates the multi-stage protocol below.
- **Sandboxing:** Docker images per task (`rust:1.85-slim` + pre-installed `cargo-nextest`, `clippy-sarif`, `cargo-deny`). `inspect-ai`'s sandbox extension API supports this directly.
- **AST analysis:** A small Rust binary (`tycheck`) built on `syn` 2.x that takes a directory of `.rs` files and emits a JSON report `{ newtypes: [...], enums_exhaustive: [...], wildcard_matches: N, panic_calls: N, error_enums: [...], typestate_markers: [...] }`. Distribute as a `cargo install` crate.
- **Clippy gating:** `cargo clippy --all-targets --message-format=json -- -D warnings` (the `-D warnings` upgrades all warns to errors so any lint failure aborts compilation), then post-process JSON for fine-grained per-lint scoring.
- **LLM judge:** A separate `inspect-ai` task that takes the candidate's source plus the reference and emits per-principle scores in a strict JSON schema; use a different vendor's model than the candidate to mitigate self-preference. Always run with one-shot ordering pinned (no pairwise) since pointwise rubrics are the right tool here per Arize/Langfuse guidance.
- **Reproducibility:** Pin Rust toolchain in `rust-toolchain.toml`; pin all crate versions; tasks include `Cargo.lock`.
- **Leaderboard:** `inspect view` plus a static site that renders per-principle scores. Optionally export to JUnit XML via `cargo2junit` for CI consumption.

### C. The companion skill: `rust-types`

The skill is published under both the Anthropic Skills format and the open Agent Skills standard so it works in Claude Code, opencode (via its native `.opencode/skills/` discovery or the `.claude/skills/` compat path), and Codex CLI's `.agents/skills/`. Layout:

```
rust-types/
  SKILL.md                     (≤180 lines, the "always-loaded when triggered" core)
  references/
    error-handling.md          (thiserror vs anyhow decision tree, ~80 lines)
    typestate.md               (PhantomData state machines, ~60 lines)
    newtype-recipes.md         (boilerplate for AsRef/Borrow/Display/serde, ~100 lines)
  examples/
    parse-dont-validate.rs     (Email, NonEmptyVec, runnable)
    typestate-builder.rs
    illegal-state-contact.rs
  assets/
    Cargo.toml.lints           (the strict [lints.clippy] block)
    clippy.toml
```

#### Recommended SKILL.md skeleton

```yaml
---
name: rust-types
description: Type-driven Rust design. Use when writing or reviewing Rust code involving domain modeling, IDs, error types, state machines, configuration, or any time primitive types (String, u64, bool) might leak business meaning. Enforces newtype, parse-don't-validate, typestate, exhaustive matching, and proper error enums.
---

# Rust Type-Driven Design

You are writing Rust. Treat the type system as your first line of defense
against bugs. The goal is that invalid states do not compile.

## Six rules with rationale

1. **Wrap primitives that have meaning.** A `u64` that is "really" a user ID
   should be `struct UserId(u64);`, because the compiler cannot otherwise
   stop a caller from passing `OrderId` where `UserId` is expected. Newtypes
   are zero-cost. (See `references/newtype-recipes.md` for AsRef/Display/
   serde boilerplate.)

2. **Parse, don't validate.** A constructor that returns `Result<Self, _>`
   is proof for the rest of the program that the value is valid. A
   `validate()` function that returns `bool` lets the next caller forget.
   So: `Email::parse(s) -> Result<Email, EmailError>`, not
   `is_valid_email(s: &str) -> bool`.

3. **Use enums for "one of N choices," not strings.** If a field has three
   legal values, it is an `enum` with three variants — not a `String`
   matched in `if`/`else`. This applies to status codes, modes, and config
   discriminants. Use `#[serde(rename_all = "snake_case")]` for JSON.

4. **Make impossible states unrepresentable.** If a `Contact` must have
   email or phone, model it as `enum Contact { Email(_), Phone(_),
   Both(_, _) }`, not `struct Contact { email: Option<_>, phone: Option<_> }`,
   which permits `(None, None)`. For state machines that must transition in
   order, use the typestate pattern with `PhantomData<State>` (see
   `references/typestate.md`).

5. **Type your errors.** A library returns a `#[derive(thiserror::Error)]`
   enum so callers can branch on variants. A binary or top-level handler
   returns `anyhow::Result<T>` with `.context("...")` annotations. The axis
   is *will the caller branch on the failure mode*, not "library vs app"
   (Palmieri). Never panic with `unwrap()` outside tests; the project's
   clippy config will reject it (see `assets/Cargo.toml.lints`).

6. **Match exhaustively.** Do not write `_ => ...` on owned enums; list
   every variant. When an enum gains a variant, you want a compile error,
   not silent fallthrough. Use `#[non_exhaustive]` on public enums whose
   variant set will grow, and require callers to handle each.

## Decision tree: newtype, enum, or typestate?

- Domain concept that is just a name on a primitive (ID, email, currency)
  → **newtype** with a smart constructor returning `Result`.
- Closed set of choices (kind, mode, status)
  → **enum**, exhaustively matched, `#[non_exhaustive]` if public.
- Object that has methods only valid in some lifecycle phases
  (open/closed connection, signed/unsigned token, with/without
  required fields in a builder)
  → **typestate** (`Foo<State>` parameterized by ZST markers).
- Combinations of the above are normal: `enum OrderStatus { Pending,
  Shipped { tracking: TrackingNumber }, ... }` mixes a newtype inside
  an enum variant.

## Required project setup

Add this to `Cargo.toml`. The agent must not bypass it via `#[allow]`:

```toml
[lints.clippy]
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
panic_in_result_fn = "deny"
unwrap_in_result = "deny"
allow_attributes = "deny"
allow_attributes_without_reason = "deny"
dbg_macro = "deny"
todo = "deny"
wildcard_enum_match_arm = "deny"
exhaustive_enums = "warn"
```

## When you are reviewing code

Look for: raw `String`/`u64`/`bool` in domain function signatures, `_ =>`
arms on owned enums, `.unwrap()` / `.expect()` outside tests, `Box<dyn
Error>` or `String` in public `Result::Err`, `Option<A>, Option<B>` pairs
that should be a single sum type, and `is_valid` / `validate` functions
that return `bool` instead of parsing into a refined type. Each is a
candidate for a concrete refactor — prefer *fixing* over *flagging*.

## See also

- `references/error-handling.md` — thiserror vs anyhow decision tree.
- `references/typestate.md` — `PhantomData`, ZST markers, `Foo<S>` pattern.
- `references/newtype-recipes.md` — AsRef, Borrow, Display, serde, sqlx.
- `examples/` — runnable, idiomatic versions of common traps.
```

This is roughly 130 lines including code blocks, well under the soft 200-line ceiling. Each rule has the "explain the why" structure that Anthropic's skill-creator explicitly recommends instead of all-caps `MUST`.

#### Companion `references/error-handling.md` (sketch)

> **When to use `thiserror`** — define a `pub enum MyError` with `#[derive(thiserror::Error, Debug)]`, one variant per failure mode the caller can meaningfully react to, `#[from]` for transparent conversions of inner errors. Use this when you are publishing a library, *or* when an internal module's caller will branch on the failure mode.
>
> **When to use `anyhow`** — at the top of a binary, in test code, and in glue code where the caller will only log/exit. Use `.context("doing X")` liberally; never use `anyhow::Error` in a public library API where downstream code might want to match.
>
> **When to combine** — a library may expose a `thiserror` enum with one variant `#[error(transparent)] Other(#[from] anyhow::Error)` to keep the public type closed while accepting arbitrary internal errors. (Palmieri pattern.)

#### Companion `references/typestate.md` (sketch)

Worked examples of `Connection<Disconnected>` → `Connection<Connected>` → `Connection<Authenticated>` (Microsoft RustTraining), `Builder<Unset, Unset>` → `Builder<Set, Unset>` → `Builder<Set, Set>::build()`, and `PooledConnection<Idle>` vs `PooledConnection<InTransaction>`.

### D. Auxiliary `AGENTS.md` / `CLAUDE.md` for projects using the skill

For a real Rust project (not the benchmark), add a short top-level instruction file pointing at the skill rather than restating it:

```md
# AGENTS.md
## Rust style
This project enforces type-driven design. When adding domain types,
defining errors, or modifying public signatures, load the `rust-types`
skill. The strict `[lints.clippy]` block in Cargo.toml is intentional;
do not add `#[allow(...)]` attributes — fix the underlying code.
Run `cargo clippy --all-targets -- -D warnings` and `cargo nextest run`
before finishing.
```

This pattern follows HumanLayer's guidance: keep `CLAUDE.md`/`AGENTS.md` short and pointer-heavy; let progressive-disclosure skills carry the volume.

### E. Validation plan for the benchmark itself

Before publishing scores, validate:
1. **Reference solutions score >90% overall.** If a hand-written canonical solution doesn't max out the metric, the metric is broken.
2. **Primitive-obsessed strawmen score <30%.** Otherwise the metric isn't discriminating.
3. **Judge agreement** with three human Rust reviewers on a 30-task sample ≥0.8 Cohen's kappa per principle.
4. **Test for prompt-leaking** — the SWE-Bench+ paper found ~33% of "passing" patches had the answer leaked in the issue text. The benchmark prompts must be linted to remove canonical type names from problem statements.
5. **Time-segmented re-runs** (LiveCodeBench style) every 3 months on freshly authored tasks to detect contamination.

### F. Compatibility matrix

| Tool | How the skill is consumed | How the benchmark drives it |
|---|---|---|
| Claude Code | `.claude/skills/rust-types/SKILL.md` (project) or `~/.claude/skills/...` (user) | inspect-ai external-agent bridge invokes `claude` CLI |
| opencode | `.opencode/skills/rust-types/SKILL.md`, or auto-discovers `.claude/skills/...` for compat; AGENTS.md loads adjacent | inspect-ai external-agent bridge or direct API via opencode SDK |
| Codex CLI | `.agents/skills/rust-types/SKILL.md` | external-agent bridge |
| aider | No skill mechanism; concatenate SKILL.md as `--read` file or system prompt | aider's own benchmark harness, post-pass through tycheck + clippy-sarif |
| Direct API (Anthropic / OpenAI / etc.) | Skill content prepended as system prompt | inspect-ai's native model providers |

---

## Caveats

- **Static analysis is not a perfect proxy for design quality.** A model can score well on "newtype count" by mechanically wrapping every primitive without genuine semantic value (e.g., `struct Index(usize)` for a loop counter). The judge layer and structural-AST layer are partial mitigations, but eliminating Goodhart effects entirely requires periodic human spot-audits — plan to hand-grade ~5–10% of submissions and retire tasks that the metric games well but humans rate poorly.
- **The "library vs app" axis for `thiserror` vs `anyhow` is contested.** Palmieri's framing (do callers branch?) is more accurate than the simple library/app split, and the benchmark grading rubric should reflect that — penalize `Box<dyn Error>` in a *public branchable* API, not in glue code. Some tasks should explicitly test that the model picks `anyhow` correctly for binary entry points.
- **Clippy `restriction` lints are intentionally opinionated.** The Clippy team explicitly warns against enabling the whole group; the benchmark must cherry-pick lints individually and document each choice. Some lints (e.g., `unwrap_used` inside `#[cfg(test)]` modules) have known false-positive issues — use the `allow-unwrap-in-tests` clippy.toml flag.
- **Some patterns the prompt mentions are not yet stably enforceable.** `non_exhaustive_omitted_patterns` is unstable as of Rust 1.85; the "warn on missing variants despite a wildcard arm" use-case relies on it. Until stabilization, the benchmark must approximate via custom `syn` AST checks.
- **Const generics for invariants are limited on stable.** Pre-`generic_const_exprs` stabilization, complex compile-time invariant encoding (e.g., `MinSlice<T, N>` with `N + M` arithmetic) is restricted. Tasks should target the const-generic features stable since 1.51 (integer/bool/char parameters) and not penalize models for avoiding nightly-only patterns.
- **LLM-as-judge biases.** Self-preference, position, and verbosity biases are well-documented. Use a non-self judge model, pin one ordering for pointwise scoring, and include a length-normalization term in the rubric prompt.
- **Skill-portability across coding agents is real but imperfect.** opencode's docs explicitly support reading `.claude/skills/` for compat, but Codex requires `.agents/skills/`, and aider has no skill primitive at all. The benchmark harness must explicitly handle each agent's skill-loading mechanism rather than assuming portability.
- **Prompt-leaking and contamination.** Like SWE-Bench+, this benchmark's tasks could leak idiomatic type names (`UserId`, `Email`, `OrderState`) in the problem statement; harness must lint task prompts for this and use generic names ("the identifier", "the contact") in problem text while expecting the model to invent good names.
- **The principle of "make impossible states unrepresentable" is properly attributed to Yaron Minsky (2010 Effective ML talk at Harvard, popularized via Jane Street and Scott Wlaschin's F# write-ups).** Anchor authority there in any public framing.
- **Speculation about future tooling** — `inspect-ai`'s external-agent bridge for CLIs like Claude Code and opencode is documented but evolving; expect the integration code to need updates as those CLIs change. Anthropic's "Skills" format is an open standard but only ~6 months old as of mid-2026 and individual fields (e.g., `allowed-tools`) are not enforced uniformly across hosts.