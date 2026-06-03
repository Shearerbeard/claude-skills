# Session 007: Skill Trigger Optimization — Imperative Routing + Cross-Platform Testing

**Date:** 2026-06-02
**Duration:** ~2 hours
**Focus:** Fix intra-skill routing (quality skills not loading), broaden quality skill triggers, test plan-discipline across prompts, cross-platform comparison (opencode vs Claude Code)
**Branch:** `main`

## Summary

Discovered and fixed a critical gap: intra-skill routing instructions ("Load X") were treated as suggestions, not commands. Quality skills (`rust-quality`, `python-quality`) never loaded during review chains. Fixed by replacing generic "Load X for rules" with imperative language explaining *why* loading matters ("Without it, you will miss [specific failure modes] that training data alone won't flag").

Tested 8 skills across 15+ prompts in opencode. Cross-platform testing revealed Claude Code doesn't auto-trigger skills on the same prompts — it responds from training.

## Commits

- `d7a3045` skill(description): broaden quality skill triggers, add imperative intra-skill routing
- (pending) skill(description): fix plan-discipline trigger language, add session notes

## Activities

### 1. Intra-skill routing fix

**Problem:** `rust-review` said "Load `rust-quality`" but the model skipped it. Same for `python-review` → `python-quality`.

**Root cause:** The model already knows `Arc::clone` and `transpose()` from training. It doesn't see loading a reference card as necessary.

**Fix:** Replace generic instructions with imperative + why:
- `rust-review`: "Before applying probes, load `rust-quality` — it contains the anti-pattern rules and preferred patterns you must check against. Without it loaded, you will miss clone escapes, speculative fallbacks, and weak error modeling that are invisible from training data alone."
- `python-review`: Same pattern with Python-specific consequences (silent degradation, duplicated traversals).

**Result:** Both chains now load quality skills:
- `gate-probes` → `rust-review` → `rust-quality` ✅
- `gate-probes` → `python-review` → `python-quality` ✅

### 2. Quality skill trigger broadening

Broadened `rust-quality`, `python-quality`, and `rust-modules` descriptions to cover planning/reviewing/discussing, not just writing/editing. Added concrete reference patterns to `rust-quality` description (transpose, Arc::clone, newtypes, parse-don't-validate, sealed traits).

### 3. plan-discipline trigger optimization

Tested multiple description variants:
- ❌ "Use before the first code edit for non-trivial implementation work" — too abstract
- ❌ "Load before writing code for multi-file features..." — model doesn't map "Add X" to "multi-file features"
- ❌ "Training data teaches scope interviews but not the user's required gates..." — too long, trigger language buried
- ✅ Short + concrete: "Use when the user asks to add a feature, refactor, migrate, or redesign code. Also use when they say 'plan this out', 'scope this', 'minimal V1', 'vet assumptions', or 'don't assume'."

**Working prompts in opencode:**
| Prompt | Triggers? |
|--------|-----------|
| "Add a REST API with auth and dashboard" | ✅ |
| "Add a SQLite persistence layer and web API" | ✅ |
| "Add a blog section with categories and search" | ✅ |
| "What's the minimal V1?" | ✅ |
| "Vet my assumptions" | ✅ |
| "Don't assume" | ✅ |
| "Refactor into workspace" (already done) | ❌ (correct — no work needed) |
| "Migrate os.walk to pathlib" (already done) | ❌ (correct — no work needed) |

### 4. Cross-platform testing (opencode vs Claude Code)

| Prompt | opencode | Claude Code |
|--------|----------|-------------|
| "Ready to commit" | ✅ gate-probes + python-review | ❌ reviews from training |
| "Humanize this" | ✅ humanizer | ✅ humanizer (or training) |
| "Add REST API + auth" | ✅ plan-discipline | ❌ scope interview from training |
| "Minimal V1" | ✅ plan-discipline | ❌ answers from training |
| "Don't assume" | ✅ plan-discipline | ❌ answers from training |
| "Review Rust code" | ✅ rust-review + rust-quality | ❌ reviews from training |
| Explicit "run gate-probes" | ✅ loads skills | ✅ loads skills |

**Key finding:** Claude Code doesn't auto-trigger skills on the same prompts. It responds from training. Skills only load when explicitly invoked or when the prompt matches very specific patterns.

### 5. Test project mutation

Previous test runs mutated the rust project (added workspace crates, built target dir). Python project also mutated (added tests, CLI config). Source files were never changed — only build artifacts and new files from prior runs.

## Key Learnings

1. **Intra-skill routing must explain *why*.** "Load X" is ignored. "Without X you will miss [specific failure modes]" works because it names consequences the model can't satisfy from training alone.

2. **plan-discipline needs short, concrete trigger language.** Long descriptions bury the trigger phrases. "Add a feature" works better than "multi-file implementation work".

3. **Claude Code and opencode have different skill routing behavior.** Claude Code relies more on training for planning/review tasks. opencode appears more willing to load skills based on description matching.

4. **Correct non-triggering is a feature.** plan-discipline correctly doesn't trigger when the task is already done (workspace exists, migration complete). The model recognizes this.

## Decisions Made

1. **Keep imperative + why pattern for intra-skill routing.** Applied to `rust-review` and `python-review`. Should apply to any future skill chains.

2. **Short descriptions work better than long ones.** The model matches on concrete phrases, not comprehensive coverage.

3. **Cross-platform differences are expected.** Skills are model-facing, and different models have different routing behavior. Test in both editors.

## Current State

- Claude global `my-skills` marketplace points to main repo path
- OpenCode skills installed from main into `~/.config/opencode/skills`
- All 3 quality gates pass: `check-skills`, `check-prose`, `check-install`

## TODOs

### High Priority
- [ ] Manual testing sessions in both opencode and Claude Code editors to refine trigger language
- [ ] Consider whether Claude Code needs different trigger language (more explicit, or different phrasing)
- [ ] Clean up terminalbench orphan from install dir
- [ ] Clean up mutated test project directories

### Medium Priority
- [ ] Add quoted user phrases to remaining 6 skills (rust-review, rust-quality, rust-modules, python-review, python-quality, docs-bustest)
- [ ] Test longest dependency chain: gate-probes → rust-review → rust-quality + docs-bustest → prose-lint → humanizer
- [ ] Test docs-bustest → prose-lint → humanizer chain with actual doc edits

### Low Priority
- [ ] Consider whether plan-discipline should recommend type-first design for Rust
- [ ] Consider custom commit workflow or commit-msg hook for prose-lint

## Testing Run This Session

- `./bin/check-skills` ✅
- `./bin/check-prose` ✅
- `./bin/check-install` ✅
- 15+ opencode skill trigger tests
- 8+ Claude Code skill trigger tests
