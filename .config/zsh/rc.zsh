# ======================
# Core Zsh Configuration
# ======================
# Options, history, completion, and theme settings

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
# Enable completion system
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ======================
# Theme & Visual Configuration
# ======================

# fzf theme configuration
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#d4d4d4,bg:-1,bg+:#03395e
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#9cdcfe
  --color=prompt:#60d701,spinner:#60d701,pointer:#d4d4d4,header:#87afaf
  --color=border:#444444,separator:#444444,scrollbar:#444444
  --color=preview-border:#444444,preview-scrollbar:#444444,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker="+" --pointer=">" --separator="─" --scrollbar="│" --gutter=" "'

# ======================
# Simple Native Prompt
# ======================
# Load git info for prompt
autoload -Uz vcs_info

# Enable command substitution in prompt
setopt PROMPT_SUBST

# Configure vcs_info for git
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b|%a'

# Cache variables for git status (avoid running git multiple times per prompt)
typeset -g _prompt_git_staged=0
typeset -g _prompt_git_modified=0
typeset -g _prompt_git_deleted=0
typeset -g _prompt_git_untracked=0
typeset -g _prompt_git_status_len=0
typeset -g _prompt_in_git=0

# Function to parse git status once and cache results
function _prompt_update_git_status() {
    _prompt_in_git=0
    _prompt_git_staged=0
    _prompt_git_modified=0
    _prompt_git_deleted=0
    _prompt_git_untracked=0
    _prompt_git_status_len=0

    # Quick check if we're in a git repo
    git rev-parse --is-inside-work-tree &>/dev/null || return
    _prompt_in_git=1

    # Single git status call
    local status_output=$(git status --porcelain 2>/dev/null)
    [[ -z "$status_output" ]] && return

    # Parse status output
    while IFS= read -r line; do
        case "${line:0:2}" in
            'A '|'M '|'D '|'R '|'C ') ((_prompt_git_staged++)) ;;
            ' M') ((_prompt_git_modified++)) ;;
            ' D') ((_prompt_git_deleted++)) ;;
            'MM'|'AM'|'AD') ((_prompt_git_staged++)); ((_prompt_git_modified++)) ;;
            '??') ((_prompt_git_untracked++)) ;;
        esac
    done <<< "$status_output"

    # Calculate status length
    [[ $_prompt_git_staged -gt 0 ]] && _prompt_git_status_len=$((_prompt_git_status_len + 1 + ${#_prompt_git_staged}))
    [[ $_prompt_git_modified -gt 0 ]] && _prompt_git_status_len=$((_prompt_git_status_len + 1 + ${#_prompt_git_modified}))
    [[ $_prompt_git_deleted -gt 0 ]] && _prompt_git_status_len=$((_prompt_git_status_len + 1 + ${#_prompt_git_deleted}))
    [[ $_prompt_git_untracked -gt 0 ]] && _prompt_git_status_len=$((_prompt_git_status_len + 1 + ${#_prompt_git_untracked}))
    [[ $_prompt_git_status_len -gt 0 ]] && _prompt_git_status_len=$((_prompt_git_status_len + 3))
}

# Function to render git status (uses cached data)
function prompt_git_status() {
    [[ $_prompt_in_git -eq 0 ]] && return

    local git_status=""
    [[ $_prompt_git_staged -gt 0 ]] && git_status="${git_status}%F{green}+${_prompt_git_staged}%f"
    [[ $_prompt_git_modified -gt 0 ]] && git_status="${git_status}%F{yellow}!${_prompt_git_modified}%f"
    [[ $_prompt_git_deleted -gt 0 ]] && git_status="${git_status}%F{red}✘${_prompt_git_deleted}%f"
    [[ $_prompt_git_untracked -gt 0 ]] && git_status="${git_status}%F{cyan}?${_prompt_git_untracked}%f"

    [[ -n "$git_status" ]] && echo " [${git_status}]"
}

# Function to generate dots dynamically (uses cached git data)
function prompt_dots() {
    # Get current directory (with ~ substitution)
    local dir_display="${PWD/#$HOME/\~}"

    # Get git branch length if available
    local git_display=""
    [[ -n "${vcs_info_msg_0_}" ]] && git_display=" on ${vcs_info_msg_0_}"

    # Calculate lengths (without ANSI color codes)
    # %D{%I:%M:%S %p} expands to 11 characters (HH:MM:SS AM/PM)
    local left_length=$((${#dir_display} + ${#git_display} + _prompt_git_status_len))
    local right_length=15  # " at HH:MM:SS AM" = 15 chars
    local dots_length=$((COLUMNS - left_length - right_length))

    # Generate dots
    (( dots_length > 0 )) && printf '·%.0s' {1..$dots_length}
}

# Update prompt data before each prompt render
precmd() {
    vcs_info
    _prompt_update_git_status
}

# Two-line prompt with dots
# Line 1: directory + git branch + git status + dots + time
# Line 2: prompt symbol
PROMPT='%F{cyan}%~%f%F{white}${vcs_info_msg_0_:+ on }%f%F{green}${vcs_info_msg_0_}%f$(prompt_git_status) %F{240}$(prompt_dots)%f %F{white}at %F{blue}%D{%I:%M:%S %p}%f
%F{green}❯%f '

# Starship prompt (commented out)
# Configuration is in ~/.config/starship.toml
# To re-enable: uncomment the eval line in .zshrc
