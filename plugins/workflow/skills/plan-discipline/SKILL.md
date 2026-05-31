---
name: plan-discipline
description: |
  Invoke before writing code when changes will touch 3+ files OR introduce a new
  module/dependency OR change a public interface, OR when the user request shifts
  from question/investigation to "let's implement/refactor/redesign/migrate".
  Extends the basic scope interview (core problem, who, success, what NOT) with:
  blast-radius pre-scoping (file map, duplicate-function search, test gaps),
  verification-first design (smoke test plan before writing), adaptive review gates
  at each commit boundary, and sub-agent delegation for 5+ commit refactors.
  Skip for single-file edits, typo/comment fixes, and pure read/answer requests.
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
