--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Character Selector)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local onOkCallback = gDialogTable.onOk
local promptText = gDialogTable.prompt or "Select a Character:"

local h = devMenuStyle.font[2]
local w = 180
local y_start = 2 * h
local y_max = 560

-- Hardcoded UI hex colors separating specific narrative factions 
local characterGroupColors = {
	main = "0077BE",  -- Deep Blue (Baumeister/Tangye family)
	evil = "D82C2C",  -- Deep Red (Antagonists)
	trav = "B8860B",  -- Goldenrod (World Travelers)
	other = "000000"  -- Black (Standard Residents)
}

-- Hardcoded UI hex colors to categorize by current building location
local buildingTypeColors = {
	market =      "3A8E1D", -- Green
	farm =        "3A8E1D", -- Green
	shop =        "B324C7", -- Purple
	factory =     "C96C3E", -- Orange
	kitchen =     "87ceeb", -- Light Blue
	casino =      "B8860B", -- Gold
	generic =     "000000", 
	bank =        "000000",
	saloon =      "000000",
	empty =       "777777"  -- Gray (Empty slot wanderer)
}

-------------------------------------------------------------------------------
-- Spatial Location Engine
-------------------------------------------------------------------------------

-- Scans the entire world map architecture to find out exactly where every single 
-- NPC currently resides, returning a mapped array containing their building, port, and archetype.
local function GetCharacterLocations()
	local locations = {}
	
	-- 1. Scan all physical port structures
	for portName, port in pairs(_AllPorts) do
		if port.buildings then
			for _, building in ipairs(port.buildings) do
				local charList = building:GetCharacterList()
				if charList then
					for _, char in ipairs(charList) do
						locations[char.name] = { 
							name = GetString(building.name), 
							port = GetString(port.name), 
							type = building.type 
						}
					end
				end
			end
		end
	end
	
	-- 2. Scan the virtual background "_travelers" logic array
	local travelersBuilding = _AllBuildings["_travelers"]
	if travelersBuilding then
		for _, char in ipairs(travelersBuilding:GetCharacterList()) do
			locations[char.name] = { name = "[On The Road]", port = "", type = "trav" }
		end
	end
	
	-- 3. Scan the virtual background "_empty" logic array
	local emptyBuilding = _AllBuildings["_empty"]
	if emptyBuilding then
		for _, char in ipairs(emptyBuilding:GetCharacterList()) do
			locations[char.name] = { name = "[Empty Building]", port = "", type = "empty" }
		end
	end
	
	return locations
end

-------------------------------------------------------------------------------
-- Data Collation & Alphabetization
-------------------------------------------------------------------------------

local characters = {}
for name, char in pairs(_AllCharacters) do
	-- Failsafe: Ignore corrupted/empty localization records
	if GetString(char.name) ~= "#####" then
		table.insert(characters, char)
	end
end

table.sort(characters, function(a, b) return GetString(a.name) < GetString(b.name) end)
local characterLocations = GetCharacterLocations()

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local items = {}
local x = 0
local y = y_start
local num_columns = 6
local col_width = 130

for _, char in ipairs(characters) do
	if y > y_max then
		x = x + col_width
		y = y_start
	end
	
	local tempChar = char

	-- Retrieve current spatial data for the tag
	local locationInfo = characterLocations[char.name]
	local locationName = "[Not Placed]"
	local locationPort = ""
	local locationType = "other"
	
	if locationInfo then
		locationName = locationInfo.name
		locationPort = locationInfo.port
		locationType = locationInfo.type
	end
	
	-- Resolve the appropriate font color context
	local nameColor = "000000" 
	if string.find(char.name, "main_") then 
		nameColor = characterGroupColors.main
	elseif string.find(char.name, "evil_") then 
		nameColor = characterGroupColors.evil
	elseif buildingTypeColors[locationType] then
		nameColor = buildingTypeColors[locationType]
	end
	
	-- Synthesize the double-line dynamic UI label
	local nameLabel = string.format("<b><font color='%s'>%s</font></b>", nameColor, GetString(char.name))
	local locationString = locationName
	
	if locationPort ~= "" then
		locationString = locationString .. ", " .. locationPort
	end
	
	local locationLabel = string.format("<font size='10' color='000000'>%s</font>", locationString)
	local label = "#" .. nameLabel .. "<br>" .. locationLabel

	table.insert(items, Button { 
		x = x, y = y, w = col_width, h = h * 2, 
		label = label, 
		command = function() 
			DebugOut("DEV", string.format("Admin Selection: Chose character '%s'.", tempChar.name))
			if type(onOkCallback) == "function" then onOkCallback(tempChar) end
			CloseWindow()
		end 
	})
	
	y = y + h * 2
end

MakeDialog
{
	name = "dev_select_character",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = col_width * num_columns, h = 600, fit = true, color = { 1, 1, 1, 0.9 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Text { x = w, y = 0, w = w * (num_columns - 1), h = h, label = "#" .. promptText, flags = kVAlignCenter + kHAlignLeft },
		
		Group(items),
	}
}