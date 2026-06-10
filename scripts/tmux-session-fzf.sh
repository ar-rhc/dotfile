#!/bin/bash

# Tmux FZF Session Switcher
# Encapsulated in a script to avoid quoting issues in tmux.conf

# 1. Get the list of sessions
# 2. Use FZF to pick one
# 3. Switch to it
target=$(tmux list-sessions -F '#S' | /opt/homebrew/bin/fzf --reverse --header 'Switch Session')

if [ -n "$target" ]; then
    tmux switch-client -t "$target"
fi
