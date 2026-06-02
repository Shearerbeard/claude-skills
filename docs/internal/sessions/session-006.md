# Session 006: Prose Lint Gates + Workflow Enforcement Triggering

**Date:** 2026-06-02
**Duration:** multi-hour working session
**Focus:** Add deterministic prose linting, testing gates, manual Claude/OpenCode evaluation workflow, and improve `plan-discipline` triggering language
**Branch:** `skill-routing-deps-plan-fixes`

## Summary

Built a more complete quality system around this skills repo. Added `prose-lint` as a separate Vale-backed skill, pinned `vale-ai-tells`, added deterministic gate scripts, and wrote a manual Claude Code/OpenCode test matrix. Reworked `plan-discipline` around enforcing the user's before-coding workflow instead of generic planning help. Temporary global Claude and OpenCode installs now point at this branch for real-world testing.

## Commits

- `7cc3ef4 feat: add prose lint gates and skill tests`
- `14c096c fix: add bundled vale fallback for prose lint`
- `fbfa2f7 fix: frame plan discipline as workflow enforcement`
- `921c113 fix: generalize plan discipline trigger order`

## Activities

1. **Skill routing audit and edits**
   - Fixed `docs-busttest` frontmatter name to `docs-bustest`.
   - Reframed skills as model-invoked, not magically auto-triggered.
   - Narrowed `humanizer` so it targets checked-in/outgoing prose and not ordinary assistant replies.
   - Flattened cross-skill routing to avoid loops.

2. **Vale/prose lint integration**
   - Added root `.vale.ini` pinned to `tbhb/vale-ai-tells` v1.13.1.
   - Added `prose-lint` skill under `plugins/docs/skills/prose-lint/`.
   - Added bundled fallback `.vale.ini` inside the skill so projects without their own Vale config still work.
   - Verified stdin modes for commit messages, raw snippets, and Markdown-like prose.

3. **Quality gate scripts**
   - Added `bin/check-skills` for skill frontmatter and plugin JSON checks.
   - Added `bin/check-install` for temp-home OpenCode/Codex install validation.
   - Added `bin/check-prose` for Vale sync, smoke tests, and changed-section prose lint.
   - Fixed staged-change coverage and dead missing-reference logic after review.

4. **Manual CC/OC evaluation workflow**
   - Added `docs/internal/testing/skill-test-matrix.md`.
   - Added `docs/internal/testing/results/template.md`.
   - Matrix scores behavior as `auto`, `nudge`, `manual`, or `miss`.
   - Explicitly documents that model-driven skill routing is measured behavior, not a deterministic contract.

5. **Smoke tests**
   - OpenCode/Kimi auto-loaded `prose-lint` and used the bundled fallback Vale config in a project without `.vale.ini`.
   - OpenCode/Kimi auto-loaded `gate-probes` and `rust-review` for Rust review prompts.
   - OpenCode/Kimi auto-loaded `plan-discipline` for both HITL-flavored and generic non-trivial implementation prompts after wording changes.
   - Claude Code saw `docs:prose-lint` with explicit `--plugin-dir`, but headless permission behavior made shell execution noisy. Interactive testing remains the better signal.

6. **Temporary installs for real-project testing**
   - Global Claude `my-skills` marketplace now points to this branch worktree.
   - OpenCode skills installed from this branch into `~/.config/opencode/skills`.
   - Backup of Claude settings exists at `~/.claude/backups/settings.json.before-skill-routing-deps-plan-fixes`.

## Key Learnings

- **`plan-discipline` should enforce workflow, not advertise planning help.** Claude and OpenCode already know how to plan. The skill needs to say what it enforces differently: scope interview, evidence check, verification framing, blast-radius scan, and review gates before the first code edit.
- **Ordering matters in descriptions.** The generic before-coding cases must come first: multi-file work, refactors, public API changes, dependency/module additions, and investigation turning into code. Recent HITL phrases such as "minimal V1" and "unblock a team" are useful secondary anchors, not the primary frame.
- **Changed-section prose lint is the normal gate.** Full-repo Vale is intentionally noisy on existing research/session docs. Changed-section and stdin modes are the practical path.
- **Projects without `.vale.ini` need a fallback.** The first OpenCode smoke failed until `prose-lint` shipped a bundled fallback config.
- **Official commit commands may bypass this.** Existing Claude marketplace `/commit` commands restrict tool usage and do not reliably run `prose-lint`. A custom commit workflow or hook remains separate future work.

## Decisions Made

