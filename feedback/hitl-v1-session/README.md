# HITL V1 Session Feedback

Raw feedback from a 2026-06-02/03 implementation session (Claude Opus
4.6, mezmo/aura HITL approval gating). Three immutable source files:

| File | What it is |
|------|-----------|
| `skill-retro.md` | Full skill system retro: which skills should have fired, naming conflicts, structural gaps, verbatim user phrases as trigger references, and 6 prioritized recommendations |
| `plan-retro.md` | Plan-discipline retro: what worked, what needed re-steering, skill triggering gaps table, feedback items |
| `skill-invocation-transcript.md` | Raw chronological transcript of every Skill tool invocation attempt with exact strings and results. Includes namespace resolution audit and plugin installation state. |

## Key findings

1. Plugin namespace resolution via the Skill tool is inconsistent.
   `workflow:plan-discipline` and `github:github-workflow` resolve;
   `workflow:gate-probes`, `docs:humanizer`, `docs:prose-lint` don't.
   Same marketplace, same session, same naming convention.

2. Agent tool sub-agents have no skill context. All Rust code was
   written by sub-agents that never had `rust:rust-quality` rules.

3. The built-in `code-review` skill shadows `rust:rust-review` in
   mental models. Both should run, in sequence.

4. Bash-driven `git commit` bypasses skill trigger evaluation for
   `git:git-commit`.

5. No composite "commit gate" skill exists to chain fmt + clippy +
   test + gate-probes + rust-review + git-commit + commitlint.

## How to use this

Pass these files to a skills optimization agent:

```
Read all three files in ~/dev/claude-skills/feedback/hitl-v1-session/
and propose changes to skill descriptions, trigger conditions, and
naming to address the findings.
```
