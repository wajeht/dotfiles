#!/bin/bash

source "$(dirname "$0")/scripts/common.sh"

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
    chmod +x scripts/*.sh

    # Track component results
    local failed_components=()

    # Run each component, continuing even if some fail
    run_component "./scripts/macos-defaults.sh" "" "macOS defaults" || failed_components+=("macOS defaults")
    run_component "./scripts/brew.sh" "install" "Homebrew packages" || failed_components+=("Homebrew packages")
    run_component "./scripts/nvim.sh" "install" "Neovim config" || failed_components+=("Neovim config")
    run_component "./scripts/git.sh" "install" "Git config" || failed_components+=("Git config")
    run_component "./scripts/ghostty.sh" "install" "Ghostty config" || failed_components+=("Ghostty config")
    run_component "./scripts/tmux.sh" "install" "Tmux config" || failed_components+=("Tmux config")
    run_component "./scripts/zsh.sh" "install" "Zsh config" || failed_components+=("Zsh config")
    run_component "./scripts/starship.sh" "install" "Starship config" || failed_components+=("Starship config")
    run_component "./scripts/lsd.sh" "install" "LSD config" || failed_components+=("LSD config")

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
