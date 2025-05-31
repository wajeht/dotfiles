#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "Installing Tmux configuration..."

    check_directory_structure
    backup_file ~/.tmux.conf

    rm -f ~/.tmux.conf
    cp -f .tmux.conf ~/.tmux.conf

    success ".tmux.conf copied to ~/.tmux.conf"
}

main "$@"
