local colors = require("colors")

local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = { string = "󰖩", color = 0xff58d1fc },
  padding_left = 3,
  padding_right = 3,
  update_freq = 30,
  updates = "on",
  popup = { height = 30, background = { border_width = 0 } },
})

-- Popup items
local popup_width = 220

local popup_ssid = sbar.add("item", "wifi.ssid", {
  position = "popup.wifi",
  icon = { string = "SSID:", width = popup_width / 2, align = "left" },
  label = { string = "—", width = popup_width / 2, align = "right" },
})

local popup_ip = sbar.add("item", "wifi.ip", {
  position = "popup.wifi",
  icon = { string = "IP:", width = popup_width / 2, align = "left" },
  label = { string = "—", width = popup_width / 2, align = "right" },
})

local popup_mask = sbar.add("item", "wifi.mask", {
  position = "popup.wifi",
  icon = { string = "Subnet:", width = popup_width / 2, align = "left" },
  label = { string = "—", width = popup_width / 2, align = "right" },
})

local popup_router = sbar.add("item", "wifi.router", {
  position = "popup.wifi",
  icon = { string = "Router:", width = popup_width / 2, align = "left" },
  label = { string = "—", width = popup_width / 2, align = "right" },
})

local popup_hostname = sbar.add("item", "wifi.hostname", {
  position = "popup.wifi",
  icon = { string = "Host:", width = popup_width / 2, align = "left" },
  label = { string = "—", width = popup_width / 2, align = "right" },
})

-- Copy to clipboard on click
local function copy_click(item)
  item:subscribe("mouse.clicked", function(env)
    sbar.exec("sketchybar --query " .. env.NAME .. " | python3 -c \"import sys,json; print(json.load(sys.stdin)['label']['value'])\" | pbcopy")
    local orig = item:query().label.value
    item:set({ label = { string = "📋 Copied!" } })
    sbar.delay(1, function() item:set({ label = { string = orig } }) end)
  end)
end

copy_click(popup_ip)
copy_click(popup_mask)
copy_click(popup_router)

-- Update WiFi status
local function update_wifi()
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
end

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, function() update_wifi() end)

-- Popup: show details on hover
wifi:subscribe("mouse.entered", function()
  wifi:set({ popup = { drawing = true } })
  sbar.exec("ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}'", function(r)
    popup_ssid:set({ label = { string = r:gsub("%s+$", "") } })
  end)
  sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(r)
    popup_ip:set({ label = { string = r:gsub("%s+$", "") } })
  end)
  sbar.exec("networksetup -getinfo Wi-Fi 2>/dev/null | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(r)
    popup_mask:set({ label = { string = r:gsub("%s+$", "") } })
  end)
  sbar.exec("networksetup -getinfo Wi-Fi 2>/dev/null | awk -F 'Router: ' '/^Router: / {print $2}'", function(r)
    popup_router:set({ label = { string = r:gsub("%s+$", "") } })
  end)
  sbar.exec("networksetup -getcomputername", function(r)
    popup_hostname:set({ label = { string = r:gsub("%s+$", "") } })
  end)
end)

wifi:subscribe("mouse.exited.global", function()
  wifi:set({ popup = { drawing = false } })
end)

-- Initial update
update_wifi()
