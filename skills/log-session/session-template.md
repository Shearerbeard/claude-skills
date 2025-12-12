# Session Log Template

Use this template when creating session logs.

```markdown
# Session NNN: [Brief Title from Focus]

**Date:** YYYY-MM-DD
**Duration:** [Estimate, e.g., "~2 hours"]
**Branch:** [Current git branch]

## Focus

[User's main focus - one line]

## Summary

[1-2 sentence summary of what was accomplished]

## What We Did

[Bulleted list of activities, extracted from:]
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

[From conversation and user responses:]
- [Learning 1]
- [Learning 2]
- [Learning 3]

If none: "No major learnings documented this session."

## Decisions Made

[If architectural or technical decisions were made:]

### [Decision Name]
**Context:** [Why this decision was needed]
**Decision:** [What was decided]
**Rationale:** [Why this choice]
**Alternatives:** [What else was considered]

If no decisions: "No architectural or technical decisions made this session."

## Files Modified

[Extract from tool calls in this session:]
- `path/to/file.rs` - Brief description of changes
- `path/to/test.rs` - Brief description

If none: "No files modified this session (exploration/research only)."

## Challenges

[If significant problems were encountered:]

### [Challenge Name]
**Problem:** [What went wrong]
**Impact:** [How it affected progress]
**Solution:** [How it was resolved]
**Time spent:** [Estimate if significant]

If none: "No major challenges encountered."

## Next Session

**Immediate priorities:**
- [Next steps]
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

## Session Numbering

- Start with session-001 and increment forever
- Zero-pad to 3 digits (session-001, session-042, session-123)
- When you hit 1000 sessions, switch to 4 digits
- Don't reset per month/year

## Directory Structure

```
docs/internal/sessions/
├── README.md          # Optional index
├── session-001.md
├── session-002.md
├── ...
└── session-NNN.md
```

## Session Index Entry

When adding to `docs/internal/sessions/README.md`:

```markdown
## Sessions

- [Session NNN](session-NNN.md) - YYYY-MM-DD - Brief title
- [Session 042](session-042.md) - 2025-11-04 - Parser optimization
- [Session 041](session-041.md) - 2025-11-03 - MCP integration
```
