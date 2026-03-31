local colors = require("colors")
local settings = require("settings")

-- Register events
sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "window_moved")

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

  -- Click: switch workspace (shift+click to rename)
  space:subscribe("mouse.clicked", function(env)
    local ws_name = ws.id
    if env.MODIFIER == "shift" then
      sbar.exec("osascript -e 'return (text returned of (display dialog \"Give a name to space " .. ws_name .. ":\" default answer \"\" with icon note buttons {\"Cancel\", \"Continue\"} default button \"Continue\"))' 2>/dev/null", function(label)
        label = label:gsub("%s+$", "")
        if label == "" then
          space:set({ icon = { string = ws_name } })
        else
          space:set({ icon = { string = ws_name .. " (" .. label .. ")" } })
        end
      end)
    else
      sbar.exec("aerospace workspace " .. ws_name)
    end
  end)

  -- Hover highlight
  space:subscribe("mouse.entered", function()
    space:set({ background = { border_color = 0x80c0efff }, icon = { highlight = true } })
  end)

  space:subscribe("mouse.exited", function()
    sbar.exec("aerospace list-workspaces --focused", function(focused)
      focused = focused:gsub("%s+$", "")
      if focused == ws.id then
        space:set({ background = { border_color = colors.grey }, icon = { highlight = true } })
      else
        space:set({ background = { border_color = colors.bg2 }, icon = { highlight = false } })
      end
    end)
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

-- Refresh icon strip for focused workspace (pure Lua)
local last_icon_cache = {}

local function reload_workspace_icons(ws_id)
  if not ws_id or ws_id == "" then return end
  sbar.exec("aerospace list-windows --workspace " .. ws_id .. " | awk -F'|' '{gsub(/^ *| *$/, \"\", $2); print $2}'", function(apps_str)
    apps_str = apps_str:gsub("%s+$", "")
    -- Cache check: skip update if unchanged
    if last_icon_cache[ws_id] == apps_str then return end
    last_icon_cache[ws_id] = apps_str

    if apps_str == "" then
      if spaces[ws_id] then
        spaces[ws_id]:set({ label = { string = "" } })
      end
      return
    end

    -- Build icon strip
    local icon_cmds = {}
    for app in apps_str:gmatch("[^\n]+") do
      if app ~= "" then table.insert(icon_cmds, app) end
    end

    if #icon_cmds == 0 then
      if spaces[ws_id] then spaces[ws_id]:set({ label = { string = "" } }) end
      return
    end

    -- Build a single shell command to get all icons at once
    local cmd = ""
    for _, app in ipairs(icon_cmds) do
      cmd = cmd .. "/Users/alex/.config/sketchybar/plugins/icon_map.sh '" .. app .. "'; "
    end
    sbar.exec(cmd, function(icons_str)
      local strip = " "
      for icon in icons_str:gmatch("[^\n]+") do
        strip = strip .. " " .. icon:gsub("%s+$", "")
      end
      if spaces[ws_id] then
        sbar.animate("sin", 10, function()
          spaces[ws_id]:set({ label = { string = strip } })
        end)
      end
    end)
  end)
end

local function highlight_focused()
  sbar.exec("aerospace list-workspaces --focused", function(focused)
    focused = focused:gsub("%s+$", "")
    for ws_id, space in pairs(spaces) do
      if ws_id == focused then
        space:set({
          icon = { highlight = true },
          label = { highlight = true },
          background = { border_color = colors.grey },
        })
      else
        space:set({
          icon = { highlight = false },
          label = { highlight = false },
          background = { border_color = colors.bg2 },
        })
      end
    end
  end)
end

-- Refresh display assignments for all monitors
local function refresh_space_displays()
  sbar.exec("aerospace list-monitors | awk '{print $1}'", function(monitors_str)
    local monitors = {}
    for m in monitors_str:gmatch("[^\n]+") do table.insert(monitors, tonumber(m)) end
    local num_monitors = #monitors

    sbar.exec("aerospace list-workspaces --focused", function(focused)
      focused = focused:gsub("%s+$", "")

      for _, m in ipairs(monitors) do
        local sketchy_display = m
        if num_monitors == 2 then sketchy_display = 3 - m end

        sbar.exec("aerospace list-workspaces --monitor " .. m .. " --empty no", function(non_empty)
          for w in non_empty:gmatch("[^\n]+") do
            w = w:gsub("%s+", "")
            if spaces[w] then spaces[w]:set({ display = sketchy_display }) end
          end
        end)

        sbar.exec("aerospace list-workspaces --monitor " .. m .. " --empty", function(empty)
          for w in empty:gmatch("[^\n]+") do
            w = w:gsub("%s+", "")
            if spaces[w] then
              if w == focused then
                spaces[w]:set({ display = sketchy_display })
              else
                spaces[w]:set({ display = 0 })
              end
            end
          end
        end)
      end
    end)
  end)
end

local function refresh_all_focused()
  sbar.exec("aerospace list-workspaces --focused", function(focused)
    focused = focused:gsub("%s+$", "")
    reload_workspace_icons(focused)
  end)
  highlight_focused()
end

-- Full workspace change handler (replaces space_windows.sh)
local function on_workspace_change()
  sbar.exec("echo $AEROSPACE_FOCUSED_WORKSPACE $AEROSPACE_PREV_WORKSPACE", function(ws)
    local focused, prev = ws:match("(%S+)%s+(%S+)")
    if focused then reload_workspace_icons(focused) end
    if prev and prev ~= focused then reload_workspace_icons(prev) end
  end)

  -- Animate focused workspace
  highlight_focused()
  refresh_space_displays()
end

-- Space creator handles workspace changes + display updates
space_creator:subscribe({ "aerospace_workspace_change" }, function()
  on_workspace_change()
end)

space_creator:subscribe("display_change", function()
  refresh_space_displays()
end)

-- Window open/close detection (kernel event, zero CPU)
space_creator:subscribe("space_windows_change", function()
  refresh_all_focused()
end)

-- App focus change also refreshes (catches most open/close scenarios)
space_creator:subscribe("front_app_switched", function()
  refresh_all_focused()
end)

-- Window moved between workspaces (from on-window-detected rules)
space_creator:subscribe("window_moved", function()
  refresh_all_focused()
end)

-- Highlight active workspace on init
highlight_focused()
