---
name: consolidate
description: Consolidate scattered documentation and clean up temporary artifacts
---

# Documentation Consolidation & Cleanup

## Task
Find scattered documentation artifacts, consolidate them into proper locations, and clean up temporary files created during Claude Code sessions.

## Common Problems This Fixes

1. **CLAUDE.md bloat** - Session notes, TODOs, temp observations
2. **Scattered markdown files** - Summary files left in random places
3. **Temporary scripts** - Verification scripts never cleaned up
4. **Duplicate information** - Same TODO in multiple places
5. **Session logs** - Insights buried in chat history

## Steps

### 1. Scan for Documentation Artifacts

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

# Find shell scripts (potential verification scripts)
find . -type f -name "*.sh" \
  -not -path "./target/*" \
  -not -path "./.git/*" \
  -not -path "./scripts/*" \
  -mtime -7  # Modified in last 7 days

# Find temporary note files
find . -type f \( -name "notes.txt" -o -name "temp.md" -o -name "session*.md" \)
```

### 2. Read CLAUDE.md for Scattered Information

Look for sections that should be elsewhere:

```markdown
# Sections to Extract from CLAUDE.md

## TODOs → TODO.md
If CLAUDE.md has:
- [ ] Implement feature X
- [ ] Fix bug in Y
→ Move to TODO.md

## Architecture Decisions → ADR/
If CLAUDE.md has:
"We decided to use PostgreSQL because..."
→ Create ADR-XXX-database-choice.md

## Session Learnings → docs/internal/sessions/
If CLAUDE.md has:
"Today I learned that the parser has issues with..."
→ Create session log: docs/internal/sessions/YYYY-MM-DD.md

## Changelog Items → CHANGELOG.md
If CLAUDE.md has:
"Added support for async operations"
→ Move to CHANGELOG.md [Unreleased]

## Technical Debt → docs/internal/tech-debt.md
If CLAUDE.md has:
"Note: The auth module needs refactoring"
→ Move to tech-debt.md
```

### 3. Consolidation Rules

**Decision Matrix:**

```
┌─────────────────────────┬─────────────────────────┬─────────────────────┐
│ Content Type            │ Belongs In              │ Action              │
├─────────────────────────┼─────────────────────────┼─────────────────────┤
│ Public API examples     │ Code doc comments       │ Move to /// docs    │
│ Architecture overview   │ ARCHITECTURE.md         │ Consolidate there   │
│ TODO items              │ TODO.md                 │ Merge & deduplicate │
│ Completed work          │ CHANGELOG.md            │ Add to [Unreleased] │
│ Design decisions        │ ADR/ADR-NNN-title.md    │ Create formal ADR   │
│ Session insights        │ docs/internal/sessions/ │ Create session log  │
│ Temporary notes         │ Delete or move          │ Clean up            │
│ Project context         │ CLAUDE.md (clean)       │ Keep only essentials│
│ Technical debt          │ docs/internal/          │ Consolidate issues  │
│ Build/verification      │ scripts/ or delete      │ Move or remove      │
└─────────────────────────┴─────────────────────────┴─────────────────────┘
```

### 4. Execute Consolidation

For each piece of scattered documentation:

**A. Extract TODOs from CLAUDE.md:**
```markdown
# Current CLAUDE.md might have:
## What's Next
- [ ] Add user authentication
- [ ] Implement rate limiting
- [ ] Fix memory leak in parser

# Move to TODO.md:
## Unreleased / Planned

