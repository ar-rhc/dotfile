#!/bin/bash

# Robust Tmux Session Switcher & Manager
# ------------------------------------------------------------------------------

# 1. Get the session names
# 2. Use FZF with reliable tmux-native commands for management
# We use 'tmux command-prompt' because it's guaranteed to handle input correctly
selected=$(tmux list-sessions -F '#S' 2>/dev/null | \
    fzf --reverse \
        --header 'Enter: Switch | Ctrl-r: Rename | Ctrl-x: Kill' \
        --preview 'tmux list-windows -t {}' \
        --preview-window 'right:50%' \
        --bind 'ctrl-r:execute(tmux command-prompt -I "{}" "rename-session -t {} \"%%\"")+reload(sleep 0.2; tmux list-sessions -F "#S")' \
        --bind 'ctrl-x:execute(tmux kill-session -t "{}")+reload(sleep 0.1; tmux list-sessions -F "#S")')

# 3. Switch to the selected session
if [[ -n "$selected" ]]; then
    if tmux has-session -t "$selected" 2>/dev/null; then
        tmux switch-client -t "$selected"
    fi
fi
