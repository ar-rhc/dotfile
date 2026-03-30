local colors = require("colors")
local settings = require("settings")

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
})

ram:subscribe({ "routine", "forced" }, function()
  sbar.exec([[
    PAGE_SIZE=$(sysctl -n vm.pagesize)
    TOTAL=$(sysctl -n hw.memsize)
    STATS=$(vm_stat)
    FREE=$(echo "$STATS" | awk '/Pages free/ {gsub(/\./,"",$3); print $3}')
    INACTIVE=$(echo "$STATS" | awk '/Pages inactive/ {gsub(/\./,"",$3); print $3}')
    SPECULATIVE=$(echo "$STATS" | awk '/Pages speculative/ {gsub(/\./,"",$3); print $3}')
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
