#!/usr/bin/env python3
"""
Unified Pomodoro / Timer / Stopwatch for SketchyBar.

Usage:
  pomodoro.py tick        - Called every second by SketchyBar update_freq
  pomodoro.py toggle      - Start/pause/resume Pomodoro
  pomodoro.py skip        - Skip to next phase
  pomodoro.py reset       - Stop and return to idle
  pomodoro.py timer <sec> - Classic countdown timer
  pomodoro.py stopwatch   - Classic stopwatch
"""

import sys
import os
import json
import time
import subprocess

# --- Configuration ---
WORK_DURATION = 25 * 60       # 25 minutes
SHORT_BREAK_DURATION = 5 * 60  # 5 minutes
LONG_BREAK_DURATION = 15 * 60  # 15 minutes
SESSIONS_BEFORE_LONG = 4

STATE_FILE = "/tmp/sketchybar_pomodoro.json"

# Colors
WHITE = "0xffcad3f5"
RED = "0xffed8796"
ORANGE = "0xffffb86c"
GREEN = "0xff50fa7b"
BLUE = "0xff8be9fd"
GREY = "0xff6272a4"

# Icons
ICON_IDLE = "􁙆"
ICON_WORK = "􀐱"
ICON_SHORT_BREAK = "􀎸"
ICON_LONG_BREAK = "􀑬"
ICON_TIMER = "􀅵"
ICON_STOPWATCH = "􀐯"


def load_state():
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return default_state()


def save_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f)


def default_state():
    return {
        "mode": "idle",          # idle | pomodoro | timer | stopwatch
        "phase": "work",         # work | short_break | long_break
        "remaining": WORK_DURATION,
        "session": 0,            # completed in current cycle (0-3)
        "total": 0,              # total pomodoros today
        "paused": False,
        "running": False,
        "stopwatch_start": 0,
        "timer_total": 0,
    }


def format_time(seconds):
    seconds = max(0, int(seconds))
    if seconds >= 3600:
        h = seconds // 3600
        m = (seconds % 3600) // 60
        s = seconds % 60
        return f"{h:02d}:{m:02d}:{s:02d}"
    else:
        m = seconds // 60
        s = seconds % 60
        return f"{m:02d}:{s:02d}"


def sbar_set(props):
    """Set sketchybar timer item properties. props is a dict with dotted keys."""
    cmd = ["sketchybar", "--set", "timer"]
    for k, v in props.items():
        cmd.append(f"{k}={v}")
    subprocess.run(cmd, capture_output=True)


def update_display(state):
    mode = state["mode"]

    if mode == "idle":
        sbar_set({"icon": ICON_IDLE, "icon.color": GREY, "label": ""})
        return

    if mode == "stopwatch":
        elapsed = int(time.time()) - state["stopwatch_start"]
        if state["paused"]:
            elapsed = state["remaining"]
        sbar_set({
            "icon": ICON_STOPWATCH, "icon.color": WHITE,
            "label": format_time(elapsed), "label.color": WHITE,
        })
        return

    if mode == "timer":
        remaining = state["remaining"]
        color = RED if remaining < 60 else WHITE
        sbar_set({
            "icon": ICON_TIMER, "icon.color": WHITE,
            "label": format_time(remaining), "label.color": color,
        })
        return

    # Pomodoro mode
    phase = state["phase"]
    remaining = state["remaining"]
    paused = state["paused"]

    if phase == "work":
        prefix, icon, color = "W", ICON_WORK, ORANGE
    elif phase == "short_break":
        prefix, icon, color = "B", ICON_SHORT_BREAK, GREEN
    else:
        prefix, icon, color = "LB", ICON_LONG_BREAK, BLUE

    label = f"{prefix} {format_time(remaining)}"
    if paused:
        label += " ⏸"

    sbar_set({"icon": icon, "icon.color": color, "label": label, "label.color": color})


def notify(title, message):
    subprocess.run([
        "osascript", "-e",
        f'display notification "{message}" with title "{title}" sound name "Funk"'
    ], capture_output=True)


