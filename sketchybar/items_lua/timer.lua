local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local POMODORO = "python3 /Users/alex/.config/sketchybar/plugins/pomodoro.py"

local timer = sbar.add("item", "timer", {
  icon = { string = icons.timer.idle, color = colors.grey },
  updates = "on",
  update_freq = 1,
  click_script = POMODORO .. " toggle",
  popup = { height = 35, background = { border_width = 0 } },
})

-- Tick every second
timer:subscribe("routine", function(env)
  sbar.exec(POMODORO .. " tick")
end)

-- Hover popup
timer:subscribe("mouse.entered", function()
  timer:set({ popup = { drawing = true } })
end)

timer:subscribe("mouse.exited.global", function()
  timer:set({ popup = { drawing = false } })
end)

-- Pomodoro controls
sbar.add("item", "timer.pomo_toggle", {
  position = "popup.timer",
  icon = { string = "􀊄" },
  label = { string = "Start" },
  click_script = "sketchybar --set timer popup.drawing=off; " .. POMODORO .. " toggle",
})

sbar.add("item", "timer.pomo_skip", {
  position = "popup.timer",
  icon = { string = "􀊐" },
  label = { string = "Skip" },
  click_script = "sketchybar --set timer popup.drawing=off; " .. POMODORO .. " skip",
})

sbar.add("item", "timer.pomo_reset", {
  position = "popup.timer",
  icon = { string = "􀛶" },
  label = { string = "Reset" },
  click_script = "sketchybar --set timer popup.drawing=off; " .. POMODORO .. " reset",
})

sbar.add("item", "timer.sessions", {
  position = "popup.timer",
  icon = { drawing = false },
  label = { string = "🍅 Ready" },
})

-- Timer presets
local presets = {
  { name = "preset1", label = "3 min",  secs = 180 },
  { name = "preset2", label = "5 min",  secs = 300 },
  { name = "preset3", label = "10 min", secs = 600 },
  { name = "preset4", label = "20 min", secs = 1200 },
  { name = "preset5", label = "1 hour", secs = 3600 },
}

for _, p in ipairs(presets) do
  sbar.add("item", "timer." .. p.name, {
    position = "popup.timer",
    label = { string = p.label },
    click_script = "sketchybar --set timer popup.drawing=off; " .. POMODORO .. " timer " .. p.secs,
  })
end

-- Custom timer
sbar.add("item", "timer.custom", {
  position = "popup.timer",
  label = { string = "Custom…" },
  click_script = [[sketchybar --set timer popup.drawing=off; mins=$(osascript -e 'text returned of (display dialog "Enter minutes:" default answer "15")' 2>/dev/null) && [ -n "$mins" ] && python3 /Users/alex/.config/sketchybar/plugins/pomodoro.py timer $(($mins * 60))]],
})

-- Stopwatch
sbar.add("item", "timer.stopwatch", {
  position = "popup.timer",
  icon = { string = icons.timer.stopwatch },
  label = { string = "Stopwatch" },
  click_script = "sketchybar --set timer popup.drawing=off; " .. POMODORO .. " stopwatch",
})
