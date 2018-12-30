--
-- Adjust values for given parameter
--

--
-- Sakura as Hanata
-- October 27, 2018 @ HackOHI/O
-- Discontinued due to AdjustGain (changes dynamics) and PartDetune (changes pitch) existing in official list of Job Plugins. Instead, a ResetValues plugin (to reset all parameter values) and plugins to adjust other unlisted parameters will replace this plugin. - December 29, 2018
--

--
-- Manifest
--
function manifest()
    myManifest = {
        name          = "Value Manipulation",
        comment       = "Change all values in a part",
        author        = "Hanata",
        pluginID      = "{6b01f629-972a-47f4-be22-06412440a448}", --GUID or UUID
        pluginVersion = "1.0",
        apiVersion    = "3.0.1.0"
    }
    
    return myManifest
end
-- Dialog boxes
paramList = {
    name = "param",
    caption = "Choose param to adjust:",
    initialVal = "Velocity, Dynamics, Breathiness, Brightness, Clearness, Opening, Gender Factor, Portamento Timing, Cross-Synthesis, Growl, Pitch Bend, Pitch Bend Sensitivity",
    type = 4
}
defaultVal = {
    name = "values",
    caption = "Choose value of adjustment (0 to 127)",
    initialVal = "0",
    type = 0
}
captionBox = {
    name = "caption"
}
pitchVal = {
    name = "values",
    caption = "Choose value of adjustment (-8192 to 8191)",
    initialVal = "0",
    type = 0
}
pbsVal = {
    name = "values",
    caption = "Choose value of adjustment (0 to 24)",
    initialVal = "2",
    type = 0
}
doWhat = {
    name = "dowhat",
    caption = "Option",
    initialVal = "Set to this value, Add this to current value, Subtract this from current value",
    type = 4
}
--
-- DIALOGUE BOXES
--
-- dialog box for selecting parameter
function chooseParam()
    -- Dialogue window
    VSDlgSetDialogTitle("Value Adjustment")
	dlgStatus  = VSDlgAddField(paramList)
	dlgStatus = VSDlgDoModal()
	if (dlgStatus == 2) then
		-- When it was cancelled.
		return -1
	end
	if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
		-- When it returned an error.
		return -1
	end
    
    dlgStatus, param = VSDlgGetStringValue("param")
    
    return param
end
-- dialog box for setting values - default
function chooseValueDef(par)
    -- Dialogue window
    VSDlgSetDialogTitle("Value Set - " .. par)
    if(par == "Opening") then
        defaultVal.initialVal = "127"
    elseif(par == "Breathiness" or par == "Clearness"  or par == "Cross-Synthesis"  or par == "Growl") then
        defaultVal.initialVal = "0"
    else
        defaultVal.initialVal = "64"
    end
	dlgStatus  = VSDlgAddField(defaultVal)
	dlgStatus  = VSDlgAddField(doWhat)
	dlgStatus = VSDlgDoModal()
	if (dlgStatus == 2) then
		-- When it was cancelled.
		return -1, -1
	end
	if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
		-- When it returned an error.
		return -1, -1
	end
    
    dlgStatus, val = VSDlgGetIntValue("values")
    dlgStatus, action = VSDlgGetStringValue("dowhat")
    
    return val, action
end
-- dialog box for setting values - pitch
function chooseValuePit()
    -- Dialogue window
    VSDlgSetDialogTitle("Value Set - Pitchbend")
	dlgStatus  = VSDlgAddField(pitchVal)
	dlgStatus  = VSDlgAddField(doWhat)
	dlgStatus = VSDlgDoModal()
	if (dlgStatus == 2) then
		-- When it was cancelled.
		return -1, -1
	end
	if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
		-- When it returned an error.
		return -1, -1
	end
    
    dlgStatus, val = VSDlgGetIntValue("values")
    dlgStatus, action = VSDlgGetStringValue("dowhat")
    
    return val, action
