# CLAUDE.md - Claude Skills Library

## Overview
This is a **personal slash commands library** for Claude Code - a centralized repository of reusable quality and documentation commands that can be installed into multiple projects. Keep this file under 500 lines.

**Implementation Note:** These are slash commands (explicitly invoked with `/command`), not Skills (model-invoked). Installed to `.claude/commands/` in projects.

## Project Summary
- **Project**: claude-skills
- **Created**: 2025-11-05
- **Goal**: Maintain a single source of truth for Claude Code skills, installable a la carte into any project
- **Architecture**: Guidelines (WHAT) → Skills (HOW) → Projects

## Current Status

**Next Steps**:
- Dogfood all skills on this repository
- Test installation workflow across multiple projects
- Document real-world usage patterns and costs

---

## Quick Start

```bash
# Test installation locally (dogfooding)
cd ~/dev/claude-skills
./install-to-project.sh --all

# Install to another project
cd ~/path/to/your-project
~/dev/claude-skills/install-to-project.sh --all

# Update this library's skills
cd ~/dev/claude-skills
git pull  # If syncing from remote

# Update installed projects
cd ~/path/to/project
~/dev/claude-skills/install-to-project.sh --update
```

---

## Project Structure

```
claude-skills/
├── skills/                        # HOW to check (9 slash commands)
│   ├── Quality (5):
│   │   ├── standards.md          # Safety check (unwrap, unsafe)
│   │   ├── docs.md               # Documentation completeness
│   │   ├── tests.md              # Test coverage
│   │   ├── perf.md               # Performance anti-patterns
│   │   └── review.md             # Comprehensive audit
│   └── Documentation (4):
│       ├── consolidate.md        # Doc cleanup
│       ├── docs-check.md         # Consistency check
│       ├── log-session.md        # Session logging
│       └── plan-session.md       # Planning/research docs
│
├── guidelines/                    # WHAT to check (source of truth)
│   ├── project-standards.md      # Rust code quality rules
│   └── project-documentation-    # Doc lifecycle management
│       standards.md
│
├── templates/                     # Templates for installed projects
│   ├── adr-template.md
│   ├── session-template.md
│   └── CLAUDE-with-doc-          # Template for project CLAUDE.md
│       standards.md
│
├── docs/
│   ├── MAINTENANCE.md            # Commands ↔ guidelines sync workflow
│   └── internal/sessions/        # Session logs for this library
│
├── install-to-project.sh         # Smart installer script
├── README.md                      # Full documentation
├── QUICK-START.md                 # One-page reference
└── ARCHITECTURE.md                # Visual flowcharts
```

**Note:** These are implemented as **slash commands** (user-invoked with `/command`), not Skills (model-invoked). When installed, they go into `.claude/commands/` in your project.

---

## Key Features

1. **A la carte installation** - Install all, quality-only, docs-only, or specific commands
2. **Smart guidelines** - Only installs guidelines needed for selected commands
3. **Update preservation** - `--update` flag preserves project customizations
4. **Single source of truth** - Maintain commands in one place, update all projects
5. **Dogfooding ready** - This repo now uses its own slash commands for quality control

---

## Recent Sessions

**Session 002 (2025-11-05)**: Skills library enhancement
- Added explicit guideline references in skills
- Created smart installer logic (only installs needed guidelines)
- Enhanced documentation with visual flowcharts and quick reference
- Added comprehensive maintenance guide
- **See**: `docs/internal/sessions/session-002.md` for full details

**Session 001 (Initial)**: Library creation
- Extracted skills from rust-quality-starter-kit
- Created multi-project installation workflow
- Established guidelines → skills architecture

---

## Documentation Structure

**This project follows strict documentation lifecycle management.**

**Essential References**:
- `TODO.md` - Task tracking and priorities
- `docs/MAINTENANCE.md` - **Skills ↔ guidelines sync workflow (READ THIS)**
- `docs/internal/sessions/` - Session logs
- `.claude/guidelines/project-documentation-standards.md` - Documentation rules

**Documentation Guidelines** (enforced by Claude):

