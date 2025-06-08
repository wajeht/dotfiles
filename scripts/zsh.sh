#!/bin/bash

source "$(dirname "$0")/common.sh"

fix_completion_permissions() {
    info "Fixing zsh completion permissions..."

    # Check if Homebrew share directory exists and fix permissions
    if [[ -d "/opt/homebrew/share" ]]; then
        if [[ -w "/opt/homebrew/share" ]]; then
            chmod go-w /opt/homebrew/share 2>/dev/null || true
            task "Fixed /opt/homebrew/share permissions"
        else
            task "/opt/homebrew/share permissions already secure"
        fi
    fi

    # Check for Intel Homebrew path as well
    if [[ -d "/usr/local/share" ]]; then
        if [[ -w "/usr/local/share" ]]; then
            chmod go-w /usr/local/share 2>/dev/null || true
            task "Fixed /usr/local/share permissions"
        else
            task "/usr/local/share permissions already secure"
        fi
    fi

    # Verify no insecure directories remain
    if command -v compaudit >/dev/null 2>&1; then
        local insecure_dirs
        insecure_dirs=$(compaudit 2>/dev/null | grep -v "There are insecure directories:" | head -5)
        if [[ -n "$insecure_dirs" ]]; then
            warning "Some completion directories may still be insecure:"
            echo "$insecure_dirs" | while read -r dir; do
                if [[ -n "$dir" ]]; then
                    task "Run: chmod go-w '$dir' (if needed)"
                fi
            done
        else
            task "All completion directories are secure"
        fi
    fi
}

install_zsh() {
    step "💻 Installing Zsh Configuration"

    backup_if_exists ~/.zshrc

    info "Installing Zsh modules..."
    mkdir -p ~/.config/zsh
    cp -r .config/zsh/* ~/.config/zsh/
    task "Copied modules to ~/.config/zsh/"

    info "Zsh plugins will be loaded from Homebrew installations..."
    task "Plugins: zsh-vi-mode, zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting"
    info "Using native Zsh configuration (no Oh My Zsh overhead)"

    info "Installing .zshrc..."
    cp .zshrc ~/.zshrc
    task "Copied .zshrc to home directory"

    # Fix completion permissions to prevent security warnings
    fix_completion_permissions

    info "Copying reload command to clipboard"
    echo "source ~/.zshrc" | pbcopy
    task "Command copied to clipboard. Paste and run it, or restart your terminal."

    success "Zsh configuration installed"
    info "💡 Don't forget to install Starship prompt: make starship install"
}

uninstall_zsh() {
    step "🗑️  Removing Zsh Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.zshrc"
    echo "   • ~/.config/zsh/ directory"
    echo "   • ~/.zsh_history (optional)"
    echo ""
    read -p "❓ Continue with Zsh uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
    echo ""

    info "Creating backup of current config..."
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) && task "✅ ~/.zshrc backed up"
    fi

    info "Removing Zsh config files..."
    rm -f ~/.zshrc
    rm -rf ~/.config/zsh
    task "Removed Zsh configuration files"

    echo ""
    read -p "❓ Also remove Zsh history? [y/N] " confirm && [ "$confirm" = "y" ] && rm -f ~/.zsh_history && task "🗑️  Zsh history removed" || task "📝 Zsh history preserved"
    echo ""

    success "Zsh configuration removed successfully!"
    info "💡 To reinstall: make zsh install"
}

main() {
    case "${1:-install}" in
    install)
        install_zsh
        ;;
    uninstall)
        uninstall_zsh
        ;;
    *)
        install_zsh
        ;;
    esac
}

main "$@"
