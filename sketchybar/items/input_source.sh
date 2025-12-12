#!/bin/sh

sketchybar --add item input_source right

sketchybar --set input_source \
    icon.font="$FONT:Regular:20.0" \
    script="$PLUGIN_DIR/get_input_source.sh" \
    icon.color=0xffffffff \
    update_freq=1 \
    click_script='
        #!/bin/bash

        # Get the current input source
        CURRENT=$(macism)

        # The IDs you provided
        ENGLISH="com.apple.keylayout.ABC"
        CHINESE="com.apple.inputmethod.SCIM.ITABC"

        if [ "$CURRENT" = "$ENGLISH" ]; then
            macism $CHINESE
        else
            macism $ENGLISH
        fi
    '

