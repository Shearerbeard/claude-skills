---
name: plan-session
description: Start a session with a planning or research document. Use at the start of complex work, new features, or investigations. Creates structured docs in docs/internal/planning/ or docs/internal/research/.
---

# Session Planning/Research Helper

Create a structured planning or research document at the start of a session.

## When to Use

**Use planning docs for:**
- Implementing a new feature
- Major refactoring
- Breaking down complex work
- Architectural decisions

**Use research docs for:**
- Investigating libraries or approaches
- Performance analysis
- Security research
- Technical spikes

**Don't use for:**
- Simple bug fixes
- Small changes
- Straightforward tasks

## Step 1: Ask Document Type

```json
{
  "questions": [
    {
      "question": "What type of session document do you need?",
      "header": "Doc Type",
      "multiSelect": false,
      "options": [
        {"label": "Planning", "description": "Breaking down implementation work"},
        {"label": "Research", "description": "Investigating options or approaches"},
        {"label": "Neither", "description": "Skip - no document needed"}
      ]
    }
  ]
}
```

If "Neither", exit immediately.

## Step 2: Get Topic

```json
{
  "questions": [
    {
      "question": "What's the main topic or goal? (e.g., 'OAuth implementation', 'Zero-copy parsing')",
      "header": "Topic",
      "multiSelect": false,
      "options": [
        {"label": "I'll type it", "description": "Enter custom topic"}
      ]
    }
  ]
}
```

## Step 3: Determine Session Number

```bash
ls docs/internal/sessions/session-*.md 2>/dev/null | \
  sed 's/.*session-\([0-9]*\)\.md/\1/' | \
  sort -n | tail -1
```

If no sessions exist, start with 001.

## Step 4: Create Document

### Planning Document

Location: `docs/internal/planning/session-NNN-[topic]-plan.md`

```markdown
# [Topic] Planning - Session NNN

**Created:** YYYY-MM-DD
**Status:** PLANNING

## Goal

[One sentence describing what we want to accomplish]

## Approach

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]
- [ ] Task 3
- [ ] Task 4

## Decisions Needed

- [ ] Decision 1?
- [ ] Decision 2?

## References

- [Related docs, ADRs, links]

---

**Status at end of session:** [PROMOTED/ARCHIVED/KEPT]
```

### Research Document

Location: `docs/internal/research/session-NNN-[topic]-research.md`

```markdown
# [Topic] Research - Session NNN

**Created:** YYYY-MM-DD
**Status:** RESEARCH

## Question

[What are we trying to learn or decide?]

## Findings

### Option 1: [Name]
**Pros:**
**Cons:**
**Effort:**

### Option 2: [Name]
**Pros:**
**Cons:**
**Effort:**

## Recommendation

[Which option and why]

## References

- [Links, docs, benchmarks]

---

**Status at end of session:** [PROMOTED/ARCHIVED/KEPT]
```

## Step 5: Output

```
SESSION DOCUMENT CREATED

File: docs/internal/[planning|research]/session-NNN-[topic]-[type].md
Type: [Planning | Research]
Session: NNN

Document ready. Update as you work through the session.

Remember at end of session:
- PROMOTE to permanent doc if valuable
- ARCHIVE to docs/archive/YYYY/ if complete
- KEEP if work continues next session

Use /log-session to document the outcome.
```

## Lifecycle

See `.claude/guidelines/project-documentation-standards.md` for full lifecycle rules.

At end of session, document status:
- **PROMOTE**: Became permanent reference (ADR, design doc)
- **ARCHIVE**: Complete, move to `docs/archive/YYYY/`
- **KEEP**: Work in progress, continue next session

---

**Related:** `/log-session` documents ephemeral doc status at session end.
