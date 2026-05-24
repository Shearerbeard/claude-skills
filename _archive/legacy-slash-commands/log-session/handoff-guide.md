# Handoff Documentation Guide

When a session ends due to context limits or mid-work interruption, create handoff documentation to enable the next session to pick up cold.

## Prerequisites

**CLAUDE.md must have a "Starting a Session" section** that tells Claude to check for WIP at session start. If missing, add:

```markdown
## Starting a Session

At the beginning of each Claude Code session:

1. **Check for work in progress:** Read `docs/TODO.md` - look for "WORK IN PROGRESS" section at top
2. **If WIP exists:** Read the referenced session log in `docs/internal/sessions/` for full context
3. **Check uncommitted changes:** Run `git status` and `git diff` to see current state
4. **Resume or start fresh:** Either continue from documented state or confirm starting new work
```

Without this, handoff docs exist but Claude won't know to look for them.

## When to Create Handoff Docs

- Context window approaching limit
- Need to stop mid-work
- Switching focus to different project
- Any incomplete work that needs continuation

## Components

### 1. Update TODO.md with Current State

Add to top of `docs/TODO.md`:

```markdown
## WORK IN PROGRESS (Session NNN - YYYY-MM-DD)

**Status:** [Describe current state in 1 sentence]

**What's Done:**
- [Completed item 1]
- [Completed item 2]

**What's In Progress:**
- [Current work item - describe exact state]
  - Files modified but uncommitted: [list]
  - Next step: [exact action needed]

**What's Blocked:**
- [Any blockers preventing progress]

**Continue by:**
1. [First step to resume work]
2. [Second step]

**Context:** See session-NNN.md for full details

---
```

### 2. Add Handoff Section to Session Log

Add this section to the session log:

```markdown
## HANDOFF TO NEXT SESSION

**Session Status:** INCOMPLETE - Ending due to [reason]

### Current State

**Work Completed:**
- [What's fully done]

**Work In Progress:**
- [What's partially done]
- Files modified but not committed:
  - `path/to/file.rs` - [state: added function X, not tested]
  - `path/to/test.rs` - [state: started writing test, incomplete]

**What Was I About To Do Next:**
[The EXACT next step you were going to take]
Example: "Was about to run `cargo test` to verify new function"

### How to Continue (Cold Start)

**Files to Review First:**
1. `path/to/file.rs` - See the new function added
2. `docs/TODO.md` - See the WIP section at top

**Commands to Run:**
```bash
# First, check current state
git status
git diff

# Then resume work
[exact command to continue]
```

**Context You Need:**
- [Important context from this session]
- [Decisions made that affect next steps]
- [Any gotchas or things to remember]

**Where We Left Off:**
[1-2 sentence summary of exact state]
Example: "Added parse_config() function to src/config.rs but haven't written tests yet. Need to add test in tests/config_tests.rs for happy path and error cases."
```

### 3. Document Uncommitted Changes

If files are modified but not committed:

```markdown
### Uncommitted Changes

**Modified Files:** [count] files with changes

```bash
# View changes
git status
git diff
```

**Changes Summary:**
- `file1.rs` - [What changed: added function X, refactored Y]
- `file2.rs` - [What changed: updated tests]

**Reason Not Committed:**
[Why these aren't committed yet]
Example: "Tests not passing yet" or "Need to verify logic first"

**Before Committing:**
- [ ] [Checklist item 1]
- [ ] [Checklist item 2]
```

### 4. Optional: Create Resume Script

For complex handoffs:

```bash
#!/bin/bash
# Resume Session NNN work
# Created: YYYY-MM-DD
# Context: [Brief description]

echo "Resuming Session NNN work..."
echo ""
echo "Current state:"
git status
echo ""
echo "Next steps:"
echo "1. Review src/config.rs changes"
echo "2. Run: cargo test tests::config_tests"
echo "3. If tests pass, commit with: git commit -m 'Add config parsing'"
echo ""
echo "Full context: docs/internal/sessions/session-NNN.md"
```

Save as `scripts/resume-session-NNN.sh`

## Handoff Output Format

When session ends with handoff:

```
SESSION LOG CREATED + HANDOFF DOCUMENTATION

Files Created:
- docs/internal/sessions/session-NNN.md (session log)
- docs/TODO.md (updated with WIP section)
- scripts/resume-session-NNN.sh (optional resume script)

Session Summary:
Session: #NNN (INCOMPLETE)
Date: YYYY-MM-DD
Duration: ~2 hours
Focus: [Main focus area]
Status: Ending due to [reason]

What's Complete:
- [Completed item 1]
- [Completed item 2]

Work In Progress:
- [Current work item]
- Files modified but uncommitted: [count] files

TO RESUME WORK (Next Session):

1. Read: docs/TODO.md (WIP section at top)
2. Read: docs/internal/sessions/session-NNN.md (handoff section)
3. Run: git status && git diff (see uncommitted changes)
4. Continue: [exact next step]

Quick Resume:
$ scripts/resume-session-NNN.sh

Session documented with handoff. Next session can pick up cold with full context.
```
