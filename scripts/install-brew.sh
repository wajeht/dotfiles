#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "📦 Installing Homebrew & Packages"

    if ! has_brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        setup_brew_path
        success "Homebrew installed"
    else
        task "Homebrew already installed"
    fi

    info "Installing packages from Brewfile (skipping upgrades)..."

    # Temporarily disable exit on error to handle brew bundle failures gracefully
    set +e
    brew bundle --file=Brewfile --no-upgrade
    local exit_code=$?
    set -e

    # Check the result and provide appropriate feedback
    if [[ $exit_code -eq 0 ]]; then
        success "All packages installed successfully (existing packages not upgraded)"
    else
        warning "Some packages failed to install (exit code: $exit_code)"
        info "This is normal - some packages may not be available or may have conflicts"
        info "The installation will continue with other components"
        success "Available packages installed (existing packages not upgraded)"
    fi
}

main "$@"
