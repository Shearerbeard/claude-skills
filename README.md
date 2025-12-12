# Claude Code Skills Library

A centralized library of Claude Code skills for Rust projects. Install selectively into any project.

## Quick Start

```bash
# Install all skills to current project
cd ~/path/to/your-project
~/dev/claude-skills/install-to-project.sh

# Or install specific categories
~/dev/claude-skills/install-to-project.sh --quality-only
~/dev/claude-skills/install-to-project.sh --docs-only
~/dev/claude-skills/install-to-project.sh --setup-only
```

## How Skills Work

Skills can be invoked two ways:

### Contextual (Conversational)
The model auto-discovers skills based on conversation context. Just describe what you need:

```
You: "Check this code for unwrap and unsafe usage"
Claude: [Uses code-safety skill automatically]

You: "I'm done coding for today, let's document what we did"
Claude: [Uses log-session skill automatically]

You: "Review my changes before I commit"
Claude: [Uses pre-commit skill automatically]
```

### Explicit (Command)
Use `/command` syntax for direct invocation:

```
/pre-commit
/code-safety
/log-session
```

Both methods use the same skill files via symlinks.

## Skills Reference

### Quality Skills (Code Review)

| Skill | Purpose | Example Prompt |
|-------|---------|----------------|
| `/code-safety` | Check unwrap, unsafe, error handling | "Check this code for unwrap and unsafe usage" |
| `/type-check` | Type-driven design patterns (ADTs, newtypes) | "Review these types for domain modeling" |
| `/test-coverage` | Verify tests exist for new code | "Do my changes have test coverage?" |
| `/perf-scan` | Performance anti-patterns (clone abuse) | "Scan for performance issues" |
| `/pre-commit` | Full quality review (runs all checks) | "Review my changes before I commit" |
| `/async-check` | Async pitfalls (blocking, Send+Sync) | "Check my async code for issues" |

### Documentation Skills

| Skill | Purpose | Example Prompt |
|-------|---------|----------------|
| `/docs-consolidate` | Clean up CLAUDE.md, organize docs | "CLAUDE.md is getting too long, clean it up" |
| `/docs-audit` | Check markdown file consistency | "Audit the documentation for consistency" |
| `/log-session` | Document session work | "Let's document what we did today" |
| `/plan-session` | Create planning/research docs | "I need to plan out this feature" |

### Setup Skills

| Skill | Purpose | Example Prompt |
|-------|---------|----------------|
| `/claudefile-audit` | Audit CLAUDE.md and .claude/ structure | "Audit my Claude Code setup" |
| `/bootstrap` | Initialize new projects with skills | "Set up Claude Code for this project" |

## Installation Options

```bash
# Full installation (all 12 skills)
./install-to-project.sh --all

# Quality skills only (6 skills)
./install-to-project.sh --quality-only

# Documentation skills only (4 skills)
./install-to-project.sh --docs-only

# Setup skills only (2 skills)
./install-to-project.sh --setup-only

# Specific skills (comma-separated)
./install-to-project.sh --skills="code-safety,pre-commit,docs-consolidate"

# Update existing installation (preserves customizations)
./install-to-project.sh --update

# Force reinstall (overwrites customizations)
./install-to-project.sh --force

# Dry run (show what would be installed)
./install-to-project.sh --dry-run

# Install to specific path
./install-to-project.sh --path=/path/to/project
```

## What Gets Installed

```
your-project/
├── .claude/
│   ├── skills/              # Skill files (model auto-discovers)
│   │   ├── code-safety.md
│   │   ├── type-check.md
│   │   ├── test-coverage.md
│   │   ├── perf-scan.md
│   │   ├── pre-commit.md
│   │   ├── async-check.md
│   │   ├── docs-consolidate.md
│   │   ├── docs-audit.md
│   │   ├── log-session/     # Directory with templates
│   │   ├── plan-session.md
│   │   ├── claudefile-audit.md
│   │   └── bootstrap.md
│   ├── commands/            # Symlinks for /command invocation
│   │   ├── code-safety.md -> ../skills/code-safety.md
│   │   ├── pre-commit.md -> ../skills/pre-commit.md
│   │   └── ...              # (all 12 skills symlinked)
│   ├── guidelines/          # Customizable standards
│   │   ├── project-standards.md
│   │   ├── type-driven-design.md
│   │   └── project-documentation-standards.md
│   ├── templates/           # Document templates
│   └── README.md            # Installation info
├── docs/
│   └── internal/
│       ├── sessions/        # Session logs
│       ├── planning/        # Ephemeral planning docs
│       └── research/        # Ephemeral research docs
```

## Guidelines

Skills reference these guidelines (installed to `.claude/guidelines/`):

| Guideline | Size | Used By |
|-----------|------|---------|
| `project-standards.md` | ~15KB | code-safety, test-coverage, perf-scan, pre-commit, async-check |
| `type-driven-design.md` | ~20KB | type-check |
| `project-documentation-standards.md` | ~14KB | docs-consolidate, docs-audit, log-session, plan-session |

Customize guidelines per-project. Skills stay synced with central library.

## Directory Structure

