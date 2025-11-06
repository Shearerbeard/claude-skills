# Claude Code Skills - Personal Library

**Multi-project, a la carte installation of Claude Code quality and documentation skills**

---

## 📖 Quick Navigation

| Document | Purpose | Read This If... |
|----------|---------|-----------------|
| **[QUICK-START.md](QUICK-START.md)** | One-page reference | You want daily commands and workflows |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Visual flowcharts | You want to understand how it all fits together |
| **[README.md](README.md)** | Full documentation | You want complete details (this file) |
| **[docs/MAINTENANCE.md](docs/MAINTENANCE.md)** | Sync workflows | You're updating skills or guidelines |

---

## 🎯 What This Is

A centralized library of Claude Code Skills that you can selectively install into any project. Perfect for:
- ✅ Using same skills across multiple projects
- ✅ Maintaining one source of truth
- ✅ A la carte adoption (install what you need)
- ✅ Individual developer workflow (not team-wide)

## 📦 What's Included

### Quality Control Skills (5 skills)
- `/standards` - Quick safety check (unwrap, unsafe, panics) - 30s
- `/docs` - Documentation completeness check - 30s
- `/tests` - Test coverage verification - 60s
- `/perf` - Performance anti-pattern scan - 30s
- `/review` - Comprehensive quality audit - 2-3min

### Documentation Skills (3 skills)
- `/consolidate` - Clean up scattered documentation - 1min
- `/docs-check` - Check internal/external doc consistency - 1min
- `/log-session` - Create session log from git activity - 2min

### Templates (2 templates)
- `adr-template.md` - Architecture Decision Records
- `session-template.md` - Session logging

### Guidelines (1 guideline)
- `project-standards.md` - Rust coding standards template

## 🚀 Quick Start

### 1. Install to a Project

```bash
cd ~/path/to/your-project
~/dev/claude-skills/install-to-project.sh
```

This creates:
```
your-project/
├── .claude/
│   ├── skills/              # Copied from this library
│   └── guidelines/          # Customizable per-project
├── docs/internal/sessions/  # For session logs
├── ADR/                     # For architecture decisions
└── TODO.md                  # Task tracking
```

### 2. Choose What to Install (A la Carte)

```bash
# Install only quality skills
~/dev/claude-skills/install-to-project.sh --quality-only

# Install only documentation skills
~/dev/claude-skills/install-to-project.sh --docs-only

# Install specific skills
~/dev/claude-skills/install-to-project.sh --skills="standards,review,consolidate"
```

### 3. Test It

```bash
cd your-project
claude
/standards
exit
```

## 📁 Directory Structure

```
~/dev/claude-skills/
├── README.md                    # This file
├── install-to-project.sh        # Installation script
├── skills/
│   ├── standards.md             # Safety check
│   ├── docs.md                  # Documentation check
│   ├── tests.md                 # Test coverage
│   ├── perf.md                  # Performance check
│   ├── review.md                # Full review
│   ├── consolidate.md           # Doc cleanup
│   ├── docs-check.md            # Doc consistency
│   └── log-session.md           # Session logging
├── templates/
│   ├── adr-template.md
│   └── session-template.md
└── guidelines/
    └── project-standards.md     # Template for projects
```

## 🔄 Updating Skills

### Update This Library

```bash
cd ~/dev/claude-skills
git pull  # If tracking updates
```

### Update Installed Projects

```bash
cd ~/path/to/your-project
~/dev/claude-skills/install-to-project.sh --update
```

This preserves your customized guidelines but updates skills.

## 💡 Multi-Project Workflow

### Scenario: You have 3 projects

**Project A (Full stack Rust web app)**
```bash
cd ~/workspace/project-a
~/dev/claude-skills/install-to-project.sh --all
# Uses: All skills, needs comprehensive quality checks
```

**Project B (Small CLI tool)**
```bash
cd ~/workspace/project-b
~/dev/claude-skills/install-to-project.sh --quality-only
# Uses: Only quality skills, minimal docs needed
```

**Project C (Library)**
```bash
cd ~/workspace/project-c
~/dev/claude-skills/install-to-project.sh --skills="standards,docs,review"
# Uses: Quality + docs, no session logging
```

### All Projects Use Same Source

- Update skills in `~/dev/claude-skills/` once
- Re-run `install-to-project.sh --update` in each project
- Customizations (guidelines, templates) stay project-specific

## 📋 Installation Options

```bash
# Full installation
./install-to-project.sh --all

# Quality skills only
./install-to-project.sh --quality-only

# Documentation skills only
./install-to-project.sh --docs-only

# Specific skills (comma-separated)
./install-to-project.sh --skills="standards,review,docs-check"

# Update existing installation (preserves customizations)
./install-to-project.sh --update

# Dry run (show what would be installed)
./install-to-project.sh --dry-run
```

## 🎯 When to Use What

### Use `/standards` every 30 minutes
Quick safety check while coding. Catches unwrap(), unsafe, panics.

### Use `/review` before every commit
Comprehensive quality audit. Runs clippy, checks tests, docs.

### Use `/consolidate` weekly
Cleans up scattered documentation, keeps CLAUDE.md < 500 lines.

### Use `/log-session` end of day
Captures session learnings from git activity.

## 🔧 Customization Per Project

After installation, customize in your project:

