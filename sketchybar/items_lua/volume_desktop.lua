local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local volume = sbar.add("item", "volume_desktop", {
  position = "right",
  display = require("displays").lg,
  icon = {
    string = icons.volume._100,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
    padding_left = 2,
    padding_right = 2,
  },
  label = { drawing = false },
  padding_left = 0,
  padding_right = 3,
  update_freq = 5,
  updates = "on",
  click_script = "betterdisplaycli toggle -n=LG --mute",
})

local slider = sbar.add("slider", "volume_desktop_slider", 0, {
  position = "right",
  icon = { drawing = false },
  label = { drawing = false },
  slider = {
    highlight_color = colors.blue,
    background = { height = 5, corner_radius = 3, color = colors.bg2 },
    knob = "􀀁",
  },
  width = 0,
  padding_left = 0,
  padding_right = 0,
})

-- Update icon based on volume
local function update_icon()
  sbar.exec("betterdisplaycli get -n=LG --mute", function(mute)
    mute = mute:gsub("%s+", "")
    if mute == "on" then
      volume:set({ icon = { string = icons.volume._0 } })
      return
    end
    sbar.exec("betterdisplaycli get -n=LG --volume", function(vol)
      vol = vol:gsub("%s+", "")
      local pct = math.floor((tonumber(vol) or 0) * 100)
      local icon
      if pct <= 0 then icon = icons.volume._0
      elseif pct <= 15 then icon = icons.volume._10
      elseif pct <= 40 then icon = icons.volume._33
      elseif pct <= 65 then icon = icons.volume._66
      else icon = icons.volume._100 end
      volume:set({ icon = { string = icon } })
    end)
  end)
end

-- Use generation counters to invalidate pending delays (sbar.delay is not cancellable)
local hover_gen = 0
local hide_gen = 0
local timeout_gen = 0
local slider_visible = false

local function hide_slider()
  hide_gen = hide_gen + 1
  slider_visible = false
  sbar.animate("tanh", 30, function()
    slider:set({ width = 0, slider = { width = 0 } })
  end)
end

local function reset_hide_timeout()
  timeout_gen = timeout_gen + 1
  local gen = timeout_gen
  sbar.delay(30, function()
    if gen == timeout_gen then hide_slider() end
  end)
end

-- Hover: show slider after 1s delay
volume:subscribe("mouse.entered", function(env)
  update_icon()
  hover_gen = hover_gen + 1
  local gen = hover_gen
  sbar.delay(1, function()
    if gen ~= hover_gen then return end
    sbar.exec("betterdisplaycli get -n=LG --volume", function(vol)
      vol = vol:gsub("%s+", "")
      local pct = math.floor((tonumber(vol) or 0) * 100)
      slider_visible = true
      slider:set({ width = "dynamic", slider = { percentage = pct, width = 100 } })
      reset_hide_timeout()
    end)
  end)
end)

volume:subscribe("mouse.exited.global", function(env)
  hover_gen = hover_gen + 1
  hide_slider()
end)

slider:subscribe("mouse.entered", function()
  if not slider_visible then return end
  hover_gen = hover_gen + 1
  hide_gen = hide_gen + 1
  reset_hide_timeout()
end)

slider:subscribe("mouse.exited.global", function()
  hide_slider()
end)

-- Slider drag: set volume
slider:subscribe("mouse.clicked", function(env)
  local pct = env.PERCENTAGE or 50
  local vol = pct / 100.0
  sbar.exec("betterdisplaycli set -n=LG --volume=" .. vol)
  update_icon()
end)

-- Click: update icon after mute toggle
volume:subscribe("mouse.clicked", function()
  sbar.delay(0.3, function() update_icon() end)
end)

-- Periodic + wake update
volume:subscribe({ "routine", "system_woke" }, function()
  update_icon()
end)
