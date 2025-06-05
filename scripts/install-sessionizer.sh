#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

main() {

    step "Installing tmux sessionizer..."

    mkdir -p ~/.config/scripts

    if [[ -f ".config/scripts/tmux-sessionizer.sh" ]]; then
        cp .config/scripts/tmux-sessionizer.sh ~/.config/scripts/
        task "Copied tmux-sessionizer.sh to ~/.config/scripts/"
    else
        error "tmux-sessionizer.sh not found in .config/scripts/"
    fi

    chmod +x ~/.config/scripts/tmux-sessionizer.sh
    task "Made script executable"

    success "tmux sessionizer installed successfully!"
}

main "$@"
