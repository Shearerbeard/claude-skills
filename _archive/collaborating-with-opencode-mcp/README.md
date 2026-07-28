# collaborating-with-opencode (retired 2026-07-28)

## What this was

An unversioned skill that lived at `~/.claude/skills/collaborating-with-opencode/`,
542 lines across `SKILL.md` and three reference files. It taught delegation to
OpenCode through the opencode MCP server, leading with `opencode_fire` and
`opencode_run`.

## Why it was retired

The transport it led with was the least reliable one available. Across roughly
70 recorded delegation attempts:

| Path | Success rate |
|---|---|
| Native in-session dispatch (inside an OpenCode session) | ~86% |
| `opencode run` CLI from an external harness | ~63% |
| opencode MCP tools from Claude Code | ~36% |

The MCP failures were 5 empty returns and 3 hangs. Root cause: the
session-creating MCP tools do the work inside the tool call, and
`opencode_ask` / `opencode_fire` / `opencode_check` expose no timeout
parameter, so the wait is unbounded under a ~27.7 hour harness ceiling. With no
job record, a client hang loses the handle to work the server is still doing.
The CLI failures all traced to un-staged inputs or the `--agent` fallback, both
with known workarounds.

The skill's reference files taught the hanging calls with no caveat, and its
model table was three pin-swaps stale. The opencode MCP server has since been
removed from this machine's Claude Code config.

One claim that circulated with this skill is false and should not be repeated:
the MCP server does not embed its own opencode build. It spawns the installed
binary (server reports 1.18.4, matching `opencode --version`).

## What replaced it

- External harnesses (Claude Code, codex, scripts): the `opencode-cli` skill in
  `plugins/workflow/skills/opencode-cli/`, which is CLI-only.
- Native OpenCode sessions: the machine's global opencode instruction file,
  which covers in-session subagent dispatch.
