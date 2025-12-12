---
name: claudefile-audit
description: Audit CLAUDE.md and .claude/ structure against best practices. Use when bootstrapping new projects, reviewing project setup, or when user mentions "audit claudefile", "check CLAUDE.md", "bootstrap project", or "project setup". Validates structure, references, and standards compliance.
---

# CLAUDE.md Audit

Audit project's CLAUDE.md and .claude/ directory against Claude Code best practices.

## When to Use

- Bootstrapping a new project with Claude Code
- Reviewing existing project setup for improvements
- Before onboarding team members
- After major project restructuring

## Step 1: Select Audit Mode

```json
{
  "questions": [
    {
      "question": "What type of audit do you need?",
      "header": "Mode",
      "multiSelect": false,
      "options": [
        {"label": "Full audit", "description": "Complete structure, content, and reference validation"},
        {"label": "Quick check", "description": "Verify essential sections exist and basic structure"},
        {"label": "Bootstrap", "description": "Generate recommendations for missing components"},
        {"label": "Diff review", "description": "Check recent changes to CLAUDE.md"}
      ]
    }
  ]
}
```

## Step 2: Locate Files

```bash
# Find CLAUDE.md (can be at root or in .claude/)
ls -la CLAUDE.md .claude/CLAUDE.md 2>/dev/null

# Check .claude directory structure
ls -la .claude/ 2>/dev/null
ls -la .claude/guidelines/ 2>/dev/null
ls -la .claude/skills/ 2>/dev/null
ls -la .claude/rules/ 2>/dev/null
```

## Step 3: Validate Structure

### Required CLAUDE.md Sections

Check for these essential sections (per official Claude Code guidance):

1. **Overview/Description** - WHAT the project does
2. **Quick Start** - HOW to build/run/test
3. **Project Structure** - Directory layout explanation
4. **Environment Setup** - Required env vars and configuration
5. **Architecture** - Key design patterns and dependencies

### Recommended Sections

6. **Current Status** - Project phase (alpha, beta, production)
7. **Key Features** - Organized feature list
8. **CI/CD** - Build and deployment process
9. **Documentation** - Where to find detailed docs

### Anti-patterns to Flag

```bash
# Check CLAUDE.md size (should be focused, not exhaustive)
wc -l CLAUDE.md

# Check for code style rules (should use linters, not CLAUDE.md)
grep -i "indent\|spacing\|braces\|semicolon" CLAUDE.md

# Check for inline code examples (should reference files with @)
grep -c '```' CLAUDE.md
```

## Step 4: Validate .claude/ Directory

### Proper Structure

```
.claude/
├── CLAUDE.md          # (optional) Alternative location
├── CLAUDE.local.md    # (optional) Personal preferences (gitignored)
├── guidelines/        # Team guidelines (checked into git)
│   ├── project-standards.md
│   ├── type-driven-design.md
│   └── ...
├── skills/            # Model-invoked capabilities
│   ├── pre-commit.md
│   ├── test-coverage.md
│   └── ...
└── rules/             # (optional) Modular rules with path filtering
    ├── rust.md        # paths: **/*.rs
    └── api.md         # paths: src/api/**
```

### Check for Common Issues

```bash
# Orphaned files (not referenced anywhere)
find .claude -name "*.md" -type f

