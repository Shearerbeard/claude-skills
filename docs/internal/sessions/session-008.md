# Session 008: Workflow Skill Enforcement — Checklist, Routing, Report Format

**Date:** 2026-06-03
**Duration:** ~1 hour
**Focus:** Fix plan-discipline and gate-probes enforcement gaps discovered in real session (ses_1740f7ee0ffetigGZ4DCwgjD8I)
**Branch:** `main`

## Summary

Diagnosed and fixed two workflow skills that failed in a real opencode session with Qwen 3.6 Plus. The model loaded plan-discipline but skipped all its gates (no scope interview, no blast radius, no gate-probes invocation), and never loaded gate-probes despite the user asking for "proper gates and verifiable checks." Root cause: both skills were pure advisory prose with no checklists, no report formats, no enforcement mechanisms, and gate-probes was missing trigger phrases for plan/document review scenarios. Added pre-flight checklists, imperative intra-skill routing with "why" explanations, structured report formats, and plan-specific probes.

## Activities

### 1. Root cause analysis

Diagnosed why both skills failed in a real session:

- **plan-discipline loaded but wasn't followed** — 52 lines of advisory prose, zero enforcement. No checklist the model must complete, no structured output, no "stop and confirm" gate.
- **gate-probes never loaded** — user said "ensure proper gates and verifiable checks" but the skill description only listed "ready to commit", "review this diff", "plan with gates", "scope this change". The LLM didn't match the trigger.
- **No intra-skill "why" for gate-probes routing** — plan-discipline said "invoke gate-probes" but research from session-007 confirmed "Load X" is ignored; "Without X you will miss [specific failure modes]" works.
- **No plan-specific probes** — gate-probes was written for code diffs, not plan documents.

Parallel agent research confirmed findings across 4 dimensions: opencode skill loading mechanism, plan-discipline audit, gate-probes audit, and skill best practices from existing session logs.

### 2. plan-discipline fixes (52 → 82 lines)

- **Added pre-flight checklist** — 5 checkbox items the model must complete before any file edit: scope interview answered, verification method stated, blast radius identified, existing building blocks searched, gate-probes invoked.
- **Added gate-probes routing with "why"** — follows the proven pattern from rust-review/python-review: "Without it loaded, you will miss sprawl, god modules, and incoherent edits that look correct in isolation but break module flow."
- **Added report format** — structured template for presenting preflight findings (scope, verification, blast radius, gate probes status).
- **Consolidated "Verification first" and "Pre-scope blast radius" into the checklist** — more actionable than standalone prose paragraphs.

### 3. gate-probes fixes (38 → 66 lines)

- **Expanded triggers** — added "ensure proper gates", "verifiable checks", "ready for implementation" to cover phrases that caused the miss in the real session.
- **Added plan-specific probes** (4 new) — verifiable exit criteria, explicit step dependencies, rollback procedures, testable success criteria.
- **Added report format** — table with PASS/FAIL per probe, gate verdict, and blocking findings. Follows the pattern established by docs-bustest and python-review.
- **Updated header** — "Run at every commit boundary, review gate, or plan review."

### 4. Validation

`./bin/check-skills` passes. All 11 skills validated.

## Key Learnings

- **Pure-prose skills are advisory, not enforceable.** Skills that are only instructions in the system prompt get ignored under cognitive load. Skills with checklists to fill, templates to follow, and files to read are much harder to skip.
- **Trigger phrase gaps are the #1 cause of skill misses.** The model matches on concrete phrases users actually type. If the phrase isn't in the description, the skill won't load regardless of how good the body content is.
- **Plan/document gates are a distinct use case from code diff gates.** gate-probes needed probes for plan reviewability (exit criteria, dependencies, rollback) that don't apply to code diffs.
- **The "why" pattern for intra-skill routing is essential.** Confirmed again: "invoke X" is ignored. "Without X you will miss [concrete failure modes]" works because it names consequences the model can't satisfy from training alone.

## Decisions Made

1. **Add checklists and report formats to workflow skills** — not just prose instructions. The pre-flight checklist in plan-discipline and the table format in gate-probes give the model concrete structures to fill in, which is harder to skip than prose.
2. **Keep plan-discipline under observation** — the skill now has enforcement structures, but its real-world effectiveness needs verification in actual planning sessions. The model may still skip the checklist under load.
3. **Expand gate-probes to cover plan review** — this is a legitimate gate scenario that was previously missing. The skill now handles both code diffs and plan documents.

## TODOs Created

### High Priority
- [ ] **Monitor plan-discipline in real sessions** — verify the pre-flight checklist actually gets completed, not just acknowledged. The model may check all boxes without doing the work.
- [ ] **Test gate-probes with plan review prompts** — verify the new triggers ("ensure proper gates", "verifiable checks", "ready for implementation") actually cause the skill to load.

### Medium Priority
- [ ] **Add test matrix entries for plan review scenario** — the skill-test-matrix doesn't currently cover gate-probes on plan documents.
- [ ] **Consider whether plan-discipline should delegate to language-specific design skills** — e.g., "Does this need a type/data model sketch before coding?" with follow-through delegated to rust-quality for Rust projects.

### Low Priority
- [ ] **Explore adding a small enforcement script** — a bin script that validates the pre-flight checklist was completed could add a deterministic layer, but may be overkill for a skill that's already model-facing.

## Code Changes

### Files Modified

| File | Changes | Description |
|------|---------|-------------|
| `plugins/workflow/skills/plan-discipline/SKILL.md` | +30 lines | Added pre-flight checklist, gate-probes routing with why, report format |
| `plugins/workflow/skills/gate-probes/SKILL.md` | +28 lines | Expanded triggers, added plan-specific probes, added report format |

### Statistics
- **Commits**: 0 (pending user review)
- **Lines added**: +58
- **Lines removed**: -12
- **Net change**: +46
- **Files changed**: 2

## Quality Checks

- ✅ `./bin/check-skills` — all 11 skills validated

## Related Documentation

- **Previous sessions**:
  - [session-007](./session-007.md) — intra-skill routing fix, trigger optimization
  - [session-006](./session-006.md) — plan-discipline workflow enforcement design
  - [session-005](./session-005.md) — initial trigger rewrites, LLM-based loading discovery
- **Skill test matrix**: `docs/internal/testing/skill-test-matrix.md`

## Session Notes

- The original failure was in session ses_1740f7ee0ffetigGZ4DCwgjD8I with opencode + Qwen 3.6 Plus in ~/workspace/aura-session-docs.
- The user asked to "audit and enhance the plan to get it ready for implementation with proper gates and verifiable checks."
- The model loaded plan-discipline but edited the plan without doing scope interview, blast radius, or invoking gate-probes.
- The model never loaded gate-probes despite the explicit request for "proper gates."
- This is the second iteration on plan-discipline enforcement (session-006 did the first pass). The skill keeps accumulating enforcement structures because pure prose isn't enough.
