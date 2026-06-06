# CLAUDE.md - Personal Skills Library

## Overview

Personal model-invoked skills for Claude Code, OpenCode, and Codex. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

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
│   ├── docs/                         # docs-bustest, prose-lint, humanizer, mermaid
│   │   └── bin/                      # Scripts added to $PATH when plugin is enabled
│   └── workflow/                     # gate-probes, plan-discipline
├── bin/
│   ├── install-skills                # Install skills to OpenCode + Codex
│   ├── check-skills                  # Static skill/frontmatter checks
│   ├── check-install                 # Temp-home install checks
│   └── check-prose                   # Vale/prose lint smoke checks
├── docs/
│   ├── internal/sessions/            # Session logs and decision tracking
│   ├── internal/testing/             # Claude/OpenCode behavior test matrix
│   └── research/                     # Research documents
└── _archive/                         # Retired content (prior art for new skills)
    └── legacy-slash-commands/        # v1 slash commands (2025-11, pre-Skills API)
```

## Installation

**Claude Code**: marketplace plugin in `~/.claude/settings.json`:
```json
"enabledPlugins": {
  "python@my-skills": true,
  "docs@my-skills": true,
  "rust@my-skills": true,
  "workflow@my-skills": true
},
"extraKnownMarketplaces": {
  "my-skills": { "source": { "source": "directory", "path": "/Users/mshearer/dev/claude-skills" } }
}
```

**OpenCode** or **Codex**: run the install script with a target:
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

For Claude Code and OpenCode behavior checks, use `docs/internal/testing/skill-test-matrix.md`. Score auto-loading separately from manual invocation; model-driven skill routing is not deterministic.

## Adding a New Skill

1. Create `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`)
2. If this is a new plugin, create `plugins/<plugin>/.claude-plugin/plugin.json` and add to `.claude-plugin/marketplace.json`
3. Run `./bin/install-skills opencode` or `./bin/install-skills codex` if using those tools

## Bundling Scripts with Skills

If a skill needs a helper script, place it in `plugins/<plugin>/bin/`. Claude Code adds this directory to `$PATH` when the plugin is enabled, so scripts can be referenced by name from any project directory.

Do NOT put scripts inside `skills/<name>/scripts/`; that path only resolves from within this repo.

See: [Plugin structure docs](https://code.claude.com/docs/en/plugins)

## Vale Prose Linting

This repo has a local `.vale.ini` pinned to `tbhb/vale-ai-tells` v1.13.1. Vale provides deterministic AI-writing checks; `humanizer` handles semantic rewrite and voice. When invoked standalone, `humanizer` runs its own Vale pre-pass (step 0) so deterministic checks apply even without an upstream `prose-lint` call.

`prose-lint` also ships a bundled fallback `.vale.ini` for projects that do not have their own Vale config. If Vale is missing or `vale sync` fails, the skill must report the skip and continue without trying to install Vale.

Initialize package styles once per checkout:
```bash
vale sync
```

Common checks for changed prose:
```bash
vale --no-global --output=JSON README.md plugins/docs/skills/prose-lint/SKILL.md
printf '%s' "$draft" | vale --no-global --ext=.md --path=.git/COMMIT_EDITMSG --output=JSON
printf '%s' "$docstring" | vale --no-global --ext=.md --ignore-syntax --output=JSON
```

Use `prose-lint` for Vale workflows. Do not lint generated content, code blocks, schemas, exact API signatures, config examples, or intentional bad-prose examples unless the user asks.

## Writing Effective Trigger Descriptions

The `description` field in SKILL.md frontmatter is model-facing routing text. Claude Code and OpenCode both rely on model judgment over skill metadata; words like "triggered", "Triggers", "auto-triggered", and "activates" have no special runtime meaning. Claude Code can also use `when_to_use`; OpenCode ignores that field, so keep critical routing phrases in `description`.

- Lead with concrete actions: "Use when creating .rs files" not "Triggers when working with Rust"
- Reference file types, tool names, and user-facing verbs the LLM can match against
- For workflow skills (planning, review), use language users actually type: "when the user asks to plan, design, scope"
- Avoid abstract state language ("entering plan mode", "at commit boundaries"); the trigger system can't observe internal state transitions

Plan mode hooks exist in Claude Code but are buggy: EnterPlanMode hook output is ignored (#41051), user-initiated `/plan` doesn't fire hooks (#15660). In OpenCode and Claude Code, invoke `plan-discipline` manually when its hard blockers matter; plan-mode prompts often make the skill look redundant to the model.

## Planning

Before non-trivial code work, load `plan-discipline` — it enforces the scope interview, verification framing, blast-radius scan, gate placement, and review checkpoints. It is the single source of truth for planning workflow; do not duplicate its rules here.

See: [Skills docs](https://code.claude.com/docs/en/skills), [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

## Archive Convention

`_archive/` holds retired content that may be useful as source material for new skills.

- `_archive/legacy-slash-commands/`: v1 slash commands from 2025-11 (pre-Skills API). Some contain useful patterns worth mining when building new skills.

**When archiving:** move to `_archive/<descriptive-name>/`, never delete.

**When creating a new skill:** check `_archive/` for related prior work. Adapt to the current format, don't copy wholesale.
