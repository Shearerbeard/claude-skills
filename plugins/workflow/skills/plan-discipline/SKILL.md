---
name: plan-discipline
description: Use this skill for ANY non-trivial implementation task — when the user asks to plan, design, scope, break down, estimate, or architect work. Also use when the user says "let's think about this first", asks "how should we approach this", or requests a plan before coding. Enforces verification-first planning, scope interviews, blast-radius pre-scoping, and adaptive review gates. Always load before implementation begins.
---

# Plan Discipline

Before writing code, get the plan right. This skill loads during planning — not during coding or review.

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
- At each gate boundary, run `gate-probes`

## Adaptive review gates

At each stage boundary, propose which deterministic tools apply to this stage (build, lint, fmt, type check, tests — skip what can't run yet and say why). Run context-isolated agent review in background (reviewer must NOT have seen the implementation). Present deterministic results + agent findings + staged diffs to user in one pass.
