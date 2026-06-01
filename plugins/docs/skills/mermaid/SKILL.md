---
name: mermaid
description: Use when asked to view, render, preview, export, or open a Mermaid diagram; when working with .mmd files; or when Markdown contains Mermaid code blocks. Render the diagram with mermaid-view and report the output path.
---

# Mermaid Diagram Viewer

Render a Mermaid diagram and open it in the browser.

## Usage

1. Identify the file (from `$ARGUMENTS` or the most recently discussed `.mmd` or mermaid-containing `.md` file)
2. Run: `mermaid-view <file-path>`
3. Report the output path and confirm it opened

Options: `--theme dark|default|forest|neutral`, `--format png|svg|pdf`

## Requirements

- `@mermaid-js/mermaid-cli` (`brew install mermaid-cli` — provides `mmdc`)
- Google Chrome (used by mmdc for rendering)
