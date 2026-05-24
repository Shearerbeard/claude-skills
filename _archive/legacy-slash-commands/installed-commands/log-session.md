---
name: log-session
description: Create structured log of current Claude Code session
---

# Session Logger

Create a structured log documenting the current Claude Code development session.

## Task

Generate a session log from the current Claude Code session based on interactive prompts. Documents what was accomplished in THIS context window.

## Standards Reference

**Source:** `.claude/guidelines/project-documentation-standards.md`

This skill enforces the session logging and ephemeral documentation lifecycle rules:
- Rule 3: Session logs must reference ephemeral docs
- Ephemeral doc lifecycle (CREATE → ITERATE → ARCHIVE/PROMOTE/KEEP)
- Session boundary handling (context limits, handoff documentation)

## Workflow Philosophy

**Session = One Claude Code Context Window**
- A session is one continuous conversation with Claude
- You may have multiple sessions per day
- Each session is numbered incrementally
- User controls git commits separately

**NOT git-based:**
- User manages commits themselves
- Session log documents conversation and decisions
- May span zero commits, one commit, or many commits
- Focus is on learnings and context, not git history

## Important: Claude's Role

**Claude analyzes the ENTIRE conversation first**, then proposes answers.

Claude should:
1. Review all tool calls (Read, Write, Edit, Bash, etc.) made in this session
2. Identify files created/modified and their purposes
3. Extract decisions from the conversation (architectural choices, tool selections)
4. Note learnings and challenges discussed
5. **Present findings with concrete evidence** (not vague summaries)
6. Ask user to confirm or override each finding

**Example of good analysis:**
✅ "I see you modified README.md to add streaming documentation (lines 211-214)"
✅ "We decided to use session-based numbering instead of date-based (discussed around the log-session redesign)"
✅ "You encountered Skills not being recognized - solved by manually executing skill instructions"

**Example of bad analysis:**
❌ "You worked on some documentation"
❌ "Some decisions were made"
❌ "Things went well"

Be specific. Use evidence. Let the user correct if you missed something.

## Steps

### 1. Determine Session Number

```bash
# Find the next session number
ls docs/internal/sessions/session-*.md 2>/dev/null | \
  sed 's/.*session-\([0-9]*\)\.md/\1/' | \
  sort -n | \
  tail -1
```

If no sessions exist, start with session-001.
If last session is session-042, next is session-043.

**Filename:** `docs/internal/sessions/session-NNN.md` (zero-padded 3 digits)

### 2. Analyze Session & Propose Answers

**First, Claude analyzes the conversation to extract:**

From tool calls and conversation history:
- Files that were created, modified, or read
- Commands that were run (Bash tool usage)
- Errors encountered and solutions found
- Decisions discussed and made
- New skills or techniques learned
- Problems solved
- Features implemented

**Then propose answers with evidence:**

Example analysis output:
```
📊 SESSION ANALYSIS

Based on this conversation, I observed:

Focus Area: Documentation
  Evidence:
  - Ran /consolidate skill
  - Ran /docs-check skill
  - Modified README.md to add streaming documentation
  - Modified docs/architecture-decisions.md to renumber ADRs
  - Enhanced /docs-check skill with automatic fixes

Accomplishments:
  ✓ Enhanced documentation (README streaming docs added)
  ✓ Made architectural decisions (skills library structure)
  ✓ Learned something new (Claude Code skills patterns)

Key Activities:
  - Installed Claude Code skills from central repository
  - Trimmed CLAUDE.md from 690 to 257 lines
  - Fixed documentation inconsistencies (P1/P2 issues)
  - Enhanced /docs-check skill with auto-fix capability
  - Created session log for 2025-11-05

Decisions Made:
  - Skills library location: ~/dev/claude-skills/
  - Use .claude/skills/ nomenclature (modern)
  - Enhanced /docs-check with automatic fixes

Files Modified (8 files):
  - .claude/skills/docs-check.md (+162 lines)
  - README.md (+7 lines)
  - docs/architecture-decisions.md (-22 lines)
  - CLAUDE.md (-433 lines)
  - TODO.md (converted to pointer)
  - ARCHITECTURE.md (converted to pointer)
  - Multiple files moved/archived

Key Learnings:
  - CLAUDE.md should stay <500 lines
  - Skills can both report AND fix issues
  - Central skills repo enables cross-project reuse
  - Session = one Claude Code context window

Challenges Encountered:
  - Skills not recognized by Claude Code initially
  - Duplicate TODO.md files (installer vs existing)
  - CLI tests hanging (Test 1.2)

Duration Estimate: ~4 hours (based on conversation length)
```

