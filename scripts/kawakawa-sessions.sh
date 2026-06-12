#!/bin/bash

TMUX_REMOTE="/opt/homebrew/bin/tmux"

result=$(ssh kawakawa "$TMUX_REMOTE list-sessions -F '#{session_last_attached} #S' 2>/dev/null" | \
    sort -rn | \
    cut -d' ' -f2- | \
    awk '{printf "%-25s (%d)\n", $0, NR}' | \
    fzf --reverse --expect=ctrl-x \
        --header 'kawakawa  |  X: Kill' \
        --preview "ssh kawakawa \"$TMUX_REMOTE list-windows -t \$(echo {} | sed 's/ *([0-9]*)$//') -F ' #I: #W'\"" \
        --preview-window 'bottom:40%')

key=$(echo "$result" | head -n 1)
selected_line=$(echo "$result" | sed -n '2p')
selected=$(echo "$selected_line" | sed 's/ *([0-9]*)$//')

case "$key" in
    ctrl-x)
        if [[ -n "$selected" ]]; then
            printf "\033[31mKill remote session '%s'? (y/n): \033[0m" "$selected"
            read -n 1 confirm < /dev/tty
            echo
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                ssh kawakawa "$TMUX_REMOTE kill-session -t '$selected'"
            fi
            exec bash "$0"
        fi
        ;;
    "")
        [[ -n "$selected" ]] && tmux respawn-pane -k -t "${PARENT_PANE:-.}" "ssh -t kawakawa '$TMUX_REMOTE attach -t $selected'"
        ;;
esac
