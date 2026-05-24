# CLAUDE.md - Personal Skills Library

## Overview

Personal auto-triggered Skills for Claude Code and OpenCode. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

## Project Structure

```
claude-skills/
├── .claude-plugin/
│   └── marketplace.json          # Plugin registry (only lists active plugins)
├── plugins/                      # Active plugins (Claude Code marketplace format)
│   └── python/
│       ├── .claude-plugin/plugin.json
│       └── skills/
│           ├── python-quality/SKILL.md   # Coding-time rules (auto-triggers on .py)
│           └── python-review/SKILL.md    # Review gates (auto-triggers on review)
├── skills/                       # Source-of-truth flat files (copied into plugins/)
│   ├── python-quality.md
│   └── python-review.md
├── guidelines/                   # Reference material for skills
├── _archive/                     # Retired content — SEE BELOW
│   └── legacy-slash-commands/    # v1 slash commands (2025-11, pre-Skills API)
└── templates/                    # Project scaffolding templates
```

## Installation

Skills are installed globally via two mechanisms:

**Claude Code** — marketplace plugin in `~/.claude/settings.json`:
```json
"enabledPlugins": { "python@my-skills": true },
"extraKnownMarketplaces": {
  "my-skills": { "source": { "source": "directory", "path": "/Users/mshearer/dev/claude-skills" } }
}
```

**OpenCode** — copied to `~/.config/opencode/skills/<name>/SKILL.md`

## Adding a New Skill

1. Write the flat source file in `skills/<name>.md` (frontmatter: `name`, `description`)
2. Create `plugins/<plugin>/skills/<name>/SKILL.md` (copy of flat file)
3. Add plugin to `.claude-plugin/marketplace.json` if new plugin
4. Copy to `~/.config/opencode/skills/<name>/SKILL.md` for OpenCode

## Archive Convention

`_archive/` holds retired content that may be useful as source material for new skills. Subdirectories describe what was archived and why:

- `_archive/legacy-slash-commands/` — 13 v1 slash commands from 2025-11 (pre-Skills API). These were user-invoked `/command` style, installed via `install-to-project.sh` to `.claude/commands/`. Replaced by auto-triggered Skills. Some contain useful patterns (Rust safety checks, perf anti-patterns, doc lifecycle) worth mining when building new skills.

**When archiving:** move to `_archive/<descriptive-name>/`, never delete. Future agents should check `_archive/` for prior art before building a skill from scratch.

**When creating a new skill:** check `_archive/` for related prior work. Legacy content may have useful patterns, checklists, or guidelines worth extracting — but adapt to the current Skills format, don't copy wholesale.
