---
date: 2026-06-10
harness: claude-code
agent: claude-fable-5
session_event: (tracked in private session wiki)
workstreams: [hitl]
repo: internal Rust agent-orchestration service @ feature worktree; ADR on a separate branch
---

# Skill retro: HITL dual-channel design session (2026-06-09/10)

Deliverables of the session under review: dual-channel HITL architecture ADR (committed
on its own branch), Rust domain type pre-design, discovery docs in the private session
wiki, and a handoff event. Design-only session: no Rust was
written, yet the work still covered Rust type design and module layout, plus
async primitive choices and two git commits.
Findings vetted with Mike before this document was written.

## How skills actually trigger (observed mechanics)

Skill loading is model-discretionary. The names and descriptions sit in context as a list;
nothing mechanically matches keywords. Whether a skill loads depends on whether its
description surfaces at a decision moment. This session showed four distinct channels,
ranked by observed reliability:

1. **Entry-time conversational match.** User phrase matches description phrase at the
   moment a task starts. Worked for rust-design ("pre-design the rust types" matched
   "design a Rust type"). Failed for plan-discipline even though the user's opening
   message contained near-verbatim trigger phrases ("assume nothing", "vet my
   assumptions") — the phrases were buried in a long, domain-dense message, and the model
   had already classified the task as "discovery, not implementation" before scanning for
   triggers. When a description's framing contradicts the model's task frame ("invoke
   before the first code edit" vs "there is no code here"), the frame wins.

2. **Mid-flow in-body cross-references.** Once inside a flow, the only instructions in
   fresh context are the already-loaded skill body and the work itself; the skill list is
   thousands of tokens back and does not get re-scanned at sub-task boundaries. This is
   exactly why rust-modules, rust-async, and rust-quality never fired: their cue moments
   (sketching the module tree, choosing std vs tokio Mutex, killing a dyn trait for an
   enum) arose *inside* the rust-design flow. A pairing note at the end of a description
   ("Pair with rust-quality") is invisible at that moment. An imperative line inside the
   loaded body, at the workflow step where the cue arises, is in fresh context exactly
   when needed. This is the highest-leverage fix class, and it is tool-neutral.

3. **Artifact/action boundaries.** Tool-use moments (about to write a checked-in .md,
   about to run git commit) trigger skills whose descriptions name the artifact or the
   action — *if the niche is not already filled*. humanizer fired before drafting the ADR
   because "checked-in docs" is an unambiguous artifact cue. gate-probes and git-commit
   did not fire for two commits, because CLAUDE.md commit rules plus feedback memories
   already occupied the "commit checklist" mental slot; with no felt gap, there was no
   lookup. Redundancy suppresses triggering: when a skill duplicates CLAUDE.md or memory
   content, the model satisfies the requirement from the always-on copy and never loads
   the skill.

4. **Deterministic hooks.** A PreToolUse hook on `git commit` is the only guaranteed
   channel. Hooks are Claude-Code-specific (settings.json); OpenCode is unaffected — the
   hook simply does not exist there, which is the correct failure mode.

Answer to the vetting question ("are we only caring about conversational cues?"): no.
Conversational cues only work at task entry. The underused valid channels are in-body
cross-loads at sub-task boundaries (fixes the rust cluster) and deterministic hooks
for hard gates (fixes commit-time skills); artifact cues already work where
descriptions name artifacts. The anti-pattern to remove is redundancy suppression: either
the skill is the single source of truth and CLAUDE.md points at it, or the skill will be
skipped.

## Per-skill findings

### Fired and earned their keep

**rust-design** — fired on an exact phrase match. Strongest content-to-outcome link of
the session: the AwaitingDecision typestate (consume-on-await), terminal-only
ApprovalOutcome (the user's "is Pending missing from the enum?" challenge was answered
*by* the skill's doctrine — pending became live values, not a variant), constrained
DecisionId, and ApprovalOrigin folding an Option co-occurrence invariant all trace to
skill content. No trigger fix needed; co-load fix below.

**humanizer** — fired correctly on the checked-in-doc clause; the Vale loop caught three
real tells in the ADR. Two issues. First, the skill is written as a rewrite pass for
existing text but was used as pre-writing guidance; it worked, but a short "pre-writing
mode" note would make that use first-class. Second, the always-on vale-ls integration
was a false-positive factory on internal files all session: 'implementation'/'implements'
flagged as AI formalism in a software repo, verb-tricolon flags on factual three-item
lists in workstream files, flags on the *generated* CLAUDE.local.md. Noise at that volume
trains the operator to ignore the linter right before it matters on a real document.

**handoff** — produced the event cleanly. Two structural gaps, both session-wiki
concerns rather than marketplace fixes (flagged here because the systems work together):
(a) "do NOT rewrite CLAUDE.local.md" collided with a real mid-cycle hazard — a dangling
START-HERE pointer to a file the session had moved; there is no sanctioned hotfix path
between garden runs. (b) The event schema has one branch/sha slot; this session's
deliverable lived on a different branch than the session worktree, and the two-branch
reality had to be carried in prose fields.

### Should have fired, did not

**plan-discipline** — missed despite near-verbatim trigger phrases, root-caused above
(task-frame mismatch: design-only session vs "before the first code edit" framing). The
session ran the equivalent manually — three scope-interview question rounds, evidence
audits with file:line proof, explicit gates — and the outcome was good, but that is
discipline-by-luck, not enforcement. Fix (vetted): add a design/ADR mode.

**rust-modules** — the eight-file module tree, which was the *direct answer to the
user's god-module complaint*, was designed without ever loading the module-layout skill.
Probably conformant (mod.rs as pure facade); unvetted against its own rules.

**rust-async** — oneshot channels, std::sync::Mutex vs tokio::sync::Mutex,
select!-over-deadline-and-cancellation, CancellationToken integration: all designed
without it. The no-await-under-lock std Mutex choice happens to match the skill's
content, by coincidence not consultation.

**rust-quality** — "planning Rust code" is in its trigger; never loaded. The
DecisionRoute enum-over-dyn-trait decision aligns with its rules, again by coincidence.

**gate-probes** — "Use before git commit"; two commits this session, zero invocations.
Both commits were low-risk and conventions held via CLAUDE.md + commitlint, but a trigger
that misses 2/2 of its named moments is dead. Side finding: a wiki-repo commit used
"planning:" as a commit type, which is not a conventional-commit type; that repo's
conventions are documented nowhere.

**git-commit / github-workflow** — not in this marketplace (they ship from a
separate work marketplace); the same redundancy-suppression finding applies, but
correctives belong to that marketplace's PR stream.

### Process-level

**Cross-model review gap.** The user's own feedback memories mandate independent review
at gates, and collaborating-with-antigravity claims architectural/spec review — yet the
ADR was committed with zero independent eyes (the user chose "design audit" over
"cross-model review" for the discovery phase, and nothing re-raised review at the
commit-the-ADR moment). Neither collaborating-* skill names "ADR or design doc
completed" as a trigger moment.

**What worked without being a skill.** Explore subagents produced the two decisive
evidence sweeps (the SSE-events vetting that corrected the user's recollection, and the
client-tool turn-ending discovery that changed the architecture). Memory-encoded
behaviors fired correctly throughout: anchor-to-design-docs (timeout numbers waited for
the user), review-before-posting (nothing pushed), worktrees-by-default, commitlint.
Several memories are candidates to migrate into skill bodies: memories are
Claude-Code-private; skills travel to OpenCode.

## Correctives (vetted with Mike 2026-06-10)

### 1. rust-design: targeted in-body co-loads (approved, targeted cases only)

Add imperative lines inside the workflow body at the step where each cue arises, not in
the description tail. Tool-neutral phrasing ("load skill X", never "invoke the Skill
tool"):

- At the type-organization step: "If the design defines module or crate boundaries
  (file splits, mod declarations, pub use facades), load rust-modules before settling
  the layout."
- At the concurrency step: "If the design includes channels, locks, spawned tasks, or
  cancellation, load rust-async before settling Send/Sync and Mutex choices."
- Before presenting: "Before presenting a finished design, load rust-quality and check
  the result against its anti-patterns (needless dyn, speculative fallbacks, weak error
  modeling)."

Mirror one back-reference line in rust-modules and rust-async ("for type and domain
modeling questions, load rust-design") where missing. Do not merge the skills; focused
triggers and per-skill context cost are worth keeping.

### 2. plan-discipline: design/ADR mode (approved)

- Description: add "design", "ADR", "architecture doc", and "design review" to the
  trigger list, and replace the "before the first code edit" framing with "before the
  first code edit or before drafting a design doc/ADR for later work".
- Body: a design-mode section where the same scope interview, evidence check, and
  blast-radius scan apply, with gates adapted: question rounds with the user replace
  manual testing; independent cross-model review replaces the test gate; the
  user-review gate is the document itself.
- Consolidation: the always-on scope interview in the user's global CLAUDE.md should
  point at this skill as the single source, removing the duplication that contributes
  to redundancy suppression.

### 3. Vale scoping and vocabulary (approved)

- Scope ai-tells away from internal/generated files: exclude `.claude/workstreams/**`,
  `CLAUDE.local.md`, wiki planning scratch, and generated index files. Implement via
  section globs in the relevant .vale.ini (global ~/.vale.ini and the vendored copies
  at claude-skills/.vale.ini and prose-lint/.vale.ini).
- Vocabulary: remove 'implementation'/'implements' from FormalRegister for software
  repos (vendored FormalRegister.yml copies), or add a repo-level exception list. These
  two words generated the majority of false positives this session.
- Keep ai-tells at full strength for checked-in prose (docs/, README, ADRs) — it caught
  three real tells in the ADR draft.

### 4. gate-probes: hook plus trigger strengthening (approved)

- Document a PreToolUse hook recipe (Claude Code settings.json) that fires on Bash
  `git commit` and reminds the model to run the gate-probes checklist. Mark it CC-only;
  OpenCode is unaffected.
- Add to the description: "including documentation-only and non-code commits".
- Separately: document the session wiki's commit conventions somewhere
  discoverable, or stop using bare invented types like "planning:".

### 5. collaborating-* skills: ADR review trigger (approved)

Add "an ADR or design document has been drafted or committed" as an explicit trigger
moment to collaborating-with-antigravity (architectural/spec review) and a review-role
mention in collaborating-with-opencode. Immediate application: run an agy/Gemini review
pass on the dual-channel HITL architecture ADR before its PR
opens.

### 6. Cross-repo flags (approved; session-wiki backlog, not marketplace edits)

- handoff event schema: support multiple branch/worktree refs per event.
- Define a sanctioned "index hotfix" path for dangling CLAUDE.local.md pointers between
  garden runs (e.g., a marked hotfix block the next garden rebuild absorbs or discards).
- These interlock with the skill fixes ("it all works together"): handoff is invoked as
  a skill but its contract is owned by the wiki system.

## OpenCode portability checklist for all edits

- Keep `compatibility: claude-code opencode` frontmatter intact.
- Bodies stay tool-neutral: "load skill X", never "invoke the Skill tool"; no
  AskUserQuestion or other CC tool names in instructions (describe the action —
  "ask the user", "run question rounds" — not the tool).
- Hooks and settings.json recipes are documented as Claude-Code-only sections; their
  absence in OpenCode must be a no-op, never a broken instruction.
- Vale config changes affect only the lint surface; OpenCode sessions that run vale via
  prose-lint pick up the same vendored styles, so vocabulary fixes apply to both.
