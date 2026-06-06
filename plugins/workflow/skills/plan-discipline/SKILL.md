---
name: plan-discipline
description: |
  Use when the user asks to add a feature, refactor, migrate, or redesign
  code. Also use when they say "plan this out", "scope this", "minimal V1",
  "vet assumptions", "don't assume", "plan with gates", "where should the
  user review?", or "what gates should this plan have?". Produces a
  structured plan with scope interview, blast-radius scan, existing building
  blocks search, and explicit review gates (self-review, agent second
  opinion, manual testing, user review, user testing) placed at the
  appropriate stages and prescribing user involvement at key checkpoints.
  Skip single-file edits, typo fixes, and pure read/answer requests.
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

## Review Gates

Every non-trivial plan must define which gates apply at each stage. Gates are
checkpoints the agent must pass before proceeding. Some gates pull the user in;
the plan must say so.

### Gate types

**Gate S — Self-review (agent, deterministic)**
- Run deterministic tools: lint, fmt --check, type check, build, test
- Fix all failures before proceeding
- Skip tools that can't run yet (e.g., tests before implementation) — note why

**Gate A — Agent second opinion (context-isolated)**
- Dispatch a fresh subagent with no prior implementation context
- Give it the diff, the plan, and the success criteria
- It must find issues or explicitly sign off
- Combine its findings with Gate S results

**Gate M — Manual testing by agent**
- Agent exercises the feature using realistic inputs
- Reports behavior: what worked, edge cases hit, open questions
- Never passes if the agent can't verify the success criteria

**Gate U — User review**
- Pause and present: staged diffs, Gate S/A results, what changed and why
- Highlight highest-risk changes (new interfaces, data migrations, auth/permission)
- Do NOT proceed until user confirms

**Gate T — User testing**
- Prescribe specific manual testing steps the user must perform
- List what to test, how to verify, what edge cases to try
- Do not assume the user knows how to test — be explicit

### Gate placement rules

| Stage | Gates | User pulled in? |
|-------|-------|-----------------|
| After each commit / chunk of work | S → A | No |
| Public API / interface changes | S → A → U | **Yes** |
| Data model / schema / migration changes | S → A → U | **Yes** |
| Auth / permission / security changes | S → A → U → T | **Yes — mandatory** |
| Before integration or merge | S → A → M → U | **Yes** |
| After full implementation | S → A → M → T | **Yes** |

If a stage triggers user involvement, the plan template must include the 🛑
USER GATE marker. The agent must STOP and present at that gate — never push past
without user approval.

### Implementation shape

- For 5+ stage refactors: delegate per-stage work to sub-agents. Main agent owns
  sequencing, gates, git, memory.
- Integration tests at each stage boundary, not bundled at end
- At each gate boundary, load `gate-probes` first, then applicable
  language-specific review skills (rust-review, python-review)

## Plan Template

After completing the pre-flight checklist, produce the plan in this format:

```
## Plan: <task summary>

### Scope
- Core problem: ...
- Audience: ...
- Success: ...
- Non-goals: ...

### Verification
- Smoke test: ...
- Deterministic checks: ...

### Blast Radius
- Files to change: ...
- Existing building blocks: ...
- Test coverage gaps: ...

### Implementation Stages

#### Stage 1: <description>
- Changes: ...
- Gates: S → A
- [ ] Gate S: <deterministic checks to run>
- [ ] Gate A: agent review of diff

#### Stage 2: <description> 🛑 USER GATE
- Changes: ...
- Gates: S → A → U
- [ ] Gate S: <checks>
- [ ] Gate A: agent review
- [ ] Gate U: present diffs + findings, highlight highest-risk changes, await approval

#### Stage 3: <description> 🛑 USER TEST
- Changes: ...
- Gates: S → A → M → T
- [ ] Gate S: ...
- [ ] Gate A: ...
- [ ] Gate M: agent exercises feature, reports behavior
- [ ] Gate T: manual testing steps for user

### Rollback
- If stage N fails: <how to revert>
```
