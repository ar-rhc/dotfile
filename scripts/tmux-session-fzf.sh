#!/bin/bash

# Compact Tmux Session Switcher with [Name] (n) format
# ------------------------------------------------------------------------------

# 1. Get session names and format them as "[Name]    (n)"
# Using a fixed width of 20 chars for the name
result=$(tmux list-sessions -F '#S' 2>/dev/null | \
    awk '{printf "%-20s (%d)\n", $0, NR}' | \
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
            printf "\033[33mNew name for $selected: \033[0m"
            read new_name < /dev/tty
            [[ -n "$new_name" ]] && tmux rename-session -t "$selected" "$new_name"
            exec bash "$0"
        fi
        ;;
    ctrl-x)
        if [[ -n "$selected" ]]; then
            printf "\033[31mKill session '$selected'? (y/n): \033[0m"
            read -n 1 confirm < /dev/tty
            echo
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                tmux kill-session -t "$selected"
            fi
            exec bash "$0"
        fi
        ;;
    "")
        [[ -n "$selected" ]] && tmux switch-client -t "$selected"
        ;;
esac
