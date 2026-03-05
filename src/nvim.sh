#!/bin/bash

source "$(dirname "$0")/_util.sh"

get_bob_target() {
    local target_file="$(cd "$(dirname "$0")" && pwd)/configs/nvim/.bob-version"

    if [ ! -f "$target_file" ]; then
        error "Bob target file not found: $target_file"
    fi

    local target
    target="$(tr -d '[:space:]' <"$target_file")"

    if [ -z "$target" ]; then
        error "Bob target file is empty: $target_file"
    fi

    # Allow users to paste the raw first line from `nvim --version`.
    target="${target#NVIM }"

    printf "%s" "$target"
}

extract_expected_hash() {
    local raw="$1"

    if [[ "$raw" =~ \+g([0-9a-fA-F]+)$ ]]; then
        printf "%s" "${BASH_REMATCH[1],,}"
        return
    fi

    if [[ "$raw" =~ ^nightly@([0-9a-fA-F]+)$ ]]; then
        printf "%s" "${BASH_REMATCH[1],,}"
        return
    fi
}

resolve_bob_install_target() {
    local raw="$1"

    # Bob can't parse numeric-leading commit hashes directly, so pinned dev
    # versions are resolved through nightly and then verified post-install.
    if [[ "$raw" =~ \+g[0-9a-fA-F]+$ ]] || [[ "$raw" =~ ^nightly@[0-9a-fA-F]+$ ]]; then
        printf "%s" "nightly"
        return
    fi

    printf "%s" "$raw"
}

verify_pinned_nvim() {
    local raw="$1"
    local expected_hash
    expected_hash="$(extract_expected_hash "$raw")"

    if [ -z "$expected_hash" ]; then
        return
    fi

    if ! command -v nvim >/dev/null 2>&1; then
        error "nvim not found while verifying pinned version"
    fi

    local actual_line
    actual_line="$(nvim --version | head -1)"

    local actual_hash=""
    if [[ "$actual_line" =~ g([0-9a-fA-F]+)$ ]]; then
        actual_hash="${BASH_REMATCH[1],,}"
    else
        error "Could not parse hash from nvim version line: $actual_line"
    fi

    if [ "$actual_hash" != "$expected_hash" ]; then
        error "Pinned Neovim hash mismatch. Expected g$expected_hash from '$raw', got: $actual_line"
    fi

    # If the full dev version is pinned, enforce exact string match too.
    if [[ "$raw" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-dev-[0-9]+\+g[0-9a-fA-F]+$ ]]; then
        local expected_line="NVIM $raw"
        if [ "$actual_line" != "$expected_line" ]; then
            error "Pinned Neovim version mismatch. Expected '$expected_line', got: '$actual_line'"
        fi
    fi
}

install_nvim_binary() {
    step "📦 Installing Neovim Binary (bob)"

    if ! command -v bob >/dev/null 2>&1; then
        error "bob not found. Install it first (e.g. brew install bob)."
    fi

    local raw_target
    raw_target="$(get_bob_target)"
    local target
    target="$(resolve_bob_install_target "$raw_target")"

    info "Pinned target from dotfiles: $raw_target"
    if [ "$target" != "$raw_target" ]; then
        info "Resolved bob install target: $target"
    fi
    info "Installing bob target: $target"
    bob install "$target"
    bob use "$target"
    task "Installed and activated: $target"

    if command -v nvim >/dev/null 2>&1; then
        task "$(nvim --version | head -1)"
    fi

    verify_pinned_nvim "$raw_target"

    success "Neovim binary installed via bob"
}

update_nvim_binary() {
    step "🔄 Updating Neovim Binary (bob)"

    if ! command -v bob >/dev/null 2>&1; then
        error "bob not found. Install it first (e.g. brew install bob)."
    fi

    local raw_target
    raw_target="$(get_bob_target)"
    local target
    target="$(resolve_bob_install_target "$raw_target")"
    local expected_hash
    expected_hash="$(extract_expected_hash "$raw_target")"

    info "Pinned target from dotfiles: $raw_target"
    if [ "$target" != "$raw_target" ]; then
        info "Resolved bob update target: $target"
    fi

    if [ -n "$expected_hash" ]; then
        info "Exact pin detected; using install+verify for reproducibility."
        bob install "$target"
    else
        info "Updating bob target: $target"
        bob update "$target"
    fi

    bob use "$target"
    task "Updated and activated: $target"

    if command -v nvim >/dev/null 2>&1; then
        task "$(nvim --version | head -1)"
    fi

    verify_pinned_nvim "$raw_target"

    success "Neovim binary updated via bob"
}

status_nvim_binary() {
    step "🧾 Neovim Binary Status (bob)"

    if ! command -v bob >/dev/null 2>&1; then
        error "bob not found. Install it first (e.g. brew install bob)."
    fi

    local raw_target
    raw_target="$(get_bob_target)"
    local target
    target="$(resolve_bob_install_target "$raw_target")"
    local expected_hash
    expected_hash="$(extract_expected_hash "$raw_target")"

    info "Pinned target from dotfiles: $raw_target"
    if [ "$target" != "$raw_target" ]; then
        info "Resolved bob target: $target"
    fi
    bob list

    if command -v nvim >/dev/null 2>&1; then
        local actual_line
        actual_line="$(nvim --version | head -1)"
        info "Current nvim:"
        echo "$actual_line"

        if [ -n "$expected_hash" ]; then
            local actual_hash=""
            if [[ "$actual_line" =~ g([0-9a-fA-F]+)$ ]]; then
                actual_hash="${BASH_REMATCH[1],,}"
            fi
            if [ "$actual_hash" = "$expected_hash" ]; then
                success "Pinned hash matches: g$expected_hash"
            else
                warning "Pinned hash mismatch: expected g$expected_hash"
            fi
        fi
    fi
}

