#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_if_missing() {
    local tool_name="$1"
    local install_command="$2"
    if ! command -v "$tool_name" &>/dev/null; then
        info "$tool_name not found. Attempting to install with Homebrew..."
        if $install_command; then
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
    if ! install_if_missing "shfmt" "brew install shfmt"; then
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
    if ! install_if_missing "stylua" "brew install stylua"; then
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
