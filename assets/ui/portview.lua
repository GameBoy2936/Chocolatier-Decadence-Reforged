--[[--------------------------------------------------------------------------
	Chocolatier Three: Port View
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

gCurrentModal = "portview"
local portName = Player.portName
local port = _AllPorts[portName]

if not Player.portsVisited[portName] then
    DebugOut("PLAYER", "First visit to port: " .. portName)
	Player.portsVisited[portName] = true
	Player.portsAvailable[portName] = "open"
	Player.portVisitCount = Player.portVisitCount + 1
    
    -- Unlock the catalogue entry for this port on the first visit.
    Player.catalogue.unlockedPorts[portName] = true
    DebugOut("PLAYER", "Unlocked port entry for '" .. portName .. "'.")
end

if port and port.buildings then
    for _, building in ipairs(port.buildings) do
        if building.inventory and (building.type == "market" or building.type == "farm") then
            for _, ing in ipairs(building.inventory) do
                if ing:IsAvailable() then
                    Player.catalogue.discoveredIngredientLocations = Player.catalogue.discoveredIngredientLocations or {}
                    Player.catalogue.discoveredIngredientLocations[ing.name] = Player.catalogue.discoveredIngredientLocations[ing.name] or {}
                    if not Player.catalogue.discoveredIngredientLocations[ing.name][port.name] then
                        Player.catalogue.discoveredIngredientLocations[ing.name][port.name] = true
                        DebugOut("CATALOGUE", "Discovered new location for " .. ing.name .. ": " .. port.name)
                    end
                end
            end
        end
    end
end

local portNameFont = { labelFontName, 22, Color(208,208,208,255) }

------------------------------------------------------------------------------

function SwapMapPortScreens()
    DebugOut("UI", "Swapping from Port View to Map View.")
	ReleaseLedger()
	SwapToModal("ui/mapview.lua")
end

------------------------------------------------------------------------------

local labels = {}
if port then
	for _,b in ipairs(port.buildings) do
		-- The key change is wrapping b.name in GetString()
		local buildingDisplayName = GetString(b.name)
		table.insert(labels,
			BSGWindow
			{
				name=b.name, x=b.x,y=b.y, fit=true, color=rolloverColor, frame="controls/rollover",
				TightText { x=0,y=0, label="#"..buildingDisplayName, font=rolloverInfoFont, flags=kVAlignTop+kHAlignLeft, }
			})
	end
end

------------------------------------------------------------------------------

MakeDialog
{
	name="port",
	
	PortWindow
	{
		x=kScreenCenterX,y=kScreenCenterY, w=kScreenWidth,h=kScreenHeight,
		port=port, background="ports/"..portName.."/"..portName,
		Group(labels),
		Bitmap { image="image/banner",x=275,y=0,
			Text { x=0,y=17,w=kMax,h=25, flags=kVAlignTop+kHAlignCenter, label="#"..GetString(portName), font=portNameFont },
		},
	},
	
	devMenu(),
}

DebugOut("UI", "Port View loaded for: " .. portName)

GrabLedger()
UpdateLedger("portview")