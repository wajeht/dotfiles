# 🌟 Dotfiles

Clean, modular macOS development setup with old school tooling.

## 🚀 Quick Start

```bash
# Remote install (recommended)
curl -fsSL https://raw.githubusercontent.com/wajeht/dotfiles/refs/heads/main/remote-install.sh | bash

# Or clone and install locally
git clone https://github.com/wajeht/dotfiles.git && cd dotfiles && ./install.sh
```

## 📦 What Gets Installed

- **🖥️ macOS Settings** - Optimized system preferences
- **📦 Homebrew & Packages** - Development tools and apps
- **⚡ Neovim** - Modern editor configuration
- **🔗 Git** - Aliases and workflow optimizations
- **💻 Zsh** - Native shell with plugins
- **⭐ Starship** - Fast, customizable prompt
- **🖼️ Ghostty** - GPU-accelerated terminal
- **📁 LSD** - Beautiful file listing with colors
- **🦇 Bat** - Syntax-highlighted cat replacement

## 🔧 Commands

```bash
# Install everything
make install

# Individual components
make macos brew nvim git zsh starship ghostty lsd bat

# Uninstall components
make <component> uninstall

# Utilities
make update    # Update packages
make clean     # Clean backups
make format    # Format code
make help      # Show all commands
```

## 📁 Configuration

| Component | Config Location |
|-----------|----------------|
| **Zsh** | `.config/zsh/` |
| **Starship** | `.config/starship/` |
| **LSD** | `.config/lsd/` |
| **Bat** | `.config/bat/` |
| **Packages** | `Brewfile` |

## 📋 Requirements

- macOS (any recent version)
- Internet connection
- That's it! 🎯
