local colors = require("colors")
local settings = require("settings")
local icon_map = require("icon_map")
local displays = require("displays")

-- Register events
sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "window_moved")

-- Module-level state
local current_focused = ""
local dividers = {}

-- Build workspace-to-monitor-group lookup from settings
local ws_to_monitor_group = {}
for m, ws_list in pairs(settings.aerospace.monitors) do
  for _, ws in ipairs(ws_list) do
    ws_to_monitor_group[ws] = m
  end
end

-- Get workspace info from AeroSpace at init time
local function get_workspaces()
  local workspaces = {}
  local handle = io.popen("aerospace list-monitors | awk '{print $1}'")
  local monitors = {}
  for line in handle:lines() do table.insert(monitors, tonumber(line)) end
  handle:close()

  local num_monitors = #monitors

  for _, m in ipairs(monitors) do
    local sketchy_display = displays.map[m] or m

    -- Get workspaces for this monitor in custom order
    local h = io.popen("aerospace list-workspaces --monitor " .. m)
    local all_ws = {}
    for line in h:lines() do table.insert(all_ws, line) end
    h:close()

    -- Custom ordering
    local custom_order = {}
    local added = {}
    for ws in settings.aerospace.custom_order:gmatch("%S+") do
      for _, actual in ipairs(all_ws) do
        if actual:lower() == ws:lower() and not added[actual] then
          table.insert(custom_order, actual)
          added[actual] = true
        end
      end
    end
    -- Add any remaining
    for _, ws in ipairs(all_ws) do
      if not added[ws] then table.insert(custom_order, ws) end
    end

    -- Group by monitor group (native group first), preserving custom order within
    local grouped = {}
    local group_list = {}
    local seen_groups = {}
    for _, sid in ipairs(custom_order) do
      local grp = ws_to_monitor_group[sid] or m
      if not grouped[grp] then grouped[grp] = {} end
      if not seen_groups[grp] then
        table.insert(group_list, grp)
        seen_groups[grp] = true
      end
      table.insert(grouped[grp], sid)
    end
    table.sort(group_list, function(a, b)
      if a == m then return true
      elseif b == m then return false
      else return a < b end
    end)
    local order = {}
    for _, grp in ipairs(group_list) do
      for _, sid in ipairs(grouped[grp]) do
        table.insert(order, sid)
      end
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
        monitor_group = ws_to_monitor_group[sid] or m,
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
    strip = strip .. " " .. icon_map.get(app)
  end
  return strip
end

-- Create space items with dividers between monitor groups
local spaces = {}
local prev_group = nil

for _, ws in ipairs(get_workspaces()) do
  -- Insert divider at monitor group boundaries
  if prev_group and ws.monitor_group ~= prev_group then
    local div_name = "space_divider." .. prev_group .. "_" .. ws.monitor_group
    local divider = sbar.add("item", div_name, {
      icon = { drawing = false },
      label = { drawing = false },
      padding_left = 1,
      padding_right = 1,
      width = 6,
      background = {
        color = colors.with_alpha(colors.grey, 0.5),
        height = 18,
        corner_radius = 1,
      },
      display = 0, -- hidden by default; shown dynamically
    })
    dividers[div_name] = {
      item = divider,
      group_before = prev_group,
      group_after = ws.monitor_group,
    }
  end
  prev_group = ws.monitor_group

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

  -- Uses cached current_focused (no async call needed)
  space:subscribe("mouse.exited", function()
    if current_focused == ws.id then
      space:set({ background = { border_color = colors.grey }, icon = { highlight = true } })
    else
      space:set({ background = { border_color = colors.bg2 }, icon = { highlight = false } })
    end
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

-- Refresh icon strip for a workspace (pure Lua icon lookup)
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

    -- Build icon strip using Lua table lookup (instant, no shell)
    local strip = " "
    for app in apps_str:gmatch("[^\n]+") do
      if app ~= "" then
        strip = strip .. " " .. icon_map.get(app)
      end
    end

    if spaces[ws_id] then
      sbar.animate("sin", 10, function()
        spaces[ws_id]:set({ label = { string = strip } })
      end)
    end
  end)
end

