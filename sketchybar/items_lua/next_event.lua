local colors = require("colors")
local settings = require("settings")

-- Configuration
local EXCLUDE_CALENDARS = "Shorebird Centre Tides & Events, Tiritiri Ferry Schedule"
local MAX_TITLE = 20
local LOOKAHEAD_DAYS = 1

local MAX_POPUP_EVENTS = 8
local popup_width = 280

-- State for collapsed/expanded labels
local last_short_label = ""
local last_full_label = ""
local skip_count = 0  -- how many events to skip in bar display

local next_event = sbar.add("item", "next_event", {
  position = "right",
  icon = { string = "􀧞" },
  padding_left = 3,
  padding_right = 3,
  display = 2,
  update_freq = 60,
  updates = "on",
  popup = { height = 30, background = { border_width = 0 } },
})

-- Popup items for today's events
local event_items = {}
for i = 1, MAX_POPUP_EVENTS do
  event_items[i] = sbar.add("item", "next_event.e" .. i, {
    position = "popup.next_event",
    icon = {
      font = { family = settings.font.text, style = "Regular", size = 12.0 },
      width = 50,
      align = "right",
      color = colors.blue,
    },
    label = {
      font = { family = settings.font.text, style = "Regular", size = 12.0 },
      width = popup_width - 50,
      color = colors.white,
    },
    drawing = false,
  })
end

-- Open Calendar on Cmd+click
sbar.add("item", "next_event.open", {
  position = "popup.next_event",
  icon = { drawing = false },
  label = {
    string = "⌘+click to open Calendar",
    font = { family = settings.font.text, style = "Regular", size = 10.0 },
    color = colors.grey,
    align = "center",
    width = popup_width,
  },
  background = { height = 2, color = colors.grey, y_offset = 12 },
})

-- Skip/dismiss button
sbar.add("event", "next_event_skip")
sbar.add("item", "next_event.skip", {
  position = "popup.next_event",
  icon = { drawing = false },
  label = {
    string = "Next →",
    font = { family = settings.font.text, style = "Regular", size = 10.0 },
    color = colors.orange,
    align = "center",
    width = popup_width,
  },
  click_script = "sketchybar --set next_event popup.drawing=off; sketchybar --trigger next_event_skip",
})

local function truncate(s, max)
  if #s > max then return s:sub(1, max) .. "..." end
  return s
end

local function format_remaining(seconds, prefix)
  seconds = math.max(0, math.floor(seconds))
  local hours = math.floor(seconds / 3600)
  local mins = math.floor((seconds % 3600) / 60)
  if hours > 0 then
    return "•" .. prefix .. " " .. hours .. "hr " .. mins .. "min"
  else
    return "•" .. prefix .. " " .. mins .. "min"
  end
end

local function parse_timestamp(date_str, time_str)
  -- date_str: "2026-03-31", time_str: "19:00"
  local y, m, d = date_str:match("(%d+)-(%d+)-(%d+)")
  local hr, mn = time_str:match("(%d+):(%d+)")
  if not y or not hr then return nil end
  return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d),
                    hour = tonumber(hr), min = tonumber(mn), sec = 0 })
end

local function update_event()
  local cmd = 'icalBuddy -n -nc -ec "' .. EXCLUDE_CALENDARS .. '" -iep "datetime,title" -po "datetime,title" -ps "|^|" -tf "%H:%M" -df "%Y-%m-%d" -nrd -b "" -ea eventsToday+' .. LOOKAHEAD_DAYS .. ' 2>/dev/null'

  sbar.exec(cmd, function(result)
    result = result:gsub("%s+$", "")
    if result == "" or result:match("error:") then
      next_event:set({ label = { string = result:match("No calendars") and "No calendar access" or "" } })
      return
    end

    local now = os.time()
    local today = os.date("%Y-%m-%d")

    -- Collect all valid events sorted by start time
    local events = {}
    for line in result:gmatch("[^\n]+") do
      local datetime, title = line:match("^(.-)%^(.+)")
      if datetime and title then
        local date_str = datetime:match("^(%d%d%d%d%-%d%d%-%d%d)")
        local start_time = datetime:match("at (%d+:%d+)")
        local end_time = datetime:match("- (%d+:%d+)")

        if date_str and start_time then
          local start_sec = parse_timestamp(date_str, start_time)
          local end_sec = end_time and parse_timestamp(date_str, end_time) or (start_sec and start_sec + 3600)

          if start_sec and end_sec then
            local event_type = nil
            if start_sec <= now and end_sec > now then
              event_type = "current"
            elseif start_sec > now then
              local event_date = os.date("%Y-%m-%d", start_sec)
              local hours_until = (start_sec - now) / 3600
              -- Show all future events when skipping, otherwise limit to today or 10hr
              if skip_count > 0 or event_date == today or hours_until <= 10 then
                event_type = "next"
              end
            end
            if event_type then
              table.insert(events, { type = event_type, title = title, start = start_sec, ends = end_sec })
            end
          end
        end
      end
    end

    -- Sort: current events first, then by start time
    table.sort(events, function(a, b)
      if a.type == "current" and b.type ~= "current" then return true end
      if a.type ~= "current" and b.type == "current" then return false end
      return a.start < b.start
    end)

    -- Pick event based on skip_count
    local idx = skip_count + 1
    if idx > #events then idx = #events end
    local best = events[idx]

    if not best then
      next_event:set({ label = { string = "" }, drawing = false })
      last_short_label = ""
      last_full_label = ""
      return
    end

    local best_type = best.type
    local best_title = best.title
    local best_start = best.start
    local best_end = best.ends

    local short_label, full_label
    if best_type == "current" then
      local left = best_end - now
      short_label = "•" .. math.floor(left / 60) .. "min left"
      full_label = truncate(best_title, MAX_TITLE) .. " " .. short_label
    else
      local until_start = best_start - now
      short_label = format_remaining(until_start, "in")
      full_label = truncate(best_title, MAX_TITLE) .. " " .. short_label
    end

    last_short_label = short_label
    last_full_label = full_label
    -- Show collapsed by default
    next_event:set({ label = { string = short_label }, drawing = true })
  end)
