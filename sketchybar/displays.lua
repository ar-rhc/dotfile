-- Shared display mapping: AeroSpace monitor ID → SketchyBar display ID
-- Require this module to get the correct display for a given monitor.

local M = {}

local handle = io.popen("aerospace list-monitors")
local monitors = {}
local monitor_names = {}
for line in handle:lines() do
  local id, name = line:match("(%d+)%s+|%s+(.+)")
  if id then
    local m = tonumber(id)
    table.insert(monitors, m)
    monitor_names[m] = name
  end
end
handle:close()

M.count = #monitors

-- AeroSpace monitor → SketchyBar display mapping
-- SketchyBar numbers displays main-first (macOS main = SB display 1). LG is the
-- main monitor, so whichever AeroSpace ID corresponds to LG gets SB1; the
-- remaining monitors get SB2+ in AeroSpace's left-to-right order. This adapts
-- automatically across 1/2/3-monitor setups and physical reordering.
M.map = {}
local main_aerospace_id = nil
for m, name in pairs(monitor_names) do
  if name:match("LG") then main_aerospace_id = m; break end
end

if main_aerospace_id then
  M.map[main_aerospace_id] = 1
  local next_sb = 2
  for _, m in ipairs(monitors) do
    if m ~= main_aerospace_id then
      M.map[m] = next_sb
      next_sb = next_sb + 1
    end
  end
else
  for _, m in ipairs(monitors) do M.map[m] = m end
end

M.lg = main_aerospace_id and M.map[main_aerospace_id] or 1

return M
