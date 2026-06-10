# Commit manifest — 2026-06-10 retro + vale session files

For the session handling commits: these files belong to the 2026-06-10 retro/vale
work and are commit-ready as a unit. The index also holds staged work from a
DIFFERENT session (doc deletions under docs/internal/sessions/ and docs/research/,
plus CLAUDE.md, README.md, and .gitignore edits) — do not assume everything staged
belongs together.

Retro batch (this session):
- feedback/README.md (new — naming convention)
- feedback/2026-06-03-claude-code-hitl-v1/ (rename from feedback/hitl-v1-session/, staged)
- feedback/2026-06-10-claude-code-hitl-dual-channel/ (new — skill-retro.md + this manifest)
- plugins/workflow/skills/skill-retro/SKILL.md (new skill)

Vale/disposition batch (this session):
- plugins/docs/skills/prose-lint/SKILL.md (description + Disposition section,
  backtick fix for check-skills)
- plugins/docs/skills/prose-lint/.vale.ini (local style added, FormalRegister off,
  EmDashUsage off — parity with root)
- plugins/docs/skills/prose-lint/.vale/local/FormalRegister.yml (new — trimmed override)
- .vale.ini (FormalRegister off in both sections)
- .vale/local/FormalRegister.yml (new — trimmed override, vetted token list:
  implement*/terminate*/optimize*/minimize*/maximize*/framework*/prioritize* removed)

Proposal (awaiting Mike's review before any of its Tier-1 items execute):
- docs/proposals/2026-06-10-vale-distribution.md

Outside this repo (Mike's to commit):
- ~/.dotfiles/Configs/vale/.vale.ini (FormalRegister off, internal-file scoping;
  reached via the ~/.vale.ini symlink)
- Machine-local, NOT in any repo: ~/Library/Application Support/vale/styles/local/
  FormalRegister.yml (bootstrap gap — covered by the proposal)

Gates at time of writing: bin/check-skills PASS, bin/check-install PASS (14 skills),
bin/check-prose PASS (em-dash advisories only), vale error-free across all files above.
Open item: skill-retro purpose-line wording nit ("file vetted correctives" vs
"file a vetted retro") — presented to Mike, not yet decided.
