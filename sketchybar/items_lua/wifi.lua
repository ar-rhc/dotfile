local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = { string = "󰖩", color = 0xff58d1fc },
  padding_left = 3,
  padding_right = 3,
  update_freq = 30,
  updates = "on",
})

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, function(env)
  sbar.exec("pmset -g batt 2>/dev/null | grep -q Battery && echo laptop || echo desktop", function(result)
    result = result:gsub("%s+", "")
    if result == "desktop" then
      wifi:set({ drawing = false })
      return
    end
    sbar.exec("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk -F: '($1 ~ \"^ *SSID$\"){print $2}' | cut -c 2-", function(ssid)
      ssid = ssid:gsub("^%s+", ""):gsub("%s+$", "")
      if ssid == "" then
        wifi:set({ icon = { string = "󰖪" }, label = { string = "No WiFi" } })
      else
        wifi:set({ icon = { string = "󰖩" }, label = { string = ssid } })
      end
    end)
  end)
end)
