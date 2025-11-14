# ~/.config/zsh/.zshrc
# Main Zsh configuration file

# ======================
# Load Core Settings
# ======================
source "$ZDOTDIR/rc.zsh"

# ======================
# Load Environment & PATH
# ======================
source "$ZDOTDIR/env.zsh"

# ======================
# Load Homebrew Plugins
# ======================
# Use single Homebrew prefix check
if [[ -d "/opt/homebrew" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local" ]]; then
    HOMEBREW_PREFIX="/usr/local"
fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
    # Load completions first
    if [[ -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
        fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
    fi

    # Load zsh-vi-mode first (order matters)
    if [[ -f "$HOMEBREW_PREFIX/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
    else
        # Fallback: enable vi mode manually
        bindkey -v
    fi

    # Load autosuggestions
    if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi

    # Load syntax highlighting (must be last)
    if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
fi

# Load bun completions
[ -s "/Users/$USER/.bun/_bun" ] && source "/Users/$USER/.bun/_bun"

# ======================
# Load User Configuration
# ======================
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/functions.zsh"

# Load private/machine-specific config if it exists
[[ -f "$ZDOTDIR/private.zsh" ]] && source "$ZDOTDIR/private.zsh"

# ======================
# Initialize Starship Prompt
# ======================
# Must be last, after all plugins and functions
# eval "$(starship init zsh)"  # Commented out - using simple native prompt instead
