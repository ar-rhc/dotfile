# AeroSpace Hotkey Reference

> Caps Lock = **Shift+Ctrl+Opt** via Karabiner.
> `caps+key` = `alt-ctrl-shift-key`

## Modes

| Hotkey | Action |
|--------|--------|
| `caps+esc` | Enter **Service Mode** |
| `caps+backtick` | Enter **App Mode** |

---

## Main Mode

### Layout
| Hotkey | Action |
|--------|--------|
| `caps+/` | Toggle tiles horizontal/vertical |
| `caps+.` | Toggle accordion horizontal/vertical |
| `caps+,` | Toggle accordion horizontal/vertical (alias) |
| `caps+f` | Toggle floating/tiling |
| `caps+v` | Center active window |
| `caps+r` | SketchyBar update (green flash) |

### Focus Window
| Hotkey | Action |
|--------|--------|
| `alt+shift+h/j/k/l` | Focus left/down/up/right (cross-monitor) |
| `alt+keypad 4/2/8/6` | Focus left/down/up/right |
| `alt+shift+ctrl+tab` | Focus next (DFS) |
| `cmd+alt+shift+ctrl+tab` | Focus previous (DFS) |

### Move Window
| Hotkey | Action |
|--------|--------|
| `caps+h/j/k/l` | Move left/down/up/right |
| `caps+keypad 4/2/8/6` | Move left/down/up/right |

### Resize
| Hotkey | Action |
|--------|--------|
| `caps+[` / `caps+]` | Resize ±50 |
| `caps+keypad -/+` | Resize ±50 |

### Switch Workspace

**Monitor 1 (HP E24u):** 1, Q, A, Z
**Monitor 2 (LG ULTRAFINE):** 2, W, S, X
**Monitor 3 (S24C31x):** 3, E, D, C, M

| Hotkey | Workspace |
|--------|-----------|
| `caps+1/q/a/z` | 1/Q/A/Z |
| `caps+2/w/s/x` | 2/W/S/X |
| `caps+3/e/d/c/m` | 3/E/D/C/M |

### Move Window to Workspace + Follow
| Hotkey | Workspace |
|--------|-----------|
| `alt+shift+1/q/a/z` | 1/Q/A/Z |
| `alt+shift+2/w/s/x` | 2/W/S/X |
| `alt+shift+3/e/d/c/m` | 3/E/D/C/M |

### Workspace Cycling
| Hotkey | Action |
|--------|--------|
| `alt+ctrl+p` | Next workspace on current monitor |
| `alt+ctrl+o` | Previous workspace on current monitor |

### Display Brightness
| Hotkey | Action |
|--------|--------|
| `alt+keypad +` | HP + Samsung brightness 100% |
| `alt+keypad -` / `alt+keypad 0` | HP + Samsung brightness 0% |

---

## Service Mode (`caps+esc` to enter)

Cheat sheet shows on left bar. Green bar color.

| Key | Action | Exits? |
|-----|--------|--------|
| `esc` | Reload config + update + exit | Yes |
| `caps+esc` | Exit only | Yes |
| `f` | Toggle floating/tiling | **Yes** |
| `w` | Close focused window | **Yes** |
| `caps+f` | Toggle fullscreen | **Yes** |
| `d` | Toggle default float/tile (edits toml) | No |
| `t` | Toggle tiles/accordion | No |
| `e` | Balance/equalize sizes | No |
| `s` | Toggle split h/v | No |
| `g` | Toggle gaps | No |
| `r` | Flatten workspace (reset) | No |
| `q` | Full SketchyBar reload | No |
| `c` | Close empty windows | No |
| `+`/`-` | Resize ±50 | No |
| `h/j/k/l` | Join left/down/up/right | No |
| `←↓↑→` | Join left/down/up/right | No |

---

## App Mode (`caps+backtick` to enter)

Quick-launch apps. Auto-exits after selection. Purple bar color.

| Key | App |
|-----|-----|
| `q` | Weather |
| `w` | WeChat |
| `e` | Microsoft Edge |
| `t` | iTerm2 |
| `c` | Calendar |
| `f` | Finder |
| `b` | BetterTouchTool |
| `z` | Zotero |
| `m` | Mail |
| `esc` | Exit |
| `caps+backtick` | Exit (toggle) |

---

## SketchyBar Items

### Left Side
`app_list` → `apple` → `menu_trigger` → `spaces` → `space_creator` → `front_app` → `timer`

### Center
`service_mode` / `music`

### Right Side (right to left)
`calendar` → `notifications` → `trash` → `focus` → `next_event` → `volume` → `input_source` → `wifi` → `ram` → `weather` → `app_list`

### Interactions
| Item | Click | Hover | Cmd+Click |
|------|-------|-------|-----------|
| Calendar | Zen mode toggle | — | — |
| Weather | Forecast popup | — | — |
| Weather (right) | Open Weather app | — | — |
| Next Event | Day popup (today+tmr) | Expand title | Open Calendar |
| Volume | Mute toggle | Slider | — |
| RAM | Process popup | — | Kill process |
| Trash | Empty trash dialog | — | Open trash |
| App List | — | App list popup | Close app |
| Music | Play/pause | Popup help | Open Music |
| Timer | Start/pause pomodoro | Popup controls | — |
| Apple | — | Popup menu | — |
