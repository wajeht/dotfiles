#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_lsd() {
    step "📁 Installing LSD Configuration"

    info "Installing LSD configuration..."
    mkdir -p ~/.config/lsd
    task "Created ~/.config/lsd directory"

    backup_if_exists ~/.config/lsd/config.yaml
    backup_if_exists ~/.config/lsd/colors.yaml

    local script_dir="$(dirname "$0")"
    cp "$script_dir/configs/lsd/config.yaml" ~/.config/lsd/config.yaml
    task "Copied config.yaml to ~/.config/lsd/"

    cp "$script_dir/configs/lsd/colors.yaml" ~/.config/lsd/colors.yaml
    task "Copied colors.yaml (VS Code Dark Modern theme) to ~/.config/lsd/"

    success "LSD configuration installed"
}

uninstall_lsd() {
    step "🗑️  Removing LSD Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/lsd/config.yaml"
    echo "   • ~/.config/lsd/colors.yaml"
    echo "   • ~/.config/lsd/ directory"
    echo "   • Note: LSD binary will remain installed"
    echo ""
    read -p "❓ Continue with LSD uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing LSD configuration files..."
    rm -f ~/.config/lsd/config.yaml ~/.config/lsd/colors.yaml
    rm -rf ~/.config/lsd
    task "Removed LSD configuration files"

    success "LSD configuration removed successfully!"
    info "💡 To reinstall: make lsd install"
    info "💡 To remove LSD binary: brew uninstall lsd"
}

main() {
    case "${1:-install}" in
    install)
        install_lsd
        ;;
    uninstall)
        uninstall_lsd
        ;;
    *)
        install_lsd
        ;;
    esac
}

main "$@"
