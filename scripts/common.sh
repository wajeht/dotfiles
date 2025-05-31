#!/bin/bash

# Common functions library for dotfiles installation scripts
# Source this file in other scripts to avoid code duplication

# Strict error handling
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# System check functions
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This script is designed for macOS only"
    fi
    return 0
}

check_macos_version() {
    local macos_version
    macos_version=$(sw_vers -productVersion)

    # Extract major version (e.g., 15 from 15.5, 10 from 10.15.7)
    local major_version
    major_version=$(echo "$macos_version" | cut -d. -f1)

    # macOS 11+ or macOS 10.15+
    if [[ $major_version -ge 11 ]] || [[ $major_version -eq 10 && $(echo "$macos_version" | cut -d. -f2) -ge 15 ]]; then
        success "macOS version check passed: $macos_version"
        return 0
    else
        error "macOS 10.15 (Catalina) or later required. Current version: $macos_version"
    fi
}

check_internet() {
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        error "No internet connection. Please check your network."
    fi
    return 0
}

check_directory_structure() {
    local required_files=("Makefile" "Brewfile")
    local required_dirs=(".config")

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "$file not found. Please run from the dotfiles directory."
        fi
    done

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            error "$dir directory not found. Please run from the dotfiles directory."
        fi
    done

    return 0
}

check_command_line_tools() {
    if ! xcode-select -p >/dev/null 2>&1; then
        warning "Command Line Tools not installed. Installing..."
        xcode-select --install
        echo "Please rerun this script after Command Line Tools installation completes."
        exit 0
    fi
    return 0
}

# File operations
make_executable() {
    local file="$1"
    if [[ ! -x "$file" ]]; then
        chmod +x "$file"
        info "Made $file executable"
    fi
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        success "Backed up existing $file to $backup"
    fi
}

# Safe application restart
safe_killall() {
    local app="$1"
    if pgrep "$app" >/dev/null 2>&1; then
        killall "$app" || warning "Failed to restart $app"
    fi
}

# Homebrew helpers
setup_homebrew_path() {
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        error "Homebrew installation completed but brew command not found"
    fi
}

# Check if Homebrew is installed
is_homebrew_installed() {
    command -v brew >/dev/null 2>&1
}

# macOS defaults helpers
set_default() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local value="$4"
    local description="$5"

    if defaults write "$domain" "$key" -"$type" "$value"; then
        return 0
    else
        warning "Failed to set $description"
        return 1
    fi
}
