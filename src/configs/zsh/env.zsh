# Preferred editor
export EDITOR='nvim'

# Language environment
export LANG=en_US.UTF-8

# Disable Homebrew auto-update
export HOMEBREW_NO_AUTO_UPDATE=1

# Colorize man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
  NVM_HOMEBREW="/opt/homebrew/opt/nvm"
elif [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
  NVM_HOMEBREW="/usr/local/opt/nvm"
fi

# Add nvm's default node to PATH for tools like Mason that need npm
if [[ -d "$NVM_DIR/versions/node" ]]; then
  NODE_DEFAULT=$(ls -t "$NVM_DIR/versions/node" 2>/dev/null | head -1)
  [[ -n "$NODE_DEFAULT" ]] && export PATH="$NVM_DIR/versions/node/$NODE_DEFAULT/bin:$PATH"
fi

# Lazy load NVM commands - only load full nvm when needed
if [[ -n "$NVM_HOMEBREW" ]] || [[ -d "$NVM_DIR" ]]; then
  nvm() {
    unset -f nvm
    if [[ -n "$NVM_HOMEBREW" ]]; then
      [ -s "$NVM_HOMEBREW/nvm.sh" ] && \. "$NVM_HOMEBREW/nvm.sh"
      [ -s "$NVM_HOMEBREW/etc/bash_completion.d/nvm" ] && \. "$NVM_HOMEBREW/etc/bash_completion.d/nvm"
    else
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
    nvm "$@"
  }
fi

# Go
export PATH="$HOME/go/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Local bin (bob, etc)
export PATH="$HOME/.local/bin:$PATH"

# For neovim version manager
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jaw/.lmstudio/bin"

export TERM=xterm-256color
