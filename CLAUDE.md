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
│   ├── rust/                         # rust-quality, rust-review, rust-modules
│   ├── docs/                         # docs-bustest, mermaid
│   │   └── bin/                      # Scripts added to $PATH when plugin is enabled
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

**OpenCode** or **Codex** — run the install script with a target:
```bash
./bin/install-skills opencode   # ~/.config/opencode/skills/
./bin/install-skills codex      # ~/.codex/skills/
```

## Adding a New Skill

1. Create `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`)
2. If this is a new plugin, create `plugins/<plugin>/.claude-plugin/plugin.json` and add to `.claude-plugin/marketplace.json`
3. Run `./bin/install-skills opencode` or `./bin/install-skills codex` if using those tools

## Bundling Scripts with Skills

If a skill needs a helper script, place it in `plugins/<plugin>/bin/`. Claude Code adds this directory to `$PATH` when the plugin is enabled, so scripts can be referenced by name from any project directory.

Do NOT put scripts inside `skills/<name>/scripts/` — that path only resolves from within this repo.

See: [Plugin structure docs](https://code.claude.com/docs/en/plugins)

## Writing Effective Trigger Descriptions

The `description` field in SKILL.md frontmatter controls auto-triggering. Claude Code uses LLM reasoning; OpenCode uses semantic embedding similarity (cosine, threshold 0.35).

- Lead with concrete actions: "Use when creating .rs files" not "Triggers when working with Rust"
- Reference file types, tool names, and user-facing verbs the LLM can match against
- For workflow skills (planning, review), use language users actually type: "when the user asks to plan, design, scope"
- Avoid abstract state language ("entering plan mode", "at commit boundaries") — the trigger system can't observe internal state transitions

Plan mode hooks exist in Claude Code but are buggy: EnterPlanMode hook output is ignored (#41051), user-initiated `/plan` doesn't fire hooks (#15660). In OpenCode, plan-discipline must be invoked manually via `/plan-discipline` because the plan agent's system prompt crowds out auto-triggering.

See: [Skills docs](https://code.claude.com/docs/en/skills), [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

## Archive Convention

`_archive/` holds retired content that may be useful as source material for new skills.

- `_archive/legacy-slash-commands/` — v1 slash commands from 2025-11 (pre-Skills API). Some contain useful patterns worth mining when building new skills.

**When archiving:** move to `_archive/<descriptive-name>/`, never delete.

**When creating a new skill:** check `_archive/` for related prior work. Adapt to the current format, don't copy wholesale.
