# CLAUDE.md - Personal Skills Library

## Overview

Personal auto-triggered skills for Claude Code, OpenCode, and Codex. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

## Project Structure

```
claude-skills/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace registry (lists plugins with source paths)
├── plugins/                          # Source of truth — one plugin per domain
│   ├── python/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       ├── python-quality/SKILL.md
│   │       └── python-review/SKILL.md
│   ├── rust/                         # rust-quality, rust-review
│   ├── docs/                         # docs-busttest, mermaid
│   └── workflow/                     # gate-probes, plan-discipline
├── bin/
│   └── install-skills                # Install skills to OpenCode + Codex
├── docs/
│   ├── internal/sessions/            # Session logs and decision tracking
│   └── research/                     # Research documents
└── _archive/                         # Retired content (prior art for new skills)
    └── legacy-slash-commands/        # v1 slash commands (2025-11, pre-Skills API)
```

## Installation

**Claude Code** — marketplace plugin in `~/.claude/settings.json`:
```json
"enabledPlugins": { "python@my-skills": true },
"extraKnownMarketplaces": {
  "my-skills": { "source": { "source": "directory", "path": "/Users/mshearer/dev/claude-skills" } }
}
```

**OpenCode + Codex** — run the install script:
```bash
./bin/install-skills
```

This copies each SKILL.md to `~/.config/opencode/skills/<name>/` and `~/.codex/skills/<name>/`.

## Adding a New Skill

1. Create `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`)
2. If this is a new plugin, create `plugins/<plugin>/.claude-plugin/plugin.json` and add to `.claude-plugin/marketplace.json`
3. Run `./bin/install-skills` to sync to OpenCode and Codex

## Archive Convention

`_archive/` holds retired content that may be useful as source material for new skills.

- `_archive/legacy-slash-commands/` — v1 slash commands from 2025-11 (pre-Skills API). Some contain useful patterns worth mining when building new skills.

**When archiving:** move to `_archive/<descriptive-name>/`, never delete.

**When creating a new skill:** check `_archive/` for related prior work. Adapt to the current format, don't copy wholesale.
