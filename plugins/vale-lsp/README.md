# vale-lsp

Vale prose linter LSP for Claude Code. Catches AI-generated writing patterns
using the [ai-tells](https://github.com/tbhb/vale-ai-tells) style package.

## Supported Extensions
`.md`, `.txt`

## Installation

### Via Homebrew (vale CLI)
```bash
brew install vale
```

### vale-ls binary
Download from [GitHub releases](https://github.com/vale-cli/vale-ls/releases)
and place on `$PATH` (e.g. `~/.local/bin/vale-ls`).

### Configuration
Requires a `~/.vale.ini` (global default) or project-local `.vale.ini`.
Run `vale sync` after creating the config to download style packages.

## More Information
- [Vale Documentation](https://vale.sh/docs)
- [vale-ls Repository](https://github.com/vale-cli/vale-ls)
- [ai-tells Style Package](https://github.com/tbhb/vale-ai-tells)
