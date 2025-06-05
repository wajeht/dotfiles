# Key bindings for zsh

# Bind Ctrl+F to the tmux sessionizer
# This creates a widget that calls the tmux sessionizer and refreshes the prompt
tmux-sessionizer-widget() {
  # Handle differently based on whether we're in tmux
  if [[ -z $TMUX ]]; then
    # Outside tmux: clear line and execute via command line for proper terminal takeover
    zle kill-whole-line
    BUFFER="sessionizer"
    zle accept-line
  else
    # Inside tmux: run normally
    zle kill-whole-line
    sessionizer
    zle reset-prompt
  fi
}
zle -N tmux-sessionizer-widget

# Set up key bindings after zsh-vi-mode initializes
# zsh-vi-mode overrides many bindings, so we need to set ours after it loads
function zvm_after_init() {
  # Bind Ctrl+F in insert mode (vi mode)
  zvm_bindkey viins '^F' tmux-sessionizer-widget
  # Also bind in normal/command mode for convenience
  zvm_bindkey vicmd '^F' tmux-sessionizer-widget
}
