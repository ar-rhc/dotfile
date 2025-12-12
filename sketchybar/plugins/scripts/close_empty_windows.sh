#!/bin/bash
# close_empty_windows.sh

aerospace list-windows --all | while IFS='|' read -r window_id app_name title; do
    # Trim whitespace
    window_id=$(echo "$window_id" | xargs)
    title=$(echo "$title" | xargs)
    
    # If title is empty, close the window
    if [ -z "$title" ] || [ "$title" = "" ]; then
        if [ -n "$window_id" ]; then
            aerospace close --window-id "$window_id"
        fi
    fi
done

