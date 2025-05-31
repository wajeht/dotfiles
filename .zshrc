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

# Source environment variables
source ~/Dev/dotfiles/env_vars.sh

# Source general aliases
source ~/Dev/dotfiles/aliases.sh

# Source custom shell functions
source ~/Dev/dotfiles/shell_funcs.sh

# ======================
# Powerlevel10k Configuration
# ======================

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions (moved here as it's a specific completion script)
[ -s "/Users/konyein/.bun/_bun" ] && source "/Users/konyein/.bun/_bun"

# fzf theme (moved here as it's directly setting an env var with multi-line content)
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#d4d4d4,bg:-1,bg+:#03395e
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#9cdcfe
  --color=prompt:#60d701,spinner:#60d701,pointer:#d4d4d4,header:#87afaf
  --color=gutter:-1,border:#444444,separator:#444444,scrollbar:#444444
  --color=preview-border:#444444,preview-scrollbar:#444444,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker="+" --pointer=">" --separator="─" --scrollbar="│"'
