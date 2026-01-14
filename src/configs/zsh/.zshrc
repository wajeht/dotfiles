# ~/.config/zsh/.zshrc
# Main Zsh configuration file

# ======================
# Core Zsh Configuration
# ======================

# Shell Initialization
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ======================
# Zsh Options
# ======================
setopt AUTO_CD              # Change directory without cd
setopt HIST_IGNORE_DUPS     # Don't record duplicate history entries
setopt HIST_IGNORE_SPACE    # Don't record commands starting with space
setopt SHARE_HISTORY        # Share history between sessions
setopt APPEND_HISTORY       # Append to history file
setopt INC_APPEND_HISTORY   # Write to history file immediately
setopt EXTENDED_HISTORY     # Record timestamp in history
setopt PROMPT_SUBST         # Enable command substitution in prompt
# setopt CORRECT            # Spell correction for commands (disabled)

# ======================
# History Configuration
# ======================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ======================
# Completion System
# ======================
# Enable completion system (optimized - only rebuild once per day)
autoload -Uz compinit
_zcompdump_day() {
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null
    else
        date -r ~/.zcompdump +'%j' 2>/dev/null
    fi
}
if [ "$(date +'%j')" != "$(_zcompdump_day)" ]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ======================
# FZF Theme Configuration
# ======================
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#d4d4d4,bg:-1,bg+:#03395e
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#9cdcfe
  --color=prompt:#60d701,spinner:#60d701,pointer:#d4d4d4,header:#87afaf
  --color=border:#444444,separator:#444444,scrollbar:#444444
  --color=preview-border:#444444,preview-scrollbar:#444444,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker="+" --pointer=">" --separator="─" --scrollbar="│" --gutter=" "'

# ======================
# Async Git Prompt
# ======================

# Load vcs_info for git branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b|%a'

# Global variables for git status
typeset -g _prompt_git_staged=0
typeset -g _prompt_git_modified=0
typeset -g _prompt_git_deleted=0
typeset -g _prompt_git_untracked=0
typeset -g _prompt_git_status_len=0
typeset -g _prompt_in_git=0
typeset -g _prompt_git_pid=0

