#!/bin/bash

# Common functions library for dotfiles installation scripts
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Logging functions
error() {
    echo -e "${RED}❌ Error:${NC} $1" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

info() {
    echo -e "${BLUE}ℹ️${NC}  $1"
}

step() {
    echo -e "\n${BOLD}$1${NC}"
}

task() {
    echo -e "${DIM}→${NC} $1"
}

# Essential system checks (for install.sh only)
check_macos() {
    [[ "$(uname)" == "Darwin" ]] || error "macOS required"
}

check_internet() {
    ping -c 1 github.com >/dev/null 2>&1 || error "No internet connection"
}

check_directory() {
    [[ -f "Brewfile" && -d ".config" ]] || error "Run from dotfiles directory"
}

check_xcode_tools() {
    if ! xcode-select -p >/dev/null 2>&1; then
        warning "Installing Command Line Tools..."
        xcode-select --install
        echo "Rerun after installation completes."
        exit 0
    fi
}

# Simple file operations
backup_if_exists() {
    if [[ -f "$1" ]]; then
        cp "$1" "$1.backup"
        task "Backed up existing $(basename "$1")"
    fi
}

# Homebrew helpers
setup_brew_path() {
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

has_brew() {
    command -v brew >/dev/null 2>&1
}

# macOS defaults helper
set_default() {
    local domain="$1" key="$2" type="$3" value="$4"
    if defaults write "$domain" "$key" -"$type" "$value" 2>/dev/null; then
        task "Set $key"
    else
        warning "Failed to set $key"
    fi
}
