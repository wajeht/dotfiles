#!/bin/bash

source "$(dirname "$0")/common.sh"

install_git() {
    step "🔗 Installing Git Configuration"

    backup_if_exists ~/.gitconfig

    info "Installing .gitconfig..."
    cp .gitconfig ~/.gitconfig
    task "Copied .gitconfig to home directory"

    success "Git configuration installed"
}

uninstall_git() {
    step "🗑️  Removing Git Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.gitconfig"
    echo ""
    read -p "❓ Continue with Git uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Creating backup of current config..."
    if [ -f ~/.gitconfig ]; then
        cp ~/.gitconfig ~/.gitconfig.backup.$(date +%Y%m%d_%H%M%S) && task "✅ ~/.gitconfig backed up"
    fi

    info "Removing Git configuration..."
    rm -f ~/.gitconfig
    task "Removed ~/.gitconfig"

    success "Git configuration removed successfully!"
    info "💡 To reinstall: make git install"
}

main() {
    case "${1:-install}" in
    install)
        install_git
        ;;
    uninstall)
        uninstall_git
        ;;
    *)
        install_git
        ;;
    esac
}

main "$@"
