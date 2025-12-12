#!/bin/bash
# install-to-project.sh - Install Claude Code skills to a project
#
# Usage:
#   cd your-project && ~/dev/claude-skills/install-to-project.sh
#   ~/dev/claude-skills/install-to-project.sh --path=/path/to/project
#   ~/dev/claude-skills/install-to-project.sh --quality-only
#   ~/dev/claude-skills/install-to-project.sh --skills="code-safety,pre-commit,docs-consolidate"
#   ~/dev/claude-skills/install-to-project.sh --update
#
# Options:
#   --all             Install all skills (default)
#   --quality-only    Install only quality skills (code-safety, type-check, test-coverage, etc.)
#   --docs-only       Install only documentation skills (docs-consolidate, docs-audit, log-session)
#   --skills=LIST     Install specific skills (comma-separated)
#   --update          Update existing installation (preserve customizations)
#   --force           Force reinstall (overwrite customizations)
#   --dry-run         Show what would be installed
#   --path=PATH       Install to specific path (default: current directory)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_LIB="$SCRIPT_DIR"

# Default options
INSTALL_MODE="all"
UPDATE_MODE=false
FORCE_MODE=false
DRY_RUN=false
TARGET_DIR="$(pwd)"

# Skill categories (updated names)
QUALITY_SKILLS=("code-safety" "type-check" "test-coverage" "perf-scan" "pre-commit" "async-check")
DOCS_SKILLS=("docs-consolidate" "docs-audit" "log-session" "plan-session")
SETUP_SKILLS=("claudefile-audit" "bootstrap")
ALL_SKILLS=("${QUALITY_SKILLS[@]}" "${DOCS_SKILLS[@]}" "${SETUP_SKILLS[@]}")
SELECTED_SKILLS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_MODE="all"
            shift
            ;;
        --quality-only)
            INSTALL_MODE="quality"
            shift
            ;;
        --docs-only)
            INSTALL_MODE="docs"
            shift
            ;;
        --setup-only)
            INSTALL_MODE="setup"
            shift
            ;;
        --skills=*)
            INSTALL_MODE="custom"
            IFS=',' read -ra SELECTED_SKILLS <<< "${1#*=}"
            shift
            ;;
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --force)
            FORCE_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --path=*)
            TARGET_DIR="${1#*=}"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--all|--quality-only|--docs-only|--setup-only|--skills=LIST] [--update] [--dry-run] [--path=PATH]"
            exit 1
            ;;
    esac
done

# Determine which skills to install
case $INSTALL_MODE in
    all)
        SKILLS_TO_INSTALL=("${ALL_SKILLS[@]}")
        ;;
    quality)
        SKILLS_TO_INSTALL=("${QUALITY_SKILLS[@]}")
        ;;
    docs)
        SKILLS_TO_INSTALL=("${DOCS_SKILLS[@]}")
        ;;
    setup)
        SKILLS_TO_INSTALL=("${SETUP_SKILLS[@]}")
        ;;
    custom)
        SKILLS_TO_INSTALL=("${SELECTED_SKILLS[@]}")
        ;;
esac

