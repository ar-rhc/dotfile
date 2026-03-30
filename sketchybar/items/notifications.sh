   #!/bin/bash
   
# Pre-add notification items (hidden by default)
sketchybar --add item notif.mail right \
    --set notif.mail drawing=off width=0 padding_left=0 padding_right=0

sketchybar --add item notif.messages right \
    --set notif.messages drawing=off width=0 padding_left=0 padding_right=0

sketchybar --add item notif.whatsapp right \
    --set notif.whatsapp drawing=off width=0 padding_left=0 padding_right=0

sketchybar --add item notif.wechat right \
    --set notif.wechat drawing=off width=0 padding_left=0 padding_right=0

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