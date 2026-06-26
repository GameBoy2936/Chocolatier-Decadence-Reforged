--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Recipe Grid View)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script renders the left-hand grid of available recipes within the active category.

-- ----------------------------------------------------------------------------
-- Pagination Reset Logic
-- ----------------------------------------------------------------------------
-- Ensures that if the player was on Page 2 of "Bars" and switches to "Blends", 
-- the UI resets to Page 1 so they don't see a blank page.
if not gLastViewedCategory or (gCategorySelection and gLastViewedCategory ~= gCategorySelection.name) then
	gRecipePage = 1
	if gCategorySelection then gLastViewedCategory = gCategorySelection.name end
end

gRecipePage = gRecipePage or 1

-- Safety fallbacks
if gRecipeSelection then gCategorySelection = gRecipeSelection.category end
if not gCategorySelection then
	gCategorySelection = _AllCategories.bar
	gRecipeSelection = gCategorySelection.products[1]
end

-- Triggers when the player clicks an icon in the grid
local function SelectProduct(prod)
	if gRecipeSelection ~= prod then
		-- Remove highlight from old selection
		if gRecipeSelection then SetBitmap(gRecipeSelection.code, "image/button_recipes_up") end
		
		-- Apply highlight to new selection
		gRecipeSelection = prod
		SetBitmap(gRecipeSelection.code, "image/button_recipes_selected")
		
		-- Update the right-hand panel to show the details of the newly selected recipe
		FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
	end
end

------------------------------------------------------------------------------
-- Layout Coordinates
------------------------------------------------------------------------------

-- Pre-defined offsets for the 3x4 grid slots
local buttonPositions = {
	{ x=8, y=0 },   { x=95, y=0 },   { x=183, y=0 },
	{ x=8, y=84 },  { x=95, y=84 },  { x=183, y=84 },
	{ x=8, y=169 }, { x=95, y=169 }, { x=183, y=169 },
	{ x=8, y=252 }, { x=95, y=252 }, { x=183, y=252 },
}

local contents = { BeginGroup() }
local itemsPerPage = 12

-- Math to determine which slice of the products array we are rendering
local startIndex = (gRecipePage - 1) * itemsPerPage + 1

------------------------------------------------------------------------------
-- Grid Generation (Standard Categories)
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
			local tint = Color(255, 255, 255, 0)
			
			-- Darken undiscovered recipes
			if not prod:IsKnown() then 
				tint = Color(128, 128, 128, 0)
			-- Show "New" burst on recipes that have never been manufactured (except basic bars)
			elseif (prod:NumberMade() == 0) and (gCategorySelection.name ~= "bar") then 
				table.insert(contents, Bitmap { x = info.x, y = info.y, image = "image/button_recipes_new_underlay" })
			end
			
			table.insert(contents,
				BitmapTint { 
					x = info.x, y = info.y, image = "image/button_recipes_up", name = prod.code, tint = tint,
					Rollover { 
						x = 34, y = 35, w = 64, h = 64,
						contents = "_AllProducts['" .. prod.code .. "']:RecipeBookRolloverContents()",
						command = function() SelectProduct(temp); SoundEvent("ui_click"); end,
						BitmapTint { x = 0, y = 0, image = "items/" .. prod.code, tint = tint },
					},
				})
		else
			-- If we reach the end of the array, render unavailable blank slots
			table.insert(contents, Bitmap { x = info.x, y = info.y, image = "image/button_recipes_unavailable" })
		end
	end
end

------------------------------------------------------------------------------
-- Grid Generation (User-Generated Recipes)
------------------------------------------------------------------------------

