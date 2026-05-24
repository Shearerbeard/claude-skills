# Personal Skills Library

Auto-triggered skills for Claude Code and OpenCode. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

## Skills

| Skill | Lines | Trigger | Purpose |
|---|---|---|---|
| `plan-discipline` | 38 | planning / plan mode | Verification-first, scope interview, blast radius |
| `gate-probes` | 22 | commit / review / PR | Universal quality probes + surgical discipline |
| `python-quality` | 54 | writing `.py` | Toolchain (uv/ruff) + code patterns + LLM anti-patterns |
| `python-review` | 43 | reviewing Python | 7 Python-specific gate probes |
| `rust-quality` | 61 | writing `.rs` | Idioms, anti-patterns, type modeling |
| `rust-review` | 18 | reviewing Rust | 7 Rust-specific gate probes |
| `docs-busttest` | 93 | docs review / updates | 18-item bus test for documentation quality |

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

**OpenCode** — files at `~/.config/opencode/skills/<name>/SKILL.md`.

## Adding a skill

1. Write source file in `skills/<name>.md` (frontmatter: `name`, `description`)
2. Create `plugins/<plugin>/skills/<name>/SKILL.md` (copy of source)
3. Add plugin to `.claude-plugin/marketplace.json` if new
4. Copy to `~/.config/opencode/skills/<name>/SKILL.md`

## Structure

```
claude-skills/
├── skills/                  # Source-of-truth flat files (7 skills)
├── plugins/                 # Claude Code marketplace format
│   ├── python/              # python-quality, python-review
│   ├── rust/                # rust-quality, rust-review
│   ├── docs/                # docs-busttest
│   └── workflow/            # plan-discipline, gate-probes
├── .claude-plugin/
│   └── marketplace.json     # Plugin registry
├── guidelines/              # Reference material
└── _archive/
    └── legacy-slash-commands/  # v1 skills (2025-11, pre-marketplace API)
```

## Archive

`_archive/legacy-slash-commands/` contains 13 v1 slash commands from before Claude Code had auto-triggered skills. Some have useful patterns worth mining when building new skills — check before building from scratch.
