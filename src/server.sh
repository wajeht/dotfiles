#!/bin/bash

source "$(dirname "$0")/_util.sh"

# Pinned nvm installer version (everything else resolves 'latest' from GitHub
# releases). Named INSTALLER, not NVM_VERSION — nvm.sh uses NVM_VERSION itself,
# and a readonly global by that name breaks it when sourced.
readonly NVM_INSTALLER_VERSION="v0.40.1"

check_linux() {
    [[ "$(uname)" == "Linux" ]] || error "Linux required (this script is for servers)"
}

install_terminfo() {
    info "Installing Ghostty terminfo..."
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local terminfo_file="$script_dir/configs/ghostty/xterm-ghostty.terminfo"
    if [[ -f "$terminfo_file" ]]; then
        tic -x "$terminfo_file"
        task "Installed xterm-ghostty terminfo"
    else
        warning "xterm-ghostty.terminfo not found, skipping"
    fi
}

install_apt_deps() {
    info "Installing dependencies via apt..."
    local apt_pkgs="zsh git gh shfmt curl fzf ripgrep unzip tar gzip lsd bat build-essential golang-go btop tmux"
    sudo apt-get update -qq
    sudo apt-get install -y $apt_pkgs
    task "Installed: $apt_pkgs"

    # Debian names bat as batcat, symlink it
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
        task "Symlinked batcat -> bat"
    fi
}

install_fzf() {
    info "Ensuring a compatible fzf version..."

    local min_version="0.51"
    local current_version=""
    if command -v fzf >/dev/null 2>&1; then
        current_version="$(fzf --version | awk '{print $1}')"
        if printf '%s\n%s\n' "$min_version" "$current_version" | sort -V -C; then
            task "fzf already installed: $current_version"
            return
        fi
        warning "fzf $current_version is older than required $min_version"
    fi

    local arch
    case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *) error "Unsupported architecture for fzf: $(uname -m)" ;;
    esac

    local release_url tag version asset
    release_url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/junegunn/fzf/releases/latest)
    tag="${release_url##*/}"
    version="${tag#v}"
    asset="fzf-${version}-linux_${arch}.tar.gz"

    install_release_bin "https://github.com/junegunn/fzf/releases/download/${tag}/${asset}" fzf
    task "$("$HOME/.local/bin/fzf" --version)"
}

install_tree_sitter_cli() {
    info "Installing tree-sitter CLI..."

    local min_version="0.26.1"
    if command -v tree-sitter >/dev/null 2>&1; then
        local current_version
        current_version="$(tree-sitter --version | awk '{print $2}')"
        if printf '%s\n%s\n' "$min_version" "$current_version" | sort -V -C; then
            task "tree-sitter CLI already installed: $current_version"
            return
        fi
        warning "tree-sitter CLI $current_version is older than required $min_version"
    fi

    local arch
    case "$(uname -m)" in
    x86_64) arch="x64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *) error "Unsupported architecture for tree-sitter: $(uname -m)" ;;
    esac

    local asset="tree-sitter-linux-${arch}.gz"
    install_release_bin "https://github.com/tree-sitter/tree-sitter/releases/latest/download/$asset" tree-sitter
    task "$("$HOME/.local/bin/tree-sitter" --version)"
}

