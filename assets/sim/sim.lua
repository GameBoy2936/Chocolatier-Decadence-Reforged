--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- Require fundamental sim object type definitions
require("sim/category.lua")
require("sim/ingredient.lua")
require("sim/product.lua")
require("sim/recipe.lua")

require("sim/tips.lua")

require("sim/port.lua")
require("sim/building.lua")
require("sim/market.lua")
require("sim/shop.lua")
require("sim/factory.lua")
require("sim/kitchen.lua")
require("sim/character_actions.lua")
require("sim/character.lua")

require("sim/quest.lua")
require("sim/quest_functions.lua")

require("sim/player.lua")

require("characters/misc_characters.lua")
require("characters/asset_manifest.lua")

--require("sim/firstpeek.lua")

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function TickSim(ticks)
	ticks = ticks or 1
    DebugOut("SIM", "TickSim called. Advancing game time by " .. ticks .. " week(s).")

	-- Advance the clock
	Player.time = Player.time + ticks
	Player.subticks = 0
    Player:UpdateHolidays()
    DebugOut("SIM", "New week is now " .. Player.time .. ".")

	-- Run the factories
    DebugOut("SIM", "Running factory production...")
	AnimateProduction()
	Player:RunFactories()

	-- Update the per-shop special order generation system
    DebugOut("SIM", "Updating special orders...")
	UpdateSpecialOrders()
	
	-- Expire ingredients and products
    DebugOut("SIM", "Checking for expired inventory...")
	Player:ExpireInventory()
	
    -- Apply tip-based price changes
    DebugOut("SIM", "Updating market tips...")
    Tips.Update()
	
	-- Update supplies and the ledger
    DebugOut("SIM", "Updating player supplies and ledger UI.")
	Player:UpdateSupplies()
	UpdateLedger("all")

--	SetState("GameWeeks", Player.time)		-- FIRST PEEK
--	if Mod(Player.time, 6) == 0 then FirstPeekProgress() end		-- FIRST PEEK
    DebugOut("SIM", "TickSim complete for week " .. Player.time .. ".")
end

function SubTickSim()
	-- FOUR sub-ticks equals one real tick
	Player.subticks = Player.subticks + 1
    DebugOut("SIM", "SubTick " .. Player.subticks .. "/4.")
	UpdateLedger("all")
	if Player.subticks == 4 then
		TickSim(1)
	end
end