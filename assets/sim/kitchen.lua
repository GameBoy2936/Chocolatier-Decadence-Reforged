--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Test Kitchen Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Kitchen" is the specialized building where players create custom User Generated Recipes (UGRs).

Kitchen =
{
	cadikey = "test_kitchen",
	type = "kitchen",
}

setmetatable(Kitchen, Building)
Kitchen.__index = Kitchen
Kitchen.__tostring = function(t) return "{Kitchen:" .. tostring(t.name) .. "}" end

------------------------------------------------------------------------------
-- Core Methods & Hooks
------------------------------------------------------------------------------

-- Compares the ingredients in the player's active inventory against the Kitchen's permanent pantry.
-- If the player is carrying an ingredient the Kitchen has never seen before, 
-- it automatically deducts 1 sack from the player's inventory and permanently unlocks it in the Kitchen.
local function NewIngredientCheck(char)
	local newIngredients = {}
	
	for name, count in pairs(Player.ingredients) do
		if not Player.labIngredients[name] then
			table.insert(newIngredients, name)
		end
	end
	
	if table.getn(newIngredients) > 0 then
		DebugOut("KITCHEN", string.format("Absorbing new ingredients into laboratory pantry: %s", table.concat(newIngredients, ", ")))
		
		local text = GetRandomString("kitchen_new_ingredients")
		DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. text }
		
		-- Deduct exactly 1 sack of each new ingredient
		for _, name in ipairs(newIngredients) do
			Player:AddIngredient(name, -1, true)
			Player.labIngredients[name] = true
		end
		
		-- Recalculate factory supplies since we altered the player's global inventory
		Player:UpdateSupplies()
	end
end

------------------------------------------------------------------------------
-- Actions
------------------------------------------------------------------------------

-- Returns an interaction action block for characters triggering the recipe creator
local _InventRecipe =
{
	DoAction = function(self, char, building)
		NewIngredientCheck(char)
		local category = _AllCategories["user"]
		
		-- Verify player hasn't hit their custom recipe slot cap
		if category and table.getn(category.products) >= Player.customSlots then
			local text = GetRandomString("user_noslots")
			DisplayDialog { "ui/ui_character_generic.lua", char = char, building = building, text = "#" .. text }
		else
			DisplayDialog { "ui/ui_kitchen.lua", char = char, building = building }
		end
	end
}

function InventRecipe() 
	return _InventRecipe 
end

------------------------------------------------------------------------------
-- Building Interaction
------------------------------------------------------------------------------

function Kitchen:EnterBuilding(char, somethingHappened)
	DebugOut("BUILDING", "Player entering the Secret Test Kitchen.")

	char = self:RandomCharacter()
	local category = _AllCategories.user
	
	-- Automatically absorb any newly discovered ingredients
	NewIngredientCheck(char)
	
	local yn = "yes"
	
	-- Verify custom recipe slot capacity before allowing entry into the creation UI
	if category and table.getn(category.products) >= Player.customSlots then
		
		if table.getn(category.products) == 12 then
			DebugOut("KITCHEN", "Access to creator blocked: Player has maxed out all 12 global UGR slots.")
			local text = GetRandomString("user_allslotsused")
			yn = DisplayDialog { "ui/ui_character_yesno.lua", char = char, building = self, text = "#" .. text }
		else
			DebugOut("KITCHEN", string.format("Access to creator blocked: Player has filled their current allowed capacity (%d).", Player.customSlots))
			local text = GetRandomString("user_noslots")
			yn = DisplayDialog { "ui/ui_character_yesno.lua", char = char, building = self, text = "#" .. text }
		end
	end
	
	-- If slots are available (or the player chose "yes" on an overwrite prompt), launch the UI
	if yn == "yes" then
		DisplayDialog { "ui/ui_kitchen.lua", char = char, building = self }
	end
	
	return true
end