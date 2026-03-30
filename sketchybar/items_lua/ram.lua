local colors = require("colors")
local settings = require("settings")

local NUM_PROCS = 8

-- System processes that should NOT be killed (shown in grey)
local SYSTEM_PROCS = {
  -- Core OS
  kernel_task = true, launchd = true, WindowServer = true, loginwindow = true,
  -- Essential services
  opendirectoryd = true, configd = true, diskarbitrationd = true, fseventsd = true,
  mds = true, mds_stores = true, notifyd = true, powerd = true, coreaudiod = true,
  bluetoothd = true, UserEventAgent = true, cfprefsd = true, coreduetd = true,
  dasd = true, trustd = true, securityd = true, systemstats = true, syslogd = true,
  -- System UI
  Finder = true, Dock = true, SystemUIServer = true, ControlCenter = true,
  -- Other system
  logd = true, watchdogd = true, filecoordinationd = true, fileproviderd = true,
  nsurlsessiond = true, lsd = true, iconservicesagent = true, distnoted = true,
  runningboardd = true, symptomsd = true, sharingd = true, rapportd = true,
  mdworker_shared = true, bird = true, cloudd = true, assistantd = true,
  suggestd = true, searchpartyd = true, siriactionsd = true, mediaremoted = true,
  ["com.apple.WebKit.WebContent"] = true, ["com.apple.WebKit.GPU"] = true,
  ["com.apple.WebKit.Networking"] = true, AMPDeviceDiscoveryAgent = true,
}

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
local proc_names = {}  -- track process names for kill

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
  proc_names[i] = { name = "", is_system = false }
end

-- Hint at bottom of popup
sbar.add("item", "ram.hint", {
  position = "popup.ram",
  icon = { drawing = false },
  label = {
    string = "⌘+click to quit app",
    font = { family = settings.font.text, style = "Regular", size = 10.0 },
    color = colors.grey,
    align = "center",
    width = popup_width,
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = 12,
  },
})

-- Cmd+click to kill process (only non-system)
for i = 1, NUM_PROCS do
  local idx = i
  sbar.add("event", "ram_kill_" .. i)
  sbar.exec("sketchybar --set ram.proc" .. i .. " click_script='sketchybar --trigger ram_kill_" .. i .. " MODIFIER=$MODIFIER'")

  ram:subscribe("ram_kill_" .. i, function(env)
    local p = proc_names[idx]
    if not p or p.name == "" then return end

    if env.MODIFIER ~= "cmd" then return end

    if p.is_system then
      proc_items[idx]:set({ label = { string = "⚠ System process!", color = colors.red } })
      sbar.delay(1.5, function()
        proc_items[idx]:set({ label = { string = p.name .. "  ⚙", color = colors.grey } })
      end)
      return
    end

    -- Kill the process
    sbar.exec("killall '" .. p.name .. "' 2>/dev/null")
    proc_items[idx]:set({ label = { string = "✕ " .. p.name .. " killed", color = colors.red } })
    sbar.delay(1.5, function()
      ram:set({ popup = { drawing = false } })
    end)
  end)
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
  sbar.exec("ps -Ao pmem,comm -r | head -" .. (NUM_PROCS + 1) .. " | tail -" .. NUM_PROCS .. " | awk '{mem=$1; $1=\"\"; cmd=$0; gsub(/^\\s+/,\"\",cmd); n=cmd; gsub(/.*\\//,\"\",n); gsub(/\\.app$/,\"\",n); print mem \"|\" n}'", function(result)
    result = result:gsub("%s+$", "")
    local i = 1
    for line in result:gmatch("[^\n]+") do
      if i > NUM_PROCS then break end
      local mem, app_name = line:match("^([%d%.]+)|(.+)")
      if mem and app_name then
        local is_system = SYSTEM_PROCS[app_name] or false
        local label_color = is_system and colors.grey or colors.white
        local suffix = is_system and " ⚙" or ""

        proc_names[i] = { name = app_name, is_system = is_system }
        proc_items[i]:set({
          label = { string = app_name .. "  " .. mem .. "%" .. suffix, color = label_color },
          icon = { string = "—" },
        })

        local idx = i
        sbar.exec("/Users/alex/.config/sketchybar/plugins/icon_map.sh '" .. app_name .. "'", function(icon)
          icon = icon:gsub("%s+$", "")
          proc_items[idx]:set({ icon = { string = icon, color = label_color } })
        end)
      end
      i = i + 1
    end
    ram:set({ popup = { drawing = "toggle" } })
  end)
end)

ram:subscribe("mouse.exited.global", function()
  ram:set({ popup = { drawing = false } })
end)
