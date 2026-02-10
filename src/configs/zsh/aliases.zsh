# Editor aliases
alias vim='nvim'
alias v='nvim'
alias c='code'
alias cr='cursor'
# alias clc='curl -fsSL https://claude.ai/install.sh | bash'
alias clc='npx @anthropic-ai/claude-code@latest'
# alias oc='bunx opencode-ai@opentui'
alias oc='npx opencode-ai@latest'
alias cdx='npx @openai/codex@latest'
alias gcli='npx @google/gemini-cli@latest'

# Shell aliases
alias resource='source ~/.zshrc'

# Development tools
alias lg="lazygit"
alias air='$(go env GOPATH)/bin/air'

# Directory navigation
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"
alias documents="cd ~/Documents"
alias music="cd ~/Music"

# File operations
alias ls="lsd -lF"
alias lst="lsd --tree --all"
alias lsa="lsd -lAFh"
alias cat="bat"

# System utilities
alias spec='fastfetch'
alias stay='echo -n "keeping screen awake ..." && caffeinate -d'

# Laravel Sail
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'

# Essential git aliases (replacing Oh My Zsh git plugin)
alias g='git'
alias ga='git add'
alias gacp='git add . && curl -s https://commit.jaw.dev/ | sh -s -- --no-verify && git push'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gstp='git stash pop'
alias gwip="git add -A && git commit -am 'chore: wip' --no-verify && git push --no-verify"
alias gbd='git branch | fzf --multi --preview "git log {1}" | xargs -I{} git branch -D {}'

alias rmnm="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"
alias rmds="find . -name '.DS_Store' -type f -delete"

if [[ "$(uname)" == "Darwin" ]]; then
    alias update='brew update && brew upgrade && brew doctor && brew autoremove && brew cleanup && brew missing'
else
    alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean'
fi

alias work="ssh kyaw@192.168.4.120"
alias one="ssh jaw@192.168.4.161"
alias plex="sshpass -p 'password' ssh jaw@192.168.4.162"
alias pi="sshpass -p 'password' ssh pi@192.168.4.181"
