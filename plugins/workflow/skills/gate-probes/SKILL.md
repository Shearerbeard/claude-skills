---
name: gate-probes
description: Universal quality gate probes for any language. Use when committing code, running git commit, preparing a PR with gh pr create, completing a task, finishing implementation work, or when presenting changes for the user to review. Run before every commit, PR, and code review. Pure checklist — no language-specific items. Language skills add their own probes on top.
---

# Gate Probes

Run at every commit boundary and review gate. Language-specific skills add their own probes after these.

## Quality probes

1. Are we sprawling code unnecessarily?
2. Did we reimplement something that already exists in the codebase?
3. Are we building god modules?
4. Will a developer be able to review and follow what we wrote?

## Surgical discipline

5. Every changed line traces directly to the user's request
6. Unrelated findings: mention, don't fix

## Coherence check

7. Re-read modified files in full after editing — diffs that look correct in isolation can create duplicated logic, inconsistent naming, orphaned imports, or functions that no longer fit the module's flow
