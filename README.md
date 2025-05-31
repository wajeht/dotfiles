# Dotfiles

Modular macOS development configuration.

## Install

```bash
make install              # Everything

# Individual components
make install-macos        # macOS settings
make install-brew         # Homebrew packages
make install-zsh          # Shell config
make install-nvim         # Neovim config
make install-tmux         # Tmux config
make install-gitconfig    # Git config
```

## Structure

```
.config/zsh/              # Modular shell config
scripts/                  # Install scripts
Brewfile                  # Package list
```

## Edit

- **Aliases**: `.config/zsh/aliases.zsh`
- **Functions**: `.config/zsh/functions.zsh`
- **Packages**: `Brewfile`
- **macOS**: `scripts/macos-defaults.sh`

## Requirements

- macOS with Zsh
- Homebrew (auto-installed)
