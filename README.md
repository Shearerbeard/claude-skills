# Personal Skills Library

Model-invoked skills for Claude Code, OpenCode, and Codex. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

## Skills

| Skill | Plugin | Trigger | Purpose |
|---|---|---|---|
| `python-quality` | python | writing `.py` | Toolchain (uv/ruff) + code patterns + LLM anti-patterns |
| `python-review` | python | reviewing Python | 7 Python-specific gate probes |
| `rust-quality` | rust | writing `.rs` | Idioms, anti-patterns, type modeling |
| `rust-review` | rust | reviewing Rust | 7 Rust-specific gate probes |
| `rust-modules` | rust | Rust module layout | Modern file layout, re-exports, type co-location |
| `docs-bustest` | docs | docs review / updates | 24-item bus test for documentation quality |
| `prose-lint` | docs | Vale / prose lint | Deterministic AI-tell checks for docs and emitted prose |
| `humanizer` | docs | publishable prose | Remove AI writing patterns from user-facing text |
| `mermaid` | docs | `.mmd` files / diagrams | Render and open Mermaid diagrams |
| `plan-discipline` | workflow | planning / design / scope | Verification-first, scope interview, blast radius |
| `gate-probes` | workflow | commit / review / PR | 7 universal quality probes + surgical discipline |

## Installation

**Claude Code**: marketplace plugin via `~/.claude/settings.json`:
```json
"enabledPlugins": {
  "python@my-skills": true,
  "docs@my-skills": true,
  "rust@my-skills": true,
  "workflow@my-skills": true
},
"extraKnownMarketplaces": {
  "my-skills": {
    "source": { "source": "directory", "path": "/Users/mshearer/dev/claude-skills" }
  }
}
```

**OpenCode** or **Codex**:
```bash
./bin/install-skills opencode   # ~/.config/opencode/skills/
./bin/install-skills codex      # ~/.codex/skills/
```

## Quality Gates

Run these before installing changed skills:

```bash
./bin/check-skills
./bin/check-install
./bin/check-prose
```

Use `docs/internal/testing/skill-test-matrix.md` for manual Claude Code and OpenCode behavior checks. Treat auto-loading as a behavior to measure, not a deterministic contract.

## Prose Linting

This repo uses Vale with `tbhb/vale-ai-tells` for deterministic checks on AI-writing patterns. Run `vale sync` once per checkout to download the pinned style packages into `.vale/`; downloaded package directories are ignored by git.

`prose-lint` prefers a project's own `.vale.ini`. If the target project has no Vale config, the skill uses its bundled fallback config. If Vale is not installed or `vale sync` fails, the skill reports that prose linting was skipped and does not try to install anything.

Use `prose-lint` for mechanical findings. Use `humanizer` after that when changed docs or outgoing prose need a rewrite.

## Adding a Skill

1. Create `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`)
2. If new plugin: create `plugins/<plugin>/.claude-plugin/plugin.json` and add to `.claude-plugin/marketplace.json`
3. Run `./bin/install-skills opencode` or `./bin/install-skills codex` if using those tools

## Structure

```
claude-skills/
├── plugins/                     # Source of truth — one plugin per domain
│   ├── python/                  # python-quality, python-review
│   ├── rust/                    # rust-quality, rust-review, rust-modules
│   ├── docs/                    # docs-bustest, prose-lint, humanizer, mermaid
│   └── workflow/                # plan-discipline, gate-probes
├── .claude-plugin/
│   └── marketplace.json         # Marketplace registry
├── bin/
│   ├── install-skills           # Install to OpenCode + Codex
│   ├── check-skills             # Static skill/frontmatter checks
│   ├── check-install            # Temp-home install checks
│   └── check-prose              # Vale/prose lint smoke checks
├── docs/
│   ├── internal/sessions/       # Session logs
│   ├── internal/testing/        # Manual Claude/OpenCode test matrix
│   └── research/                # Research documents
└── _archive/
    └── legacy-slash-commands/   # v1 slash commands (2025-11)
```

## Archive

`_archive/legacy-slash-commands/` contains v1 slash commands from before Claude Code had skills. Some have useful patterns worth mining; check before building from scratch.
