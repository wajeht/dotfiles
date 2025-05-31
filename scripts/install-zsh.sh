#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "🐚 Installing Zsh configuration..."

    # Backup existing config
    backup_if_exists ~/.zshrc

    # Install zsh modules
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/

    # Install .zshrc
    cp .zshrc ~/.zshrc

    success "Zsh configuration installed!"
}

main "$@"
