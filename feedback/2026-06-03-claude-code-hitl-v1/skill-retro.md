# HITL V1 Skill System Retro

Session: 2026-06-02 to 2026-06-03
Task: implement HITL approval gating for an internal Rust agent-orchestration service (config-driven + callable tool)
Result: 3 commits, ~1960 lines, functional and shipping — but required
heavy user re-steering that the skill system should have prevented.

## Executive Summary

The user has a layered skill system designed to catch quality issues at
every stage: planning → writing → reviewing → committing → documenting.
During this implementation, **none of the review/quality skills fired
automatically** despite matching trigger conditions. All quality issues
were caught by the user asking "did you run X?" or by a cross-model
review (Kimi K2.6 / Gemini) dispatched manually.

Root causes: (1) the Agent tool spawns sub-agents with no skill context,
(2) Bash-driven `git commit` bypasses skill trigger evaluation, (3) the
built-in `code-review` skill shadowed the plugin `rust:rust-review`, and
(4) plan-discipline lacks probes for forward compatibility and consumer
documentation.

---

## Part 1: Skills That Should Have Fired

### `git:git-commit`

**Trigger condition (from description):** "Triggers on git commits,
writing commit messages, or preparing changes to commit."

**What happened:** 14 commits were made via `git commit -m "..."` in
Bash. Every one had prohibited `Signed-off-by` and `Co-Authored-By`
lines. None had `Ref:` footers. Body lines exceeded 72 chars. The
skill was never invoked.

**Why it missed:** Commits were created directly via the Bash tool. The
skill trigger evaluates when Claude is composing a response — but the
commit message was a string literal in a Bash command, not a
deliberated artifact. Claude never "wrote a commit message" in a way
the trigger system could observe.

**Fix needed:** Either (a) the skill description should also trigger on
"running git commit" / "calling Bash with git commit", or (b) a
pre-commit hook in `.claude/settings.json` should invoke this skill
before any `git commit` Bash call.

### `rust:rust-quality`

**Trigger condition:** "Use when writing or editing Rust code: .rs
files, Cargo.toml."

**What happened:** All Rust code was written by sub-agents dispatched
via the Agent tool. Sub-agents receive a plain text prompt — they have
no access to the skill system. The main session that HAS the skill
never wrote Rust directly.

**Why it missed:** The Agent tool spawns fresh agents with no skill
context. Unlike defined subagents (which support `skills: [...]` in
frontmatter), ad-hoc Agent tool calls have no mechanism to inject
skills. The quality rules (no speculative fallbacks, parse-don't-
validate, minimize clones, thiserror over manual Display) existed in
the skill but never reached the code-writing agents.

