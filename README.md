# Dotfiles

Modular configuration files for macOS development environment.

## Structure

```
.config/zsh/          # Modular Zsh configuration
├── env.zsh           # Environment variables
├── aliases.zsh       # Command aliases
├── functions.zsh     # Custom functions
├── completions.zsh   # Shell completions
└── theme.zsh         # Visual configs
```

## Installation

```bash
# Install everything (includes macOS system preferences)
make install

# Install individual components
make install-zsh
make install-nvim
make install-tmux
make install-gitconfig
make install-brew
make install-macos    # macOS system preferences only
```

## Usage

- **Add alias**: Edit `.config/zsh/aliases.zsh`
- **Add function**: Edit `.config/zsh/functions.zsh`
- **Add env var**: Edit `.config/zsh/env.zsh`
- **Add brew package**: Edit `Brewfile`
- **Add macOS setting**: Edit `macos-defaults.sh`

## Requirements

- macOS with Zsh
- Homebrew
- Oh My Zsh + Powerlevel10k (optional)
