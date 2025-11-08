# Session 004: Fix Slash Command Installation

**Date:** 2025-11-06
**Duration:** ~30 minutes
**Branch:** main

## Focus

Debugging and fixing slash command installation issue

## Summary

Diagnosed and fixed issue where slash commands weren't showing up in Claude Code sessions. Root cause was installing files to `.claude/skills/` instead of `.claude/commands/`. Updated installer script and documentation to use correct directory structure.

## What We Did

- Investigated why slash commands weren't appearing in new Claude sessions
- Examined `.claude/` directory structure and found files in wrong location
- Researched Claude Code documentation to understand Skills vs Slash Commands
- Modified `install-to-project.sh` to install to `.claude/commands/` (5 edits)
- Updated terminology in installer output messages and README generation
- Successfully tested fixed installer by reinstalling to this repository
- Updated `CLAUDE.md` to clarify slash commands vs Skills distinction (5 edits)
- Verified installation with 9 slash commands in `.claude/commands/`

## Key Learnings

- **Skills vs Slash Commands are fundamentally different:**
  - Skills: Located in `.claude/skills/name/SKILL.md`, model-invoked automatically
  - Slash Commands: Located in `.claude/commands/name.md`, user-invoked with `/name`

- **Directory structure matters** - Commands won't appear if installed to wrong location

- **Slash commands better for quality checks** because:
  - Users want explicit control over when to run quality checks
  - Don't want Claude randomly deciding to audit code mid-task
  - Simpler format (just markdown, no required frontmatter)

- **SlashCommand tool behavior** - Won't recognize commands until new session starts

## Decisions Made

### Decision: Use Slash Commands instead of Skills
**Context:** Library was structured to provide quality checks but wasn't clear on implementation
**Decision:** Implement as user-invoked slash commands, not model-invoked Skills
**Rationale:**
- Quality checks are explicit workflows users want to control
- Slash commands provide predictable, on-demand execution
- Simpler installation (single .md file vs directory structure)
- Better UX for "run standards check now" use case
**Alternatives:**
- Skills (rejected - too automatic for quality checks)
- Hybrid approach (rejected - adds complexity)

## Files Modified

- `install-to-project.sh` - Changed installation target from `.claude/skills/` to `.claude/commands/`
  - Updated directory creation (line 175)
  - Changed file copy destination (line 189)
  - Updated check for existing installation (line 130)
  - Modified output messages to say "slash commands" instead of "skills"
  - Updated generated README.md content

- `CLAUDE.md` - Updated documentation terminology
  - Added implementation note about slash commands vs Skills (line 6)
  - Updated project structure documentation (line 47)
  - Changed architecture flow diagram (line 267)
  - Updated available commands list (line 414)
  - Clarified key features section (line 89)

## Challenges

### Challenge: Understanding Skills vs Slash Commands distinction
**Problem:** Documentation conflated two different Claude Code features with same name
**Impact:** Installed to wrong directory, commands didn't work
**Solution:** Fetched official docs from code.claude.com to clarify difference
**Time spent:** ~10 minutes researching documentation

## Next Session

**Immediate priorities:**
- Test slash commands in a fresh Claude session (requires new session to load commands)
- Consider testing installation in another project to verify fix works elsewhere
- May need to update README.md and other documentation files

**Future work:**
- Document this Skills vs Slash Commands distinction in project docs
- Add troubleshooting section to README
- Consider creating a quick reference guide

## Related

- Session: session-004.md
- Branch: main
- Previous: session-003.md
- Next: session-005.md (when created)

---

**Session Notes:**

Quick but important fix. The library was working perfectly except for one critical detail - wrong directory. This session clarified the distinction between Skills (model-invoked) and Slash Commands (user-invoked), which will be important for future development and documentation.

The slash command format is actually simpler than Skills, which is a nice bonus. Just markdown files in `.claude/commands/` with optional frontmatter.

Commands now properly installed and ready to test in next session.
