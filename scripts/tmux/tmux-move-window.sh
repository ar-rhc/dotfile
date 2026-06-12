#!/bin/bash
# Move current window to another (or new) session via fzf picker

src_window="$1"
current=$(tmux display-message -p '#S')

target=$({ echo "+ New Session"; tmux list-sessions -F '#{session_name}' | grep -v "^${current}$"; } | \
    fzf --prompt='move to> ' --reverse --header="Move window to session")

[ -z "$target" ] && exit 0

if [ "$target" = "+ New Session" ]; then
    printf "New session name: "
    read -r name < /dev/tty
    [ -z "$name" ] && exit 0
    tmux new-session -d -s "$name"
    tmux move-window -s "$src_window" -t "$name"
else
    tmux move-window -s "$src_window" -t "$target"
fi