end

next_event:subscribe({ "routine", "forced", "system_woke" }, function()
  update_event()
end)

-- Hover: expand to show full title
next_event:subscribe("mouse.entered", function()
  if last_full_label and last_full_label ~= "" then
    next_event:set({ label = { string = last_full_label } })
  end
end)

next_event:subscribe("mouse.exited", function()
  if last_short_label and last_short_label ~= "" then
    next_event:set({ label = { string = last_short_label } })
  end
end)

-- Click: show today's events, Cmd+click opens Calendar
next_event:subscribe("mouse.clicked", function(env)
  if env.MODIFIER == "cmd" then
    sbar.exec("open -a Calendar")
    return
  end

  -- Fetch all today's events for popup
  local cmd = 'icalBuddy -n -nc -ec "' .. EXCLUDE_CALENDARS .. '" -iep "datetime,title" -po "datetime,title" -ps "|^|" -tf "%H:%M" -df "%Y-%m-%d" -nrd -b "" -ea eventsToday+1 2>/dev/null'

  sbar.exec(cmd, function(result)
    result = result:gsub("%s+$", "")

    -- Hide all popup items first
    for i = 1, MAX_POPUP_EVENTS do
      event_items[i]:set({ drawing = false })
    end

    if result == "" then
      event_items[1]:set({
        drawing = true,
        icon = { string = "" },
        label = { string = "No events today", color = colors.grey },
      })
      next_event:set({ popup = { drawing = "toggle" } })
      return
    end

    local now = os.time()
    local today = os.date("%Y-%m-%d")
    local last_date = ""
    local i = 1
    for line in result:gmatch("[^\n]+") do
      if i > MAX_POPUP_EVENTS then break end
      local datetime, title = line:match("^(.-)%^(.+)")
      if datetime and title then
        local start_time = datetime:match("at (%d+:%d+)")
        local end_time = datetime:match("- (%d+:%d+)")
        local date_str = datetime:match("^(%d%d%d%d%-%d%d%-%d%d)")

        if start_time and date_str then
          -- Insert day header when date changes
          if date_str ~= last_date and i <= MAX_POPUP_EVENTS then
            local day_label = date_str == today and "Today" or "Tomorrow"
            event_items[i]:set({
              drawing = true,
              icon = { string = "—", color = colors.grey },
              label = { string = day_label, color = colors.orange,
                font = { family = settings.font.text, style = "Bold", size = 12.0 } },
            })
            last_date = date_str
            i = i + 1
            if i > MAX_POPUP_EVENTS then break end
          end

          local time_display = start_time
          if end_time then time_display = start_time .. "-" .. end_time end

          -- Color: past events grey, current green, future white
          local start_sec = parse_timestamp(date_str, start_time)
          local end_sec = end_time and parse_timestamp(date_str, end_time) or (start_sec + 3600)
          local label_color = colors.white
          local time_color = colors.blue
          if start_sec and end_sec then
            if end_sec < now then
              label_color = colors.grey
              time_color = colors.grey
            elseif start_sec <= now then
              label_color = colors.green
              time_color = colors.green
            end
          end

          event_items[i]:set({
            drawing = true,
            icon = { string = time_display, color = time_color },
            label = { string = title, color = label_color,
              font = { family = settings.font.text, style = "Regular", size = 12.0 } },
          })
          i = i + 1
        end
      end
    end

    next_event:set({ popup = { drawing = "toggle" } })
  end)
end)

next_event:subscribe("mouse.exited.global", function()
  next_event:set({ popup = { drawing = false } })
end)

-- Next: skip to show the next event in bar (popup still shows all)
next_event:subscribe("next_event_skip", function()
  skip_count = skip_count + 1
  update_event()
end)

update_event()
