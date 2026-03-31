local day_icons = {
  [1000] = "",
  [1003] = "",
  [1006] = "",
  [1009] = "",
  [1030] = "",
  [1063] = "",
  [1066] = "",
  [1069] = "",
  [1072] = "",
  [1087] = "",
  [1114] = "",
  [1117] = "",
  [1135] = "",
  [1147] = "",
  [1150] = "",
  [1153] = "",
  [1168] = "",
  [1171] = "",
  [1180] = "",
  [1183] = "",
  [1186] = "",
  [1189] = "",
  [1192] = "",
  [1195] = "",
  [1198] = "",
  [1201] = "",
  [1204] = "",
  [1207] = "",
  [1210] = "",
  [1213] = "",
  [1216] = "",
  [1219] = "",
  [1222] = "",
  [1225] = "",
  [1237] = "",
  [1240] = "",
  [1243] = "",
  [1246] = "",
  [1249] = "",
  [1252] = "",
  [1255] = "",
  [1258] = "",
  [1261] = "",
  [1264] = "",
  [1273] = "",
  [1276] = "",
  [1279] = "",
  [1282] = "",
}

local night_icons = {
  [1000] = "",
  [1003] = "",
  [1006] = "",
  [1009] = "",
  [1030] = "",
  [1063] = "",
  [1066] = "",
  [1069] = "",
  [1072] = "",
  [1087] = "",
  [1114] = "",
  [1117] = "",
  [1135] = "",
  [1147] = "",
  [1150] = "",
  [1153] = "",
  [1168] = "",
  [1171] = "",
  [1180] = "",
  [1183] = "",
  [1186] = "",
  [1189] = "",
  [1192] = "",
  [1195] = "",
  [1198] = "",
  [1201] = "",
  [1204] = "",
  [1207] = "",
  [1210] = "",
  [1213] = "",
  [1216] = "",
  [1219] = "",
  [1222] = "",
  [1225] = "",
  [1237] = "",
  [1240] = "",
  [1243] = "",
  [1246] = "",
  [1249] = "",
  [1252] = "",
  [1255] = "",
  [1258] = "",
  [1261] = "",
  [1264] = "",
  [1273] = "",
  [1276] = "",
  [1279] = "",
  [1282] = "",
}

local API_KEY = "92d1dbd1f0ed49f392c195243260701"

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
})

local function update_weather()
  sbar.exec("curl -s ipinfo.io/loc 2>/dev/null || echo '-36.8,174.7'", function(loc)
    loc = loc:gsub("%s+$", "")
    if loc == "" then loc = "-36.8,174.7" end

    local url = "https://api.weatherapi.com/v1/current.json?key=" .. API_KEY .. "&q=" .. loc .. "&aqi=no"
    sbar.exec("curl -s '" .. url .. "'", function(result)
      if type(result) == "table" and result.current then
        local temp = result.current.temp_c
        local code = result.current.condition and result.current.condition.code or 1000
        local is_day = result.current.is_day or 1

        local icon
        if is_day == 0 and night_icons[code] then
          icon = night_icons[code]
        elseif day_icons[code] then
          icon = day_icons[code]
        else
          icon = "󰖐"
        end

        weather:set({
          icon = { string = icon },
          label = { string = string.format("%.1f°C", temp) },
        })
      elseif type(result) == "string" and result ~= "" then
        local temp = result:match('"temp_c":([%d%.%-]+)')
        if temp then
          weather:set({ label = { string = temp .. "°C" } })
        end
      end
    end)
  end)
end

weather:subscribe({ "routine", "forced" }, function() update_weather() end)

weather:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("open -a Weather")
  else
    sbar.exec([[osascript -e 'tell application "BetterTouchTool" to trigger_named "metero"' 2>/dev/null &]])
  end
end)

update_weather()
