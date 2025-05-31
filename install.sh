#!/bin/bash

# Source common functions
source "$(dirname "$0")/scripts/common.sh"

main() {
    step "🚀 Installing dotfiles"

    # Basic checks
    info "Performing system checks..."
    check_macos
    check_directory
    check_internet
    check_xcode_tools

    # Make scripts executable
    task "Making scripts executable"
    chmod +x scripts/*.sh

    # Run installation
    ./scripts/macos-defaults.sh
    ./scripts/install-brew.sh
    ./scripts/install-nvim.sh
    ./scripts/install-gitconfig.sh
    ./scripts/install-tmux.sh
    ./scripts/install-zsh.sh

    step "🎉 Installation complete!"
    info "Restart your terminal or run: source ~/.zshrc"
}

main "$@"
