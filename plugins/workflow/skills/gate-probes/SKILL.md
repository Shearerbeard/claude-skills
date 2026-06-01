---
name: gate-probes
description: Use before git commit or gh pr create, and before handing coding work to the user. Run these universal gates before language-specific review skills. Checks scope control, duplication, reviewability, verification, and residual risks.
---

# Gate Probes

Run at every commit boundary and review gate. Language-specific skills add their own probes after these.

After the universal probes, route to the next applicable skill without repeating work already done for this diff:
- Python diffs (`.py`, `pyproject.toml`, `uv`, `ruff`, `pytest`, `click`): run `python-review`
- Rust diffs (`.rs`, `Cargo.toml`, `clippy`): run `rust-review`
- Rust module layout changes: run `rust-modules`
- Checked-in docs changes: run `docs-bustest`
- User-facing prose without a docs structure review need: run `prose-lint`; then run `humanizer` if the prose will be checked in, published, or sent on the user's behalf

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
