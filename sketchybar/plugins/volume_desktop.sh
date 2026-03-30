#!/bin/bash

source "$CONFIG_DIR/icons.sh"

update_icon() {
  MUTE=$(betterdisplaycli get -n=LG --mute 2>/dev/null)
  VOL=$(betterdisplaycli get -n=LG --volume 2>/dev/null)

  if [ "$MUTE" = "on" ] || [ -z "$VOL" ]; then
    ICON=$VOLUME_0
  else
    PCT=$(python3 -c "print(int(float('${VOL}') * 100))" 2>/dev/null)
    if [ -z "$PCT" ] || [ "$PCT" -le 0 ]; then
      ICON=$VOLUME_0
    elif [ "$PCT" -le 15 ]; then
      ICON=$VOLUME_10
    elif [ "$PCT" -le 40 ]; then
      ICON=$VOLUME_33
    elif [ "$PCT" -le 65 ]; then
      ICON=$VOLUME_66
    else
      ICON=$VOLUME_100
    fi
  fi

  sketchybar --set volume_desktop icon="$ICON"
}

case "$SENDER" in
  "mouse.entered")
    VOL=$(betterdisplaycli get -n=LG --volume 2>/dev/null)
    PCT=$(python3 -c "print(int(float('${VOL:-0}') * 100))" 2>/dev/null)
    sketchybar --set volume_desktop_slider slider.percentage="${PCT:-50}" \
               --animate tanh 30 --set volume_desktop_slider slider.width=100
    ;;
  "mouse.exited.global")
    sketchybar --animate tanh 30 --set volume_desktop_slider slider.width=0
    ;;
  *)
    update_icon
    ;;
esac
