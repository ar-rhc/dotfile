local colors = require("colors")

local bracket_style = {
  background = {
    color = colors.with_alpha(colors.bg1, 0.5),
    border_color = colors.bg2,
    border_width = 2,
    corner_radius = 11,
    height = 30,
  },
}

-- Group: Calendar + Next Event
sbar.add("bracket", "group.time", { "calendar", "next_event" }, bracket_style)

-- Group: Volume + Input Source
sbar.add("bracket", "group.audio", { "volume_desktop", "input_source" }, bracket_style)

-- Group: RAM (+ CPU when enabled)
sbar.add("bracket", "group.system", { "ram" }, bracket_style)

-- Group: WiFi + Weather
sbar.add("bracket", "group.info", { "wifi", "weather" }, bracket_style)
