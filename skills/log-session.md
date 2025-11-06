---
name: log-session
description: Create structured log of current development session
---

# Session Logger

Create a structured log documenting the current development session.

## Task

Generate a session log from today's work based on git activity and current context.

## Steps

### 1. Gather Session Data

```bash
# Get today's git activity
git log --since="today" --oneline --all
git log --since="today" --stat

# Show what's changed but not committed
git status --short
git diff --stat

# Show last commit details
git log -1 --stat

# Check current branch
git branch --show-current
```

### 2. Infer Session Details

From the git data, infer:
- **Duration**: Time span from first to last commit today
- **Focus**: Main area of work (from commit messages and files)
- **Activities**: List what was done
- **Decisions**: Any architectural choices evident in commits

### 3. Create Session Log File

**Filename:** `docs/internal/sessions/$(date +%Y-%m-%d).md`

If file exists, append to it. If not, create new.

**Use this structure:**

```markdown
# Session: [Brief title from main activity]

**Date:** [Today's date YYYY-MM-DD]
**Duration:** [Estimate from git log times, e.g., "3 hours"]
**Focus:** [Main work area, e.g., "Parser optimization"]

## Summary

[One paragraph summarizing what was accomplished today. Extract from commit messages and file changes.]

## Activities

[List activities chronologically, extracted from commits:]
- Implemented zero-copy parsing in src/parser.rs
- Added benchmarks to verify performance
- Refactored tokenizer for better efficiency
- Updated documentation

## Key Learnings

[Extract insights from commit messages or ask user:]
- String allocations were causing 70% of CPU time
- Zero-copy approach using &str improved performance by 3x
- Need to document this pattern for future reference

## Decisions Made

[Look for architectural decisions in today's work:]
- Adopted zero-copy parsing strategy (suggest ADR if significant)
- Chose to use nom parser combinator library
- Decided to keep synchronous API for now

## TODOs Created

[Extract TODO comments added today or from commit messages:]
- [ ] Add property-based tests for parser
- [ ] Document zero-copy pattern in ARCHITECTURE.md
- [ ] Profile memory usage after changes

## Code Changes

### Files Modified
[From git diff --stat:]
- `src/parser.rs` - Complete rewrite for zero-copy approach (+450, -200)
- `src/tokenizer.rs` - Refactored to work with &str (-50, +30)
- `benches/parser_bench.rs` - Added benchmark suite (+120)
- `tests/parser_tests.rs` - Updated tests for new API (+80, -40)

### Statistics
- Lines added: +650
- Lines removed: -290
- Net change: +360
- Files changed: 8
- Commits: 5

## Performance Metrics

[If applicable - from benchmarks, profiling, etc.:]

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Parse time (10KB) | 2.5 ms | 0.8 ms | 3.1x faster |
| Memory allocations | 1,200 | 150 | 8x fewer |
| Binary size | 5.2 MB | 5.1 MB | -2% |

## Challenges & Solutions

[If any significant problems were encountered:]

### Challenge: Lifetime annotations complexity
**Problem:** Borrow checker errors with zero-copy approach
**Time spent:** 90 minutes
**Solution:** Used explicit lifetime annotations and restructured API
**Learning:** Need to design lifetimes upfront, not retrofit

## Testing

- **Tests run:** All passing (✓ 45 tests)
- **Coverage:** 87% (+5% from before)
- **New tests added:** 8
- **Benchmarks:** 5 new benchmarks

## Next Steps

**Immediate (next session):**
- Create ADR-006 for zero-copy parsing decision
- Add documentation to ARCHITECTURE.md
- Update README with new performance numbers

**This Week:**
- Add property-based tests
- Profile memory usage
- Consider async version of parser

**Future:**
- Parallel parsing for large files
- Streaming parser API

## Related

- Commits: $(git log --since="today" --oneline | cut -d' ' -f1 | tr '\n' ' ')
- Branch: $(git branch --show-current)
- [Link to ADR-006] (if created)
- GitHub issue: #[N] (if applicable)

---

**Session Notes:**
[Any additional observations or notes for future reference]
```

### 4. Update CLAUDE.md

Add session reference to CLAUDE.md:

Find the "## Recent Sessions" section and add:
```markdown
- **[DATE]**: [Brief summary] (docs/internal/sessions/[DATE].md)
```

If section doesn't exist, create it before the end of CLAUDE.md.

### 5. Check for ADR Creation Need

If the session involved significant architectural decisions:
- Prompt user: "Should we create an ADR for [decision]?"
- If yes, create ADR/ADR-NNN-title.md using ADR template

### 6. Update TODO.md

If TODOs were created during the session:
- Add them to TODO.md under appropriate priority
- Link from session log to TODO.md entries

### 7. Output Format

```
📝 SESSION LOG CREATED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 File: docs/internal/sessions/2025-11-04.md

📊 Session Summary:
   Duration: 3 hours 15 minutes
   Focus: Parser optimization
   Commits: 5
   Files changed: 8
   Lines: +650, -290

🎯 Key Achievements:
   - Implemented zero-copy parsing
   - Performance improved 3.1x
   - Added comprehensive benchmarks

💡 Key Learnings:
   - String allocations were the bottleneck
   - Zero-copy approach requires careful lifetime design

🚨 Decisions Made:
   - Adopted zero-copy parsing (suggest creating ADR-006)
   - Chose nom parser combinators
   - Keeping sync API for now

✅ TODOs Created: 3
   - [ ] Property-based tests
   - [ ] Update ARCHITECTURE.md
   - [ ] Profile memory usage

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Next Actions:

1. Review session log: docs/internal/sessions/2025-11-04.md
2. Create ADR-006 for zero-copy decision? (Recommended)
3. Update TODO.md with new tasks? (Auto-added)
4. Update CLAUDE.md with session reference (Done)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like me to:
a) Create ADR-006 for the zero-copy parsing decision
b) Update README with new performance numbers
c) Both
d) Neither (you'll do it manually)

[Wait for response]
```

## Customization

### If No Git Activity Today

```
⚠️  No git activity found for today.

Would you like to:
1. Create session log manually (I'll ask you questions)
2. Skip session log for today
3. Review uncommitted changes instead

[Wait for response]
```

### If User Chooses Manual Entry

Ask these questions:
- What was the main focus of your session?
- What did you accomplish?
- Any key learnings or insights?
- Any decisions made?
- What should be worked on next?

Then create session log from responses.

### Integration with TODO.md

When extracting TODOs from session:
```markdown
## TODO.md Entry Format

### [Category based on session focus]
- [ ] [TODO item] - From session 2025-11-04 (docs/internal/sessions/2025-11-04.md#todos-created)
```

This links back to the session log for context.

## Tips for Better Session Logs

1. **Run at end of each session** - While work is fresh
2. **Be specific about learnings** - Future you will thank present you
3. **Note challenges honestly** - Helps others avoid same issues
4. **Link related docs** - ADRs, issues, PRs
5. **Include metrics when possible** - Concrete numbers are valuable
6. **Suggest ADRs for decisions** - Don't lose the "why"

## Error Handling

If session log file already exists:
- Show existing content
- Ask: "Append to existing session or create new entry?"
- If append, add divider and new section

If git returns no commits:
- Check for uncommitted changes
- Offer to document work-in-progress
- Or skip session log creation

If CLAUDE.md doesn't exist:
- Warn user
- Create it with template
- Add session reference
