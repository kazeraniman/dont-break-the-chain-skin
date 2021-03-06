--- Rainmeter function which is run when the skin is activated or refreshed.
-- Ensures that the started timestamp and date are set and sets them if this is not the case.
function Initialize()
    -- Global constant setup
    SECONDS_PER_DAY = 60 * 60 * 24
    MONTHS = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    }
    DAYS_PER_MONTH = {
        January=31,
        February=28,
        March=31,
        April=30,
        May=31,
        June=30,
        July=31,
        August=31,
        September=30,
        October=31,
        November=30,
        December=31
    }
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
    -- Get the current day timestamp
    local now = os.date("*t")
    local startedTimestamp = os.time{day=now.day, month=now.month, year=now.year, hour=0, min=0, sec=0}
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
    -- Hide the special warning meter which doesn't belong to a group
    SKIN:Bang("!HideMeter", "FutureDateWarning")
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
    -- Set the default set date as today
    local now = os.date("*t")
    setMonth = now.month
    setDay = now.day
    setYear = now.year
    -- Update the text meters with today's date
    SKIN:Bang("!SetOption", "SetDateMonthTextMeter", "Text", MONTHS[setMonth])
    SKIN:Bang("!SetOption", "SetDateDayTextMeter", "Text", setDay)
    SKIN:Bang("!SetOption", "SetDateYearTextMeter", "Text", setYear)
    -- Draw the updated results
    SKIN:Bang("!Update")
end

--- Enables reset mode and disables other modes.
function enableResetMode()
    -- Show / hide the needed meter groups
    SKIN:Bang("!HideMeterGroup", "MainMode")
    SKIN:Bang("!HideMeterGroup", "SetMode")
    SKIN:Bang("!ShowMeterGroup", "ResetMode")
    -- Hide the special warning meter which doesn't belong to a group
    SKIN:Bang("!HideMeter", "FutureDateWarning")
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
        SKIN:Bang("!SetOption", "FutureDateWarning", "Y", 285);
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
        SKIN:Bang("!SetOption", "FutureDateWarning", "Y", 0);
    end
end

--- Move backward along the table of months, wrapping around if necessary.
function handleSetDateMonthUpButton()
    -- Move backward one month
    setMonth = setMonth - 1
    -- Wrap around if we were on January before
    if setMonth == 0 then
        setMonth = 12
    end
    -- Accomodate non-leap years
    limitSetDateOnNonLeapYear()
    -- Check if the requested started date is valid
    isSetDateInFuture()
    -- Update the text
    SKIN:Bang("!SetOption", "SetDateMonthTextMeter", "Text", MONTHS[setMonth])
    -- Draw the updates
    SKIN:Bang("!Update")
end

--- Move forward along the table of months, wrapping around if necessary.
function handleSetDateMonthDownButton()
    -- Move forward one month
    setMonth = setMonth + 1
    -- Wrap around if we were on December before
    if setMonth == 13 then
        setMonth = 1
    end
    -- Accomodate non-leap years
    limitSetDateOnNonLeapYear()
    -- Check if the requested started date is valid
    isSetDateInFuture()
    -- Update the text
    SKIN:Bang("!SetOption", "SetDateMonthTextMeter", "Text", MONTHS[setMonth])
    -- Draw the updates
    SKIN:Bang("!Update")
end

--- Move backward along the days of the month, wrapping around if necessary.
function handleSetDateDayUpButton()
    -- Move backward one day
    setDay = setDay - 1
    -- Wrap around if we were on the first before
    local extraDay = 0
    if setMonth == 2 and isLeapYear(setYear) then
        extraDay = 1
    end
    if setDay == 0 then
        setDay = DAYS_PER_MONTH[MONTHS[setMonth]] + extraDay
    end
    -- Check if the requested started date is valid
    isSetDateInFuture()
    -- Update the text
    SKIN:Bang("!SetOption", "SetDateDayTextMeter", "Text", setDay)
    -- Draw the updates
    SKIN:Bang("!Update")
end

