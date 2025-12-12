   #!/bin/bash
   
# Pre-add notification items (hidden by default)
sketchybar --add item notif.mail right \
    --set notif.mail drawing=off

sketchybar --add item notif.messages right \
    --set notif.messages drawing=off

# Add the main notifications item that triggers the script
# IMPORTANT: We use a tiny invisible item (width=0) instead of drawing=off
# because drawing=off prevents scripts from running even with updates=on
   sketchybar --add item notifications right \
       --set notifications \
           script="$PLUGIN_DIR/notifications.sh" \
           update_freq=5 \
        updates=on \
        width=0 \
        padding_left=0 \
        padding_right=0 \
        icon.drawing=off \
        label.drawing=off \
        background.drawing=off \
    --subscribe notifications system_woke