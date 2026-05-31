# Session 005: Skill Triggering Engineering + Humanizer Fork + Vale Research

**Date:** 2026-05-31
**Duration:** ~half day
**Focus:** Diagnose and fix skill auto-triggering failures across Claude Code and OpenCode; fork humanizer with improved trigger; research vale integration paths
**Branch:** main

## Summary

Diagnosed why several skills (plan-discipline, rust-quality, rust-review, gate-probes, docs-bustest, humanizer) weren't auto-triggering as expected. Established that both Claude Code and OpenCode use LLM judgment over skill descriptions (NOT semantic embeddings — corrected a prior wrong assumption). Rewrote all trigger descriptions from passive ("Triggers when…") to imperative ("Use when… Always load…"). Added cross-references between quality/review skill pairs. Created rust-modules skill for file layout rules LLMs consistently get wrong. Fixed mermaid script path resolution via plugin `bin/` directory. Forked blader/humanizer with MIT attribution to add a trigger description that leads with user-typed verbs. Verified vale supports stdin/JSON for future "pipe prose fragments through vale at emit moments" enhancement. Created global `~/.claude/CLAUDE.md` with scope-interview questions as the always-on bypass for plan-discipline's mid-conversation triggering ceiling.

## Activities

1. **Marketplace path investigation** — verified `./plugins/<name>` paths resolve correctly. Skills loading globally was confirmed via fresh OpenCode session listing all 8 plugins. No path changes needed.

2. **plan-discipline + gate-probes trigger rewrites** — both used abstract state language ("entering plan mode", "commit boundaries"). Rewrote to imperative + concrete user actions.

3. **docs-bustest expansion** — added agent discoverability section (6 new checks: CLAUDE.md existence, current status, handoff currency, single roadmap, cross-references, no duplication). Added "one fact, one place" principle. Renamed dir from `docs-busttest` to `docs-bustest`.

4. **rust-modules skill created** — covers what rust-quality doesn't: no-mod.rs, re-exports/facade, type co-location, anti-stuttering, legacy scope containment. ~50 lines, tight and complementary.

5. **Mermaid `bin/` fix** — moved `scripts/mermaid-view` to `plugins/docs/bin/` so Claude Code adds it to `$PATH` automatically when the docs plugin is enabled.

6. **CLAUDE.md updated** — documented the `bin/` pattern and trigger description engineering with sources.

7. **rust/python quality+review trigger rewrites** — all four skills converted from passive to imperative pattern.

8. **Cross-references added** — each quality skill mentions the review skill (and vice versa), so loading one nudges toward the pair.

9. **Plan-discipline ceiling investigation** — multiple test sessions showed plan-discipline never auto-triggers, even when "review/plan this" is in the prompt. Research established root causes (see learnings below).

10. **Opus second opinion** — confirmed framing of the ceiling, suggested UserPromptSubmit hook as an alternative to CLAUDE.md. After verification of hook costs (every-prompt overhead, OpenCode parity gap, severity filter issues), kept CLAUDE.md approach.

11. **Global `~/.claude/CLAUDE.md` created** — minimal entry with scope-interview questions as always-on context that survives "investigation → design" failure mode.

12. **Humanizer fork** — copied blader/humanizer v2.5.1 (MIT) into `plugins/docs/skills/humanizer/` with attribution inline + LICENSE file. Rewrote trigger description leading with verbs users actually type ("humanize", "de-AI", "naturalize"). Expanded to cover AI-on-behalf-of-user channels: commit messages, PR descriptions, GH issue/comment bodies, Slack/Discord posts, email drafts, release notes.

13. **install-skills hardened** — switched from `cp SKILL.md` to `cp -R skill_dir/` so LICENSE files and progressive-disclosure references propagate to opencode/codex installs.

14. **Vale-as-LSP research** — initial agent claim that "OpenCode doesn't surface diagnostics" was WRONG. Verified at source: `packages/opencode/src/lsp/diagnostic.ts` filters severity=1 errors and appends them to every `edit`/`write` tool output. Claude Code also surfaces diagnostics after edits via internal injection (not via the LSP tool API). Path forward for vale-in-OpenCode: bump severity in `.vale.ini` (Vale-side fix dominates) instead of patching OpenCode.

15. **Vale stdin verification** — confirmed `vale --ext=.md --output=JSON` accepts stdin, returns line/span/check/severity/match per finding. `--path=` flag allows pretending stdin is a specific file for `.vale.ini` glob matching. `--ignore-syntax` lints line-by-line for raw prose. This enables a future skill enhancement: pipe prose fragments through vale at emit moments without writing to disk.

## Key Learnings

- **Both Claude Code and OpenCode use LLM judgment for skill loading** (source-verified). No semantic embeddings, no ranking, no top-N cutoff. A prior memory claim of MiniLM/cosine matching in OpenCode was WRONG and has been corrected. All allowed skills are listed verbatim in `<available_skills>` every turn; the model picks via the `skill` tool.

