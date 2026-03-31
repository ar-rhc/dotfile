local colors = require("colors")
local settings = require("settings")

-- CPU graph uses the C helper (helper/helper.c + cpu.h)
-- The helper responds to cpu.percent events and pushes graph data

-- CPU percentage + top process label
local cpu_percent = sbar.add("graph", "cpu.percent", 75, {
  position = "right",
  graph = {
    color = colors.blue,
    fill_color = colors.with_alpha(colors.blue, 0.3),
  },
  icon = { string = "CPU", font = { family = settings.font.text, style = "Bold", size = 10.0 }, color = colors.grey },
  label = {
    string = "0%",
    font = { family = settings.font.numbers, style = "Regular", size = 10.0 },
    color = colors.white,
    align = "right",
    width = 40,
  },
  background = {
    color = colors.with_alpha(colors.bg1, 0.7),
    border_color = colors.bg2,
    border_width = 1,
    corner_radius = 9,
    height = 26,
  },
  padding_left = 3,
  padding_right = 3,
  update_freq = 4,
  updates = "on",
  mach_helper = "git.felix.helper",
})

-- Top process label (shown below/beside the graph)
local cpu_top = sbar.add("item", "cpu.top", {
  position = "right",
  icon = { drawing = false },
  label = {
    font = { family = settings.font.text, style = "Regular", size = 9.0 },
    color = colors.grey,
    max_chars = 20,
  },
  width = 0,
  padding_left = 0,
  padding_right = 0,
  y_offset = -6,
})

-- The C helper handles all the heavy lifting:
-- - Reads CPU via Mach API (no polling overhead)
-- - Pushes graph data points
-- - Sets cpu.percent label with color-coded percentage
-- - Sets cpu.top label with top process name
-- The helper is already started in init.lua

-- Connect to the C helper via mach_helper
sbar.exec("sketchybar --set cpu.percent mach_helper=git.felix.helper")

-- Subscribe to trigger the helper
cpu_percent:subscribe("routine", function() end)

-- Click to open Activity Monitor
cpu_percent:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Bracket: group RAM + CPU
sbar.add("bracket", "system_stats", { "ram", "cpu.percent" }, {
  background = {
    color = colors.with_alpha(colors.bg1, 0.5),
    border_color = colors.bg2,
    border_width = 2,
    corner_radius = 11,
    height = 30,
  },
})

-- Bracket: calendar + next event
sbar.add("bracket", "time_events", { "calendar", "next_event" }, {
  background = {
    color = colors.with_alpha(colors.bg1, 0.5),
    border_color = colors.bg2,
    border_width = 2,
    corner_radius = 11,
    height = 30,
  },
})

-- Bracket: volume + input source
sbar.add("bracket", "audio_input", { "volume_desktop", "input_source" }, {
  background = {
    color = colors.with_alpha(colors.bg1, 0.5),
    border_color = colors.bg2,
    border_width = 2,
    corner_radius = 11,
    height = 30,
  },
})
