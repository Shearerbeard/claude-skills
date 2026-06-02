---
name: prose-lint
description: Use when asked to run Vale, prose lint, style lint, check AI tells/slop, or vet prose. Use for checked-in docs/README/skill prose, release notes, commit-message drafts, PR descriptions, issue comments, Slack/email drafts, and public docstrings or doc comments. Reports findings; does not rewrite.
compatibility: claude-code opencode
---

# Prose Lint

Run deterministic prose checks with Vale. This skill reports findings and suggested fixes; it does not rewrite prose. Use `humanizer` after fixes when changed prose will be checked in or sent on the user's behalf.

## Preconditions

1. Check whether Vale is available: `vale --version`.
2. If Vale is missing, report that prose linting was skipped. Do not install Vale unless the user asks.
3. Prefer the project's `.vale.ini` when one exists.
4. If the project has no `.vale.ini`, use this skill's bundled fallback config:
   - Claude Code: `${CLAUDE_SKILL_DIR}/.vale.ini`
   - OpenCode: use `.vale.ini` in the skill base directory shown below the loaded skill content
5. Set `VALE_CONFIG` to the selected config path.
6. If synced styles are missing, run `vale --config "$VALE_CONFIG" sync`. If sync fails, report the failure and continue without prose linting.

This repo and this skill's fallback config use `tbhb/vale-ai-tells` pinned to v1.13.1.

## Input modes

### File mode

Use when prose already exists in files:

```bash
vale --config "$VALE_CONFIG" --output=JSON README.md CLAUDE.md docs/**/*.md plugins/**/*.md
vale --config "$VALE_CONFIG" --output=JSON plugins/python/skills/python-quality/SKILL.md
```

Prefer changed files or changed prose sections. Do not lint the whole repo unless the user asks for a full prose audit.

### Markdown stdin mode

Use when the agent is drafting Markdown-like prose before it exists in a file:

```bash
printf '%s' "$draft" | vale --config "$VALE_CONFIG" --ext=.md --output=JSON
```

Use for PR descriptions, issue comments, release notes, Slack/email drafts, and proposed README/docs paragraphs.

### Commit-message stdin mode

Use the commit-message rules by associating stdin with the commit-message path:

```bash
printf '%s' "$message" | vale --config "$VALE_CONFIG" --ext=.md --path=.git/COMMIT_EDITMSG --output=JSON
```

### Raw prose snippet mode

Use for small snippets that are not Markdown, such as public docstrings or API comments:

```bash
printf '%s' "$docstring" | vale --config "$VALE_CONFIG" --ext=.md --ignore-syntax --output=JSON
```

## Reporting

- Parse JSON findings by file, line, span, check, severity, match, and message.
- Prioritize `error` and `warning`; include `suggestion` findings when they point to a clear fix and are not noisy.
- For large output, summarize the top repeated issues instead of dumping raw JSON.
- Do not rewrite entire files automatically from a large Vale report. Suggest deterministic small fixes, then summarize remaining style suggestions for the user.
- Ignore code blocks, generated content, schemas, exact API signatures, config examples, and intentional examples of bad prose unless the user asks to lint them.
- `plugins/docs/skills/humanizer/**` is excluded from file-mode Vale because it contains intentional bad-prose examples. For changes to its non-example prose, lint the changed text with stdin mode.
