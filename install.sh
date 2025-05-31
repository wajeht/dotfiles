#!/bin/bash

# Main dotfiles installation script
# Performs system checks and runs installation in correct order

# Source common functions
source "$(dirname "$0")/scripts/common.sh"

# System checks
check_system() {
    info "Performing system checks..."

    check_macos

    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    info "macOS version: $macos_version"

    # Check available disk space (require at least 1GB)
    local available_space
    available_space=$(df -g . | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1 ]]; then
        error "Insufficient disk space. At least 1GB required."
    fi

    check_directory_structure
    check_internet

    success "System checks passed"
}

# Check and install dependencies
check_dependencies() {
    info "Checking dependencies..."

    check_command_line_tools

    # Check if scripts are executable
    for script in scripts/*.sh; do
        make_executable "$script"
    done

    success "Dependencies checked"
}

# Run installation steps
run_installation() {
    info "Starting installation process..."

    # Installation order matters!
    local steps=(
        "scripts/macos-defaults.sh:macOS system preferences"
        "scripts/install-brew.sh:Homebrew and packages"
        "scripts/install-nvim.sh:Neovim configuration"
        "scripts/install-gitconfig.sh:Git configuration"
        "scripts/install-tmux.sh:Tmux configuration"
        "scripts/install-zsh.sh:Zsh configuration"
    )

    local step_num=1
    local total_steps=${#steps[@]}

    for step in "${steps[@]}"; do
        local script="${step%%:*}"
        local description="${step##*:}"

        echo ""
        info "Step $step_num/$total_steps: Installing $description"

        if [[ -x "$script" ]]; then
            if ./"$script"; then
                success "Step $step_num completed: $description"
            else
                error "Step $step_num failed: $description"
            fi
        else
            error "Script not found or not executable: $script"
        fi

        ((step_num++))
    done
}

# Main function
main() {
    echo "🚀 Starting dotfiles installation..."
    echo "This will set up your macOS development environment."
    echo ""

    # Ask for confirmation
    read -p "Do you want to continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    check_system
    check_dependencies
    run_installation

    echo ""
    success "🎉 Dotfiles installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Some macOS changes may require logout/login"
    echo "3. Consider installing Oh My Zsh + Powerlevel10k for enhanced prompt"
}

# Run main function
main "$@"
