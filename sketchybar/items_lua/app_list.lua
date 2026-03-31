local colors = require("colors")
local settings = require("settings")
local icon_map = require("icon_map")

local MAX_APPS = 12

local app_list = sbar.add("item", "app_list", {
  position = "right",
  icon = {
    string = "􀈕",
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
    color = colors.grey,
  },
  label = { drawing = false },
  padding_left = 5,
  padding_right = 3,
  popup = { height = 30, background = { border_width = 0 } },
})

-- Popup items
local popup_width = 260
local app_items = {}
local app_data = {}  -- { window_id, app_name, workspace }

for i = 1, MAX_APPS do
  app_items[i] = sbar.add("item", "app_list.app" .. i, {
    position = "popup.app_list",
    drawing = false,
    icon = {
      font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
      width = 30,
      align = "center",
    },
    label = {
      font = { family = settings.font.text, style = "Regular", size = 12.0 },
      width = popup_width - 30,
    },
  })
  app_data[i] = {}

  -- Click/Cmd+click events
  local idx = i
  sbar.add("event", "app_list_click_" .. i)
  sbar.exec("sketchybar --set app_list.app" .. i .. " click_script='sketchybar --trigger app_list_click_" .. i .. " MODIFIER=$MODIFIER'")

  app_list:subscribe("app_list_click_" .. i, function(env)
    local d = app_data[idx]
    if not d or not d.window_id then return end

    if env.MODIFIER == "cmd" then
      -- Cmd+click: close the window
      sbar.exec("aerospace close --window-id " .. d.window_id)
      app_items[idx]:set({ label = { string = "✕ " .. (d.app_name or ""), color = colors.red } })
      sbar.delay(1, function()
        app_list:set({ popup = { drawing = false } })
      end)
    else
      -- Click: focus the window
      sbar.exec("aerospace focus --window-id " .. d.window_id)
      app_list:set({ popup = { drawing = false } })
    end
  end)
end

-- Hint at bottom
sbar.add("item", "app_list.hint", {
  position = "popup.app_list",
  icon = { drawing = false },
  label = {
    string = "Click: focus  ⌘+click: close",
    font = { family = settings.font.text, style = "Regular", size = 10.0 },
    color = colors.grey,
    align = "center",
    width = popup_width,
  },
  background = { height = 2, color = colors.grey, y_offset = 12 },
})

-- Hover: show running apps
app_list:subscribe("mouse.entered", function()
  -- Hide all first
  for i = 1, MAX_APPS do
    app_items[i]:set({ drawing = false })
    app_data[i] = {}
  end

  sbar.exec("aerospace list-windows --all --format '%{app-name}|%{window-id}|%{workspace}'", function(result)
    result = result:gsub("%s+$", "")
    if result == "" then
      app_items[1]:set({
        drawing = true,
        icon = { string = "" },
        label = { string = "No windows", color = colors.grey },
      })
      app_list:set({ popup = { drawing = true } })
      return
    end

    local i = 1
    local seen = {}  -- deduplicate by app name
    for line in result:gmatch("[^\n]+") do
      if i > MAX_APPS then break end
      local app_name, wid, ws = line:match("^(.-)|(.-)|(.+)")
      if app_name and wid and not seen[app_name] then
        seen[app_name] = true
        app_data[i] = { window_id = wid, app_name = app_name, workspace = ws }

        app_items[i]:set({
          drawing = true,
          icon = { string = icon_map.get(app_name), color = colors.white },
          label = { string = app_name .. "  [" .. ws .. "]", color = colors.white },
        })
        i = i + 1
      end
    end

    -- Update the icon with count
    app_list:set({
      icon = { string = "􀈕", color = colors.white },
      popup = { drawing = true },
    })
  end)
end)

app_list:subscribe("mouse.exited.global", function()
  app_list:set({ popup = { drawing = false } })
end)
