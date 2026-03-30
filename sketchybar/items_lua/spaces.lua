local colors = require("colors")
local settings = require("settings")

-- Register aerospace event
sbar.add("event", "aerospace_workspace_change")

-- Space items are created by a shell script at init time because
-- AeroSpace queries (list-workspaces, list-windows) require shell execution.
-- The shell script creates space.* items, then Lua handles events via space_creator.

-- Execute the space creation shell script synchronously at config time
local config_dir = os.getenv("CONFIG_DIR") or os.getenv("HOME") .. "/.config/sketchybar"
os.execute(config_dir .. "/plugins/spaces_init.sh")

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

-- Workspace change handler — delegates to shell for AeroSpace queries
space_creator:subscribe({ "aerospace_workspace_change", "display_change" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/space_windows.sh", function() end)
end)
