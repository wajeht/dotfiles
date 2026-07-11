#!/bin/bash

source "$(dirname "$0")/../scripts/utils.sh"

# Homebrew refuses to load formulae from untrusted third-party taps, and
# `brew bundle` aborts on the FIRST one it hits — skipping everything listed
# after it (all casks included). Pre-trust every tap the Brewfile pulls a
# formula from (the owner/repo/formula entries) so the bundle runs to the end.
trust_brewfile_taps() {
    local brewfile="$1" tap
    while IFS= read -r tap; do
        [ -n "$tap" ] || continue
        brew tap "$tap" >/dev/null 2>&1 || true
        if brew trust "$tap" >/dev/null 2>&1; then
            task "Trusted tap $tap"
        fi
    done < <(grep -oE 'brew "[^"]+/[^"]+/[^"]+"' "$brewfile" | sed -E 's/.*"([^/]+\/[^/]+)\/.*/\1/' | sort -u)
}

install_brew() {
    step "📦 Installing Homebrew & Packages"

    if ! has_brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        setup_brew_path
        success "Homebrew installed"
    else
        task "Homebrew already installed"
    fi

    trust_brewfile_taps "$(dirname "$0")/Brewfile"

    info "Installing packages from Brewfile (skipping upgrades)..."

    # Temporarily disable exit on error to handle brew bundle failures gracefully
    set +e
    brew bundle --file="$(dirname "$0")/Brewfile" --no-upgrade
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        success "All packages installed successfully (existing packages not upgraded)"
    else
        warning "Some packages failed to install (exit code: $exit_code)"
        info "This is normal - some packages may not be available or may have conflicts"
        info "The installation will continue with other components"
        success "Available packages installed (existing packages not upgraded)"
    fi
}

uninstall_brew() {
    step "🗑️  Removing Homebrew Packages from Brewfile"

    echo "⚠️  This will uninstall ALL packages listed in Brewfile"
    echo "📋 Homebrew itself will remain installed"
    echo ""
    read -p "❓ Continue? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Homebrew packages..."
    brew bundle cleanup --file="$(dirname "$0")/Brewfile" --force
    task "Removed packages from Brewfile"

    success "Homebrew packages removed"
    info "💡 To reinstall packages: make brew install"
    info "💡 To remove Homebrew entirely: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)\""
}

main() {
    case "${1:-install}" in
    install)
        install_brew
        ;;
    uninstall)
        uninstall_brew
        ;;
    *)
        install_brew
        ;;
    esac
}

main "$@"
