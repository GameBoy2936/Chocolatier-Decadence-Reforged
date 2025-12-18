--[[---------------------------------------------------------------------------
	Chocolatier Three: Recipe Book Dialog - Category Side
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

gRecipePage = gRecipePage or 1

if gRecipeSelection then gCategorySelection = gRecipeSelection.category end
if not gCategorySelection then
	gCategorySelection = _AllCategories.bar
	gRecipeSelection = gCategorySelection.products[1]
end

local function SelectProduct(prod)
	if gRecipeSelection ~= prod then
		if gRecipeSelection then SetBitmap(gRecipeSelection.code, "image/button_recipes_up") end
		gRecipeSelection = prod
		SetBitmap(gRecipeSelection.code, "image/button_recipes_selected")
		
--[[
		if gCurrentFactory then
			local allow = prod:IsKnown()
			if allow then
				local needs = prod:GetNeeds()
				for name,need in pairs(needs) do
					local have = Player.ingredients[name] or 0
					if need > have then allow = false end
				end
			end
			EnableWindow("use_recipe", allow)
		end
]]--
		
		FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
	end
end

------------------------------------------------------------------------------

local buttonPositions =
{
	{ x=8,y=0 },
	{ x=95,y=0 },
	{ x=183,y=0 },
	{ x=8,y=84 },
	{ x=95,y=84 },
	{ x=183,y=84 },
	{ x=8,y=169 },
	{ x=95,y=169 },
	{ x=183,y=169 },
	{ x=8,y=252 },
	{ x=95,y=252 },
	{ x=183,y=252 },
}

local contents = { BeginGroup() }
local itemsPerPage = 12
local startIndex = (gRecipePage - 1) * itemsPerPage + 1

------------------------------------------------------------------------------

local function PrepareNormal()
	local n = table.getn(gCategorySelection.products)
	if n == 0 then return end
	
	for i = 1, itemsPerPage do
		local productIndex = startIndex + i - 1
		local prod = gCategorySelection.products[productIndex]
		local info = buttonPositions[i]

		if prod then
			local temp = prod
			local tint = Color(255,255,255,0)
			if not prod:IsKnown() then tint = Color(128,128,128,0)
			elseif (prod:NumberMade() == 0) and (gCategorySelection.name ~= "bar") then table.insert(contents, Bitmap { x=info.x,y=info.y, image="image/button_recipes_new_underlay" })
			end
			table.insert(contents,
				BitmapTint { x=info.x,y=info.y, image="image/button_recipes_up", name=prod.code, tint=tint,
					Rollover { x=34,y=35, w=64,h=64,
						contents = "_AllProducts['"..prod.code.."']:RecipeBookRolloverContents()",
						command=function() SelectProduct(temp); SoundEvent("ui_click"); end,
--						prod:GetAppearance()
						BitmapTint { x=0,y=0, image="items/"..prod.code, tint=tint },
					},
				})
--[[				
				Button { x=info.x, y=info.y, name=prod.code, graphics=graphics, type=kRadio, command=function() SelectProduct(temp) end,
--					prod:GetAppearanceBig(18,19)
					prod:GetAppearance(34,35)
				})
]]--
		else
			-- This slot is empty on the last page, so show an unavailable button.
			table.insert(contents, Bitmap { x=info.x,y=info.y, image="image/button_recipes_unavailable" })
		end
	end
end

------------------------------------------------------------------------------

local function PrepareUser()
	local n = Player.customSlots
	
	for i = 1, itemsPerPage do
		local slotIndex = startIndex + i - 1
		local info = buttonPositions[i]
		
		-- Check if this slot index is within the number of slots the player has unlocked.
		if slotIndex <= n then
			local prod = gCategorySelection.products[slotIndex]
			if prod then
				-- This is a filled slot, display the created recipe.
				local temp = prod
				if (prod:NumberMade() == 0) and (gCategorySelection.name ~= "bar") then table.insert(contents, Bitmap { x=info.x,y=info.y, image="image/button_recipes_new_underlay" }) end
				table.insert(contents,
					Bitmap { x=info.x,y=info.y, image="image/button_recipes_up", name=prod.code,
						Rollover { x=34,y=35, w=64,h=64,
							contents = "_AllProducts['"..prod.code.."']:RecipeBookRolloverContents()",
							command=function() SelectProduct(temp); SoundEvent("ui_click"); end,
							prod:GetAppearance()
						},
					})
--[[
			table.insert(contents,
				Button { x=info.x, y=info.y, graphics=graphics, type=kRadio,
					name=prod.code, command=function() SelectProduct(temp) end,
					prod:GetAppearance(34,35)
				})
]]--				
			else
				-- This is an available but empty slot.
				table.insert(contents,
					Bitmap { x=info.x,y=info.y, image="image/button_recipes_up",
						Rollover { x=34,y=35, w=64,h=64,
							contents = "RecipeBookEmptySlotContents()",
							Bitmap { x=0,y=0, image="items/unknown" },
						},
					})
--[[			
				Button { x=info.x, y=info.y, graphics=graphics, type=kRadio,
					command=function() SelectProduct(null) end,
					Bitmap { x=34,y=35, image="items/unknown" },
					
				})
]]--
			end
		else
			-- This slot is beyond the number of custom slots the player has.
			table.insert(contents, Bitmap { x=info.x,y=info.y, image="image/button_recipes_unavailable" })
		end
	end
end

------------------------------------------------------------------------------

if gCategorySelection and gCategorySelection.name == "user" then PrepareUser()
else PrepareNormal()
end

------------------------------------------------------------------------------

MakeDialog (contents)
if gRecipeSelection then
	SetBitmap(gRecipeSelection.code, "image/button_recipes_selected")
--	SetButtonToggleState(gRecipeSelection.code, true)
end