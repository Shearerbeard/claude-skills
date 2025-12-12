---
name: bootstrap
description: Bootstrap a new project with Claude Code structure. Use when starting new projects, setting up .claude/ directory, or when user mentions "bootstrap", "init claude", "setup project", or "new project setup". Creates CLAUDE.md and .claude/ structure.
---

# Project Bootstrap

Set up Claude Code structure for a new or existing project.

## When to Use

- Starting a new Rust project
- Adding Claude Code support to existing project
- Migrating from other AI assistant configurations
- After running /claudefile-audit in Bootstrap mode

## Step 1: Determine Scope

```json
{
  "questions": [
    {
      "question": "What do you want to bootstrap?",
      "header": "Scope",
      "multiSelect": true,
      "options": [
        {"label": "CLAUDE.md", "description": "Create/update main project instructions"},
        {"label": "Guidelines", "description": "Copy standard guidelines to .claude/guidelines/"},
        {"label": "Skills", "description": "Copy standard skills to .claude/skills/"},
        {"label": "Rules", "description": "Create .claude/rules/ with path-specific rules"}
      ]
    }
  ]
}
```

## Step 2: Gather Project Context

For CLAUDE.md generation, gather:

```bash
# Project name and description
cat Cargo.toml | grep -E "^name|^description" | head -4

# Workspace structure (if monorepo)
cat Cargo.toml | grep -A20 "\[workspace\]" | grep "members"

# Key dependencies
cat Cargo.toml | grep -E "^(rig|tokio|axum|serde|anyhow|thiserror)" | head -10

# Existing docs
ls -la README.md docs/ 2>/dev/null

# Environment files
ls -la .env* .envrc 2>/dev/null
```

## Step 3: Create Directory Structure

```bash
# Create .claude directory structure
mkdir -p .claude/guidelines
mkdir -p .claude/skills
mkdir -p .claude/rules
```

## Step 4: Copy Guidelines

Source: `~/dev/claude-skills/guidelines/`

**Core guidelines to copy:**

1. **project-standards.md** - Rust code standards
   - Error handling (no unwrap in production)
   - Documentation requirements
   - Testing standards
   - Performance guidelines

2. **type-driven-design.md** - Type safety patterns
   - Protected types with private fields
   - Smart constructors
   - No primitive obsession
   - State machines over boolean flags

3. **project-documentation-standards.md** - Doc organization
   - CLAUDE.md size limits
   - Ephemeral doc lifecycle
   - Session logging

```bash
cp ~/dev/claude-skills/guidelines/*.md .claude/guidelines/
```

## Step 5: Copy Skills

Source: `~/dev/claude-skills/skills/`

**Essential skills:**

| Skill | Purpose |
|-------|---------|
| `pre-commit.md` | Full quality review before commits |
| `test-coverage.md` | Verify test coverage for new code |
| `standards.md` | Check code against project standards |
| `type-check.md` | Verify type-driven design patterns |

**Recommended skills:**

| Skill | Purpose |
|-------|---------|
| `perf.md` | Performance anti-pattern scan |
| `plan-session.md` | Create planning/research docs |
| `log-session/` | Session logging (directory) |
| `docs-audit.md` | Documentation consistency |
| `docs-consolidate.md` | Documentation cleanup |
| `claudefile-audit.md` | Audit this setup |

```bash
# Copy all skills
cp -r ~/dev/claude-skills/skills/* .claude/skills/
```

## Step 6: Generate CLAUDE.md

Template for Rust projects:

```markdown
# CLAUDE.md - Project Documentation

## Overview
[Project name] is [brief description].

## Current Status: [Alpha | Beta | Production Ready]

[Current state, what's working, what's pending]

---

## Quick Start

```bash
# Build
cargo build --release

# Run tests
cargo test

# Run with example
cargo run --bin [binary] -- [args]
```

## Project Structure

```
[project]/
├── crates/               # Workspace members
│   ├── [crate-name]/     # [description]
│   └── ...
├── src/                  # Main source (if not workspace)
├── tests/                # Integration tests
├── docs/                 # Documentation
└── .claude/              # Claude Code configuration
    ├── guidelines/       # Team coding standards
    └── skills/           # Available skills
```

## Key Features

### [Feature Category 1]
- Feature A: [description]
- Feature B: [description]

### [Feature Category 2]
- Feature C: [description]

## Environment Setup

```bash
export VAR_NAME="value"     # [description]
export ANOTHER_VAR="value"  # [description]
```

## Architecture

### Dependencies
- **[crate]**: [what it's used for]
- **[crate]**: [what it's used for]

### Key Modules
- `[module]` - [responsibility]
- `[module]` - [responsibility]

## Standards

This project follows guidelines in `.claude/guidelines/`:
- `project-standards.md` - Error handling, testing, documentation
- `type-driven-design.md` - Type safety and domain modeling

## Documentation

- `README.md` - User-facing documentation
- `docs/` - Detailed technical docs
- `CHANGELOG.md` - Version history
```

## Step 7: Create Path-Specific Rules (Optional)

For Rust projects, create `.claude/rules/rust.md`:

```markdown
---
paths: **/*.rs
---

# Rust Code Rules

## Error Handling
- Use `?` for error propagation
- No `unwrap()` or `expect()` in production code
- Use `anyhow::Context` for error context

## Types
- Domain types: private fields + smart constructors
- Use newtypes for domain concepts (not raw String/i64)
- Prefer enums over boolean flags for state

## Documentation
- All `pub` items need doc comments
- `# Errors` section for Result-returning functions
- Don't over-document type signatures

## Testing
- Every public function needs tests
- Test happy path AND error cases
- Descriptive test names
```

## Step 8: Output Summary

```
PROJECT BOOTSTRAP COMPLETE

Project: [name]
Location: [path]

CREATED/UPDATED

CLAUDE.md
  - Overview section
  - Quick start commands
  - Project structure
  - Environment setup
  - Architecture overview
  - Standards references

.claude/guidelines/ [3 files]
  - project-standards.md
  - type-driven-design.md
  - project-documentation-standards.md

.claude/skills/ [10 files]
  - pre-commit.md
  - test-coverage.md
  - standards.md
  - type-check.md
  - perf.md
  - plan-session.md
  - log-session/ (directory)
  - docs-audit.md
  - docs-consolidate.md
  - claudefile-audit.md

.claude/rules/ [1 file]
  - rust.md (paths: **/*.rs)

NEXT STEPS

1. Review and customize CLAUDE.md for your project
2. Update environment variables section
3. Add project-specific architecture details
4. Run /claudefile-audit to verify setup
5. Commit .claude/ directory to git

VERIFICATION

Run: /claudefile-audit
Expected: All checks pass

Git:
  git add CLAUDE.md .claude/
  git commit -m "feat: add Claude Code project configuration"
```

## Customization Notes

### For Monorepos
- List all workspace members in Project Structure
- Document which crates are apps vs libraries
- Add crate-specific rules in `.claude/rules/`

### For Web Services
- Document API endpoints location
- Add OpenAPI/Swagger references
- Include health check endpoints

### For CLI Tools
- Document all subcommands
- Include usage examples
- Reference man pages if available

---

**After bootstrap, run /claudefile-audit to verify setup.**
