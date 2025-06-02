# ~/.zshrc

# Shell Initialization
# Enable Powerlevel10k instant prompt (must be near the top of .zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"

# Disable Oh My Zsh security warnings for Homebrew directories
export ZSH_DISABLE_COMPFIX=true

ZSH_THEME="powerlevel10k/powerlevel10k"

# Only use core Oh My Zsh plugins (not the ones we install via Homebrew)
plugins=(
    git
)

source $ZSH/oh-my-zsh.sh

# Load Homebrew-installed plugins
# Load zsh-vi-mode first (order matters)
if [[ -f "/opt/homebrew/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
    source "/opt/homebrew/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
elif [[ -f "/usr/local/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
    source "/usr/local/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
else
    # Fallback: enable vi mode manually
    bindkey -v
fi

# Load autosuggestions
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Load syntax highlighting (must be last)
if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Load completions
if [[ -d "/opt/homebrew/share/zsh-completions" ]]; then
    fpath=(/opt/homebrew/share/zsh-completions $fpath)
elif [[ -d "/usr/local/share/zsh-completions" ]]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

# Custom Configuration
# Source all zsh configuration files from ~/.config/zsh/
# Order matters: env -> completions -> aliases -> functions -> theme
for config_file in "$HOME/.config/zsh/env.zsh" \
                   "$HOME/.config/zsh/completions.zsh" \
                   "$HOME/.config/zsh/aliases.zsh" \
                   "$HOME/.config/zsh/functions.zsh" \
                   "$HOME/.config/zsh/theme.zsh"; do
  if [[ -f "$config_file" ]]; then
    source "$config_file"
  fi
done

# Powerlevel10k configuration
if [[ -f ~/.p10k.zsh ]]; then
    source ~/.p10k.zsh
fi
