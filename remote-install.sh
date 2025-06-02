#!/bin/bash

set -euo pipefail

readonly REPO_URL="https://github.com/wajeht/dotfiles.git"
readonly SCRIPT_NAME="$(basename "$0")"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

error() {
    echo -e "${RED}❌ Error:${NC} $1" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ️${NC}  $1"
}

step() {
    echo -e "\n${BOLD}$1${NC}"
}

task() {
    echo -e "${BLUE}→${NC} $1"
}

cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        task "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
        success "Cleanup complete"
    fi
}

check_dependencies() {
    command -v git >/dev/null 2>&1 || error "git is required but not installed"
    [[ "$(uname)" == "Darwin" ]] || error "This script is designed for macOS"
}

main() {
    step "🚀 Remote Dotfiles Installation"

    info "This script will:"
    info "  1. Create a temporary directory"
    info "  2. Clone the dotfiles repository"
    info "  3. Run the installation script"
    info "  4. Clean up temporary files"
    echo

    # Set up cleanup trap
    trap cleanup EXIT ERR INT TERM

    check_dependencies

    TEMP_DIR=$(mktemp -d)
    task "Created temporary directory: $TEMP_DIR"

    step "📦 Cloning dotfiles repository"
    if git clone "$REPO_URL" "$TEMP_DIR/dotfiles"; then
        success "Repository cloned successfully"
    else
        error "Failed to clone repository"
    fi

    cd "$TEMP_DIR/dotfiles"

    chmod +x install.sh

    step "🔧 Running installation script"
    if ./install.sh; then
        success "Installation completed successfully!"
    else
        error "Installation failed"
    fi

    step "🎉 Remote installation complete!"
    info "The temporary directory will be cleaned up automatically"
    echo
    info "To use the dotfiles, run 'source ~/.zshrc' or restart your terminal"
}

main "$@"
