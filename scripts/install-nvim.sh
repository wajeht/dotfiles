#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "⚡ Installing Neovim Configuration"

    info "Installing Neovim configuration..."
    mkdir -p ~/.config/nvim
    cp -r .config/nvim/* ~/.config/nvim/
    task "Copied configuration to ~/.config/nvim/"

    info "Cleaning LSP/Mason cache to prevent conflicts..."
    rm -rf ~/.local/share/nvim/mason 2>/dev/null || true
    rm -rf ~/.local/state/nvim/mason.log 2>/dev/null || true
    rm -rf ~/.cache/nvim/lsp.log* 2>/dev/null || true
    task "Cleaned LSP/Mason cache"

    success "Neovim configuration installed"
}

main "$@"
