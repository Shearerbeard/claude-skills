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

## Skills Reference

### Quality Skills (Code Review)

| Skill | Purpose | Use When |
|-------|---------|----------|
| `/code-safety` | Check unwrap, unsafe, error handling | After writing code |
| `/type-check` | Type-driven design patterns (ADTs, newtypes) | Designing domain types |
| `/test-coverage` | Verify tests exist for new code | Before commits |
| `/perf-scan` | Performance anti-patterns (clone abuse) | Optimizing |
| `/pre-commit` | Full quality review (runs all checks) | Before every commit |
| `/async-check` | Async pitfalls (blocking, Send+Sync) | Writing async code |

### Documentation Skills

| Skill | Purpose | Use When |
|-------|---------|----------|
| `/docs-consolidate` | Clean up CLAUDE.md, organize docs | Weekly maintenance |
| `/docs-audit` | Check markdown file consistency | Before releases |
| `/log-session` | Document session work | End of day |
| `/plan-session` | Create planning/research docs | Starting complex work |

### Setup Skills

| Skill | Purpose | Use When |
|-------|---------|----------|
| `/claudefile-audit` | Audit CLAUDE.md and .claude/ structure | Reviewing project setup |
| `/bootstrap` | Initialize new projects with skills | Starting new projects |

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
│   ├── skills/              # Skill files
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
│   ├── guidelines/          # Customizable standards
│   │   ├── project-standards.md
│   │   ├── type-driven-design.md
│   │   └── project-documentation-standards.md
│   └── templates/           # Document templates
├── docs/
│   └── internal/
│       ├── sessions/        # Session logs
│       ├── planning/        # Ephemeral planning docs
│       └── research/        # Ephemeral research docs
└── .claude/README.md        # Installation info
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

**Skills not found after installation:**
```bash
ls .claude/skills/  # Should see *.md files
```

**Update not working:**
```bash
~/dev/claude-skills/install-to-project.sh --force
```

**Check what's installed:**
```bash
cat .claude/README.md
```

---

**Last Updated:** 2025-12-12

**License:** Personal use
