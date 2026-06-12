#!/bin/bash
# Show quick action menu. Adds remote section when pane is running ssh.

PANE_CMD=$(tmux display-message -p '#{pane_current_command}')

BASE_ITEMS=(
    "Horizontal Split"   "|" "split-window -h -c '#{pane_current_path}'"
    "Vertical Split"     "-" "split-window -v -c '#{pane_current_path}'"
    ""                   ""  ""
    "Zoom Pane"          "z" "resize-pane -Z"
    "Kill Pane"          "x" "kill-pane"
    ""                   ""  ""
    "Rename Pane"        "r" "command-prompt -p 'New pane title:' -I '#{pane_title}' 'select-pane -T %%'"
    "Rename Window"      "R" "command-prompt -I '#W' 'rename-window %%'"
    "Session Switcher"   "s" "display-popup -w 30% -h 35% -E 'bash ~/dotfiles/scripts/tmux-session-fzf.sh'"
    "List Shortcuts"     "?" "list-keys"
    ""                   ""  ""
    "── Remote ──"       ""  ""
    "Remote Sessions"    "k" "display-popup -w 38% -h 50% -E 'bash ~/dotfiles/scripts/remote-sessions.sh'"
)

REMOTE_ITEMS=(
    ""                   ""  ""
    "── Remote ──"       ""  ""
    "Remote Sessions"    "w" "display-popup -w 38% -h 50% -E 'bash ~/dotfiles/scripts/remote-sessions.sh'"
    "Exit Remote Tmux"   "d" "send-keys C-q C-q d"
)

ITEMS=("${BASE_ITEMS[@]}")
if [ "$PANE_CMD" = "ssh" ]; then
    ITEMS+=("${REMOTE_ITEMS[@]}")
fi

# Build the display-menu command
CMD=(tmux display-menu -T "#[align=centre] Quick Actions " -x C -y C)
for ((i=0; i<${#ITEMS[@]}; i+=3)); do
    CMD+=("${ITEMS[$i]}" "${ITEMS[$i+1]}" "${ITEMS[$i+2]}")
done

"${CMD[@]}"
