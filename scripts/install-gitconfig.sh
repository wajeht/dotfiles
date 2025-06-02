#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🔗 Installing Git Configuration"

    backup_if_exists ~/.gitconfig

    info "Installing .gitconfig..."
    cp .gitconfig ~/.gitconfig
    task "Copied .gitconfig to home directory"

    success "Git configuration installed"
}

main "$@"
