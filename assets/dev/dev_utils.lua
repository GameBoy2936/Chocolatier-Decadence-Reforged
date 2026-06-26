--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Utility Tools)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Time & Simulation Manipulation
-------------------------------------------------------------------------------

function devTickSim()
	DebugOut("DEV", "Utility Tool: Forced primary Simulation Tick (+1 Week).")
	TickSim(1)
end

function devSubTickSim()
	DebugOut("DEV", "Utility Tool: Forced Sub-Tick step (+1/4 Week).")
	SubTickSim()
end

-------------------------------------------------------------------------------
-- Engine State Manipulation
-------------------------------------------------------------------------------

function devRestartGame()
	DebugOut("DEV", "Utility Tool: Restarting game state from scratch.")
	local n = Player.name
	Player:Reset()
	Player.name = n
	SwapToModal("ui/portview.lua")
	
	local q = _AllQuests["tut_01"]
	q:Offer()
end

-- Extremely useful for modifying Port Layouts or Data arrays without needing to reboot the engine
function devReloadPort()
	DebugOut("DEV", string.format("Utility Tool: Hot-reloading active port data scripts for %s.", Player.portName))
	local file = "ports/" .. Player.portName .. "/" .. Player.portName .. ".lua"
	
	dofile(file)
	PrepareCharactersForBuildings()
	Player:RecalculatePricesForCurrentPort()
	SwapToModal("ui/portview.lua")
end

function devReloadStrings()
	DebugOut("DEV", "Utility Tool: Reloading Localization XML files.")
	Player:ReloadStrings()
	CloseWindow()
end

function devFlushStrings()
	ClearStringCache()
	-- If a tooltip was currently trying to render a broken placeholder, this forces a redraw
	if gCurrentModal == "portview" or gCurrentModal == "mapview" then
		UpdateLedger("all")
	end
end

-------------------------------------------------------------------------------
-- Progression Manipulation
-------------------------------------------------------------------------------

function devAddSlot(n)
	Player.customSlots = (Player.customSlots or 0) + (n or 1)
	Player.questVariables.ugr_slots = Player.customSlots - (Player.categoryCount.user or 0)
	DebugOut("DEV", string.format("Utility Tool: Forced grant of %d Custom Recipe Slots (New Total: %d).", n, Player.customSlots))
	CloseWindow()
end

-------------------------------------------------------------------------------
-- UI & Minigame Shortcuts
-------------------------------------------------------------------------------

function devDesignProduct()
	DebugOut("DEV", "Utility Tool: Launching Recipe Creator Override.")
	CloseWindow()
	QueueCommand(function() DisplayDialog { "ui/ui_kitchen.lua" } end)
end

function devDesignSign()
	DebugOut("DEV", "Utility Tool: Launching Sign Designer Override.")
	CloseWindow()
	QueueCommand(function() DisplayDialog {"ui/sign_basic.lua"} end)
end

function devSlotMachine()
	DebugOut("DEV", "Utility Tool: Launching Slot Machine Override.")
	CloseWindow()
	QueueCommand(function() DisplayDialog {"ui/ui_slotselect.lua"} end)
end

function devCrates()
	DebugOut("DEV", "Utility Tool: Launching Cargo Crates Override.")
	CloseWindow()
	QueueCommand(function() DisplayDialog {"ui/ui_crates.lua"} end)
end

function devCurves()
	DebugOut("DEV", "Utility Tool: Launching Curve Editor Override.")
	CloseWindow()
	QueueCommand(function() DoModal("dev/dev_animation.lua") end)
end

function devConsole(x, y)
	DisplayDialog { "dev/dev_console.lua", x = x, y = y }
end

-------------------------------------------------------------------------------
-- Event Generation
-------------------------------------------------------------------------------

local function ForceNewTip(tipType)
	local newTip
	
	if tipType == "ingredient" then newTip = Tips.GenerateIngredientTip()
	elseif tipType == "product" then newTip = Tips.GenerateProductTip()
	elseif tipType == "category" then newTip = Tips.GenerateCategoryTip()
	elseif tipType == "port" then newTip = Tips.GeneratePortTip()
	elseif tipType == "seasonal" then newTip = Tips.GenerateSeasonalTip()
	end

	if newTip then
		table.insert(Player.activeTips, newTip)
		
		-- Seasonal tips do not utilize NPC chat announcements
		if not newTip.seasonal_key then
			table.insert(Player.pendingAnnouncements, newTip)
		end
		
		DebugOut("DEV", string.format("Utility Tool: Successfully force-spawned new market tip of type '%s'.", tipType))
		CloseWindow()
	else
		DebugOut("ERROR", string.format("Utility Tool: Failed to force tip generation for type '%s'. Requirements likely unmet.", tipType))
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 130
local x = 0
local y = 2 * h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	if y > 550 then
		x = x + w
		y = 2 * h
	end
end

MakeDialog
{
	name = "dev_utils",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = w, h = h, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		
		Button { x = 0, y = h, w = w, h = h, label = "#Progress by +1 Week", command = devTickSim },
		Button { x = x, y = 2*h, w = w, h = h, label = "#Progress by +1/4 Wk", command = devSubTickSim },
		
		Button { x = 0, y = 3*h, w = w, h = h, label = "#Reload Current Port", command = devReloadPort },
		Button { x = 0, y = 4*h, w = w, h = h, label = "#Restart Game", command = devRestartGame },
		
		Button { x = 0, y = 5*h, w = w, h = h, label = "#Product Creator", command = devDesignProduct },
		Button { x = 0, y = 6*h, w = w, h = h, label = "#Crates", command = devCrates },
		Button { x = 0, y = 7*h, w = w, h = h, label = "#Curve Editor", command = devCurves },
		
		Button { x = 0, y = 8*h, w = w, h = h, label = "#Add 1 Custom Slot", command = function() devAddSlot(1) end },
		Button { x = 0, y = 9*h, w = w, h = h, label = "#Add 10 Custom Slots", command = function() devAddSlot(10) end },
		
		Button { x = 0, y = 10*h, w = w, h = h, label = "#Slot Machine", command = devSlotMachine },
		Button { x = 0, y = 11*h, w = w, h = h, label = "#Tip Manager", command = function() CloseWindow(); QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = 0, y = h} end) end },
		Button { x = 0, y = 12*h, w = w, h = h, label = "#Debug Console", command = function() devConsole(0, gDialogTable.y + h) end },
	},
}