#!/bin/bash

source "$(dirname "$0")/_util.sh"

replace_in_file() {
    local pattern="$1"
    local replacement="$2"
    local file="$3"

    sed -i.bak "s|$pattern|$replacement|" "$file"
    rm -f "$file.bak"
}

ensure_personal_ssh_key() {
    local key_path="$HOME/.ssh/id_ed25519"
    local email="$1"

    if [ -f "$key_path.pub" ]; then
        task "Personal SSH key already exists"
        return
    fi

    info "Generating personal SSH key for Git signing/auth..."
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N "" >/dev/null
    chmod 600 "$key_path"
    chmod 644 "$key_path.pub"
    task "Generated $key_path.pub"
}

add_github_ssh_key_if_authenticated() {
    local key_path="$1"

    if ! command -v gh >/dev/null 2>&1; then
        warning "gh not found. Run 'gh auth login' later, then add $key_path to GitHub."
        return
    fi

    if gh auth status -h github.com >/dev/null 2>&1; then
        if ! gh api user/keys --jq '.[].key' >/tmp/gh-ssh-keys.$$ 2>/tmp/gh-ssh-keys.err.$$; then
            warning "gh cannot manage SSH keys yet. Run: gh auth refresh -h github.com -s admin:public_key"
            rm -f /tmp/gh-ssh-keys.$$ /tmp/gh-ssh-keys.err.$$
            return
        fi

        local public_key
        public_key="$(awk '{print $1 " " $2}' "$key_path")"
        if grep -Fqx "$public_key" /tmp/gh-ssh-keys.$$; then
            task "GitHub already has this SSH key"
        else
            if gh ssh-key add "$key_path" --title "$(hostname)-$(date +%Y%m%d)" >/dev/null; then
                task "Added SSH key to GitHub"
            else
                warning "Could not add SSH key to GitHub. Run: gh auth refresh -h github.com -s admin:public_key"
            fi
        fi
        rm -f /tmp/gh-ssh-keys.$$ /tmp/gh-ssh-keys.err.$$
    else
        warning "gh is not authenticated. Run 'gh auth login', then add $key_path to GitHub."
    fi
}

add_github_ssh_signing_key_if_authenticated() {
    local key_path="$1"

    if ! command -v gh >/dev/null 2>&1; then
        warning "gh not found. Run 'gh auth login' later, then add $key_path as a GitHub signing key."
        return
    fi

    if gh auth status -h github.com >/dev/null 2>&1; then
        if ! gh api user/ssh_signing_keys --jq '.[].key' >/tmp/gh-ssh-signing-keys.$$ 2>/tmp/gh-ssh-signing-keys.err.$$; then
            warning "gh cannot manage SSH signing keys yet. Run: gh auth refresh -h github.com -s admin:ssh_signing_key"
            rm -f /tmp/gh-ssh-signing-keys.$$ /tmp/gh-ssh-signing-keys.err.$$
            return
        fi

        local public_key
        public_key="$(awk '{print $1 " " $2}' "$key_path")"
        if grep -Fqx "$public_key" /tmp/gh-ssh-signing-keys.$$; then
            task "GitHub already has this SSH signing key"
        else
            if gh api user/ssh_signing_keys -X POST -f title="$(hostname)-signing-$(date +%Y%m%d)" -f key="$public_key" >/dev/null; then
                task "Added SSH signing key to GitHub"
            else
                warning "Could not add SSH signing key to GitHub. Run: gh auth refresh -h github.com -s admin:ssh_signing_key"
            fi
        fi
        rm -f /tmp/gh-ssh-signing-keys.$$ /tmp/gh-ssh-signing-keys.err.$$
    else
        warning "gh is not authenticated. Run 'gh auth login', then add $key_path as a GitHub signing key."
    fi
}

