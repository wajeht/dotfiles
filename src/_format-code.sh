#!/bin/bash

source "$(dirname "$0")/_util.sh"

export PATH="$HOME/.local/bin:$PATH"

install_shfmt_linux() {
    install_release_bin "https://github.com/mvdan/sh/releases/download/v3.13.1/shfmt_v3.13.1_linux_amd64" shfmt
}

install_stylua_linux() {
    install_release_bin "https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-linux-x86_64.zip" stylua
}

install_if_missing() {
    local tool_name="$1"
    local brew_package="$2"
    local apt_package="${3:-$tool_name}"
    if ! command -v "$tool_name" &>/dev/null; then
        if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
            info "$tool_name not found. Attempting to install with Homebrew..."
            brew install "$brew_package"
        elif [[ "$(uname)" == "Linux" && "$tool_name" == "shfmt" ]]; then
            info "$tool_name not found. Attempting to install from GitHub releases..."
            install_shfmt_linux
        elif [[ "$(uname)" == "Linux" && "$tool_name" == "stylua" ]]; then
            info "$tool_name not found. Attempting to install from GitHub releases..."
            install_stylua_linux
        elif [[ "$(uname)" == "Linux" ]] && command -v apt-get &>/dev/null && apt-cache show "$apt_package" &>/dev/null; then
            info "$tool_name not found. Attempting to install with apt..."
            sudo apt-get update -qq
            sudo apt-get install -y "$apt_package"
        else
            error "No installer available for $tool_name on this system. Please install it manually."
            return 1
        fi

        if command -v "$tool_name" &>/dev/null; then
            success "$tool_name installed successfully."
        else
            error "Failed to install $tool_name. Please install it manually."
            return 1
        fi
    fi
    return 0
}

format_bash_files() {
    step "💅 Formatting Bash files"
    if ! install_if_missing "shfmt" "shfmt"; then
        return 1
    fi

    info "Finding and formatting Bash files (.sh, .bash)..."
    find . -type d -name ".git" -prune -o \
        \( -name "*.sh" -o -name "*.bash" \) -print0 | while IFS= read -r -d $'\0' file; do
        if [[ -f "$file" ]]; then
            task "Formatting $file"
            shfmt -w -i 4 "$file"
        fi
    done
    success "Bash files formatting complete."
}

format_lua_files() {
    step "💅 Formatting Lua files"
    if ! install_if_missing "stylua" "stylua"; then
        return 1
    fi

    info "Finding and formatting Lua files (.lua)..."
    find . -type d -name ".git" -prune -o -name "*.lua" -print0 | while IFS= read -r -d $'\0' file; do
        if [[ -f "$file" ]]; then
            task "Formatting $file"
            stylua "$file"
        fi
    done
    success "Lua files formatting complete."
}

main() {
    step "💅 Starting code formatting"

    format_bash_files
    format_lua_files

    success "🎉 All formatting complete!"
}

main "$@"
