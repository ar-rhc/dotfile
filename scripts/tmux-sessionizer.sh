#!/bin/bash

# Tmux Sessionizer
# Quickly create or switch to sessions based on project folders

# 1. Define your project paths
# We include the parent folders and their immediate subdirectories
search_paths="~/dotfiles /Users/alex/ARfiles /Users/alex/ARfiles/Obsidian/Obsidian-Git"

# Use 'find' on all paths, allowing the parents to show up as well
selected=$(find $(eval echo $search_paths) -maxdepth 1 -type d 2>/dev/null | /opt/homebrew/bin/fzf --reverse --header 'Create/Switch Session')

# If user cancels (ESC), exit
if [[ -z $selected ]]; then
    exit 0
fi

# 2. Get the name for the session (basename of the folder)
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# 3. Handle session creation and switching
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
