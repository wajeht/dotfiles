#!/bin/bash

source "$(dirname "$0")/common.sh"

install_starship() {
    if ! command -v starship &>/dev/null; then
        info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        success "Starship installed"
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

        success "Starship configuration installed!"
    else
        warning "No Starship config directory found in dotfiles"
        info "You can configure Starship manually or run 'starship config' later"
    fi
}

main() {
    step "⭐ Installing Starship Prompt"

    # Install Starship binary
    install_starship

    # Install configuration
    install_starship_config

    info "Starship installation complete!"
    info "Your shell prompt is now powered by Starship 🚀"
    info "Restart your terminal or run 'source ~/.zshrc' to apply changes"

    success "Starship setup complete"
}

main "$@"
