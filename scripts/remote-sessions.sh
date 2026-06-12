#!/bin/bash
# Step 1: pick machine, then launch session list popup at wider size.

MACHINES="mini
kawakawa
nuc"

machine=$(echo "$MACHINES" | \
    fzf --prompt='remote> ' --reverse --header='Select machine')
[ -z "$machine" ] && exit 0

tmux display-popup -w 40 -h 15 -T " $machine " -E "bash ~/dotfiles/scripts/remote-session-list.sh $machine"
