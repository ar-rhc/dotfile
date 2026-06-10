#!/bin/bash

# Tmux Sessionizer
# Quickly create or switch to sessions based on project folders

# 1. Define your project paths
# We use 'find' to list the directories
# -maxdepth 1 to only see top-level folders in ARfiles
selected=$(find ~/dotfiles /Users/alex/ARfiles -mindepth 1 -maxdepth 1 -type d 2>/dev/null | /opt/homebrew/bin/fzf --reverse --header 'Create/Switch Session')

# If user cancels (ESC), exit
if [[ -z $selected ]]; then
    exit 0
fi

# 2. Get the name for the session (basename of the folder)
# Replace dots with underscores as tmux doesn't like dots in names
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# 3. Handle session creation and switching
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    # Tmux is not running at all
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    # Session doesn't exist, create it in detached mode
    tmux new-session -ds $selected_name -c $selected
fi

# Switch to the session (works whether we are inside or outside tmux)
tmux switch-client -t $selected_name
