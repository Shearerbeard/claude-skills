#!/usr/bin/env python3
"""Shared Agent Skills frontmatter validator.

Single source of truth for the SKILL.md frontmatter limits defined by the
Agent Skills spec (agentskills.io/specification) and enforced by OpenCode.
Both install-skills (install-time gate) and check-skills (standalone gate)
call this so the two cannot drift apart -- that drift is exactly what let a
skill pass install-skills while violating a limit check-skills knew about.

Scope is spec compliance only, because install-skills also installs
third-party marketplaces: repo-specific authoring lints (magic-trigger
wording, cross-skill references) stay in check-skills.

Usage: _check-frontmatter.py <plugins-dir>
Exit 0 on success (warnings still exit 0), 1 on any error. Errors and
warnings go to stderr; a one-line summary goes to stdout.
"""
import pathlib
import re
import sys

import yaml

# Agent Skills spec frontmatter fields.
SPEC_FIELDS = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
# Non-spec fields honored by Claude Code and knowingly ignored by OpenCode.
CLAUDE_FIELDS = {"when_to_use", "disable-model-invocation"}
KNOWN_FIELDS = SPEC_FIELDS | CLAUDE_FIELDS

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def main():
    if len(sys.argv) != 2:
        sys.stderr.write("usage: _check-frontmatter.py <plugins-dir>\n")
        return 2

    root = pathlib.Path(sys.argv[1])
    errors = []
    warnings = []
    count = 0

    for path in sorted(root.glob("*/skills/*/SKILL.md")):
        count += 1
        text = path.read_text()
        if not text.startswith("---\n"):
            errors.append(f"{path}: missing YAML frontmatter")
            continue
        end = text.find("\n---", 4)
        if end == -1:
            errors.append(f"{path}: missing YAML frontmatter terminator")
            continue
        try:
            data = yaml.safe_load(text[4:end]) or {}
        except yaml.YAMLError as exc:
            errors.append(f"{path}: invalid YAML in frontmatter: {exc}")
            continue

        skill_dir = path.parent.name
        name = data.get("name")
        if not name:
            errors.append(f"{path}: missing name")
        else:
            name = str(name)
            if name != skill_dir:
                errors.append(f"{path}: name {name!r} does not match directory {skill_dir!r}")
            if len(name) > 64:
                errors.append(f"{path}: name is {len(name)} chars; spec allows 64")
            if not NAME_RE.match(name):
                errors.append(
                    f"{path}: name {name!r} must be lowercase alphanumeric and hyphens "
                    "with no leading, trailing, or consecutive hyphen"
                )

        description = str(data.get("description") or "")
        if not description.strip():
            errors.append(f"{path}: missing description")
        elif len(description) > 1024:
            errors.append(f"{path}: description is {len(description)} chars; OpenCode allows 1024")

        compatibility = data.get("compatibility")
        if compatibility is not None and len(str(compatibility)) > 500:
            errors.append(f"{path}: compatibility is {len(str(compatibility))} chars; spec allows 500")

        for key in data:
            if key not in KNOWN_FIELDS:
                warnings.append(f"{path}: unknown frontmatter key {key!r} (not in Agent Skills spec)")

    for warning in warnings:
        sys.stderr.write(f"warning: {warning}\n")
    if errors:
        sys.stderr.write("frontmatter validation failed:\n  " + "\n  ".join(errors) + "\n")
        return 1

    print(f"frontmatter OK: {count} skills")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