def transition_phase(state):
    """Handle phase transitions when time runs out."""
    phase = state["phase"]

    if phase == "work":
        state["session"] += 1
        state["total"] += 1
        if state["session"] % SESSIONS_BEFORE_LONG == 0:
            state["phase"] = "long_break"
            state["remaining"] = LONG_BREAK_DURATION
            notify("Pomodoro", f"Great work! Long break time. ({state['total']} total)")
        else:
            state["phase"] = "short_break"
            state["remaining"] = SHORT_BREAK_DURATION
            notify("Pomodoro", f"Take a short break! ({state['session']}/{SESSIONS_BEFORE_LONG})")
    else:
        # Break ended, start work
        state["phase"] = "work"
        state["remaining"] = WORK_DURATION
        notify("Pomodoro", "Break's over — time to focus!")

    # Play sound
    subprocess.Popen(["afplay", "/System/Library/Sounds/Funk.aiff"])


def cmd_tick(state):
    mode = state["mode"]

    if mode == "idle":
        update_display(state)
        return state

    if mode == "stopwatch":
        if not state["paused"]:
            state["remaining"] = int(time.time()) - state["stopwatch_start"]
        update_display(state)
        return state

    if mode == "timer":
        if not state["paused"] and state["running"]:
            state["remaining"] -= 1
            if state["remaining"] <= 0:
                sbar_set(label="Time Up!", **{"label.color": WHITE, "icon.color": WHITE}, icon=ICON_TIMER)
                notify("Timer", "Your timer has finished.")
                subprocess.Popen(["afplay", "/System/Library/Sounds/Funk.aiff"])
                return default_state()
        update_display(state)
        return state

    # Pomodoro mode
    if state["running"] and not state["paused"]:
        state["remaining"] -= 1
        if state["remaining"] <= 0:
            transition_phase(state)

    update_display(state)
    return state


def cmd_toggle(state):
    mode = state["mode"]

    if mode == "idle":
        # Start Pomodoro
        state["mode"] = "pomodoro"
        state["phase"] = "work"
        state["remaining"] = WORK_DURATION
        state["running"] = True
        state["paused"] = False
        notify("Pomodoro", "Focus time — let's go!")
    elif mode == "pomodoro":
        state["paused"] = not state["paused"]
    elif mode == "timer":
        state["paused"] = not state["paused"]
    elif mode == "stopwatch":
        if state["paused"]:
            # Resume: adjust start time to account for paused duration
            state["stopwatch_start"] = int(time.time()) - state["remaining"]
            state["paused"] = False
        else:
            state["remaining"] = int(time.time()) - state["stopwatch_start"]
            state["paused"] = True

    update_display(state)
    return state


def cmd_skip(state):
    if state["mode"] == "pomodoro":
        transition_phase(state)
    update_display(state)
    return state


def cmd_reset(state):
    state = default_state()
    update_display(state)
    return state


def cmd_timer(state, seconds):
    state = default_state()
    state["mode"] = "timer"
    state["remaining"] = seconds
    state["timer_total"] = seconds
    state["running"] = True
    state["paused"] = False
    update_display(state)
    return state


def cmd_stopwatch(state):
    state = default_state()
    state["mode"] = "stopwatch"
    state["stopwatch_start"] = int(time.time())
    state["remaining"] = 0
    state["running"] = True
    state["paused"] = False
    update_display(state)
    return state


def update_popup(state):
    """Update the session counter in popup."""
    import subprocess
    mode = state["mode"]
    if mode == "pomodoro":
        session_text = f"🍅 {state['session'] % SESSIONS_BEFORE_LONG}/{SESSIONS_BEFORE_LONG}  (Total: {state['total']})"
    elif mode == "idle":
        session_text = f"🍅 Ready  (Total: {state['total']})"
    else:
        session_text = ""
    subprocess.run(["sketchybar", "--set", "timer.sessions", f"label={session_text}"], capture_output=True)


def main(argv):
    state = load_state()

    if len(argv) < 2 or argv[1] == "tick":
        state = cmd_tick(state)
    elif argv[1] == "toggle":
        state = cmd_toggle(state)
    elif argv[1] == "skip":
        state = cmd_skip(state)
    elif argv[1] == "reset":
        state = cmd_reset(state)
    elif argv[1] == "timer" and len(argv) >= 3:
        try:
            seconds = int(argv[2])
            state = cmd_timer(state, seconds)
        except ValueError:
            pass
    elif argv[1] == "stopwatch":
        state = cmd_stopwatch(state)

    update_popup(state)
    save_state(state)


if __name__ == "__main__":
    main(sys.argv)
