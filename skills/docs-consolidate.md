---
name: docs-consolidate
description: Consolidate scattered documentation and clean up temporary artifacts. Use weekly, after large sessions, when CLAUDE.md is bloated, or when user mentions "consolidate docs", "clean up documentation", "organize docs", or "CLAUDE.md too big". Moves content to proper locations.
---

# Documentation Consolidation & Cleanup

Find scattered documentation artifacts, consolidate them into proper locations, and clean up temporary files.

## Standards Reference

**Source:** `.claude/guidelines/project-documentation-standards.md`

Implements:
- Rule 1: CLAUDE.md must stay <500 lines
- Rule 2: No orphaned ephemeral docs
- Rule 4: Pointer files at root

## Common Problems This Fixes

1. **CLAUDE.md bloat** - Session notes, TODOs, temp observations
2. **Scattered markdown files** - Summary files in random places
3. **Temporary scripts** - Verification scripts never cleaned up
4. **Duplicate information** - Same TODO in multiple places
5. **Session logs** - Insights buried in chat history

## Step 1: Scan for Documentation Artifacts

```bash
# Find temporary markdown files
find . -type f -name "*.md" \
  -not -path "./docs/*" \
  -not -path "./target/*" \
  -not -path "./.git/*" \
  -not -name "README.md" \
  -not -name "CHANGELOG.md" \
  -not -name "TODO.md" \
  -not -name "CLAUDE.md" \
  -not -name "ARCHITECTURE.md"

# Find shell scripts (potential temp scripts)
find . -type f -name "*.sh" \
  -not -path "./target/*" \
  -not -path "./.git/*" \
  -not -path "./scripts/*" \
  -mtime -7

# Find temporary note files
find . -type f \( -name "notes.txt" -o -name "temp.md" -o -name "session*.md" \)

# Check CLAUDE.md size
wc -l CLAUDE.md
```

## Step 2: Analyze CLAUDE.md for Scattered Content

Look for sections that belong elsewhere:

| Content Type | Move To | Action |
|--------------|---------|--------|
| TODOs | TODO.md | Extract and merge |
| Architecture decisions | ADR/ | Create formal ADR |
| Session learnings | docs/internal/sessions/ | Create session log |
| Changelog items | CHANGELOG.md | Add to [Unreleased] |
| Technical debt | docs/internal/tech-debt.md | Consolidate |

## Step 3: Consolidation Decision Matrix

```
Content Type            | Belongs In              | Action
------------------------|-------------------------|------------------
Public API examples     | Code doc comments       | Move to /// docs
Architecture overview   | ARCHITECTURE.md         | Consolidate there
TODO items              | TODO.md                 | Merge & deduplicate
Completed work          | CHANGELOG.md            | Add to [Unreleased]
Design decisions        | ADR/ADR-NNN-title.md    | Create formal ADR
Session insights        | docs/internal/sessions/ | Create session log
Temporary notes         | Delete or move          | Clean up
Project context         | CLAUDE.md (clean)       | Keep only essentials
Technical debt          | docs/internal/          | Consolidate issues
Build/verification      | scripts/ or delete      | Move or remove
```

## Step 4: Output Consolidation Plan

```
DOCUMENTATION CONSOLIDATION

FOUND SCATTERED DOCUMENTATION

Temporary Files:
  - ./temp_notes.md (2KB, modified today)
  - ./session_summary.md (1KB, modified today)
  - ./verify_api.sh (500B, modified yesterday)

CLAUDE.md Analysis (currently N lines):
  - 8 TODO items (should be in TODO.md)
  - 2 architectural decisions (should be ADRs)
  - 1 session log (should be in docs/internal/sessions/)
  - 1 changelog entry (should be in CHANGELOG.md)

CONSOLIDATION PLAN

1. TODO.md
   ADD:
   - [ ] Fix memory leak in parser (from CLAUDE.md)
   - [ ] Add authentication (from CLAUDE.md)

   REMOVE FROM CLAUDE.md:
   Lines 45-52

2. ADR/ADR-006-zero-copy-parsing.md
   CREATE NEW:
   Extract decision from CLAUDE.md lines 60-75
   Status: Accepted
   Date: [today]

3. docs/internal/sessions/session-NNN.md
   CREATE NEW:
   Extract session notes from CLAUDE.md lines 80-95

4. CHANGELOG.md [Unreleased]
   ADD:
   - Added zero-copy parsing

5. scripts/
   MOVE:
   - verify_api.sh -> scripts/verify_api.sh

6. CLEANUP:
   DELETE:
   - temp_notes.md (content moved)
   - session_summary.md (content moved)

ESTIMATED RESULT

CLAUDE.md: N lines -> M lines (reduced by X%)
```

