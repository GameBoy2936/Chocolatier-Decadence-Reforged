--[[--------------------------------------------------------------------------
	Chocolatier Three - Test Kitchen
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

Kitchen =
{
	cadikey = "test_kitchen",
	type = "kitchen",
}

setmetatable(Kitchen, Building)
Kitchen.__index = Kitchen
Kitchen.__tostring = function(t) return "{Kitchen:"..tostring(t.name).."}" end

------------------------------------------------------------------------------

local function NewIngredientCheck(char)
	-- Check kitchen ingredients versus player's inventory and remove some...
	local newIngredients = {}
	for name,count in pairs(Player.ingredients) do
		if not Player.labIngredients[name] then
			table.insert(newIngredients, name)
		end
	end
	
	if table.getn(newIngredients) > 0 then
        DebugOut("KITCHEN", "New ingredients detected for lab pantry: " .. table.concat(newIngredients, ", "))
		DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..GetString("kitchen_new_ingredients") }
		for _,name in ipairs(newIngredients) do
			Player:AddIngredient(name, -1, true)
			Player.labIngredients[name] = true
		end
		Player:UpdateSupplies()
	end
end

------------------------------------------------------------------------------

local _InventRecipe =
{
	DoAction = function(self, char, building)
		NewIngredientCheck(char)
		local category = _AllCategories["user"]
		if category and table.getn(category.products) >= Player.customSlots then
			DisplayDialog { "ui/ui_character_generic.lua", char=char, building=building, text="#"..GetString("user_noslots") }
		else
			DisplayDialog { "ui/ui_kitchen.lua", char=char, building=building }
		end
	end
}
function InventRecipe() return _InventRecipe end

------------------------------------------------------------------------------
-- Click Management

function Kitchen:EnterBuilding(char, somethingHappened)
    DebugOut("BUILDING", "Player entering Secret Test Kitchen.")

--	char = char or self:RandomCharacter()
	char = self:RandomCharacter()
	local category = _AllCategories.user
	NewIngredientCheck(char)
	
	local yn = "yes"
	if category and table.getn(category.products) >= Player.customSlots then
		if table.getn(category.products) == 12 then
            DebugOut("KITCHEN", "Player has filled all 12 custom recipe slots.")
			yn = DisplayDialog { "ui/ui_character_yesno.lua", char=char, building=self, text="#"..GetString("user_allslotsused") }
		else
            DebugOut("KITCHEN", "Player has no available custom recipe slots.")
			yn = DisplayDialog { "ui/ui_character_yesno.lua", char=char, building=self, text="#"..GetString("user_noslots") }
		end
	end
	if yn == "yes" then
		DisplayDialog { "ui/ui_kitchen.lua", char=char, building=self }
	end
	return true
end