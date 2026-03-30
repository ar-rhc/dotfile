local weather = sbar.add("item", "weather", {
  position = "right",
  display = 2,
  icon = {
    string = "󰖐",
    font = { family = "Hack Nerd Font", style = "Regular", size = 13.0 },
  },
  update_freq = 1800,
  click_script = "$CONFIG_DIR/plugins/scripts/weather_click.sh",
})

weather:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/weather.sh")
end)

weather:subscribe("mouse.clicked", function(env)
  sbar.exec("$CONFIG_DIR/plugins/scripts/weather_click.sh")
end)
