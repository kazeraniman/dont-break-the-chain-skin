--- Rainmeter function which is run when the skin is activated or refreshed.
-- Ensures that the started timestamp and date are set and sets them if this is not the case.
function Initialize()
    -- Global constant setup
    SECONDS_PER_DAY = 60 * 60 * 24
    -- Get the comparison values from Rainmeter
    local startedTimestamp = SKIN:GetVariable("StartedTimestamp")
    local startedDate = SKIN:GetVariable("StartedDate")
    -- Check if there is a started timestamp which already exists
    if not startedTimestamp then
        -- No started timestamp, so we should set it to now
        setCurrentAsStarted()
    -- Check if there is a started date which already exists
    elseif not startedDate then
        -- Set the date to the timestamp which we have
        setStartedDate(getFormattedDate(tonumber(startedTimestamp)))
    end
    -- Start in main mode
    enableMainMode()
end

--- Rainmeter function which is run whenever script measure updates.
-- Updates the chain counter and the date
function Update()
    -- Update the chain counter text
    applyDayCount()
    -- Update the date started text
    applyDateStarted()
end

--- Updates the StartedTimestamp and StartedDate in both Rainmeter and the persisted files by setting them to the current values.
function setCurrentAsStarted()
    -- Get the current timestamp
    local startedTimestamp = os.time()
    -- Get the human-readable date
    local startedDate = getFormattedDate(startedTimestamp)
    -- Update the values in Rainmeter and the persisted files
    setStartedTimestamp(startedTimestamp)
    setStartedDate(startedDate)
end

--- Updates the StartedTimestamp in both Rainmeter and the persisted files.
-- @param startedTimestamp string: The seconds since the epoch representing the started time.
function setStartedTimestamp(startedTimestamp)
    -- Update the values in Rainmeter
    SKIN:Bang("!SetVariable", "StartedTimestamp", startedTimestamp)
    -- Update the values in the data file
    SKIN:Bang("!WriteKeyValue", "Variables", "StartedTimestamp", startedTimestamp, "#@#/User/data.inc")
end

--- Updates the StartedDate in both Rainmeter and the persisted files.
-- @param startedDate string: A formatted date representing the started date.
function setStartedDate(startedDate)
    -- Update the values in Rainmeter
    SKIN:Bang("!SetVariable", "StartedDate", startedDate)
    -- Update the values in the data file
    SKIN:Bang("!WriteKeyValue", "Variables", "StartedDate", startedDate, "#@#/User/data.inc")
end

--- Formats a timestamp into the intended date format.
-- @param timestamp time: A time since the epoch.
-- @return string: A formatted date generated from the timestamp.
function getFormattedDate(timestamp)
    return os.date("%B %d, %Y", timestamp)
end

--- Sets the value of the started date in the skin
function applyDateStarted()
    local startedDate = SKIN:GetVariable("StartedDate")
    local textDate = "(" .. startedDate .. ")"
    SKIN:Bang("!SetOption", "DateStartedTextMeter", "Text", textDate)
end

--- Determines the difference in days between the current time and the started timestamp then sets the value in the skin
function applyDayCount()
    -- Get the two timestamps
    local startedTimestamp = SKIN:GetVariable("StartedTimestamp")
    local currentTime = os.time()
    -- Determine the difference in days
    local timeDifference = os.difftime(currentTime, startedTimestamp)
    local differenceInDays = math.floor(timeDifference/SECONDS_PER_DAY)
    local formattedDayCount = tostring(differenceInDays) .. " " .. (differenceInDays == 1 and "Day" or "Days")
    -- Update the value in the skin
    SKIN:Bang("!SetOption", "DayCountTextMeter", "Text", formattedDayCount)
end

--- Called when the reset action has been confirmed.
-- Resets the values for the started timestamp and date and notifies the skin to update
function handleConfirmResetButton()
    -- Update the values
    setCurrentAsStarted()
    -- Go back to main mode
    enableMainMode()
end

