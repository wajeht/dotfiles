#!/bin/bash

source "$(dirname "$0")/../scripts/utils.sh"

install_monaco_nerd_font() {
    info "Installing Monaco Nerd Font Mono..."

    local font_dir
    case "$(uname)" in
    Darwin)
        font_dir="$HOME/Library/Fonts"
        ;;
    *)
        font_dir="$HOME/.local/share/fonts"
        ;;
    esac

    if find "$font_dir" -maxdepth 1 -name 'MonacoNerdFontMono-*.ttf' -print -quit 2>/dev/null | grep -q .; then
        task "Monaco Nerd Font Mono already installed"
        return
    fi

    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL "https://github.com/thep0y/monaco-nerd-font/releases/download/v0.2.2/MonacoNerdFontMono.zip" -o "$tmp/MonacoNerdFontMono.zip"
    unzip -q "$tmp/MonacoNerdFontMono.zip" 'MonacoNerdFontMono-*.ttf' -d "$tmp/fonts"

    mkdir -p "$font_dir"
    cp "$tmp"/fonts/MonacoNerdFontMono-*.ttf "$font_dir/"
    rm -rf "$tmp"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir"
    fi

    task "Installed Monaco Nerd Font Mono to $font_dir"
}

install_ghostty() {
    step "🖼️ Installing Ghostty Configuration"

    install_monaco_nerd_font

    info "Installing Ghostty configuration..."
    backup_if_exists ~/.config/ghostty # consistent with the other component installers
    mkdir -p ~/.config/ghostty
    local config_dir
    config_dir="$(dirname "$0")"
    cp -r "$config_dir/"* ~/.config/ghostty/
    if [[ "$(uname)" != "Darwin" ]]; then
        cp "$config_dir/config.linux" ~/.config/ghostty/config
        task "Selected config.linux"
    fi
    # Drop platform variants and this module's own installer — none are ghostty config.
    rm -f ~/.config/ghostty/config.linux ~/.config/ghostty/config.local ~/.config/ghostty/config.macos ~/.config/ghostty/install.sh
    task "Copied configuration to ~/.config/ghostty/"

    success "Ghostty configuration installed"
}

uninstall_ghostty() {
    step "🗑️  Removing Ghostty Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/ghostty/ directory"
    echo "   • All Ghostty configuration files"
    echo ""
    read -p "❓ Continue with Ghostty uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Ghostty configuration..."
    rm -rf ~/.config/ghostty
    task "Removed ~/.config/ghostty/"

    success "Ghostty configuration removed successfully!"
    info "💡 To reinstall: make ghostty install"
}

main() {
    case "${1:-install}" in
    install)
        install_ghostty
        ;;
    uninstall)
        uninstall_ghostty
        ;;
    *)
        install_ghostty
        ;;
    esac
}

main "$@"