1. **CLAUDE.md stays under 500 lines**
   - Extract session history to `docs/archive/YYYY/`
   - Use pointers, not full content
   - Run `/consolidate` if exceeding limit

2. **Ephemeral docs have lifecycle**
   - Planning docs: `docs/internal/planning/session-NNN-planning.md`
   - Research docs: `docs/internal/research/session-NNN-research.md`
   - Must be archived or promoted at end of session

3. **Session logs document everything**
   - Created using `/log-session` skill
   - Reference ephemeral docs
   - Record archive/promote decisions

---

## Maintenance Workflow

### Adding a New Standard

**Example:** Add "No hardcoded secrets" check

1. **Update guideline first** (source of truth):
   ```bash
   vim guidelines/project-standards.md
   # Add section: "No Hardcoded Secrets"
   # Include: rationale, examples, when it applies
   ```

2. **Update implementing skill**:
   ```bash
   vim skills/standards.md
   # Add check: grep for API_KEY|SECRET|PASSWORD
   # Reference new guideline section
   ```

3. **Document mapping**:
   ```bash
   vim docs/MAINTENANCE.md
   # Add row to mapping table
   ```

4. **Test**:
   ```bash
   claude
   /standards
   exit
   ```

**See**: `docs/MAINTENANCE.md` for complete workflow

### Updating Skills in Projects

```bash
# 1. Update skills in this library
cd ~/dev/claude-skills
vim skills/standards.md

# 2. Test locally (dogfooding)
claude
/standards
exit

# 3. Update all installed projects
cd ~/path/to/project-a
~/dev/claude-skills/install-to-project.sh --update

cd ~/path/to/project-b
~/dev/claude-skills/install-to-project.sh --update
```

### Syncing Guidelines and Skills

```bash
# Check all guideline references in skills
grep -r "guidelines/" skills/

# Check templates reference guidelines
grep -r "guidelines/" templates/

# Use LLM-assisted sync check
claude
> Review guidelines/project-standards.md and skills/standards.md
> for consistency. Report discrepancies and suggest fixes.
exit
```

---

## Development Workflow

**Starting a new session:**
1. Create planning doc if needed: `/plan-session`
2. Work through changes
3. Run quality checks: `/standards`, `/docs`
4. Create session log: `/log-session`
5. Archive or promote ephemeral docs

**Before committing to this library:**
```bash
# No Rust code to check, so focus on docs
claude
/docs-check     # Verify documentation consistency
/consolidate    # If CLAUDE.md > 500 lines
exit

# Commit
git add .
git commit -m "feat: add new skill"
```

**Weekly maintenance:**
```bash
# Check documentation health
wc -l CLAUDE.md  # Should be <500

# Check ephemeral docs
find docs/internal/{planning,research} -name "*.md" -mtime +14

# Run skills on this library
claude
/docs-check
exit
```

---

## Architecture: Source of Truth

**Guidelines = WHAT to check (rules, principles, examples)**
**Slash Commands = HOW to check (implementation, commands, reporting)**

```
guidelines/project-standards.md
  ↓ defines "No unwrap() in production code"
  ↓
skills/standards.md (source file)
  ↓ implements: grep for unwrap(), check context
  ↓ references: guideline section
  ↓
install-to-project.sh
  ↓ copies to: ~/path/to/project/.claude/commands/standards.md
  ↓ invoked as: /standards
```

**Critical Rule:** Update guidelines first, then slash commands. Never the reverse.

**Guideline → Skill Mapping:**

| Guideline | Checked By | How |
|-----------|------------|-----|
| `project-standards.md` | `/standards` | grep unwrap/unsafe, check docs |
| `project-standards.md` | `/docs` | Check /// comments on pub items |
| `project-standards.md` | `/tests` | Check test coverage |
| `project-standards.md` | `/perf` | grep clone, allocations |
| `project-documentation-standards.md` | `/consolidate` | wc -l CLAUDE.md |
| `project-documentation-standards.md` | `/log-session` | Document lifecycle |
| `project-documentation-standards.md` | `/docs-check` | Consistency check |

**See**: `docs/MAINTENANCE.md` for complete mapping and workflows

---

## Installation Script Logic

