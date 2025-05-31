# Dotfiles

A modular and organized collection of configuration files for macOS development environment.

## Structure

```
.
├── .config/           # Application configurations (XDG Base Directory compliant)
│   ├── alacritty/     # Terminal emulator config
│   ├── bat/           # Better cat command config
│   ├── btop/          # System monitor config
│   ├── ghostty/       # Terminal emulator config
│   ├── lsd/           # Better ls command config
│   ├── nvim/          # Neovim configuration
│   └── zsh/           # Modular Zsh configuration
├── .legacy/           # Backup of old configuration files
├── .vscode/           # VSCode settings for this repository
├── .gitconfig         # Git configuration
├── .tmux.conf         # Tmux configuration
├── .vimrc             # Vim configuration
├── .zshrc             # Main Zsh configuration (sources modular files)
├── brew-apps.sh       # Homebrew applications installation script
└── Makefile           # Installation and management scripts
```

## Features

### Modular Zsh Configuration
- **Organized Structure**: Zsh configuration split into logical modules
- **Easy Maintenance**: Add aliases, functions, and environment variables in dedicated files
- **Portable**: Consistent configuration across different machines

### Application Configs
- **Neovim**: Full Lua-based configuration with LSP, plugins, and custom keybindings
- **Terminal Tools**: Enhanced configurations for `bat`, `lsd`, `btop`, and terminal emulators
- **Git**: Optimized Git configuration with aliases and settings

## Installation

### Full Installation
Install all configurations:
```bash
make install
```

### Individual Components
Install specific components:
```bash
make install-zsh      # Install Zsh configuration
make install-nvim     # Install Neovim configuration
make install-gitconfig # Install Git configuration
```

### Manual Installation
You can also manually copy configurations:
```bash
# Zsh (recommended method)
make install-zsh

# Or manually:
mkdir -p ~/.config/zsh
cp -r .config/zsh/* ~/.config/zsh/
cp .zshrc ~/.zshrc
```

## Zsh Configuration Details

The Zsh configuration uses a modular approach located in `.config/zsh/`:

- `env.zsh` - Environment variables and PATH
- `aliases.zsh` - Command aliases
- `functions.zsh` - Custom shell functions
- `completions.zsh` - Shell completions
- `theme.zsh` - Visual configurations

See [.config/zsh/README.md](.config/zsh/README.md) for detailed documentation.

## Requirements

- **macOS** (tested on macOS Sonoma)
- **Zsh** (default on macOS)
- **Homebrew** (for additional tools)
- **Git** (for version control)

### Optional Dependencies
- **Oh My Zsh** + **Powerlevel10k** (for advanced prompt)
- **Neovim** (for the Neovim configuration)
- **Node.js** + **bun** (for development tools)

## Customization

### Adding New Aliases
Edit `.config/zsh/aliases.zsh`:
```bash
alias myalias='command'
```

### Adding New Functions
Edit `.config/zsh/functions.zsh`:
```bash
function myfunction() {
  # your code here
}
```

### Adding Environment Variables
Edit `.config/zsh/env.zsh`:
```bash
export MY_VAR="value"
```

## Backup and Restore

### Backup Current Config
Your existing configurations are automatically backed up during installation.

### Restore from Git
```bash
git clone https://github.com/yourusername/dotfiles.git ~/Dev/dotfiles
cd ~/Dev/dotfiles
make install
```

## Uninstallation

Remove installed configurations:
```bash
make uninstall
```

**Note**: This removes copied configurations but preserves `.gitconfig` and `.zshrc` for safety.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the configuration
5. Submit a pull request

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
