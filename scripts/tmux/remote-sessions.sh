#!/bin/bash
# Multi-machine remote session selector.
# Step 1: pick machine. Step 2: pick SSH or a tmux session.

ALL_MACHINES="mini
kawakawa
nuc"

get_tmux_path() {
    case "$1" in
        mini|kawakawa) echo "/opt/homebrew/bin/tmux" ;;
        nuc)           echo "/usr/bin/tmux" ;;
    esac
}

# Filter out local machine if REMOTE_SELF is set
if [ -n "$REMOTE_SELF" ]; then
    machines=$(echo "$ALL_MACHINES" | grep -v "^${REMOTE_SELF}$")
else
    machines="$ALL_MACHINES"
fi

# Number the list (same style as session switcher)
numbered=$(echo "$machines" | awk '{printf "%-25s (%d)\n", $0, NR}')
count=$(echo "$machines" | wc -l | tr -d ' ')
expect_keys=$(seq 1 $count | tr '\n' ',' | sed 's/,$//')

# Step 1: pick machine
result=$(echo "$numbered" | \
    fzf --prompt='remote> ' --reverse \
        --expect="$expect_keys" \
        --header="Select machine")
[ -z "$result" ] && exit 0

key=$(echo "$result" | head -n 1)
line=$(echo "$result" | sed -n '2p')

if echo "$key" | grep -qE '^[0-9]+$'; then
    machine=$(echo "$machines" | sed -n "${key}p")
else
    machine=$(echo "$line" | sed 's/ *([0-9]*)$//' | xargs)
fi
[ -z "$machine" ] && exit 0

tmux_remote=$(get_tmux_path "$machine")

# Step 2: fetch sessions + prepend SSH option
sessions=$(ssh "$machine" "$tmux_remote list-sessions -F '#{session_last_attached} #S' 2>/dev/null" | \
    sort -rn | \
    cut -d' ' -f2- | \
    awk '{printf "%-25s (%d)\n", $0, NR}')

options=$(printf '%-25s\n' "SSH"; [ -n "$sessions" ] && echo "$sessions")

result=$(echo "$options" | \
    fzf --prompt="$machine> " --reverse --expect=ctrl-x \
        --header "$machine  |  X: Kill session" \
        --preview "
            name=\$(echo {} | sed 's/ *([0-9]*)$//' | xargs)
            if [ \"\$name\" = 'SSH' ]; then
                echo 'Open plain SSH session'
            else
                ssh $machine \"$tmux_remote list-windows -t \\\"\$name\\\" -F ' #I: #W' 2>/dev/null\"
            fi
        " \
        --preview-window 'bottom:40%')

key=$(echo "$result" | head -n 1)
selected_line=$(echo "$result" | sed -n '2p')
selected=$(echo "$selected_line" | sed 's/ *([0-9]*)$//' | xargs)

[ -z "$selected" ] && exit 0

case "$key" in
    ctrl-x)
        if [ "$selected" != "SSH" ]; then
            printf "\033[31mKill session '%s' on %s? (y/n): \033[0m" "$selected" "$machine"
            read -n 1 confirm < /dev/tty
            echo
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                ssh "$machine" "$tmux_remote kill-session -t '$selected'"
            fi
            exec bash "$0"
        fi
        ;;
    "")
        if [ "$selected" = "SSH" ]; then
            tmux new-window -n "$machine" "ssh $machine"
        else
            tmux new-window -n "$machine" "ssh -t $machine '$tmux_remote attach -t $selected; exec bash'"
        fi
        ;;
esac