install_git() {
    step "🔗 Installing Git Configuration"

    backup_if_exists ~/.config/git/config
    backup_if_exists ~/.gitconfig # Backup legacy location if exists

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    info "Installing Git configuration (XDG-compliant)..."
    mkdir -p ~/.config/git
    cp "$(dirname "$0")/configs/git/config" ~/.config/git/config
    task "Copied config to ~/.config/git/config"

    # Work laptop: has both id_ed25519 (work) and id_ed25519_personal (personal)
    # Personal computer: only has id_ed25519 (personal)
    local personal_email="58354193+wajeht@users.noreply.github.com"
    local signing_key="$HOME/.ssh/id_ed25519.pub"
    if [ -f ~/.ssh/id_ed25519_personal.pub ]; then
        signing_key="$HOME/.ssh/id_ed25519_personal.pub"
        replace_in_file "signingKey = ~/.ssh/id_ed25519.pub" "signingKey = ~/.ssh/id_ed25519_personal.pub" ~/.config/git/config
        cp "$(dirname "$0")/configs/git/work" ~/.config/git/work
        task "Work laptop detected — default signing key set to personal, work profile installed"
    else
        ensure_personal_ssh_key "$personal_email"
        task "Personal computer detected — using default signing key"
    fi

    info "Installing SSH configuration for GitHub multi-account..."
    backup_if_exists ~/.ssh/config
    if [ -f ~/.ssh/config ]; then
        if ! grep -q "github-personal" ~/.ssh/config; then
            cat "$(dirname "$0")/configs/git/ssh_config" >>~/.ssh/config
            task "Appended GitHub SSH config to ~/.ssh/config"
        else
            task "GitHub SSH config already present in ~/.ssh/config"
        fi
    else
        cp "$(dirname "$0")/configs/git/ssh_config" ~/.ssh/config
        task "Copied SSH config to ~/.ssh/config"
    fi
    chmod 600 ~/.ssh/config

    info "Generating allowed_signers for commit verification..."
    : >~/.ssh/allowed_signers
    if [ -f ~/.ssh/id_ed25519_personal.pub ]; then
        # Work laptop: id_ed25519 = work key, id_ed25519_personal = personal key
        if [ -f ~/.ssh/id_ed25519.pub ]; then
            echo "265659615+clevyr-kyaw@users.noreply.github.com $(cat ~/.ssh/id_ed25519.pub)" >>~/.ssh/allowed_signers
        fi
        echo "58354193+wajeht@users.noreply.github.com $(cat ~/.ssh/id_ed25519_personal.pub)" >>~/.ssh/allowed_signers
        task "Added personal (and work, if present) keys to allowed_signers"
    elif [ -f ~/.ssh/id_ed25519.pub ]; then
        # Personal computer: id_ed25519 = personal key (only key)
        echo "58354193+wajeht@users.noreply.github.com $(cat ~/.ssh/id_ed25519.pub)" >>~/.ssh/allowed_signers
        task "Added personal key to allowed_signers"
    fi
    chmod 644 ~/.ssh/allowed_signers

    info "Adding GitHub host keys..."
    ssh-keyscan -t ed25519 -p 443 ssh.github.com 2>/dev/null >>~/.ssh/known_hosts
    task "Added GitHub SSH host key"

    add_github_ssh_key_if_authenticated "$signing_key"
    add_github_ssh_signing_key_if_authenticated "$signing_key"

    success "Git configuration installed"
    info "💡 Using XDG location: ~/.config/git/config (modern standard)"
    info "💡 SSH configured for multi-account GitHub (github.com + github-personal)"
}

uninstall_git() {
    step "🗑️  Removing Git Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/git/config"
    echo "   • ~/.config/git/work"
    echo "   • ~/.ssh/allowed_signers"
    echo "   • ~/.gitconfig (legacy, if exists)"
    echo ""
    read -p "❓ Continue with Git uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Creating backup of current config..."
    if [ -f ~/.config/git/config ]; then
        mkdir -p ~/.config/git.backup.$(date +%Y%m%d_%H%M%S)
        cp ~/.config/git/config ~/.config/git.backup.$(date +%Y%m%d_%H%M%S)/ && task "✅ Git config backed up"
    fi
    if [ -f ~/.gitconfig ]; then
        cp ~/.gitconfig ~/.gitconfig.backup.$(date +%Y%m%d_%H%M%S) && task "✅ Legacy .gitconfig backed up"
    fi

    info "Removing Git configuration..."
    rm -f ~/.config/git/config
    rm -f ~/.config/git/work
    rm -f ~/.ssh/allowed_signers
    rm -f ~/.gitconfig # Remove legacy location if it exists
    task "Removed Git configuration files"

    success "Git configuration removed successfully!"
    info "💡 To reinstall: make git install"
}

main() {
    case "${1:-install}" in
    install)
        install_git
        ;;
    uninstall)
        uninstall_git
        ;;
    *)
        install_git
        ;;
    esac
}

main "$@"
