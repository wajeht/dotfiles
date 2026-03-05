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

    # Work laptop: has both id_ed25519 (work) and id_ed25519_personal (personal)
    # Personal computer: only has id_ed25519 (personal)
    if [ -f ~/.ssh/id_ed25519_personal.pub ]; then
        sed -i '' 's|signingKey = ~/.ssh/id_ed25519.pub|signingKey = ~/.ssh/id_ed25519_personal.pub|' ~/.config/git/config
        cp "$(dirname "$0")/configs/git/work" ~/.config/git/work
        task "Work laptop detected — default signing key set to personal, work profile installed"
    else
        task "Personal computer detected — using default signing key"
    fi

    info "Installing SSH configuration for GitHub multi-account..."
    mkdir -p ~/.ssh
    backup_if_exists ~/.ssh/config
    if [ -f ~/.ssh/config ]; then
        if ! grep -q "github-personal" ~/.ssh/config; then
            cat "$(dirname "$0")/configs/git/ssh_config" >>~/.ssh/config
            task "Appended GitHub SSH config to ~/.ssh/config"
        else
            task "GitHub SSH config already present in ~/.ssh/config"
        fi
    else
        cp "$(dirname "$0")/configs/git/ssh_config" ~/.ssh/config
        task "Copied SSH config to ~/.ssh/config"
    fi
    chmod 600 ~/.ssh/config

    info "Generating allowed_signers for commit verification..."
    : >~/.ssh/allowed_signers
    if [ -f ~/.ssh/id_ed25519_personal.pub ]; then
        # Work laptop: id_ed25519 = work key, id_ed25519_personal = personal key
        echo "265659615+clevyr-kyaw@users.noreply.github.com $(cat ~/.ssh/id_ed25519.pub)" >>~/.ssh/allowed_signers
        echo "58354193+wajeht@users.noreply.github.com $(cat ~/.ssh/id_ed25519_personal.pub)" >>~/.ssh/allowed_signers
        task "Added work and personal keys to allowed_signers"
    elif [ -f ~/.ssh/id_ed25519.pub ]; then
        # Personal computer: id_ed25519 = personal key (only key)
        echo "58354193+wajeht@users.noreply.github.com $(cat ~/.ssh/id_ed25519.pub)" >>~/.ssh/allowed_signers
        task "Added personal key to allowed_signers"
    fi

    info "Adding GitHub host keys..."
    ssh-keyscan -t ed25519 -p 443 ssh.github.com 2>/dev/null >>~/.ssh/known_hosts
    task "Added GitHub SSH host key"

    success "Git configuration installed"
    info "💡 Using XDG location: ~/.config/git/config (modern standard)"
    info "💡 SSH configured for multi-account GitHub (github.com + github-personal)"
}

uninstall_git() {
    step "🗑️  Removing Git Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/git/config"
    echo "   • ~/.config/git/work"
    echo "   • ~/.ssh/allowed_signers"
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
    rm -f ~/.config/git/work
    rm -f ~/.ssh/allowed_signers
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
