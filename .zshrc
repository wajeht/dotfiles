# ~/.zshrc

# ======================
# Shell Initialization
# ======================

# Enable Powerlevel10k instant prompt (must be near the top of .zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ======================
# Oh My Zsh Configuration
# ======================

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme (Powerlevel10k)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-vi-mode
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ======================
# Custom Configuration Files
# (Order matters for some things, e.g., PATH should be defined before functions using tools in PATH)
# ======================

# Define the dotfiles directory
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

# ======================
# Powerlevel10k Configuration
# ======================

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
