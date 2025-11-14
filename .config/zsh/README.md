# Minimal Zsh Configuration

A clean, minimal Zsh configuration using the ZDOTDIR approach with no framework bloat.

## Structure

```
~/
├── .zshenv                    # Sets ZDOTDIR (loaded first, always)
└── .config/zsh/
    ├── .zshrc                 # Main configuration loader
    ├── rc.zsh                 # Core Zsh settings (options, history, completion)
    ├── env.zsh                # Environment variables and PATH
    ├── aliases.zsh            # Command aliases
    ├── functions.zsh          # Custom functions and keybindings
    └── private.zsh (optional) # Machine-specific config (gitignored)
```

## File Descriptions

### `~/.zshenv`
- Sets `ZDOTDIR="$HOME/.config/zsh"`
- Loaded first for all shell types
- Ensures all Zsh config lives in one place

### `.zshrc`
- Main configuration loader
- Sources all config files in the correct order
- Loads Homebrew plugins (zsh-vi-mode, autosuggestions, syntax-highlighting)
- Initializes Starship prompt

### `rc.zsh`
- Core Zsh options (AUTO_CD, history settings, etc.)
- History configuration (size, file location, deduplication)
- Completion system setup and styling
- FZF theme configuration
- Replaces: theme.zsh, completions.zsh

### `env.zsh`
- Environment variables (EDITOR, LANG, HOMEBREW_NO_AUTO_UPDATE)
- PATH modifications (Go, Bun, Bob nvim, LM Studio)
- Lazy-loaded NVM (faster shell startup)
- Man page colorization with bat

### `aliases.zsh`
- Editor shortcuts (vim, nvim, code, cursor)
- Development tools (lazygit, sail)
- File operations (ls → lsd, cat → bat)
- Git aliases (comprehensive set)
- System utilities and maintenance
- SSH connection shortcuts

### `functions.zsh`
- Utility functions (mkcd, dev, kill-port)
- Database import helpers (importDB, importMDB)
- Enhanced cd (auto-list with lsd)
- Git workflow functions (git_diff_all, git_pr_comments)
- Custom keybindings (dev-widget for Cmd+F)

### `private.zsh` (optional)
- Machine-specific configuration
- Not tracked in git
- Automatically loaded if present

## Loading Order

1. `~/.zshenv` → Sets ZDOTDIR
2. `~/.config/zsh/.zshrc` → Main loader
   1. `rc.zsh` → Core settings, completion, theme
   2. `env.zsh` → Environment & PATH
   3. Homebrew plugins (zsh-vi-mode, autosuggestions, syntax-highlighting)
   4. `aliases.zsh` → Command aliases
   5. `functions.zsh` → Functions & keybindings
   6. `private.zsh` → Machine-specific (if exists)
   7. Starship prompt initialization

## Plugins (via Homebrew)

- **zsh-vi-mode**: Vi keybindings
- **zsh-completions**: Additional completion definitions
- **zsh-autosuggestions**: Command suggestions from history
- **zsh-syntax-highlighting**: Syntax highlighting for commands

No plugin manager needed - plugins loaded directly from Homebrew.

## Adding New Configuration

- **New alias**: Add to `aliases.zsh`
- **New function**: Add to `functions.zsh`
- **New environment variable**: Add to `env.zsh`
- **New Zsh option**: Add to `rc.zsh`
- **Machine-specific config**: Add to `private.zsh` (create if needed)

## Installation

Install the complete configuration:
```bash
make zsh
```

This will:
- Backup existing config
- Copy `.zshenv` to `~/`
- Copy all config files to `~/.config/zsh/`
- Fix completion permissions
- Copy reload command to clipboard

## Reloading Configuration

After making changes:
```bash
exec zsh
```

Or source manually:
```bash
source ~/.zshenv
```

## Uninstallation

Remove all Zsh configuration:
```bash
make zsh uninstall
```

This will backup then remove:
- `~/.zshenv`
- `~/.config/zsh/` directory
- Optionally: `~/.zsh_history`

## Benefits

- **Minimal files**: Only 5-6 files total
- **No framework bloat**: Bare Zsh with selective plugins
- **XDG compliant**: Everything in `~/.config/zsh/`
- **Fast startup**: Lazy-loaded tools (NVM), optimized completion caching
- **Easy maintenance**: Clear file organization and purpose
- **Git-friendly**: Machine-specific config in gitignored `private.zsh`
- **Industry standard**: ZDOTDIR + modular sourcing pattern
