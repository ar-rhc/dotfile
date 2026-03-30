local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = { string = "󰖩", color = 0xff58d1fc },
  update_freq = 30,
  updates = "on",
})

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; /Users/alex/.config/sketchybar/plugins/wifi.sh'")
end)