- **Skills evaluate at prompt-submit time and don't re-trigger mid-loop.** When a task evolves from "investigate X" to "design Y", the originally-loaded skill set stays fixed. The model rarely self-invokes skills it perceives as redundant with its own capabilities.

- **Concrete-noun anchors trigger reliably; abstract verbs don't.** rust-quality (.rs, Cargo.toml, clippy) and gate-probes (git commit, gh pr create) load consistently. plan-discipline (plan, design, scope) gets shadowed because the model already thinks it can plan. The description must tell the model what it would do DIFFERENTLY if loaded.

- **EnterPlanMode is invisible to skills** (Claude Code #21282, #41051). UserPromptSubmit hooks fire every prompt with no matcher (script must filter internally). Plan-mode prompts in both tools cover enough planning territory that plan-discipline looks redundant.

- **LSP diagnostics ARE surfaced to agents in both tools** (verified): OpenCode appends them to every edit/write tool output (severity=1 hardcoded filter); Claude Code injects them after edits via internal mechanism (not exposed in the LSP tool API).

- **Vale-pipe future pattern**: at any prose-emit moment (commit message, PR description, GH comment), `echo "$draft" | vale --ext=.md --ignore-syntax --output=JSON` returns structured findings. No file, no LSP, works in any tool that can shell out. This is the cleanest path to integrate vale's regex layer into humanizer-style skills without committing to LSP configuration.

- **Plugin `bin/` directory is the canonical script-bundling pattern** in Claude Code. Scripts in `plugins/<name>/bin/` get added to `$PATH` automatically when the plugin is enabled. Scripts inside `skills/<name>/scripts/` only resolve from within the repo.

- **For mid-conversation/always-on behaviors, CLAUDE.md beats skill auto-trigger.** Skills compete for the model's attention based on description matching; CLAUDE.md is always in context. The scope-interview questions belong in CLAUDE.md, not in a skill that has to fight to load.

## Decisions

- **Kept plan-discipline as manual `/plan-discipline` invocation** + scope-interview in `~/.claude/CLAUDE.md`. Rejected UserPromptSubmit hook approach (every-prompt overhead, OpenCode parity gap, no plan-mode awareness, version-cache fragility).

- **Forked humanizer rather than depending on OSS skill.** OSS trigger description failed to fire even when the user said the skill name. Fork sole modification: frontmatter rewrite. Body unchanged.

- **Did NOT integrate vale into humanizer body.** Real measurement showed 14% FULL coverage, 30% PARTIAL, 56% NO coverage. Realistic line savings: 21% (559→440). Not worth the external dependency. Captured vale-pipe as future enhancement instead.

- **install-skills now copies full skill directory** (cp -R), not just SKILL.md. Required for forks with bundled LICENSE files and for progressive-disclosure reference dirs.

## Files Modified

- `plugins/workflow/skills/plan-discipline/SKILL.md` — trigger rewrite
- `plugins/workflow/skills/gate-probes/SKILL.md` — trigger rewrite
- `plugins/docs/skills/docs-bustest/` — renamed from docs-busttest, agent discoverability section added, trigger rewrite
- `plugins/docs/skills/mermaid/SKILL.md` — updated to use `mermaid-view` (was `scripts/mermaid-view`)
- `plugins/docs/bin/mermaid-view` — moved from `skills/mermaid/scripts/`
- `plugins/rust/skills/rust-quality/SKILL.md` — trigger rewrite + cross-ref to rust-review
- `plugins/rust/skills/rust-review/SKILL.md` — trigger rewrite + cross-refs to rust-quality and gate-probes
- `plugins/rust/skills/rust-modules/SKILL.md` — new skill
- `plugins/python/skills/python-quality/SKILL.md` — trigger rewrite + cross-ref
- `plugins/python/skills/python-review/SKILL.md` — trigger rewrite + cross-refs
- `plugins/docs/skills/humanizer/SKILL.md` — new fork (MIT, attributed)
- `plugins/docs/skills/humanizer/LICENSE` — MIT notice preserved
- `bin/install-skills` — cp -R for full skill dirs
- `CLAUDE.md` — bin/ pattern and trigger description guidance + sources
- `~/.claude/CLAUDE.md` — new global, scope-interview questions

## Next Session Starting Points

- Test plan-discipline behavior with the new CLAUDE.md scope-interview in real planning sessions (aura, agent-driver-rs).
- Run the three validation projects (agent-driver-rs, aura HTIL, neckcharts) to measure skills effectiveness.
- Consider implementing vale-pipe enhancement to humanizer when a commit-message/GH-comment emit moment triggers it organically.
- If the vale-in-OpenCode workflow becomes a daily-driver need, write a setup script that creates `~/.config/opencode/opencode.json` lsp entry + project `.vale.ini` with bumped severities.
