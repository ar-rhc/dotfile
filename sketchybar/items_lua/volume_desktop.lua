local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local volume = sbar.add("item", "volume_desktop", {
  position = "right",
  icon = {
    string = icons.volume._100,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
  },
  label = { drawing = false },
  padding_left = 3,
  padding_right = 3,
  update_freq = 5,
  updates = "on",
  click_script = "/Users/alex/.config/sketchybar/plugins/volume_desktop_click.sh",
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

-- Hover: show slider after 0.5s delay
local hover_timer = nil
volume:subscribe("mouse.entered", function(env)
  hover_timer = sbar.delay(0.5, function()
    sbar.exec("betterdisplaycli get -n=LG --volume", function(vol)
      vol = vol:gsub("%s+", "")
      local pct = math.floor((tonumber(vol) or 0) * 100)
      slider:set({ width = "dynamic", slider = { percentage = pct, width = 100 } })
    end)
  end)
end)

volume:subscribe("mouse.exited.global", function(env)
  sbar.animate("tanh", 30, function()
    slider:set({ width = 0, slider = { width = 0 } })
  end)
end)

slider:subscribe("mouse.entered", function()
  slider:set({ width = "dynamic", slider = { width = 100 } })
end)

slider:subscribe("mouse.exited.global", function()
  sbar.animate("tanh", 30, function()
    slider:set({ width = 0, slider = { width = 0 } })
  end)
end)

-- Slider drag: set volume
slider:subscribe("mouse.clicked", function(env)
  local pct = env.PERCENTAGE or 50
  local vol = pct / 100.0
  sbar.exec("betterdisplaycli set -n=LG --volume=" .. vol)
  update_icon()
end)

-- Periodic update
volume:subscribe({ "routine", "forced", "volume_change", "system_woke" }, function()
  update_icon()
end)