**Then use `AskUserQuestion` to confirm or override:**

```markdown
# Question 1: Confirm Session Focus
question: "I analyzed this session as focused on 'Documentation'. Is this correct?"
header: "Session Focus"
options:
  - label: "Yes, Documentation"
    description: "Confirmed - main focus was documentation"
  - label: "Actually, Multiple areas"
    description: "Override - worked on several things"
  - label: "Actually, [specify other]"
    description: "Override with different focus"

# Question 2: Confirm Accomplishments
question: "I identified these accomplishments:\n- Enhanced documentation\n- Made architectural decisions\n- Learned something new\n\nAre these correct?"
header: "Accomplishments"
options:
  - label: "Yes, all correct"
    description: "Confirmed - these are the accomplishments"
  - label: "Partially correct"
    description: "Some are right, but need to adjust"
  - label: "Let me specify"
    description: "I'll provide the accomplishments"

# Question 3: Confirm Decisions
question: "I found these decisions:\n- Skills library at ~/dev/claude-skills/\n- Use .claude/skills/ nomenclature\n- Enhanced /docs-check with auto-fixes\n\nDid I capture the important decisions?"
header: "Decisions"
options:
  - label: "Yes, captured correctly"
    description: "Confirmed - these are the key decisions"
  - label: "Missing some"
    description: "Add more decisions I didn't catch"
  - label: "Different decisions"
    description: "Override with correct decisions"

# Question 4: Key Learnings
question: "I identified these learnings:\n- CLAUDE.md should stay <500 lines\n- Skills can report AND fix issues\n- Central repo enables reuse\n\nAnything to add or change?"
header: "Learnings"
options:
  - label: "Looks good"
    description: "Confirmed - captured the learnings"
  - label: "Add more"
    description: "I have additional learnings"
  - label: "Override"
    description: "Different learnings to capture"
```

**If user selects override/modify options:**

⚠️ **CRITICAL UX REQUIREMENT**: Always re-display the original content being clarified so the user doesn't have to work from memory.

Example flow when user selects "Partially correct" for accomplishments:

```
You selected "Partially correct" for accomplishments.

Here's what I identified:
- Created central skills library
- Installed 8 skills
- Created installation script
- Enhanced docs-check with automatic fixes
- Redesigned log-session skill twice
- Added session boundary handling

What needs adjustment? What did I miss or get wrong?
```

Then wait for user's clarification before proceeding.

**Pattern for all clarification follow-ups:**
1. Acknowledge user's selection ("You selected X")
2. Re-display the original content verbatim
3. Ask specific follow-up question
4. Wait for answer before moving to next question

### 3. Capture Context from Conversation (Automatic)

**This happens automatically during step 2 analysis.**

From the Claude session conversation, extract:
- **Files modified** (from Write, Edit tool calls)
- **Files read** (from Read tool calls - for context)
- **Commands run** (from Bash tool usage)
- **Problems encountered** (from error messages in tool results)
- **Solutions found** (from successful approaches after errors)
- **Tools used** (Git operations, grep searches, file manipulations)
- **Skills executed** (if any Claude Code skills were run)

**Evidence-based extraction:**
- Parse tool call parameters and results
- Count file modifications (additions/deletions if available)
- Track command execution patterns
- Note any error → solution sequences
- Identify decision points in conversation

This provides concrete evidence for the session log instead of vague summaries.

### 4. Create Session Log

**Structure:**