### High Priority
- [ ] Fix memory leak in parser (#issue-ref)

### Medium Priority  
- [ ] Add user authentication
- [ ] Implement rate limiting

### Low Priority
...
```

**B. Convert Insights to ADRs:**
```markdown
# If CLAUDE.md has:
"We chose Tokio over async-std because it has better 
ecosystem support and we need compatibility with..."

# Create: ADR/ADR-005-async-runtime-choice.md
# Status: Accepted
# Date: 2025-11-04

## Context
We needed to choose an async runtime...

## Decision
We will use Tokio...

## Consequences
Positive: Better ecosystem...
Negative: Larger binary size...
```

**C. Create Session Logs:**
```markdown
# If CLAUDE.md has session notes, create:
# docs/internal/sessions/2025-11-04-parser-optimization.md

## Session: Parser Optimization
**Date:** 2025-11-04
**Duration:** 3 hours
**Participants:** Claude Code session

### What We Did
- Profiled parser performance
- Identified bottleneck in tokenization
- Implemented zero-copy parsing

### Key Learnings
- String allocations were 70% of CPU time
- Using &str instead of String improved perf by 3x
- Need to document this pattern for future work

### Decisions Made
- Keep zero-copy approach (see ADR-006)
- Add benchmarks to CI

### TODO Items Created
- [ ] Add documentation for zero-copy pattern
- [ ] Create benchmark suite

### Files Modified
- src/parser.rs (complete rewrite)
- tests/parser_tests.rs (added benchmarks)

### Related
- ADR-006: Zero-copy parsing strategy
- GitHub PR #123
```

### 5. Clean Up Temporary Files

```bash
# Move keeper scripts to scripts/
mv verify_*.sh scripts/

# Remove temporary markdown files
rm -f temp.md notes.txt session_*.md summary_*.md

# Archive old session scripts
mkdir -p .archive/scripts
mv old_script_*.sh .archive/scripts/
```

### 6. Update CLAUDE.md to Clean Version

**Before (bloated):**
```markdown
# CLAUDE.md - Project Context

## Project Overview
...

## TODOs
- [ ] Fix auth bug
- [ ] Add tests
- [ ] Refactor parser

## Session Notes - Nov 3
Discovered that the parser has memory issues...

## Random Notes
The database connection pool might need tuning...

## What's Next
Need to implement async support...

## Temporary Observations
The API response time is slow...
```

**After (clean):**
```markdown
# CLAUDE.md - Project Context

## Project Overview
[Keep current, factual information]

## Current Focus Areas
- Optimizing parser performance
- Implementing authentication

## Architecture
See ARCHITECTURE.md for details.
Module structure: [Brief current state]

## Development Workflow
[Build commands, testing approach]

## Recent Changes
See CHANGELOG.md for complete history.
See docs/internal/sessions/ for session logs.

## Known Issues
See docs/internal/tech-debt.md
See TODO.md for planned work

## Related Documentation
- ADR/ - Architecture decisions
- docs/internal/sessions/ - Development sessions
- TODO.md - Planned work
- CHANGELOG.md - Version history
```

### 7. Create Missing Structure

If directories don't exist, create them:

```bash
mkdir -p docs/internal/sessions
mkdir -p docs/internal/architecture
mkdir -p ADR
mkdir -p scripts
```

### 8. Output Format

```
🗂️  DOCUMENTATION CONSOLIDATION

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 FOUND SCATTERED DOCUMENTATION

Temporary Files:
  - ./temp_notes.md (2KB, modified today)
  - ./session_summary.md (1KB, modified today)
  - ./verify_api.sh (500B, modified yesterday)

In CLAUDE.md:
  - 8 TODO items (should be in TODO.md)
  - 2 architectural decisions (should be ADRs)
  - 1 session log (should be in docs/internal/sessions/)
  - 1 changelog entry (should be in CHANGELOG.md)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 CONSOLIDATION PLAN

1. TODO.md
   ADD:
   - [ ] Fix memory leak in parser (from CLAUDE.md)
   - [ ] Add authentication (from CLAUDE.md)
   - [ ] Implement rate limiting (from CLAUDE.md)
   
   REMOVE FROM CLAUDE.md:
   Lines 45-52

2. ADR/ADR-006-zero-copy-parsing.md
   CREATE NEW:
   Extract decision from CLAUDE.md lines 60-75
   Status: Accepted
   Date: 2025-11-04

3. docs/internal/sessions/2025-11-04.md
   CREATE NEW:
   Extract session notes from CLAUDE.md lines 80-95
   
4. CHANGELOG.md [Unreleased]
   ADD:
   - Added zero-copy parsing (from CLAUDE.md line 100)
   
5. scripts/
   MOVE:
   - verify_api.sh → scripts/verify_api.sh

6. CLEANUP:
   DELETE:
   - temp_notes.md (content moved to session log)
   - session_summary.md (content moved to session log)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 ACTIONS REQUIRED

Automatic (I can do):
✓ Create session log: docs/internal/sessions/2025-11-04.md
✓ Create ADR: ADR/ADR-006-zero-copy-parsing.md
✓ Update TODO.md with consolidated items
✓ Update CHANGELOG.md with new entries
✓ Move scripts to scripts/ directory
✓ Delete temporary files
✓ Clean up CLAUDE.md

Manual (You should review):
⚠️  Verify consolidated TODOs are accurate
⚠️  Review ADR before committing
⚠️  Check CHANGELOG entry formatting

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like me to proceed with consolidation? (y/N)
```

### 9. Execute Consolidation

When approved:

1. **Create new files** (ADRs, session logs)
2. **Update existing files** (TODO.md, CHANGELOG.md)
3. **Clean CLAUDE.md** (remove migrated content)
4. **Move scripts** to proper location
5. **Delete temporary files**
6. **Create git commit** with consolidated changes

## Templates to Use

### ADR Template
```markdown
# ADR-NNN: [Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded by ADR-XXX]
**Date:** YYYY-MM-DD
**Deciders:** [List decision makers]

## Context
What is the issue we're trying to solve?

## Decision
What did we decide to do?

## Consequences
### Positive
- Benefit 1
- Benefit 2

### Negative
- Tradeoff 1
- Tradeoff 2

### Risks
- Risk 1
- Mitigation plan

## Alternatives Considered
1. Option A - Rejected because...
2. Option B - Rejected because...

## References
- Related ADRs
- External docs
- GitHub issues
```

### Session Log Template
```markdown
# Session: [Brief Title]

**Date:** YYYY-MM-DD
**Duration:** X hours
**Focus:** [Main goal of session]

## Summary
One-paragraph summary of what was accomplished.

## What We Did
- Action 1
- Action 2
- Action 3

## Key Learnings
- Insight 1
- Insight 2

## Decisions Made
- Decision 1 (see ADR-XXX if major)
- Decision 2

## TODO Items Created
- [ ] Task 1 (#issue)
- [ ] Task 2

## Files Modified
- `path/to/file.rs` - Brief description
- `path/to/test.rs` - Brief description

## Performance Metrics
- Before: X ms
- After: Y ms
- Improvement: Z%

## Next Steps
What to focus on next session.

## Related
- ADR-XXX
- GitHub PR #123
- Slack thread: [link]
```

### Tech Debt Template  
```markdown
# Technical Debt

Last updated: YYYY-MM-DD

## Critical (Fix ASAP)
### Item 1: [Brief description]
**Location:** src/module/file.rs
**Impact:** High - Causes production issues
**Effort:** 2 days
**Issue:** #123

## High Priority (Fix This Sprint)
### Item 2: [Brief description]
...

## Medium Priority (Fix This Quarter)
...

## Low Priority (Nice to Have)
...

## Resolved
- [x] ~~Old debt item~~ - Fixed in v0.3.0
```

## Final Verification

After consolidation:

```bash
# Verify structure
ls -la ADR/
ls -la docs/internal/sessions/
ls -la scripts/

# Check file sizes
wc -l CLAUDE.md  # Should be smaller
wc -l TODO.md    # Should have all TODOs
wc -l CHANGELOG.md

# Verify no temp files remain
find . -name "temp*.md" -o -name "session*.md" -o -name "notes.txt"

# Git status
git status
```

**Commit message:**
```
docs: Consolidate scattered documentation

- Extracted TODOs from CLAUDE.md to TODO.md
- Created ADR-006 for zero-copy parsing decision
- Added session log for 2025-11-04
- Moved verification scripts to scripts/
- Cleaned up temporary markdown files
- Updated CHANGELOG.md with recent work
```

## Maintenance Tips

**To prevent future scatter:**

1. **During sessions, create artifacts in correct location immediately:**
   - TODOs → Add to TODO.md directly
   - Decisions → Create ADR immediately
   - Observations → Add to session log as you go

2. **Use this command weekly:**
   ```bash
   claude
   /consolidate
   exit
   ```

3. **Keep CLAUDE.md lean:**
   - Only current context
   - Links to detailed docs
   - No historical info

4. **Set up git hooks:**
   ```bash
   # .git/hooks/pre-commit
   # Warn if CLAUDE.md > 500 lines
   if [ $(wc -l < CLAUDE.md) -gt 500 ]; then
     echo "⚠️  CLAUDE.md is large - time to consolidate?"
   fi
   ```
