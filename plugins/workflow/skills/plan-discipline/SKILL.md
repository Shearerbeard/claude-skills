---
name: plan-discipline
description: |
  Use before the first code edit for non-trivial implementation work. Load for
  multi-file features, refactors, migrations, redesigns, public API changes,
  new dependencies/modules, or work shifting from investigation to coding. Also
  load when the user asks to define a minimal V1, unblock a team, vet
  assumptions, do heavy research, or says "don't assume". Enforces the scope
  interview, evidence check, verification plan, blast-radius scan, and review
  gates that invoke gate-probes.
  Skip single-file edits, typo/comment fixes, and pure read/answer requests.
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
