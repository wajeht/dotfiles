#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "🍺 Installing Homebrew and packages..."

    # Install Homebrew if needed
    if ! has_brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        setup_brew_path
    fi

    # Install packages
    echo "Installing packages from Brewfile..."
    brew bundle --file=Brewfile

    success "Homebrew installation complete!"
}

main "$@"
