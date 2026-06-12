#!/bin/bash
# Multi-machine remote session selector.
# Step 1: pick machine. Step 2: pick SSH or a tmux session.

MACHINES="mini
kawakawa
nuc"

get_tmux_path() {
    case "$1" in
        mini|kawakawa) echo "/opt/homebrew/bin/tmux" ;;
        nuc)           echo "/usr/bin/tmux" ;;
    esac
}

# Step 1: pick machine
machine=$(echo "$MACHINES" | \
    fzf --prompt='remote> ' --reverse --header='Select machine')
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
            line={}
            name=\$(echo \"\$line\" | sed 's/ *([0-9]*)$//' | xargs)
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
