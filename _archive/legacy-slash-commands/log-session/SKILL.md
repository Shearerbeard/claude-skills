---
name: log-session
description: Create structured session logs documenting work done in a Claude Code conversation. Use at end of development sessions, when context is approaching limits, when switching focus areas, or when the user says "log session", "create session log", or "document this session". Captures decisions, learnings, files modified, and handoff documentation.
---

# Session Logger

Create a structured log documenting the current Claude Code development session.

## When to Use

- End of a productive development session
- Before context window limit is reached
- When switching to a different task or project
- After completing a feature or significant work
- User explicitly requests session documentation

## Core Principle

**Analyze the ENTIRE conversation first, then propose findings with evidence.**

Review all tool calls made in this session:
- Files created/modified (Write, Edit tools)
- Files read (Read tool)
- Commands run (Bash tool)
- Errors encountered and solutions found
- Decisions discussed and made

Present findings with concrete evidence, not vague summaries.

**Good:** "Modified README.md to add streaming documentation (lines 211-214)"
**Bad:** "You worked on some documentation"

## Workflow

### Step 1: Determine Session Number

```bash
ls docs/internal/sessions/session-*.md 2>/dev/null | \
  sed 's/.*session-\([0-9]*\)\.md/\1/' | \
  sort -n | tail -1
```

If no sessions exist, start with session-001. Filename: `docs/internal/sessions/session-NNN.md`

### Step 2: Analyze Session and Confirm with User

First, analyze the conversation and extract:
- Focus area (what type of work)
- Key activities performed
- Decisions made
- Files modified
- Learnings and challenges

Then use AskUserQuestion to confirm findings. Example:

```json
{
  "questions": [
    {
      "question": "I analyzed this session as focused on 'Documentation and refactoring'. Is this correct?",
      "header": "Focus",
      "multiSelect": false,
      "options": [
        {"label": "Yes, correct", "description": "Confirmed focus area"},
        {"label": "Different focus", "description": "I'll specify the actual focus"}
      ]
    },
    {
      "question": "I identified these key accomplishments:\n- Refactored streaming handlers\n- Updated configuration\n- Fixed 3 bugs\n\nAre these correct?",
      "header": "Done",
      "multiSelect": false,
      "options": [
        {"label": "Yes, all correct", "description": "These are the accomplishments"},
        {"label": "Partially correct", "description": "Some adjustments needed"},
        {"label": "Let me specify", "description": "I'll provide the list"}
      ]
    }
  ]
}
```

**Critical UX pattern:** If user selects override/modify, re-display the original content so they don't work from memory, then ask what needs adjustment.

### Step 3: Determine Session End Type

```json
{
  "questions": [
    {
      "question": "How are you ending this session?",
      "header": "Session End",
      "multiSelect": false,
      "options": [
        {"label": "Work Complete", "description": "Finished what I set out to do"},
        {"label": "Context Limit", "description": "Running low on context window"},
        {"label": "Stopping Mid-Work", "description": "Interrupting before completion"},
        {"label": "Switching Focus", "description": "Moving to different task"}
      ]
    }
  ]
}
```

If "Context Limit" or "Stopping Mid-Work", create handoff documentation. See [handoff-guide.md](handoff-guide.md).

### Step 4: Create Session Log

Use the template in [session-template.md](session-template.md).

Key sections:
- **Focus**: Main area of work
- **Summary**: 1-2 sentence overview
- **What We Did**: Bulleted list from analysis
- **Key Learnings**: Insights gained
- **Decisions Made**: With context and rationale
- **Files Modified**: From tool call analysis
- **Challenges**: Problems and solutions
- **Next Session**: Immediate priorities and future work

### Step 5: Update Session Index (Optional)

If `docs/internal/sessions/README.md` exists, add entry:
```markdown
- [Session NNN](session-NNN.md) - YYYY-MM-DD - Brief title
```

## Output

After creating the session log, display:

```
SESSION LOG CREATED

File: docs/internal/sessions/session-NNN.md

Session: #NNN
Date: YYYY-MM-DD
Duration: ~X hours
Focus: [Focus area]

Accomplishments:
- [Item 1]
- [Item 2]

Key Learnings:
- [Learning 1]

Files Modified: N files

Session log saved.
```

For incomplete sessions (handoff), also show:
- Work in progress items
- Resume instructions
- Files with uncommitted changes

## Best Practices

**Do create session logs for:**
- Sessions with meaningful work done
- Important decisions or learnings
- After implementing features or fixing bugs
- Research sessions with findings

**Don't create for:**
- Very short sessions (<15 min) with no progress
- Sessions that only read code with no outputs

## References

- [session-template.md](session-template.md) - Full session log template
- [handoff-guide.md](handoff-guide.md) - Handoff documentation for incomplete sessions
- [examples.md](examples.md) - Example session logs
