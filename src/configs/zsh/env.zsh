# Preferred editor
export EDITOR='nvim'

# Language environment
export LANG=en_US.UTF-8

# Disable Homebrew auto-update
export HOMEBREW_NO_AUTO_UPDATE=1

# Colorize man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# NVM (Node Version Manager) - Lazy loading for faster startup
# Only load if NVM is installed
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"

  # Lazy load NVM - only load when needed
  nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion
    nvm "$@"
  }

  # Alias common node commands to trigger NVM loading
  node() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    node "$@"
  }

  npm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm "$@"
  }

  npx() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npx "$@"
  }
fi

# Go
export PATH="$HOME/go/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# For neovim version manager
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jaw/.lmstudio/bin"

export TERM=xterm-256color
