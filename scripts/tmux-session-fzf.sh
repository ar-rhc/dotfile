#!/bin/bash

# Super Stable Tmux Session Switcher & Manager
# ------------------------------------------------------------------------------

# 1. Get just the session names
# 2. Use FZF with custom keybindings
# We use bash -c inside FZF to make sure the environment is clean
selected=$(tmux list-sessions -F '#S' 2>/dev/null | \
    fzf --reverse \
        --header 'Enter: Switch | Ctrl-r: Rename | Ctrl-x: Kill' \
        --preview 'tmux list-windows -t {}' \
        --preview-window 'right:50%' \
        --bind 'ctrl-r:execute-silent(bash -c "read -p \"New name for {}: \" name < /dev/tty && tmux rename-session -t \"{}\" \"\$name\"")+reload(tmux list-sessions -F "#S")' \
        --bind 'ctrl-x:execute(tmux kill-session -t "{}")+reload(tmux list-sessions -F "#S")')

# 3. Switch to the selected session
if [[ -n "$selected" ]]; then
    if tmux has-session -t "$selected" 2>/dev/null; then
        tmux switch-client -t "$selected"
    fi
fi
