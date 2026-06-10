# Skill Invocation Transcript — HITL V1 Session

Session: 2026-06-02 to 2026-06-03
Model: Claude Opus 4.6 (1M context)
Project: internal Rust agent-orchestration service, feature worktree
Task: implement HITL approval gating (config gate + callable tool)

This is a raw transcript of every skill invocation attempt, in order,
with exact strings passed to the Skill tool and the result. Use as
ground truth for diagnosing trigger failures and namespace resolution
bugs.

## Invocations (chronological)

### 1. workflow:plan-discipline — SUCCESS
```
Skill("workflow:plan-discipline")
→ "Launching skill: workflow:plan-discipline"
```
Context: user said "yes" to invoking plan-discipline before coding.
Loaded correctly, ran scope interview and blast-radius scan.

### 2. code-review — SUCCESS (but wrong skill for the job)
```
Skill("code-review", args="high")
→ "Launching skill: code-review"
```
Context: user asked "did you run gate probes and rust quality?" after
all commits were done. I invoked the built-in `code-review` skill
instead of `workflow:gate-probes` + `rust:rust-review`. The built-in
runs generic multi-angle finder+verifier. The user's plugin skills run
their specific Rust quality probes and universal gate checks.

This is a naming conflation: "code review" mentally maps to "review
the code" which is what `rust:rust-review` does. The built-in
`code-review` is actually a structured bug-finder, not a quality
auditor.

### 3. workflow:gate-probes — FAILED
```
Skill("workflow:gate-probes")
→ "Unknown skill: workflow:gate-probes"
```
Then:
```
Skill("gate-probes")
→ "Unknown skill: gate-probes"
```
Context: attempted after user asked about gate probes. Both namespaced
and bare name failed. The skill IS listed in the system reminder as
`workflow:gate-probes`. No personal copy exists at
`~/.claude/skills/gate-probes/`. Never successfully invoked.

### 4. docs:humanizer — FAILED, then personal copy worked
```
Skill("docs:humanizer")
→ "Unknown skill: docs:humanizer"
```
Then:
```
Skill("humanizer")
→ "Launching skill: humanizer"
```
Context: user asked to humanize a GH issue draft. The plugin
`docs:humanizer` failed but the personal skill at
`~/.claude/skills/humanizer/` resolved. Same skill content, different
install path.

### 5. docs:prose-lint — FAILED
```
Skill("docs:prose-lint")
→ "Unknown skill: docs:prose-lint"
```
Then:
```
Skill("prose-lint")
→ "Unknown skill: prose-lint"
```
Context: user said "use the prose-lint" to check em dashes. Both
failed. I found the skill file manually at
`~/dev/claude-skills/plugins/docs/skills/prose-lint/skill.md`, read
its content, and ran Vale directly per its instructions. Workaround
was correct but shouldn't have been necessary.

### 6. git:git-commit — NEVER ATTEMPTED
Context: 14 commits written during the session. Every one had
prohibited `Signed-off-by` and `Co-Authored-By` lines. The skill
would have caught all violations. I never invoked it because commit
messages were string literals inside `git commit -m "..."` Bash calls.
The skill trigger says "triggers on git commits, writing commit
messages" but the Bash-driven commit flow never paused for skill
evaluation.

### 7. rust:rust-review — NEVER ATTEMPTED
Context: all code was written by sub-agents and reviewed by the
built-in `code-review` skill. I conflated `code-review` (generic
bug-finder) with `rust:rust-review` (user's Rust quality probes).
The Kimi K2.6 cross-model review via OpenCode caught what
`rust:rust-review` would have caught: stringly-typed fields, missing
From impls, speculative variants, clone waste, manual Display.

### 8. rust:rust-quality — NEVER ATTEMPTED
Context: sub-agents wrote all Rust code. They have no skill access.
The main session never wrote Rust directly, so the trigger condition
("use when writing or editing Rust code") never matched in the main
session context. The rules existed but never reached any writing
context.

### 9. rust:rust-modules — NEVER ATTEMPTED
Context: created a new 834-line module (hitl.rs). The skill says
"use when creating, splitting, moving, or reviewing Rust modules."
Never considered invoking it.

### 10. docs:docs-bustest — NEVER ATTEMPTED
Context: wrote ADR and integration guide. User had to ask "is our
documentation clear enough for someone to test against it?" — exactly
what this skill checks. Never invoked; user's question was the
manual equivalent.

### 11. verify — NEVER ATTEMPTED
Context: smoke testing was done ad-hoc with manual curl commands and
a Python webhook stub. The skill says "use when asked to verify a PR,
confirm a fix works, test a change manually." The structured verify
skill would have provided better test scaffolding.

### 12. github:github-workflow — SUCCESS
```
Skill("github:github-workflow")
→ "Launching skill: github:github-workflow"
```
Context: filing GH issue #191. Loaded correctly, guided title/body
format. This was the only plugin skill with a colon namespace that
resolved correctly besides plan-discipline.

## Namespace Resolution Summary

| Namespace | Skill | Skill tool result |
|-----------|-------|------------------|
| `workflow:plan-discipline` | plan-discipline | SUCCESS |
| `workflow:gate-probes` | gate-probes | FAILED |
| `docs:humanizer` | humanizer | FAILED |
| `docs:prose-lint` | prose-lint | FAILED |
| `github:github-workflow` | github-workflow | SUCCESS |
| `code-review` | (built-in) | SUCCESS |
| `humanizer` | (personal) | SUCCESS |

Two namespaced invocations worked (`workflow:plan-discipline`,
`github:github-workflow`). Three failed (`workflow:gate-probes`,
`docs:humanizer`, `docs:prose-lint`). No pattern explains which
succeed and which fail — same marketplace, same session, same
SKILL.md naming convention.

## Plugin Installation State

```
docs@my-skills     -> ~/.claude/plugins/cache/my-skills/docs/1.0.0     NOT ON DISK
rust@my-skills     -> ~/.claude/plugins/cache/my-skills/rust/1.0.0     NOT ON DISK
workflow@my-skills -> ~/.claude/plugins/cache/my-skills/workflow/1.0.0  NOT ON DISK
```

`my-skills` is a directory-source marketplace at
`~/dev/claude-skills`. The cache paths in
`installed_plugins.json` don't exist because directory marketplaces
read from source directly. Skills appear in the system reminder,
suggesting discovery works but invocation resolution is inconsistent.

## Root Cause Hypotheses

1. **Session-startup indexing race**: plugins discovered during startup
   may not all be indexed by the time the Skill tool resolves names.
   plan-discipline worked (invoked minutes into the session);
   gate-probes failed (invoked hours later, possibly after a cache
   invalidation).

2. **Directory marketplace resolution bug**: the Skill tool may look
   for the skill at the cache path (which doesn't exist) instead of
   the source directory. Some skills resolve anyway (startup cache?)
   while others don't.

3. **Worktree isolation**: the session runs in a git worktree. Plugin
   resolution may anchor to the worktree's `.claude/` instead of the
   main repo's, causing some project-scoped plugins to not resolve.
