#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_git() {
    step "🔗 Installing Git Configuration"

    backup_if_exists ~/.config/git/config
    backup_if_exists ~/.gitconfig # Backup legacy location if exists

    info "Installing Git configuration (XDG-compliant)..."
    mkdir -p ~/.config/git
    cp "$(dirname "$0")/configs/git/config" ~/.config/git/config
    task "Copied config to ~/.config/git/config"
    cp "$(dirname "$0")/configs/git/work" ~/.config/git/work
    task "Copied work profile override to ~/.config/git/work"

    success "Git configuration installed"
    info "💡 Using XDG location: ~/.config/git/config (modern standard)"
}

uninstall_git() {
    step "🗑️  Removing Git Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/git/config"
    echo "   • ~/.gitconfig (legacy, if exists)"
    echo ""
    read -p "❓ Continue with Git uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Creating backup of current config..."
    if [ -f ~/.config/git/config ]; then
        mkdir -p ~/.config/git.backup.$(date +%Y%m%d_%H%M%S)
        cp ~/.config/git/config ~/.config/git.backup.$(date +%Y%m%d_%H%M%S)/ && task "✅ Git config backed up"
    fi
    if [ -f ~/.gitconfig ]; then
        cp ~/.gitconfig ~/.gitconfig.backup.$(date +%Y%m%d_%H%M%S) && task "✅ Legacy .gitconfig backed up"
    fi

    info "Removing Git configuration..."
    rm -f ~/.config/git/config
    rm -f ~/.gitconfig # Remove legacy location if it exists
    task "Removed Git configuration files"

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
