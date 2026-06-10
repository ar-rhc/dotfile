#!/bin/bash

# Stable Tmux Session Switcher
# ------------------------------------------------------------------------------

# 1. Get just the session names (simplest and most reliable)
# 2. Use FZF with a preview of the windows in that session
selected=$(/opt/homebrew/bin/tmux list-sessions -F '#S' 2>/dev/null | \
    /opt/homebrew/bin/fzf --reverse \
        --header 'Jump to Session' \
        --preview '/opt/homebrew/bin/tmux list-windows -t {}' \
        --preview-window 'right:50%')

# 3. Switch to the selected session
if [[ -n "$selected" ]]; then
    /opt/homebrew/bin/tmux switch-client -t "$selected"
fi
