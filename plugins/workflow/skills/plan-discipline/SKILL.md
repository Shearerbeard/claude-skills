---
name: plan-discipline
description: |
  Use when the user asks to add a feature, refactor, migrate, or redesign
  code. Also use when they say "plan this out", "scope this", "minimal V1",
  "vet assumptions", or "don't assume". Enforces evidence check, verification
  framing, and gate-probes before the first code edit. Skip single-file edits,
  typo fixes, and pure read/answer requests.
compatibility: claude-code opencode
when_to_use: |
  Invoke before the first code edit when the task is too broad to safely start
  coding immediately. This includes multi-file implementation, refactors,
  migrations, redesigns, public interface changes, new dependencies/modules,
  and investigation that turns into implementation. Use this skill even if
  Claude Code is already in native plan mode; native planning does not enforce
  the user's required gates: scope interview, evidence check, verification
  framing, blast-radius scan, and gate-probes review boundary.
---

# Plan Discipline

Enforce the user's pre-coding workflow before writing code. Do not rely on plan mode to enforce it.

## Pre-flight checklist

Before any file edit, complete this checklist. Do not proceed until all items are answered:

- [ ] **Scope interview answered**: core problem, audience, success criteria, explicit non-goals
- [ ] **Verification method stated**: how will this be verified? Include smoke test plan for the happy path
- [ ] **Blast radius identified**: which files change, which docs update, what tests exist, what coverage is needed
- [ ] **Existing building blocks searched**: grep/glob for reusable functions before implementing
- [ ] **Gate-probes invoked**: if this is a gate boundary (plan review, pre-implementation checkpoint), run `gate-probes` first

## Gate-probes routing

Before any file edit at a gate boundary, load `gate-probes` — it runs universal scope control, duplication, reviewability, and residual risk checks that this skill does not cover. Without it loaded, you will miss sprawl, god modules, and incoherent edits that look correct in isolation but break module flow.

## Scope interview

For non-trivial tasks, ask before building:
- What is the core problem this solves?
- Who is it for?
- What does success look like?
- What should this NOT do?

Summarize back before writing code.

## Implementation shape

- For 5+ commit refactors: delegate per-commit work to sub-agents. Main agent owns sequencing, gates, git, memory.
- Integration tests at each commit boundary, not bundled at end
- At each gate boundary, invoke `gate-probes` first, then any applicable language-specific review skill

## Adaptive review gates

At each stage boundary, propose which deterministic tools apply (build, lint, fmt, type check, tests — skip what can't run yet and say why). Run context-isolated agent review in background (reviewer must NOT have seen the implementation). Present deterministic results + agent findings + staged diffs to user in one pass.

## Report format

After completing the pre-flight checklist, present findings:

```
## Plan Preflight: <task summary>

### Scope
- Core problem: ...
- Audience: ...
- Success: ...
- Non-goals: ...

### Verification
- Smoke test: ...
- Deterministic checks: ...

### Blast radius
- Files to change: ...
- Existing building blocks: ...
- Test coverage gaps: ...

### Gate probes
- Status: <invoked / not needed — reason>
```
