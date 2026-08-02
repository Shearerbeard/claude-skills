---
name: process-feedback
description: |
  Use when the user says "file process feedback", "record process friction",
  "send feedback to boardkit", or names friction whose fix belongs in an
  upstream toolkit or process repo (boardkit, rust-holes, another kit this
  repo consumes) rather than in the current repo. Records the finding as a
  session-feedback entry and mirrors it into the upstream repo's FEEDBACK.md
  inbox when a local checkout exists. Not for skill-trigger retros (use
  skill-retro) and not for code review findings.
compatibility: claude-code opencode
---

# Process feedback

Record friction with an upstream toolkit or process repo so its maintainer
can act on it, without editing that repo's content from a consumer session.
Two writes, both append-shaped: a local record under the skills marketplace
repo's feedback/ directory, and a mirrored entry in the upstream repo's
FEEDBACK.md inbox when that repo is checked out locally.

## Ground rules

- Ground the finding in the actual session: what happened, where, and what
  the friction cost. Never assert from memory.
- Vet the finding with the user before writing either copy.
- The upstream repo is touched in exactly one way: appending one entry to
  its FEEDBACK.md inbox. Never edit its templates, code, docs, or existing
  inbox entries, never reformat the file, and never scaffold missing files
  in it. If the repo has no FEEDBACK.md, keep the local record only and
  tell the user the upstream side has no inbox yet.
- An entry proposes; the upstream maintainer disposes. Do not phrase the
  entry as a commitment that the kit will change.

## The local record

File the finding under the marketplace repo's feedback/ directory using
the convention feedback/README.md owns: one directory per session,
feedback/<YYYY-MM-DD>-<harness>-<topic-slug>/, harness vocabulary
claude-code, opencode, codex, or antigravity, same-day collisions taking a
-2 suffix. The artifact for this skill is process-feedback.md, with the
standard frontmatter (date, harness, agent, session_event, workstreams,
repo) and the finding in prose: what happened, why it is upstream
material, and the candidate fix if one is apparent. Retro sessions run in
the consuming project, not the marketplace repo: resolve feedback/ against
the marketplace checkout.

## The mirror

When the upstream repo is a local checkout, append one entry to its
FEEDBACK.md in the format that file itself states (the inbox is
self-describing; read its format section before writing). Reuse the local
record's frontmatter values, and point the entry's source field at the
local record's path so the two copies cross-reference. Append at the end
of the entries; touch nothing else in the file.

When the upstream repo is not local, the local record is the only copy;
tell the user it needs hand delivery.

## After writing

Read both files back and confirm the upstream diff is append-only (one
entry added, nothing else changed). If anything beyond the append shows
up, stop: make no further writes to the upstream repo, show the user the
exact diff, and let them decide how to clean it up. The append is the
only upstream write this skill ever authorizes, including during its own
error handling.
Where a gate or commit follows, prose lint applies to the entry like any
other checked-in prose.
