#!/bin/bash

# Ultimate Tmux Session Switcher & Manager
# ------------------------------------------------------------------------------

# Use a temporary file to track what the user wanted to do
temp_file="/tmp/tmux-switcher-action"
rm -f "$temp_file"

# 1. Get the session names and use FZF
# We use 'expect' to tell us which key was pressed
result=$(tmux list-sessions -F '#S' 2>/dev/null | \
    fzf --reverse --expect=ctrl-r,ctrl-x \
        --header 'Enter: Switch | Ctrl-r: Rename | Ctrl-x: Kill' \
        --preview 'tmux list-windows -t {}' \
        --preview-window 'right:50%')

# Parse the result (FZF --expect returns the key on line 1 and the selection on line 2)
key=$(echo "$result" | head -n 1)
selected=$(echo "$result" | sed -n '2p')

# Handle actions
case "$key" in
    ctrl-r)
        if [[ -n "$selected" ]]; then
            # We close FZF first, then use a native tmux prompt for renaming
            # This ensures the rename actually works and has focus
            tmux command-prompt -I "$selected" "rename-session -t \"$selected\" \"%%\""
        fi
        ;;
    ctrl-x)
        if [[ -n "$selected" ]]; then
            tmux kill-session -t "$selected"
            # Re-open the switcher after killing
            bash "$0"
        fi
        ;;
    "") # Enter pressed (no key expected)
        if [[ -n "$selected" ]]; then
            tmux switch-client -t "$selected"
        fi
        ;;
esac
