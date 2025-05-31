#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    step "⚙️ Installing Git configuration"

    backup_if_exists ~/.gitconfig

    info "Installing .gitconfig..."
    cp .gitconfig ~/.gitconfig
    task "Copied .gitconfig to home directory"

    success "Git configuration installed"
}

main "$@"
