# Preferred editor
export EDITOR='nvim'

# Ripgrep config (vscode-theme colors)
export RIPGREP_CONFIG_PATH="$HOME/.config/zsh/ripgreprc"

# FZF theme — colors mirror the nvim vscode theme (nvim/lua/colors/init.lua).
# Lives here (not .zshrc) so the tmux sessionizer popup gets it without a
# full interactive shell startup
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#D4D4D4,bg:-1,bg+:#03395e
  --color=hl:#2AAAFF,hl+:#2AAAFF,info:#808080,marker:#9CDCFE
  --color=prompt:#569CD6,spinner:#4EC9B0,pointer:#D4D4D4,header:#4EC9B0
  --color=border:#444444,separator:#444444,scrollbar:#444444
  --color=preview-border:#444444,preview-scrollbar:#444444,label:#808080,query:#D4D4D4
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker="+" --pointer=">" --separator="─" --scrollbar="│" --gutter=" "'

# Language environment
export LANG=en_US.UTF-8

# Disable Homebrew auto-update
export HOMEBREW_NO_AUTO_UPDATE=1

# Homebrew
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Colorize man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Difftastic defaults
export DFT_DISPLAY="side-by-side-show-both"
export DFT_CONTEXT="2"
export DFT_BACKGROUND="dark"
export DFT_SYNTAX_HIGHLIGHT="off"

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

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

export TERM=xterm-256color

# SOPS age key
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
