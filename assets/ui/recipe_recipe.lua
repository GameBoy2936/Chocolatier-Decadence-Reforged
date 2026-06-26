--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Recipe Detail View)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script renders the right-hand panel detailing the specific recipe selected.

local contents = {}

-- Coordinates for the required ingredients
local slotPositions = {
	{ x = 24, y = 238 },
	{ x = 92, y = 238 },
	{ x = 160, y = 238 },
	{ x = 228, y = 238 },
	{ x = 296, y = 238 },
	{ x = 364, y = 238 },
}

if gRecipeSelection and gRecipeSelection:IsKnown() then
	-- Render Basic Metadata
	table.insert(contents, Text { x = 24, y = 20, w = 418, h = 44, name = "recipe_name", label = "#" .. gRecipeSelection:GetName(), font = { labelFontName, 22, Color(0, 0, 0, 255) }, flags = kVAlignCenter + kHAlignCenter })
	table.insert(contents, Text { x = 192, y = 76, w = 250, h = 157, name = "recipe_desc", label = "#" .. gRecipeSelection:GetDescription() })
	
	-- Display massive product icon (Centered roughly at 99, 144)
	table.insert(contents, gRecipeSelection:GetAppearanceHuge(35, 80))
	
	-- ------------------------------------------------------------------------
	-- Required Ingredient Bar
	-- ------------------------------------------------------------------------
	local n = table.getn(gRecipeSelection.recipe)
	for i = 1, n do
		local info = slotPositions[i]
		local name = gRecipeSelection.recipe[i]
		
		-- Determine if the player currently lacks sufficient inventory for this ingredient
		local missing = nil
		local needs = gRecipeSelection:GetNeeds()
		
		if needs[name] and (not Player.ingredients[name] or Player.ingredients[name] < needs[name]) then
			missing = Bitmap { x = 0, y = 0, image = "image/missing_ingredient" }
		end
		
		table.insert(contents,
			Rollover { 
				x = info.x, y = info.y, w = 64, h = 64,
				contents = name .. ":RecipeBookRolloverContents()",
				Bitmap { x = 0, y = 0, image = "items/" .. name .. "_big" },
				missing,
			}
		)
	end

	-- ------------------------------------------------------------------------
	-- Factory Feasibility Checks
	-- ------------------------------------------------------------------------
	-- If the book was opened via a Factory terminal, evaluate if the player is allowed 
	-- to set this recipe for active production.
	if gCurrentFactory and gRecipeSelection then
		local machinery = gRecipeSelection:GetMachinery().name
		
		-- Check 1: Does the factory possess the required hardware upgrade?
		if not gCurrentFactory:IsEquipped(machinery) then
			table.insert(contents, Text { x = 192, y = 180, w = 238, h = 60, label = "factory_nomachinery" })
			
			-- Block assignment entirely if hardware is missing
			if gCurrentFactory.port.name ~= Player.portName then 
				EnableWindow("use_recipe", false) 
			end
			EnableWindow("dev_force_rate", false)
			
		else
			-- Check 2: Has this factory ever made this product before?
			local count = gCurrentFactory:GetProduction(gRecipeSelection)
			
			if count and count > 0 then
				-- Factory is fully compliant and has historical yields
				table.insert(contents, Text { x = 192, y = 180, w = 238, h = 60, name = "factory_production", label = "#" .. GetString("factory_config", tostring(count)) })
				EnableWindow("use_recipe", true)
				EnableWindow("dev_force_rate", true)
				
			elseif gCurrentFactory.port.name == Player.portName then
				-- It's a new recipe for this factory, and we are physically on-site.
				-- Evaluate physical material inventory to see if they can play the minigame.
				local missing = false
				local needs = gRecipeSelection:GetNeeds()
				
				for name, need in pairs(needs) do
					local have = Player.ingredients[name] or 0
					if need > have then missing = true; break; end
				end
				
				if missing then
					-- Cannot configure new recipes without ingredients for the minigame
					table.insert(contents, Text { x = 192, y = 180, w = 238, h = 60, name = "factory_production", label = "#" .. GetString("factory_noingredients") })
					EnableWindow("use_recipe", false)
					EnableWindow("dev_force_rate", true) -- Cheat mode bypasses material requirements
				else
					EnableWindow("use_recipe", true)
					EnableWindow("dev_force_rate", true)
				end
				
			else
				-- Trying to configure a remote factory via Telephone, but it lacks historical minigame data for this product.
				table.insert(contents, Text { x = 192, y = 180, w = 238, h = 60, name = "factory_production", label = "#" .. GetString("factory_noconfig", GetString(gCurrentFactory.port.name)) })
				EnableWindow("use_recipe", false)
				EnableWindow("dev_force_rate", true) 
			end
		end
		
	-- If looking purely for reference, display which factory is the best at making this item
	elseif gRecipeSelection and gRecipeSelection:NumberMade() > 0 then
		local max = 0
		local maxFactory = nil
		
		for name, _ in pairs(Player.factories) do
			local f = _AllBuildings[name]
			local n = f:GetProduction(gRecipeSelection)
			if n > max then
				max = n
				maxFactory = f
			end
		end
		
		table.insert(contents, Text { x = 192, y = 180, w = 238, h = 60, name = "factory_production", label = "#" .. GetString("factory_other", GetString(maxFactory.port.name), tostring(max)) })
	end

-- ------------------------------------------------------------------------
-- Edge Cases: Empty Custom Slots
-- ------------------------------------------------------------------------
elseif gCategorySelection and gCategorySelection.name == "user" and Player.customSlots == 0 then
	-- Player clicked the "User" tab but hasn't unlocked any UGR slots yet
	EnableWindow("use_recipe", false)
	EnableWindow("dev_force_rate", false)
	table.insert(contents, Text { x = 62, y = 19, w = 338, h = 307, name = "recipe_desc", label = "#" .. GetString("recipe_noslots"), flags = kVAlignCenter + kHAlignCenter })

elseif gCategorySelection and gCategorySelection.name == "user" then
	-- Player clicked a UGR slot they own, but haven't actually invented a recipe for it yet
	EnableWindow("use_recipe", false)
	EnableWindow("dev_force_rate", false)
	table.insert(contents, Text { x = 62, y = 19, w = 338, h = 307, name = "recipe_desc", label = "#" .. GetString("user_blankslot"), flags = kVAlignCenter + kHAlignCenter })

else
	-- Player clicked an entirely undiscovered system recipe silhouette
	EnableWindow("use_recipe", false)
	EnableWindow("dev_force_rate", false)
	table.insert(contents, Text { x = 62, y = 19, w = 338, h = 307, name = "recipe_desc", label = "#" .. GetString("recipe_unknown"), flags = kVAlignCenter + kHAlignCenter })
end

MakeDialog(contents)