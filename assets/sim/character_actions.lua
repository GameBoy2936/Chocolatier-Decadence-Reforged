--[[--------------------------------------------------------------------------
	Chocolatier Three: Character Actions
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]--------------------------------------------------------------------------

------------------------------------------------------------------------------
local _ActionSpeak = 
{
	DoAction = function(self, char, building)
        DebugOut("CHAR", char.name .. " is speaking. Dialogue key: " .. self.key)
		local t = "#"..GetReplacedString(self.key)
		DisplayDialog { "ui/ui_character_generic.lua", char=char, text=t, building=building, }
	end
}
function Speak(key) return CreateObject(_ActionSpeak, { key=key }) end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local _ActionSpeakDynamic = 
{
	DoAction = function(self, char, building)
        -- This is the new dynamic generic dialogue system with probability-based fallbacks.

        -- 1. Define the base keys for each rank.
        local rank_dialogue_keys = {
            [2] = "generic_rank2",
            [3] = "generic_rank3",
            [4] = "generic_rank4",
            [5] = "generic_rank4", -- Handle Master Chocolatier (Rank 5) by reusing Rank 4 lines
        }
        
        -- 2. Build a list of potential dialogue keys, from most specific to most generic.
        local keys_to_try = {}
        
        -- NEW: Priority 1: Location + Character specific (e.g. "Onaona in her Hut")
        if building and building.name and char and char.name then
            table.insert(keys_to_try, "generic_building_" .. building.name .. "_" .. char.name)
        end

        -- NEW: Priority 2: Port + Character specific (e.g. "Onaona in Kona")
        if building and building.port and building.port.name and char and char.name then
            table.insert(keys_to_try, "generic_port_" .. building.port.name .. "_" .. char.name)
        end

        -- NEW: Priority 3: Building specific (General comments about this location)
        if building and building.name then
            table.insert(keys_to_try, "generic_building_" .. building.name)
        end

        -- Priority 4: Character-specific dialogue for the current rank
        if rank_dialogue_keys[Player.rank] and char and char.name then
            table.insert(keys_to_try, rank_dialogue_keys[Player.rank] .. "_" .. char.name)
        end
        
        -- Priority 5: Character-specific generic dialogue (The "Personality" layer)
        if char and char.name then
            table.insert(keys_to_try, "generic_building_" .. char.name)
        end
        
        -- Priority 6: General dialogue for the current rank
        if rank_dialogue_keys[Player.rank] then
            table.insert(keys_to_try, rank_dialogue_keys[Player.rank])
        end
        
        -- Priority 7: Fallback to original generic building dialogue
        table.insert(keys_to_try, "generic_building")


        -- 3. Determine Probability
        -- MODIFIED: Reduced from 75 to 40. 
        -- This means if a specific line exists, they only say it 40% of the time,
        -- leaving a 60% chance to check the next priority level.
        local specific_chance = 40 
        
        -- Check if this is a generic "Empty Building" placeholder character.
        if _EmptyCharacters then
            for _, emptyName in ipairs(_EmptyCharacters) do
                if char.name == emptyName then
                    specific_chance = 15 -- Reduced from 20 to 15. Very high variance.
                    break
                end
            end
        end

        -- 4. Find the best available key and DYNAMICALLY count its variations.
        local final_base_key = nil
        local variation_count = 0
        
        for _, base_key in ipairs(keys_to_try) do
            -- We check for the existence of the first variation ("_1")
            -- We use GetString to check existence against the raw table.
            if GetString(base_key .. "_1") ~= "#####" then
                
                -- Check if this is a specific character/location key (anything more specific than "generic_building")
                -- If the key is NOT just "generic_building", we treat it as specific content subject to RNG.
                local is_specific = (base_key ~= "generic_building")
                
                -- If it is specific, roll the dice to see if we use it or fall through
                local use_this_key = true
                if is_specific then
                    local roll = RandRange(1, 100)
                    if roll > specific_chance then
                        use_this_key = false
                        DebugOut("CHAR", "Skipping specific line '" .. base_key .. "' for variety (Roll: " .. roll .. " > " .. specific_chance .. ").")
                    end
                end

                if use_this_key then
                    -- We found our key. Now we MUST count how many variations exist.
                    final_base_key = base_key
                    variation_count = 1
                    while GetString(final_base_key .. "_" .. (variation_count + 1)) ~= "#####" do
                        variation_count = variation_count + 1
                    end
                    
                    DebugOut("CHAR", "Found dialogue match: " .. final_base_key .. " (" .. variation_count .. " variations)")
                    break -- Stop searching, we found our key and counted it.
                end
            end
        end
        
        -- Fallback safety
        if not final_base_key then
            final_base_key = "generic_building"
            variation_count = 1
            while GetString(final_base_key .. "_" .. (variation_count + 1)) ~= "#####" do
                variation_count = variation_count + 1
            end
            DebugOut("CHAR", "Fallback to generic_building (" .. variation_count .. " variations)")
        end
        
        -- 5. Select a random variation.
        local final_key = final_base_key .. "_" .. tostring(RandRange(1, variation_count))
        
		local t = "#"..GetReplacedString(final_key)
		DisplayDialog { "ui/ui_character_generic.lua", char=char, text=t, building=building, }
	end
}
function SpeakDynamic() return _ActionSpeakDynamic end

------------------------------------------------------------------------------
local _ActionPlayCrates =
{
	DoAction = function(self, char, building)
		DisplayDialog { "ui/ui_crates.lua", char=char, building=building }
	end
}
function PlayCrates() return _ActionPlayCrates end

------------------------------------------------------------------------------
local _ActionSlotMachine =
{
	DoAction = function(self, char, building)
		DisplayDialog { "ui/ui_slotselect.lua", char=char, building=building }
	end
}
function PlaySlots() return _ActionSlotMachine end

------------------------------------------------------------------------------
-- TODO: Decide whether this is the way to go...

local _ActionSellIngredients =
{
	DoAction = function(self, char, building)
		DisplayDialog { "ui/ui_market.lua", market=building, char=char, inventory=self.inventory, ok="ok" }
	end
}
function SellIngredients(inventory) return CreateObject(_ActionSellIngredients, { inventory=inventory }) end

------------------------------------------------------------------------------