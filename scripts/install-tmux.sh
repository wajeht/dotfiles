#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🖥️ Installing Tmux Configuration"

    backup_if_exists ~/.tmux.conf

    info "Installing .tmux.conf..."
    cp .tmux.conf ~/.tmux.conf
    task "Copied .tmux.conf to home directory"

    tmux source-file ~/.tmux.conf

    success "Tmux configuration installed"
}

main "$@"
