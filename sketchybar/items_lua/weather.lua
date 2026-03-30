local weather = sbar.add("item", "weather", {
  position = "right",
  display = 2,
  icon = {
    string = "󰖐",
    font = { family = "Hack Nerd Font", style = "Regular", size = 13.0 },
  },
  update_freq = 1800,
  updates = "on",
  click_script = "/Users/alex/.config/sketchybar/plugins/scripts/weather_click.sh",
})

weather:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; /Users/alex/.config/sketchybar/plugins/weather.sh'")
end)