```
~/dev/claude-skills/
├── README.md                 # This file
├── install-to-project.sh     # Installation script
├── skills/
│   ├── code-safety.md        # Unwrap, unsafe, error handling
│   ├── type-check.md         # ADTs, newtypes, smart constructors
│   ├── test-coverage.md      # Test coverage verification
│   ├── perf-scan.md          # Performance anti-patterns
│   ├── pre-commit.md         # Full quality review
│   ├── async-check.md        # Async/await pitfalls
│   ├── docs-consolidate.md   # Documentation cleanup
│   ├── docs-audit.md         # Markdown consistency
│   ├── log-session/          # Session logging (directory)
│   ├── plan-session.md       # Planning/research docs
│   ├── claudefile-audit.md   # Project setup audit
│   └── bootstrap.md          # New project initialization
├── guidelines/
│   ├── project-standards.md
│   ├── type-driven-design.md
│   └── project-documentation-standards.md
└── templates/
    ├── adr-template.md
    └── session-template.md
```

## Updating Skills

```bash
# Update this library
cd ~/dev/claude-skills
git pull

# Update installed projects
cd ~/path/to/your-project
~/dev/claude-skills/install-to-project.sh --update
```

Update all projects at once:

```bash
for project in ~/workspace/*/; do
  if [ -d "$project/.claude/skills" ]; then
    echo "Updating $project"
    ~/dev/claude-skills/install-to-project.sh --update --path="$project"
  fi
done
```

## Multi-Project Workflow

```bash
# Project A: Full Rust web app - install everything
cd ~/workspace/web-app
~/dev/claude-skills/install-to-project.sh --all

# Project B: Small CLI tool - quality only
cd ~/workspace/cli-tool
~/dev/claude-skills/install-to-project.sh --quality-only

# Project C: Library - specific skills
cd ~/workspace/my-lib
~/dev/claude-skills/install-to-project.sh --skills="code-safety,type-check,test-coverage"
```

## Example Prompts by Skill

### Quality Skills

**code-safety** - Error handling and safety checks:
```
"Check this module for unwrap usage"
"Are there any unsafe blocks I should review?"
"Scan src/parser.rs for error handling issues"
"Review the error handling in my recent changes"
```

**type-check** - Type-driven design:
```
"Review these domain types"
"Is this struct using type-driven design correctly?"
"Check if I'm using primitive obsession anywhere"
"Should this use a newtype wrapper?"
```

**test-coverage** - Test verification:
```
"Do my changes have tests?"
"What's missing test coverage?"
"Check if the new functions are tested"
"Review test coverage for this PR"
```

**perf-scan** - Performance review:
```
"Look for unnecessary clones"
"Check for performance anti-patterns"
"Is there any clone abuse in this code?"
"Review this for allocation overhead"
```

**pre-commit** - Full quality review:
```
"Ready to commit, please review"
"Pre-commit check"
"Full quality review before I push"
"Review all my changes"
```

**async-check** - Async/await issues:
```
"Check my async code"
"Are there blocking calls in async context?"
"Review Send+Sync bounds"
"Look for async pitfalls"
```

### Documentation Skills

**docs-consolidate** - Documentation cleanup:
```
"CLAUDE.md is too long"
"Clean up the documentation"
"Consolidate the docs"
"Organize session history"
```

**docs-audit** - Markdown consistency:
```
"Audit the documentation"
"Check markdown files for consistency"
"Review doc structure"
"Are the docs organized correctly?"
```

**log-session** - Session documentation:
```
"Document today's session"
"Let's log what we accomplished"
"End of day summary"
"Create a session log"
```

**plan-session** - Planning documents:
```
"I need to plan this feature"
"Let's create a planning doc"
"Start a research document"
"Plan out the implementation"
```

### Setup Skills

**claudefile-audit** - Project setup audit:
```
"Audit my Claude Code setup"
"Is my .claude/ configured correctly?"
"Check CLAUDE.md structure"
"Review project configuration"
```

**bootstrap** - New project setup:
```
"Set up Claude Code for this project"
"Bootstrap the .claude/ directory"
"Initialize Claude Code config"
"Add Claude Code to this repo"
```

## Adding Custom Skills

Create `~/dev/claude-skills/skills/my-skill.md`:

```markdown
---
name: my-skill
description: Custom check for my workflow. Use when [trigger conditions].
---

# My Custom Skill

[Skill implementation]
```

Then update projects:

```bash
~/dev/claude-skills/install-to-project.sh --update
```

## Troubleshooting

**Skills not working contextually:**
- Check that `.claude/skills/` contains the skill files
- Verify the skill's `description:` field contains trigger words
- Try using more explicit language that matches the skill description

**Commands not working with /command:**
```bash
ls -la .claude/commands/  # Should see symlinks to ../skills/
```

**Skills not found after installation:**
```bash
ls .claude/skills/  # Should see *.md files
ls .claude/commands/  # Should see symlinks
```

**Update not working:**
```bash
~/dev/claude-skills/install-to-project.sh --force
```

**Check what's installed:**
```bash
cat .claude/README.md
```

**Symlinks broken after git clone:**
```bash
# Re-run installer to recreate symlinks
~/dev/claude-skills/install-to-project.sh --update
```

---

**Last Updated:** 2025-12-12

**License:** Personal use
