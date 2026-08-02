# Stash triage: pre-merge-skill-routing-dirty-main

Triage of `stash@{0}` ("On main: pre-merge-skill-routing-dirty-main"),
2026-08-02. Full patch archived at [stash.diff](stash.diff); the stash
itself was cleared after this note was written.

The stash predates the prose-lint and humanizer merge and no longer
applies to main. Disposition of its contents:

- The one correction still worth checking, that OpenCode skill routing
  uses LLM judgment over metadata rather than embedding similarity,
  already landed independently: README.md's "Writing Skill Descriptions"
  section states that Claude Code and OpenCode both rely on model
  judgment. Nothing to port.
- Everything else (the .gitignore vale entry, the CLAUDE.md/README
  catalog lines, the prose-lint routing lines in docs-bustest,
  python-review, rust-review, and gate-probes, the humanizer Vale
  pre-pass) shipped long ago in evolved form on main. Dropped.