--- Enables main mode and disables other modes..
function enableMainMode()
    -- Show / hide the needed meter groups
    SKIN:Bang("!HideMeterGroup", "SetMode")
    SKIN:Bang("!HideMeterGroup", "ResetMode")
    SKIN:Bang("!ShowMeterGroup", "MainMode")
    -- Resize the skin background accordingly
    SKIN:Bang("!SetOption", "Background", "H", 200)
    -- Move the mode-specific elements to their appropriate positions
    positionSetModeControls(false)
    positionResetModeControls(false)
    -- Draw the updated results
    SKIN:Bang("!Update")
end

--- Enables set mode and disables other modes.
function enableSetMode()
    -- Show / hide the needed meter groups
    SKIN:Bang("!HideMeterGroup", "MainMode")
    SKIN:Bang("!HideMeterGroup", "ResetMode")
    SKIN:Bang("!ShowMeterGroup", "SetMode")
    -- Resize the skin background accordingly
    SKIN:Bang("!SetOption", "Background", "H", 320)
    -- Move the mode-specific elements to their appropriate positions
    positionSetModeControls(true)
    positionResetModeControls(false)
    -- Draw the updated results
    SKIN:Bang("!Update")
end

--- Enables reset mode and disables other modes.
function enableResetMode()
    -- Show / hide the needed meter groups
    SKIN:Bang("!HideMeterGroup", "MainMode")
    SKIN:Bang("!HideMeterGroup", "SetMode")
    SKIN:Bang("!ShowMeterGroup", "ResetMode")
    -- Resize the skin background accordingly
    SKIN:Bang("!SetOption", "Background", "H", 277)
    -- Move the mode-specific elements to their appropriate positions
    positionResetModeControls(true)
    positionSetModeControls(false)
    -- Draw the updated results
    SKIN:Bang("!Update")
end

--- Position the reset-specific controls depending on the mode in order to avoid over-large skin
-- sizes relative to the visible controls.
-- @param activePosition boolean: Whether or not the controls should be placed in their correct,
-- mode is active positions.
function positionResetModeControls(activePosition)
    if activePosition then
        SKIN:Bang("!SetOption", "ResetWarningTextMeter", "Y", 202);
        SKIN:Bang("!SetOption", "ConfirmResetButtonMeter", "Y", 234);
    else
        SKIN:Bang("!SetOption", "ResetWarningTextMeter", "Y", 0);
        SKIN:Bang("!SetOption", "ConfirmResetButtonMeter", "Y", 0);
    end
end

--- Position the set-specific controls depending on the mode in order to avoid over-large skin
-- sizes relative to the visible controls.
-- @param activePosition boolean: Whether or not the controls should be placed in their correct,
-- mode is active positions.
function positionSetModeControls(activePosition)
    if activePosition then
        SKIN:Bang("!SetOption", "SetDateBackgroundBlocksShapeMeter", "Y", 222);
        SKIN:Bang("!SetOption", "SetDateMonthTextMeter", "Y", 223);
        SKIN:Bang("!SetOption", "SetDateDayTextMeter", "Y", 223);
        SKIN:Bang("!SetOption", "SetDateYearTextMeter", "Y", 223);
        SKIN:Bang("!SetOption", "SetDateMonthUpButtonMeter", "Y", 200);
        SKIN:Bang("!SetOption", "SetDateDayUpButtonMeter", "Y", 200);
        SKIN:Bang("!SetOption", "SetDateYearUpButtonMeter", "Y", 200);
        SKIN:Bang("!SetOption", "SetDateMonthDownButtonMeter", "Y", 254);
        SKIN:Bang("!SetOption", "SetDateDayDownButtonMeter", "Y", 254);
        SKIN:Bang("!SetOption", "SetDateYearDownButtonMeter", "Y", 254);
        SKIN:Bang("!SetOption", "ConfirmSetButtonMeter", "Y", 277);
    else
        SKIN:Bang("!SetOption", "SetDateBackgroundBlocksShapeMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateMonthTextMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateDayTextMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateYearTextMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateMonthUpButtonMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateDayUpButtonMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateYearUpButtonMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateMonthDownButtonMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateDayDownButtonMeter", "Y", 0);
        SKIN:Bang("!SetOption", "SetDateYearDownButtonMeter", "Y", 0);
        SKIN:Bang("!SetOption", "ConfirmSetButtonMeter", "Y", 0);
    end
end
