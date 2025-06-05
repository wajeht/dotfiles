#!/usr/bin/env bash

# ThePrimeagen-style tmux sessionizer for ~/Dev projects
# This script finds directories in ~/Dev, lets you select one with fzf,
# and creates or switches to a tmux session for that project with 3 windows

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Find directories in ~/Dev, excluding hidden ones
    selected=$(find ~/Dev -maxdepth 1 -type d -not -path "*/\.*" | grep -v "^$HOME/Dev$" | fzf --height 40% --layout=reverse --border)
fi

if [[ -z $selected ]]; then
    exit 0
fi

# Create session name from directory name, replacing dots with underscores
selected_name=$(basename "$selected" | tr . _)

# Function to setup/create all windows
setup_session() {
    local session_name="$1"
    local project_dir="$2"

    # Kill existing session if it exists to start fresh
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux kill-session -t "$session_name"
    fi

    # Create new session with first window and start nvim immediately
    tmux new-session -d -s "$session_name" -c "$project_dir" nvim

    # Rename the window to nvim (after nvim has started)
    tmux rename-window -t "$session_name:0" "nvim"

    # Create second window (shell)
    tmux new-window -t "$session_name:1" -n "shell" -c "$project_dir"

    # Create third window (output)
    tmux new-window -t "$session_name:2" -n "output" -c "$project_dir"

    # Go back to nvim window
    tmux select-window -t "$session_name:0"
}

# Always setup the session fresh
setup_session "$selected_name" "$selected"

# Attach or switch to the session
if [[ -z $TMUX ]]; then
    # Not in tmux, so attach
    exec tmux attach -t "$selected_name"
else
    # Already in tmux, so switch
    tmux switch-client -t "$selected_name"
fi
