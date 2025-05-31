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

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
