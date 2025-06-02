#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "⚡ Installing Neovim Configuration"

    info "Installing Neovim configuration..."
    mkdir -p ~/.config/nvim
    cp -r .config/nvim/* ~/.config/nvim/
    task "Copied configuration to ~/.config/nvim/"

    success "Neovim configuration installed"
}

main "$@"