```bash
cd your-project

# Edit project-specific standards
vim .claude/guidelines/project-standards.md

# Edit templates if needed
vim .claude/templates/adr-template.md
```

Skills remain unchanged (updated from central library).

## 📊 Maintenance

### Keep Skills Up to Date

```bash
# In skills library
cd ~/dev/claude-skills
git pull

# Update all your projects
for project in ~/workspace/*/; do
  if [ -d "$project/.claude/skills" ]; then
    echo "Updating $project"
    ~/dev/claude-skills/install-to-project.sh --update --path="$project"
  fi
done
```

### Track Your Changes

```bash
cd ~/dev/claude-skills
git init
git add .
git commit -m "Initial skills library"

# Optional: Push to private repo
git remote add origin git@github.com:yourusername/claude-skills.git
git push -u origin main
```

## 🎨 Customization Tips

### Add Your Own Skills

Create `~/dev/claude-skills/skills/my-skill.md`:

```markdown
---
name: my-skill
description: Custom check for my workflow
---

# My Custom Skill

Check for:
- Project-specific patterns
- Domain-specific issues
```

Install to projects:
```bash
~/dev/claude-skills/install-to-project.sh --update
```

### Per-Project Variations

Some projects need different standards:

```bash
# Project A: Strict standards (web app)
cd ~/workspace/project-a
vim .claude/guidelines/project-standards.md
# Add: "No unwrap() in any code"

# Project B: Relaxed standards (personal tool)
cd ~/workspace/project-b
vim .claude/guidelines/project-standards.md
# Add: "unwrap() OK in main.rs only"
```

Skills stay the same, guidelines differ.

## 💰 Cost Estimate

Per project, per month:
- Light usage (1-2 checks/day): $5-10
- Regular usage (5-10 checks/day): $20-40
- Heavy usage (20+ checks/day): $50-100

Using same skills across 3 projects doesn't triple cost—it's about usage frequency.

## 🐛 Troubleshooting

### Skills not found after installation
```bash
cd your-project
ls .claude/skills/  # Should see *.md files
```

### Update not working
```bash
# Force reinstall
~/dev/claude-skills/install-to-project.sh --force
```

### Different projects need different skill versions
Create separate skill libraries:
```bash
mkdir ~/dev/claude-skills-v1
mkdir ~/dev/claude-skills-v2
```

## 🏗️ Architecture: Source of Truth

**Guidelines = WHAT to check (rules, principles, examples)**
**Skills = HOW to check (implementation, commands, reporting)**

```
guidelines/project-standards.md
  ↓ defines "No unwrap() in production code"
  ↓
skills/standards.md
  ↓ implements: grep for unwrap(), check context
  ↓ references: guideline sections
```

**Why this matters:**
- Guidelines are source of truth for rules
- Skills implement the checks
- Update guidelines first, then skills
- Avoid duplication and drift

**See:** `docs/MAINTENANCE.md` for complete maintenance workflow

### Current Guidelines

| Guideline | Purpose | Referenced By |
|-----------|---------|---------------|
| `project-standards.md` | Rust code quality rules | `/standards`, `/docs`, `/tests`, `/perf` |
| `project-documentation-standards.md` | Doc lifecycle management | `/consolidate`, `/docs-check`, `/log-session`, `/plan-session` |

### Current Skills

**Quality Skills:**
- `/standards` - Checks: unwrap(), unsafe, doc comments (refs: project-standards.md)
- `/docs` - Checks: documentation completeness (refs: project-standards.md)
- `/tests` - Checks: test coverage (refs: project-standards.md)
- `/perf` - Checks: performance anti-patterns (refs: project-standards.md)
- `/review` - Comprehensive audit (uses all above + clippy)

**Documentation Skills:**
- `/consolidate` - Cleanup (refs: project-documentation-standards.md)
- `/docs-check` - Consistency check + auto-fixes (refs: project-documentation-standards.md)
- `/log-session` - Session logging with lifecycle (refs: project-documentation-standards.md)
- `/plan-session` - Planning/research docs (refs: project-documentation-standards.md)

## 🔧 Maintenance

**Adding a new standard:**

1. Update guideline first (source of truth)
2. Update implementing skill
3. Document mapping in `docs/MAINTENANCE.md`
4. Test changes

**Syncing skills and guidelines:**

```bash
# Check references
grep -r "guidelines/" skills/

# Verify mapping
cat docs/MAINTENANCE.md
```

**LLM-assisted maintenance:**

Use Claude to help maintain consistency:

```
Review guidelines/project-standards.md and skills/standards.md
for consistency. Report discrepancies and suggest fixes.
```

**See:** `docs/MAINTENANCE.md` for complete workflows

## 📚 Related Documentation

- `docs/MAINTENANCE.md` - **Maintenance guide (skills ↔ guidelines sync)**
- `QUICK-REFERENCE-v2.txt` - One-page command reference
- `COMPLETE-IMPLEMENTATION-GUIDE.md` - Detailed setup guide
- `skills/*.md` - Individual skill documentation
- `guidelines/*.md` - Standards and rules

## 🔗 Source

Skills extracted from:
- rust-quality-starter-kit.tar.gz
- documentation-addon.tar.gz

Organized for multi-project, a la carte installation.

---

**Last Updated:** 2025-11-05

**Maintained By:** Your name

**License:** Personal use

**Note:** This is your personal skills library. Customize freely!
