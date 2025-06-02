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

    info "Installing packages from Brewfile..."
    brew bundle --file=Brewfile

    success "All packages installed"
}

main "$@"
