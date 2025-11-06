# Quick Start - 5 Minutes

## 1. Install to Current Project (All Skills)

```bash
cd /path/to/your-rust-project
~/dev/claude-skills/install-to-project.sh --all
```

## 2. Test It

```bash
claude
/standards
exit
```

## 3. Commit to Git

```bash
git add .claude/ docs/ ADR/ TODO.md ARCHITECTURE.md
git commit -m "Add Claude Code skills"
```

---

## A La Carte Installation

### Quality Skills Only
```bash
~/dev/claude-skills/install-to-project.sh --quality-only
```
Installs: `/standards`, `/docs`, `/tests`, `/perf`, `/review`

### Documentation Skills Only
```bash
~/dev/claude-skills/install-to-project.sh --docs-only
```
Installs: `/consolidate`, `/docs-check`, `/log-session`

### Specific Skills
```bash
~/dev/claude-skills/install-to-project.sh --skills="standards,review,consolidate"
```
Installs only the skills you specify.

---

## Update Existing Installation

```bash
cd /path/to/your-project
~/dev/claude-skills/install-to-project.sh --update
```

This updates skills but preserves your customized guidelines.

---

## Usage Examples

### During Development (Every 30 minutes)
```bash
claude
/standards   # Quick safety check
exit
```

### Before Committing
```bash
git add .
claude
/review      # Comprehensive quality check
exit
# Fix issues, then commit
git commit -m "Your message"
```

### Weekly Maintenance
```bash
claude
/consolidate # Clean up scattered docs
exit
```

### End of Session
```bash
claude
/log-session # Create session log from git activity
exit
```

---

## Multi-Project Workflow

### Install to Multiple Projects

**Project A (full install):**
```bash
cd ~/workspace/web-app
~/dev/claude-skills/install-to-project.sh --all
```

**Project B (quality only):**
```bash
cd ~/workspace/cli-tool
~/dev/claude-skills/install-to-project.sh --quality-only
```

**Project C (minimal):**
```bash
cd ~/workspace/library
~/dev/claude-skills/install-to-project.sh --skills="standards,review"
```

### Update All Projects

```bash
# Update the skills library first
cd ~/dev/claude-skills
git pull  # If tracking remote updates

# Update each project
for project in ~/workspace/*/; do
  if [ -d "$project/.claude/skills" ]; then
    echo "Updating $project"
    ~/dev/claude-skills/install-to-project.sh --update --path="$project"
  fi
done
```

---

## Customization Per Project

After installation, customize guidelines for each project:

```bash
cd your-project
vim .claude/guidelines/project-standards.md
```

Skills stay the same (updated from library), guidelines are project-specific.

---

## Troubleshooting

### "Permission denied" when running install script
```bash
chmod +x ~/dev/claude-skills/install-to-project.sh
```

### "Already installed" error
```bash
# Update existing installation
~/dev/claude-skills/install-to-project.sh --update

# Or force reinstall
~/dev/claude-skills/install-to-project.sh --force
```

### See what would be installed
```bash
~/dev/claude-skills/install-to-project.sh --dry-run
```

---

For more details, see `README.md` in `~/dev/claude-skills/`
