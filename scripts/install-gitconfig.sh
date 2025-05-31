#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "⚙️ Installing Git configuration..."

    backup_if_exists ~/.gitconfig
    cp .gitconfig ~/.gitconfig

    success "Git configuration installed!"
}

main "$@"
