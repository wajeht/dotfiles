#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🐚 Installing Zsh configuration"

    backup_if_exists ~/.zshrc

    info "Installing Zsh modules..."
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/
    task "Copied modules to ~/.config/zsh/"

    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    info "Copying reload command to clipboard"
    echo "source ~/.zshrc" | pbcopy
    task "Command copied to clipboard. Paste and run it, or restart your terminal."

    success "Zsh configuration installed"
}

main "$@"