# Async git status update (runs in background)
function _prompt_async_git_status() {
    # Run in subshell to avoid blocking
    {
        local staged=0 modified=0 deleted=0 untracked=0 in_git=0

        # Quick check if in git repo
        git rev-parse --is-inside-work-tree &>/dev/null || {
            echo "0:0:0:0:0:0"
            return
        }
        in_git=1

        # Single git status call
        local status_output=$(git status --porcelain 2>/dev/null)
        [[ -z "$status_output" ]] && {
            echo "1:0:0:0:0:0"
            return
        }

        # Parse status output
        while IFS= read -r line; do
            case "${line:0:2}" in
                'A '|'M '|'D '|'R '|'C ') ((staged++)) ;;
                ' M') ((modified++)) ;;
                ' D') ((deleted++)) ;;
                'MM'|'AM'|'AD') ((staged++)); ((modified++)) ;;
                '??') ((untracked++)) ;;
            esac
        done <<< "$status_output"

        # Calculate status length for dots
        local status_len=0
        [[ $staged -gt 0 ]] && status_len=$((status_len + 1 + ${#staged}))
        [[ $modified -gt 0 ]] && status_len=$((status_len + 1 + ${#modified}))
        [[ $deleted -gt 0 ]] && status_len=$((status_len + 1 + ${#deleted}))
        [[ $untracked -gt 0 ]] && status_len=$((status_len + 1 + ${#untracked}))
        [[ $status_len -gt 0 ]] && status_len=$((status_len + 3))

        echo "$in_git:$staged:$modified:$deleted:$untracked:$status_len"
    } &!
}

# Callback to update git status from async result
function _prompt_async_callback() {
    local result="$1"
    IFS=':' read -r _prompt_in_git _prompt_git_staged _prompt_git_modified _prompt_git_deleted _prompt_git_untracked _prompt_git_status_len <<< "$result"
    _prompt_git_pid=0

    # Refresh prompt
    zle && zle reset-prompt
}

# Function to render git status (uses cached data)
function prompt_git_status() {
    [[ $_prompt_in_git -eq 0 ]] && return

    local git_status=""
    [[ $_prompt_git_staged -gt 0 ]] && git_status="${git_status}%F{green}+${_prompt_git_staged}%f"
    [[ $_prompt_git_modified -gt 0 ]] && git_status="${git_status}%F{yellow}!${_prompt_git_modified}%f"
    [[ $_prompt_git_deleted -gt 0 ]] && git_status="${git_status}%F{red}x${_prompt_git_deleted}%f"
    [[ $_prompt_git_untracked -gt 0 ]] && git_status="${git_status}%F{cyan}?${_prompt_git_untracked}%f"

    [[ -n "$git_status" ]] && echo " [${git_status}]"
}

# Function to generate dots dynamically
function prompt_dots() {
    local dir_display="${PWD/#$HOME/\~}"
    local git_display=""
    [[ -n "${vcs_info_msg_0_}" ]] && git_display=" on ${vcs_info_msg_0_}"

    # Calculate lengths (without ANSI color codes)
    local left_length=$((${#dir_display} + ${#git_display} + _prompt_git_status_len))
    local right_length=$((${#HOST} + 16))  # " hostname at HH:MM:SS AM"
    local dots_length=$((COLUMNS - left_length - right_length))

    # Generate dots
    (( dots_length > 0 )) && printf '·%.0s' {1..$dots_length}
}

# Precmd - runs before each prompt
precmd() {
    vcs_info

    # Start async git status update if not already running
    if [[ $_prompt_git_pid -eq 0 ]]; then
        local git_result=$(_prompt_async_git_status)
        _prompt_async_callback "$git_result"
    fi
}

# Two-line prompt with dots
# Line 1: directory + git branch + git status + dots + time
# Line 2: prompt symbol
PROMPT='%F{cyan}%~%f%F{white}${vcs_info_msg_0_:+ on }%f%F{green}${vcs_info_msg_0_}%f$(prompt_git_status) %F{240}$(prompt_dots)%f %F{magenta}%m%f %F{white}at %F{blue}%D{%I:%M:%S %p}%f
%F{green}❯%f '

# ======================
# Load Environment & PATH
# ======================
source "$ZDOTDIR/env.zsh"

# ======================
# Load Zsh Plugins
# ======================
# Detect plugin source: Homebrew (macOS) or git clones (Linux/server)
_PLUGIN_DIR=""
if [[ -d "/opt/homebrew/share" ]]; then
    _PLUGIN_DIR="/opt/homebrew/share"
elif [[ -d "/usr/local/share" ]]; then
    _PLUGIN_DIR="/usr/local/share"
elif [[ -d "$HOME/.zsh/plugins" ]]; then
    _PLUGIN_DIR="$HOME/.zsh/plugins"
fi

if [[ -n "$_PLUGIN_DIR" ]]; then
    # Load completions first
    if [[ -d "$_PLUGIN_DIR/zsh-completions" ]]; then
        fpath=("$_PLUGIN_DIR/zsh-completions" $fpath)
    elif [[ -d "$_PLUGIN_DIR/zsh-completions/src" ]]; then
        fpath=("$_PLUGIN_DIR/zsh-completions/src" $fpath)
    fi

    # Load zsh-vi-mode first (order matters)
    if [[ -f "$_PLUGIN_DIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
        source "$_PLUGIN_DIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
    else
        # Fallback: enable vi mode manually
        bindkey -v
    fi

    # Load autosuggestions
    if [[ -f "$_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source "$_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi

    # Load syntax highlighting (must be last)
    if [[ -f "$_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "$_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
fi
unset _PLUGIN_DIR

# Lazy load bun completions (faster startup)
bun() {
    unset -f bun
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
    command bun "$@"
}

# ======================
# Load User Configuration
# ======================
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/functions.zsh"

# Load private/machine-specific config if it exists
[[ -f "$ZDOTDIR/private.zsh" ]] && source "$ZDOTDIR/private.zsh"