install_neovim() {
    info "Installing Neovim stable from GitHub releases..."

    if command -v nvim >/dev/null 2>&1; then
        task "Neovim already installed: $(nvim --version | head -1)"
        return
    fi

    local install_dir="$HOME/.local"
    mkdir -p "$install_dir/bin"

    local arch
    case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *) error "Unsupported architecture for Neovim: $(uname -m)" ;;
    esac

    local tarball="nvim-linux-${arch}.tar.gz"

    # Neovim ships a bin/lib/share tree (not a single binary), so it's extracted
    # into ~/.local directly rather than via install_release_bin.
    local tmp
    tmp=$(mktemp -d)
    info "Downloading $tarball..."
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/$tarball" -o "$tmp/$tarball"

    info "Extracting to $install_dir..."
    tar -xzf "$tmp/$tarball" -C "$tmp"
    cp -rf "$tmp/${tarball%.tar.gz}"/* "$install_dir/"
    rm -rf "$tmp"

    task "Installed Neovim to $install_dir"
    command -v nvim >/dev/null 2>&1 && task "$(nvim --version | head -1)"
    info "Ensure ~/.local/bin is in your PATH"
}

install_nvm() {
    info "Installing nvm and Node.js..."

    if [[ -d "$HOME/.nvm" ]]; then
        task "nvm already installed"
    else
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_INSTALLER_VERSION}/install.sh" | bash
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
    cp "$script_dir/configs/zsh/ripgreprc" ~/.config/zsh/
    task "Copied zsh configs to ~/.config/zsh/"

    success "Zsh configuration installed"
}

install_tmux_config() {
    step "Installing Tmux Configuration"

    backup_if_exists ~/.config/tmux/tmux.conf

    local script_dir="$(dirname "$0")"
    mkdir -p ~/.config/tmux
    cp "$script_dir/configs/tmux/"* ~/.config/tmux/
    task "Copied tmux config to ~/.config/tmux/"

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

    rm -rf ~/.config/nvim
    mkdir -p ~/.config/nvim
    local script_dir="$(dirname "$0")"
    cp -R "$script_dir/configs/nvim/." ~/.config/nvim/
    task "Replaced nvim config in ~/.config/nvim/"

    # Clean caches
    rm -rf ~/.local/share/nvim/mason 2>/dev/null || true
    rm -rf ~/.local/state/nvim/mason.log 2>/dev/null || true
    rm -rf ~/.cache/nvim/tree-sitter-* 2>/dev/null || true

    success "Neovim configuration installed"
}

set_default_shell() {
    info "Setting zsh as default shell..."
    local zsh_path current_shell
    zsh_path="$(command -v zsh)"
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"

    if [[ "$current_shell" != "$zsh_path" ]]; then
        sudo chsh -s "$zsh_path" "$USER"
        task "Changed default shell to zsh"
    else
        task "zsh is already the default shell"
    fi
}

install_server() {
    step "🖥️  Installing Server Dotfiles (Linux)"

    check_linux
    check_internet
    export PATH="$HOME/.local/bin:$PATH"

    install_apt_deps
    install_fzf
    install_terminfo
    install_nvm
    install_tree_sitter_cli
    install_neovim
    install_zsh_plugins
    install_zsh_config
    install_tmux_config
    install_nvim_config
    install_bat_config
    install_lsd_config
    install_btop_config

    echo ""
    read -p "❓ Set zsh as your default shell? [y/N] " confirm
    [[ "$confirm" == "y" ]] && set_default_shell

    success "Server dotfiles installed!"
    info "Run 'exec zsh' or log out and back in to use zsh"
    info "Run 'nvim' once to install plugins via vim.pack"
}

uninstall_server() {
    step "🗑️  Removing Server Dotfiles"

    echo "This will remove:"
    echo "  - ~/.zshenv, ~/.config/{zsh,tmux,nvim,bat,lsd,btop}/"
    echo "  - ~/.zsh/plugins/"
    echo "  - Neovim (~/.local/bin/nvim + its lib/share) and its state/cache"
    echo "  - CLIs installed to ~/.local/bin: fzf, tree-sitter"
    echo ""
    read -p "❓ Continue? [y/N] " confirm && [[ "$confirm" == "y" ]] || exit 1

    rm -f ~/.zshenv
    rm -rf ~/.config/zsh ~/.config/tmux ~/.config/nvim ~/.config/bat ~/.config/lsd ~/.config/btop
    rm -rf ~/.zsh/plugins

    # Neovim is installed as a tarball tree under ~/.local (bin/lib/share), not an AppImage.
    rm -f ~/.local/bin/nvim
    rm -rf ~/.local/lib/nvim ~/.local/share/nvim-linux-* 2>/dev/null || true
    rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim

    # CLIs installed via install_release_bin (gh/shfmt come from apt, not here)
    rm -f ~/.local/bin/fzf ~/.local/bin/tree-sitter

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
