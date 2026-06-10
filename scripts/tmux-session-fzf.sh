#!/bin/bash

# Enhanced Tmux Session Switcher
# Shows metadata and a preview of windows in the session

# 1. Define the format for the list
# Format: session_name | windows count | last attached
format="#{session_name} | #{session_windows} windows | last: #{t/p:session_last_attached}"

# 2. Run FZF with a preview window
selected=$(tmux list-sessions -F "$format" 2>/dev/null | \
    /opt/homebrew/bin/fzf --reverse \
        --header 'Jump to active session' \
        --preview 'tmux list-windows -t $(echo {} | cut -d" " -f1)' \
        --preview-window 'right:40%')

# 3. Switch if something was selected
if [[ -n $selected ]]; then
    # Extract the session name (everything before the first space)
    target=$(echo "$selected" | cut -d' ' -f1)
    tmux switch-client -t "$target"
fi