# Check guidelines are referenced in skills
grep -l "guidelines/" .claude/skills/*.md 2>/dev/null

# Check for path-specific rules frontmatter
grep -l "^paths:" .claude/rules/*.md 2>/dev/null
```

## Step 5: Rust Project Specifics

For Rust projects, verify these are documented or referenced:

### Error Handling Standards
- [ ] Document `anyhow` vs `thiserror` usage
- [ ] Reference error handling guidelines
- [ ] Custom error types documented

### Type-Driven Design
- [ ] Reference type safety guidelines
- [ ] Document domain modeling approach
- [ ] ADT patterns explained (if used)

### Build/Test Commands
- [ ] `cargo build` / `cargo build --release`
- [ ] `cargo test` with any specific flags
- [ ] `cargo clippy` requirements
- [ ] `cargo fmt` expectations

### Environment
- [ ] Required env vars for build
- [ ] Runtime configuration options
- [ ] Feature flags documented

## Step 6: Cross-Reference Validation

```bash
# Check all referenced files exist
# Extract @references from CLAUDE.md
grep -o '@[a-zA-Z0-9_/.-]*' CLAUDE.md | while read ref; do
  file="${ref#@}"
  [ ! -f "$file" ] && echo "Missing: $file"
done

# Check doc links are valid
grep -oE '\[.*\]\([^)]+\)' CLAUDE.md | grep -oE '\([^)]+\)' | tr -d '()' | while read link; do
  [[ "$link" != http* ]] && [ ! -f "$link" ] && echo "Broken link: $link"
done
```

## Step 7: Output Report

```
CLAUDEFILE AUDIT

Project: [name from CLAUDE.md or directory]
Location: [path]
Mode: [Full audit | Quick check | Bootstrap | Diff review]

STRUCTURE [X/Y sections present]

Required:
  [OK] Overview - Clear project description
  [OK] Quick Start - Build/run/test commands present
  [MISSING] Project Structure - No directory explanation
  [OK] Environment Setup - 3 env vars documented
  [PARTIAL] Architecture - Mentions patterns but no detail

Recommended:
  [OK] Current Status
  [OK] Key Features
  [MISSING] CI/CD
  [OK] Documentation links

SIZE & FOCUS

Lines: 156 (OK - under 500)
Code blocks: 3 (OK - minimal)
Style rules found: 0 (OK - using linters)

.claude/ DIRECTORY [X/Y components]

  [OK] guidelines/ - 3 files
       - project-standards.md
       - type-driven-design.md
       - project-documentation-standards.md
  [OK] skills/ - 8 files
       - pre-commit.md, test-coverage.md, ...
  [MISSING] rules/ - Consider for path-specific guidelines

RUST PROJECT STANDARDS

  [OK] Error handling: References anyhow/thiserror usage
  [OK] Type safety: References type-driven-design guideline
  [OK] Build commands: cargo build, test, clippy documented
  [PARTIAL] Environment: Missing AWS_REGION in setup section

CROSS-REFERENCES

  [OK] All @references resolve to existing files
  [WARN] docs/architecture-decisions.md referenced but not found
  [OK] All internal links valid

RECOMMENDATIONS

1. [P1] Add "Project Structure" section explaining:
   - crates/ directory layout
   - Key module responsibilities
   - Where to find specific functionality

2. [P2] Create .claude/rules/rust.md with:
   ---
   paths: **/*.rs
   ---
   Rust-specific guidelines here

3. [P3] Add CI/CD section documenting:
   - Pre-commit requirements
   - CI pipeline stages
   - Deployment process

BOOTSTRAP ADDITIONS (if Bootstrap mode)

To fully bootstrap this project, create:

1. .claude/guidelines/project-standards.md
   Copy from: ~/dev/claude-skills/guidelines/project-standards.md

2. .claude/guidelines/type-driven-design.md
   Copy from: ~/dev/claude-skills/guidelines/type-driven-design.md

3. .claude/skills/pre-commit.md
   Copy from: ~/dev/claude-skills/skills/pre-commit.md

Run: cp -r ~/dev/claude-skills/{guidelines,skills} .claude/

SUMMARY

Score: 7/10
Status: [HEALTHY | NEEDS WORK | MISSING ESSENTIALS]

Required actions: 1
Recommended improvements: 2
Optional enhancements: 1
```

## Best Practices Reference

### CLAUDE.md Content (Official Guidance)

**DO include:**
- Project overview (WHAT, WHY)
- Build/test/run commands (HOW)
- Project structure for navigation
- Environment requirements
- Architecture patterns used
- Links to detailed documentation

**DON'T include:**
- Code style rules (use linters: clippy, rustfmt)
- Exhaustive API documentation (use rustdoc)
- Long code examples (use @references)
- Historical changelog (use CHANGELOG.md)

### Size Guidelines

- CLAUDE.md: < 500 lines ideal, < 1000 max
- Guidelines: Focused, single-topic files
- Skills: < 200 lines each
- Rules: Short, specific, use path filtering

### References

- [Claude Code Memory Guide](https://code.claude.com/docs/en/memory.md)
- [Claude Code Skills Guide](https://code.claude.com/docs/en/skills.md)
- [Using CLAUDE.md Files](https://claude.com/blog/using-claude-md-files)

---

**Use /bootstrap to generate missing components after audit.**
