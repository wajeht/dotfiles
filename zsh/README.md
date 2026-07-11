# Minimal Zsh Configuration

A blazing-fast, clean Zsh configuration with async git prompt and zero framework bloat.

## Structure

```
~/
├── .zshenv                    # Sets ZDOTDIR (loaded first, always)
└── .config/zsh/
    ├── .zshrc                 # Main config (core settings + async prompt)
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
- **Core Zsh settings** (options, history, completion)
- **Async git prompt** (instant rendering, non-blocking)
- **FZF theme** configuration
- **Plugin loading** (zsh-vi-mode, autosuggestions, syntax-highlighting)
- Sources env.zsh, aliases.zsh, functions.zsh

### `env.zsh`
- Environment variables (EDITOR, LANG, HOMEBREW_NO_AUTO_UPDATE)
- PATH modifications (Go, Bun, LM Studio)
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
- Custom keybindings (dev-widget for Ctrl+F)

### `private.zsh` (optional)
- Machine-specific configuration
- Not tracked in git
- Automatically loaded if present

## Features

### ⚡ Async Git Prompt
- **Instant prompt rendering** - appears immediately
- **Non-blocking git status** - runs in background
- **Smart caching** - avoids redundant git calls
- **Visual indicators**:
  - `+4` = 4 staged files (green)
  - `!2` = 2 modified files (yellow)
  - `✘1` = 1 deleted file (red)
  - `?3` = 3 untracked files (cyan)

### 🎨 Clean Prompt Design
```
~/Dev/dotfiles on main [+4!2?3] ················ at 12:04:03 PM
❯
```
- Cyan directory
- White "on" + Green branch name
- Colored git status in brackets
- Auto-adjusting dots
- White "at" + Blue time with AM/PM
- Green prompt symbol

### 🚀 Performance Optimizations
- Lazy-loaded completions (bun)
- Lazy-loaded NVM (only loads when needed)
- Cached completions (`compinit -d`)
- Single git status call per prompt
- Async git operations

## Loading Order

1. `~/.zshenv` → Sets ZDOTDIR
2. `~/.config/zsh/.zshrc` → Main loader
   1. Core Zsh options & history
   2. Completion system
   3. FZF theme
   4. Async git prompt setup
   5. `env.zsh` → Environment & PATH
   6. Homebrew plugins (vi-mode, autosuggestions, syntax-highlighting)
   7. Lazy load bun completions
   8. `aliases.zsh` → Command aliases
   9. `functions.zsh` → Functions & keybindings
   10. `private.zsh` → Machine-specific (if exists)

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
- **New Zsh option**: Add to `.zshrc` (Core Zsh Configuration section)
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

- **4 files total**: Minimal, focused configuration
- **Instant prompt**: Async git status, no blocking
- **No framework bloat**: Bare Zsh with selective plugins
- **XDG compliant**: Everything in `~/.config/zsh/`
- **Fast startup**: Lazy-loaded tools, optimized completion caching
- **Easy maintenance**: Clear file organization and purpose
- **Git-friendly**: Machine-specific config in gitignored `private.zsh`
- **Industry standard**: ZDOTDIR + modular sourcing pattern

## Performance

- **Startup time**: ~50-100ms (with async prompt)
- **Prompt render**: <10ms (instant, non-blocking)
- **Git status**: Async, doesn't block prompt
- **Memory**: Lightweight, ~10MB RSS

## Customization

### Change Prompt Colors
Edit `.zshrc` PROMPT variable (line 178):
```zsh
PROMPT='%F{cyan}%~%f...'  # Change cyan to any color
```

### Disable Async Git
Comment out async functions in `.zshrc` and use synchronous version.

## Troubleshooting

**Prompt not updating?**
- Run `exec zsh` to reload

**Git status not showing?**
- Make sure you're in a git repository
- Check `git status --porcelain` works

**Slow startup?**
- Check which plugins are loading: `zsh -xv`
- Disable unused plugins

**Completion warnings?**
- Run `make zsh` again to fix permissions
- Or manually: `chmod go-w /opt/homebrew/share`
