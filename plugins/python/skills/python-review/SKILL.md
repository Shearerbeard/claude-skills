---
name: python-review
description: |
  Use for Python code reviews, including .py diffs and Python PRs. Also use for
  Python pre-commit checks. Run gate-probes first for universal checks, then
  these Python-specific probes. Always load before presenting Python code review
  findings to the user.
compatibility: claude-code opencode
---

# Python Review Gates

Review checklist applied after Python work is complete. Rules are defined in `/python-quality` — this skill applies them as gate probes.

Load `python-quality` for the quality rules being checked. If `gate-probes` has not already run for this diff, run it first for universal checks. Then apply these Python-specific probes.

If the diff changes public docs, public API docstrings, README content, release notes, or PR prose, invoke `prose-lint` on changed prose only. For docstrings or public comments, pass the changed text via stdin. Use `humanizer` only for prose that will be checked in, published, or sent on the user's behalf.

## Python Gate Checklist

Run these probes against every function in the diff:

1. **Silent degradation?** — Does any function return `[]`, `{}`, `None`, or `""` when required data is missing? It should raise instead.

2. **Speculative code?** — Is there an alternate code path (fallback layout, "parse free text" branch, format B handler) that has zero real-world instances? Verify with `find`/`ls` before accepting.

3. **Duplicated traversal?** — Do two or more functions walk the same directory tree independently? Extract one walker.

4. **Raw tuples?** — Any function returning or yielding 3+ positional values without a `NamedTuple`?

5. **Imperative accumulation?** — Any loop that's just `result.append(x)` with no side effects? Should be a comprehension.

6. **Magic strings?** — Repeated string literals that should be module-level constants?

7. **Dead guards?** — Any `is_dir()`, `exists()`, or name-exclusion guard that protects against a condition with zero real instances in the data?

## Toolchain Check

Verify `pyproject.toml` uses:
- `uv_build` backend (not setuptools/hatchling)
- `ruff` config with `select = ["E", "F", "I", "UP", "B", "SIM"]`
- `line-length = 88`

```bash
uv run ruff check . && uv run ruff format --check .
```

## Report Format

For each finding, report: file, line, which probe (1-7) failed, one-line fix.