local function PrepareUser()
	local n = Player.customSlots
	
	for i = 1, itemsPerPage do
		local slotIndex = startIndex + i - 1
		local info = buttonPositions[i]
		
		-- Check if this slot index is within the maximum number of slots the player has unlocked
		if slotIndex <= n then
			local prod = gCategorySelection.products[slotIndex]
			if prod then
				-- Filled Slot: Display the player's custom recipe
				local temp = prod
				if (prod:NumberMade() == 0) and (gCategorySelection.name ~= "bar") then 
					table.insert(contents, Bitmap { x = info.x, y = info.y, image = "image/button_recipes_new_underlay" }) 
				end
				
				table.insert(contents,
					Bitmap { 
						x = info.x, y = info.y, image = "image/button_recipes_up", name = prod.code,
						Rollover { 
							x = 34, y = 35, w = 64, h = 64,
							contents = "_AllProducts['" .. prod.code .. "']:RecipeBookRolloverContents()",
							command = function() SelectProduct(temp); SoundEvent("ui_click"); end,
							prod:GetAppearance()
						},
					})
			else
				-- Empty Slot: The player has unlocked the slot, but hasn't created a recipe for it yet
				table.insert(contents,
					Bitmap { 
						x = info.x, y = info.y, image = "image/button_recipes_up",
						Rollover { 
							x = 34, y = 35, w = 64, h = 64,
							contents = "RecipeBookEmptySlotContents()",
							Bitmap { x = 0, y = 0, image = "items/unknown" },
						},
					})
			end
		else
			-- Locked Slot: The player hasn't earned this custom recipe slot yet
			table.insert(contents, Bitmap { x = info.x, y = info.y, image = "image/button_recipes_unavailable" })
		end
	end
end

------------------------------------------------------------------------------
-- Pagination Logic
------------------------------------------------------------------------------

local function PrevPage()
	if gRecipePage > 1 then
		SoundEvent("ui_click")
		gRecipePage = gRecipePage - 1
		FillWindow("recipe_category", "ui/recipe_category.lua")
	end
end

local function NextPage()
	local totalItems
	if gCategorySelection.name == "user" then
		totalItems = Player.customSlots or 0
	else
		totalItems = table.getn(gCategorySelection.products)
	end
	
	if (gRecipePage * itemsPerPage) < totalItems then
		SoundEvent("ui_click")
		gRecipePage = gRecipePage + 1
		FillWindow("recipe_category", "ui/recipe_category.lua")
	end
end

------------------------------------------------------------------------------
-- Layout Execution
------------------------------------------------------------------------------

if gCategorySelection and gCategorySelection.name == "user" then 
	PrepareUser()
else 
	PrepareNormal()
end

-- Render Pagination Controls
local totalItemsForPage
if gCategorySelection.name == "user" then
	totalItemsForPage = Player.customSlots or 0
else
	totalItemsForPage = table.getn(gCategorySelection.products)
end

-- Only show the arrows if the category exceeds 12 items
if totalItemsForPage > itemsPerPage then
	local arrowScale = 0.8
	local arrowY = 128 -- Vertically centered relative to the grid block
	
	-- Previous Button (Left Side)
	if gRecipePage > 1 then
		table.insert(contents, Button {
			x = 0, y = arrowY,
			graphics = { "image/button_arrow_left_up", "image/button_arrow_left_down", "image/button_arrow_left_over" },
			command = PrevPage,
			scale = arrowScale
		})
	end
	
	-- Next Button (Right Side)
	if (gRecipePage * itemsPerPage) < totalItemsForPage then
		table.insert(contents, Button {
			x = 260, y = arrowY,
			graphics = { "image/button_arrow_right_up", "image/button_arrow_right_down", "image/button_arrow_right_over" },
			command = NextPage,
			scale = arrowScale
		})
	end
	
	-- Current Page / Total Pages Indicator
	local totalPages = Floor((totalItemsForPage + itemsPerPage - 1) / itemsPerPage)
	
	table.insert(contents, Text {
		x = 0, y = 340, w = 289, h = 20,
		label = "#" .. gRecipePage .. " / " .. totalPages,
		font = { uiFontName, 14, BlackColor },
		flags = kHAlignCenter + kVAlignCenter
	})
end

------------------------------------------------------------------------------
-- UI Render Phase
------------------------------------------------------------------------------

MakeDialog(contents)

-- Apply final active-highlight overlay
if gRecipeSelection then
	local idx = -1
	for i, prod in ipairs(gCategorySelection.products) do
		if prod == gRecipeSelection then
			idx = i
			break
		end
	end
	
	-- Only highlight the selection if it is physically visible on the current page
	if idx >= startIndex and idx < startIndex + itemsPerPage then
		SetBitmap(gRecipeSelection.code, "image/button_recipes_selected")
	end
end