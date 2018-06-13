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
    --[[
    Updates the StartedTimestamp in both Rainmeter and the persisted files.
    ]]--
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

--- Called when the reset button is pressed on the skin.
-- Resets the values for the started timestamp and date and notifies the skin to update
function handleResetButton()
    -- Update the values
    setCurrentAsStarted()
    -- Draw the updated values
    SKIN:Bang("!Update")
end
