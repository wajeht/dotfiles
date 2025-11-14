#!/bin/bash

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

error() {
    printf "${RED}💥 Error:${NC} %s\n" "$1" >&2
    exit 1
}

success() {
    printf "  ${GREEN}🎯${NC} %s\n" "$1"
}

warning() {
    printf "  ${YELLOW}⚡${NC} %s\n" "$1"
}

info() {
    printf "  ${BLUE}💡${NC} %s\n" "$1"
}

step() {
    printf "\n${BOLD}%s${NC}\n" "$1"
}

task() {
    printf "    ${DIM}▶${NC} %s\n" "$1"
}

check_macos() {
    [[ "$(uname)" == "Darwin" ]] || error "macOS required"
}

check_internet() {
    ping -c 1 github.com >/dev/null 2>&1 || error "No internet connection"
}

check_directory() {
    [[ -f ".config/homebrew/Brewfile" && -d ".config" ]] || error "Run from dotfiles directory"
}

check_xcode_tools() {
    if ! xcode-select -p >/dev/null 2>&1; then
        warning "Installing Command Line Tools..."
        xcode-select --install
        echo "Rerun after installation completes."
        exit 0
    fi
}

backup_if_exists() {
    if [[ -f "$1" ]]; then
        cp "$1" "$1.backup"
        task "Backed up existing $(basename "$1")"
    fi
}

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

set_default() {
    local domain="$1" key="$2" type="$3" value="$4"
    if defaults write "$domain" "$key" -"$type" "$value" 2>/dev/null; then
        task "Set $key"
    else
        warning "Failed to set $key"
    fi
}
