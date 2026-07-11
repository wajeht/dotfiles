#!/bin/bash

source "$(dirname "$0")/../scripts/utils.sh"

install_bat() {
    step "🦇 Installing Bat Configuration"

    info "Installing Bat configuration..."
    mkdir -p ~/.config/bat
    task "Created ~/.config/bat directory"

    backup_if_exists ~/.config/bat/config

    cp "$(dirname "$0")/config" ~/.config/bat/config
    task "Copied config to ~/.config/bat/"

    success "Bat configuration installed"
}

uninstall_bat() {
    step "🗑️  Removing Bat Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/bat/config"
    echo "   • ~/.config/bat/ directory"
    echo "   • Note: Bat binary will remain installed"
    echo ""
    read -p "❓ Continue with Bat uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Creating backup of current config..."
    if [ -f ~/.config/bat/config ]; then
        cp ~/.config/bat/config ~/.config/bat/config.backup.$(date +%Y%m%d_%H%M%S) && task "✅ ~/.config/bat/config backed up"
    fi

    info "Removing Bat configuration..."
    rm -f ~/.config/bat/config
    rm -rf ~/.config/bat
    task "Removed Bat configuration files"

    success "Bat configuration removed successfully!"
    info "💡 To reinstall: make bat install"
    info "💡 To remove Bat binary: brew uninstall bat"
}

main() {
    case "${1:-install}" in
    install)
        install_bat
        ;;
    uninstall)
        uninstall_bat
        ;;
    *)
        install_bat
        ;;
    esac
}

main "$@"