--- Move forward along the days of the month, wrapping around if necessary.
function handleSetDateDayDownButton()
    -- Move forward one day
    setDay = setDay + 1
    -- Wrap around if we were on the last of the month before
    local extraDay = 0
    if setMonth == 2 and isLeapYear(setYear) then
        extraDay = 1
    end
    if setDay == DAYS_PER_MONTH[MONTHS[setMonth]] + extraDay + 1 then
        setDay = 1
    end
    -- Check if the requested started date is valid
    isSetDateInFuture()
    -- Update the text
    SKIN:Bang("!SetOption", "SetDateDayTextMeter", "Text", setDay)
    -- Draw the updates
    SKIN:Bang("!Update")
end

--- Move backward along the years, constrained to the first year.
function handleSetDateYearUpButton()
    -- Move backward one year
    setYear = setYear - 1
    -- Don't go further back than year 1
    if setYear == 0 then
        setYear = 1
    end
    -- Accomodate non-leap years
    limitSetDateOnNonLeapYear()
    -- Check if the requested started date is valid
    isSetDateInFuture()
    -- Update the text
    SKIN:Bang("!SetOption", "SetDateYearTextMeter", "Text", setYear)
    -- Draw the updates
    SKIN:Bang("!Update")
end

--- Move forward along the years, constrained to the current year.
function handleSetDateYearDownButton()
    -- Move forward one day
    setYear = setYear + 1
    -- Don't go past the current year
    local currentYear = os.date("*t")["year"]
    if setYear == currentYear + 1 then
        setYear = currentYear
    end
    -- Accomodate non-leap years
    limitSetDateOnNonLeapYear()
    -- Check if the requested started date is valid
    isSetDateInFuture()
    -- Update the text
    SKIN:Bang("!SetOption", "SetDateYearTextMeter", "Text", setYear)
    -- Draw the updates
    SKIN:Bang("!Update")
end

--- Updates the StartedTimestamp and StartedDate in both Rainmeter and the persisted files by setting them to the selected values.
function handleConfirmSetButton()
    -- Create a timestamp for the selected date
    local startedTimestamp = os.time{day=setDay, month=setMonth, year=setYear, hour=0, min=0, sec=0}
    -- Get the human-readable date
    local startedDate = getFormattedDate(startedTimestamp)
    -- Update the values in Rainmeter and the persisted files
    setStartedTimestamp(startedTimestamp)
    setStartedDate(startedDate)
    -- Go back to main mode
    enableMainMode()
    -- Update the skin
    SKIN:Bang("!Update")
end

--- Determines whether or not the provided year is a leap year.
-- @param year number: The year to check.
-- @return boolean: True if the year is a leap year, false otherwise.
function isLeapYear(year)
    if (year % 400 == 0) or ((year % 4 == 0) and (year % 100 ~= 0)) then
        return true
    else
        return false
    end
end

--- Changes the set day from the 29th to the 28th of February in the event that it is not a leap year.
function limitSetDateOnNonLeapYear()
    -- If the set day is the 29th of February of a non-leap year, drop the day to the 28th
    if setDay == 29 and setMonth == 2 and not isLeapYear(setYear) then
        -- Change the day
        setDay = 28
        -- Update the text
        SKIN:Bang("!SetOption", "SetDateDayTextMeter", "Text", setDay)
        -- Draw the updates
        SKIN:Bang("!Update")
    end
end

--- Displays a warning if in set mode and the date is in the future, otherwise allowing the user to confirm
-- the selected date.
function isSetDateInFuture()
    -- Get the current timestamp
    local now = os.time()
    -- Get the set date timestamp
    local setDateTimestamp = os.time{day=setDay, month=setMonth, year=setYear, hour=0, min=0, sec=0}
    -- Compare the timestamps
    local isFuture = os.difftime(now, setDateTimestamp) < 0
    -- Display the correct meter depending on whether the set date is valid
    if not isFuture then
        SKIN:Bang("!HideMeter", "FutureDateWarning")
        SKIN:Bang("!ShowMeter", "ConfirmSetButtonMeter")
    else
        SKIN:Bang("!HideMeter", "ConfirmSetButtonMeter")
        SKIN:Bang("!ShowMeter", "FutureDateWarning")
    end
end
