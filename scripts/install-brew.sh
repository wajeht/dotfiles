#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

install_homebrew() {
    if is_homebrew_installed; then
        success "Homebrew already installed"
        return 0
    fi

    echo "Installing Homebrew..."
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        error "Failed to install Homebrew"
    fi

    setup_homebrew_path
    success "Homebrew installed successfully"
}

install_packages() {
    echo "Installing packages from Brewfile..."

    # Update Homebrew
    if ! brew update; then
        warning "Failed to update Homebrew, continuing anyway..."
    fi

    # Install packages
    if ! brew bundle --file=Brewfile; then
        error "Failed to install some packages from Brewfile"
    fi

    success "All packages installed successfully"
}

main() {
    echo "🍺 Installing Homebrew and packages..."

    check_macos
    check_internet
    check_directory_structure
    check_command_line_tools

    install_homebrew
    install_packages

    success "Homebrew installation complete!"
}

main "$@"
