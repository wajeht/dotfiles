#!/bin/bash

source "$(dirname "$0")/../scripts/utils.sh"

install_btop() {
    step "📊 Installing Btop Configuration"

    info "Installing Btop configuration..."
    mkdir -p ~/.config/btop
    task "Created ~/.config/btop directory"

    backup_if_exists ~/.config/btop/btop.conf

    cp "$(dirname "$0")/btop.conf" ~/.config/btop/btop.conf
    task "Copied btop.conf to ~/.config/btop/"

    success "Btop configuration installed"
}

uninstall_btop() {
    step "🗑️  Removing Btop Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/btop/btop.conf"
    echo "   • ~/.config/btop/ directory"
    echo "   • Note: Btop binary will remain installed"
    echo ""
    read -p "❓ Continue with Btop uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Creating backup of current config..."
    if [ -f ~/.config/btop/btop.conf ]; then
        cp ~/.config/btop/btop.conf ~/.config/btop/btop.conf.backup.$(date +%Y%m%d_%H%M%S) && task "✅ ~/.config/btop/btop.conf backed up"
    fi

    info "Removing Btop configuration..."
    rm -f ~/.config/btop/btop.conf
    rm -rf ~/.config/btop
    task "Removed Btop configuration files"

    success "Btop configuration removed successfully!"
    info "💡 To reinstall: make btop install"
    info "💡 To remove Btop binary: brew uninstall btop"
}

main() {
    case "${1:-install}" in
    install)
        install_btop
        ;;
    uninstall)
        uninstall_btop
        ;;
    *)
        install_btop
        ;;
    esac
}

main "$@"
