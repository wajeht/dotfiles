#!/bin/bash

# Source common functions
source "$(dirname "$0")/scripts/common.sh"

main() {
    echo "🚀 Installing dotfiles..."

    # Basic checks
    check_macos
    check_directory
    check_internet
    check_xcode_tools

    # Make scripts executable
    chmod +x scripts/*.sh

    # Run installation
    ./scripts/macos-defaults.sh
    ./scripts/install-brew.sh
    ./scripts/install-nvim.sh
    ./scripts/install-gitconfig.sh
    ./scripts/install-tmux.sh
    ./scripts/install-zsh.sh

    success "🎉 Dotfiles installed!"
    echo "Restart your terminal or run: source ~/.zshrc"
}

main "$@"
