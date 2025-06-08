#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "📁 Installing LSD Configuration"

    info "Installing LSD configuration..."
    mkdir -p ~/.config/lsd
    task "Created ~/.config/lsd directory"

    backup_if_exists ~/.config/lsd/config.yaml
    backup_if_exists ~/.config/lsd/colors.yaml

    cp .config/lsd/config.yaml ~/.config/lsd/config.yaml
    task "Copied config.yaml to ~/.config/lsd/"

    cp .config/lsd/colors.yaml ~/.config/lsd/colors.yaml
    task "Copied colors.yaml (VS Code Dark Modern theme) to ~/.config/lsd/"

    success "LSD configuration installed"
}

main "$@"
