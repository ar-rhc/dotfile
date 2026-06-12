#!/bin/bash
# Show quick action menu. Adds remote section when pane is running ssh.

PANE_CMD=$(tmux display-message -p '#{pane_current_command}')

BASE_ITEMS=(
    "Horizontal Split" "|" "split-window -h -c '#{pane_current_path}'"
    "Vertical Split"   "-" "split-window -v -c '#{pane_current_path}'"
    ""                 ""  ""
    "Zoom Pane"        "z" "resize-pane -Z"
    "Kill Pane"        "x" "kill-pane"
    ""                 ""  ""
    "Rename Pane"      "r" "command-prompt -p 'New pane title:' -I '#{pane_title}' 'select-pane -T %%'"
    "Rename Window"    "R" "command-prompt -I '#W' 'rename-window %%'"
    "Session Switcher" "s" "display-popup -w 30% -h 35% -E 'bash ~/dotfiles/scripts/tmux-session-fzf.sh'"
    "List Shortcuts"   "?" "list-keys"
)

REMOTE_ITEMS=(
    ""                 ""  ""
    "── Kawakawa ──"   ""  ""
    "Switch Session"   "k" "display-popup -w 50% -h 40% -E 'bash ~/dotfiles/scripts/kawakawa-sessions.sh'"
    "List Sessions"    "l" "display-popup -w 40% -h 20% \"ssh kawakawa '/opt/homebrew/bin/tmux ls 2>/dev/null || echo no sessions'\""
    "Close Remote"     "d" "kill-window"
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
