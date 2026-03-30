sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("default")
require("items_lua")
sbar.end_config()

-- Create space items AFTER config (shell script adds them via CLI)
-- This ensures they appear in the correct position (after apple, menu_trigger)
local config_dir = os.getenv("CONFIG_DIR") or os.getenv("HOME") .. "/.config/sketchybar"
os.execute(config_dir .. "/plugins/spaces_init.sh")

-- Start the helper process
sbar.exec("killall helper 2>/dev/null; (cd $CONFIG_DIR/helper && make) && $CONFIG_DIR/helper/helper git.felix.helper > /dev/null 2>&1 &")

-- Unload macOS volume OSD
sbar.exec("launchctl unload -F /System/Library/LaunchAgents/com.apple.OSDUIHelper.plist > /dev/null 2>&1 &")

-- Force initial update
sbar.exec("sketchybar --update")

-- Run the event loop (required for callbacks)
sbar.event_loop()
