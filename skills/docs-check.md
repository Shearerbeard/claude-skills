---
name: docs-check
description: Check documentation consistency between internal and external docs
---

# Documentation Consistency Check

## Task
Verify consistency between internal developer docs and external public API documentation.

## Documentation Categories

### External Documentation (Public API)
**Files:** `README.md`, `docs/*.md`, doc comments in code (`///`)
**Audience:** Library users, external developers
**Focus:** Public APIs, usage examples, guarantees

### Internal Documentation (Development)
**Files:** `CLAUDE.md`, `docs/internal/*.md`, `ARCHITECTURE.md`, `ADR/`
**Audience:** Project developers, maintainers
**Focus:** Architecture, decisions, TODOs, implementation details

## Steps

1. **Read all documentation files:**
```bash
# External docs
find . -name "README.md" -o -name "CONTRIBUTING.md"
find docs -name "*.md" -not -path "*/internal/*" 2>/dev/null

# Internal docs
cat CLAUDE.md
find docs/internal -name "*.md" 2>/dev/null
find ADR -name "*.md" 2>/dev/null
```

2. **Check for inconsistencies:**

   **A. Public API Documentation vs Code**
   - Are all public functions documented in code?
   - Does README show current API signatures?
   - Are examples in docs still valid?
   
   **B. Internal vs External Claims**
   - Does README claim features that aren't implemented?
   - Are TODOs in CLAUDE.md contradicting README claims?
   - Are deprecated features still shown in examples?
   
   **C. Version Consistency**
   - Is CHANGELOG.md up to date with Cargo.toml version?
   - Do examples reference correct dependency versions?
   
   **D. Architectural Documentation**
   - Does CLAUDE.md architecture match actual code structure?
   - Are ADRs referenced in code comments?
   - Are design decisions documented?

3. **Check doc comments:**
```bash
# Find public items without doc comments
rg "pub (fn|struct|enum|trait)" src/ --no-heading
```

4. **Output format:**
```
📚 DOCUMENTATION CONSISTENCY CHECK

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 CRITICAL INCONSISTENCIES

1. README.md claims "Full async support" but:
   - src/lib.rs:45 - `sync_only()` is the only public API
   - TODO in CLAUDE.md says "Add async support"
   Fix: Either implement async or update README

2. Example in README uses deprecated API:
   - README.md:67 shows `old_function()`
   - Deprecated in v0.3.0 (see CHANGELOG.md)
   Fix: Update example to use `new_function()`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  DOCUMENTATION GAPS

Internal Documentation (for developers):
- src/parser.rs - Complex parsing logic undocumented
  Add: Explain parsing algorithm in ARCHITECTURE.md
  
- Database schema changes not recorded
  Add: Create ADR for schema migration strategy

External Documentation (for users):
- README missing error handling guidance
  Add: Section on error types and handling patterns
  
- Missing examples for advanced use cases
  Add: docs/advanced-usage.md with real-world examples

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ DOCUMENTATION HEALTH

Good practices found:
- All public APIs have doc comments with examples
- CHANGELOG.md up to date
- ADR-003 properly referenced in auth.rs
- Internal complexity documented in CLAUDE.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 METRICS

Public API Documentation Coverage:   12/15 items (80%)
Internal Architecture Docs:          Present
ADRs for major decisions:            3 recorded
Changelog entries this version:      5 entries
External examples validity:          2 broken, 8 working

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 RECOMMENDED ACTIONS

Priority 1 (Fix Today):
1. Remove or implement async claims in README
2. Update deprecated API examples

Priority 2 (This Week):
3. Document parser algorithm
4. Add error handling guide to README

Priority 3 (Nice to Have):
5. Add advanced usage examples
6. Create ADR template for future decisions
```

## Specific Checks

### Internal vs External Documentation Rules

**Internal docs can mention:**
- TODOs and future plans
- Known limitations and tech debt
- Implementation complexity
- Development workflows
- Architecture decisions

**External docs should only mention:**
- Currently available features
- Stable public APIs
- Supported use cases
- Migration guides for deprecated features
- Clear limitations (not as TODOs)

### Red Flags to Report

1. **Feature claims without implementation**
   ```
   ❌ README: "Supports real-time streaming"
   ❌ CLAUDE.md: "TODO: Implement streaming"
   ```

2. **Outdated examples**
   ```
   ❌ README shows: config.load()
   ❌ Code has: Config::from_file()
   ```

3. **Missing migration guides**
   ```
   ⚠️ CHANGELOG: "Breaking: Changed API"
   ❌ README: No migration guide provided
   ```

4. **Undocumented complexity**
   ```
   ⚠️ Complex algorithm in src/core.rs
   ❌ No explanation in ARCHITECTURE.md or comments
   ```

5. **Inconsistent terminology**
   ```
   ⚠️ README calls it "session"
   ⚠️ Code calls it "connection"
   ⚠️ Docs call it "context"
   ```

## Best Practices to Recommend

1. **Public API docs belong in code:**
   ```rust
   /// Brief description under 15 words.
   ///
   /// # Examples
   /// ```
   /// let result = my_function(input)?;
   /// ```
   pub fn my_function() { }
   ```

2. **Architecture belongs in ARCHITECTURE.md:**
   - High-level system design
   - Component interactions
   - Key algorithms
   - Performance characteristics

3. **Decisions belong in ADRs:**
   - Why we chose technology X
   - Tradeoffs considered
   - Alternative approaches rejected

4. **TODOs belong in TODO.md or GitHub Issues:**
   - Not scattered in CLAUDE.md
   - Not in code comments (unless very local)

5. **Changes belong in CHANGELOG.md:**
   - Following Keep a Changelog format
   - Grouped by type (Added, Changed, Fixed)

**Be specific about which file needs which update. Show exact diffs when possible.**
