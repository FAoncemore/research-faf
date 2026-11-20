--UI switch for Exp alert
ExpAlert = false

-- Cooldown settings
local ExpVoiceCooldown = 10
local LastExpVoiceTime = 0

-- Create a lookup table
local EXPvoiceLookup = {
    uel0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04179'},
    ues0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04180'},
    ueb2401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04181'},
    url0402 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04182'},
    ura0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04183'},
    url0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04184'},
    ual0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04185'},
    uaa0310 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04186'},
    uas0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04187'},
    xab1401 = Sound {Bank = 'X06_VO', Cue = 'X06_HQ_M02_04491'},
    xsl0401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04188'},
    xsa0402 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04189'},
    xsb2401 = Sound {Bank = 'XGG', Cue = 'XGG_HQ_GD1_04190'},
}

-- Function using lookup
function ExpDetected(data)
    if ExpAlert == true then
	    local soundToPlay = EXPvoiceLookup[data[2]]
		if soundToPlay then
		    PlayVoice(soundToPlay)
		else
		    -- fallback sound
			PlayVoice(Sound({Bank = 'X06_VO', Cue = 'X06_Fletcher_T01_04805'}))
		end
	end
end

function ArtilleryDestory()
    local now = GetSystemTimeSeconds()

    -- cooldown check
    if (now - LastExpVoiceTime) < ExpVoiceCooldown then
        return
    end

    LastExpVoiceTime = now
	
	PlayVoice(Sound({Cue = 'XGG_HQ_GD1_04199', Bank = 'XGG'}))
end
