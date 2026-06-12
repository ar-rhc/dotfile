#!/bin/bash

# Compact & Ranked Tmux Session Switcher
# ------------------------------------------------------------------------------

# 1. Get sessions, sort by last attached time (descending), and format
#    We use a timestamp for sorting, then remove it, then number with awk.
result=$(tmux list-sessions -F "#{session_last_attached} #S" 2>/dev/null | \
    sort -rn | \
    cut -d' ' -f2- | \
    awk '{printf "%-25s (%d)\n", $0, NR}' | \
    fzf --reverse --expect=ctrl-r,ctrl-x \
        --header 'R: Rename | X: Kill' \
        --preview 'tmux list-windows -t $(echo {} | sed "s/ *([0-9]*)$//") -F " #I: #W"' \
        --preview-window 'bottom:40%')

# Parse result
key=$(echo "$result" | head -n 1)
selected_line=$(echo "$result" | sed -n '2p')
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
