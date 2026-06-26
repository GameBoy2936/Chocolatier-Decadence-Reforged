--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Simulator Master Core)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Object Instantiation Hierarchy
-------------------------------------------------------------------------------

-- 1. Base Item Objects
require("sim/category.lua")
require("sim/ingredient.lua")
require("sim/product.lua")
require("sim/recipe.lua")

-- 2. Meta Economic & Data Handlers
require("sim/tips.lua")
require("sim/player.lua")

-- 3. Geography & Environment Objects
require("sim/port.lua")
require("sim/building.lua")
require("sim/market.lua")
require("sim/shop.lua")
require("sim/factory.lua")
require("sim/kitchen.lua")

-- 4. Lore & Interaction Objects
require("sim/character_actions.lua")
require("sim/character.lua")
require("characters/misc_characters.lua")
require("characters/asset_manifest.lua")

-- 5. Logic & Quest Engine Handlers
require("sim/quest.lua")
require("sim/quest_functions.lua")

-- Legacy Analytics Engine (Disabled by default)
-- require("sim/firstpeek.lua")

------------------------------------------------------------------------------
-- Master Clock execution
------------------------------------------------------------------------------

-- The main progression hook for the entire game world.
-- Advances time, handles physical processing, updates arrays, and ticks UI states.
function TickSim(ticks)
	ticks = ticks or 1
	DebugOut("SIM", string.format("TickSim Called: Advancing global clock by %d week(s).", ticks))

	-- 1. Time & Temporal Event Processing
	Player.time = Player.time + ticks
	Player.subticks = 0
	Player:UpdateHolidays()
	DebugOut("SIM", string.format("Date updated. Current week is now %d.", Player.time))

	-- 2. Industrial Processing
	-- Commits ingredients to factories and generates finished products
	DebugOut("SIM", "Executing active factory production lines...")
	AnimateProduction()
	Player:RunFactories()

	-- 3. Order Generation
	-- Refreshes the probability matrix for generating new telegram delivery quests
	DebugOut("SIM", "Updating regional special order requests...")
	UpdateSpecialOrders()
	
	-- 4. Inventory Degradation
	-- Calculates spoilage logic for stagnant warehouse inventory
	DebugOut("SIM", "Evaluating warehouse stocks for expired inventory...")
	Player:ExpireInventory()
	
	-- 5. Economic Shifts
	-- Triggers rumors, events, and applies dynamic market tip price modifiers
	DebugOut("SIM", "Generating and applying global market tips...")
	Tips.Update()
	
	-- 6. State Consolidation & UI Updates
	-- Validates inventory numbers and broadcasts them to the Ledger interface
	DebugOut("SIM", "Consolidating player supply chains and refreshing UI Ledger.")
	Player:UpdateSupplies()
	UpdateLedger("all")

	-- Legacy Telemetry Hooks
	-- SetState("GameWeeks", Player.time)
	-- if Mod(Player.time, 6) == 0 then FirstPeekProgress() end

	DebugOut("SIM", string.format("TickSim successfully completed for Week %d.", Player.time))
end

-- Advances a partial segment of a week.
-- (Visual representation primarily used for the airplane travel animation).
function SubTickSim()
	-- 4 subticks equals 1 real week tick
	Player.subticks = Player.subticks + 1
	DebugOut("SIM", string.format("SubTick advanced (%d/4).", Player.subticks))
	
	UpdateLedger("all")
	
	-- When 4 subticks accumulate, trigger a full standard simulation tick
	if Player.subticks == 4 then
		TickSim(1)
	end
end