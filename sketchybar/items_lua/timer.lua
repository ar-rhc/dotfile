local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Pomodoro state (in-memory, no temp files)
local pomo = {
  mode = "idle",          -- idle | pomodoro | timer | stopwatch
  phase = "work",         -- work | short_break | long_break
  remaining = 25 * 60,
  session = 0,
  total = 0,
  paused = false,
  sw_start = 0,

  work = 25 * 60,
  short_break = 5 * 60,
  long_break = 15 * 60,
  cycle = 4,
}

local timer

local function format_time(sec)
  sec = math.max(0, math.floor(sec))
  if sec >= 3600 then
    return string.format("%02d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
  end
  return string.format("%02d:%02d", sec // 60, sec % 60)
end

local function notify(title, msg)
  sbar.exec("osascript -e 'display notification \"" .. msg .. "\" with title \"" .. title .. "\" sound name \"Funk\"'")
  sbar.exec("afplay /System/Library/Sounds/Funk.aiff")
end

local function update_sessions()
  local label = ""
  if pomo.mode == "pomodoro" then
    label = "🍅 " .. (pomo.session % pomo.cycle) .. "/" .. pomo.cycle .. "  (Total: " .. pomo.total .. ")"
  elseif pomo.mode == "idle" then
    label = "🍅 Ready  (Total: " .. pomo.total .. ")"
  end
  sbar.exec("sketchybar --set timer.sessions label='" .. label .. "'")
end

local function update_display()
  if pomo.mode == "idle" then
    timer:set({ icon = { string = icons.timer.idle, color = colors.grey }, label = { string = "" } })
    return
  end
  if pomo.mode == "stopwatch" then
    local elapsed = pomo.paused and pomo.remaining or (os.time() - pomo.sw_start)
    timer:set({
      icon = { string = icons.timer.stopwatch, color = colors.white },
      label = { string = format_time(elapsed), color = colors.white },
    })
    return
  end
  if pomo.mode == "timer" then
    local color = pomo.remaining < 60 and colors.red or colors.white
    timer:set({
      icon = { string = icons.timer.countdown, color = colors.white },
      label = { string = format_time(pomo.remaining), color = color },
    })
    return
  end
  -- Pomodoro
  local prefix, icon, color
  if pomo.phase == "work" then prefix, icon, color = "W", icons.timer.work, colors.orange
  elseif pomo.phase == "short_break" then prefix, icon, color = "B", icons.timer.short_break, colors.green
  else prefix, icon, color = "LB", icons.timer.long_break, colors.blue end
  local label = prefix .. " " .. format_time(pomo.remaining) .. " 🍅" .. pomo.total
  if pomo.paused then label = label .. " ⏸" end
  timer:set({ icon = { string = icon, color = color }, label = { string = label, color = color } })
end

local function transition_phase()
  if pomo.phase == "work" then
    pomo.session = pomo.session + 1
    pomo.total = pomo.total + 1
    if pomo.session % pomo.cycle == 0 then
      pomo.phase = "long_break"
      pomo.remaining = pomo.long_break
      notify("Pomodoro", "Great work! Long break time.")
    else
      pomo.phase = "short_break"
      pomo.remaining = pomo.short_break
      notify("Pomodoro", "Take a short break! (" .. (pomo.session % pomo.cycle) .. "/" .. pomo.cycle .. ")")
    end
  else
    pomo.phase = "work"
    pomo.remaining = pomo.work
    notify("Pomodoro", "Break over — time to focus!")
  end
end

-- Create timer item
timer = sbar.add("item", "timer", {
  icon = { string = icons.timer.idle, color = colors.grey },
  updates = "on",
  update_freq = 1,
  popup = { height = 35, background = { border_width = 0 } },
})

-- Tick every second
timer:subscribe("routine", function()
  if pomo.mode == "idle" then update_display(); return end
  if pomo.mode == "stopwatch" then update_display(); return end
  if not pomo.paused then
    pomo.remaining = pomo.remaining - 1
    if pomo.remaining <= 0 then
      if pomo.mode == "timer" then
        notify("Timer", "Your timer has finished.")
        pomo.mode = "idle"
        pomo.remaining = pomo.work
      elseif pomo.mode == "pomodoro" then
        transition_phase()
      end
      update_sessions()
    end
  end
  update_display()
end)

-- Hover popup
timer:subscribe("mouse.entered", function() timer:set({ popup = { drawing = true } }) end)
timer:subscribe("mouse.exited.global", function() timer:set({ popup = { drawing = false } }) end)

-- Click: toggle
timer:subscribe("mouse.clicked", function()
  if pomo.mode == "idle" then
    pomo.mode = "pomodoro"; pomo.phase = "work"; pomo.remaining = pomo.work; pomo.paused = false
    notify("Pomodoro", "Focus time!")
  elseif pomo.mode == "pomodoro" or pomo.mode == "timer" then
    pomo.paused = not pomo.paused
  elseif pomo.mode == "stopwatch" then
    if pomo.paused then pomo.sw_start = os.time() - pomo.remaining; pomo.paused = false
    else pomo.remaining = os.time() - pomo.sw_start; pomo.paused = true end
  end
  update_display(); update_sessions()
end)

-- Shared popup item style
local popup_label = { font = { family = settings.font.text, style = "Regular", size = 12.0 } }
local popup_icon = { font = { family = settings.font.text, style = "Regular", size = 14.0 } }

-- Popup items + custom events for popup click handling
sbar.add("event", "pomo_skip")
sbar.add("event", "pomo_reset")
sbar.add("event", "pomo_stopwatch")

sbar.add("item", "timer.pomo_toggle", { position = "popup.timer", icon = { string = "􀊄", font = popup_icon.font }, label = { string = "Start/Pause", font = popup_label.font },
  click_script = "sketchybar --set timer popup.drawing=off" })
sbar.add("item", "timer.pomo_skip", { position = "popup.timer", icon = { string = "􀊐", font = popup_icon.font }, label = { string = "Skip", font = popup_label.font },
  click_script = "sketchybar --set timer popup.drawing=off; sketchybar --trigger pomo_skip" })
sbar.add("item", "timer.pomo_reset", { position = "popup.timer", icon = { string = "􀛶", font = popup_icon.font }, label = { string = "Reset", font = popup_label.font },
  click_script = "sketchybar --set timer popup.drawing=off; sketchybar --trigger pomo_reset" })
sbar.add("item", "timer.sessions", { position = "popup.timer", icon = { drawing = false }, label = { string = "🍅 Ready", font = popup_label.font } })

timer:subscribe("pomo_skip", function()
  if pomo.mode == "pomodoro" then transition_phase() end
  update_display(); update_sessions()
end)

timer:subscribe("pomo_reset", function()
  pomo.mode = "idle"; pomo.phase = "work"; pomo.remaining = pomo.work; pomo.paused = false
  update_display(); update_sessions()
end)

-- Timer presets via events
local presets = { { "3min", 180 }, { "5min", 300 }, { "egg", 390 }, { "10min", 600 }, { "20min", 1200 }, { "1hr", 3600 } }
local preset_labels = { "3 min", "5 min", "6.5 min 🥚", "10 min", "20 min", "1 hour" }
for i, p in ipairs(presets) do
  sbar.add("event", "timer_" .. p[1])
  sbar.add("item", "timer.preset" .. i, { position = "popup.timer", label = { string = preset_labels[i], font = popup_label.font },
    click_script = "sketchybar --set timer popup.drawing=off; sketchybar --trigger timer_" .. p[1] })
  timer:subscribe("timer_" .. p[1], function()
    pomo.mode = "timer"; pomo.remaining = p[2]; pomo.paused = false
    update_display(); update_sessions()
  end)
end

-- Custom timer
sbar.add("event", "timer_custom")
sbar.add("item", "timer.custom", { position = "popup.timer", label = { string = "Custom…", font = popup_label.font },
  click_script = [[sketchybar --set timer popup.drawing=off; mins=$(osascript -e 'text returned of (display dialog "Enter minutes:" default answer "15")' 2>/dev/null) && [ -n "$mins" ] && sketchybar --trigger timer_custom SECONDS=$(($mins * 60))]] })
timer:subscribe("timer_custom", function(env)
  pomo.mode = "timer"; pomo.remaining = tonumber(env.SECONDS) or 900; pomo.paused = false
  update_display(); update_sessions()
end)

-- Stopwatch
sbar.add("item", "timer.stopwatch", { position = "popup.timer", icon = { string = icons.timer.stopwatch, font = popup_icon.font }, label = { string = "Stopwatch", font = popup_label.font },
  click_script = "sketchybar --set timer popup.drawing=off; sketchybar --trigger pomo_stopwatch" })
timer:subscribe("pomo_stopwatch", function()
  pomo.mode = "stopwatch"; pomo.sw_start = os.time(); pomo.remaining = 0; pomo.paused = false
  update_display(); update_sessions()
end)
