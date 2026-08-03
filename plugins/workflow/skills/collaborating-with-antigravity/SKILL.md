---
name: collaborating-with-antigravity
description: Delegate plan, prose, spec, architecture, product, and marketing review to the Google Antigravity (agy) CLI, through the agy MCP tools from Claude Code or a JSON-bridge script from other harnesses. Also covers sandboxed execution in a worktree and long agent loops that should not block the main conversation. Not for code review, which goes to the opencode CLI reviewers or the codex CLI. agy spend is budget-gated, so get explicit user approval once per session before dispatching.
---

# Collaborating with Antigravity

The agy bridge (`scripts/agy_bridge.py`) is a thin JSON wrapper around the
Google Antigravity (`agy`) CLI plus an optional `gemini` CLI fallback. It
produces stable `BridgeResponse` envelopes so this skill can drive
Antigravity sessions deterministically.

## Reserved for language-shaped review

agy/Antigravity is **reserved for plan reviews, prose, spec,
architecture, product, and marketing review**. It handles human language
more naturally than Anthropic and Anthropic-inspired models, which is
exactly what those artifacts are judged on.

It is **not** the default for code review. Low-level code review routes
to the OpenCode CLI reviewers (load `opencode-cli`) or the codex CLI.

The budget gate still applies: get explicit user approval for agy spend
once per session before dispatching.

That gate is also the tiebreaker where two documents claim prose review:
the codex CLI stays the un-gated default for card and gate prose legs,
and agy takes plan and prose review only once the user has approved
spend for this session.

## MCP or bridge

Two frontends, one backend. Pick by what your harness can reach:

- **From Claude Code, use the agy MCP tools.** They implement a bounded
  job model: `agy_start` returns a job id immediately, then `agy_status`,
  `agy_read`, `agy_result`, and `agy_cancel` work against that id. Every
  call takes an explicit `timeout`, and jobs are recorded in an on-disk
  session store. That job record is why agy stays reliable where a
  client-side wait would strand the work.
- **Use `scripts/agy_bridge.py` from harnesses that cannot reach Claude
  Code's MCP servers**: an OpenCode or codex session, or a plain shell
  script.

Both drive the same agy-mcp backend, so this is a transport choice, not
a capability difference.

Do not trust any install-state claim written into this file. Run the
`agy_doctor` tool at the moment you use the skill and read its report as
authoritative: it confirms the agy version, the auth state, whether the
`gemini` CLI fallback is present, and the session-store path.

## When to use

- You need a **second opinion** on a plan, spec, architecture note, or
  other language-shaped artifact.
- You are delegating **execution** of a change and want it kept in
  isolation (auto-worktree). This is execution delegation, not review,
  and it stays behind the budget gate.
- You need to **run a long agent loop** (planning, large refactors) without
  blocking your own conversation: start a background job and poll.
- You want code Antigravity proposes **run in a sandbox** so its side
  effects are contained. Again isolation, not a review verdict, and
  budget-gated like the rest.

Do not use for trivial one-shot questions - the round-trip overhead is
not worth it. Prefer direct work for those.

## Quick start

```bash
# One-shot synchronous call (ask mode, no write):
python scripts/agy_bridge.py \
  --cd "/path/to/project" \
  --PROMPT "Explain the auth flow in src/auth/"
```

Output is a single JSON line on stdout: `{"success": true, "SESSION_ID":
"...", "agent_messages": "...", "adapter": {...}, ...}`.

## Modes

`--mode` controls the agent persona and downstream safety policy:

| Mode | Use it for | Worktree? | Writes? |
|------|-----------|-----------|---------|
| `ask` (default) | Q&A, code reading, design discussion | no | no |
| `plan` | Multi-step planning, breakdown | no | no |
| `prototype` | Generate diffs to hand back (execution delegation, not review) | optional | no |
| `review` | Review of a plan, prose, or spec artifact | no | no |
| `execute` | Make file edits in the workspace | **yes** | requires `--allow-write` |
| `browser` | Interactive browsing / research | no | no |
| `long` | Multi-hour agent loop, expect to poll status | no | no |

`execute` always creates a worktree by default; combine with
`--allow-write` to opt in to mutations. The worktree default is
configurable in `~/.config/agy-mcp/config.toml` (see references/security.md).

## Multi-turn

Capture `SESSION_ID` from the first response, then pass it back:

```bash
# Turn 1
python scripts/agy_bridge.py --cd "/proj" --PROMPT "Analyse src/auth/"
# → {"SESSION_ID": "abc-123", "agent_messages": "..."}

# Turn 2 (continues the same conversation)
python scripts/agy_bridge.py --cd "/proj" --SESSION_ID abc-123 \
  --PROMPT "Now propose a refactor."
```

## Long jobs (start / status / result / read / cancel)

For tasks that exceed a single Claude turn, use the supervisor surface
via the MCP tools `agy_start` / `agy_status` / `agy_result` /
`agy_read` / `agy_cancel`.
See `references/usage.md` for full examples.

## Capability detection

The bridge advertises adapter capabilities in every response under
`"adapter"`. Trust those over your prior assumptions - `agy` does not
stream tokens, so `supports_streaming=false` is normal; `gemini` does,
so the fallback path returns finer-grained events.

## Output protocols

`--output-protocol claude` (default) emits events shaped like Claude
Code stream-json. `--output-protocol codex` emits OpenAI Codex
exec-json. `--output-protocol raw` returns the canonical event envelope
unchanged. Pick the one that matches your downstream parser.

## Safety floor

- Secrets are scrubbed from every response and log via `SafetyPolicy`.
- `--allow-write` is required for any mutation; safety policy denies
  destructive prompts even with the flag.
- Long jobs expose `exit_code` and timing on the `JobRecord` returned
  by `agy_status`.

## Detailed references

- `references/usage.md` - full CLI flag reference, MCP tool surface,
  long-job patterns, exit codes.
- `references/prompt-patterns.md` - proven prompt scaffolds for `ask`,
  `plan`, `prototype`, `review`, and `execute` modes.
- `references/security.md` - threat model, secret handling, denylist,
  worktree behaviour, audit log layout.
