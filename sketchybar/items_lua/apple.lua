local colors = require("colors")
local icons = require("icons")

local apple = sbar.add("item", "apple.logo", {
  icon = {
    string = icons.apple,
    font = { family = "SF Pro", style = "Black", size = 16.0 },
    color = colors.white,
  },
  label = { drawing = false },
  padding_right = 5,
  popup = { height = 35, background = { border_width = 0 } },
})

local function popup_off()
  apple:set({ popup = { drawing = false } })
end

apple:subscribe("mouse.entered", function()
  sbar.exec("sketchybar --trigger close_popups OPENER=apple")
  apple:set({ popup = { drawing = true } })
end)
apple:subscribe("close_popups", function(env)
  if env.OPENER ~= "apple" then popup_off() end
end)
apple:subscribe("mouse.exited.global", function() popup_off() end)
apple:subscribe("mouse.clicked", function()
  sbar.exec("sketchybar --trigger close_popups OPENER=apple")
  apple:set({ popup = { drawing = "toggle" } })
end)

-- Popup items
sbar.add("item", "apple.prefs", {
  position = "popup.apple.logo",
  icon = { string = icons.preferences },
  label = { string = "Preferences" },
  click_script = "open -a 'System Preferences'; sketchybar --set apple.logo popup.drawing=off",
})

sbar.add("item", "apple.activity", {
  position = "popup.apple.logo",
  icon = { string = icons.activity },
  label = { string = "Activity" },
  click_script = "open -a 'Activity Monitor'; sketchybar --set apple.logo popup.drawing=off",
})

sbar.add("item", "apple.aero_apps", {
  position = "popup.apple.logo",
  icon = { string = "􀫵" },
  label = { string = "Apps List", max_chars = 180 },
  click_script = "/Users/alex/.config/sketchybar/plugins/aerospace/aerospace_apps.sh",
})

sbar.add("item", "apple.aero_windows", {
  position = "popup.apple.logo",
  icon = { string = "􀏜" },
  label = { string = "Windows List", max_chars = 180 },
  click_script = "/Users/alex/.config/sketchybar/plugins/aerospace/aerospace_windows.sh",
})

sbar.add("item", "apple.lock", {
  position = "popup.apple.logo",
  icon = { string = icons.lock },
  label = { string = "Lock Screen" },
  click_script = "pmset displaysleepnow; sketchybar --set apple.logo popup.drawing=off",
})
