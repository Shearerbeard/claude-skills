# Personal Skills Library

Auto-triggered skills for Claude Code, OpenCode, and Codex. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

## Skills

| Skill | Plugin | Trigger | Purpose |
|---|---|---|---|
| `python-quality` | python | writing `.py` | Toolchain (uv/ruff) + code patterns + LLM anti-patterns |
| `python-review` | python | reviewing Python | 7 Python-specific gate probes |
| `rust-quality` | rust | writing `.rs` | Idioms, anti-patterns, type modeling |
| `rust-review` | rust | reviewing Rust | 7 Rust-specific gate probes |
| `docs-busttest` | docs | docs review / updates | 18-item bus test for documentation quality |
| `mermaid` | docs | `.mmd` files / diagrams | Render and open Mermaid diagrams |
| `plan-discipline` | workflow | planning / plan mode | Verification-first, scope interview, blast radius |
| `gate-probes` | workflow | commit / review / PR | 7 universal quality probes + surgical discipline |

## Installation

**Claude Code** — marketplace plugin via `~/.claude/settings.json`:
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

**OpenCode + Codex**:
```bash
./bin/install-skills
```

## Adding a Skill

1. Create `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`)
2. If new plugin: create `plugins/<plugin>/.claude-plugin/plugin.json` and add to `.claude-plugin/marketplace.json`
3. Run `./bin/install-skills` to sync to OpenCode and Codex

## Structure

```
claude-skills/
├── plugins/                     # Source of truth — one plugin per domain
│   ├── python/                  # python-quality, python-review
│   ├── rust/                    # rust-quality, rust-review
│   ├── docs/                    # docs-busttest, mermaid
│   └── workflow/                # plan-discipline, gate-probes
├── .claude-plugin/
│   └── marketplace.json         # Marketplace registry
├── bin/
│   └── install-skills           # Install to OpenCode + Codex
├── docs/
│   ├── internal/sessions/       # Session logs
│   └── research/                # Research documents
└── _archive/
    └── legacy-slash-commands/   # v1 slash commands (2025-11)
```

## Archive

`_archive/legacy-slash-commands/` contains v1 slash commands from before Claude Code had auto-triggered skills. Some have useful patterns worth mining — check before building from scratch.
