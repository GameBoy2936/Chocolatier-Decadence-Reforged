--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (World Map View)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

gCurrentModal = "mapview"

------------------------------------------------------------------------------
-- Navigation
------------------------------------------------------------------------------

-- Toggles between the global map and the interior of the current local port
function SwapMapPortScreens()
	if gTravelActive then return end
	
	if Player.portName ~= "enroute" then
		DebugOut("UI", string.format("Swapping from Global Map to Local Port View: %s", Player.portName))
		
		ReleaseLedger()
		SwapToModal("ui/portview.lua")
		
		local port = Player:GetPort()
		SoundEvent(port.cadikey)
	end
end

------------------------------------------------------------------------------
-- Scene Construction
------------------------------------------------------------------------------

MakeDialog
{
	name = "map", x = kCenter, y = kCenter,
	
	-- Generates the interactive globe
	MapWindow
	{
		x = kScreenCenterX, y = kScreenCenterY, w = kScreenWidth, h = kScreenHeight,
		background = "image/worldmap",
		yFar = 80, yNear = 400, farScale = 0.4, nearScale = 1,
		cloudY = 370, cloudTime = 60000,
	},
	
	-- Inject the hidden developer menu wrapper
	devMenu(),
}

DebugOut("UI", "World Map View successfully loaded and rendered.")

SoundEvent("Stop_Environments")
SoundEvent("map_screen")

-- Ensure the Ledger overlays the map and sets its button states correctly
GrabLedger()
UpdateLedger("mapview")