--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Interior Port View)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

gCurrentModal = "portview"
local portName = Player.portName
local port = _AllPorts[portName]

------------------------------------------------------------------------------
-- Discovery & Environment Evaluation
------------------------------------------------------------------------------

-- If this is the absolute first time entering this port, flag it and unlock it in the Catalogue
if not Player.portsVisited[portName] then
	DebugOut("PLAYER", string.format("First arrival detected for Port: %s", portName))
	
	Player.portsVisited[portName] = true
	Player.portsAvailable[portName] = "open"
	Player.portVisitCount = Player.portVisitCount + 1
	
	Player.catalogue.unlockedPorts[portName] = true
	DebugOut("CATALOGUE", string.format("Unlocked port entry for '%s'.", portName))
end

-- Perform a silent scan of the port's markets and farms.
-- Any available ingredients found will have this port added to their "Where to Find" list in the Catalogue.
if port and port.buildings then
	for _, building in ipairs(port.buildings) do
		if building.inventory and (building.type == "market" or building.type == "farm") then
			for _, ing in ipairs(building.inventory) do
				if ing:IsAvailable() then
					-- Ensure safety arrays exist
					Player.catalogue.discoveredIngredientLocations = Player.catalogue.discoveredIngredientLocations or {}
					Player.catalogue.discoveredIngredientLocations[ing.name] = Player.catalogue.discoveredIngredientLocations[ing.name] or {}
					
					-- Register the discovery
					if not Player.catalogue.discoveredIngredientLocations[ing.name][port.name] then
						Player.catalogue.discoveredIngredientLocations[ing.name][port.name] = true
						DebugOut("CATALOGUE", string.format("Discovered reliable source for %s: %s", ing.name, port.name))
					end
				end
			end
		end
	end
end

local portNameFont = { labelFontName, 22, Color(208, 208, 208, 255) }

------------------------------------------------------------------------------
-- Navigation
------------------------------------------------------------------------------

-- Toggles between the interior of the current local port and the global map
function SwapMapPortScreens()
	DebugOut("UI", "Swapping from Local Port View to Global Map.")
	ReleaseLedger()
	SwapToModal("ui/mapview.lua")
end

------------------------------------------------------------------------------
-- Visual Setup & Labels
------------------------------------------------------------------------------

-- Programmatically generate interactive tooltips for every building defined in the Port's data file
local labels = {}
if port then
	for _, b in ipairs(port.buildings) do
		local buildingDisplayName = GetString(b.name)
		
		table.insert(labels, BSGWindow {
			name = b.name, x = b.x, y = b.y, fit = true, color = rolloverColor, frame = "controls/rollover",
			TightText { x = 0, y = 0, label = "#" .. buildingDisplayName, font = rolloverInfoFont, flags = kVAlignTop + kHAlignLeft }
		})
	end
end

------------------------------------------------------------------------------
-- Scene Construction
------------------------------------------------------------------------------

MakeDialog
{
	name = "port",
	
	-- Render the dynamic Port Engine component
	PortWindow
	{
		x = kScreenCenterX, y = kScreenCenterY, w = kScreenWidth, h = kScreenHeight,
		port = port, background = "ports/" .. portName .. "/" .. portName,
		Group(labels),
		
		-- Port Title Banner
		Bitmap { image = "image/banner", x = 275, y = 0,
			Text { x = 0, y = 17, w = kMax, h = 25, flags = kVAlignTop + kHAlignCenter, label = "#" .. GetString(portName), font = portNameFont },
		},
	},
	
	-- Inject the hidden developer menu wrapper
	devMenu(),
}

DebugOut("UI", string.format("Interior Port View successfully loaded for: %s", portName))

-- Ensure the Ledger overlays the port and sets its button states correctly
GrabLedger()
UpdateLedger("portview")