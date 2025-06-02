#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "💻 Installing Zsh Configuration"

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
                error "Failed to clone plugin: $plugin_name"
            fi
        fi
    done

    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    info "Copying reload command to clipboard"
    echo "source ~/.zshrc" | pbcopy
    task "Command copied to clipboard. Paste and run it, or restart your terminal."

    success "Zsh configuration installed"
}

main "$@"
