---
name: plan-session
description: Start session with planning or research document
---

# Session Planning/Research Helper

Create structured planning or research document for current session.

## Task

Generate a planning or research document at the start of a session to organize complex work or investigation.

## When to Use

**Use planning docs when:**
- Implementing a new feature
- Major refactoring
- Breaking down complex work
- Need to make architectural decisions

**Use research docs when:**
- Investigating libraries or approaches
- Performance analysis
- Security research
- Technical spikes
- Exploring design alternatives

**Don't use for:**
- Simple bug fixes
- Small changes
- Straightforward tasks

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

### 2. Ask User: Planning or Research?

Use AskUserQuestion tool.

If user selects "Neither", exit immediately. No document needed.

### 3. Get Topic/Goal

Ask user for brief description of main goal or topic.

Example answers:
- "OAuth 2.0 implementation"
- "Zero-copy parser optimization"
- "Vector database migration"

### 4. Create Document

Use appropriate template based on type (planning or research).

See full skill documentation for complete templates and lifecycle rules.

---

**See Also:**
- /log-session - Documents ephemeral doc status at end of session
- .claude/guidelines/project-documentation-standards.md - Complete lifecycle rules
