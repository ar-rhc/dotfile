#!/bin/bash

# Improved Tmux Sessionizer
# ------------------------------------------------------------------------------

# 1. Define and expand paths
# Using an array for cleaner path management
paths=(
    "$HOME/dotfiles"
    "/Users/alex/ARfiles"
    "/Users/alex/ARfiles/Obsidian/Obsidian-Git"
)

# 2. Use find to collect directories and pipe to FZF
# We filter for directories (-type d) and limit depth
selected=$(find "${paths[@]}" -maxdepth 1 -type d 2>/dev/null | /opt/homebrew/bin/fzf --reverse --header 'Select Folder to Create/Switch Session')

# Exit if nothing was selected (ESC or empty)
if [[ -z "$selected" ]]; then
    exit 0
fi

# 3. Clean up the session name
# basename gets the folder name, tr replaces dots with underscores
selected_name=$(basename "$selected" | tr . _)

# 4. Create session if it doesn't exist
if ! tmux has-session -t "$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

# 5. Switch to the session
# Logic: If we are already in tmux, switch client. If not, attach.
if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$selected_name"
else
    tmux attach-session -t "$selected_name"
fi