```markdown
# Session NNN: [Brief Title from Focus]

**Date:** YYYY-MM-DD
**Duration:** [Estimate based on session, e.g., "~2 hours"]
**Branch:** [Current git branch]

## Focus

[User's main focus response]

## Summary

[1-2 sentence summary from user's description]

## What We Did

[Bulleted list of activities from the session, extracted from:]
- User responses to questions
- Files modified (from tool calls)
- Commands executed (from Bash tools)
- Features implemented
- Bugs fixed
- Documentation updated

Example:
- Implemented zero-copy parsing in src/parser.rs
- Fixed lifetime annotation issues with borrow checker
- Added 5 unit tests for new parser
- Updated README with performance numbers

## Key Learnings

[From user responses or conversation:]
- [Learning 1]
- [Learning 2]
- [Learning 3]

If none: "No major learnings documented this session."

## Decisions Made

[If user indicated decisions were made:]

### [Decision Name]
**Context:** [Why this decision was needed]
**Decision:** [What was decided]
**Rationale:** [Why this choice]
**Alternatives:** [What else was considered]

If no decisions: "No architectural or technical decisions made this session."

## Files Modified

[Extract from tool calls in this session:]
- `path/to/file.rs` - [Brief description of changes]
- `path/to/test.rs` - [Brief description]

If none: "No files modified this session (exploration/research only)."

## Challenges

[If any significant problems were encountered:]

### [Challenge Name]
**Problem:** [What went wrong]
**Impact:** [How it affected progress]
**Solution:** [How it was resolved]
**Time spent:** [Estimate if significant]

If none: "No major challenges encountered."

## Next Session

**Immediate priorities:**
- [Next steps from user response]
- [Unfinished work from this session]

**Future work:**
- [Longer-term items identified]

## Related

- Session: session-NNN.md
- Branch: [branch name]
- Previous: session-[NNN-1].md (if exists)
- Next: session-[NNN+1].md (when created)

---

**Session Notes:**
[Any additional observations for future reference]
[Can be left blank if nothing to add]
```

### 5. Update Session Index (Optional)

If `docs/internal/sessions/README.md` exists, add entry:

```markdown
## Sessions

- [Session NNN](session-NNN.md) - YYYY-MM-DD - [Brief title]
- [Session 042](session-042.md) - 2025-11-04 - Parser optimization
- [Session 041](session-041.md) - 2025-11-03 - MCP integration
```

If doesn't exist, offer to create it.

### 6. Session Ending & Handoff Documentation

**Detect why the session is ending:**

Use `AskUserQuestion` to determine session ending reason:

```markdown
# Question: Session Ending Reason
question: "How are you ending this session?"
header: "Session End"
options:
  - label: "Work Complete"
    description: "Finished what I set out to do"
  - label: "Context Limit Approaching"
    description: "Running low on context window"
  - label: "Need to Stop Mid-Work"
    description: "Interrupting before completion"
  - label: "Switching Focus"
    description: "Moving to different task/project"
```

**If "Context Limit Approaching" or "Need to Stop Mid-Work":**

Create handoff documentation to enable next session to pick up cold.

#### A. Update TODO.md with Current State

Add to top of `docs/TODO.md`:

```markdown
## ⏸️ WORK IN PROGRESS (Session NNN - YYYY-MM-DD)

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

#### B. Document Ephemeral State in Session Log

Add section to session log:

```markdown
## 🔄 HANDOFF TO NEXT SESSION

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

#### C. Preserve Uncommitted Changes Context

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

#### D. Create "Resume Work" Script (Optional)

For complex handoffs, offer to create resume script:

```bash
#!/bin/bash
# Resume Session NNN work
# Created: YYYY-MM-DD
# Context: [Brief description]

echo "🔄 Resuming Session NNN work..."
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

### 7. Prompt for ADR Creation

If user indicated architectural decisions were made:

```
Would you like to create an ADR for this decision?
- Decision: [Decision name from session]
- This would be ADR-XXX: [Suggested title]

Create ADR now? (y/N)
```

If yes, use ADR template from `.claude/templates/adr-template.md`.

## Output Format

### Standard Output (Work Complete)

```
📝 SESSION LOG CREATED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 File: docs/internal/sessions/session-NNN.md

📊 Session Summary:
   Session: #NNN
   Date: YYYY-MM-DD
   Duration: ~2 hours
   Focus: [Main focus area]

🎯 Accomplishments:
   - [Item 1]
   - [Item 2]
   - [Item 3]

💡 Key Learnings:
   - [Learning 1]
   - [Learning 2]

🚨 Decisions Made:
   - [Decision 1]
   - [Decision 2] → Consider creating ADR

📝 Files Modified: N files

🔗 Related:
   - Previous: session-[NNN-1].md
   - Branch: [branch name]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
1. Review session log if needed
2. Create ADR for architectural decision? (optional)
3. Continue work or end session

Session log saved ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Handoff Output (Context Limit / Mid-Work)