**What it would have caught:**
- `request_type: String` → should be enum (parse-don't-validate)
- `ApprovalError::Rejected` variant never constructed (speculative)
- Manual `Display`/`Error` impls → `thiserror`
- `Vec<String>` cloned per worker → `Arc<[String]>`
- 5 manual match arms → `From<ApprovalError> for ToolError`

**Fix needed:** When dispatching an Agent to write Rust code, the main
session should manually paste the `rust-quality` rules into the agent
prompt. This is the only mechanism available for ad-hoc Agent tool
calls. A helper skill that generates "rust writing context" for agent
prompts would reduce the manual overhead.

### `rust:rust-review`

**Trigger condition:** "Use for Rust reviews: .rs diffs, PRs with Rust
changes, Cargo.toml changes, and clippy/pre-commit checks. Run
gate-probes first for universal checks, then these Rust-specific
probes."

**What happened:** Never invoked. The built-in `code-review` skill was
invoked instead (via `/code-review high`), which runs a generic
multi-angle finder+verifier review — NOT the user's Rust-specific
quality probes.

**Why it missed:** Name shadowing. The user typed `/code-review` which
invoked the built-in skill. The plugin `rust:rust-review` requires
explicit invocation as `/rust:rust-review` or would need to be
triggered by Claude's auto-detection. But during the review phase,
Claude chose `/code-review` (built-in) because it was the obvious
match for "review this code."

**Conflation:** The built-in `code-review` and the plugin
`rust:rust-review` serve different purposes:
- `code-review`: generic multi-angle bug finder (correctness focus)
- `rust:rust-review`: user's specific Rust quality standards
  (idiomatic patterns, type-driven design, clone waste, error
  modeling)

Both should run, in sequence: `code-review` for bugs, then
`rust:rust-review` for quality. The user's description says exactly
this: "Run gate-probes first for universal checks, then these
Rust-specific probes." But this sequencing is manual.

**Fix needed:** Either (a) `rust:rust-review` should auto-trigger when
`code-review` completes on Rust files, or (b) `code-review` should
check for language-specific review skills and invoke them.

### `workflow:gate-probes`

**Trigger condition:** "Use before git commit or gh pr create, and
before handing coding work to the user."

**What happened:** Never invoked. The execution loop went: dispatch
agent → cargo build/test → git commit → next. No pause for gate
probes.

**Why it missed:** Same as `git:git-commit` — the commit happened via
Bash, and the "before git commit" trigger requires Claude to be in a
deliberation phase, not executing a Bash pipeline.

**Fix needed:** Same as `git:git-commit` — either a settings.json hook
or a composite skill that wraps the commit flow.

### `docs:docs-bustest`

**Trigger condition:** "Use when reviewing, auditing, or updating
documentation — checks whether a repo's docs are good enough for both
a new human contributor and a cold AI agent."

**What happened:** Never invoked when writing the ADR or integration
guide. The user had to ask: "Is our documentation clear enough for
someone to test against it?" The answer was no — field nullability was
wrong, a serde rename change broke the wire format docs.

**Why it missed:** Documentation was written by the main session and
committed without review. Claude didn't self-evaluate the docs because
the execution loop optimized for "write → commit → next."

**Fix needed:** The skill should auto-trigger when any file in `docs/`
is staged for commit. Or `gate-probes` should include a doc quality
check when docs are in the changeset.

### `verify`

**Trigger condition:** "Use when asked to verify a PR, confirm a fix
works, test a change manually, check that a feature works."

**What happened:** Smoke testing was done ad-hoc with manual curl
commands and a quickly-written Python stub. The stub crashed on
interactive prompts (threading issue). The test config had the wrong
TOML format.

**Why it missed:** The skill wasn't invoked because smoke testing was
treated as manual exploratory work, not as a structured verify pass.

**Fix needed:** After implementation commits, the execution loop should
invoke `/verify` which would provide structured test scaffolding
instead of ad-hoc scripts.

---

## Part 2: Naming and Trigger Conflicts

### `code-review` (built-in) vs `rust:rust-review` (plugin)

**Problem:** When the user or Claude wants to "review Rust code," the
natural invocation is `/code-review`. This invokes the built-in
generic multi-angle review, not the Rust-specific quality review. The
plugin skill requires `/rust:rust-review` — a less discoverable name.

**Impact:** The built-in `code-review` found correctness bugs but
missed all type-driven design issues (stringly-typed fields, missing
From impls, speculative variants, clone waste). These are exactly what
`rust:rust-review` catches.

**Proposed fix:** Either:
- Rename the plugin skill to something that doesn't overlap: e.g.
  `rust:quality-audit` or `rust:idiom-check`
- Or make `code-review` language-aware: after running its generic
  angles, check for language-specific review skills and invoke them

### `rust:rust-quality` vs `rust:rust-review`

**Problem:** Similar names, different purposes:
- `rust-quality`: rules for WRITING Rust code (proactive)
- `rust-review`: rules for REVIEWING Rust code (reactive)

**Impact:** Easy to invoke the wrong one. During writing, `rust-review`
might be invoked (which is a review checklist, not writing guidance).
During review, `rust-quality` might be skipped.

**Proposed fix:** The names are actually fine — `quality` (proactive)
vs `review` (reactive) is a meaningful distinction. But the
descriptions should make the write/review split explicit in the first
line, not buried in the body.

### `gate-probes` naming

**Problem:** The name `gate-probes` doesn't clearly signal "run this
before every commit." It sounds like a diagnostic tool, not a
mandatory gate.

**Proposed fix:** Consider `pre-commit-gate` or `commit-readiness` —
names that encode the trigger point, not just the mechanism.

---

## Part 3: Structural Gaps

### Agent tool sub-agents have no skill context

**The gap:** When Claude dispatches work to a sub-agent via the Agent
tool, the sub-agent is a fresh context with no loaded skills. The
user's quality rules (rust-quality, commit conventions, etc.) exist
only in the main session.

**Why this matters:** In the HITL implementation, 6 out of 8 code
commits were written by sub-agents. None had rust-quality rules. All
quality issues were caught retroactively by cross-model review.

**Current workaround:** Manually paste skill content into the Agent
tool prompt. This is verbose and error-prone.

**Proposed fix options:**
1. A "context builder" skill that generates a compressed version of
   relevant skill rules for pasting into agent prompts
2. A wrapper around Agent dispatch that auto-appends language-specific
   quality rules based on the file types being edited
3. Documentation in the skills themselves noting "when delegating to
   sub-agents, include these rules in the prompt: [key points]"

### No composite "commit flow" skill

**The gap:** Committing requires 4+ sequential skill invocations:
`cargo fmt/clippy/test` → `gate-probes` → `rust:rust-review` →
`git:git-commit` → commitlint. Currently all manual and all skipped.

**Proposed fix:** A composite skill like `workflow:commit-gate` that
runs the full sequence. Trigger: "before any git commit on Rust files."
Steps:
1. `cargo fmt && cargo clippy && cargo test` (deterministic)
2. `/gate-probes` on staged diff
3. `/rust:rust-review` on staged diff (if .rs files present)
4. `/git:git-commit` to draft the message
5. `commitlint` on the drafted message
6. Present results to user before executing `git commit`

### plan-discipline missing probes

**The gap:** `/plan-discipline` ran during planning but didn't catch 5
design concerns that required user re-steering:

| Missing probe | What it would ask |
|--------------|-------------------|
| Forward compatibility | "What V2 features exist? Sketch the data model. Prove V1 doesn't foreclose it." |
| Consumer documentation | "Who consumes this externally? What docs do they need?" |
| Wire contract design | "Does the schema have versioning? Type discriminators? Omit vs null?" |
| Deployment modes | "Does this work in all deployment modes (server, CLI, standalone, A2A)?" |
| Serde-aware doc lint | "Do any docs reference wire format fields that serde attributes control?" |

---

## Part 4: Cross-Model Review Findings

The cross-model review (Kimi K2.6 via OpenCode + Gemini via MCP) was
the most effective quality gate in this session. It caught issues that
same-model self-review missed entirely.

**Kimi caught:**
- `RequestType` enum (parse-don't-validate)
- `thiserror` over manual Display/Error
- `From<ApprovalError> for ToolError` (5 match arms → 1)
- `Arc<[String]>` for patterns
- `reqwest::Client` sharing
- `tokio::sync::Mutex` in async tests

**Gemini caught:**
- `RequestApprovalTool::call` missing SSE event emission (the wrapper
  emitted events but the tool didn't — inconsistency)

**Claude's own code-review caught:**
- Orchestration workers missing `request_approval` tool when patterns
  empty (real bug)
- Glob `*` intercepting `request_approval` itself (footgun)
- Pre_call spawn missing tracing span propagation

**Takeaway:** Cross-model review should be a standard gate, not an
afterthought. Different models have different blind spots.

---

## Part 5: Recommendations for Skills System

---

## Part 6: Verbatim User Phrases as Trigger References

These are exact user phrases from this session that indicate a skill
should have already fired. Use these to calibrate trigger descriptions.

### Commit quality / git conventions
> "did you run gate probs and rust quality?"
— User had to ask if quality gates ran. They should have been automatic.

> "how will you personally vet my preferences for rust quality at each commit gate?"
— User noticed the plan listed cargo build/test/clippy but not their
custom skill invocations.

> "check better for our commit rules - they should be in skills and commit lint tells you a lot. You do not want to have the signed off by etc."
— Every commit violated rules that exist in `git:git-commit` and
`feedback-commit-style` memory. Neither was consulted.

### Rust quality / review hierarchy
> "Was this review from your background agent or opencode?"
— User checking whether cross-model review ran. It hadn't.

> "rust-quality has many stipulations on ADR use and type driven design as well as some guidance on code sprawl"
— User pointing out that the review missed findings their own skill
would have caught.

> "We must emit events - if possible use good rust design in the serde layer to inline commonly used fields similar to other events"
— User directing Rust idiom application that rust-quality should have
enforced proactively.

### Planning gaps
> "dont worry about your #3 mcp hitl impl - this was a stop gap experiement. I want V1 to have the avility to have our same hitl stucture callable as a tool"
— User expanding scope because the plan didn't ask about all HITL
surfaces. plan-discipline should have probed this.

> "Do both coordinator and worker get the tool for calling user as HITL?"
— User asking a design question the plan should have addressed.
Forward-compatibility probe would have caught this.

> "We need to roll our plans up into a public ADR"
— User noticing the plan had no external documentation deliverable.
Consumer documentation probe would have caught this.

### Documentation quality
> "Is our documetnation clear enough on HITL and the schema we just put together for someone to test against it?"
— User invoking the bus test manually. docs-bustest should have fired
when docs/ files were written.

> "This isn't a real [project] config"
— User rejecting a smoke test config that was written from scratch
instead of adapted from an existing working config.

### Skill system itself
> "this work is getting big - are we well scoped enough with modular code and contained blast radius to do our edits in fresh agent winows keeping the main process in charge of manually gating or dispatching gate agents?"
— User designing the execution model. Should have been a standard
pattern from plan-discipline.

> "One final gating - use the opencode cli to review each gate with fresh eyes using our rust standard"
— User had to explicitly request cross-model review. Should be a
standard gate step.

> "Give me the prompt for Kimi exactly how you were going to run it"
— User checking that cross-model review was actually happening, not
just claimed.

> "I thought kimi had already fixed the review items? If we wait until after handoff to do the retro there wont be one."
— Two misses: (1) tracking what was fixed vs outstanding, (2) retro
must happen before handoff or context is lost.

## Part 7: Recommendations for Skills System

Priority order:

1. **Composite commit-gate skill** — highest impact, prevents the
   most common failure mode (quality skipped during fast commit loop)
2. **plan-discipline probes** — add forward-compat, consumer docs,
   wire contract, deployment mode probes
3. **Sub-agent skill injection pattern** — document or automate
   pasting quality rules into Agent tool prompts
4. **Language-specific review chaining** — `code-review` should
   invoke `rust:rust-review` when Rust files are in scope
5. **Rename gate-probes** — encode the trigger point in the name
6. **Serde doc lint** — add to `rust:rust-review` as a probe
