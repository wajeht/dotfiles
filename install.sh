#!/bin/bash

source "$(dirname "$0")/scripts/common.sh"

main() {
    step "🚀 Installing dotfiles"

    info "Performing system checks..."
    check_macos
    check_directory
    check_internet
    check_xcode_tools

    task "Making scripts executable"
    chmod +x scripts/*.sh

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
