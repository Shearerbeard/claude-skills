---
name: mermaid
description: Render and open Mermaid diagrams. Triggers when working with .mmd files, markdown files containing ```mermaid blocks, or when asked to view, render, or preview a diagram. Also invocable as /mermaid.
---

# Mermaid Diagram Viewer

Render a Mermaid diagram and open it in the browser.

## Usage

1. Identify the file (from `$ARGUMENTS` or the most recently discussed `.mmd` or mermaid-containing `.md` file)
2. Run: `scripts/mermaid-view <file-path>`
3. Report the output path and confirm it opened

Options: `--theme dark|default|forest|neutral`, `--format png|svg|pdf`

## Requirements

- `@mermaid-js/mermaid-cli` (`brew install mermaid-cli` — provides `mmdc`)
- Google Chrome (used by mmdc for rendering)
