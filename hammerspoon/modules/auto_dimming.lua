-- modules/auto_dimming.lua
-- Auto-dims monitors that haven't been active based on mouse position and window focus.

local autoDimming = {}

-- Configuration
local bdPath = "/opt/homebrew/bin/BetterDisplaycli"
local idleThresholdFirst = 300 -- Seconds before first dim (to 60%)
local idleThresholdSecond = 1200 -- Seconds before second dim (to 0%)
local activeBrightness = 1
local firstDimBrightness = 0.6 -- First dim level (60%)
local secondDimBrightness = 0 -- Second dim level (0%)
local checkInterval = 2 -- How often to check for idle screens (seconds)

-- Monitor State Tracking
-- dimLevel: 0 = active, 1 = first dim (60%), 2 = second dim (0%)
local monitors = {
    ["HP E24u G4"] = { lastActive = os.time(), dimLevel = 0 },
    ["S24C31x"]    = { lastActive = os.time(), dimLevel = 0 }
}

-- Helper to run BetterDisplay commands asynchronously
local function setBrightness(name, level)
    hs.task.new(bdPath, nil, {"set", "-name=" .. name, "-brightness=" .. tostring(level)}):start()
end

-- Get filtered system assertions (only the relevant block, excluding verbose USB hub output)
-- This filters out the massive list of Kernel Assertions from USB hubs and peripherals
local function getSystemAssertions()
    -- Use sed to get only the relevant block between "Assertion status system-wide" 
    -- and "Listed by owning process", excluding the header line
    local cmd = 'pmset -g assertions | sed -n "/Assertion status system-wide/,/Listed by owning process/p" | sed "$d"'
    local success, output = hs.execute(cmd)
    if not success or type(output) ~= "string" then
        return nil
    end
    return output
end

-- Check for video playback (pmset assertion)
-- Checks for UserIsActive or PreventUserIdleDisplaySleep assertions
-- These are typically active when video is playing or user is actively interacting
-- Uses filtered output for better performance (avoids parsing massive USB hub assertion lists)
local function isVideoPlaying()
    local output = getSystemAssertions()
    if not output then
        return false
    end
    -- Check for UserIsActive assertion (indicates active user interaction/video)
    local userIsActive = output:match("UserIsActive%s+1")
    -- Check for PreventUserIdleDisplaySleep assertion (prevents display sleep during video)
    local preventDisplaySleep = output:match("PreventUserIdleDisplaySleep%s+1")
    
    return userIsActive ~= nil or preventDisplaySleep ~= nil
end

-- Wake up the current screen (called on mouse movement or focus change)
local function wakeCurrentScreen()
    local currentScreen = hs.mouse.getCurrentScreen()
    if not currentScreen then return end
    
    local name = currentScreen:name()
    local data = monitors[name]

    if data then
        data.lastActive = os.time() -- Mark this screen as active NOW
        if data.dimLevel > 0 then
            setBrightness(name, activeBrightness)
            data.dimLevel = 0
        end
    end
end

-- The idle dimmer timer (runs periodically to check and dim idle screens)
local function checkAndDimIdleScreens()
    -- Skip dimming if video is playing anywhere
    if isVideoPlaying() then 
        for name, data in pairs(monitors) do
            if data.dimLevel > 0 then
                setBrightness(name, activeBrightness)
                data.dimLevel = 0
            end
            data.lastActive = os.time()
        end
        return 
    end

    local now = os.time()
    for name, data in pairs(monitors) do
        local secondsIdle = os.difftime(now, data.lastActive)
        
        -- Two-step dimming process
        if secondsIdle > idleThresholdSecond and data.dimLevel < 2 then
            -- Second dim: dim to 0%
            setBrightness(name, secondDimBrightness)
            data.dimLevel = 2
        elseif secondsIdle > idleThresholdFirst and data.dimLevel < 1 then
            -- First dim: dim to 60%
            setBrightness(name, firstDimBrightness)
            data.dimLevel = 1
        end
    end
end

function autoDimming:start()
    -- Watch mouse movement (primary trigger)
    self.mouseWatcher = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(event)
        wakeCurrentScreen()
        return false -- Do not block the event
    end)
    self.mouseWatcher:start()

    -- Watch window focus changes (backup trigger for keyboard navigation)
    self.windowWatcher = hs.window.filter.new():subscribe(hs.window.filter.windowFocused, function(window)
        -- Wake the screen where the focused window is located
        if window then
            local screen = window:screen()
            if screen then
                local name = screen:name()
                local data = monitors[name]
                if data then
                    data.lastActive = os.time()
                    if data.dimLevel > 0 then
                        setBrightness(name, activeBrightness)
                        data.dimLevel = 0
                    end
                end
            end
        end
        -- Also wake current mouse screen as backup
        wakeCurrentScreen()
    end)

    -- Start the idle checker timer
    self.idleTimer = hs.timer.doEvery(checkInterval, checkAndDimIdleScreens)
    
    -- Initial check
    checkAndDimIdleScreens()
    
    local monitorNames = {}
    for name, _ in pairs(monitors) do
        table.insert(monitorNames, name)
    end
    print("✅ Auto-dimming enabled for monitors: " .. table.concat(monitorNames, ", "))
end

function autoDimming:stop()
    if self.mouseWatcher then
        self.mouseWatcher:stop()
        self.mouseWatcher = nil
    end
    
    if self.windowWatcher then
        self.windowWatcher:unsubscribeAll()
        self.windowWatcher = nil
    end
    
    if self.idleTimer then
        self.idleTimer:stop()
        self.idleTimer = nil
    end
    
    -- Restore brightness on all monitors and reset dim levels
    for name, data in pairs(monitors) do
        setBrightness(name, activeBrightness)
        data.dimLevel = 0
    end
    
    print("⏸️ Auto-dimming stopped.")
end

-- Expose getSystemAssertions for debugging purposes
-- Usage in Hammerspoon console: autoDimming.getSystemAssertions()
function autoDimming.getSystemAssertions()
    return getSystemAssertions()
end

return autoDimming

