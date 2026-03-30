#!/bin/bash

# Get the monitor number where the mouse cursor is
# Returns: monitor number (1, 2, 3, etc.) or "active" if detection fails

# Use Python to get mouse position and screen information
monitor=$(python3 << 'PYTHON'
import Quartz
from AppKit import NSScreen
import sys

try:
    # Get mouse position
    point = Quartz.CGEventGetLocation(Quartz.CGEventCreate(None))
    mouse_x = int(point.x)
    mouse_y = int(point.y)
    
    # Get all screens
    screens = NSScreen.screens()
    
    # Find which screen contains the mouse
    found_screen = None
    for i, screen in enumerate(screens, 1):
        frame = screen.frame()
        x1 = int(frame.origin.x)
        y1 = int(frame.origin.y)
        x2 = int(frame.origin.x + frame.size.width)
        y2 = int(frame.origin.y + frame.size.height)
        
        # Check if mouse is within this screen's bounds
        if x1 <= mouse_x < x2 and y1 <= mouse_y < y2:
            found_screen = i
            break
    
    if found_screen:
        print(found_screen)
    else:
        # Fallback: find closest screen by distance to center
        min_dist = float('inf')
        closest = 1
        for i, screen in enumerate(screens, 1):
            frame = screen.frame()
            center_x = frame.origin.x + frame.size.width / 2
            center_y = frame.origin.y + frame.size.height / 2
            dist = ((mouse_x - center_x)**2 + (mouse_y - center_y)**2)**0.5
            if dist < min_dist:
                min_dist = dist
                closest = i
        print(closest)
except Exception:
    # On any error, return active
    print("active")
PYTHON
)

echo "$monitor"
