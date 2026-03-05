#!/bin/bash

source "$(dirname "$0")/_util.sh"

check_linux() {
    [[ "$(uname)" == "Linux" ]] || error "Linux required (this script is for servers)"
}

install_apt_deps() {
    info "Installing dependencies via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y zsh git curl fzf ripgrep unzip lsd bat build-essential golang-go btop
    task "Installed zsh, git, curl, fzf, ripgrep, unzip, lsd, bat, build-essential, go, btop"

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
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local bob_target_file="$script_dir/configs/nvim/.bob-version"
    local bob_target_raw="nightly"
    local bob_target="nightly"
    local expected_hash=""

    if [[ -f "$bob_target_file" ]]; then
        bob_target_raw="$(tr -d '[:space:]' <"$bob_target_file")"
    fi

    if [[ -z "$bob_target_raw" ]]; then
        bob_target_raw="nightly"
    fi

    bob_target_raw="${bob_target_raw#NVIM }"
    bob_target="$bob_target_raw"

    # Bob cannot parse numeric-leading commit hashes directly. For pinned dev
    # versions, install nightly and verify exact hash afterwards.
    if [[ "$bob_target_raw" =~ \+g([0-9a-fA-F]+)$ ]]; then
        bob_target="nightly"
        expected_hash="${BASH_REMATCH[1],,}"
    elif [[ "$bob_target_raw" =~ ^nightly@([0-9a-fA-F]+)$ ]]; then
        bob_target="nightly"
        expected_hash="${BASH_REMATCH[1],,}"
    fi

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

    info "Pinned target from dotfiles: $bob_target_raw"
    if [[ "$bob_target" != "$bob_target_raw" ]]; then
        info "Resolved bob install target: $bob_target"
    fi

    # Install nvim via bob using dotfiles-pinned target
    "$bob_bin" install "$bob_target"
    "$bob_bin" use "$bob_target"
    task "Installed nvim $bob_target via bob"

    if [[ -n "$expected_hash" ]]; then
        local pinned_nvim="$HOME/.local/share/bob/$bob_target/bin/nvim"
        [[ -x "$pinned_nvim" ]] || error "Pinned nvim binary not found at $pinned_nvim"

        local actual_line
        actual_line="$("$pinned_nvim" --version | head -1)"

        local actual_hash=""
        if [[ "$actual_line" =~ g([0-9a-fA-F]+)$ ]]; then
            actual_hash="${BASH_REMATCH[1],,}"
        else
            error "Could not parse hash from nvim version line: $actual_line"
        fi

        if [[ "$actual_hash" != "$expected_hash" ]]; then
            error "Pinned Neovim hash mismatch. Expected g$expected_hash from '$bob_target_raw', got: $actual_line"
        fi

        if [[ "$bob_target_raw" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-dev-[0-9]+\+g[0-9a-fA-F]+$ ]]; then
            local expected_line="NVIM $bob_target_raw"
            if [[ "$actual_line" != "$expected_line" ]]; then
                error "Pinned Neovim version mismatch. Expected '$expected_line', got: '$actual_line'"
            fi
        fi

        task "Verified pinned Neovim hash: g$expected_hash"
    fi

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

install_bat_config() {
    step "Installing Bat Configuration"

    local script_dir="$(dirname "$0")"
    mkdir -p ~/.config/bat
    cp "$script_dir/configs/bat/config" ~/.config/bat/
    task "Copied bat config to ~/.config/bat/"

    success "Bat configuration installed"
}

install_lsd_config() {
    step "Installing LSD Configuration"

    local script_dir="$(dirname "$0")"
    mkdir -p ~/.config/lsd
    cp "$script_dir/configs/lsd/config.yaml" ~/.config/lsd/
    cp "$script_dir/configs/lsd/colors.yaml" ~/.config/lsd/
    task "Copied lsd config to ~/.config/lsd/"

    success "LSD configuration installed"
}

install_btop_config() {
    step "Installing Btop Configuration"

    local script_dir="$(dirname "$0")"
    mkdir -p ~/.config/btop
    cp "$script_dir/configs/btop/btop.conf" ~/.config/btop/
    task "Copied btop config to ~/.config/btop/"

    success "Btop configuration installed"
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
    install_bat_config
    install_lsd_config
    install_btop_config

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
