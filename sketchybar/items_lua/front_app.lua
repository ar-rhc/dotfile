local icon_map = require("icon_map")

local front_app = sbar.add("item", "front_app", {
  icon = {
    font = { family = "sketchybar-app-font", style = "Regular", size = 16.0 },
    drawing = true,
  },
  label = {
    font = { family = "SF Pro", style = "Black", size = 13.0 },
  },
  display = "active",
  click_script = "open -a 'Mission Control'",
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = { string = env.INFO },
    icon = { string = icon_map.get(env.INFO) },
  })
end)
