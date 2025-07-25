#!/bin/bash

source "$(dirname "$0")/common.sh"

install_starship_binary() {
    if ! command -v starship &>/dev/null; then
        info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        success "Starship binary installed"
    else
        task "Starship already installed"
    fi
}

install_starship_config() {
    info "Installing Starship configuration..."
    mkdir -p ~/.config

    if [[ -d ".config/starship" ]]; then
        # Backup existing config if it exists
        backup_if_exists ~/.config/starship.toml

        # Copy starship config directory
        cp -r .config/starship ~/.config/
        task "Copied Starship configuration to ~/.config/starship/"

        # Copy starship.toml to the expected location
        if [[ -f ".config/starship/starship.toml" ]]; then
            cp .config/starship/starship.toml ~/.config/starship.toml
            task "Copied starship.toml to ~/.config/starship.toml"
        fi

        success "Starship configuration installed"
    else
        warning "No Starship config directory found in dotfiles"
        info "You can configure Starship manually or run 'starship config' later"
    fi
}

install_starship() {
    step "⭐ Installing Starship Prompt"

    # Install Starship binary
    install_starship_binary

    # Install configuration
    install_starship_config

    info "Starship installation complete! 🚀"
    info "Restart your terminal or run 'source ~/.zshrc' to apply changes"

    success "Starship setup complete"
}

uninstall_starship() {
    step "🗑️  Removing Starship Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/starship.toml"
    echo "   • ~/.config/starship/ directory"
    echo "   • Note: Starship binary will remain installed"
    echo ""
    read -p "❓ Continue with Starship uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
    echo ""

    info "Creating backup of current config..."
    if [ -f ~/.config/starship.toml ]; then
        cp ~/.config/starship.toml ~/.config/starship.toml.backup.$(date +%Y%m%d_%H%M%S) && task "✅ starship.toml backed up"
    fi

    info "Removing Starship config files..."
    rm -f ~/.config/starship.toml
    rm -rf ~/.config/starship
    task "Removed Starship configuration files"

    echo ""
    success "Starship configuration removed successfully!"
    info "💡 To reinstall: make starship install"
    info "💡 To remove Starship binary: brew uninstall starship"
}

main() {
    case "${1:-install}" in
    install)
        install_starship
        ;;
    uninstall)
        uninstall_starship
        ;;
    *)
        install_starship
        ;;
    esac
}

main "$@"
