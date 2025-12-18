--[[---------------------------------------------------------------------------
	Chocolatier Three: Recipe Book Dialog
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local contents = {}

------------------------------------------------------------------------------

local slotPositions =
{
	{ x=24,y=238 },
	{ x=92,y=238 },
	{ x=160,y=238 },
	{ x=228,y=238 },
	{ x=296,y=238 },
	{ x=364,y=238 },
}

DebugOut(tostring(gRecipeSelection))

if gRecipeSelection and gRecipeSelection:IsKnown() then
	-- Recipe name and description
	table.insert(contents, Text { x=24,y=20,w=418,h=44, name="recipe_name", label="#"..gRecipeSelection:GetName(), font = { labelFontName, 22, Color(0,0,0 ,255)}, flags=kVAlignCenter+kHAlignCenter })
	table.insert(contents, Text { x=192,y=76,w=250,h=157, name="recipe_desc", label="#"..gRecipeSelection:GetDescription() })
	
	-- Center at 99,144
	table.insert(contents, gRecipeSelection:GetAppearanceHuge(35,80) )
	
	-- Recipe ingredients
	local n = table.getn(gRecipeSelection.recipe)
	for i=1,n do
		local info = slotPositions[i]
		local name = gRecipeSelection.recipe[i]
		
		local missing = nil
		local needs = gRecipeSelection:GetNeeds()
		if needs[name] and (not Player.ingredients[name] or Player.ingredients[name] < needs[name]) then
			missing = Bitmap { x=0,y=0, image="image/missing_ingredient" }
		end
		
		table.insert(contents,
			Rollover { x=info.x,y=info.y, w=64,h=64,
				contents = name .. ":RecipeBookRolloverContents()",
				Bitmap { x=0,y=0, image="items/".. name .."_big" },
				missing,
			})
	end

	if gCurrentFactory and gRecipeSelection then
		local machinery = gRecipeSelection:GetMachinery().name
		if not gCurrentFactory:IsEquipped(machinery) then
			table.insert(contents, Text { x=192,y=180,w=238,h=60, label="factory_nomachinery" })
			if gCurrentFactory.port.name ~= Player.portName then EnableWindow("use_recipe", false) end
		else
			local count = gCurrentFactory:GetProduction(gRecipeSelection)
			if count and count > 0 then
				table.insert(contents, Text { x=192,y=180,w=238,h=60, name="factory_production", label="#"..GetString("factory_config", tostring(count)) })
				EnableWindow("use_recipe", true)
			elseif gCurrentFactory.port.name == Player.portName then
				-- Check ingredients
				local missing = false
				local needs = gRecipeSelection:GetNeeds()
				for name,need in pairs(needs) do
					local have = Player.ingredients[name] or 0
					if need > have then missing=true; break; end
				end
				
				-- Report missing ingredients
				if missing then
					table.insert(contents, Text { x=192,y=180,w=238,h=60, name="factory_production", label = "#"..GetString("factory_noingredients") })
					EnableWindow("use_recipe", false)
				else
					EnableWindow("use_recipe", true)
				end
			else
				table.insert(contents, Text { x=192,y=180,w=238,h=60, name="factory_production", label = "#"..GetString("factory_noconfig", GetString(gCurrentFactory.port.name)) })
				EnableWindow("use_recipe", false)
			end
		end
	elseif gRecipeSelection and gRecipeSelection:NumberMade() > 0 then
		-- Which factory makes the most of this product?
		local max = 0
		local maxFactory = nil
		for name,_ in pairs(Player.factories) do
			local f = _AllBuildings[name]
			local n = f:GetProduction(gRecipeSelection)
			if n > max then
				max = n
				maxFactory = f
			end
		end
		table.insert(contents, Text { x=192,y=180,w=238,h=60, name="factory_production", label = "#"..GetString("factory_other", GetString(maxFactory.port.name), tostring(max)) })
	end

elseif gCategorySelection and gCategorySelection.name == "user" and Player.customSlots == 0 then
	EnableWindow("use_recipe", false)

	-- TODO: Indicate that player has no custom slots...
	table.insert(contents, Text { x=62,y=19,w=338,h=307, name="recipe_desc", label="#"..GetString"recipe_noslots", flags=kVAlignCenter+kHAlignCenter })

elseif gCategorySelection and gCategorySelection.name == "user" then
	EnableWindow("use_recipe", false)

	-- TODO: Indicate this is a blank slot...
	table.insert(contents, Text { x=62,y=19,w=338,h=307, name="recipe_desc", label="#"..GetString"user_blankslot", flags=kVAlignCenter+kHAlignCenter })

else	--if gCategorySelection and gCategorySelection:KnownProductCount() > 0 then
	EnableWindow("use_recipe", false)

	-- Recipe name and description
--	table.insert(contents, Text { x=24,y=19,w=406,h=44, name="recipe_name", label="#"..gRecipeSelection:GetName(), font = { labelFontName, 22, Color(0,0,0 ,255)}, flags=kVAlignCenter+kHAlignLeft })
	table.insert(contents, Text { x=62,y=19,w=338,h=307, name="recipe_desc", label="#"..GetString"recipe_unknown", flags=kVAlignCenter+kHAlignCenter })
	
	-- Center at 99,144
-- JB: 12/8 we decided not to show unknown recipes in the book
--	table.insert(contents, gRecipeSelection:GetAppearanceHuge(35,80) )

--else

	-- TODO: No known products in this category

end

------------------------------------------------------------------------------

MakeDialog (contents)