1. **Keep `prose-lint` separate from `humanizer`**
   - Rationale: Vale is deterministic and reports issues; `humanizer` rewrites and handles voice.
   - Impact: `humanizer` consumes `prose-lint` findings when provided but does not invoke `prose-lint` recursively.

2. **Use `vale-ai-tells` v1.13.1**
   - Rationale: Best public Vale package found for AI-writing tells, with commit-message rules.
   - Impact: Root and bundled fallback configs both pin that release.

3. **Treat checked-in docs prose as public enough**
   - Rationale: `docs-bustest` evaluates docs as if a maintainer disappeared.
   - Impact: Changed checked-in docs prose should run `prose-lint`, then `humanizer`, while skipping code blocks, generated content, schemas, exact API signatures, config examples, and intentional bad-prose examples.

4. **Do not depend on auto skill invocation for hard guarantees**
   - Rationale: Skill loading is model judgment.
   - Impact: Manual matrix records `auto`, `nudge`, `manual`, and `miss` separately.

## Current Temporary State

- Claude global `my-skills` marketplace path:
  `/Users/mshearer/dev/claude-skills/.claude/worktrees/skill-routing-deps-plan-fixes`
- OpenCode installed skills path:
  `/Users/mshearer/.config/opencode/skills`
- Rollback Claude settings:
  `cp ~/.claude/backups/settings.json.before-skill-routing-deps-plan-fixes ~/.claude/settings.json`
- Reinstall OpenCode from main:
  `cd /Users/mshearer/dev/claude-skills && ./bin/install-skills opencode`

## TODOs

### High Priority

- [ ] Run the manual matrix in real projects, starting with `aura-orchestration-mode` and `agent-driver-rs`.
- [ ] Record results under `docs/internal/testing/results/`.
- [ ] Test whether Claude Code in an interactive fresh session now loads `workflow:plan-discipline` for non-trivial implementation prompts without manual invocation.
- [ ] Decide whether to merge this branch after manual testing or keep iterating on trigger text.

### Type-First Planning Follow-Up

- [ ] Test whether `plan-discipline` should recommend designing types first when the target language benefits from type modeling, especially Rust.
- [ ] Explore a small extension to `plan-discipline`: after the scope interview and evidence check, ask whether the core data model/API shape should be sketched before implementation.
- [ ] For Rust, consider invoking `rust-modules` and/or a future `rust-type-design` split when a task introduces public types, state machines, persistence formats, tool schemas, or protocol messages.
- [ ] Validate this carefully to avoid overloading `plan-discipline`. The current skill is lean enough to mention a type-first checkpoint, but detailed Rust type modeling likely belongs in a separate Rust skill so planning does not become a god skill.

### Medium Priority

- [ ] Consider a custom commit workflow or commit-msg hook that runs `prose-lint` against commit messages.
- [ ] Decide whether to create a formal `rust-type-design` skill or extend `rust-modules`.
- [ ] Re-run OpenCode smoke tests after each trigger wording change.

### Low Priority

- [ ] Tune Vale exclusions after real changed-section use exposes repeated false positives.

## Testing Run This Session

- `./bin/check-skills`
- `./bin/check-install`
- `./bin/check-prose`
- `git diff --check`
- `vale sync`
- Vale stdin smoke tests for commit-message and raw docstring modes
- OpenCode headless smoke prompts for `prose-lint`, `rust-review`, and `plan-discipline`
- Claude Code headless direct `/docs:prose-lint` smoke with explicit `--plugin-dir`

## Handoff Notes

Before merge, this session lived in:

`/Users/mshearer/dev/claude-skills/.claude/worktrees/skill-routing-deps-plan-fixes`

After merging this branch to main and removing the worktree, start next session in:

`/Users/mshearer/dev/claude-skills`

After merge, repoint Claude global `my-skills` back to the main repo path and reinstall OpenCode skills from main.

Before merging or installing permanently, run:

```bash
./bin/check-skills
./bin/check-install
./bin/check-prose
```

Then run the manual matrix in one real Claude Code session and one real OpenCode session. The most important remaining question is not whether `plan-discipline` can auto-load in ideal prompts; it is whether it reliably enforces the workflow in the user's real planning language without becoming overfit to the HITL example.

## Open Design Question

The user wants `plan-discipline` to recommend type-first design when applicable. Current implementation is lean enough to support a short checkpoint such as "Does this need a type/data model sketch before coding?" The detailed rules should probably live outside `plan-discipline`, with Rust-specific follow-through delegated to a Rust skill. That keeps `plan-discipline` as the workflow gate and avoids making it a language-specific design manual.
