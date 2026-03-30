#!/bin/bash

zen_on() {
  sketchybar --set wifi drawing=off \
             --set '/cpu.*/' drawing=off \
             --set calendar icon.drawing=off \
             --set separator drawing=off \
             --set front_app drawing=off \
             --set volume_icon drawing=off \
             --set spotify.anchor drawing=off \
             --set spotify.play updates=off \
             --set brew drawing=off \
             --set volume drawing=off \
             --set github.bell drawing=off \
             --set next_event label.drawing=off \
            # --set next_event drawing=off \
}

zen_off() {
  sketchybar --set wifi drawing=on \
             --set '/cpu.*/' drawing=on \
             --set calendar icon.drawing=on \
             --set separator drawing=on \
             --set front_app drawing=on \
             --set volume_icon drawing=on \
             --set spotify.play updates=on \
             --set brew drawing=on \
             --set volume drawing=on \
             --set github.bell drawing=on \
             --set next_event label.drawing=on \
             #--set next_event drawing=on \
}
#--set apple.logo drawing=off \
if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  # Use calendar icon drawing state to determine zen mode
  if [ "$(sketchybar --query calendar | jq -r ".icon.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi

