# ~/.zshrc

# Shell Initialization

# Zsh Configuration
# Essential zsh options
setopt AUTO_CD              # Change directory without cd
setopt HIST_IGNORE_DUPS     # Don't record duplicate history entries
setopt HIST_IGNORE_SPACE    # Don't record commands starting with space
setopt SHARE_HISTORY        # Share history between sessions
setopt APPEND_HISTORY       # Append to history file
setopt INC_APPEND_HISTORY   # Write to history file immediately
setopt EXTENDED_HISTORY     # Record timestamp in history
# setopt CORRECT              # Spell correction for commands (disabled)

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Enable completion system
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Load Homebrew-installed plugins (optimized loading)
# Use single Homebrew prefix check
if [[ -d "/opt/homebrew" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local" ]]; then
    HOMEBREW_PREFIX="/usr/local"
fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
    # Load completions first
    if [[ -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
        fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
    fi

    # Load zsh-vi-mode first (order matters)
    if [[ -f "$HOMEBREW_PREFIX/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
    else
        # Fallback: enable vi mode manually
        bindkey -v
    fi

    # Load autosuggestions
    if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi

    # Load syntax highlighting (must be last)
    if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
fi

# Custom Configuration
# Source all zsh configuration files from ~/.config/zsh/
# Order matters: env -> completions -> aliases -> functions -> keybindings -> theme
for config_file in "$HOME/.config/zsh/env.zsh" \
                   "$HOME/.config/zsh/completions.zsh" \
                   "$HOME/.config/zsh/aliases.zsh" \
                   "$HOME/.config/zsh/functions.zsh" \
                   "$HOME/.config/zsh/keybindings.zsh" \
                   "$HOME/.config/zsh/theme.zsh"; do
  if [[ -f "$config_file" ]]; then
    source "$config_file"
  fi
done

# Initialize Starship prompt (must be last, after all plugins and functions)
eval "$(starship init zsh)"
