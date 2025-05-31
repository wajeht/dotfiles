# Editor aliases
alias vim='nvim'
alias v='nvim'
alias c='code'

# Shell aliases
alias resource='source ~/.zshrc'

# Development tools
alias lg="lazygit"
alias air='$(go env GOPATH)/bin/air'

# File operations
alias ls="lsd -lF"
alias lst="ls --tree"
alias lsa="lsd -lAFh"
alias cat="bat"
alias lst='lsd --tree'

# System utilities
alias spec='fastfetch'
alias stay='echo -n "keeping screen awake ..." && caffeinate -d'

# Laravel Sail
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'

# Git shortcuts
alias wip="git add -A && git commit -am 'chore: wip' --no-verify && git push --no-verify"

# Cleanup aliases
alias rmnm="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"
alias rmds="find . -name '.DS_Store' -type f -delete"

# System maintenance
alias update='brew update && brew upgrade && brew doctor && brew autoremove && brew cleanup && brew missing'

# SSH aliases (consider moving to a separate file if you have many)
alias mac="sshpass -p 'password' ssh jaw@192.168.4.29"
alias zero="sshpass -p 'password' ssh jaw@192.168.4.160"
alias one="sshpass -p 'password' ssh jaw@192.168.4.161"
alias two="sshpass -p 'password' ssh jaw@192.168.4.162"
alias three="sshpass -p 'password' ssh jaw@192.168.4.163"
