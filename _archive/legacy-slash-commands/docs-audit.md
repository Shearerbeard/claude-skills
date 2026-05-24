---
name: docs-audit
description: Check documentation consistency between internal and external docs. Use when reviewing documentation, before releases, after major changes, or when user mentions "docs audit", "documentation check", "README accuracy", or "doc consistency". Can check full codebase or specific areas.
---

# Documentation Consistency Check

Verify consistency between internal developer docs and external public API documentation.

## Standards Reference

**Source:** `.claude/guidelines/project-documentation-standards.md`

Checks:
- Internal vs External documentation separation
- Feature claims vs implementation reality
- Documentation lifecycle compliance

## Step 1: Select Scope

```json
{
  "questions": [
    {
      "question": "What documentation scope should I check?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Full audit", "description": "Check all documentation files"},
        {"label": "External only", "description": "Check README, public docs, API docs"},
        {"label": "Internal only", "description": "Check CLAUDE.md, ADRs, internal docs"},
        {"label": "Specific file", "description": "I'll specify which file to check"}
      ]
    }
  ]
}
```

## Documentation Categories

### External Documentation (Public API)
**Files:** `README.md`, `docs/*.md` (not internal), doc comments (`///`)
**Audience:** Library users, external developers
**Focus:** Public APIs, usage examples, guarantees

### Internal Documentation (Development)
**Files:** `CLAUDE.md`, `docs/internal/*.md`, `ARCHITECTURE.md`, `ADR/`
**Audience:** Project developers, maintainers
**Focus:** Architecture, decisions, TODOs, implementation details

## Step 2: Read Documentation Files

```bash
# External docs
find . -name "README.md" -o -name "CONTRIBUTING.md"
find docs -name "*.md" -not -path "*/internal/*" 2>/dev/null

# Internal docs
cat CLAUDE.md
find docs/internal -name "*.md" 2>/dev/null
find ADR -name "*.md" 2>/dev/null
```

## Step 3: Check for Inconsistencies

### A. Public API Documentation vs Code
- Are all public functions documented in code?
- Does README show current API signatures?
- Are examples in docs still valid?

### B. Internal vs External Claims
- Does README claim features that aren't implemented?
- Are TODOs in CLAUDE.md contradicting README claims?
- Are deprecated features still shown in examples?

### C. Version Consistency
- Is CHANGELOG.md up to date with Cargo.toml version?
- Do examples reference correct dependency versions?

### D. Architectural Documentation
- Does CLAUDE.md architecture match actual code structure?
- Are ADRs referenced in code comments?

## Step 4: Check Doc Comments

```bash
# Find public items without doc comments
rg "pub (fn|struct|enum|trait)" src/ --no-heading
```

## Step 5: Output Format

```
DOCUMENTATION CONSISTENCY CHECK

Scope: [Full audit | External only | Internal only | file]

CRITICAL INCONSISTENCIES

[P1] README.md claims "Full async support" but:
  - src/lib.rs:45 - `sync_only()` is the only public API
  - TODO in CLAUDE.md says "Add async support"
  Fix: Either implement async or update README

[P1] Example in README uses deprecated API:
  - README.md:67 shows `old_function()`
  - Deprecated in v0.3.0 (see CHANGELOG.md)
  Fix: Update example to use `new_function()`

DOCUMENTATION GAPS

Internal Documentation (for developers):
[P2] src/parser.rs - Complex parsing logic undocumented
  Add: Explain parsing algorithm in ARCHITECTURE.md

[P2] Database schema changes not recorded
  Add: Create ADR for schema migration strategy

External Documentation (for users):
[P2] README missing error handling guidance
  Add: Section on error types and handling patterns

[P3] Missing examples for advanced use cases
  Add: docs/advanced-usage.md

GOOD PRACTICES FOUND

[OK] All public APIs have doc comments with examples
[OK] CHANGELOG.md up to date
[OK] ADR-003 properly referenced in auth.rs

METRICS

Public API Documentation Coverage:   12/15 items (80%)
Internal Architecture Docs:          Present
ADRs for major decisions:            3 recorded
External examples validity:          2 broken, 8 working

RECOMMENDED ACTIONS

Priority 1 (Fix Today):
1. Remove or implement async claims in README
2. Update deprecated API examples

Priority 2 (This Week):
3. Document parser algorithm
4. Add error handling guide to README

Priority 3 (Nice to Have):
5. Add advanced usage examples
```

If no issues:
```
DOCUMENTATION CONSISTENCY CHECK

Scope: [scope]

No documentation inconsistencies found.
All external claims match implementation.
```

## Step 6: Apply Automatic Fixes (Optional)

After reporting findings, offer to fix P1 and P2 issues automatically.

```json
{
  "questions": [
    {
      "question": "I found N fixable issues. Would you like me to apply automatic fixes?",
      "header": "Auto-fix",
      "multiSelect": false,
      "options": [
        {"label": "Yes, fix all", "description": "Apply all P1 and P2 fixes automatically"},
        {"label": "P1 only", "description": "Fix only critical issues"},
        {"label": "Show me first", "description": "Show proposed changes before applying"},
        {"label": "No", "description": "I'll fix manually"}
      ]
    }
  ]
}
```

### Fixable Issues (Safe for Automation)

**Can fix automatically:**
- Missing documentation sections (add, don't remove)
- Duplicate ADR numbers (renumber sequentially)
- Redundant template sections
- Broken internal doc links
- Version inconsistencies (use Cargo.toml as source)
- Missing feature documentation (add based on CLAUDE.md)

**Require manual review:**
- Feature claims without implementation (ambiguous)
- Deprecated API usage (depends on timeline)
- Complex architectural changes
- Public API breaking changes

### Safety Guidelines

1. **Only add, never remove** user-written content without confirmation
2. **Preserve formatting** - match existing markdown style
3. **Verify before/after** - show what changed in summary
4. **Ask for complex cases** - use AskUserQuestion for ambiguous situations

## Red Flags to Report

1. **Feature claims without implementation**
   ```
   [P1] README: "Supports real-time streaming"
        CLAUDE.md: "TODO: Implement streaming"
   ```

2. **Outdated examples**
   ```
   [P1] README shows: config.load()
        Code has: Config::from_file()
   ```

3. **Missing migration guides**
   ```
   [P2] CHANGELOG: "Breaking: Changed API"
        README: No migration guide provided
   ```

4. **Undocumented complexity**
   ```
   [P2] Complex algorithm in src/core.rs
        No explanation in ARCHITECTURE.md
   ```

5. **Inconsistent terminology**
   ```
   [P2] README calls it "session"
        Code calls it "connection"
        Docs call it "context"
   ```

## Documentation Rules

**Internal docs can mention:**
- TODOs and future plans
- Known limitations and tech debt
- Implementation complexity
- Development workflows

**External docs should only mention:**
- Currently available features
- Stable public APIs
- Supported use cases
- Clear limitations (not as TODOs)

---

**Focus:** Ensure external documentation accurately reflects current implementation.
