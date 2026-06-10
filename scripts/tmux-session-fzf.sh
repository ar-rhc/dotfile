#!/bin/bash

# Stable Tmux Session Switcher & Manager
# ------------------------------------------------------------------------------

# 1. Get the session names and use FZF
# We use 'expect' to handle management actions without closing the popup environment
result=$(tmux list-sessions -F '#S' 2>/dev/null | \
    fzf --reverse --expect=ctrl-r,ctrl-x \
        --header 'Enter: Switch | Ctrl-r: Rename | Ctrl-x: Kill' \
        --preview 'tmux list-windows -t {}' \
        --preview-window 'right:50%')

# Parse the result
key=$(echo "$result" | head -n 1)
selected=$(echo "$result" | sed -n '2p')

# Handle actions
case "$key" in
    ctrl-r)
        if [[ -n "$selected" ]]; then
            # Prompt for name INSIDE the popup
            printf "\033[33mNew name for $selected: \033[0m"
            read new_name < /dev/tty
            
            if [[ -n "$new_name" ]]; then
                tmux rename-session -t "$selected" "$new_name"
            fi
            # Restart the script to refresh the list
            exec bash "$0"
        fi
        ;;
    ctrl-x)
        if [[ -n "$selected" ]]; then
            tmux kill-session -t "$selected"
            # Restart the script to refresh the list
            exec bash "$0"
        fi
        ;;
    "") # Enter pressed (Switch)
        if [[ -n "$selected" ]]; then
            tmux switch-client -t "$selected"
        fi
        ;;
esac
