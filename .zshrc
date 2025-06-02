# ~/.zshrc

# Shell Initialization
# Enable Powerlevel10k instant prompt (must be near the top of .zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"

if [[ -d "$ZSH" ]]; then
    # Oh My Zsh is installed
    ZSH_THEME="powerlevel10k/powerlevel10k"

    plugins=(
        git
        zsh-vi-mode
        zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
    )

    source $ZSH/oh-my-zsh.sh
else
    # Fallback without Oh My Zsh
    echo "⚠️  Oh My Zsh not found. Using basic zsh configuration."

    # Enable vi mode manually
    bindkey -v

    # Basic prompt
    PS1='%F{blue}%~%f %F{green}❯%f '

    # Load syntax highlighting from Homebrew if available
    if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    elif [[ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi

    # Load autosuggestions from Homebrew if available
    if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    elif [[ -f "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
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

# Powerlevel10k (only if Oh My Zsh is available)
if [[ -d "$ZSH" && -f ~/.p10k.zsh ]]; then
    source ~/.p10k.zsh
fi
