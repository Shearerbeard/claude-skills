# Claude Skills Library - Quick Start Guide

**One-page reference for daily use**

---

## ⚡ Installation

```bash
# Install to current project
cd ~/path/to/project
~/dev/claude-skills/install-to-project.sh --all

# Options
--quality-only              # Just code quality skills
--docs-only                 # Just documentation skills
--skills="standards,review" # Specific skills
--update                    # Update existing install
```

---

## 🎯 Daily Commands

### Quick Quality Check (30 seconds)
```bash
claude
/standards
exit
```
**When:** Every 30 minutes while coding
**Checks:** unwrap(), unsafe, doc comments, panics

### Full Review (2-3 minutes)
```bash
claude
/review
exit
```
**When:** Before every commit
**Checks:** Everything + clippy + tests + formatting

### Start Session with Planning
```bash
claude
/plan-session
# Choose: Planning or Research
# Enter topic
exit

# ... work on implementation ...

claude
/log-session
# Documents session + ephemeral doc status
exit
```
**When:** Complex features, research tasks

### Clean Up Documentation
```bash
claude
/consolidate
exit
```
**When:** CLAUDE.md >500 lines (check weekly)

---

## 📋 All Skills Reference

| Skill | Time | When to Use | What It Checks |
|-------|------|-------------|----------------|
| `/standards` | 30s | Every 30 min | unwrap(), unsafe, docs, panics |
| `/docs` | 30s | After feature | Doc completeness |
| `/tests` | 60s | After feature | Test coverage |
| `/perf` | 30s | Before commit | Clones, allocations |
| `/review` | 2-3m | Before commit | All of above + clippy |
| `/consolidate` | 1m | Weekly | CLAUDE.md size, scattered docs |
| `/docs-check` | 1m | Before commit | Internal vs external docs |
| `/plan-session` | 1m | Session start | Create planning/research doc |
| `/log-session` | 2m | Session end | Document session + decisions |

---

## 🔄 Typical Workflows

### Feature Development
```bash
# 1. Start
claude → /plan-session → exit

# 2. During (every 30 min)
claude → /standards → exit

# 3. Before commit
claude → /review → exit

# 4. End of session
claude → /log-session → exit
```

### Bug Fix
```bash
# Fix bug + add test
claude → /standards → /tests → exit
git commit
```

### Weekly Maintenance
```bash
# Check doc size
wc -l CLAUDE.md

# If >500 lines
claude → /consolidate → exit

# Check consistency
claude → /docs-check → exit
```

---

## 🏗️ Architecture (Quick Version)

```
Guidelines (WHAT)    →    Skills (HOW)
─────────────────         ────────────
project-standards.md  →   /standards checks unwrap()
                     →   /docs checks completeness
                     →   /tests checks coverage
                     →   /perf checks allocations

project-documentation →   /consolidate cleans docs
-standards.md         →   /log-session enforces lifecycle
                     →   /plan-session creates ephemeral
```

**Rule:** Update guidelines first, then skills

---

## 📊 Documentation Lifecycle

### Ephemeral Docs (Planning/Research)

```
CREATE
  └─ docs/internal/planning/session-NNN-plan.md
  └─ docs/internal/research/session-NNN-research.md

ITERATE
  └─ Work through doc, check off tasks

END OF SESSION (/log-session)
  ├─ KEEP (multi-session work)
  ├─ ARCHIVE (to docs/archive/YYYY/)
  └─ PROMOTE (to docs/[feature].md or ADR)
```

### Session Logs

```
docs/internal/sessions/
├── session-001.md
├── session-002.md
└── ...

# Created by: /log-session
# References: ephemeral docs, decisions, learnings
```

---

## 🚨 Critical Rules

1. **CLAUDE.md <500 lines**
   - Check: `wc -l CLAUDE.md`
   - Fix: `/consolidate`

2. **No orphaned ephemeral docs**
   - Check: `find docs/internal/{planning,research} -mtime +14`
   - Fix: Archive or promote at end of session

