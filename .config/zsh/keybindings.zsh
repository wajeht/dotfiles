# Custom Keybindings

# Widget function to run dev() and refresh the command line
function dev-widget() {
  # Clear line and execute via command line for proper terminal takeover
  zle kill-whole-line
  BUFFER="dev"
  zle accept-line
}

# Create a zsh widget from the function
zle -N dev-widget

# Set up key bindings after zsh-vi-mode initializes
# zsh-vi-mode overrides many bindings, so we need to set ours after it loads
function zvm_after_init() {
  # Bind Cmd+F (Ghostty sends \x06 escape sequence when cmd+f is pressed)
  # Bind in insert mode (vi mode)
  zvm_bindkey viins '\x06' dev-widget
  # Also bind in normal/command mode for convenience
  zvm_bindkey vicmd '\x06' dev-widget
}
