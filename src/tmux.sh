#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_tmux() {
    step "🖥️ Installing Tmux Configuration"

    backup_if_exists ~/.config/tmux/tmux.conf

    info "Installing Tmux configuration..."
    mkdir -p ~/.config/tmux
    cp -r "$(dirname "$0")/configs/tmux/"* ~/.config/tmux/
    task "Copied configuration to ~/.config/tmux/"

    # display-popup (Ctrl+F sessionizer) needs tmux >= 3.2 — warn if older.
    if command -v tmux >/dev/null 2>&1; then
        local tmux_version=$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [ "$(printf '%s\n3.2\n' "$tmux_version" | sort -V | head -1)" != "3.2" ]; then
            warning "tmux $tmux_version < 3.2: Ctrl+F popup binding will not work"
        fi
    fi

    success "Tmux configuration installed"
}

uninstall_tmux() {
    step "🗑️  Removing Tmux Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/tmux/ directory"
    echo "   • All Tmux configuration files"
    echo ""
    read -p "❓ Continue with Tmux uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Tmux configuration..."
    rm -rf ~/.config/tmux
    task "Removed ~/.config/tmux/"

    success "Tmux configuration removed successfully!"
    info "💡 To reinstall: make tmux install"
}

main() {
    case "${1:-install}" in
    install)
        install_tmux
        ;;
    uninstall)
        uninstall_tmux
        ;;
    *)
        install_tmux
        ;;
    esac
}

main "$@"
