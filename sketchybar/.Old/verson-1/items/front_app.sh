#!/bin/bash

sketchybar --add item front_app center \
           --set front_app       background.color=$ACCENT_COLOR \
                                 icon.color=$BAR_COLOR \
                                 icon.font="sketchybar-app-font:Regular:16.0" \
                                 label.color=$BAR_COLOR \
                                 display=active \
                                 script="$PLUGIN_DIR/front_app.sh"            \
           --subscribe front_app front_app_switched
