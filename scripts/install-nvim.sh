#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "📝 Installing Neovim configuration..."

    mkdir -p ~/.config/nvim
    cp -r .config/nvim/* ~/.config/nvim/

    success "Neovim configuration installed!"
}

main "$@"
