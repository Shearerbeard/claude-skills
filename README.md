# Personal Skills Library

Model-invoked skills for Claude Code, OpenCode, and Codex. Registered as a local marketplace (`my-skills`) in `~/.claude/settings.json`.

## Skills

| Skill | Plugin | Trigger | Purpose |
|---|---|---|---|
| `python-quality` | python | writing `.py` | Toolchain (uv/ruff) + code patterns + LLM anti-patterns |
| `python-review` | python | reviewing Python | 7 Python-specific gate probes |
| `rust-quality` | rust | writing `.rs` | Anti-pattern catch list (clone escapes, wildcards, transitive deps) |
| `rust-async` | rust | async, tokio, Send+Sync | Cooperative scheduling, Send+'static, spawn_blocking vs rayon, async Drop |
| `rust-design` | rust | writing/designing/reviewing types | ADT-first workflow, constrained types, railway programming, 6-step clone avoidance |
| `rust-review` | rust | reviewing Rust | 7 Rust-specific gate probes |
| `rust-modules` | rust | Rust module layout | Modern file layout, re-exports, type co-location |
| `docs-bustest` | docs | docs review / updates | 24-item bus test for documentation quality |
| `prose-lint` | docs | Vale / prose lint | Deterministic AI-tell checks for docs and emitted prose |
| `humanizer` | docs | publishable prose | Remove AI writing patterns from user-facing text |
| `mermaid` | docs | `.mmd` files / diagrams | Render and open Mermaid diagrams |
| `plan-discipline` | workflow | planning / design / scope | Verification-first, scope interview, blast radius |
| `gate-probes` | workflow | commit / review / PR | 7 universal quality probes + surgical discipline |

## How Skills Chain

Skills are designed to compose — a single prompt can load 2-3 skills when the content spans multiple domains.

### Rust stack

```
User prompt → rust-design   (type modeling, ADTs, constrained types)
            → rust-async    (Send+Sync, spawn, cooperative scheduling)
            → rust-quality  (anti-pattern catch list)
            → rust-review   (gate checklist, loaded at review time)
            → rust-modules  (file layout, triggered on mod/split/create)
```

Common combos:
- "design an async connection pool with proper types and Send bounds" → `rust-design` + `rust-async`
- "create a new billing module with Invoice state machine, avoid clone escapes" → `rust-design` + `rust-modules` + `rust-quality`
- "review this PR for clone issues and wildcard matches" → `rust-review` → `rust-quality` (loaded internally)

### Plan stack

```
User prompt → plan-discipline   (scope interview, blast radius, gate placement)
            → gate-probes       (exit check at each gate: sprawl, duplication, coherence)
                                   → rust-review / python-review (language-specific)
```

### Async concerns

`rust-async` is separate from `rust-design`. Design triggers ("type", "enum", "struct") fire `rust-design`. Async triggers ("tokio", "spawn", "Send+Sync") fire `rust-async`. A prompt with both triggers loads both.

## Writing Skill Descriptions

The `description` field in SKILL.md frontmatter is model-facing routing text. Follow these conventions:

- **Lead with concrete user phrases**: "Use when the user says 'design a Rust type', 'model this in Rust'" — not "Triggers when working with Rust."
- **List keywords and verbs the user actually types**: "async function", "tokio", "spawn a task" — the model matches against these.
- **Front-load trigger conditions, then describe content**: trigger phrases first, then "Contains X, Y, Z."
- **Mention sibling skills for pairing**: "Pair with rust-quality during implementation."
- **Avoid abstract state language**: "entering plan mode", "at commit boundaries" — the trigger system can't observe internal state transitions.

## CLAUDE.md Guidelines

`CLAUDE.md` files (project-level and repo-level) should route to skills, not duplicate them:

```markdown
## Planning

Before non-trivial code work, load `plan-discipline` — it enforces the scope
interview, verification framing, blast-radius scan, gate placement, and review
checkpoints. It is the single source of truth for planning workflow; do not
duplicate its rules here.
```

This pattern keeps the skill as the single source of truth. Duplicating skill rules in CLAUDE.md causes the model to follow the CLAUDE.md version (which is always active) and never load the skill — missing gate types, placement rules, and templates.

## Review Gate Types

`plan-discipline` defines five gate types for structuring a plan. Each stage in the plan template specifies which gates apply and whether the user must be pulled in:

| Gate | Who | What |
|------|-----|------|
| **S** — Self-review | Agent | Run deterministic tools (lint, fmt, type check, build, test). Fix all failures. |
| **A** — Agent second opinion | Context-isolated subagent | Review diff with fresh eyes — no prior implementation context. Find issues or sign off. |
| **M** — Manual testing | Agent | Exercise the feature, report behavior, verify success criteria. |
| **U** — User review | 🛑 User | Pause and present diffs + findings. Highlight highest-risk changes. Await approval. |
| **T** — User testing | 🛑 User | Prescribe specific manual testing steps. Be explicit — don't assume the user knows how to test. |

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
│   ├── rust/                    # rust-design, rust-async, rust-quality, rust-review, rust-modules
│   ├── docs/                    # docs-bustest, prose-lint, humanizer, mermaid
│   └── workflow/                # plan-discipline, gate-probes
├── .claude-plugin/
│   └── marketplace.json         # Marketplace registry
├── bin/
│   ├── install-skills           # Install to OpenCode + Codex
│   ├── check-skills             # Static skill/frontmatter checks
│   ├── check-install            # Temp-home install checks
│   └── check-prose              # Vale/prose lint smoke checks
├── CLI.md                       # CLAUDE.md routing — routes to skills, never duplicates rules
├── docs/
│   ├── internal/sessions/       # Session logs
│   ├── internal/testing/        # Manual Claude/OpenCode test matrix
│   └── research/                # Research documents
└── _archive/
    └── legacy-slash-commands/   # v1 slash commands (2025-11)
```

## Archive

`_archive/legacy-slash-commands/` contains v1 slash commands from before Claude Code had skills. Some have useful patterns worth mining; check before building from scratch.
