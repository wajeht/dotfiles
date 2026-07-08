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
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    [[ -f "$script_dir/configs/homebrew/Brewfile" && -d "$script_dir/configs" ]] || error "Run from dotfiles directory"
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
    if [[ -e "$1" ]]; then
        rm -rf "$1.backup"
        cp -a "$1" "$1.backup" # -a so directories (e.g. ~/.config/nvim) are backed up too
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

# Warn if tmux/fzf are too old for the sessionizer: the Ctrl+F popup needs tmux
# >= 3.2, and the "create session" line reads $FZF_QUERY (fzf >= 0.51).
check_sessionizer_deps() {
    local v
    if command -v tmux >/dev/null 2>&1; then
        v=$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [ "$(printf '%s\n3.2\n' "$v" | sort -V | head -1)" != "3.2" ]; then
            warning "tmux $v < 3.2: Ctrl+F popup binding will not work"
        fi
    fi
    if command -v fzf >/dev/null 2>&1; then
        v=$(fzf --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [ "$(printf '%s\n0.51\n' "$v" | sort -V | head -1)" != "0.51" ]; then
            warning "fzf $v < 0.51: sessionizer 'create session' line won't appear"
        fi
    fi
}

tmux_supports_sessionizer() {
    local v
    command -v tmux >/dev/null 2>&1 || return 1
    v=$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)
    [ "$(printf '%s\n3.2\n' "$v" | sort -V | head -1)" = "3.2" ]
}

# Echo the value matching this machine's architecture, e.g.
#   asset_arch=$(dl_arch amd64 arm64)      # gh / shfmt style
#   asset_arch=$(dl_arch x86_64 aarch64)   # rust-triple style
# Exits (via error) on an unsupported arch.
dl_arch() {
    local a
    a=$(uname -m)
    case "$a" in
    x86_64) printf '%s' "$1" ;;
    aarch64 | arm64) printf '%s' "$2" ;;
    *) error "Unsupported architecture: $a" ;;
    esac
}

# Download a release asset and install a single binary into ~/.local/bin.
#   install_release_bin <url> <bin-name>
# Archive type is inferred from the URL: .tar.gz/.tgz and .zip are extracted and
# the binary is located with find; .gz is gunzipped; anything else is treated as
# a raw binary. Uses a mktemp workdir (no fixed /tmp paths).
install_release_bin() {
    local url="$1" bin="$2"
    local tmp
    tmp=$(mktemp -d)
    mkdir -p "$HOME/.local/bin"
    local file="$tmp/${url##*/}"
    curl -fsSL "$url" -o "$file"
    case "$url" in
    *.tar.gz | *.tgz)
        tar -xzf "$file" -C "$tmp"
        local found
        found=$(find "$tmp" -type f -name "$bin" | head -1)
        [ -n "$found" ] || error "Could not find '$bin' in $(basename "$url")"
        cp "$found" "$HOME/.local/bin/$bin"
        ;;
    *.zip)
        unzip -q "$file" -d "$tmp"
        local found
        found=$(find "$tmp" -type f -name "$bin" | head -1)
        [ -n "$found" ] || error "Could not find '$bin' in $(basename "$url")"
        cp "$found" "$HOME/.local/bin/$bin"
        ;;
    *.gz)
        gzip -dc "$file" >"$HOME/.local/bin/$bin"
        ;;
    *)
        cp "$file" "$HOME/.local/bin/$bin"
        ;;
    esac
    chmod +x "$HOME/.local/bin/$bin"
    rm -rf "$tmp"
}
