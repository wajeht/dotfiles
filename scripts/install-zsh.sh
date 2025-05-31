#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    step "🐚 Installing Zsh configuration"

    # Backup existing config
    backup_if_exists ~/.zshrc

    # Install zsh modules
    info "Installing Zsh modules..."
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/
    task "Copied modules to ~/.config/zsh/"

    # Install .zshrc
    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    success "Zsh configuration installed"
}

main "$@"
