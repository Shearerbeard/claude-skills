---
name: log-session
description: Create structured log of current Claude Code session
---

# Session Logger

Create a structured log documenting the current Claude Code development session.

## Task

Generate a session log from the current Claude Code session based on interactive prompts. Documents what was accomplished in THIS context window.

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

### 2. Interactive Session Capture

Use `AskUserQuestion` tool to gather session details:

```markdown
# Question 1: Session Focus
question: "What was the main focus of this Claude session?"
header: "Session Focus"
options:
  - label: "Bug fix"
    description: "Fixed one or more bugs"
  - label: "New feature"
    description: "Implemented new functionality"
  - label: "Refactoring"
    description: "Code cleanup or restructuring"
  - label: "Documentation"
    description: "Updated docs, READMEs, or comments"
  - label: "Exploration"
    description: "Research, investigation, or learning"
  - label: "Multiple areas"
    description: "Worked on several different things"

# Question 2: Key Accomplishments
question: "What were the key accomplishments in this session?"
header: "Accomplishments"
multiSelect: true
options:
  - label: "Implemented feature"
    description: "Built new functionality"
  - label: "Fixed bugs"
    description: "Resolved existing issues"
  - label: "Improved performance"
    description: "Optimizations or speedups"
  - label: "Enhanced documentation"
    description: "Better docs or examples"
  - label: "Made architectural decisions"
    description: "Important design choices"
  - label: "Learned something new"
    description: "Gained new understanding"

# Question 3: Decisions Made
question: "Were any significant decisions made this session?"
header: "Decisions"
options:
  - label: "Yes, architectural"
    description: "Design or architecture choices"
  - label: "Yes, technical"
    description: "Tool/library/approach choices"
  - label: "Yes, process"
    description: "Workflow or methodology decisions"
  - label: "No major decisions"
    description: "Incremental work, no big choices"
```

After getting responses, ask follow-up questions to capture details:
- **Brief description** of what was done (1-2 sentences)
- **Key learnings** from this session (if any)
- **Next steps** for the next session

### 3. Capture Context from Conversation

From the Claude session conversation, extract:
- **Files modified** (from tool calls)
- **Commands run** (from Bash tool usage)
- **Problems encountered** (from error messages)
- **Solutions found** (from successful approaches)

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

### 6. Prompt for ADR Creation

If user indicated architectural decisions were made:

```
Would you like to create an ADR for this decision?
- Decision: [Decision name from session]
- This would be ADR-XXX: [Suggested title]

Create ADR now? (y/N)
```

If yes, use ADR template from `.claude/templates/adr-template.md`.

## Output Format

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
