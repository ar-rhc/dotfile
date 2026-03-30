local weather = sbar.add("item", "weather", {
  position = "right",
  display = 2,
  icon = {
    string = "󰖐",
    font = { family = "Hack Nerd Font", style = "Regular", size = 13.0 },
  },
  padding_left = 3,
  padding_right = 3,
  update_freq = 1800,
  updates = "on",
  click_script = "/Users/alex/.config/sketchybar/plugins/scripts/weather_click.sh",
})

local function update_weather()
  sbar.exec("NAME=weather CONFIG_DIR=/Users/alex/.config/sketchybar /Users/alex/.config/sketchybar/plugins/weather.sh")
end

weather:subscribe({ "routine", "forced" }, function(env)
  update_weather()
end)

-- Force initial update
update_weather()
