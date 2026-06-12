#!/bin/bash
osascript -e '
tell application "System Events"
    set frontApp to first application process whose frontmost is true
    set frontWindow to first window of frontApp
    set {w, h} to size of frontWindow
    tell application "Finder"
        set screenBounds to bounds of window of desktop
        set screenW to item 3 of screenBounds
        set screenH to item 4 of screenBounds
    end tell
    set position of frontWindow to {(screenW - w) / 2, (screenH - h) / 2}
end tell
'
