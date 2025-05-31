# ~/.zshrc

# Shell Initialization
# Enable Powerlevel10k instant prompt (must be near the top of .zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-vi-mode
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Custom Configuration
DOTFILES_DIR="$HOME/Dev/dotfiles"

# Source all zsh configuration files from .config/zsh/
# Order matters: env -> completions -> aliases -> functions -> theme
for config_file in "$DOTFILES_DIR/.config/zsh/env.zsh" \
                   "$DOTFILES_DIR/.config/zsh/completions.zsh" \
                   "$DOTFILES_DIR/.config/zsh/aliases.zsh" \
                   "$DOTFILES_DIR/.config/zsh/functions.zsh" \
                   "$DOTFILES_DIR/.config/zsh/theme.zsh"; do
  if [[ -f "$config_file" ]]; then
    source "$config_file"
  fi
done

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
