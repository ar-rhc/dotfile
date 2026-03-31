local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Register events
sbar.add("event", "aerospace_service_mode_enter")
sbar.add("event", "aerospace_service_mode_exit")
sbar.add("event", "aerospace_app_mode_enter")
sbar.add("event", "aerospace_app_mode_exit")

-- Main service mode icon (center)
local service_mode = sbar.add("item", "service_mode", {
  position = "center",
  icon = {
    string = icons.service.dog,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
    color = colors.white,
    drawing = false,
  },
  label = { drawing = false },
  background = { drawing = false },
  width = 0,
})

-- Cheat sheet styling
local cheat_style = {
  drawing = false,
  icon = {
    font = { family = settings.font.text, style = "Bold", size = 12.0 },
    color = colors.white,
    padding_left = 8,
    padding_right = 2,
  },
  label = {
    font = { family = settings.font.text, style = "Regular", size = 12.0 },
    color = colors.grey,
    padding_left = 2,
    padding_right = 8,
  },
  background = {
    color = colors.bg1,
    border_color = colors.bg2,
    border_width = 2,
    corner_radius = 9,
    height = 26,
  },
  padding_left = 2,
  padding_right = 2,
}

-- Service mode cheat keys
local service_cheats = {
  { key = "f", action = "float" }, { key = "d", action = "default" },
  { key = "t", action = "layout" }, { key = "e", action = "equal" },
  { key = "s", action = "split" }, { key = "w", action = "close" },
  { key = "+/-", action = "size" }, { key = "g", action = "gaps" },
  { key = "r", action = "reset" }, { key = "c", action = "empty" },
  { key = "q", action = "reload" }, { key = "hjkl", action = "join" },
  { key = "esc", action = "exit" },
}

local service_cheat_items = {}
for _, c in ipairs(service_cheats) do
  local item = sbar.add("item", "cheat." .. c.key, cheat_style)
  item:set({ icon = { string = c.key }, label = { string = c.action } })
  table.insert(service_cheat_items, item)
end

-- App mode cheat keys
local app_cheats = {
  { key = "Q", icon = ":weather:" }, { key = "W", icon = ":wechat:" },
  { key = "E", icon = ":microsoft_edge:" }, { key = "T", icon = ":iterm:" },
  { key = "F", icon = ":finder:" }, { key = "B", icon = ":bettertouchtool:" },
  { key = "C", icon = ":calendar:" }, { key = "Z", icon = ":zotero:" }, { key = "M", icon = ":mail:" },
  { key = "ESC", icon = "Exit" },
}

local app_cheat_items = {}
for _, c in ipairs(app_cheats) do
  local item = sbar.add("item", "appcheat." .. c.key, cheat_style)
  local is_esc = c.key == "ESC"
  item:set({
    icon = { string = c.key, padding_right = 6 },
    label = {
      string = c.icon,
      font = is_esc
        and { family = settings.font.text, style = "Regular", size = 12.0 }
        or { family = "sketchybar-app-font", style = "Regular", size = 18.0 },
      color = colors.white,
      padding_left = 6,
    },
  })
  table.insert(app_cheat_items, item)
end

-- Items to hide in modes
local HIDE_ITEMS = {
  "menu_trigger", "space_creator", "app_list", "timer", "volume_desktop",
  "volume_desktop_slider", "notifications", "input_source", "trash",
  "next_event", "wifi", "ram", "cpu.percent", "cpu.top", "weather", "music", "focus",
}

local function hide_items()
  for _, name in ipairs(HIDE_ITEMS) do
    sbar.set(name, { drawing = false })
  end
  -- Hide space and notif items dynamically
  sbar.exec([[sketchybar --query bar | python3 -c "
import sys, json, subprocess
items = json.load(sys.stdin).get('items', [])
for i in items:
    if i.startswith('space.') or i.startswith('notif.'):
        subprocess.run(['sketchybar', '--set', i, 'drawing=off'], capture_output=True)
"]])
end

local function show_items()
  for _, name in ipairs(HIDE_ITEMS) do
    sbar.set(name, { drawing = true })
  end
  sbar.exec([[sketchybar --query bar | python3 -c "
import sys, json, subprocess
items = json.load(sys.stdin).get('items', [])
for i in items:
    if i.startswith('space.'):
        subprocess.run(['sketchybar', '--set', i, 'drawing=on'], capture_output=True)
"]])
end

local function show_cheat(items)
  for _, item in ipairs(items) do item:set({ drawing = true }) end
end

local function hide_cheat(items)
  for _, item in ipairs(items) do item:set({ drawing = false }) end
end

-- Event handlers
service_mode:subscribe("aerospace_service_mode_enter", function()
  sbar.bar({ color = colors.bar.service })
  service_mode:set({ icon = { string = icons.service.dog, drawing = true }, width = "dynamic" })
  show_cheat(service_cheat_items)
  hide_cheat(app_cheat_items)
  hide_items()
end)

service_mode:subscribe("aerospace_service_mode_exit", function()
  sbar.bar({ color = colors.bar.bg })
  service_mode:set({ icon = { drawing = false }, width = 0 })
  hide_cheat(service_cheat_items)
  hide_cheat(app_cheat_items)
  show_items()
end)

service_mode:subscribe("aerospace_app_mode_enter", function()
  sbar.bar({ color = colors.bar.app })
  service_mode:set({ icon = { string = icons.service.cat, drawing = true }, width = "dynamic" })
  hide_cheat(service_cheat_items)
  show_cheat(app_cheat_items)
  hide_items()
end)

service_mode:subscribe("aerospace_app_mode_exit", function()
  sbar.bar({ color = colors.bar.bg })
  service_mode:set({ icon = { drawing = false }, width = 0 })
  hide_cheat(service_cheat_items)
  hide_cheat(app_cheat_items)
  show_items()
end)
