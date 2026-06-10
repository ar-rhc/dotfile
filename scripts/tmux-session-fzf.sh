#!/bin/bash

# Enhanced Tmux Session Switcher & Manager
# ------------------------------------------------------------------------------
# Usage:
#   Enter   - Switch to session
#   Ctrl-r  - Rename session
#   Ctrl-x  - Kill session
# ------------------------------------------------------------------------------

# 1. Get just the session names
# 2. Use FZF with custom keybindings for managing sessions
selected=$(tmux list-sessions -F '#S' 2>/dev/null | \
    fzf --reverse \
        --header 'Enter: Switch | Ctrl-r: Rename | Ctrl-x: Kill' \
        --preview 'tmux list-windows -t {}' \
        --preview-window 'right:50%' \
        --bind 'ctrl-r:execute(read -p "New name: " name && tmux rename-session -t {} "$name")+reload(tmux list-sessions -F "#S")' \
        --bind 'ctrl-x:execute(tmux kill-session -t {})+reload(tmux list-sessions -F "#S")')

# 3. Switch to the selected session if it still exists
if [[ -n "$selected" ]]; then
    # Final check if session still exists (in case it was just killed)
    if tmux has-session -t "$selected" 2>/dev/null; then
        tmux switch-client -t "$selected"
    fi
fi
