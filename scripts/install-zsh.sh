#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

install_zsh_config() {
    echo "Installing Zsh configuration..."

    # Create backup of existing config
    backup_file ~/.zshrc

    # Install zsh modules
    if ! mkdir -p ~/.config/zsh; then
        error "Failed to create ~/.config/zsh directory"
    fi

    if ! cp -r .config/zsh/* ~/.config/zsh/; then
        error "Failed to copy zsh modules"
    fi
    success "Zsh modules copied to ~/.config/zsh/"

    # Install .zshrc
    if ! cp .zshrc ~/.zshrc; then
        error "Failed to copy .zshrc"
    fi
    success ".zshrc copied to ~/.zshrc"

    # Copy reload command to clipboard (if pbcopy exists)
    if command -v pbcopy >/dev/null 2>&1; then
        echo "source ~/.zshrc" | pbcopy
        success "Reload command copied to clipboard"
    fi
}

main() {
    echo "🐚 Installing Zsh configuration..."

    check_directory_structure

    # Check if zsh is installed
    if ! command -v zsh >/dev/null 2>&1; then
        error "Zsh is not installed. Please install it first (should be default on macOS)."
    fi

    # Check if we're already using zsh
    if [[ "$SHELL" != */zsh ]]; then
        warning "Current shell is not zsh. You may want to change it with: chsh -s $(which zsh)"
    fi

    install_zsh_config

    success "Zsh configuration installed!"
    echo "Run 'source ~/.zshrc' or start a new shell to apply changes"
}

main "$@"
