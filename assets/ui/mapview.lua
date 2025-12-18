--[[--------------------------------------------------------------------------
	Chocolatier Three: World Map
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

gCurrentModal = "mapview"

------------------------------------------------------------------------------

function SwapMapPortScreens()
	if gTravelActive then return end
	
	if Player.portName ~= "enroute" then
        DebugOut("UI", "Swapping from Map View to Port View: " .. Player.portName)
		ReleaseLedger()
		SwapToModal("ui/portview.lua")
		
		local port = Player:GetPort()
		SoundEvent(port.cadikey)
	end
end

------------------------------------------------------------------------------

MakeDialog
{
	name="map",x=kCenter,y=kCenter,
	MapWindow
	{
		x=kScreenCenterX,y=kScreenCenterY, w=kScreenWidth,h=kScreenHeight,
		background="image/worldmap",
		yFar=80,yNear=400, farScale=.4,nearScale=1,
		cloudY=370,cloudTime=60000,
	},
	
	devMenu(),
}

DebugOut("UI", "Map View loaded.")

SoundEvent("Stop_Environments")
SoundEvent("map_screen")

GrabLedger()
UpdateLedger("mapview")