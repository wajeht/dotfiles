#!/bin/bash

source "$(dirname "$0")/../scripts/utils.sh"

install_nvim() {
    step "⚡ Installing Neovim Configuration"

    local config_nvim="$HOME/.config/nvim"
    local dotfiles_nvim="$(cd "$(dirname "$0")" && pwd)"

    info "Installing Neovim configuration..."
    backup_if_exists "$config_nvim" # back up before replacing (backup_if_exists handles dirs)
    rm -rf "$config_nvim"
    deploy_module_config "$dotfiles_nvim" "$config_nvim"
    task "Replaced configuration in ~/.config/nvim/"

    info "Cleaning LSP/Mason/tree-sitter cache to prevent conflicts..."
    rm -rf ~/.local/share/nvim/mason 2>/dev/null || true
    rm -rf ~/.local/state/nvim/mason.log 2>/dev/null || true
    rm -rf ~/.cache/nvim/lsp.log* 2>/dev/null || true
    rm -rf ~/.cache/nvim/tree-sitter-* 2>/dev/null || true
    task "Cleaned LSP/Mason/tree-sitter cache"

    success "Neovim configuration installed"
}

uninstall_nvim() {
    step "🧹 Cleaning Neovim Configuration and Caches"

    echo "📋 This will remove:"
    echo "   • ~/.config/nvim/ (configuration)"
    echo "   • ~/.cache/nvim/ (cache files)"
    echo "   • ~/.local/share/nvim/ (data files)"
    echo "   • ~/.local/state/nvim/ (state files)"
    echo "   • Plugin/LSP data (mason servers, treesitter parsers)"
    echo ""
    read -p "❓ Continue with Neovim cleanup? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Neovim configuration and caches..."
    # These four dirs cover everything (mason/treesitter/site all live under them).
    rm -rf ~/.config/nvim
    rm -rf ~/.cache/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
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
