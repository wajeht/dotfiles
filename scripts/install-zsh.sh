#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "💻 Installing Zsh Configuration"

    backup_if_exists ~/.zshrc

    info "Installing Zsh modules..."
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/
    task "Copied modules to ~/.config/zsh/"

    info "Zsh plugins will be loaded from Homebrew installations..."
    task "Plugins: zsh-vi-mode, zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting"
    info "Using native Zsh configuration (no Oh My Zsh overhead)"

    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    info "Copying reload command to clipboard"
    echo "source ~/.zshrc" | pbcopy
    task "Command copied to clipboard. Paste and run it, or restart your terminal."

    success "Zsh configuration installed"
    info "💡 Don't forget to install Starship prompt: make install-starship"
}

main "$@"