```
📝 SESSION LOG CREATED + HANDOFF DOCUMENTATION

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Files Created:
   - docs/internal/sessions/session-NNN.md (session log)
   - docs/TODO.md (updated with WIP section)
   - scripts/resume-session-NNN.sh (optional resume script)

📊 Session Summary:
   Session: #NNN (INCOMPLETE)
   Date: YYYY-MM-DD
   Duration: ~2 hours
   Focus: [Main focus area]
   Status: Ending due to [reason]

🎯 What's Complete:
   - [Completed item 1]
   - [Completed item 2]

⏸️  Work In Progress:
   - [Current work item]
   - Files modified but uncommitted: [count] files

🔄 Handoff Documentation:
   ✓ TODO.md updated with current state
   ✓ Session log includes handoff section
   ✓ Uncommitted changes documented
   ✓ Resume instructions provided

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 TO RESUME WORK (Next Session):

1. Read: docs/TODO.md (WIP section at top)
2. Read: docs/internal/sessions/session-NNN.md (handoff section)
3. Run: git status && git diff (see uncommitted changes)
4. Continue: [exact next step]

💡 Quick Resume:
   $ scripts/resume-session-NNN.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session documented with handoff ✓

Next session can pick up cold with full context.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Best Practices

### When to Create Session Logs

**DO create for:**
- Any Claude session where meaningful work was done
- Sessions with important decisions or learnings
- After implementing a feature or fixing a bug
- After research/exploration sessions with findings

**DON'T create for:**
- Very short sessions (<15 min) with no meaningful progress
- Sessions that only read code with no outputs
- Sessions immediately before creating a full session log

### Typical Session Patterns

**Quick Bug Fix Session:**
- Focus: Bug fix
- Duration: 30-60 minutes
- Accomplishments: Fixed bug, added test
- Decisions: Usually none
- Files: 1-3 files modified

**Feature Implementation Session:**
- Focus: New feature
- Duration: 2-4 hours
- Accomplishments: Implemented feature, tests, docs
- Decisions: Design choices, API decisions
- Files: 5-15 files modified

**Exploration/Research Session:**
- Focus: Exploration
- Duration: 1-2 hours
- Accomplishments: Understanding gained, options identified
- Decisions: Approach selected for future work
- Files: 0 files (or just notes)

**Refactoring Session:**
- Focus: Refactoring
- Duration: 1-3 hours
- Accomplishments: Code cleaned up, better structure
- Decisions: Refactoring approach, patterns used
- Files: Many files with structural changes

### Session Numbering Strategy

Start with session-001 and increment forever. Don't reset per month/year.

**Why continuous numbering:**
- Easy to reference: "See session-042"
- Clear chronological order
- No ambiguity with dates (multiple sessions per day)
- Simpler to script/automate

**Directory structure:**
```
docs/internal/sessions/
  ├── README.md          # Optional index
  ├── session-001.md
  ├── session-002.md
  ├── ...
  ├── session-042.md
  └── session-043.md
```

**When you hit 1000 sessions:**
- Switch to 4 digits: session-1000.md
- Keep 3-digit zero-padding for <1000

### Integration with Git

Session logs are **independent** of git commits:

**Session with no commits:**
```markdown
# Session 042: API Design Exploration

Research session exploring authentication approaches.
No code written, but decisions made about API design.
```

**Session with many commits:**
```markdown
# Session 043: Feature Implementation