3. **Session logs reference ephemeral docs**
   - Enforced by: `/log-session` skill

4. **Update guidelines first, then skills**
   - See: `docs/MAINTENANCE.md`

---

## 🔍 Quick Checks

### Check CLAUDE.md size
```bash
wc -l CLAUDE.md
# If >500: run /consolidate
```

### Check for old ephemeral docs
```bash
find docs/internal/{planning,research} -name "*.md" -mtime +14
# Archive or promote these
```

### Check skill-guideline sync
```bash
grep -r "guidelines/" skills/
# Verify all skills reference guidelines
```

---

## 💡 Tips

### Start Small
Week 1: Just use `/standards`
Week 2: Add `/review` before commits
Week 3: Add `/log-session` for session docs
Week 4: Full workflow with planning

### Keyboard Shortcuts
Add to `~/.zshrc` or `~/.bashrc`:
```bash
alias check='claude -p "/standards" --exit'
alias review='claude -p "/review" --exit'
```

Then: `check` runs quick check, `review` runs full audit

### Cost Management
- Quick checks: ~$0.01 each
- Full reviews: ~$0.05-0.10 each
- Regular usage: $20-40/month

---

## 🎯 Decision Trees

### "Which skill should I run?"

```
Writing code?          → /standards (every 30 min)
Feature complete?      → /docs + /tests
About to commit?       → /review
End of session?        → /log-session
CLAUDE.md >500 lines? → /consolidate
```

### "Update guideline or skill?"

```
Rule changed?         → Update guideline, then skill
Better check method?  → Update skill only
New standard?         → Add to guideline, implement in skill
```

---

## 📁 File Locations

```
.claude/
├── guidelines/                    # WHAT to check
│   ├── project-standards.md       # Code quality rules
│   └── project-documentation-     # Doc lifecycle rules
│       standards.md
│
├── skills/                        # HOW to check
│   ├── standards.md
│   ├── docs.md, tests.md, perf.md
│   ├── review.md
│   ├── consolidate.md
│   ├── docs-check.md
│   ├── log-session.md
│   └── plan-session.md
│
└── templates/
    ├── adr-template.md
    ├── session-template.md
    └── CLAUDE-with-doc-standards.md

docs/
├── TODO.md                        # Master task list
├── architecture-decisions.md      # All ADRs
└── internal/
    ├── planning/                  # Ephemeral planning docs
    ├── research/                  # Ephemeral research docs
    └── sessions/                  # Permanent session logs
        ├── session-001.md
        └── ...
```

---

## 🚀 Getting Help

### Read Full Docs
```bash
cat ~/dev/claude-skills/README.md           # Full guide
cat ~/dev/claude-skills/ARCHITECTURE.md     # Visual flowcharts
cat ~/dev/claude-skills/docs/MAINTENANCE.md # Sync workflows
```

### Common Problems

**Skills not working?**
```bash
ls .claude/skills/  # Should see *.md files
```

**CLAUDE.md too large?**
```bash
claude → /consolidate → exit
```

**Old ephemeral docs accumulating?**
```bash
find docs/internal/{planning,research} -mtime +14
# Archive or promote them
```

**Skills and guidelines out of sync?**
```bash
cat ~/dev/claude-skills/docs/MAINTENANCE.md
# Follow sync workflow
```

---

## 📖 Next Steps

1. ✅ Install to project
2. ✅ Start with `/standards` only
3. ✅ Add `/review` before commits after 1 week
4. ✅ Add session logging after 2 weeks
5. ✅ Full workflow after 1 month

---

**Remember:**
- Check early, check often, fix immediately
- Guidelines = WHAT (source of truth)
- Skills = HOW (implementation)
- Update guidelines first, then skills
- /log-session at end of every session

**See:** `README.md` for complete documentation
**See:** `ARCHITECTURE.md` for visual flowcharts
**See:** `docs/MAINTENANCE.md` for sync workflows
