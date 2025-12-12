#!/bin/bash

source "$CONFIG_DIR/colors.sh"

sketchybar --add item battery right \
           --set battery script="$PLUGIN_DIR/battery.sh" \
           --set battery icon.color=0xffffffff \
           --set battery icon.font="0xProto Nerd Font Mono:Bold:18.0" \
           --set battery label.color=0xffffffff \
           --set battery label.font="0xProto Nerd Font Mono:Bold:15.0" \
           --set battery update_freq=120 \
           --subscribe battery system_woke power_source_change
