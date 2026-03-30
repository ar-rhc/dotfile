local colors = require("colors")
local settings = require("settings")

-- Register aerospace event
sbar.add("event", "aerospace_workspace_change")

-- Get workspace info from AeroSpace at init time
local function get_workspaces()
  local workspaces = {}
  local handle = io.popen("aerospace list-monitors | awk '{print $1}'")
  local monitors = {}
  for line in handle:lines() do table.insert(monitors, tonumber(line)) end
  handle:close()

  local num_monitors = #monitors

  for _, m in ipairs(monitors) do
    local sketchy_display = m
    if num_monitors == 2 then sketchy_display = 3 - m end

    -- Get workspaces for this monitor in custom order
    local h = io.popen("aerospace list-workspaces --monitor " .. m)
    local all_ws = {}
    for line in h:lines() do table.insert(all_ws, line) end
    h:close()

    -- Custom ordering
    local order = {}
    local added = {}
    for ws in settings.aerospace.custom_order:gmatch("%S+") do
      for _, actual in ipairs(all_ws) do
        if actual:lower() == ws:lower() and not added[actual] then
          table.insert(order, actual)
          added[actual] = true
        end
      end
    end
    -- Add any remaining
    for _, ws in ipairs(all_ws) do
      if not added[ws] then table.insert(order, ws) end
    end

    -- Get empty workspaces
    local empty = {}
    local eh = io.popen("aerospace list-workspaces --monitor " .. m .. " --empty")
    for line in eh:lines() do empty[line] = true end
    eh:close()

    for _, sid in ipairs(order) do
      table.insert(workspaces, {
        id = sid,
        display = sketchy_display,
        empty = empty[sid] or false,
      })
    end
  end
  return workspaces
end

-- Get app icons for a workspace
local function get_icon_strip(sid)
  local h = io.popen("aerospace list-windows --workspace " .. sid .. " | awk -F'|' '{gsub(/^ *| *$/, \"\", $2); print $2}'")
  local apps = {}
  for line in h:lines() do
    if line ~= "" then table.insert(apps, line) end
  end
  h:close()

  if #apps == 0 then return " —" end

  local strip = " "
  for _, app in ipairs(apps) do
    local ih = io.popen("$CONFIG_DIR/plugins/icon_map.sh '" .. app .. "'")
    local icon = ih:read("*a"):gsub("%s+$", "")
    ih:close()
    strip = strip .. " " .. icon
  end
  return strip
end

-- Create space items
local spaces = {}
for _, ws in ipairs(get_workspaces()) do
  local space = sbar.add("space", "space." .. ws.id, {
    space = ws.id,
    icon = {
      string = ws.id,
      highlight_color = colors.orange,
      padding_left = 10,
      padding_right = 10,
    },
    label = {
      string = get_icon_strip(ws.id),
      color = colors.grey,
      highlight_color = colors.white,
      font = { family = "sketchybar-app-font", style = "Regular", size = 16.0 },
      y_offset = -1,
      padding_right = 20,
    },
    display = ws.empty and 0 or ws.display,
    padding_left = 2,
    padding_right = 2,
    background = {
      color = colors.bg1,
      border_color = colors.bg2,
      border_width = 2,
      corner_radius = 9,
      height = 26,
    },
  })

  space:subscribe({ "aerospace_workspace_change", "display_change", "system_woke",
                     "mouse.clicked", "mouse.entered", "mouse.exited" }, function(env)
    sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; export NAME=" .. space.name .. "; export SENDER=" .. (env.SENDER or "routine") .. "; /Users/alex/.config/sketchybar/plugins/space.sh'")
  end)

  spaces[ws.id] = space
end

-- Space creator (>) — placed after all space items
local space_creator = sbar.add("item", "space_creator", {
  icon = {
    string = "􀆊",
    font = { family = settings.font.text, style = "Heavy", size = 16.0 },
    color = colors.white,
  },
  label = { drawing = false },
  padding_left = 5,
  padding_right = 5,
  display = "active",
})

space_creator:subscribe({ "aerospace_workspace_change", "display_change" }, function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; export SENDER=" .. (env.SENDER or "routine") .. "; /Users/alex/.config/sketchybar/plugins/space_windows.sh'")
end)
