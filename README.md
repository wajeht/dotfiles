# Dotfiles

Clean, modular macOS development setup with old school tooling.

## Quick Start

```bash
# Remote install (recommended)
$ curl -fsSL https://raw.githubusercontent.com/wajeht/dotfiles/refs/heads/main/install.sh | bash -s -- --remote

# Or clone and install locally
$ git clone https://github.com/wajeht/dotfiles.git && cd dotfiles && ./install.sh
```

## Commands

```bash
# Install everything
make install

# Individual components
make macos brew nvim git zsh ghostty tmux lsd bat btop

# Uninstall components
make <component> uninstall

# Utilities
make update    # Update packages
make clean     # Clean backups
make format    # Format code
make sync-nvim # Sync nvim-pack-lock.json (run :lua vim.pack.update() first)
make help      # Show all commands
```

## Docs

- [SSH Keys, Hosts & GitHub Accounts](./docs/ssh.md) — key naming, host aliases, multi-account GitHub, passwordless login, new-machine setup
- [Verified Commits](./docs/verified-commit.md) — SSH commit signing setup on macOS
- [Tmux](./docs/tmux.md) — keybindings and session reference
- [Testing](./docs/testing.md) — try changes safely in a throwaway macOS VM (Tart) or Linux guest

## License
Distributed under the MIT License © [wajeht](https://github.com/wajeht). See [LICENSE](./LICENSE) for more information.
