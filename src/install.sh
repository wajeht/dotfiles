#!/bin/bash

# Handle remote installation - download utilities first
if [[ "${1:-}" == "--remote" ]]; then
    set -euo pipefail

    readonly REPO_URL="https://github.com/wajeht/dotfiles.git"
    readonly UTIL_URL="https://raw.githubusercontent.com/wajeht/dotfiles/refs/heads/main/src/_util.sh"

    # Download _util.sh to temp location
    TEMP_UTIL=$(mktemp)
    if ! curl -fsSL "$UTIL_URL" >"$TEMP_UTIL"; then
        printf "💥 Failed to download utilities\n" >&2
        rm -f "$TEMP_UTIL"
        exit 1
    fi

    # Source utilities
    source "$TEMP_UTIL"

    cleanup() {
        [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
        rm -f "$TEMP_UTIL"
    }

    trap cleanup EXIT ERR INT TERM

    step "🌟 Remote Dotfiles Installation"
    info "This will:"
    info "  1. Clone the dotfiles repository"
    info "  2. Run the installation script"
    info "  3. Clean up temporary files"
    echo

    command -v git >/dev/null 2>&1 || error "git is required but not installed"
    [[ "$(uname)" == "Darwin" ]] || error "This script is designed for macOS"

    TEMP_DIR=$(mktemp -d)
    task "Created temporary directory: $TEMP_DIR"

    step "📥 Downloading Repository"
    if git clone "$REPO_URL" "$TEMP_DIR/dotfiles"; then
        success "Repository cloned successfully"
    else
        error "Failed to clone repository"
    fi

    cd "$TEMP_DIR/dotfiles"

    step "⚙️ Running Installation"
    if ./src/install.sh; then
        success "Installation completed successfully!"
    else
        error "Installation failed"
    fi

    step "🎉 Installation Complete!"
    info "To use the dotfiles, run 'source ~/.zshrc' or restart your terminal"
    info "💡 For individual component management, use: make <component> [install|uninstall]"

    exit 0
fi

# Normal installation - load utilities
source "$(dirname "$0")/_util.sh"

run_component() {
    local script="$1"
    local args="$2"
    local name="$3"

    set +e
    if [ -n "$args" ]; then
        if "$script" "$args"; then
            success "$name completed successfully"
            return 0
        else
            warning "$name encountered issues but installation continues"
            return 1
        fi
    else
        if "$script"; then
            success "$name completed successfully"
            return 0
        else
            warning "$name encountered issues but installation continues"
            return 1
        fi
    fi
    set -e
}

main() {
    step "🌟 Installing Dotfiles"

    info "Performing system checks..."
    check_macos
    check_directory
    check_internet
    check_xcode_tools

    task "Making scripts executable"
    chmod +x "$(dirname "$0")"/*.sh

    # Track component results
    local failed_components=()

    # Run each component, continuing even if some fail
    run_component "$(dirname "$0")/macos-defaults.sh" "" "macOS defaults" || failed_components+=("macOS defaults")
    run_component "$(dirname "$0")/brew.sh" "install" "Homebrew packages" || failed_components+=("Homebrew packages")
    run_component "$(dirname "$0")/nvim.sh" "install" "Neovim config" || failed_components+=("Neovim config")
    run_component "$(dirname "$0")/git.sh" "install" "Git config" || failed_components+=("Git config")
    run_component "$(dirname "$0")/ghostty.sh" "install" "Ghostty config" || failed_components+=("Ghostty config")
    run_component "$(dirname "$0")/zsh.sh" "install" "Zsh config" || failed_components+=("Zsh config")
    run_component "$(dirname "$0")/lsd.sh" "install" "LSD config" || failed_components+=("LSD config")
    run_component "$(dirname "$0")/bat.sh" "install" "Bat config" || failed_components+=("Bat config")

    step "🎉 Installation Complete!"

    if [[ ${#failed_components[@]} -eq 0 ]]; then
        success "All components installed successfully!"
    else
        warning "Some components had issues: ${failed_components[*]}"
        info "This is normal - you can retry individual components later with 'make <component>'"
    fi

    info "Run 'source ~/.zshrc' or restart your terminal to apply changes"
}

main "$@"
