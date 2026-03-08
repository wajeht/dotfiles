# Dotfiles

Clean, modular macOS development setup with old school tooling.

## Quick Start

```bash
# Remote install (recommended)
$ curl -fsSL https://raw.githubusercontent.com/wajeht/dotfiles/refs/heads/main/src/install.sh | bash -s -- --remote

# Or clone and install locally
$ git clone https://github.com/wajeht/dotfiles.git && cd dotfiles && ./src/install.sh
```

## What Gets Installed

- **macOS Settings** - Optimized system preferences
- **Homebrew & Packages** - Development tools and apps
- **Neovim** - Modern editor configuration
- **Git** - Aliases and workflow optimizations
- **Zsh** - Async native prompt with zero bloat
- **Ghostty** - GPU-accelerated terminal
- **LSD** - Beautiful file listing with colors
- **Bat** - Syntax-highlighted cat replacement

## 🔧 Commands

```bash
# Install everything
make install

# Individual components
make macos brew nvim git zsh ghostty lsd bat

# Uninstall components
make <component> uninstall

# Utilities
make update    # Update packages
make clean     # Clean backups
make format    # Format code
make sync-nvim # Sync nvim-pack-lock.json (run :lua vim.pack.update() first)
make help      # Show all commands
```

## License
Distributed under the MIT License © [wajeht](https://github.com/wajeht). See [LICENSE](./LICENSE) for more information.