Implemented user authentication feature across 8 commits.
Files Modified: 15 files
(Session may reference commit range, but doesn't depend on it)
```

**Multiple sessions per commit:**
```markdown
# Session 044: Started auth implementation (not committed)
# Session 045: Finished auth implementation (committed in this session)
```

User controls when to commit. Session logs document the thought process and decisions, not the git history.

## Example Session Logs

### Example 1: Quick Bug Fix

```markdown
# Session 027: Fix Parser Memory Leak

**Date:** 2025-11-05
**Duration:** ~45 minutes
**Branch:** main

## Focus

Bug fix

## Summary

Fixed memory leak in parser that was causing crashes on large files. Added test to prevent regression.

## What We Did

- Identified memory leak in src/parser.rs line 156
- Fixed by properly dropping temporary buffers
- Added regression test in tests/parser_tests.rs
- Verified fix with valgrind

## Key Learnings

- String::from_utf8_lossy() creates temporary allocations that must be managed
- Valgrind is essential for catching these issues
- Always add regression tests for memory bugs

## Decisions Made

No architectural decisions this session.

## Files Modified

- `src/parser.rs` - Fixed memory leak in buffer handling
- `tests/parser_tests.rs` - Added regression test

## Challenges

### Challenge: Reproducing the leak
**Problem:** Leak only occurred on files >100MB
**Solution:** Created synthetic large test file
**Time spent:** 20 minutes

## Next Session

- Monitor production for any related issues
- Consider adding property-based tests for parser

## Related

- Session: session-027.md
- Branch: main
- Previous: session-026.md
```

### Example 2: Feature Implementation

```markdown
# Session 035: OAuth Integration

**Date:** 2025-11-05
**Duration:** ~3 hours
**Branch:** feature/oauth

## Focus

New feature

## Summary

Implemented OAuth 2.0 authentication flow with support for Google and GitHub providers. Includes token refresh and user profile fetching.

## What We Did

- Implemented OAuth client in src/auth/oauth.rs
- Added provider configurations for Google/GitHub
- Created token refresh logic with automatic renewal
- Built user profile fetching and caching
- Added integration tests for auth flow
- Updated README with OAuth setup instructions

## Key Learnings

- OAuth token refresh should happen 5 minutes before expiry
- Provider redirect URLs must be exact matches (no trailing slashes)
- User profile schemas differ significantly between providers - need abstraction layer

## Decisions Made

### Decision: Use `oauth2` crate instead of manual implementation
**Context:** Needed OAuth 2.0 support for multiple providers
**Decision:** Use oauth2 crate v4.4.0 for token management
**Rationale:**
- Well-maintained, secure implementation
- Handles token refresh automatically
- Supports multiple providers out of box
**Alternatives:**
- Manual implementation (rejected - security risk)
- reqwest-oauth (rejected - less mature)

### Decision: Abstract provider profiles into common User struct
**Context:** Each OAuth provider returns different profile schema
**Decision:** Created User struct with common fields, provider-specific in metadata
**Rationale:**
- Consistent internal API regardless of provider
- Easy to add new providers
- Keeps provider quirks isolated

## Files Modified

- `src/auth/oauth.rs` - New OAuth client implementation
- `src/auth/providers/` - Google and GitHub provider configs
- `src/auth/user.rs` - User profile abstraction
- `tests/integration/oauth_tests.rs` - Integration tests
- `README.md` - OAuth setup documentation
- `Cargo.toml` - Added oauth2 dependency

## Challenges

### Challenge: Testing OAuth flow without real providers
**Problem:** Integration tests needed real OAuth without actual provider API calls
**Solution:** Created mock OAuth server using wiremock
**Time spent:** 60 minutes

## Next Session

**Immediate:**
- Add support for Microsoft OAuth provider
- Implement session persistence
- Add token encryption at rest

**Future:**
- Consider adding OIDC support
- Profile photo caching
- Multi-provider account linking

## Related

- Session: session-035.md
- Branch: feature/oauth
- Previous: session-034.md
- Consider creating: ADR-018: OAuth Provider Selection

---

**Session Notes:**

OAuth integration went smoothly thanks to good crate support. The profile abstraction decision will make adding new providers much easier. Need to remember to encrypt tokens before production deployment.
```

## Tips

1. **Create immediately after session** - While details are fresh in memory
2. **Be honest about challenges** - Future you will appreciate the context
3. **Document WHY not just WHAT** - Decisions and rationale are most valuable
4. **Link related sessions** - Creates narrative thread across sessions
5. **Use consistent formatting** - Makes sessions easier to grep/search
6. **Include code snippets** - For important changes or learnings
7. **Note time spent on challenges** - Helps with future estimation

## Troubleshooting

**Q: What if I forget to create a session log?**
A: Create it later with "Session NNN (retroactive)" - capture what you remember

**Q: Can I combine multiple short sessions into one log?**
A: Yes, if they're part of the same work thread. Use "Sessions NNN-MMM"

**Q: How detailed should "What We Did" be?**
A: Enough for someone (or future you) to understand what happened. Usually 5-10 bullets.

**Q: Should I document failed experiments?**
A: Absolutely! Document what didn't work and why. Very valuable for future sessions.

**Q: What if a session spans multiple days?**
A: Use the date you started. Note in Summary: "Session continued across 2025-11-05 to 2025-11-06"
