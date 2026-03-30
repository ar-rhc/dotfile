# AeroSpace Hotkey Reference

> Caps Lock is remapped to **Shift+Ctrl+Opt** via Karabiner.
> So `alt-ctrl-shift-*` = **Caps Lock + key** in practice.

## Modes

| Hotkey | Action |
|--------|--------|
| `caps-esc` | Enter **Service Mode** |
| `caps-backtick` | Enter **App Mode** |

---

## Main Mode

### Layout
| Hotkey | Action |
|--------|--------|
| `caps-/` | Toggle tiles horizontal/vertical |
| `caps-,` | Toggle accordion horizontal/vertical |
| `caps-f` | Toggle floating/tiling |

### Focus Window
| Hotkey | Action |
|--------|--------|
| `alt-shift-h/j/k/l` | Focus left/down/up/right (cross-monitor) |
| `alt-keypad 4/2/8/6` | Focus left/down/up/right (cross-monitor) |
| `alt-shift-ctrl-tab` | Focus next (DFS traversal) |
| `cmd-alt-shift-ctrl-tab` | Focus previous (DFS traversal) |

### Move Window
| Hotkey | Action |
|--------|--------|
| `caps-h/j/k/l` | Move left/down/up/right |
| `caps-keypad 4/2/8/6` | Move left/down/up/right |

### Resize
| Hotkey | Action |
|--------|--------|
| `caps-[` / `caps-]` | Resize smart -50 / +50 |
| `caps-keypad -/+` | Resize smart -50 / +50 |

### Switch Workspace

**Monitor 1 (HP E24u):** Workspaces 1, Q, A, Z
**Monitor 2 (LG ULTRAFINE):** Workspaces 2, W, S, X
**Monitor 3 (S24C31x):** Workspaces 3, E, D, C, M

| Hotkey | Workspace |
|--------|-----------|
| `caps-1` / `caps-q` / `caps-a` / `caps-z` | 1 / Q / A / Z |
| `caps-2` / `caps-w` / `caps-s` / `caps-x` | 2 / W / S / X |
| `caps-3` / `caps-e` / `caps-d` / `caps-c` / `caps-m` | 3 / E / D / C / M |

### Move Window to Workspace + Follow
| Hotkey | Workspace |
|--------|-----------|
| `alt-shift-1/q/a` | 1 / Q / A |
| `alt-shift-2/w/s` | 2 / W / S |
| `alt-shift-3/e/d/c/m` | 3 / E / D / C / M |

> **Missing:** `alt-shift-z` and `alt-shift-x` (can't move windows to Z or X)

### Workspace Cycling
| Hotkey | Action |
|--------|--------|
| `alt-ctrl-p` | Cycle to next workspace on current monitor |
| `alt-ctrl-o` | Cycle to previous workspace on current monitor |

### Display Brightness (BetterDisplay)
| Hotkey | Action |
|--------|--------|
| `alt-keypad +` | HP + Samsung brightness to 100% |
| `alt-keypad -` / `alt-keypad 0` | HP + Samsung brightness to 0% |

---

## Service Mode (caps-esc to enter, esc to exit)

Cheat sheet shows on the left bar. Keys stay in service mode until `esc`.

| Key | Action |
|-----|--------|
| `esc` | Exit + reload config + reload SketchyBar |
| `r` | Flatten workspace tree (reset layout) |
| `f` | Toggle floating/tiling (current window) |
| `d` | Toggle default float/tile for focused app (modifies aerospace.toml) |
| `c` | Close empty windows |
| `caps-f` | Toggle fullscreen |
| `h/j/k/l` | Join with left/down/up/right |
| `←/↓/↑/→` | Join with left/down/up/right |
| `caps-esc` | Exit service mode (alt exit) |
| All other keys | Disabled (no passthrough) |

---

## App Mode (caps-backtick to enter, esc to exit)

Quick-launch apps. Auto-exits after selection.

| Key | App |
|-----|-----|
| `esc` | Exit app mode |
| `m` | Mail |
| `z` | Zotero |
| `w` | WeChat |
| `b` | BetterTouchTool |
| `e` | Microsoft Edge |
| `q` | Weather |
| `caps-backtick` | Exit app mode (toggle) |

---

## Suggestions for New Hotkeys

### Service Mode
| Key | Suggested Action | Reason |
|-----|-----------------|--------|
| `t` | Toggle accordion/tiles | Quick layout switch |
| `e` | `balance-sizes` | Equalize windows after manual resize |
| `m` | Move window to next monitor (cycle) | No current way to send to another monitor |
| `+`/`-` | Resize ±50 | Resize without leaving service mode |
| `s` | Toggle split direction | Change horizontal/vertical split |
| `w` | Close focused window | Quick close |
| `g` | Toggle gaps (0 ↔ normal) | Distraction-free mode |

### Main Mode
| Hotkey | Suggested Action | Reason |
|--------|-----------------|--------|
| `caps-tab` | `workspace-back-and-forth` | Quick toggle last 2 workspaces (currently commented out) |
| `alt-shift-z` | Move window to Z + follow | Missing from move bindings |
| `alt-shift-x` | Move window to X + follow | Missing from move bindings |
| `caps-n` | Move workspace to next monitor | Rearrange workspace placement |

### App Mode
| Key | Suggested Action | Reason |
|-----|-----------------|--------|
| `t` | Terminal/iTerm2 | Quick terminal access |
| `f` | Finder | Quick Finder window |
| `c` | Cursor/VS Code | Quick editor access |
| `s` | System Settings | Quick settings |
