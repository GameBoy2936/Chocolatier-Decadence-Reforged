--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Building Properties
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Object Manipulators
-------------------------------------------------------------------------------

local function RefreshPanel()
	CloseWindow()
	QueueCommand(function() DisplayDialog { "dev/dev_buildings.lua", x = gDialogTable.x, y = gDialogTable.y } end)
end

-- Grants or revokes ownership of Shops and Factories
local function devToggleOwned(building)
	if building:IsOwned() then
		Player.buildingsOwned[building.name] = nil
		
		-- Scrub factory output tracking if un-owning
		if building.type == "factory" then
			Player.factories[building.name] = nil
		end
		DebugOut("DEV", string.format("Admin Action: Revoked player ownership of %s.", building.name))
	else
		building:MarkOwned()
		DebugOut("DEV", string.format("Admin Action: Force-granted ownership of %s.", building.name))
	end
	RefreshPanel()
end

-- Blocks or unblocks access to specific buildings
local function devToggleBlocked(building)
	if Player.buildingsBlocked[building.name] then
		Player.buildingsBlocked[building.name] = nil
		DebugOut("DEV", string.format("Admin Action: Lifted entry block on %s.", building.name))
	else
		Player.buildingsBlocked[building.name] = true
		DebugOut("DEV", string.format("Admin Action: Placed entry block on %s.", building.name))
	end
	RefreshPanel()
end

-- Teleports to the specific port and immediately triggers the Click event for the target building
local function devRemoteVisit(building)
	local port = building.port
	DebugOut("DEV", string.format("Admin Action: Safe Teleport initiated to %s -> %s", port.name, building.name))
	
	CloseWindow()
	
	-- Clean up legacy background travel states if we are snatching the player mid-flight
	if gTravelActive then
		gTravelActive = false
		if PauseTravel then PauseTravel() end
	end
	
	-- Update absolute location coordinate
	Player:SetPort(port.name)

	QueueCommand(function() 
		-- A. Purge Dev Menu toolbar to prevent layer conflicts
		PopModal("dev_menu")
		
		-- B. Release ledger to prepare for screen swap
		ReleaseLedger()
		
		-- C. Swap the game environment logic and UI
		SwapToModal("ui/portview.lua")
		
		-- D. Re-trigger ambient environment audio
		SoundEvent(port.cadikey)

		-- E. Nested Event Queue: Wait for portview to finish GrabLedger, then force the building interaction
		QueueCommand(function() 
			building:OnClick() 
		end)
	end)
end

-------------------------------------------------------------------------------
-- UI Construction & Data Matrix
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 200 -- Standard column width limit
local y_start = 2 * h
local y_max = 560

local items = {}
local x = 0
local y = y_start

-- Sort the parent ports alphabetically to keep the headers organized
local sortedPorts = {}
for _, port in pairs(_AllPorts) do table.insert(sortedPorts, port) end
table.sort(sortedPorts, function(a, b) return a.name < b.name end)

-- Double nested loop: Iterate ports, then iterate buildings inside each port
for _, port in ipairs(sortedPorts) do
	if port.buildings and table.getn(port.buildings) > 0 then
		
		-- Render Port Geography Header
		if y + (h * 2) > y_max then x = x + w; y = y_start end
		table.insert(items, Text { x = x, y = y, w = w, h = h, label = "#---------- " .. string.upper(GetString(port.name)) .. " ----------", font = { devMenuStyle.font[1], 10, Color(150, 150, 150, 255) } })
		y = y + h
		
		for _, building in ipairs(port.buildings) do
			if building.type ~= "special" then
				if y > y_max then x = x + w; y = y_start end
				
				local b = building
				local isOwned = b:IsOwned()
				local isBlocked = Player.buildingsBlocked[b.name]
				
				-- Only shops and factories technically support ownership flags
				local canOwn = (b.type == "shop" or b.type == "factory")
				
				local nameColor = "000000"
				if isOwned then nameColor = "3A8E1D" 		-- Owned (Green)
				elseif isBlocked then nameColor = "A02020" 	-- Blocked (Red)
				end
				
				-- Format Name Label (Shorten verbose names aggressively to prevent UI overlap)
				local displayName = GetString(b.name)
				displayName = string.gsub(displayName, " Market", " Mkt")
				displayName = string.gsub(displayName, " Shop", " Shp")
				
				local label = string.format("#<font color='%s'>%s</font>", nameColor, displayName)
				
				-- Group everything for this specific building into a contiguous row
				local row = { x = x, y = y, w = w, h = h }
				
				-- 1. Core Label & Remote Visit trigger
				table.insert(row, Button { x = 0, y = 0, w = w - 45, h = h, label = label, command = function() devRemoteVisit(b) end })
				
				-- 2. Ownership Toggle Bracket [O] (Conditional)
				if canOwn then
					table.insert(row, Button { x = w - 45, y = 0, w = 22, h = h, label = (isOwned and "#<b>[O]</b>" or "#[o]"), command = function() devToggleOwned(b) end })
				else
					-- Insert empty spacing block to keep the UI columns aligned
					table.insert(row, Window { x = w - 45, y = 0, w = 22, h = h })
				end
						
				-- 3. Block Toggle Bracket [B]
				table.insert(row, Button { x = w - 22, y = 0, w = 22, h = h, label = (isBlocked and "#<b>[B]</b>" or "#[b]"), command = function() devToggleBlocked(b) end })
				
				table.insert(items, Window(row))
				y = y + h
			end
		end
		
		-- Margin gap between geography sectors
		y = y + (h / 2)
	end
end

MakeDialog
{
	name = "dev_buildings",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = w * 4.5, h = 600, fit = true, color = { 1, 1, 1, 0.9 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = 100, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Text { x = 110, y = 0, w = 400, h = h, label = "#<b>Green=Owned | Red=Blocked | Click Name=Teleport & Visit | [O]=Own | [B]=Block</b>", font = { devMenuStyle.font[1], 10, BlackColor } },
		
		Group(items),
	},
}