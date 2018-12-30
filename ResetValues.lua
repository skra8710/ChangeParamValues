--
-- Reset values for given parameter
--

--
-- Sakura, December 29, 2018 - In Progress
--

--
-- Manifest
--
function manifest()
    myManifest = {
        name          = "Reset Values",
        comment       = "Resets values of parameter",
        author        = "Hanata",
        pluginID      = "{b68b5e7c-7c83-48ee-902d-1ae0a6d0a455}", --GUID or UUID
        pluginVersion = "1.0",
        apiVersion    = "3.0.1.0"
    }
    
    return myManifest
end

-- Dialog box
dialogueBox = {
    name = "param",
    caption = "Select parameter to reset",
    initialVal = "Select All, Velocity, Dynamics, Breathiness, Brightness, Clearness, Opening, Gender Factor, Portamento Timing, Cross-Synthesis, Growl, Pitch Bend, Pitch Bend Sensitivity",
    type = 4
}

-- 
-- Main Values
--
function main(processParam, envParam)
    -- initialize variables
    -- pop dialogue box
    -- determine selection
    -- reset values of given selection
    -- return code
end
