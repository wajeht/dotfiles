#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "👻 Installing Ghostty configuration"

    info "Installing Ghostty configuration..."
    mkdir -p ~/.config/ghostty
    cp -r .config/ghostty/* ~/.config/ghostty/
    task "Copied configuration to ~/.config/ghostty/"

    success "Ghostty configuration installed"
}

main "$@"
