--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Character Actions)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Explicit Static Dialogue Action
------------------------------------------------------------------------------
-- Forces the character to speak a specific, predefined string key.
local _ActionSpeak = 
{
	DoAction = function(self, char, building)
		DebugOut("CHAR", string.format("%s is speaking static dialogue key: %s", char.name, self.key))
		local t = "#" .. GetReplacedString(self.key)
		DisplayDialog { "ui/ui_character_generic.lua", char = char, text = t, building = building }
	end
}
function Speak(key) return CreateObject(_ActionSpeak, { key = key }) end

------------------------------------------------------------------------------
-- Dynamic Contextual Dialogue Action
------------------------------------------------------------------------------
-- The master dialogue generator. Determines what an NPC says based on their location,
-- their identity, the player's rank, and randomized probability weights.
local _ActionSpeakDynamic = 
{
	DoAction = function(self, char, building)
		-- 1. Base UI Keys mapped to the player's progression rank
		local rank_dialogue_keys = {
			[2] = "generic_rank2",
			[3] = "generic_rank3",
			[4] = "generic_rank4",
			[5] = "generic_rank4", -- Master Chocolatier (Rank 5) reuses Rank 4 lines
		}
		
		-- 2. Build the fallback hierarchy of potential string keys.
		-- The system checks from most highly specific (top) to completely generic (bottom).
		local keys_to_try = {}
		
		-- Priority 1: Location + Character specific (e.g., "Onaona inside her Hut")
		if building and building.name and char and char.name then
			table.insert(keys_to_try, "generic_building_" .. building.name .. "_" .. char.name)
		end

		-- Priority 2: Port + Character specific (e.g., "Onaona anywhere in Kona")
		if building and building.port and building.port.name and char and char.name then
			table.insert(keys_to_try, "generic_port_" .. building.port.name .. "_" .. char.name)
		end

		-- Priority 3: Building specific (e.g., "General chatter regarding the local market")
		if building and building.name then
			table.insert(keys_to_try, "generic_building_" .. building.name)
		end

		-- Priority 4: Rank + Character specific (e.g., "Onaona talking to a Rank 4 player")
		if rank_dialogue_keys[Player.rank] and char and char.name then
			table.insert(keys_to_try, rank_dialogue_keys[Player.rank] .. "_" .. char.name)
		end
		
		-- Priority 5: Character personality base (e.g., "Onaona's standard generic greeting")
		if char and char.name then
			table.insert(keys_to_try, "generic_building_" .. char.name)
		end
		
		-- Priority 6: Rank specific (e.g., "Random NPC reacting to a Rank 4 player")
		if rank_dialogue_keys[Player.rank] then
			table.insert(keys_to_try, rank_dialogue_keys[Player.rank])
		end
		
		-- Priority 7: Ultimate Fallback (Completely generic building dialogue)
		table.insert(keys_to_try, "generic_building")


		-- 3. Determine Variance Probability
		-- If a specific lore string is found, we don't ALWAYS want to play it, or the
		-- NPC becomes a repetitive robot. We roll probability to let them fall down the 
		-- hierarchy and say something more generic for variety.
		
		-- 40% chance to say their specific lore line; 60% chance to check the next tier down.
		local specific_chance = 40 
		
		-- Empty building "Travelers" have much less to say, so we lower their specific
		-- chance to 15% to force higher dialogue variance.
		if _EmptyCharacters then
			for _, emptyName in ipairs(_EmptyCharacters) do
				if char.name == emptyName then
					specific_chance = 15 
					break
				end
			end
		end

		-- 4. Execute the Hierarchy Search
		local final_base_key = nil
		local variation_count = 0
		
		for _, base_key in ipairs(keys_to_try) do
			-- Ensure the string actually exists in the localized file (checking for _1)
			if GetString(base_key .. "_1") ~= "#####" then
				
				-- If the key is NOT the ultimate generic fallback, we test it against the RNG.
				local is_specific = (base_key ~= "generic_building")
				local use_this_key = true
				
				if is_specific then
					local roll = RandRange(1, 100)
					if roll > specific_chance then
						use_this_key = false
						DebugOut("CHAR", string.format("Skipping specific line '%s' to provide dialogue variety (Roll %d > %d threshold).", base_key, roll, specific_chance))
					end
				end

				-- We won the RNG roll. Lock in this string prefix and tally its variations.
				if use_this_key then
					final_base_key = base_key
					variation_count = 1
					
					while GetString(final_base_key .. "_" .. (variation_count + 1)) ~= "#####" do
						variation_count = variation_count + 1
					end
					
					DebugOut("CHAR", string.format("Dialogue key selected: %s (%d variations available)", final_base_key, variation_count))
					break 
				end
			end
		end
		
		-- Ultimate Fail-safe execution
		if not final_base_key then
			final_base_key = "generic_building"
			variation_count = 1
			while GetString(final_base_key .. "_" .. (variation_count + 1)) ~= "#####" do
				variation_count = variation_count + 1
			end
			DebugOut("CHAR", string.format("Dialogue search exhausted. Falling back to base generic_building (%d variations).", variation_count))
		end
		
		-- 5. Selection and Rendering
		-- Pick one of the numbered variations (e.g., generic_building_3)
		local final_key = final_base_key .. "_" .. tostring(RandRange(1, variation_count))
		local t = "#" .. GetReplacedString(final_key)
		
		DisplayDialog { "ui/ui_character_generic.lua", char = char, text = t, building = building }
	end
}
function SpeakDynamic() return _ActionSpeakDynamic end

------------------------------------------------------------------------------
-- UI Action: Launch Cargo Crates Minigame
------------------------------------------------------------------------------
local _ActionPlayCrates =
{
	DoAction = function(self, char, building)
		DebugOut("CHAR", string.format("%s launched Cargo Crates minigame.", char.name))
		DisplayDialog { "ui/ui_crates.lua", char = char, building = building }
	end
}
function PlayCrates() return _ActionPlayCrates end

------------------------------------------------------------------------------
-- UI Action: Launch Slot Machine Minigame
------------------------------------------------------------------------------
local _ActionSlotMachine =
{
	DoAction = function(self, char, building)
		DebugOut("CHAR", string.format("%s launched Casino Slots minigame.", char.name))
		DisplayDialog { "ui/ui_slotselect.lua", char = char, building = building }
	end
}
function PlaySlots() return _ActionSlotMachine end

------------------------------------------------------------------------------
-- UI Action: Sell Specific Inventory
------------------------------------------------------------------------------
local _ActionSellIngredients =
{
	DoAction = function(self, char, building)
		DebugOut("CHAR", string.format("%s opened specific ingredient merchant panel.", char.name))
		DisplayDialog { "ui/ui_market.lua", market = building, char = char, inventory = self.inventory, ok = "ok" }
	end
}
function SellIngredients(inventory) return CreateObject(_ActionSellIngredients, { inventory = inventory }) end