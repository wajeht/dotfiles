#!/bin/bash

source "$(dirname "$0")/common.sh"

install_nvim() {
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

uninstall_nvim() {
    step "🧹 Cleaning Neovim Configuration and Caches"

    echo "📋 This will remove:"
    echo "   • ~/.config/nvim/ (configuration)"
    echo "   • ~/.cache/nvim/ (cache files)"
    echo "   • ~/.local/share/nvim/ (data files)"
    echo "   • ~/.local/state/nvim/ (state files)"
    echo "   • Plugin manager caches (lazy, mason)"
    echo ""
    read -p "❓ Continue with Neovim cleanup? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Neovim configuration and caches..."
    rm -rf ~/.config/nvim
    rm -rf ~/.cache/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/lazy
    rm -rf ~/.cache/mason
    rm -rf ~/.local/share/nvim/mason
    rm -rf ~/.local/share/nvim/lazy
    rm -rf ~/.local/share/nvim/site
    task "Removed Neovim files and directories"

    info "Clearing npm cache..."
    npm cache clean --force 2>/dev/null || true
    task "Cleared npm cache"

    success "Neovim configuration and caches cleaned!"
    info "💡 To reinstall: make nvim install"
    info "💡 Restart Neovim after reinstall to download plugins"
}

main() {
    case "${1:-install}" in
    install)
        install_nvim
        ;;
    uninstall)
        uninstall_nvim
        ;;
    *)
        install_nvim
        ;;
    esac
}

main "$@"
