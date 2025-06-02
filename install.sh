#!/bin/bash

source "$(dirname "$0")/scripts/common.sh"

run_component() {
    local script="$1"
    local name="$2"

    set +e
    if "$script"; then
        success "$name completed successfully"
        return 0
    else
        warning "$name encountered issues but installation continues"
        return 1
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
    run_component "./scripts/macos-defaults.sh" "macOS defaults" || failed_components+=("macOS defaults")
    run_component "./scripts/install-brew.sh" "Homebrew packages" || failed_components+=("Homebrew packages")
    run_component "./scripts/install-nvim.sh" "Neovim config" || failed_components+=("Neovim config")
    run_component "./scripts/install-gitconfig.sh" "Git config" || failed_components+=("Git config")
    run_component "./scripts/install-ghostty.sh" "Ghostty config" || failed_components+=("Ghostty config")
    run_component "./scripts/install-tmux.sh" "Tmux config" || failed_components+=("Tmux config")
    run_component "./scripts/install-zsh.sh" "Zsh config" || failed_components+=("Zsh config")

    step "🎉 Installation Complete!"

    if [[ ${#failed_components[@]} -eq 0 ]]; then
        success "All components installed successfully!"
    else
        warning "Some components had issues: ${failed_components[*]}"
        info "This is normal - you can retry individual components later if needed"
    fi

    info "Run 'source ~/.zshrc' or restart your terminal to apply changes"
}

main "$@"
