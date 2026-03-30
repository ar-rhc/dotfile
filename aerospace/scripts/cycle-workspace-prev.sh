#!/bin/bash

# Cycle backwards through workspaces in custom order based on focused monitor
# Skips empty workspaces
# Monitor 1: 1, Q, A, Z (reversed)
# Monitor 2: 2, W, S, X (reversed)
# Monitor 3: 3, E, D, C, M (reversed)

# 1. Get the ID of the currently focused monitor
# AeroSpace returns monitor IDs (usually 1, 2, 3...)
AEROSPACE="${AEROSPACE:-/opt/homebrew/bin/aerospace}"
FOCUS_MON=$("$AEROSPACE" list-monitors --focused --format "%{monitor-id}")

# 2. Define the workspace lists for each monitor based on your layout (reversed for backwards)
case "$FOCUS_MON" in
    1)
        # Monitor 1 list (reversed for backwards cycling)
        ORDERED_LIST="Z A Q 1"
        ;;
    2)
        # Monitor 2 list (reversed for backwards cycling)
        ORDERED_LIST="X S W 2"
        ;;
    3)
        # Monitor 3 list (reversed for backwards cycling)
        ORDERED_LIST="M C D E 3"
        ;;
    *)
        # Fallback for unexpected monitor IDs
        exit 1
        ;;
esac

# 3. Get non-empty workspaces for this monitor
NON_EMPTY=$("$AEROSPACE" list-workspaces --monitor "$FOCUS_MON" --empty no --format "%{workspace}" 2>/dev/null)

# 4. Filter ordered list to only include non-empty workspaces
FILTERED_LIST=""
for ws in $ORDERED_LIST; do
    # Check if workspace is in the non-empty list
    if echo "$NON_EMPTY" | grep -q "^${ws}$"; then
        if [ -z "$FILTERED_LIST" ]; then
            FILTERED_LIST="$ws"
        else
            FILTERED_LIST="${FILTERED_LIST}\n${ws}"
        fi
    fi
done

# 5. If we have any non-empty workspaces, cycle through them
if [ -n "$FILTERED_LIST" ]; then
    printf "%b\n" "$FILTERED_LIST" | "$AEROSPACE" workspace --wrap-around --stdin next
else
    # If all workspaces are empty, just stay on current (or exit silently)
    exit 0
fi

# Update sketchybar spaces after workspace change
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sleep 0.1
/bin/bash "$SCRIPT_DIR/update-sketchybar-spaces.sh"

