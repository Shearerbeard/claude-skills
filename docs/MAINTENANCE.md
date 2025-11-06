# Skills Library Maintenance Guide

## Architecture: Source of Truth

**Guidelines = WHAT (rules, principles)**
**Skills = HOW (implementation, checks)**

```
guidelines/project-standards.md
  ↓ defines rules
  ↓
skills/standards.md
  ↓ implements checks
  ↓ references guideline sections
```

## Guideline → Skill Mapping

| Guideline | Section | Checked By | How |
|-----------|---------|------------|-----|
| `project-standards.md` | Error Handling | `/standards` | grep unwrap/expect, clippy |
| `project-standards.md` | Unsafe Code | `/standards` | grep unsafe, check SAFETY comments |
| `project-standards.md` | Documentation | `/standards`, `/docs` | Check /// comments on pub items |
| `project-standards.md` | Testing | `/tests` | Check test coverage |
| `project-standards.md` | Performance | `/perf` | grep clone, string allocations |
| `project-documentation-standards.md` | CLAUDE.md size | `/consolidate` | wc -l CLAUDE.md |
| `project-documentation-standards.md` | Ephemeral docs | `/log-session` | Document lifecycle status |
| `project-documentation-standards.md` | Consistency | `/docs-check` | README vs CLAUDE.md claims |

## When to Update

### Updating Standards/Rules

**Scenario:** Adding new rule "No hardcoded secrets"

**Steps:**
1. Update guideline first:
   ```bash
   # Edit guidelines/project-standards.md
   # Add new section: "No Hardcoded Secrets"
   # Include: rationale, examples, references
   ```

2. Update implementing skill:
   ```bash
   # Edit skills/standards.md
   # Add check: grep for "const.*KEY\|const.*SECRET"
   # Add to output format
   # Add reference to new guideline section
   ```

3. Document the mapping:
   ```bash
   # Update this file (MAINTENANCE.md)
   # Add row to mapping table above
   ```

4. Test the change:
   ```bash
   claude
   /standards
   # Verify new check works
   ```

### Updating Skill Implementation

**Scenario:** Better way to detect unwrap()

**Steps:**
1. Update skill only:
   ```bash
   # Edit skills/standards.md
   # Change grep pattern or add ast-grep
   ```

2. No guideline update needed (rule didn't change, just HOW we check)

3. Test:
   ```bash
   claude
   /standards
   ```

### Updating Documentation Standards

**Scenario:** Change CLAUDE.md size limit from 500 to 400 lines

**Steps:**
1. Update guideline:
   ```bash
   # Edit guidelines/project-documentation-standards.md
   # Change all references: 500 → 400
   ```

2. Update implementing skills:
   ```bash
   # Edit skills/consolidate.md (checks CLAUDE.md size)
   # Update threshold: 500 → 400
   ```

3. Update templates:
   ```bash
   # Edit templates/CLAUDE-with-doc-standards.md
   # Update references: 500 → 400
   ```

4. Document:
   ```bash
   # Update this file
   # Update mapping table if needed
   ```

## Sync Checks

### Manual Verification

```bash
# 1. Check all guideline references in skills
grep -r "guidelines/" skills/

# 2. Check all standard sections are implemented
# (Manual review of mapping table above)

# 3. Check template references
grep -r "guidelines/" templates/
```

### LLM-Assisted Sync Check

Create this skill:

**`skills/sync-check.md`** (future enhancement):

```markdown
---
name: sync-check
description: Verify skills and guidelines are in sync
---

# Skills-Guidelines Sync Check

## Task

Verify that skills correctly implement and reference guidelines.

## Steps

1. Read all guidelines
2. Read all skills
3. Check cross-references:
   - Each skill references relevant guidelines
   - Each guideline section is checked by at least one skill
4. Report mismatches

## Output

✅ skills/standards.md correctly references project-standards.md
❌ project-standards.md section "Performance" not referenced by /perf skill
```

## Best Practices

### DO:
- ✅ Update guideline first (source of truth)
- ✅ Then update implementing skills
- ✅ Document mapping in this file
- ✅ Test changes with Claude Code
- ✅ Use LLM to help with updates
- ✅ Keep guidelines human-readable

### DON'T:
- ❌ Update skill without checking guideline
- ❌ Let guidelines and skills drift
- ❌ Embed all rules in skills (defeats single source of truth)
- ❌ Make guidelines machine-only readable

## LLM Maintenance Workflow

**Prompt for adding new standard:**

```
I want to add a new code standard: "No hardcoded secrets in source code"

Please:
1. Add section to guidelines/project-standards.md with:
   - Rule description
   - Good/bad examples
   - Rationale
   - When it applies

2. Update skills/standards.md to check for this:
   - Add grep pattern for const.*KEY|SECRET|PASSWORD
   - Add to output format
   - Add reference to new guideline section

3. Update docs/MAINTENANCE.md mapping table

4. Show me the changes before committing
```

**Prompt for syncing:**

```
Review guidelines/project-standards.md and skills/standards.md
for consistency. Check:

1. Does /standards skill check all rules in the guideline?
2. Are all references up to date?
3. Are there rules in the guideline not implemented in skill?
4. Are there checks in skill not documented in guideline?

Report discrepancies and suggest fixes.
```

## Versioning

When making breaking changes to guidelines:

```bash
# Before: project-standards.md has rule "No unwrap()"
# After: Change to "Minimal unwrap() with justification"

# 1. Document the change
git commit -m "breaking: relax unwrap() rule to allow justified cases

BREAKING CHANGE: unwrap() now allowed with JUSTIFICATION comment

See guidelines/project-standards.md section 1 for new rule."

# 2. Update CHANGELOG
# (semantic-release will auto-generate if using conventional commits)
```

## Future Enhancements

1. **Automated sync check** - CI/CD step to verify guidelines↔skills alignment
2. **Guideline versioning** - Track when rules change
3. **Skill test suite** - Verify skills correctly implement guidelines
4. **Cross-project standards** - Share guidelines across related projects

---

**Maintenance is easiest with LLM assistance + clear structure.**

Update guidelines first, then skills. Document mappings. Test changes.