The `install-to-project.sh` script is **smart about guidelines**:

```bash
# Only installs guidelines needed for selected skills

--quality-only
  → Installs: project-standards.md
  → Skips: project-documentation-standards.md

--docs-only
  → Installs: project-documentation-standards.md
  → Skips: project-standards.md

--all
  → Installs: both guidelines
```

**Rationale:** Minimizes context size in installed projects. If you only use quality skills, you don't need 14KB of doc standards.

---

## Key Design Decisions

Recent decisions (see session logs for details):
- **Guidelines as source of truth** - Skills implement what guidelines define (session-002)
- **Smart installer** - Only installs guidelines needed for selected commands (session-002)
- **Slash commands not Skills** - User-invoked for quality checks (session-004)
- **Explicit guideline references** - Commands reference specific guideline sections (session-002)

---

## Installation Options Reference

```bash
# Full installation
./install-to-project.sh --all

# Quality skills only (5 skills)
./install-to-project.sh --quality-only

# Documentation skills only (4 skills)
./install-to-project.sh --docs-only

# Specific skills
./install-to-project.sh --skills="standards,review,consolidate"

# Update existing (preserves customizations)
./install-to-project.sh --update

# Force reinstall (overwrites customizations)
./install-to-project.sh --force

# Dry run (show what would be installed)
./install-to-project.sh --dry-run

# Install to specific path
./install-to-project.sh --path=/path/to/project
```

---

## Testing Strategy

**Dogfooding this library:**
```bash
cd ~/dev/claude-skills
./install-to-project.sh --all

# Test each skill
claude
/standards     # Should work (checks .md files for standards)
/docs          # Should report on documentation
/docs-check    # Should verify this CLAUDE.md
/consolidate   # Should check CLAUDE.md size
exit
```

**Multi-project testing:**
```bash
# Create test projects in different states
mkdir ~/test-project-{a,b,c}

# Test different installation modes
cd ~/test-project-a && ~/dev/claude-skills/install-to-project.sh --quality-only
cd ~/test-project-b && ~/dev/claude-skills/install-to-project.sh --docs-only
cd ~/test-project-c && ~/dev/claude-skills/install-to-project.sh --all

# Verify directory structures
ls -R ~/test-project-{a,b,c}/.claude/
```

---

## Important: Claude Code Instructions

**Claude, you MUST:**

1. **Read `docs/MAINTENANCE.md` before modifying skills or guidelines**
   - Follow guidelines → skills workflow
   - Update guidelines first, then skills
   - Document mappings

2. **When updating a skill:**
   - Check if guideline needs updating first
   - Verify guideline references are correct
   - Test the skill after changes

3. **When updating a guideline:**
   - Identify all skills that implement it
   - Update those skills to match
   - Update mapping table in MAINTENANCE.md

4. **At end of session:**
   - Run `/log-session` skill
   - Document ephemeral doc status
   - Check CLAUDE.md size (< 500 lines)

5. **Before committing:**
   - Run `/docs-check` on this library
   - Verify skills reference guidelines correctly
   - Ensure documentation is consistent

**Available slash commands** (dogfooding):
- `/standards` - Code quality check (30s) - *now checks this library*
- `/docs` - Documentation completeness (30s)
- `/tests` - Test coverage (60s)
- `/perf` - Performance issues (30s)
- `/review` - Full quality audit (2-3 min)
- `/consolidate` - Documentation cleanup (1 min)
- `/docs-check` - Documentation consistency (1 min)
- `/log-session` - Create session log (2 min)
- `/plan-session` - Planning/research doc creation (1 min)

---

## Documentation Sources of Truth

**Installation Guide**: `README.md` - Comprehensive documentation for all installation scenarios

**Quick Reference**: `QUICK-START.md` - One-page guide for daily usage

**Visual Guide**: `ARCHITECTURE.md` - Flowcharts and diagrams

**Maintenance**: `docs/MAINTENANCE.md` - **Skills ↔ guidelines sync workflow**

**Session History**: `docs/internal/sessions/` - Development history reference

**Documentation Rules**: `.claude/guidelines/project-documentation-standards.md`