install_nvim() {
    step "⚡ Installing Neovim Configuration"

    local config_nvim="$HOME/.config/nvim"
    local dotfiles_nvim="$(cd "$(dirname "$0")" && pwd)/configs/nvim"

    # Check if already symlinked to dotfiles
    if [ -L "$config_nvim" ]; then
        local current_target=$(readlink "$config_nvim")
        if [ "$current_target" = "$dotfiles_nvim" ]; then
            success "Neovim config already linked to dotfiles (no copy needed)"
            return 0
        fi
    fi

    info "Installing Neovim configuration..."
    mkdir -p ~/.config/nvim
    cp -r "$dotfiles_nvim/"* ~/.config/nvim/
    task "Copied configuration to ~/.config/nvim/"

    info "Cleaning LSP/Mason cache to prevent conflicts..."
    rm -rf ~/.local/share/nvim/mason 2>/dev/null || true
    rm -rf ~/.local/state/nvim/mason.log 2>/dev/null || true
    rm -rf ~/.cache/nvim/lsp.log* 2>/dev/null || true
    task "Cleaned LSP/Mason cache"

    success "Neovim configuration installed"
}

link_nvim() {
    step "🔗 Linking Neovim Configuration"

    local dotfiles_nvim="$(cd "$(dirname "$0")" && pwd)/configs/nvim"
    local config_nvim="$HOME/.config/nvim"

    if [ ! -d "$dotfiles_nvim" ]; then
        error "Neovim config not found in dotfiles: $dotfiles_nvim"
        exit 1
    fi

    if [ -L "$config_nvim" ]; then
        local current_target=$(readlink "$config_nvim")
        if [ "$current_target" = "$dotfiles_nvim" ]; then
            success "Neovim config already linked to dotfiles"
            return 0
        else
            warning "Neovim config is linked to: $current_target"
            read -p "❓ Replace with dotfiles link? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
            rm "$config_nvim"
        fi
    elif [ -d "$config_nvim" ]; then
        warning "Existing Neovim config found at $config_nvim"
        read -p "❓ Back up and replace with symlink? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
        mv "$config_nvim" "$config_nvim.backup.$(date +%Y%m%d-%H%M%S)"
        task "Backed up existing config"
    fi

    mkdir -p ~/.config
    ln -s "$dotfiles_nvim" "$config_nvim"
    task "Created symlink: ~/.config/nvim -> $dotfiles_nvim"

    success "Neovim configuration linked to dotfiles"
}

unlink_nvim() {
    step "🔓 Unlinking Neovim Configuration"

    local config_nvim="$HOME/.config/nvim"

    if [ ! -L "$config_nvim" ]; then
        if [ -d "$config_nvim" ]; then
            warning "Neovim config is not a symlink"
        else
            warning "No Neovim config found at $config_nvim"
        fi
        exit 1
    fi

    local link_target=$(readlink "$config_nvim")
    info "Current symlink: $config_nvim -> $link_target"
    read -p "❓ Remove symlink? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    rm "$config_nvim"
    task "Removed symlink"

    success "Neovim configuration unlinked"
    info "💡 To restore: make nvim link or make nvim install"
}

uninstall_nvim() {
    step "🧹 Cleaning Neovim Configuration and Caches"

    echo "📋 This will remove:"
    echo "   • ~/.config/nvim/ (configuration)"
    echo "   • ~/.cache/nvim/ (cache files)"
    echo "   • ~/.local/share/nvim/ (data files)"
    echo "   • ~/.local/state/nvim/ (state files)"
    echo "   • Plugin manager caches (lazy, mason)"
    echo ""
    read -p "❓ Continue with Neovim cleanup? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Neovim configuration and caches..."
    rm -rf ~/.config/nvim
    rm -rf ~/.cache/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/lazy
    rm -rf ~/.cache/mason
    rm -rf ~/.local/share/nvim/mason
    rm -rf ~/.local/share/nvim/lazy
    rm -rf ~/.local/share/nvim/site
    task "Removed Neovim files and directories"

    info "Clearing npm cache..."
    npm cache clean --force 2>/dev/null || true
    task "Cleared npm cache"

    success "Neovim configuration and caches cleaned!"
    info "💡 To reinstall: make nvim install"
    info "💡 Restart Neovim after reinstall to download plugins"
}

main() {
    case "${1:-install}" in
    install)
        install_nvim
        ;;
    install-bin | bin)
        install_nvim_binary
        ;;
    update-bin)
        update_nvim_binary
        ;;
    status-bin)
        status_nvim_binary
        ;;
    link)
        link_nvim
        ;;
    unlink)
        unlink_nvim
        ;;
    uninstall)
        uninstall_nvim
        ;;
    *)
        install_nvim
        ;;
    esac
}

main "$@"
