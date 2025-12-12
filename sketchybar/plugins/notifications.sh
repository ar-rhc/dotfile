#!/usr/bin/env bash

# Set CONFIG_DIR if not already set
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

# Source required files
source "$CONFIG_DIR/colors.sh" 2>/dev/null || true
source "$CONFIG_DIR/icons.sh" 2>/dev/null || true

# Font - hardcode since FONT is not exported from sketchybarrc
FONT="SF Pro"

# Color fallbacks if not sourced
ICON_COLOR="${ICON_COLOR:-0xffffffff}"
RED="${RED:-0xffff5555}"
BACKGROUND_1="${BACKGROUND_1:-0x901a1a1a}"

# Get badge count using lsappinfo (doesn't require accessibility permissions)
check_app_badge() {
    local app_name="$1"
    local bundle_id=""
    
    case "$app_name" in
        "Mail") bundle_id="com.apple.mail" ;;
        "Messages") bundle_id="com.apple.MobileSMS" ;;
        *) return ;;
    esac
    
    # Try lsappinfo method first
    local badge=$(lsappinfo info -only StatusLabel "$bundle_id" 2>/dev/null | grep -o '"label"="[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$badge" ] && [ "$badge" != " " ]; then
        echo "$badge"
    else
        # Fallback to AppleScript (works if called from terminal with accessibility)
        osascript <<APPLESCRIPT 2>/dev/null
tell application "System Events"
    tell process "Dock"
        try
            set badgeValue to value of attribute "AXStatusLabel" of UI element "$app_name" of list 1
            if badgeValue is missing value then
                return "0"
            else
                return badgeValue as string
            end if
        on error
            return "0"
        end try
    end tell
end tell
APPLESCRIPT
    fi
}

# Check Mail app
MAIL_BADGE=$(check_app_badge "Mail")

if [ -n "$MAIL_BADGE" ] && [ "$MAIL_BADGE" != "0" ] && [ "$MAIL_BADGE" != "missing value" ]; then
    MAIL_ICON=$($CONFIG_DIR/plugins/icon_map.sh "Mail")
    # Set all properties
    sketchybar --set notif.mail \
        icon="$MAIL_ICON" \
        icon.font="sketchybar-app-font:Regular:16.0" \
        icon.color="$ICON_COLOR" \
        label="$MAIL_BADGE" \
        label.color="$ICON_COLOR" \
        label.font="$FONT:Bold:14.0" \
        label.padding_right=10 \
        background.color=0x80494949 \
        background.corner_radius=9 \
        background.height=26 \
        icon.padding_left=6 \
        icon.padding_right=2 \
        icon.padding_left=10 \
        padding_left=0 \
        padding_right=6 \
        click_script="open -a 'Mail'"
    # Set drawing separately (workaround for sketchybar quirk)
    sketchybar --set notif.mail drawing=on
else
    sketchybar --set notif.mail drawing=off
fi

# Check Messages app
MESSAGES_BADGE=$(check_app_badge "Messages")
if [ -n "$MESSAGES_BADGE" ] && [ "$MESSAGES_BADGE" != "0" ] && [ "$MESSAGES_BADGE" != "missing value" ]; then
    MESSAGES_ICON=$($CONFIG_DIR/plugins/icon_map.sh "Messages")
    # Set all properties
    sketchybar --set notif.messages \
        icon="$MESSAGES_ICON" \
        icon.font="sketchybar-app-font:Regular:16.0" \
        icon.color="$ICON_COLOR" \
        label="$MESSAGES_BADGE" \
        label.color="$ICON_COLOR" \
        label.font="$FONT:Bold:14.0" \
        label.padding_right=6 \
        background.color=0x90494949 \
        background.corner_radius=9 \
        background.height=26 \
        icon.padding_left=6 \
        icon.padding_right=2 \
        padding_left=0 \
        padding_right=6 \
        click_script="open -a 'Messages'"
    # Set drawing separately (workaround for sketchybar bug)
    sketchybar --set notif.messages drawing=on
else
    sketchybar --set notif.messages drawing=off
fi
