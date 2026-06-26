---
name: git-commit
description: Use when writing a commit message or preparing a git commit. Covers conventional commit format, message structure, prose quality, and mandatory user review before committing. Pair with github-workflow for branch naming and PR conventions.
---

# Git Commit Conventions

## Format

```
<type>(<scope>): <short description>

<body explaining what and why>

<optional footer>
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Scope is optional. When used, it names the module or area changed: `feat(parser):`, `fix(auth):`.

The short description is imperative mood, lowercase, no trailing period: "add retry logic", not "Added retry logic."

## Body

The body explains *what* changed and *why*, not *how*. Wrap at 72 characters. Use a blank line between the subject and body.

For multi-point changes, use a plain list:

```
feat: add --json flag and exit codes to sync status command

Add machine-readable output for CI/CD workflows:

- Add --json flag for structured JSON output
- Exit code 0 when up to date
- Exit code 1 when changes detected
- Exit code 2 on error
```

## Forbidden content

Never add AI attribution to commits:

- No "Generated with Claude Code"
- No "Co-Authored-By: Claude" or any AI co-author line
- No footer indicating AI assistance
- No robot emoji taglines

Commits contain only: type, description, optional body, and optional footers (`Ref:`, `Fixes:`). No `Signed-off-by` lines.

## Prose quality

Before presenting the commit message, invoke `prose-lint` on the message body to catch AI tells. If the body reads like AI-generated text, invoke `humanizer` to rewrite it. Short single-line commits without a body skip this step.

## User review

Always present the full commit message to the user before committing. Show the exact text that will be committed. Do not commit without explicit user approval. Do not batch multiple commits without individual review of each message.

## Validation

If the project has a `.commitlintrc`, `.commitlintrc.js`, `.commitlintrc.json`, or `commitlint.config.js`, run commitlint after committing to verify the message format:

```bash
npx commitlint --edit
```

If commitlint fails, amend the message and re-validate. Do not skip this step or ask whether to run it.

If no commitlint config exists in the project, skip validation silently.
