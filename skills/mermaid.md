---
name: mermaid
description: Render and open a Mermaid diagram. Use when the user asks to visualize, preview, or render a Mermaid diagram, or mentions "mermaid", "diagram", "flowchart", "sequence diagram", or "render diagram". Supports .mmd files and markdown files with ```mermaid blocks.
---

# Mermaid Diagram Renderer

Render a Mermaid diagram from a file and open the result.

## When to Use

- User asks to visualize or preview a Mermaid diagram
- A `.mmd` file or markdown with a ```mermaid block was just created or discussed
- User says "render this diagram", "show the flowchart", etc.

## Prerequisites

- `mermaid-view` script installed at `~/.local/bin/mermaid-view`
- `mmdc` (mermaid-cli): `npm install -g @mermaid-js/mermaid-cli`
- Chrome or Chromium (used by Puppeteer for rendering)

## Usage

```
mermaid-view <file-path> [--format png|svg|pdf] [--theme dark|default|forest|neutral]
```

- `.mmd` files: rendered directly
- `.md` files: extracts the first ```mermaid block and renders it
- Output: `~/Documents/mermaid/<filename>.<format>` (default: SVG)
- Opens the rendered file automatically

## Steps

1. Identify the file from $ARGUMENTS or the most recently discussed/created
   Mermaid-containing file in the conversation
2. Run: `mermaid-view <file-path>`
3. Report the output path and confirm it opened

Append `--theme dark` or `--format png` if the user requests a specific theme or format.

## Neovim Integration

This script is also bound to `<leader>mm` in neovim, which renders the current
buffer's file and opens the result. Both the Claude Code skill and the neovim
keymap call the same `mermaid-view` script.
