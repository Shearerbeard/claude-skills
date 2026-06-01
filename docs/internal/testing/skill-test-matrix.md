# Skill Test Matrix

Use this checklist to compare Claude Code and OpenCode behavior after skill changes. These are behavioral probes, not deterministic unit tests. Record whether each tool auto-loads the expected skill, loads it after a nudge, works by manual invocation only, or misses.

## Scoring

- `auto`: the expected skill loads without naming it
- `nudge`: the expected skill loads after a natural hint such as "use the relevant skill"
- `manual`: direct slash/tool invocation works
- `miss`: the tool does not load or use the skill correctly

## Setup

- Use a fresh session for each tool.
- Open this repo in the branch/worktree under test.
- Install to OpenCode only after deterministic gates pass: `./bin/install-skills opencode`.
- For Claude Code, ensure all marketplace plugins are enabled: `python@my-skills`, `docs@my-skills`, `rust@my-skills`, and `workflow@my-skills`.
- Keep transcripts or notes under `docs/internal/testing/results/` when running a formal pass.

## Prompt Matrix

| Scenario | Prompt | Expected Skills | Claude Code | OpenCode | Notes |
|---|---|---|---|---|---|
| Rust review | `Review this Rust diff for issues before I commit.` | `gate-probes`, `rust-review`, `rust-quality` | | | |
| Python review | `Review this Python diff before I open a PR.` | `gate-probes`, `python-review`, `python-quality` | | | |
| Docs bus test | `I changed the README. Audit whether the docs pass the bus test.` | `docs-bustest` | | | |
| Prose lint file | `Run Vale/prose lint on the changed docs sections.` | `prose-lint` | | | |
| Prose lint snippet | `Vet this docstring for AI tells: "This docstring leverages a comprehensive framework to seamlessly enhance the developer experience."` | `prose-lint` | | | |
| Humanize outgoing prose | `Humanize this PR description before I post it: "This PR leverages a comprehensive solution..."` | `humanizer` | | | |
| Mermaid render | `Render the Mermaid diagram in this file.` | `mermaid` | | | |
| Planning preflight | `Plan this refactor before coding. Ask me what you need to know first.` | `plan-discipline` or manual fallback | | | |
| Commit gate | `I think this is ready to commit. Review the gate checks first.` | `gate-probes`, plus applicable review skills | | | |

## Prompt Notes

- Do not count plan-mode failure as a hard failure if manual `plan-discipline` works. Plan mode often shadows the skill.
- Do not expect official marketplace `/commit` commands to run prose lint. They restrict tool usage. Test prose lint through normal prompts or a future custom commit workflow.
- For OpenCode, verify skill discovery with the skill tool or the available skills list before scoring a miss.
