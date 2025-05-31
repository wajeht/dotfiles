#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "🪟 Installing Tmux configuration..."

    backup_if_exists ~/.tmux.conf
    cp .tmux.conf ~/.tmux.conf

    success "Tmux configuration installed!"
}

main "$@"
