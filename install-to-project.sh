#!/bin/bash
# install-to-project.sh - Install Claude Code skills to a project
#
# Usage:
#   cd your-project && ~/dev/claude-skills/install-to-project.sh
#   ~/dev/claude-skills/install-to-project.sh --path=/path/to/project
#   ~/dev/claude-skills/install-to-project.sh --quality-only
#   ~/dev/claude-skills/install-to-project.sh --skills="standards,review,consolidate"
#   ~/dev/claude-skills/install-to-project.sh --update
#
# Options:
#   --all             Install all skills (default)
#   --quality-only    Install only quality skills (standards, docs, tests, perf, review)
#   --docs-only       Install only documentation skills (consolidate, docs-check, log-session)
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

# Skill categories
QUALITY_SKILLS=("standards" "docs" "tests" "perf" "review")
DOCS_SKILLS=("consolidate" "docs-check" "log-session")
ALL_SKILLS=("${QUALITY_SKILLS[@]}" "${DOCS_SKILLS[@]}")
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
            echo "Usage: $0 [--all|--quality-only|--docs-only|--skills=LIST] [--update] [--dry-run] [--path=PATH]"
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
    custom)
        SKILLS_TO_INSTALL=("${SELECTED_SKILLS[@]}")
        ;;
esac

# Header
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}    Claude Code Skills - Project Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
    echo -e "${YELLOW}⚠️  Claude skills already installed in this project!${NC}"
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
    if [[ -f "$SKILLS_LIB/skills/${skill}.md" ]]; then
        echo -e "  ✓ ${skill}"
    else
        echo -e "  ${RED}✗ ${skill} (not found)${NC}"
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
mkdir -p docs/archive/$(date +%Y)
mkdir -p ADR
mkdir -p scripts
echo -e "  ✓ Directories created"

# Step 2: Install skills
echo -e "${GREEN}[2/5] Installing skills...${NC}"
INSTALLED_COUNT=0
for skill in "${SKILLS_TO_INSTALL[@]}"; do
    src_file="$SKILLS_LIB/skills/${skill}.md"
    dst_file=".claude/skills/${skill}.md"

    if [[ -f "$src_file" ]]; then
        cp "$src_file" "$dst_file"
        echo -e "  ✓ Installed: /${skill}"
        ((INSTALLED_COUNT++))
    else
        echo -e "  ${YELLOW}⚠️  Skipped: ${skill} (not found in library)${NC}"
    fi
done
echo -e "  ${GREEN}Installed ${INSTALLED_COUNT}/${#SKILLS_TO_INSTALL[@]} skills${NC}"

# Step 3: Install templates
echo -e "${GREEN}[3/5] Installing templates...${NC}"
if [[ -f "$SKILLS_LIB/templates/adr-template.md" ]]; then
    cp "$SKILLS_LIB/templates/adr-template.md" ".claude/templates/"
    cp "$SKILLS_LIB/templates/adr-template.md" "ADR/template.md"
    echo -e "  ✓ Installed: adr-template.md"
fi

if [[ -f "$SKILLS_LIB/templates/session-template.md" ]]; then
    cp "$SKILLS_LIB/templates/session-template.md" ".claude/templates/"
    cp "$SKILLS_LIB/templates/session-template.md" "docs/internal/sessions/template.md"
    echo -e "  ✓ Installed: session-template.md"
fi

# Step 4: Install guidelines (only if not exists or force mode)
echo -e "${GREEN}[4/5] Installing guidelines...${NC}"
if [[ ! -f ".claude/guidelines/project-standards.md" ]] || [[ "$FORCE_MODE" == true ]]; then
    cp "$SKILLS_LIB/guidelines/project-standards.md" ".claude/guidelines/"
    echo -e "  ✓ Installed: project-standards.md"
else
    echo -e "  ⤳ Preserved: project-standards.md (use --force to overwrite)"
fi

# Step 5: Create project files
echo -e "${GREEN}[5/5] Creating project files...${NC}"

# TODO.md
if [[ ! -f "TODO.md" ]]; then
    cat > TODO.md << 'EOF'
# TODO

Last updated: $(date +%Y-%m-%d)

## 🔥 High Priority


## 📋 Medium Priority


## 💡 Low Priority / Ideas


## ✅ Recently Completed

EOF
    echo -e "  ✓ Created: TODO.md"
else
    echo -e "  ⤳ Skipped: TODO.md (already exists)"
fi

# ARCHITECTURE.md
if [[ ! -f "ARCHITECTURE.md" ]]; then
    cat > ARCHITECTURE.md << 'EOF'
# Architecture

## Overview

High-level system design and component interactions.

## Components

### Core Components

(Describe your main components here)

## Data Flow

(How data moves through the system)

## Key Design Decisions

See ADR/ directory for detailed architecture decision records.
EOF
    echo -e "  ✓ Created: ARCHITECTURE.md"
else
    echo -e "  ⤳ Skipped: ARCHITECTURE.md (already exists)"
fi

# .claude/README.md
cat > .claude/README.md << EOF
# Claude Code Skills

Installed from: ~/dev/claude-skills
Installation date: $(date +%Y-%m-%d)
Installation mode: $INSTALL_MODE

## Installed Skills

$(for skill in "${SKILLS_TO_INSTALL[@]}"; do
    if [[ -f ".claude/skills/${skill}.md" ]]; then
        echo "- /${skill}"
    fi
done)

## Usage

\`\`\`bash
# Run a skill
claude
/${SKILLS_TO_INSTALL[0]}
exit

# Update skills from library
~/dev/claude-skills/install-to-project.sh --update
\`\`\`

## Customization

- Edit \`.claude/guidelines/project-standards.md\` for project-specific standards
- Skills are updated from central library, don't edit directly
EOF
echo -e "  ✓ Created: .claude/README.md"

# .gitignore additions
if [[ -f ".gitignore" ]]; then
    if ! grep -q "# Claude Code" ".gitignore"; then
        cat >> .gitignore << 'EOF'

# Claude Code temporary files
scripts/temp/
docs/internal/sessions/*.tmp.md
*.backup.*
EOF
        echo -e "  ✓ Updated: .gitignore"
    fi
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installed to: $TARGET_DIR"
echo "Skills installed: ${#SKILLS_TO_INSTALL[@]}"
echo ""
echo "Next steps:"
echo ""
echo "1. Test the installation:"
echo "   cd $TARGET_DIR"
echo "   claude"
echo "   /${SKILLS_TO_INSTALL[0]}"
echo "   exit"
echo ""
echo "2. Customize project standards:"
echo "   vim .claude/guidelines/project-standards.md"
echo ""
echo "3. Add to git:"
echo "   git add .claude/ docs/ ADR/ TODO.md ARCHITECTURE.md"
echo "   git commit -m 'Add Claude Code skills'"
echo ""
echo "4. Update later:"
echo "   ~/dev/claude-skills/install-to-project.sh --update"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
