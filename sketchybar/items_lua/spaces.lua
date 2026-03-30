local colors = require("colors")
local settings = require("settings")

-- Register aerospace event
sbar.add("event", "aerospace_workspace_change")

-- Note: space.* items are created by spaces_init.sh called from init.lua
-- AFTER sbar.end_config() to ensure correct ordering.

-- Space creator item handles workspace change events
local space_creator = sbar.add("item", "space_creator", {
  icon = {
    string = "􀆊",
    font = { family = settings.font.text, style = "Heavy", size = 16.0 },
    color = colors.white,
  },
  label = { drawing = false },
  padding_left = 5,
  padding_right = 5,
  display = "active",
})

space_creator:subscribe({ "aerospace_workspace_change", "display_change" }, function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; /Users/alex/.config/sketchybar/plugins/space_windows.sh'")
end)
