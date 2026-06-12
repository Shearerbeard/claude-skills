# feedback/ - session retros

Retrospectives on how skills from this marketplace performed in real sessions. Each
retro critiques trigger accuracy and skill content against an actual conversation log
and proposes correctives.

## Naming convention

One directory per retro session:

```
feedback/<YYYY-MM-DD>-<harness>-<topic-slug>/
├── skill-retro.md     # how skills triggered and performed (the usual artifact)
├── plan-retro.md      # planning-process retro (when applicable)
└── transcript.md      # supporting excerpts (when applicable)
```

- `harness` is the tool that ran the session: `claude-code`, `opencode`, or
  `antigravity`. Same vocabulary as the session-tracking wiki's event `tool:`
  field, so retros and handoff events cross-reference.
- `topic-slug` is short kebab-case for the session's subject.
- Same-day collisions take a `-2` suffix.
- File names inside stay type-based; the directory carries the session identity.

## Required frontmatter

Every retro file starts with:

```yaml
---
date: 2026-06-10
harness: claude-code
agent: <model id, e.g. claude-fable-5>
session_event: <handoff event id from the session-tracking wiki, if one exists>
workstreams: [<workstream names touched>]
repo: <repo @ worktree/branch context>
---
```

The agent/model lives in frontmatter, not the directory name, to keep paths short
while staying greppable (`grep -r "agent: claude-fable-5" feedback/`).

## Process expectations

- Ground findings in the actual conversation log; do not assert from memory.
- Vet findings with the user before writing the document.
- Corrective proposals must respect cross-harness portability: skill bodies stay
  tool-neutral so OpenCode consumes them unchanged.
