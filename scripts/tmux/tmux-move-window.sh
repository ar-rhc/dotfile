#!/bin/bash
# Move current window to another (or new) session via fzf picker

src_window="$1"
current=$(tmux display-message -p '#S')

sessions=$(tmux list-sessions -F '#{session_name}' | grep -v "^${current}$")
options=$(printf '+ New Session\n'; echo "$sessions" | awk '{printf "%-25s (%d)\n", $0, NR}')

count=$(echo "$sessions" | grep -c .)
expect_keys=$(seq 1 $count | tr '\n' ',' | sed 's/,$//')

result=$(echo "$options" | \
    fzf --prompt='move to> ' --reverse \
        --expect="$expect_keys" \
        --header="Move window to session")

[ -z "$result" ] && exit 0

key=$(echo "$result" | head -n 1)
line=$(echo "$result" | sed -n '2p')

if echo "$key" | grep -qE '^[0-9]+$'; then
    target=$(echo "$sessions" | sed -n "${key}p")
else
    target=$(echo "$line" | sed 's/ *([0-9]*)$//' | xargs)
fi

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
