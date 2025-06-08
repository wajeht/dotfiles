# 🌟 Dotfiles

Clean, modular macOS development setup with modern tooling and native performance.

## 🚀 Quick Start

### Remote Install (Recommended)

Install directly from GitHub without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/wajeht/dotfiles/refs/heads/main/remote-install.sh | bash
```

### Local Install

First clone the repository, then run:

```bash
./install.sh
```

That's it! 🎉

## 📦 What Gets Installed

- **🖥️ macOS Settings** - Vim-optimized keyboard, dock positioning, better Finder
- **📦 Homebrew & Packages** - Development tools, apps, and utilities
- **⚡ Neovim Configuration** - Lightning-fast editor with modern config
- **🔗 Git Configuration** - Aliases, settings, and workflow optimizations
- **🖥️ Tmux Configuration** - Terminal multiplexer for productivity
- **💻 Zsh Configuration** - Native zsh with modular plugins and blazing performance
- **⭐ Starship Prompt** - Beautiful, fast, and highly customizable shell prompt
- **🖼️ Ghostty Configuration** - GPU-accelerated terminal emulator
- **📁 LSD Configuration** - Beautiful file listing with icons and colors

## ⚙️ Manual Installation

```bash
# Everything at once
make install

# Individual components (install by default)
make macos      # 🖥️ macOS system preferences
make brew       # 📦 Homebrew + packages
make nvim       # ⚡ Neovim configuration
make git        # 🔗 Git configuration
make tmux       # 🖥️ Tmux configuration
make zsh        # 💻 Shell configuration
make starship   # ⭐ Starship prompt
make ghostty    # 🖼️ Terminal configuration
make lsd        # 📁 File listing configuration

# Explicit install/uninstall
make zsh install        # Install Zsh configuration
make nvim uninstall     # Remove Neovim configuration
make starship install   # Install Starship prompt
```

## 🎛️ Customization

| What | Where | Description |
|------|-------|-------------|
| **Shell aliases** | `.config/zsh/aliases.zsh` | Custom command shortcuts |
| **Shell functions** | `.config/zsh/functions.zsh` | Reusable shell functions |
| **Environment vars** | `.config/zsh/env.zsh` | Environment configuration |
| **Key bindings** | `.config/zsh/keybindings.zsh` | Custom keyboard shortcuts |
| **Completions** | `.config/zsh/completions.zsh` | Shell completion settings |
| **Starship prompt** | `.config/starship/starship.toml` | Terminal prompt configuration |
| **LSD configuration** | `.config/lsd/config.yaml` | File listing colors and icons |
| **Packages** | `Brewfile` | Homebrew packages and apps |
| **macOS settings** | `scripts/macos-defaults.sh` | System preferences |

## 🏗️ Architecture

This setup uses **native zsh** with **Starship prompt** for optimal performance:

- ⚡ **Fast startup**: ~148ms (58% faster than Oh My Zsh)
- 🧩 **Modular configuration**: Clean separation of concerns
- 🚀 **Starship prompt**: Written in Rust, blazing fast
- 📦 **Homebrew plugins**: Direct integration, no framework overhead

## 🔧 Maintenance

```bash
# Individual component management
make zsh              # Install/reinstall Zsh configuration
make zsh uninstall    # Remove Zsh configuration
make nvim             # Install/reinstall Neovim configuration
make brew uninstall   # Remove Homebrew packages

# System-wide commands
make update           # 🔄 Update all packages (upgrades existing ones)
make uninstall        # 🗑️ Remove all dotfiles safely (keeps Homebrew packages)
make uninstall-complete # 💥 Complete removal (dotfiles + packages)
make clean            # 🧹 Clean backup files
make dev              # 💻 Quick dev environment setup (brew, nvim, git)
make format           # ✨ Format Bash and Lua files
make help             # 📋 Show all available commands
```

## 📋 Requirements

- **macOS** (any recent version)
- **Internet connection** for downloads
- That's it! All tools auto-install 🎯

## 🛡️ Safety Features

- **🔒 Automatic backups** - Existing configs are safely preserved
- **⚡ Error handling** - Graceful failures with helpful messages
- **🧹 Cleanup** - Temporary files are automatically removed
- **💡 Verbose logging** - Clear feedback on what's happening
- **📦 Smart installation** - Installs missing packages without upgrading existing ones
- **🔄 Resilient installation** - Continues installing other components even if some fail

---

**💡 Pro tip:** Installation skips upgrading existing packages for faster setup. Use `make update` to upgrade everything!
