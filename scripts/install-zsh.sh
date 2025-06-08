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

main() {
    step "💻 Installing Zsh Configuration"

    # Install Starship prompt
    install_starship

    backup_if_exists ~/.zshrc

    info "Installing Zsh modules..."
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/
    task "Copied modules to ~/.config/zsh/"

    info "Zsh plugins will be loaded from Homebrew installations..."
    task "Plugins: zsh-vi-mode, zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting"
    info "Using native Zsh with Starship prompt (no Oh My Zsh overhead)"

    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    # Install Starship configuration
    info "Installing Starship configuration..."
    mkdir -p ~/.config
    if [[ -d ".config/starship" ]]; then
        backup_if_exists ~/.config/starship.toml
        cp -r .config/starship ~/.config/
        task "Copied Starship configuration to ~/.config/starship/"

        # Copy starship.toml to the expected location
        if [[ -f ".config/starship/starship.toml" ]]; then
            cp .config/starship/starship.toml ~/.config/starship.toml
            task "Copied starship.toml to ~/.config/starship.toml"
        fi

        success "Starship pre-configured with custom theme!"
    else
        info "No Starship config found - using default configuration"
    fi

    info "Copying reload command to clipboard"
    echo "source ~/.zshrc" | pbcopy
    task "Command copied to clipboard. Paste and run it, or restart your terminal."

    success "Zsh configuration installed"
}

main "$@"
