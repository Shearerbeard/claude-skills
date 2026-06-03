---
name: python-quality
description: |
  Use when writing or editing Python code: .py files, pyproject.toml, uv, ruff,
  pytest, or click CLIs. Enforces fail-loud errors, no speculative fallbacks,
  consolidated traversals, and uv/ruff conventions. For reviews, use
  python-review; it applies these rules.
compatibility: claude-code opencode
---

# Python Quality Standards

Quality rules applied while writing Python. For reviews, use `python-review`; it loads these rules and applies the review gate checklist.

## Toolchain

- **Build:** `uv_build` (not setuptools, not hatchling)
- **Lint + format:** `ruff` (not Black). `select = ["E", "F", "I", "UP", "B", "SIM"]`, `line-length = 88`
- **CLI:** `click` (not argparse)
- **Types:** hints everywhere, `mypy --strict` where feasible
- **Docstrings:** module-level only. Skip verbose per-function docstrings on obvious functions

Gate command:
```bash
uv run ruff check . && uv run ruff format --check .
```

## Code Patterns

**Fail loud.** Never return empty defaults for missing data. If a required file doesn't exist, let it raise `FileNotFoundError` — don't return `[]`. Callers handle exceptions; silent degradation hides bugs.

**No speculative fallbacks.** Don't write alternate code paths for scenarios that don't exist. Check with `find`/`ls` first. Zero hits = don't write the code. Applies to:
- Directory layouts no runner has ever produced
- Model tool-calling failures that don't manifest in practice
- File format variations with no real-world instances

Log a warning and let it fail. Add the fallback only when a real failure manifests.

**One walker, many projections.** When multiple functions traverse the same directory structure, extract a single walk function and filter/group from its output. Never duplicate traversal logic.

**NamedTuple for 3+ fields.** Functions returning tuples with 3+ fields use `NamedTuple`. Self-documenting access (`e.label` not `entry[2]`), eliminates `_unused` lint noise.

**Comprehensions over loops.** If a loop body is a single append/filter with no side effects, use a list/dict comprehension.

**Constants for magic strings.** Directory prefixes, file patterns, repeated literals → module-level constants.

**Guard removal.** Before accepting `is_dir()`, `exists()`, or exclusion guards, verify:
```bash
find . -name "pattern" | wc -l
```
Zero hits = speculative guard. Remove it.

## LLM Anti-Patterns

**No test-shaped production code.** Don't hardcode values, example data, or tutorial-style constants into the final design. If you scaffolded with `expected = "hello world"` to get a test passing, replace it with real logic before moving on.

**No temporary workarounds that outlive the problem.** Don't add fallback code to route around a dev roadblock (missing API, unfinished dependency, broken fixture) — the roadblock may not exist by the time the code ships. Flag blockers explicitly, don't code around them silently.

**Tests assert behavior, not examples.** Test assertions should verify properties and contracts, not hardcoded snapshot values copied from a single run. `assert len(results) > 0` and `assert result.status == "ok"` beat `assert results == [{"id": 1, "name": "test"}]`.
