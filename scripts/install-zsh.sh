#!/bin/bash

source "$(dirname "$0")/common.sh"

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh My Zsh..."
        # Install Oh My Zsh without prompting and without changing shell
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        success "Oh My Zsh installed"
    else
        task "Oh My Zsh already installed"
    fi
}

install_powerlevel10k() {
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        success "Powerlevel10k installed"
    else
        task "Powerlevel10k already installed"
    fi
}

main() {
    step "💻 Installing Zsh Configuration"

    # Install Oh My Zsh first
    install_oh_my_zsh

    # Install Powerlevel10k theme
    install_powerlevel10k

    backup_if_exists ~/.zshrc

    info "Installing Zsh modules..."
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/
    task "Copied modules to ~/.config/zsh/"

    info "Checking and installing Zsh plugins..."
    export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
    ZSH_CUSTOM_PLUGINS_DIR="$ZSH/custom/plugins"
    mkdir -p "$ZSH_CUSTOM_PLUGINS_DIR"

    plugins=(
        "https://github.com/jeffreytse/zsh-vi-mode.git"
        "https://github.com/zsh-users/zsh-completions.git"
        "https://github.com/zsh-users/zsh-autosuggestions.git"
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    for plugin_url in "${plugins[@]}"; do
        plugin_name=$(basename "$plugin_url" .git)
        if [ -d "$ZSH_CUSTOM_PLUGINS_DIR/$plugin_name" ]; then
            info "Plugin $plugin_name already exists, skipping clone."
        else
            info "Cloning $plugin_name from $plugin_url..."
            if git clone --depth 1 "$plugin_url" "$ZSH_CUSTOM_PLUGINS_DIR/$plugin_name"; then
                task "Installed plugin: $plugin_name"
            else
                warning "Failed to clone plugin: $plugin_name"
            fi
        fi
    done

    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    # Install Powerlevel10k configuration if available
    if [[ -f ".p10k.zsh" ]]; then
        backup_if_exists ~/.p10k.zsh
        info "Installing Powerlevel10k configuration..."
        cp .p10k.zsh ~/.p10k.zsh
        task "Copied .p10k.zsh to home directory"
        success "Powerlevel10k pre-configured - no setup wizard needed!"
    else
        info "No .p10k.zsh found - you can run 'p10k configure' later to set up the theme"
    fi

    info "Copying reload command to clipboard"
    echo "source ~/.zshrc" | pbcopy
    task "Command copied to clipboard. Paste and run it, or restart your terminal."

    success "Zsh configuration installed"
}

main "$@"
