# 🌟 Dotfiles

Clean, modular macOS development setup with modern tooling.

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
- **💻 Zsh Configuration** - Modern shell with plugins, customizations, and pre-configured Powerlevel10k theme
- **🖼️ Ghostty Configuration** - GPU-accelerated terminal emulator

## ⚙️ Manual Installation

```bash
# Everything at once
make install

# Individual components
make install-macos     # 🖥️ macOS system preferences
make install-brew      # 📦 Homebrew + packages
make install-nvim      # ⚡ Neovim configuration
make install-git       # 🔗 Git configuration
make install-tmux      # 🖥️ Tmux configuration
make install-zsh       # 💻 Shell configuration
```

## 🎛️ Customization

| What | Where | Description |
|------|-------|-------------|
| **Shell aliases** | `.config/zsh/aliases.zsh` | Custom command shortcuts |
| **Shell functions** | `.config/zsh/functions.zsh` | Reusable shell functions |
| **Environment vars** | `.config/zsh/env.zsh` | Environment configuration |
| **Powerlevel10k theme** | `.p10k.zsh` | Terminal prompt configuration |
| **Packages** | `Brewfile` | Homebrew packages and apps |
| **macOS settings** | `scripts/macos-defaults.sh` | System preferences |

## 🔧 Maintenance

```bash
make update            # 🔄 Update all packages (upgrades existing ones)
make uninstall         # 🗑️ Remove dotfiles safely
make clean             # 🧹 Clean backup files
make dev               # 💻 Quick dev environment setup
make format            # ✨ Format Bash and Lua files
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
