#!/bin/bash
selected=$(ssh kawakawa '/opt/homebrew/bin/tmux ls 2>/dev/null' | fzf --prompt='kawakawa> ' | cut -d: -f1)
[ -n "$selected" ] && tmux new-window -n kawakawa "ssh -t kawakawa '/opt/homebrew/bin/tmux attach -t $selected'"
