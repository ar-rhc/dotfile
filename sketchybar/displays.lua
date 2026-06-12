-- Shared display mapping: AeroSpace monitor ID → SketchyBar display ID
-- Require this module to get the correct display for a given monitor.

local M = {}

-- Get actual monitors from AeroSpace
local handle = io.popen("aerospace list-monitors")
local monitor_names = {}
local monitor_ids = {}
for line in handle:lines() do
  local id, name = line:match("(%d+)%s+|%s+(.+)")
  if id then
    local m = tonumber(id)
    table.insert(monitor_ids, m)
    monitor_names[m] = name
  end
end
handle:close()

M.count = #monitor_ids
M.map = {}

-- Strategy:
-- 1. Identify which AeroSpace ID is the "LG" monitor.
-- 2. Map LG to SB Display 1.
-- 3. Map everything else sequentially.
local lg_aerospace_id = nil
for m, name in pairs(monitor_names) do
  if name:match("LG") then lg_aerospace_id = m; break end
end

if lg_aerospace_id then
  M.map[lg_aerospace_id] = 1
  local next_sb = 2
  for _, m in ipairs(monitor_ids) do
    if m ~= lg_aerospace_id then
      M.map[m] = next_sb
      next_sb = next_sb + 1
    end
  end
else
  -- Fallback: 1-to-1 mapping
  for _, m in ipairs(monitor_ids) do M.map[m] = m end
end

return M
