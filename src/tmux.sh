#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_tmux() {
    step "🖥️ Installing Tmux Configuration"

    backup_if_exists ~/.config/tmux/tmux.conf

    info "Installing Tmux configuration..."
    mkdir -p ~/.config/tmux
    cp -r "$(dirname "$0")/configs/tmux/"* ~/.config/tmux/
    task "Copied configuration to ~/.config/tmux/"

    info "Installing Tmux Plugin Manager..."
    mkdir -p ~/.config/tmux/plugins
    if [[ ! -d ~/.config/tmux/plugins/tpm ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
        task "Installed TPM to ~/.config/tmux/plugins/tpm"
    else
        task "TPM already installed"
    fi

    check_sessionizer_deps

    if tmux_supports_sessionizer; then
        info "Installing Tmux persistence plugins..."
        if tmux start-server \; source-file ~/.config/tmux/tmux.conf >/dev/null 2>&1 &&
            ~/.config/tmux/plugins/tpm/bin/install_plugins; then
            task "Installed tmux plugins"
        else
            warning "Could not auto-install tmux plugins; run prefix + I inside tmux to finish"
        fi
    else
        warning "Skipping tmux plugin install until tmux is upgraded to 3.2+"
    fi

    success "Tmux configuration installed"
}

uninstall_tmux() {
    step "🗑️  Removing Tmux Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/tmux/ directory"
    echo "   • All Tmux configuration files"
    echo "   • Tmux plugins installed under ~/.config/tmux/plugins/"
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
