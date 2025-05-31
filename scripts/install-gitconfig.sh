#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "Installing Git configuration..."

    check_directory_structure
    backup_file ~/.gitconfig

    rm -f ~/.gitconfig
    cp -f .gitconfig ~/.gitconfig

    success ".gitconfig copied to ~/.gitconfig"
}

main "$@"
