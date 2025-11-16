#!/bin/bash

source "$(dirname "$0")/common.sh"

install_ghostty() {
    step "🖼️ Installing Ghostty Configuration"

    info "Installing Ghostty configuration..."
    mkdir -p ~/.config/ghostty
    cp -r config/ghostty/* ~/.config/ghostty/
    task "Copied configuration to ~/.config/ghostty/"

    success "Ghostty configuration installed"
}

uninstall_ghostty() {
    step "🗑️  Removing Ghostty Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/ghostty/ directory"
    echo "   • All Ghostty configuration files"
    echo ""
    read -p "❓ Continue with Ghostty uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Ghostty configuration..."
    rm -rf ~/.config/ghostty
    task "Removed ~/.config/ghostty/"

    success "Ghostty configuration removed successfully!"
    info "💡 To reinstall: make ghostty install"
}

main() {
    case "${1:-install}" in
    install)
        install_ghostty
        ;;
    uninstall)
        uninstall_ghostty
        ;;
    *)
        install_ghostty
        ;;
    esac
}

main "$@"
