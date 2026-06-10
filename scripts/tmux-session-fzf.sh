#!/bin/bash

# Stable Tmux Session Switcher & Manager
# ------------------------------------------------------------------------------

# 1. Get just the session names
# 2. Use FZF with custom keybindings
# Note: we use 'read' with redirection from /dev/tty to ensure it's interactive
selected=$(tmux list-sessions -F '#S' 2>/dev/null | \
    fzf --reverse \
        --header 'Enter: Switch | Ctrl-r: Rename | Ctrl-x: Kill' \
        --preview 'tmux list-windows -t {}' \
        --preview-window 'right:50%' \
        --bind 'ctrl-r:execute(printf "New name for {}: "; read name < /dev/tty; tmux rename-session -t "{}" "$name")+reload(tmux list-sessions -F "#S")' \
        --bind 'ctrl-x:execute(tmux kill-session -t "{}")+reload(tmux list-sessions -F "#S")')

# 3. Switch to the selected session if it still exists
if [[ -n "$selected" ]]; then
    if tmux has-session -t "$selected" 2>/dev/null; then
        tmux switch-client -t "$selected"
    fi
fi
