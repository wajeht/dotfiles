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
# Environment Variables
# ======================

# Preferred editor
export EDITOR='nvim'

# Language environment
export LANG=en_US.UTF-8

# Colorize man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion

# ======================
# Aliases
# ======================

# General aliases
alias vim='nvim'
alias v='nvim'
alias c='code'
alias resource='source ~/.zshrc'
alias ls="lsd -lF"
alias t="tmux"
alias lg="lazygit"
alias lst="ls --tree"
alias lsa="lsd -lAFh"
alias cat="bat"
alias lst='lsd --tree'
alias spec='fastfetch'
alias stay='echo -n "keeping screen awake ..." && caffeinate -d'
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias wip="git add -A && git commit -am 'chore: wip' --no-verify && git push --no-verify"
alias rmnm="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"
alias air='$(go env GOPATH)/bin/air'
alias update='brew update && brew upgrade && brew doctor && brew autoremove && brew cleanup && brew missing'

# SSH aliases for servers
alias mac="sshpass -p 'password' ssh jaw@192.168.4.29"
alias zero="sshpass -p 'password' ssh jaw@192.168.0.110"
alias one="ssh jaw@192.168.0.111"
alias two="ssh jaw@192.168.0.112"
alias three="ssh jaw@192.168.0.113"

# ======================
# Custom Functions
# ======================

# Create a directory and cd into it
function mkcd {
  last=$(eval "echo \$$#")
  if [ ! -n "$last" ]; then
    echo "Enter a directory name"
  elif [ -d $last ]; then
    echo "\`$last' already exists"
  else
    mkdir $@ && cd $last
  fi
}

# Browse directories in ~/Dev with fzf
function dev {
  selected_dir=$(find ~/Dev -maxdepth 1 -type d -not -path "*/\.*" | grep -v "^$HOME/Dev$" | fzf --height 40% --layout=reverse --border)
  if [ -n "$selected_dir" ]; then
    cd "$selected_dir" && nvim .
  fi
}

# change dir and list
cd() {
  builtin cd "$1" && ls
}

# ======================
# Powerlevel10k Configuration
# ======================

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions
[ -s "/Users/konyein/.bun/_bun" ] && source "/Users/konyein/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fzf theme
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#d4d4d4,bg:-1,bg+:#03395e
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#9cdcfe
  --color=prompt:#60d701,spinner:#60d701,pointer:#d4d4d4,header:#87afaf
  --color=gutter:-1,border:#444444,separator:#444444,scrollbar:#444444
  --color=preview-border:#444444,preview-scrollbar:#444444,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker="+" --pointer=">" --separator="─" --scrollbar="│"'
