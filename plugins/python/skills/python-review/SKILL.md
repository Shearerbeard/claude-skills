---
name: python-review
description: Review Python code for quality gate violations. Triggers when reviewing Python diffs, completing Python work, running pre-commit checks on .py files, or when asked to review Python code quality. References python-quality for the underlying rules.
---

# Python Review Gates

Review checklist applied after Python work is complete. Rules are defined in `/python-quality` — this skill applies them as gate probes.

Run `gate-probes` first for universal checks. Then apply these Python-specific probes.

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
