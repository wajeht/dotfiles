#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_nvim() {
    step "⚡ Installing Neovim Configuration"

    local config_nvim="$HOME/.config/nvim"
    local dotfiles_nvim="$(cd "$(dirname "$0")" && pwd)/configs/nvim"

    # Check if already symlinked to dotfiles
    if [ -L "$config_nvim" ]; then
        local current_target=$(readlink "$config_nvim")
        if [ "$current_target" = "$dotfiles_nvim" ]; then
            success "Neovim config already linked to dotfiles (no copy needed)"
            return 0
        fi
    fi

    info "Installing Neovim configuration..."
    rm -rf "$config_nvim"
    mkdir -p "$config_nvim"
    cp -R "$dotfiles_nvim/." "$config_nvim/"
    task "Replaced configuration in ~/.config/nvim/"

    info "Cleaning LSP/Mason cache to prevent conflicts..."
    rm -rf ~/.local/share/nvim/mason 2>/dev/null || true
    rm -rf ~/.local/state/nvim/mason.log 2>/dev/null || true
    rm -rf ~/.cache/nvim/lsp.log* 2>/dev/null || true
    task "Cleaned LSP/Mason cache"

    info "Removing retired Neovim plugin packages..."
    rm -rf ~/.local/share/nvim/site/pack/core/opt/fzf-lua 2>/dev/null || true
    rm -rf ~/.local/share/nvim/site/pack/core/start/fzf-lua 2>/dev/null || true
    task "Removed retired plugin packages"

    success "Neovim configuration installed"
}

link_nvim() {
    step "🔗 Linking Neovim Configuration"

    local dotfiles_nvim="$(cd "$(dirname "$0")" && pwd)/configs/nvim"
    local config_nvim="$HOME/.config/nvim"

    if [ ! -d "$dotfiles_nvim" ]; then
        error "Neovim config not found in dotfiles: $dotfiles_nvim"
        exit 1
    fi

    if [ -L "$config_nvim" ]; then
        local current_target=$(readlink "$config_nvim")
        if [ "$current_target" = "$dotfiles_nvim" ]; then
            success "Neovim config already linked to dotfiles"
            return 0
        else
            warning "Neovim config is linked to: $current_target"
            read -p "❓ Replace with dotfiles link? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
            rm "$config_nvim"
        fi
    elif [ -d "$config_nvim" ]; then
        warning "Existing Neovim config found at $config_nvim"
        read -p "❓ Back up and replace with symlink? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
        mv "$config_nvim" "$config_nvim.backup.$(date +%Y%m%d-%H%M%S)"
        task "Backed up existing config"
    fi

    mkdir -p ~/.config
    ln -s "$dotfiles_nvim" "$config_nvim"
    task "Created symlink: ~/.config/nvim -> $dotfiles_nvim"

    success "Neovim configuration linked to dotfiles"
}

unlink_nvim() {
    step "🔓 Unlinking Neovim Configuration"

    local config_nvim="$HOME/.config/nvim"

    if [ ! -L "$config_nvim" ]; then
        if [ -d "$config_nvim" ]; then
            warning "Neovim config is not a symlink"
        else
            warning "No Neovim config found at $config_nvim"
        fi
        exit 1
    fi

    local link_target=$(readlink "$config_nvim")
    info "Current symlink: $config_nvim -> $link_target"
    read -p "❓ Remove symlink? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    rm "$config_nvim"
    task "Removed symlink"

    success "Neovim configuration unlinked"
    info "💡 To restore: make nvim link or make nvim install"
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
    link)
        link_nvim
        ;;
    unlink)
        unlink_nvim
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
