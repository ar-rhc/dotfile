sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("default")
require("items_lua")
sbar.end_config()

-- Start the helper process (pass color env vars for CPU)
sbar.exec("killall helper 2>/dev/null; (cd $CONFIG_DIR/helper && make) && RED=0xffff5555 ORANGE=0xffffb86c YELLOW=0xfff1fa8c LABEL_COLOR=0xffffffff $CONFIG_DIR/helper/helper git.felix.helper > /dev/null 2>&1 &")

-- Unload macOS volume OSD
sbar.exec("launchctl unload -F /System/Library/LaunchAgents/com.apple.OSDUIHelper.plist > /dev/null 2>&1 &")

-- Force initial update
sbar.exec("sketchybar --update")

-- Run the event loop (required for callbacks)
sbar.event_loop()