## Step 5: Confirm Before Executing

```json
{
  "questions": [
    {
      "question": "I've analyzed the documentation and have a consolidation plan. How should I proceed?",
      "header": "Action",
      "multiSelect": false,
      "options": [
        {"label": "Execute all", "description": "Apply all consolidation changes"},
        {"label": "Step by step", "description": "Show me each change before applying"},
        {"label": "Just report", "description": "Don't make changes, just show the plan"},
        {"label": "Specific items", "description": "I'll tell you which items to consolidate"}
      ]
    }
  ]
}
```

## Step 6: Execute Consolidation

When approved:

1. **Create new files** (ADRs, session logs)
2. **Update existing files** (TODO.md, CHANGELOG.md)
3. **Clean CLAUDE.md** (remove migrated content)
4. **Move scripts** to proper location
5. **Delete temporary files**
6. **Create directory structure** if missing

```bash
# Create missing directories
mkdir -p docs/internal/sessions
mkdir -p docs/internal/architecture
mkdir -p ADR
mkdir -p scripts
```

## Step 7: Final Output

```
CONSOLIDATION COMPLETE

Changes Made:
  - Created: ADR/ADR-006-zero-copy-parsing.md
  - Created: docs/internal/sessions/session-042.md
  - Updated: TODO.md (+3 items)
  - Updated: CHANGELOG.md (+1 entry)
  - Updated: CLAUDE.md (reduced from 650 to 280 lines)
  - Moved: verify_api.sh -> scripts/
  - Deleted: temp_notes.md, session_summary.md

CLAUDE.md Size:
  Before: 650 lines
  After:  280 lines
  Status: Under 500 line limit

Files Ready for Commit:
  - ADR/ADR-006-zero-copy-parsing.md (new)
  - docs/internal/sessions/session-042.md (new)
  - TODO.md (modified)
  - CHANGELOG.md (modified)
  - CLAUDE.md (modified)
  - scripts/verify_api.sh (moved)

Suggested commit message:
  docs: Consolidate scattered documentation

  - Extracted TODOs from CLAUDE.md to TODO.md
  - Created ADR-006 for zero-copy parsing decision
  - Added session log for today's work
  - Moved verification scripts to scripts/
  - Cleaned up temporary markdown files
```

## Templates

### ADR Template
```markdown
# ADR-NNN: [Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** YYYY-MM-DD

## Context
What is the issue we're trying to solve?

## Decision
What did we decide to do?

## Consequences
### Positive
- Benefit 1

### Negative
- Tradeoff 1

## Alternatives Considered
1. Option A - Rejected because...
```

### Session Log Template
```markdown
# Session NNN: [Brief Title]

**Date:** YYYY-MM-DD
**Duration:** X hours
**Branch:** [branch name]

## Summary
One-paragraph summary.

## What We Did
- Action 1
- Action 2

## Key Learnings
- Insight 1

## Decisions Made
- Decision 1 (see ADR-XXX if major)

## Files Modified
- `path/to/file.rs` - Brief description

## Next Session
What to focus on next.
```

## Clean CLAUDE.md Structure

After consolidation, CLAUDE.md should contain only:

```markdown
# CLAUDE.md - Project Context

## Project Overview
[Current, factual information]

## Current Focus
- Active work area 1
- Active work area 2

## Architecture
See ARCHITECTURE.md for details.

## Development Workflow
[Build commands, testing approach]

## Related Documentation
- ADR/ - Architecture decisions
- docs/internal/sessions/ - Development sessions
- TODO.md - Planned work
- CHANGELOG.md - Version history
```

## Maintenance Tips

**To prevent future scatter:**

1. Create artifacts in correct location immediately
2. Run `/consolidate` weekly
3. Keep CLAUDE.md lean (only current context)

**Git hook (optional):**
```bash
# .git/hooks/pre-commit
if [ $(wc -l < CLAUDE.md) -gt 500 ]; then
  echo "Warning: CLAUDE.md exceeds 500 lines - consider running /consolidate"
fi
```

---

**Focus:** Keep documentation organized and CLAUDE.md under 500 lines.
