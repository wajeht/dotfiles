# Modular Zsh Configuration

This directory contains a modular Zsh configuration structure that keeps your shell setup organized and maintainable.

## Structure

```
.config/zsh/
├── env.zsh          # Environment variables and PATH configuration
├── aliases.zsh      # Command aliases
├── functions.zsh    # Custom shell functions
├── completions.zsh  # Completion scripts and settings
├── theme.zsh        # Theme and visual configurations (fzf, etc.)
└── README.md        # This file
```

## File Descriptions

### `env.zsh`
- Environment variables (`EDITOR`, `LANG`, etc.)
- PATH modifications
- Tool-specific environment setup (NVM, bun, etc.)

### `aliases.zsh`
- Command aliases organized by category
- Editor shortcuts, development tools, system utilities
- SSH connection shortcuts

### `functions.zsh`
- Custom shell functions
- Development workflow helpers
- Git utilities and enhanced commands

### `completions.zsh`
- Shell completion configurations
- Tool-specific completion scripts

### `theme.zsh`
- Visual configurations and theming
- FZF color schemes and options
- Prompt customizations (if any)

## Loading Order

The files are loaded in this specific order in `.zshrc`:
1. `env.zsh` - Environment setup first
2. `completions.zsh` - Completion configuration
3. `aliases.zsh` - Command aliases
4. `functions.zsh` - Custom functions
5. `theme.zsh` - Visual configuration last

## Adding New Configuration

- **New alias**: Add to `aliases.zsh`
- **New function**: Add to `functions.zsh`
- **New environment variable**: Add to `env.zsh`
- **New completion**: Add to `completions.zsh`
- **Theme changes**: Add to `theme.zsh`

## Installation

The modular configuration is installed automatically when running:
```bash
make install-zsh
```

This copies all files to `~/.config/zsh/` and updates your `~/.zshrc` to source them.