end
-- dialog box for setting values - PBS
function chooseValuePbs()
    -- Dialogue window
    VSDlgSetDialogTitle("Value Set - PBS")
	dlgStatus  = VSDlgAddField(pbsVal)
	dlgStatus  = VSDlgAddField(doWhat)
    dlgStatus = VSDlgDoModal()
	if (dlgStatus == 2) then
		-- When it was cancelled.
		return -1, -1
	end
	if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
		-- When it returned an error.
		return -1, -1
	end
    
    dlgStatus, val = VSDlgGetIntValue("values")
    dlgStatus, action = VSDlgGetStringValue("dowhat")
    
    return val, action
end
--
-- VALUE ADJUSTMENT FUNCTIONS
--
function changeVelOpe(processParam, envParam, adjParam, adjValue, adjOption)
    -- Variables
    local note      -- current note
    local noteCount -- total notes in part
    local noteList = {} -- holds all notes
    local k         -- counter
    local opt
    local max
    local min

    -- get list of notes
    k = 1
    local noteList = {}
    VSSeekToBeginNote()
    retCode, note = VSGetNextNoteEx()
    while (retCode == 1) do
        noteList[k] = note
        k = k + 1
        retCode, note = VSGetNextNoteEx()
    end
    
	noteCount = k - 1
    
    -- Decide what to do with note
    if(adjOption == "Add this to current value") then
        opt = adjValue
    elseif(adjOption == "Subtract this from current value") then
        opt = 0 - adjValue
    else --Set to this value
        opt = 0
    end

    -- loop through musical part until you're done
    if (adjParam == "Velocity") then
        for k = 1, noteCount do
            if (opt ~= 0) then
                noteList[k].velocity = noteList[k].velocity + opt
            else
                noteList[k].velocity = adjValue
            end
            retCode = VSUpdateNoteEx(noteList[k])
            if (retCode == 0) then
                VSMessageBox("Cannot update notes!", 0)
                break
            end
        end
    else -- adjParam == "Opening"
        for k = 1, noteCount do
            if (opt ~= 0) then
                noteList[k].opening = noteList[k].opening + opt
            else
                noteList[k].opening = adjValue
            end
            retCode = VSUpdateNoteEx(noteList[k])
            if (retCode == 0) then
                VSMessageBox("Cannot update notes!", 0)
                break
            end
        end
    end
end

function changePit(processParam, envParam, adjParam, adjValue, adjOption)
    -- Variables
    local opt
    local max
    local min
    
	local beginPosTick = processParam.beginPosTick
	local endPosTick   = processParam.endPosTick
	local songPosTick  = processParam.songPosTick
    
    local retCode
    local pit = {}
    
    -- Decide what to do with note
    if(adjOption == "Add this to current value") then
        opt = adjValue
    elseif(adjOption == "Subtract this from current value") then
        opt = 0 - adjValue
    else --Set to this value
        opt = 0
    end
    
    retCode = VSSeekToBeginControl("PIT")
    retCode, pit = VSGetNextControl("PIT")
    while (retCode == 1) do
        retCode = VSRemoveControl(pit)
        -- adjust pitch as necessary
        if (opt ~= 0) then
            pit.value = pit.value + opt
        else
            pit.value = adjValue
        end
        retCode = VSInsertControl(pit)
        -- go on to next pitch
		retCode_Pit, pit = VSGetNextControl("PIT")
    end
end
-- 
-- Main Function
--
function main(processParam, envParam)
    -- Variables
    local adjParam
    local adjValue
    local adjOption

    -- select parameter to adjust
    adjParam = chooseParam()
    
    if(string.len(adjParam) < 3) then
        return 0
    end
    
    -- depending on what it is, pop up a different dialog box
    if(adjParam == "Pitch Bend") then
        adjValue, adjOption = chooseValuePit()
    elseif(adjParam == "Pitch Bend Sensitivity") then
        adjValue, adjOption = chooseValuePbs()
    else
        adjValue, adjOption = chooseValueDef(adjParam)
    end
    
    if(adjValue < 0) then
        return 0
    end
    
    -- now adjust the values accordingly
    if(adjParam == "Velocity" or adjParam == "Opening") then
        changeVelOpe(processParam, envParam, adjParam, adjValue, adjOption)
    elseif(adjParam == "Pitch Bend") then
        changePit(processParam, envParam, adjParam, adjValue, adjOption)
    elseif(adjParam == "Pitch Bend Sensitivity") then
        --
    else
        adjValue, adjOption = chooseValueDef(adjParam)
    end
    
end
