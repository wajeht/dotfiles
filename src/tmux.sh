#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_tmux() {
    step "🖥️ Installing Tmux Configuration"

    backup_if_exists ~/.config/tmux/tmux.conf

    info "Installing Tmux configuration..."
    mkdir -p ~/.config/tmux
    cp -r "$(dirname "$0")/configs/tmux/"* ~/.config/tmux/
    task "Copied configuration to ~/.config/tmux/"

    check_sessionizer_deps

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
