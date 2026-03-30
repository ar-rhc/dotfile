local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = { string = "󰖩", color = 0xff58d1fc },
  update_freq = 30,
})

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/wifi.sh")
end)
