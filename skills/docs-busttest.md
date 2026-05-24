---
name: docs-busttest
description: "Bus test" documentation review — ensures any repo's docs are good enough for a subject-matter-expert to pick up cold. Triggers when work is complete, docs are reviewed, documentation is updated, README changes, CLAUDE.md changes, or when asked to review/audit/update docs. Based on CNCF techdocs criteria and the Diataxis framework.
---

# Documentation Bus Test

Review a repo's documentation as if the maintainer disappeared tomorrow. Could a subject-matter expert — someone who knows the domain but not this specific project — pick it up, run it, and ship changes?

This is not a style guide. It checks whether the information exists and is findable.

## The Test

Score each section pass/fail. Report the count and any P1/P2 findings.

### 1. Orient (can they understand what this is?)

- [ ] **One-liner**: README opens with what it does in one sentence, no jargon
- [ ] **Quick start**: copy-pastable install + run, under 5 steps
- [ ] **Structure**: where code lives, key modules/crates/packages named
- [ ] **Architecture**: how components connect (diagram, prose, or both)

### 2. Operate (can they run it?)

- [ ] **Env setup**: all required env vars, keys, and dependencies listed
- [ ] **Build + test**: exact commands, not "run the tests"
- [ ] **Config**: what knobs exist, what they default to, where they live
- [ ] **Deploy**: how it gets to production (CI, Docker, Helm, manual — whatever applies)

### 3. Decide (can they understand why things are this way?)

- [ ] **Decision log**: ADRs, design docs, or a DECISIONS.md — anything explaining *why*
- [ ] **Constraints**: known limitations, tradeoffs, things that don't work
- [ ] **Changelog**: what changed and when (auto-generated or manual)

### 4. Contribute (can they change it safely?)

- [ ] **Dev workflow**: branch naming, commit conventions, PR process
- [ ] **Test strategy**: what's tested, how, what coverage looks like
- [ ] **CI/CD**: what runs on push/PR, how to read failures
- [ ] **Code quality**: linting, formatting, type checking commands

### 5. Content quality (is what exists trustworthy?)

- [ ] **No stale claims**: README says X, code does Y → P1 finding
- [ ] **No jargon walls**: internal labels, acronyms, or shorthand without definition
- [ ] **Dated or versioned**: reader can tell if docs are current

## Scoring

- **15-18 pass**: bus-test ready — a new contributor can be productive in a day
- **10-14 pass**: survivable — gaps will slow people down but won't block them
- **6-9 pass**: fragile — significant tribal knowledge not captured
- **Under 6**: bus factor is 1

## Severity

- **P1**: docs contradict code, or a required step is missing (blocks someone cold)
- **P2**: info exists but is hard to find, outdated, or scattered
- **P3**: nice-to-have improvements (better examples, diagrams, cross-links)

## Report Format

```
## Bus Test: <repo name>
Score: X/18 (<rating>)

### P1 (blocking)
- <file>: <what's wrong, one line>

### P2 (friction)
- <file>: <what's wrong, one line>

### P3 (polish)
- <file>: <suggestion, one line>

### Missing docs (by Diataxis quadrant)
- Tutorial: <exists/missing — guided learning path>
- How-to: <exists/missing — task recipes>
- Reference: <exists/missing — complete API/config surface>
- Explanation: <exists/missing — design rationale>
```

## After editing docs

- **Coherence check**: re-read the full document after edits. LLMs edit in diff-mode and produce sections that look good in isolation but create disjointed flow, repeated context, or contradictory statements when read end-to-end. The file must read as a coherent narrative, not a patchwork of additions.
- **Humanizer**: run `/humanizer` on the changed sections (not the whole file) to strip AI writing patterns before committing.

## References

- [CNCF TechDocs Analysis Criteria](https://github.com/cncf/techdocs/blob/main/docs/analysis/criteria.md)
- [Diataxis Framework](https://diataxis.fr/)
- [Good Docs Project Templates](https://thegooddocsproject.dev/template)
