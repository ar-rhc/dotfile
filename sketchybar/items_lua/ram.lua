local colors = require("colors")
local settings = require("settings")

local NUM_PROCS = 5

local ram = sbar.add("item", "ram", {
  position = "right",
  icon = {
    string = "􀫦",
    color = colors.green,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
  },
  label = {
    font = { family = settings.font.numbers, style = "Regular", size = 12.0 },
    color = colors.white,
  },
  padding_left = 3,
  padding_right = 3,
  update_freq = 10,
  updates = "on",
  popup = { height = 30, background = { border_width = 0 } },
})

-- Popup items for top processes
local popup_width = 250
local proc_items = {}
for i = 1, NUM_PROCS do
  proc_items[i] = sbar.add("item", "ram.proc" .. i, {
    position = "popup.ram",
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
end

-- Update RAM usage
ram:subscribe({ "routine", "forced" }, function()
  sbar.exec([[
    PAGE_SIZE=$(sysctl -n vm.pagesize)
    TOTAL=$(sysctl -n hw.memsize)
    STATS=$(vm_stat)
    WIRED=$(echo "$STATS" | awk '/Pages wired/ {gsub(/\./,"",$4); print $4}')
    ACTIVE=$(echo "$STATS" | awk '/Pages active/ {gsub(/\./,"",$3); print $3}')
    COMPRESSED=$(echo "$STATS" | awk '/Pages occupied by compressor/ {gsub(/\./,"",$6); print $6}')
    COMPRESSED=${COMPRESSED:-0}
    USED_PAGES=$((ACTIVE + WIRED + COMPRESSED))
    USED_BYTES=$((USED_PAGES * PAGE_SIZE))
    TOTAL_GB=$(echo "$TOTAL" | awk '{printf "%.0f", $0/1024/1024/1024}')
    USED_GB=$(echo "$USED_BYTES" | awk '{printf "%.1f", $0/1024/1024/1024}')
    PCT=$(echo "$USED_BYTES $TOTAL" | awk '{printf "%.0f", ($1/$2)*100}')
    echo "${USED_GB}/${TOTAL_GB}G|${PCT}"
  ]], function(result)
    result = result:gsub("%s+$", "")
    local display, pct_str = result:match("(.+)|(.+)")
    if not display then return end

    local pct = tonumber(pct_str) or 0
    local color
    if pct > 85 then color = colors.red
    elseif pct > 70 then color = colors.orange
    elseif pct > 50 then color = colors.yellow
    else color = colors.green end

    ram:set({
      label = { string = display },
      icon = { color = color },
    })
  end)
end)

-- Click: show top memory-consuming processes
ram:subscribe("mouse.clicked", function()
  ram:set({ popup = { drawing = "toggle" } })

  -- Fetch top processes by memory
  sbar.exec("ps -Ao pmem,comm -r | head -" .. (NUM_PROCS + 1) .. " | tail -" .. NUM_PROCS, function(result)
    result = result:gsub("%s+$", "")
    local i = 1
    for line in result:gmatch("[^\n]+") do
      if i > NUM_PROCS then break end
      local mem, cmd = line:match("^%s*([%d%.]+)%s+(.+)")
      if mem and cmd then
        -- Get just the app name from the path
        local app_name = cmd:match("([^/]+)$") or cmd
        -- Clean up common suffixes
        app_name = app_name:gsub("%.app$", "")

        -- Try to get app icon
        sbar.exec("/Users/alex/.config/sketchybar/plugins/icon_map.sh '" .. app_name .. "'", function(icon)
          icon = icon:gsub("%s+$", "")
          if proc_items[i] then
            proc_items[i]:set({
              icon = { string = icon },
              label = { string = app_name .. "  " .. mem .. "%" },
            })
          end
        end)
      end
      i = i + 1
    end
  end)
end)

ram:subscribe("mouse.exited.global", function()
  ram:set({ popup = { drawing = false } })
end)
