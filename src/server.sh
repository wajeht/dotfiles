#!/bin/bash

source "$(dirname "$0")/_util.sh"

check_linux() {
    [[ "$(uname)" == "Linux" ]] || error "Linux required (this script is for servers)"
}

install_apt_deps() {
    info "Installing dependencies via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y zsh git curl fzf ripgrep unzip lsd bat build-essential golang-go
    task "Installed zsh, git, curl, fzf, ripgrep, unzip, lsd, bat, build-essential, go"

    # Debian names bat as batcat, symlink it
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
        task "Symlinked batcat -> bat"
    fi
}

install_neovim() {
    info "Installing Neovim via bob..."

    local arch=$(uname -m)
    local bob_bin="$HOME/.local/bin/bob"

    # Download bob
    mkdir -p "$HOME/.local/bin"
    if [[ "$arch" == "x86_64" ]]; then
        curl -sL "https://github.com/MordechaiHadad/bob/releases/latest/download/bob-linux-x86_64.zip" -o /tmp/bob.zip
    elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        curl -sL "https://github.com/MordechaiHadad/bob/releases/latest/download/bob-linux-arm.zip" -o /tmp/bob.zip
    else
        warning "Unknown arch $arch, falling back to apt"
        sudo apt-get install -y neovim
        task "Installed neovim via apt"
        return
    fi

    unzip -o /tmp/bob.zip -d /tmp >/dev/null
    mv /tmp/bob-linux-*/bob "$bob_bin"
    rmdir /tmp/bob-linux-* 2>/dev/null || true
    chmod +x "$bob_bin"
    rm /tmp/bob.zip
    task "Installed bob to ~/.local/bin/bob"

    # Install nightly nvim via bob
    "$bob_bin" use nightly
    task "Installed nvim nightly via bob"

    info "Ensure ~/.local/share/bob/nvim-bin is in your PATH"
}

install_nvm() {
    info "Installing nvm and Node.js..."

    if [[ -d "$HOME/.nvm" ]]; then
        task "nvm already installed"
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        task "Installed nvm"
    fi

    # Load nvm and install latest LTS node
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    task "Installed Node.js LTS via nvm"
}

install_zsh_plugins() {
    info "Installing zsh plugins from git..."

    local plugin_dir="$HOME/.zsh/plugins"
    mkdir -p "$plugin_dir"

    # zsh-vi-mode
    if [[ ! -d "$plugin_dir/zsh-vi-mode" ]]; then
        git clone --depth=1 https://github.com/jeffreytse/zsh-vi-mode.git "$plugin_dir/zsh-vi-mode"
        task "Cloned zsh-vi-mode"
    else
        task "zsh-vi-mode already exists"
    fi

    # zsh-autosuggestions
    if [[ ! -d "$plugin_dir/zsh-autosuggestions" ]]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$plugin_dir/zsh-autosuggestions"
        task "Cloned zsh-autosuggestions"
    else
        task "zsh-autosuggestions already exists"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$plugin_dir/zsh-syntax-highlighting" ]]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir/zsh-syntax-highlighting"
        task "Cloned zsh-syntax-highlighting"
    else
        task "zsh-syntax-highlighting already exists"
    fi

    # zsh-completions
    if [[ ! -d "$plugin_dir/zsh-completions" ]]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-completions.git "$plugin_dir/zsh-completions"
        task "Cloned zsh-completions"
    else
        task "zsh-completions already exists"
    fi
}

install_zsh_config() {
    step "Installing Zsh Configuration"

    backup_if_exists ~/.zshenv
    backup_if_exists ~/.config/zsh

    local dotfiles_root="$(cd "$(dirname "$0")/.." && pwd)"
    cp "$dotfiles_root/.zshenv" ~/.zshenv
    task "Copied .zshenv"

    mkdir -p ~/.config/zsh
    local script_dir="$(dirname "$0")"
    cp "$script_dir/configs/zsh/.zshrc" ~/.config/zsh/
    cp "$script_dir/configs/zsh/env.zsh" ~/.config/zsh/
    cp "$script_dir/configs/zsh/aliases.zsh" ~/.config/zsh/
    cp "$script_dir/configs/zsh/functions.zsh" ~/.config/zsh/
    task "Copied zsh configs to ~/.config/zsh/"

    success "Zsh configuration installed"
}

install_nvim_config() {
    step "Installing Neovim Configuration"

    backup_if_exists ~/.config/nvim

    mkdir -p ~/.config/nvim
    local script_dir="$(dirname "$0")"
    cp -r "$script_dir/configs/nvim/"* ~/.config/nvim/
    task "Copied nvim config to ~/.config/nvim/"

    # Clean caches
    rm -rf ~/.local/share/nvim/mason 2>/dev/null || true
    rm -rf ~/.local/state/nvim/mason.log 2>/dev/null || true

    success "Neovim configuration installed"
}

set_default_shell() {
    info "Setting zsh as default shell..."
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s "$(which zsh)"
        task "Changed default shell to zsh"
    else
        task "zsh is already the default shell"
    fi
}

install_server() {
    step "🖥️  Installing Server Dotfiles (Linux)"

    check_linux
    check_internet

    install_apt_deps
    install_nvm
    install_neovim
    install_zsh_plugins
    install_zsh_config
    install_nvim_config

    echo ""
    read -p "❓ Set zsh as your default shell? [y/N] " confirm
    [[ "$confirm" == "y" ]] && set_default_shell

    success "Server dotfiles installed!"
    info "Run 'exec zsh' or log out and back in to use zsh"
    info "Run 'nvim' to install plugins via Lazy"
}

uninstall_server() {
    step "🗑️  Removing Server Dotfiles"

    echo "This will remove:"
    echo "  - ~/.zshenv"
    echo "  - ~/.config/zsh/"
    echo "  - ~/.config/nvim/"
    echo "  - ~/.zsh/plugins/"
    echo "  - ~/.local/bin/nvim (AppImage)"
    echo ""
    read -p "❓ Continue? [y/N] " confirm && [[ "$confirm" == "y" ]] || exit 1

    rm -f ~/.zshenv
    rm -rf ~/.config/zsh
    rm -rf ~/.config/nvim
    rm -rf ~/.zsh/plugins
    rm -rf ~/.local/bin/nvim 2>/dev/null || true
    rm -rf ~/.local/bin/squashfs-root 2>/dev/null || true
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/nvim

    success "Server dotfiles removed"
}

main() {
    case "${1:-install}" in
    install)
        install_server
        ;;
    uninstall)
        uninstall_server
        ;;
    *)
        install_server
        ;;
    esac
}

main "$@"
