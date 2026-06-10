#!/bin/bash

# Compact Tmux Session Switcher with [Name] (n) format
# ------------------------------------------------------------------------------

# 1. Get session names and format them as "[Name]    (n)"
# Using a fixed width of 25 chars for the name to fit narrower popup
result=$(tmux list-sessions -F '#S' 2>/dev/null | \
    awk '{printf "%-25s (%d)\n", $0, NR}' | \
    fzf --reverse --expect=ctrl-r,ctrl-x \
        --header 'R: Rename | X: Kill' \
        --preview 'tmux list-windows -t $(echo {} | sed "s/ *([0-9]*)$//") -F " #I: #W"' \
        --preview-window 'bottom:40%')

# Parse result
key=$(echo "$result" | head -n 1)
selected_line=$(echo "$result" | sed -n '2p')

# Extract just the session name (remove the " (n)" suffix)
selected=$(echo "$selected_line" | sed 's/ *([0-9]*)$//')

# Handle actions
case "$key" in
    ctrl-r)
        if [[ -n "$selected" ]]; then
            # Prompt inside the popup
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
            # Prompt for confirmation inside the popup
            printf "\033[31mKill session '$selected'? (y/n): \033[0m"
            read -n 1 confirm < /dev/tty
            echo
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                tmux kill-session -t "$selected"
            fi
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
