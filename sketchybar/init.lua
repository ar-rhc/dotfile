sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("default")
require("items_lua")
sbar.end_config()

-- Start the helper process
sbar.exec("killall helper 2>/dev/null; (cd $CONFIG_DIR/helper && make) && $CONFIG_DIR/helper/helper git.felix.helper > /dev/null 2>&1 &")

-- Unload macOS volume OSD
sbar.exec("launchctl unload -F /System/Library/LaunchAgents/com.apple.OSDUIHelper.plist > /dev/null 2>&1 &")

-- Force initial update
sbar.exec("sketchybar --update")

-- Run the event loop (required for callbacks)
sbar.event_loop()
