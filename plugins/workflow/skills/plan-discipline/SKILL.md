---
name: plan-discipline
description: |
  Use before non-trivial code work to enforce the user's required workflow.
  Load when the user asks to dive into details, define a minimal V1, build a
  phased plan, unblock a team, vet assumptions, do heavy research, or says
  "don't assume". Also load for refactors, migrations, redesigns, public API
  changes, new dependencies/modules, or work shifting from investigation to
  coding. Enforces the scope interview, evidence check, verification plan,
  blast-radius scan, and review gates that invoke gate-probes.
  Skip single-file edits, typo/comment fixes, and pure read/answer requests.
when_to_use: |
  Invoke before the first code edit for non-trivial coding work, even if Claude
  Code is already in plan mode. Plan mode does not enforce the user's workflow:
  scope interview, evidence-backed research, verification framing, blast-radius
  scan, and gate-probes review boundary. Common user phrases include "dive down",
  "implementation details", "minimal V1", "unblock the team", "phased plan",
  "heavy research", "vet data", "vet assumptions", "don't assume", "refactor",
  "migrate", and "redesign".
---

# Plan Discipline

Enforce the user's pre-coding workflow before writing code. Do not rely on plan mode to enforce it.

## Verification first

Before doing any work, state how you will verify it. For features, include a smoke test plan beyond integration tests — how would you manually exercise the happy path end-to-end?

## Scope interview

For non-trivial tasks, ask before building:
- What is the core problem this solves?
- Who is it for?
- What does success look like?
- What should this NOT do?

Summarize back before writing code.

## Pre-scope blast radius

- Which files need editing, which docs need updating
- Search for existing building-block functions before implementing — prevent duplication
- Identify what tests exist and what new coverage is needed

## Implementation shape

- For 5+ commit refactors: delegate per-commit work to sub-agents. Main agent owns sequencing, gates, git, memory.
- Integration tests at each commit boundary, not bundled at end
- At each gate boundary, invoke the `gate-probes` skill first, then any applicable language-specific review skill

## Adaptive review gates

At each stage boundary, propose which deterministic tools apply to this stage (build, lint, fmt, type check, tests — skip what can't run yet and say why). Run context-isolated agent review in background (reviewer must NOT have seen the implementation). Present deterministic results + agent findings + staged diffs to user in one pass.
