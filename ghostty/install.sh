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
    mkdir -p ~/.config/ghostty
    backup_if_exists ~/.config/ghostty/config
    local config_dir
    config_dir="$(dirname "$0")"
    # Deploy only the active config. config.linux/.macos are platform sources, and
    # the terminfo/palette/install.sh alongside them aren't ghostty config. Copying
    # just `config` also leaves any user-managed ~/.config/ghostty/config.local intact.
    if [[ "$(uname)" == "Darwin" ]]; then
        cp "$config_dir/config" ~/.config/ghostty/config
    else
        cp "$config_dir/config.linux" ~/.config/ghostty/config
        task "Selected config.linux"
    fi
    task "Copied configuration to ~/.config/ghostty/"

    # Custom shaders (e.g. the trailing cursor). custom-shader paths in the
    # config are relative to ~/.config/ghostty/, so mirror ghostty/shaders/ there.
    if compgen -G "$config_dir/shaders/*.glsl" >/dev/null; then
        mkdir -p ~/.config/ghostty/shaders
        cp "$config_dir"/shaders/*.glsl ~/.config/ghostty/shaders/
        task "Copied shaders to ~/.config/ghostty/shaders/"
    fi

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
