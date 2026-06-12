#!/bin/bash
# Move current window to another session via fzf picker

current=$(tmux display-message -p '#S')

target=$(tmux list-sessions -F '#{session_name}' | \
    grep -v "^${current}$" | \
    fzf --prompt='move to> ' --reverse --header="Move window to session")

[ -z "$target" ] && exit 0

tmux move-window -t "$target"