local function highlight_focused()
  sbar.exec("aerospace list-workspaces --focused", function(focused)
    focused = focused:gsub("%s+$", "")
    current_focused = focused
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

-- Refresh display assignments and divider visibility (single batched call)
local function refresh_space_displays()
  local cmd = [[/bin/bash -c '
    focused=$(aerospace list-workspaces --focused)
    echo "FOCUSED:$focused"
    for m in $(aerospace list-monitors | awk "{print \$1}"); do
      echo "MONITOR:$m"
      echo "NONEMPTY:$(aerospace list-workspaces --monitor $m --empty no | tr "\n" ",")"
      echo "EMPTY:$(aerospace list-workspaces --monitor $m --empty | tr "\n" ",")"
    done
  ']]

  sbar.exec(cmd, function(result)
    local focused = ""
    local monitors = {}
    local current_monitor = nil
    local monitor_data = {} -- { [m] = { nonempty={}, empty={} } }

    for line in result:gmatch("[^\n]+") do
      local f = line:match("^FOCUSED:(.+)$")
      if f then focused = f:gsub("%s+", "") end

      local m = line:match("^MONITOR:(%d+)$")
      if m then
        current_monitor = tonumber(m)
        table.insert(monitors, current_monitor)
        monitor_data[current_monitor] = { nonempty = {}, empty = {} }
      end

      local ne = line:match("^NONEMPTY:(.*)$")
      if ne and current_monitor then
        for ws in ne:gmatch("[^,]+") do
          local name = ws:gsub("%s+", "")
          if name ~= "" then table.insert(monitor_data[current_monitor].nonempty, name) end
        end
      end

      local em = line:match("^EMPTY:(.*)$")
      if em and current_monitor then
        for ws in em:gmatch("[^,]+") do
          local name = ws:gsub("%s+", "")
          if name ~= "" then table.insert(monitor_data[current_monitor].empty, name) end
        end
      end
    end

    current_focused = focused
    local group_to_sketchy = {}

    for _, m in ipairs(monitors) do
      local sketchy_display = displays.map[m] or m

      for _, name in ipairs(monitor_data[m].nonempty) do
        if spaces[name] then spaces[name]:set({ display = sketchy_display }) end
        local grp = ws_to_monitor_group[name]
        if grp then group_to_sketchy[grp] = sketchy_display end
      end

      for _, name in ipairs(monitor_data[m].empty) do
        local grp = ws_to_monitor_group[name]
        if grp then group_to_sketchy[grp] = sketchy_display end
        if spaces[name] then
          if name == focused then
            spaces[name]:set({ display = sketchy_display })
          else
            spaces[name]:set({ display = 0 })
          end
        end
      end
    end

    -- Update divider visibility: show when adjacent groups share a display
    for _, div in pairs(dividers) do
      local d_before = group_to_sketchy[div.group_before]
      local d_after = group_to_sketchy[div.group_after]
      if d_before and d_after and d_before == d_after then
        div.item:set({ display = d_before })
      else
        div.item:set({ display = 0 })
      end
    end
  end)
end

local function refresh_all_focused()
  sbar.exec("aerospace list-workspaces --focused", function(focused)
    focused = focused:gsub("%s+$", "")
    current_focused = focused
    reload_workspace_icons(focused)
  end)
  highlight_focused()
end

-- Workspace change handler — uses env vars from subscriber callback directly
local function on_workspace_change(env)
  local focused = env.AEROSPACE_FOCUSED_WORKSPACE
  local prev = env.AEROSPACE_PREV_WORKSPACE

  if focused and focused ~= "" then
    current_focused = focused
    reload_workspace_icons(focused)
  end
  if prev and prev ~= "" and prev ~= focused then
    reload_workspace_icons(prev)
  end

  highlight_focused()
  refresh_space_displays()
end

-- Refresh all workspace icons (for window_moved where source is unknown)
local function refresh_all_visible()
  for ws_id, _ in pairs(spaces) do
    reload_workspace_icons(ws_id)
  end
  highlight_focused()
  refresh_space_displays()
end

-- Event subscriptions
space_creator:subscribe("aerospace_workspace_change", function(env)
  on_workspace_change(env)
end)

space_creator:subscribe("display_change", function()
  refresh_space_displays()
end)

space_creator:subscribe("space_windows_change", function()
  refresh_all_focused()
end)

space_creator:subscribe("front_app_switched", function()
  refresh_all_focused()
end)

-- Window moved: refresh all workspaces (source unknown, cache short-circuits unchanged)
space_creator:subscribe("window_moved", function()
  refresh_all_visible()
end)

-- Init: highlight active workspace and set divider visibility
highlight_focused()
refresh_space_displays()
