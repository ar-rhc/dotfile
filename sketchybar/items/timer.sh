#!/usr/bin/env bash

POMODORO="python3 $PLUGIN_DIR/pomodoro.py"

# Main timer item — tick every second
timer=(
  icon="􁙆"
  icon.color=$GREY
  script="$PLUGIN_DIR/timer_script.sh"
  click_script="$POMODORO toggle"
  updates=on
  update_freq=1
  popup.background.border_width=0
  popup.height=35
  padding_left=5
)

# --- Pomodoro section ---
pomo_toggle=(
  label="Start"
  icon="􀊄"
  click_script="sketchybar --set timer popup.drawing=off; $POMODORO toggle"
)

pomo_skip=(
  label="Skip"
  icon="􀊐"
  click_script="sketchybar --set timer popup.drawing=off; $POMODORO skip"
)

pomo_reset=(
  label="Reset"
  icon="􀛶"
  click_script="sketchybar --set timer popup.drawing=off; $POMODORO reset"
)

pomo_sessions=(
  label="🍅 Ready"
  icon.drawing=off
)

# --- Timer presets section ---
preset1=(label="3 min"   click_script="sketchybar --set timer popup.drawing=off; $POMODORO timer 180")
preset2=(label="5 min"   click_script="sketchybar --set timer popup.drawing=off; $POMODORO timer 300")
preset3=(label="10 min"  click_script="sketchybar --set timer popup.drawing=off; $POMODORO timer 600")
preset4=(label="20 min"  click_script="sketchybar --set timer popup.drawing=off; $POMODORO timer 1200")
preset5=(label="1 hour"  click_script="sketchybar --set timer popup.drawing=off; $POMODORO timer 3600")

# Custom time via dialog
custom=(
  label="Custom…"
  click_script="sketchybar --set timer popup.drawing=off; mins=\$(osascript -e 'text returned of (display dialog \"Enter minutes:\" default answer \"15\")' 2>/dev/null) && [ -n \"\$mins\" ] && $POMODORO timer \$((\$mins * 60))"
)

# --- Stopwatch section ---
stopwatch=(
  label="Stopwatch"
  icon="􀐯"
  click_script="sketchybar --set timer popup.drawing=off; $POMODORO stopwatch"
)

sketchybar --add item timer left \
           --set timer "${timer[@]}" \
           --subscribe timer mouse.entered mouse.exited mouse.exited.global \
                                                                          \
           --add item timer.pomo_toggle popup.timer \
           --set timer.pomo_toggle "${pomo_toggle[@]}" \
           --add item timer.pomo_skip popup.timer \
           --set timer.pomo_skip "${pomo_skip[@]}" \
           --add item timer.pomo_reset popup.timer \
           --set timer.pomo_reset "${pomo_reset[@]}" \
           --add item timer.sessions popup.timer \
           --set timer.sessions "${pomo_sessions[@]}" \
                                                      \
           --add item timer.preset1 popup.timer \
           --set timer.preset1 "${preset1[@]}" \
           --add item timer.preset2 popup.timer \
           --set timer.preset2 "${preset2[@]}" \
           --add item timer.preset3 popup.timer \
           --set timer.preset3 "${preset3[@]}" \
           --add item timer.preset4 popup.timer \
           --set timer.preset4 "${preset4[@]}" \
           --add item timer.preset5 popup.timer \
           --set timer.preset5 "${preset5[@]}" \
           --add item timer.custom popup.timer \
           --set timer.custom "${custom[@]}" \
                                             \
           --add item timer.stopwatch popup.timer \
           --set timer.stopwatch "${stopwatch[@]}"