# Header
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}    Claude Code Skills - Project Installation${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Validate target directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET_DIR${NC}"
    exit 1
fi

cd "$TARGET_DIR"
echo -e "Target project: ${GREEN}$TARGET_DIR${NC}"
echo -e "Skills library: ${BLUE}$SKILLS_LIB${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN MODE - No files will be modified${NC}"
    echo ""
fi

# Check if already installed
if [[ -d ".claude/skills" ]] && [[ "$UPDATE_MODE" == false ]] && [[ "$FORCE_MODE" == false ]]; then
    echo -e "${YELLOW}[WARN] Claude skills already installed in this project!${NC}"
    echo ""
    echo "Options:"
    echo "  1. Run with --update to update skills (preserves customizations)"
    echo "  2. Run with --force to reinstall (overwrites customizations)"
    echo ""
    exit 1
fi

# Display installation plan
echo -e "${GREEN}Installation Plan:${NC}"
echo ""
echo "Skills to install (${#SKILLS_TO_INSTALL[@]}):"
for skill in "${SKILLS_TO_INSTALL[@]}"; do
    # Handle log-session directory specially
    if [[ "$skill" == "log-session" ]]; then
        if [[ -d "$SKILLS_LIB/skills/log-session" ]]; then
            echo -e "  [OK] /log-session (directory)"
        else
            echo -e "  ${RED}[MISSING] /log-session${NC}"
        fi
    elif [[ -f "$SKILLS_LIB/skills/${skill}.md" ]]; then
        echo -e "  [OK] /${skill}"
    else
        echo -e "  ${RED}[MISSING] /${skill}${NC}"
    fi
done
echo ""

if [[ "$UPDATE_MODE" == true ]]; then
    echo -e "${YELLOW}Update mode:${NC} Customizations in .claude/guidelines/ will be preserved"
    echo ""
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${BLUE}Dry run complete. Exiting.${NC}"
    exit 0
fi

# Confirm installation
if [[ "$UPDATE_MODE" == false ]] && [[ "$FORCE_MODE" == false ]]; then
    read -p "Proceed with installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Step 1: Create directory structure
echo -e "${GREEN}[1/5] Creating directory structure...${NC}"
mkdir -p .claude/skills
mkdir -p .claude/guidelines
mkdir -p .claude/templates
mkdir -p docs/internal/sessions
mkdir -p docs/internal/planning
mkdir -p docs/internal/research
mkdir -p docs/archive/$(date +%Y)
echo -e "  [OK] Directories created"

# Step 2: Install skills
echo -e "${GREEN}[2/5] Installing skills...${NC}"
INSTALLED_COUNT=0
for skill in "${SKILLS_TO_INSTALL[@]}"; do
    # Handle log-session directory specially
    if [[ "$skill" == "log-session" ]]; then
        if [[ -d "$SKILLS_LIB/skills/log-session" ]]; then
            cp -r "$SKILLS_LIB/skills/log-session" ".claude/skills/"
            echo -e "  [OK] Installed: /log-session (directory)"
            ((INSTALLED_COUNT++))
        else
            echo -e "  ${YELLOW}[SKIP] log-session (not found)${NC}"
        fi
    else
        src_file="$SKILLS_LIB/skills/${skill}.md"
        dst_file=".claude/skills/${skill}.md"

        if [[ -f "$src_file" ]]; then
            cp "$src_file" "$dst_file"
            echo -e "  [OK] Installed: /${skill}"
            ((INSTALLED_COUNT++))
        else
            echo -e "  ${YELLOW}[SKIP] ${skill} (not found in library)${NC}"
        fi
    fi
done
echo -e "  ${GREEN}Installed ${INSTALLED_COUNT}/${#SKILLS_TO_INSTALL[@]} skills${NC}"

# Step 3: Install templates
echo -e "${GREEN}[3/5] Installing templates...${NC}"
TEMPLATES_INSTALLED=0

if [[ -f "$SKILLS_LIB/templates/adr-template.md" ]]; then
    cp "$SKILLS_LIB/templates/adr-template.md" ".claude/templates/"
    echo -e "  [OK] Installed: adr-template.md"
    ((TEMPLATES_INSTALLED++))
fi

if [[ -f "$SKILLS_LIB/templates/session-template.md" ]]; then
    cp "$SKILLS_LIB/templates/session-template.md" ".claude/templates/"
    cp "$SKILLS_LIB/templates/session-template.md" "docs/internal/sessions/template.md"
    echo -e "  [OK] Installed: session-template.md"
    ((TEMPLATES_INSTALLED++))
fi

if [[ $TEMPLATES_INSTALLED -eq 0 ]]; then
    echo -e "  [SKIP] No templates found in library"
fi

# Step 4: Install guidelines (smart based on skill types)
echo -e "${GREEN}[4/5] Installing guidelines...${NC}"

# Determine which guidelines to install based on skills
NEED_CODE_STANDARDS=false
NEED_TYPE_DESIGN=false
NEED_DOC_STANDARDS=false

# Check skill categories
for skill in "${SKILLS_TO_INSTALL[@]}"; do
    if [[ " ${QUALITY_SKILLS[@]} " =~ " ${skill} " ]]; then
        NEED_CODE_STANDARDS=true
        # type-check needs type-driven-design guideline
        if [[ "$skill" == "type-check" ]]; then
            NEED_TYPE_DESIGN=true
        fi
    fi
    if [[ " ${DOCS_SKILLS[@]} " =~ " ${skill} " ]]; then
        NEED_DOC_STANDARDS=true
    fi
    if [[ " ${SETUP_SKILLS[@]} " =~ " ${skill} " ]]; then
        # Setup skills need all guidelines
        NEED_CODE_STANDARDS=true
        NEED_TYPE_DESIGN=true
        NEED_DOC_STANDARDS=true
    fi
done

# Install project-standards.md (for code-safety, test-coverage, perf-scan, pre-commit, async-check)
if [[ "$NEED_CODE_STANDARDS" == true ]]; then
    if [[ ! -f ".claude/guidelines/project-standards.md" ]] || [[ "$FORCE_MODE" == true ]]; then
        cp "$SKILLS_LIB/guidelines/project-standards.md" ".claude/guidelines/"
        echo -e "  [OK] Installed: project-standards.md (~15KB)"
    else
        echo -e "  [KEEP] project-standards.md (use --force to overwrite)"
    fi
fi

# Install type-driven-design.md (for type-check)
if [[ "$NEED_TYPE_DESIGN" == true ]]; then
    if [[ ! -f ".claude/guidelines/type-driven-design.md" ]] || [[ "$FORCE_MODE" == true ]]; then
        if [[ -f "$SKILLS_LIB/guidelines/type-driven-design.md" ]]; then
            cp "$SKILLS_LIB/guidelines/type-driven-design.md" ".claude/guidelines/"
            echo -e "  [OK] Installed: type-driven-design.md (~20KB)"
        fi
    else
        echo -e "  [KEEP] type-driven-design.md (use --force to overwrite)"
    fi
fi

# Install project-documentation-standards.md (for docs-consolidate, docs-audit, log-session, plan-session)
if [[ "$NEED_DOC_STANDARDS" == true ]]; then
    if [[ ! -f ".claude/guidelines/project-documentation-standards.md" ]] || [[ "$FORCE_MODE" == true ]]; then
        cp "$SKILLS_LIB/guidelines/project-documentation-standards.md" ".claude/guidelines/"
        echo -e "  [OK] Installed: project-documentation-standards.md (~14KB)"
    else
        echo -e "  [KEEP] project-documentation-standards.md (use --force to overwrite)"
    fi
fi

# Show what was skipped
if [[ "$NEED_CODE_STANDARDS" == false ]] && [[ "$NEED_DOC_STANDARDS" == false ]]; then
    echo -e "  [SKIP] No guidelines needed for selected skills"
fi

# Step 5: Create .claude/README.md
echo -e "${GREEN}[5/5] Creating documentation...${NC}"

cat > .claude/README.md << EOF
# Claude Code Skills

Installed from: ~/dev/claude-skills
Installation date: $(date +%Y-%m-%d)
Installation mode: $INSTALL_MODE

## Installed Skills

$(for skill in "${SKILLS_TO_INSTALL[@]}"; do
    if [[ -f ".claude/skills/${skill}.md" ]] || [[ -d ".claude/skills/${skill}" ]]; then
        echo "- /${skill}"
    fi
done)

## Skill Categories

**Quality Skills** (code review):
- /code-safety - Check unwrap, unsafe, error handling
- /type-check - Type-driven design patterns
- /test-coverage - Verify test coverage
- /perf-scan - Performance anti-patterns
- /pre-commit - Full quality review
- /async-check - Async/await pitfalls

**Documentation Skills**:
- /docs-consolidate - Clean up CLAUDE.md, organize docs
- /docs-audit - Check markdown consistency
- /log-session - Document session work
- /plan-session - Create planning/research docs

**Setup Skills**:
- /claudefile-audit - Audit project setup
- /bootstrap - Initialize new projects

## Usage

\`\`\`bash
# Start Claude Code and run a skill
claude
/pre-commit
exit

# Update skills from library
~/dev/claude-skills/install-to-project.sh --update
\`\`\`

## Guidelines

Guidelines are in \`.claude/guidelines/\`:
- \`project-standards.md\` - Rust code standards (error handling, safety, docs)
- \`type-driven-design.md\` - Type safety patterns (ADTs, newtypes)
- \`project-documentation-standards.md\` - Documentation organization

Customize these for your project. Use --force to reset to defaults.
EOF
echo -e "  [OK] Created: .claude/README.md"

# Summary
echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}Installation Complete${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo "Installed to: $TARGET_DIR"
echo "Skills installed: $INSTALLED_COUNT"
echo ""
echo "Next steps:"
echo ""
echo "1. Test the installation:"
echo "   cd $TARGET_DIR"
echo "   claude"
echo "   /pre-commit"
echo "   exit"
echo ""
echo "2. Customize guidelines (optional):"
echo "   vim .claude/guidelines/project-standards.md"
echo ""
echo "3. Add to git:"
echo "   git add .claude/ docs/"
echo "   git commit -m 'Add Claude Code skills'"
echo ""
echo "4. Update later:"
echo "   ~/dev/claude-skills/install-to-project.sh --update"
echo ""
echo -e "${BLUE}============================================================${NC}"
