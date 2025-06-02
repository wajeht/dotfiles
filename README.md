# Dotfiles

Clean, modular macOS development setup.

## Remote Install (Recommended)

Install directly from GitHub without cloning:

```bash
$ curl -fsSL https://raw.githubusercontent.com/wajeht/dotfiles/refs/heads/main/remote-install.sh | bash
```

## Local Install

First clone the repository, then run:

```bash
$ ./install.sh
```

That's it! 🎉

## What Gets Installed

- **🍎 macOS settings** - Vim-optimized keyboard, dock on right, better Finder
- **🍺 Homebrew packages** - Development tools, apps, and utilities
- **📝 Neovim config** - Ready-to-use editor configuration
- **⚙️ Git config** - Aliases, settings, and defaults
- **📟 Tmux config** - Terminal multiplexer setup
- **🐚 Zsh config** - Modular shell with aliases and functions

## Manual Install

```bash
# Everything
$ make install

# Individual components
$ make install-macos     # macOS system preferences
$ make install-brew      # Homebrew + packages
$ make install-nvim      # Neovim configuration
$ make install-git       # Git configuration
make install-tmux      # Tmux configuration
make install-zsh       # Shell configuration
```

## Customize

| What | Where |
|------|-------|
| Shell aliases | `.config/zsh/aliases.zsh` |
| Shell functions | `.config/zsh/functions.zsh` |
| Environment vars | `.config/zsh/env.zsh` |
| Packages | `Brewfile` |
| macOS settings | `scripts/macos-defaults.sh` |

## Maintenance

```bash
$ make update            # Update all packages
$ make uninstall         # Remove dotfiles
$ make clean             # Clean backup files
$ make dev               # Quick dev setup
$ make format            # Format Bash and Lua files
```

## Requirements

- macOS (any recent version)
- Internet connection
- That's it! Homebrew and tools auto-install.

---

*Automatic backups are created for existing configs.*
