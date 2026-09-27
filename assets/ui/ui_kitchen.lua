--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Test Kitchen UI)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- UI State Initialization
-------------------------------------------------------------------------------

local targetCategory = gDialogTable.targetCategory or "bar"
local usedSlotCount = gDialogTable.usedSlotCount or 3
local ingredients = gDialogTable.ingredients or {}
local colors = gDialogTable.colors or { 1, 1, 1, 1 }
local openDrawer = gDialogTable.openDrawer
local design = gDialogTable.design or { 0, 0, 0, 0 }
local productName = gDialogTable.productName or productName
local productDescription = gDialogTable.productDescription or productDescription

local autoRandomize = true

-- Community Creations load into the active Test Kitchen workspace.
require("community/api.lua")
ClearStringCache()

-- Compatibility entry point for direct developer imports.
local startupCommunityCreation = gDialogTable and gDialogTable.communityCreation or nil
local startupCommunityCreationId = gDialogTable and gDialogTable.communityCreationId or nil

-- Tracks the Community origin of the recipe currently on Teddy's bench. It is
-- deliberately session-local until the player commits the recipe to the Recipe
-- Book, at which point a compact provenance record is stored in Player.
local communitySource = nil

local defaultProductName = GetString("recipe_name_default")
local defaultProductDescription = GetString("recipe_description_default")

local kBottleWidth = 40

-------------------------------------------------------------------------------
-- Color Palette Definitions (RGBA)
-------------------------------------------------------------------------------
local colorOptions =
{
	-- Browns and Tans (Chocolate Colors)
	Color(40, 22, 8, 255),    Color(67, 29, 8, 255),    Color(82, 35, 7, 255),    Color(99, 41, 16, 255),   Color(116, 50, 28, 255),  Color(154, 81, 46, 255),
	Color(244, 224, 151, 255),Color(225, 187, 116, 255),Color(238, 178, 106, 255),Color(204, 127, 35, 255), Color(160, 119, 89, 255), Color(138, 87, 69, 255),

	-- White, Greys and Blacks
	Color(0, 0, 0, 255),      Color(59, 59, 59, 255),   Color(115, 115, 115, 255),Color(176, 176, 176, 255),Color(227, 227, 227, 255),Color(255, 255, 255, 255),

	-- Reds
	Color(255, 184, 184, 255),Color(237, 78, 78, 255),  Color(209, 2, 2, 255),    Color(145, 12, 12, 255),  Color(87, 3, 3, 255),     Color(31, 0, 0, 255),

	-- Oranges
	Color(33, 11, 2, 255),    Color(87, 36, 10, 255),   Color(174, 72, 20, 255),  Color(250, 99, 35, 255),  Color(255, 133, 84, 255), Color(255, 200, 184, 255),
	Color(255, 224, 189, 255),Color(255, 176, 87, 255), Color(250, 141, 10, 255), Color(204, 127, 35, 255), Color(77, 42, 0, 255),    Color(28, 17, 3, 255),

	-- Yellows
	Color(31, 18, 0, 255),    Color(106, 74, 11, 255),  Color(201, 133, 4, 255),  Color(245, 162, 7, 255),  Color(255, 191, 107, 255),Color(255, 217, 184, 255),
	Color(255, 235, 184, 255),Color(255, 232, 107, 255),Color(247, 228, 30, 255), Color(191, 175, 0, 255),  Color(128, 117, 0, 255),  Color(31, 27, 0, 255),

	-- Greens
	Color(24, 31, 0, 255),    Color(92, 106, 11, 255),  Color(149, 174, 20, 255), Color(204, 235, 56, 255), Color(224, 255, 107, 255),Color(245, 255, 184, 255),
	Color(217, 255, 184, 255),Color(179, 255, 107, 255),Color(153, 235, 56, 255), Color(103, 174, 20, 255), Color(61, 106, 11, 255),  Color(15, 31, 0, 255),
	Color(6, 31, 0, 255),     Color(30, 106, 11, 255),  Color(56, 174, 20, 255),  Color(102, 235, 56, 255), Color(140, 255, 107, 255),Color(200, 255, 184, 255),
	Color(184, 255, 200, 255),Color(107, 255, 140, 255),Color(56, 235, 102, 255), Color(20, 174, 56, 255),  Color(11, 106, 30, 255),  Color(0, 31, 4, 255),

	-- Cyans
	Color(0, 31, 13, 255),    Color(11, 106, 61, 255),  Color(20, 174, 103, 255), Color(56, 235, 153, 255), Color(107, 255, 209, 255),Color(184, 255, 217, 255),
	Color(184, 255, 245, 255),Color(107, 255, 224, 255),Color(56, 235, 204, 255), Color(20, 174, 149, 255), Color(11, 106, 92, 255),  Color(0, 31, 24, 255),
	Color(0, 31, 31, 255),    Color(11, 106, 106, 255), Color(20, 174, 174, 255), Color(56, 235, 235, 255), Color(107, 255, 255, 255),Color(184, 255, 255, 255),

	-- Blues
	Color(184, 245, 255, 255),Color(107, 224, 255, 255),Color(56, 204, 235, 255), Color(20, 149, 174, 255), Color(11, 92, 106, 255),  Color(0, 24, 31, 255),
	Color(0, 13, 31, 255),    Color(11, 61, 106, 255),  Color(20, 103, 174, 255), Color(56, 153, 235, 255), Color(107, 209, 255, 255),Color(184, 217, 255, 255),
	Color(184, 200, 255, 255),Color(107, 140, 255, 255),Color(56, 102, 235, 255), Color(20, 56, 174, 255),  Color(11, 30, 106, 255),  Color(0, 4, 31, 255),

	-- Purples
	Color(6, 0, 31, 255),     Color(30, 11, 106, 255),  Color(56, 20, 174, 255),  Color(102, 56, 235, 255), Color(140, 107, 255, 255),Color(200, 184, 255, 255),
	Color(217, 184, 255, 255),Color(179, 107, 255, 255),Color(153, 56, 235, 255), Color(103, 20, 174, 255), Color(61, 11, 106, 255),  Color(15, 0, 31, 255),

	-- Magentas
	Color(24, 0, 31, 255),    Color(92, 11, 106, 255),  Color(149, 20, 174, 255), Color(204, 56, 235, 255), Color(224, 107, 255, 255),Color(245, 184, 255, 255),
	Color(255, 184, 235, 255),Color(255, 107, 232, 255),Color(235, 56, 219, 255), Color(174, 20, 177, 255), Color(106, 11, 102, 255), Color(31, 0, 27, 255),

	-- Pinks and Crimsons
	Color(31, 0, 18, 255),    Color(106, 11, 74, 255),  Color(174, 20, 125, 255), Color(235, 56, 165, 255), Color(255, 107, 191, 255),Color(255, 184, 217, 255),
	Color(255, 184, 200, 255),Color(255, 107, 149, 255),Color(235, 56, 111, 255), Color(174, 20, 72, 255),  Color(106, 11, 43, 255),  Color(31, 0, 9, 255),
}

-------------------------------------------------------------------------------
-- Dynamic UI Methods
-------------------------------------------------------------------------------

local function SetDynamicFeedbackText(text)
	-- Dynamically adjusts the font size of Teddy's feedback text box by finding
	-- the largest possible font size that will cleanly fit the text. (LUA 5.0 COMPATIBLE)

	local function Ceil(x)
		return Floor(x + 0.99999)
	end

	-- 1. Define our rendering rules: font sizes, their character-per-line estimates, and max line limits
	local font_sizes_to_check = {18, 16, 14, 12}
	local chars_per_line_map = {[18] = 38,
		[16] = 50,
		[14] = 62,
		[12] = 74,
	}
	local line_thresholds = {[18] = 5, -- Size 18 is only allowed if the text fits within 5 lines
		[16] = 6, -- Size 16 is only allowed if the text fits within 6 lines
		[14] = 7, -- Size 14 is only allowed if the text fits within 7 lines
		[12] = 999, -- Size 12 is the universal fallback
	}

	-- 2. Manually split the string by the "<br>" delimiter to count hard breaks
	local segments = {}
	local current_pos = 1
	if text then
		local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
		while start_pos do
			table.insert(segments, string.sub(text, current_pos, start_pos - 1))
			current_pos = end_pos + 1
			start_pos, end_pos = string.find(text, "<br>", current_pos, true)
		end
		table.insert(segments, string.sub(text, current_pos))
	end

	if table.getn(segments) == 0 then segments = { text or "" } end

	-- 3. Iterate through our font sizes to find the best fit
	local final_font_size = 12
	for _, current_font_size in ipairs(font_sizes_to_check) do
		local chars_per_line = chars_per_line_map[current_font_size]
		local line_threshold = line_thresholds[current_font_size]

		-- Calculate the total lines based on THIS font size's character estimate
		local total_lines = table.getn(segments) - 1
		for _, segment in ipairs(segments) do
			total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
		end

		-- If the calculated lines are within the UI threshold, we lock it in
		if total_lines <= line_threshold then
			final_font_size = current_font_size
			break
		end
	end

	DebugOut("UI", string.format("Kitchen feedback string requires dynamic font size %d to fit safely.", final_font_size))

	-- 4. Apply the final font size HTML tag and push the text to the UI element
	local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
	SetLabel("feedback", formatted_text)
end

-- Toggles visibility of "Clear" and "Design" buttons depending on active bowl states
local function UpdateRecipeButtons()
	EnableWindow("clear_recipe", false)
	EnableWindow("add_recipe", true)

	for i = 1, usedSlotCount do
		if ingredients[i] then
			EnableWindow("clear_recipe", true) -- Allow "clear all" if at least one is full
		else
			EnableWindow("add_recipe", false)  -- Disallow proceeding to design if any active slot is empty
		end
	end
end

-- Empties a specific mixing bowl slot
local function ClearSlot(i)
	SetBitmap("slot_" .. i, "")
	ingredients[i] = nil
	UpdateRecipeButtons()
	EnableWindow("design_recipe", false)
end

-- Empties all active mixing bowl slots and resets UI state
local function ClearAllSlots()
	DebugOut("RECIPE", "All active recipe ingredient slots cleared by player.")
	-- Start Over / category changes sever the Community lineage. Individual bowl
	-- edits do not: those are what turn a loaded creation into a genuine remix.
	communitySource = nil
	for i = 1, 6 do
		SetBitmap("slot_" .. i, "")
		ingredients[i] = nil
	end

	EnableWindow("new_recipe", false)
	EnableWindow("add_recipe", false)
	EnableWindow("design_recipe", false)
	SetDynamicFeedbackText(GetRandomString("invent_instructions"))
end

-- Hides or reveals ingredient mixing bowls depending on the current required slot count
local function UpdateBowlAndSlotVisibility()
	for i = 1, 6 do
		if i <= usedSlotCount then
			EnableWindow("bowl_" .. i, true)
			EnableWindow("slot_" .. i, true)
		else
			EnableWindow("bowl_" .. i, false)
			EnableWindow("slot_" .. i, false)

			-- Eject any ingredient stuck in a slot we are now hiding
			if ingredients[i] then
				ingredients[i] = nil
				SetBitmap("slot_" .. i, "")
			end
		end
	end

	UpdateRecipeButtons()

	local category = _AllCategories[targetCategory]
	if category then
		-- Allow removing a slot only while the category minimum is preserved.
		EnableWindow("remove_slot_button", usedSlotCount > tonumber(category.min_ingredients))

		-- Allow adding a slot only while the category maximum is preserved.
		EnableWindow("add_slot_button", usedSlotCount < tonumber(category.max_ingredients))
	else
		-- Disable slot controls if category data is unavailable.
		EnableWindow("remove_slot_button", false)
		EnableWindow("add_slot_button", false)
	end
end

function AddIngredientSlot()
	local category = _AllCategories[targetCategory]

	if usedSlotCount < tonumber(category.max_ingredients) then
		usedSlotCount = usedSlotCount + 1
		DebugOut("RECIPE", string.format("Added additional ingredient slot. Total active slots: %d", usedSlotCount))
		UpdateBowlAndSlotVisibility()
	end
end

function RemoveIngredientSlot()
	local category = _AllCategories[targetCategory]

	if usedSlotCount > tonumber(category.min_ingredients) then
		-- Eject the active ingredient from the final slot before physically removing the slot itself
		ClearSlot(usedSlotCount)
		usedSlotCount = usedSlotCount - 1
		DebugOut("RECIPE", string.format("Removed ingredient slot. Total active slots: %d", usedSlotCount))
		UpdateBowlAndSlotVisibility()
	end
end

-- Modifies the underlying recipe framework base (e.g., Bar vs Truffle vs Exotic)
local function SetTargetCategory(cat)
	SetButtonToggleState(cat, true)
	targetCategory = cat
	autoRandomize = true

	DebugOut("RECIPE", string.format("Player selected recipe machinery category: %s", cat))

	-- Re-align the active slots to the default baseline for the new category type
	if cat == "bar" then usedSlotCount = 3
	elseif cat == "beverage" then usedSlotCount = 3
	elseif cat == "infusion" then usedSlotCount = 4
	elseif cat == "truffle" then usedSlotCount = 6
	elseif cat == "blend" then usedSlotCount = 4
	elseif cat == "exotic" then usedSlotCount = 5
	end

	UpdateBowlAndSlotVisibility()
	ClearAllSlots()
end

-- Injects a selected ingredient from the drawer into the next available mixing bowl
local function AddSlotIngredient(ing, slot)
	local success = false
	for i = 1, usedSlotCount do
		if not ingredients[i] then
			success = true
			ingredients[i] = ing
			SetBitmap("slot_" .. i, "items/" .. ing.name .. "_big")
			DebugOut("RECIPE", string.format("Player added ingredient '%s' to mixing bowl %d.", ing.name, i))
			break
		end
	end

	if success then UpdateRecipeButtons() end
	return success
end

-------------------------------------------------------------------------------
-- Design & Visual Tinting Logic
-------------------------------------------------------------------------------

function SetRecipeTint(layer, index)
	-- Wrap around safely
	if index > table.getn(colorOptions) then
		index = Mod(index, table.getn(colorOptions)) + 1
	end

	colors[layer] = index
	SetRectangleColor("tint" .. layer, colorOptions[index])
	BTSetTint("option_layer" .. (layer - 1), colorOptions[index])
	BTSetTint("display_layer" .. (layer - 1), colorOptions[index])
end

-- Triggers the pop-out palette UI
local function SelectTint(layer, x, y)
	newColor = DisplayDialog { "ui/ui_colorselect.lua", image = ingredients[layer], colors = colorOptions, x = x, y = y }
	if newColor then SetRecipeTint(layer, newColor) end
end

local function IncLayer(field)
	design[field] = SetLayer(field - 1, design[field] + 1)
end

local function DecLayer(field)
	design[field] = SetLayer(field - 1, design[field] - 1)
end

-------------------------------------------------------------------------------
-- Ingredient Drawer Mapping
-------------------------------------------------------------------------------

-- Physically sort the global ingredient list into the nine Test Kitchen drawers.
-- Six drawer tabs are visible at once; the arrow controls swap between two
-- overlapping banks so the original drawer artwork can retain its full width.
-- Ingredient XML may still override the Kitchen drawer independently of recipe
-- balance via kitchen_category / recipe_family metadata.
local categorized = { cacao={}, coffee={}, tea={}, dairy={}, sugar={}, fruit={}, nut={}, flavor={}, liqueur={} }

-- Drawer labels are separate from ingredient IDs.  In particular, the ingredient
-- key "tea" is localized as "Black Tea", so the category needs its own label.
local drawerLabels = {
	cacao = "cacao",
	coffee = "coffee",
	tea = "kitchen_category_tea",
	dairy = "dairy",
	sugar = "sugar",
	fruit = "fruit",
	nut = "nut",
	flavor = "flavor",
	liqueur = "kitchen_category_liqueur",
}

-- Resolve drawer headings through the active localization table before passing
-- them to UI widgets.  Button/Text label properties do not behave identically
-- for dynamically selected keys, so using a literal localized label keeps open
-- and closed drawers consistent in every language.
local function GetDrawerLabel(name)
	local key = drawerLabels[name] or name
	return "#" .. GetString(key)
end

-- Keep the two busiest open drawers clear of the drawer-bank arrow controls.
-- The tab artwork itself remains full size; only the ingredient-vial layout is
-- constrained for these drawers.  Arrow hitboxes occupy roughly x=18-44 and
-- x=739-765 at the current scale, so 50..735 leaves a small safety margin.
local drawerContentBounds = {
	fruit  = { left = 50, right = 735 },
	flavor = { left = 50, right = 735 },
}

for _, ing in ipairs(_IngredientOrder) do
	local drawer = ing.GetKitchenCategory and ing:GetKitchenCategory() or ing.category
	if categorized[drawer] then
		table.insert(categorized[drawer], ing)
	else
		DebugOut("ERROR", string.format("Ingredient '%s' has no valid Test Kitchen drawer '%s'.", tostring(ing.name), tostring(drawer)))
	end
end

local function ToggleDrawer(windowName)
	if windowName == openDrawer then windowName = nil end

	-- Close previous active drawer.  Drawer windows are page-specific so the open
	-- drawer graphic always lines up under the tab the player actually clicked.
	if openDrawer then
		EnableWindow(openDrawer, false)
		openDrawer = nil
	end

	if windowName then
		openDrawer = windowName
		EnableWindow(openDrawer, true)
		DebugOut("UI", string.format("Player opened ingredient drawer window: %s", windowName))
	end
end

local drawerPage = 1

local function SetDrawerPage(page)
	if page < 1 then page = 1 end
	if page > 2 then page = 2 end
	if page == drawerPage then return end

	-- A page shift closes the open drawer first.  This avoids leaving an open tab
	-- visually attached to a category that has just scrolled off-screen.
	if openDrawer then ToggleDrawer(nil) end

	drawerPage = page
	EnableWindow("drawer_tabs_page_1", drawerPage == 1)
	EnableWindow("drawer_tabs_page_2", drawerPage == 2)
	DebugOut("UI", string.format("Test Kitchen drawer bank changed to page %d.", drawerPage))
end

local function ScrollDrawers(delta)
	SetDrawerPage(drawerPage + delta)
end

-- Dynamically generates the visual drawer UI based on the player's unlocked ingredients.
-- Modified to support dynamic row-wrapping for categories that exceed screen width (like Flavors).
local function IngredientDrawer(t)
	local name = t.name
	local windowName = t.window_name or name
	local vials = {}
	local y = 32

	local ingredients_in_drawer = categorized[name]
	local num_ingredients = table.getn(ingredients_in_drawer)
	local bounds = drawerContentBounds[name] or { left = 5, right = 773 }
	local leftBound = bounds.left
	local rightBound = bounds.right

	-- Max horizontal capacity before the drawer graphics clip the edge of the UI
	local max_per_row = 17

	if num_ingredients > max_per_row then
		-- MULTI-ROW DRAWER LOGIC
		-- Calculates dynamic offset wrapping to prevent clipping
		local x_start = leftBound
		local x = x_start
		local row_num = 1

		for _, ing in ipairs(ingredients_in_drawer) do
			local temp = ing

			if Player.labIngredients[ing.name] then
				table.insert(vials,
					Rollover { x = x, y = y, fit = true,
						Bitmap { x = 0, y = 0, image = "image/kitchen_jar",
							Bitmap { x = 5, y = 14, image = "items/" .. ing.name },
						},
						contents = ing.name .. ":InventoryRolloverContents()",
						command = function() AddSlotIngredient(temp) end,
					})
			else
				-- If the player hasn't discovered it yet, render an empty jar
				table.insert(vials, Bitmap { x = x, y = y, image = "image/kitchen_jar_space" })
			end

			x = x + kBottleWidth

			-- Detect edge-clip and force a line break
			if x + kBottleWidth > rightBound then
				y = y + 60
				row_num = row_num + 1

				-- Alternate the starting X offset slightly for an interlocking honeycomb/triangular aesthetic
				if Mod(row_num, 2) == 0 then
					x = x_start + 20
				else
					x = x_start
				end
			end
		end
	else
		-- SINGLE-ROW DRAWER LOGIC
		-- Centers the jars dynamically if there's plenty of space
		local w = num_ingredients * kBottleWidth
		local x = t.x + 55 - w / 2

		if x < leftBound then x = leftBound end
		if x + w > rightBound then x = rightBound - w end

		for _, ing in ipairs(ingredients_in_drawer) do
			local temp = ing

			if Player.labIngredients[ing.name] then
				table.insert(vials,
					Rollover { x = x, y = y, fit = true,
						Bitmap { x = 0, y = 0, image = "image/kitchen_jar",
							Bitmap { x = 5, y = 14, image = "items/" .. ing.name },
						},
						contents = ing.name .. ":InventoryRolloverContents()",
						command = function() AddSlotIngredient(temp) end,
					})
			else
				table.insert(vials, Bitmap { x = x, y = y, image = "image/kitchen_jar_space" })
			end

			x = x + kBottleWidth
		end
	end

	-- Assemble and return the physical drawer group layer
	return Window
	{
		x = 0, y = t.y, name = windowName, fit = true,
		Bitmap { x = t.x, y = 0, image = "image/kitchen_drawer_open",
			-- The open drawer artwork is 110px wide.  This 91px label field is
			-- inset evenly and explicitly centered so short and long translations
			-- sit in the middle of the metal nameplate.
			Text { x = 9, y = 130, w = 92, h = 17, label = GetDrawerLabel(name),
				font = { labelFontName, 14, BlackColor }, flags = kHAlignCenter + kVAlignCenter },
		},
		Group(vials),
	}
end

-------------------------------------------------------------------------------
-- Evaluation & Action Logic
-------------------------------------------------------------------------------

-- Submits the bowl's contents to Teddy (recipe.lua) for culinary scoring
function TasteIt()
	local allFull = true
	for i = 1, usedSlotCount do
		if not ingredients[i] then allFull = false break end
	end

	if not allFull then
		SetDynamicFeedbackText(GetRandomString("taster_fillslots"))
	else
		DebugOut("RECIPE", "Player clicked 'Taste It'. Commencing evaluation.")

		local productCategory = _AllCategories[targetCategory]
		local feedback
		feedback, r, low, high, allow = EvaluatePlayerRecipe(productCategory, ingredients, usedSlotCount)

		SetDynamicFeedbackText(tostring(feedback))

		-- Check global limit logic: Allow them to proceed to naming/marketing IF they
		-- still have free UGR memory slots remaining.
		local category = _AllCategories.user
		if (Player.IsFreePlay and Player:IsFreePlay()) or (category and table.getn(category.products) < Player.customSlots) then
			EnableWindow("design_recipe", true)
		end

		-- Force disable if Teddy absolutely hates it and rejects it
		if not allow then EnableWindow("design_recipe", false) end

	end
end

local mode = "create_mode"

function CreateMode()
	mode = "create_mode"
	EnableWindow("design_mode", false)
	EnableWindow("create_mode", true)
	SetLabel("nameplate", GetString("title_kitchen"))
	DebugOut("UI", "Switched Test Kitchen to creation mode.")
end

function DesignMode()
	mode = "design_mode"
	SetRecipeType(targetCategory)
	EnableWindow("create_mode", false)
	EnableWindow("design_mode", true)
	SetLabel("nameplate", GetString("title_marketing"))
	DebugOut("UI", "Switched Test Kitchen to marketing mode.")

	-- Served Drinks use the glass-mug sandwich. Beverage Blends are packaged
	-- dry/ground mixes and render directly from their tin/package layers.
	local isServedDrink = (targetCategory == "beverage")
	if isServedDrink then
		SetBitmap("display_mug", "custom/" .. targetCategory .. "/mug")
		SetBitmap("display_rim_outer", "custom/" .. targetCategory .. "/rim_outer")
		SetBitmap("display_rim_inner", "custom/" .. targetCategory .. "/rim_inner")

		EnableWindow("display_mug", true)
		EnableWindow("display_rim_outer", true)
		EnableWindow("display_rim_inner", true)
	else
		EnableWindow("display_mug", false)
		EnableWindow("display_rim_outer", false)
		EnableWindow("display_rim_inner", false)
	end

	-- Auto-generate a random color profile so the player doesn't have to start from blank white
	if autoRandomize then
		autoRandomize = false
		RandomDesign()
	end
end

-------------------------------------------------------------------------------
-- Community Import / Duplicate Protection
-------------------------------------------------------------------------------

local function ColorChannelByte(value)
	if type(value) ~= "number" then return nil end
	if value >= 0 and value <= 1 then return Floor((value * 255) + 0.5) end
	return Floor(value + 0.5)
end

local function FindPaletteIndex(red, green, blue)
	for i, color in ipairs(colorOptions) do
		local r = ColorChannelByte(color[1])
		local g = ColorChannelByte(color[2])
		local b = ColorChannelByte(color[3])
		if r == red and g == green and b == blue then return i end
	end
	return 1
end

-- On some Playground builds, SetLayer() is effectively zero-based for real
-- assets, meaning selector state 0 can legitimately resolve to layerN_01. The
-- previous save/export logic treated any selector state <= 0 as blank, which
-- silently dropped imported Community layers that used the first art option.
-- Determine persistence from the resolved image name first, using selector
-- state only as a final fallback for truly blank/pseudo-blank layers.
local function HasPersistableLayer(layerIndexZeroBased)
	local image = GetLayerImage(layerIndexZeroBased)
	if not image or string.len(image) == 0 then
		return false, image
	end

	-- Explicit blank sentinels from older/newer engine builds.
	if string.find(image, "/layer[1-4]_0+$") then
		return false, image
	end

	-- Any numbered real asset should persist, even if the selector state that
	-- produced it happens to be zero on this build.
	if string.find(image, "/layer[1-4]_[0-9]+$") then
		return true, image
	end

	-- Last resort: preserve the legacy state-based behavior only for ambiguous
	-- image names we do not recognize.
	return (design[layerIndexZeroBased + 1] or 0) > 0, image
end

-- Restore a Community appearance by its exact registered asset name. The native
-- SetLayer selector is zero-based in some Playground builds even though custom
-- assets are numbered from 01. Try the expected corrected index first, then
-- verify against GetLayerImage() so imports remain safe across engine builds.
local function SetCommunityLayerImage(layer, image, option)
	local candidates = { option - 1, option, option + 1 }
	local tried = {}
	for _, candidate in ipairs(candidates) do
		if candidate >= 0 and not tried[candidate] then
			tried[candidate] = true
			local state = SetLayer(layer - 1, candidate)
			if GetLayerImage(layer - 1) == image then
				return state
			end
		end
	end

	DebugOut("COMMUNITY", string.format(
		"Could not verify exact imported appearance '%s' on layer %d; using corrected selector index %d.",
		tostring(image), layer, option - 1
	))
	local corrected = option - 1
	if corrected < 0 then corrected = 0 end
	return SetLayer(layer - 1, corrected)
end

local function HasCommunityTag(metadata, wanted)
	if not metadata or type(metadata.tags) ~= "table" then return false end
	for _, tag in ipairs(metadata.tags) do
		if tag == wanted then return true end
	end
	return false
end

local function CommunityCategoryDescriptor(category)
	local descriptors =
	{
		bar = "chocolate bar",
		beverage = "drink",
		infusion = "chocolate infusion",
		truffle = "truffle",
		blend = "beverage blend",
		exotic = "exotic confection",
	}
	return descriptors[category] or "creation"
end

local function CommunityKitchenLoadedFeedback(imported, metadata)
	metadata = metadata or {}
	local candidates = {}
	local function AddCandidate(key, weight)
		weight = weight or 1
		for i = 1, weight do table.insert(candidates, key) end
	end

	local categoryKey =
	{
		bar = "bar",
		beverage = "drink",
		infusion = "infusion",
		truffle = "truffle",
		blend = "bevblend",
		exotic = "exotic",
	}
	local categorySuffix = categoryKey[imported.category]
	if categorySuffix then
		AddCandidate("community_kitchen_loaded_main_tedd_" .. categorySuffix, 3)
	end

	local ratingAverage = tonumber(metadata.rating_average) or 0
	local ratingCount = tonumber(metadata.rating_count) or 0
	if ratingCount >= 3 then
		if ratingAverage >= 4.0 then
			AddCandidate("community_kitchen_loaded_main_tedd_highrated", 4)
		elseif ratingAverage <= 2.5 then
			AddCandidate("community_kitchen_loaded_main_tedd_lowrated", 4)
		end
	end

	local loadCount = tonumber(metadata.load_count) or 0
	if loadCount >= 10 then
		AddCandidate("community_kitchen_loaded_main_tedd_popular", 2)
	end

	if metadata.is_owned == true then
		AddCandidate("community_kitchen_loaded_main_tedd_own", 2)
	else
		local author = metadata.author and tostring(metadata.author.public_name or "") or ""
		if author ~= "" then
			AddCandidate("community_kitchen_loaded_main_tedd_creator", 1)
		end
	end

	if HasCommunityTag(metadata, "experimental") then
		AddCandidate("community_kitchen_loaded_main_tedd_experimental", 2)
	end
	if HasCommunityTag(metadata, "boozy") then
		AddCandidate("community_kitchen_loaded_main_tedd_boozy", 1)
	end
	if HasCommunityTag(metadata, "savoury") then
		AddCandidate("community_kitchen_loaded_main_tedd_savoury", 1)
	end
	if HasCommunityTag(metadata, "tropical") then
		AddCandidate("community_kitchen_loaded_main_tedd_tropical", 1)
	end

	AddCandidate("community_kitchen_loaded_main_tedd_general", 1)

	local key = candidates[RandRange(1, table.getn(candidates))]
	local authorName = metadata.author and tostring(metadata.author.public_name or "") or ""
	local text = GetRandomString(
		key,
		imported.name,
		CommunityCategoryDescriptor(imported.category),
		string.format("%.1f", ratingAverage),
		tostring(ratingCount),
		tostring(loadCount),
		authorName
	)

	if not text or text == "" or text == key then
		return GetString("community_kitchen_loaded", imported.name)
	end
	return text
end

local function ApplyCommunityAppearance(imported)
	if not imported then return end

	-- Start from blank layer selectors, then restore each canonical layer by its
	-- saved asset index and exact Test Kitchen palette colour.
	for layer = 1, 4 do
		design[layer] = SetLayer(layer - 1, 0)
	end

	for _, layerInfo in ipairs(imported.appearance or {}) do
		local image = layerInfo[1]
		local _, _, layerText, optionText = string.find(image or "", "/layer([1-4])_([0-9]+)$")
		local layer = tonumber(layerText)
		local option = tonumber(optionText)
		if layer and option then
			design[layer] = SetCommunityLayerImage(layer, image, option)
			SetRecipeTint(layer, FindPaletteIndex(layerInfo[2], layerInfo[3], layerInfo[4]))
		end
	end
end

local function CurrentRecipeSignature()
	local active = {}
	for i = 1, usedSlotCount do
		if ingredients[i] then table.insert(active, ingredients[i]) end
	end
	if table.getn(active) ~= usedSlotCount then return nil end
	local codeTable = BuildCodeTable(active, targetCategory)
	return string.lower(table.concat(codeTable, "_"))
end

local function HasSavedRecipeSignature(signature)
	if not signature or not Player or type(Player.itemRecipes) ~= "table" then return false end
	for _, codeTable in ipairs(Player.itemRecipes) do
		if type(codeTable) == "table" and string.lower(table.concat(codeTable, "_")) == signature then
			return true
		end
	end
	if Player.IsFreePlay and Player:IsFreePlay() and Player.storyCreationLibrary then
		for _, codeTable in ipairs(Player.storyCreationLibrary.recipes or {}) do
			if type(codeTable) == "table" and string.lower(table.concat(codeTable, "_")) == signature then
				return true
			end
		end
	end
	return false
end

local function ApplyCommunityCreationToWorkspace(value, creationId, metadata)
	local imported, importError = CommunityCreation.ToKitchenData(value)
	if not imported then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. tostring(importError) }
		DebugOut("COMMUNITY", "Could not import Community Creation: " .. tostring(importError))
		return false
	end

	-- Let the normal category method clear stale bowls and establish machinery,
	-- then resize it to the exact imported ingredient count.
	SetTargetCategory(imported.category)
	usedSlotCount = table.getn(imported.ingredients)
	UpdateBowlAndSlotVisibility()

	for i = 1, usedSlotCount do
		local ingObj = _AllIngredients[imported.ingredients[i]]
		if not ingObj then
			DisplayDialog { "ui/ui_generic.lua", text = "#Unknown imported ingredient." }
			return false
		end
		ingredients[i] = ingObj
		SetBitmap("slot_" .. i, "items/" .. ingObj.name .. "_big")
	end

	productName = imported.name
	productDescription = imported.description
	SetLabel("product_name", productName)
	SetLabel("product_desc", productDescription)

	-- The designer exists even while Creation Mode is visible. Prime its recipe
	-- type and exact downloaded appearance without forcing the player into
	-- Marketing Mode; they can inspect/edit ingredients immediately, then Taste.
	autoRandomize = false
	SetRecipeType(targetCategory)
	ApplyCommunityAppearance(imported)

	-- Set provenance only after the workspace has accepted the creation. The
	-- earlier SetTargetCategory() call intentionally clears any previous source.
	metadata = metadata or {}
	local sourceSignature = CommunityCreation.CoreSignature(imported)
	communitySource =
	{
		creation_id = tostring(creationId or ""),
		profile_id = metadata.author and tostring(metadata.author.profile_id or "") or "",
		public_name = metadata.author and tostring(metadata.author.public_name or "") or "",
		is_owned = metadata.is_owned == true,
		core_signature = sourceSignature or "",
	}

	UpdateRecipeButtons()
	EnableWindow("design_recipe", true)
	CreateMode()
	SetDynamicFeedbackText(CommunityKitchenLoadedFeedback(imported, metadata))

	DebugOut("COMMUNITY", "Loaded Community creation into the active Test Kitchen: " .. tostring(imported.name))

	-- Count a load only after the workspace actually accepted the creation.
	if creationId and creationId ~= "" and not CommunityTransport.IsBusy() then
		CommunityApi.RecordLoad(creationId, function(body, response, err)
			if err then
				DebugOut("COMMUNITY", "Creation loaded, but load-count update failed: " .. tostring(err))
			end
		end)
	end
	return true
end

function OpenCommunityCookbook()
	-- The modal Cookbook returns its selected Creation through a short-lived global.
	gCommunityKitchenImport = nil
	DisplayDialog {
		"ui/community_cookbook.lua",
		allow_load = true,
		source = "test_kitchen",
	}

	local pending = gCommunityKitchenImport
	gCommunityKitchenImport = nil
	if pending and pending.creation then
		ApplyCommunityCreationToWorkspace(pending.creation, pending.id, pending.metadata)
	end
end

-------------------------------------------------------------------------------
-- Data Finalization & Persistence
-------------------------------------------------------------------------------

local function DoRecipeCreation()
	-- Gather the ingredients safely (ignoring blanks if the array was modified)
	local ings = {}
	for i = 1, usedSlotCount do
		if ingredients[i] then table.insert(ings, ingredients[i]) end
	end

	productName = GetLabel("product_name")
	productDescription = GetLabel("product_desc")

	-- Compile the active visual profile
	local appearance = {}
	for i = 0, 3 do
		local shouldPersist, image = HasPersistableLayer(i)
		local tint = colors[i + 1]
		tint = colorOptions[tint]

		if shouldPersist and image and string.len(image) > 0 then
			-- Local recipe persistence must keep the engine-native tint channel
			-- representation exactly as the original game expects. Community
			-- JSON uses byte RGB through CommunityCreation.Normalize(), but
			-- Player.itemAppearance should continue storing the native values
			-- directly so Recipe Book / factory / shop rendering does not
			-- reinterpret 0-255 bytes as live tint channels.
			table.insert(appearance, {
				image,
				tint[1],
				tint[2],
				tint[3]
			})
		end
	end

	-- Commit the recipe permanently into the player's save structure
	local recipe = CreateCustomRecipe(productName, productDescription, ings, appearance, targetCategory)

	if recipe then
		-- If this began as a Community recipe, carry its origin into the saved
		-- UGR. Only category + ordered ingredients define whether it remains an
		-- unchanged copy or has become a remix; marketing changes alone do not.
		if communitySource then
			local savedIngredientNames = {}
			for _, ing in ipairs(ings) do
				table.insert(savedIngredientNames, ing.name)
			end
			local savedCreation =
			{
				name = productName,
				description = productDescription,
				category = targetCategory,
				ingredients = savedIngredientNames,
				appearance = appearance,
			}
			local recorded, recordError = CommunityCreation.RecordSavedRecipeSource(recipe, communitySource, savedCreation)
			if not recorded then
				DebugOut("COMMUNITY", "Could not preserve Community recipe provenance: " .. tostring(recordError))
			end
		end

		gRecipeSelection = recipe
		QueueCommand(function() DisplayDialog{"ui/ui_recipes.lua"} end)
		CloseWindow()
	end
end

-- Validates strings and checks for global collisions before finalizing
local function ConfirmRecipeCreation()
	productName = GetLabel("product_name")
	productDescription = GetLabel("product_desc")

	-- Free Play deliberately has no gameplay-imposed Creation cap.
	if (not (Player.IsFreePlay and Player:IsFreePlay())) and (Player.categoryCount.user or 0) >= (Player.customSlots or 0) then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("recipe_noslots") }
		return
	end

	local signature = CurrentRecipeSignature()
	if signature and HasSavedRecipeSignature(signature) then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("recipe_saved_failed_duplicate", productName) }
		return
	end

	if productName == "" or productName == defaultProductName or productDescription == "" or productDescription == defaultProductDescription then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetRandomString("invent_noname") }
	else
		-- Ensure no existing product across the entire game uses this exact name string
		local nameOk = true
		local lowerName = string.lower(productName)

		for code, prod in pairs(_AllProducts) do
			local s = string.lower(prod:GetName())
			if lowerName == s then
				nameOk = false

				-- If this is an existing custom UGR, we CAN overwrite it assuming the
				-- player actually owns it (prevents stomping on mod/DLC products).
				if (not nameOk) and (prod.category.name == "user") and (not Player.itemNames[prod.code]) then
					nameOk = true
				end

				if (not nameOk) then break end
			end
		end

		if nameOk then
			local text = GetRandomString("invent_confirm")
			local yn = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. text }

			if yn == "yes" then DoRecipeCreation() end
		else
			-- Utilizing the %1% dynamic formatting parameter required by standard localized strings
			local text = GetRandomString("invent_name_inuse", productName)
			DisplayDialog { "ui/ui_generic.lua", text = "#" .. text }
		end
	end
end

-------------------------------------------------------------------------------
-- Mod Specific Utilities (Import/Export)
-------------------------------------------------------------------------------

function LoadCreation()
	DebugOut("UI", "Opening Community Cookbook from the Test Kitchen.")
	OpenCommunityCookbook()
end

function SaveCreation()
	DebugOut("UI", "Save Creation button clicked.")
	local currentName = GetLabel("product_name")
	local currentDesc = GetLabel("product_desc")

	if currentName == "" or currentName == defaultProductName or currentDesc == "" or currentDesc == defaultProductDescription then
		DisplayDialog { "ui/ui_generic.lua", text = "invent_noname" }
		return
	end

	-- Consolidate the entire workspace state into an exportable table
	local creationData = {}
	creationData.name = currentName
	creationData.description = currentDesc
	creationData.category = targetCategory

	creationData.ingredients = {}
	for i = 1, usedSlotCount do
		if ingredients[i] then
			table.insert(creationData.ingredients, ingredients[i].name)
		end
	end

	creationData.appearance = {}
	for i = 0, 3 do
		local shouldPersist, image = HasPersistableLayer(i)
		local tintIndex = colors[i + 1]
		local tint = colorOptions[tintIndex]
		if shouldPersist and image and string.len(image) > 0 then
			table.insert(creationData.appearance, { image, tint[1], tint[2], tint[3] })
		end
	end

	SaveCreationToFile(creationData)
end

-------------------------------------------------------------------------------
-- UI Rendering: Viewport Frames
-------------------------------------------------------------------------------

local CreationModeWindow = Bitmap
{
	x = 6, y = 16, image = "image/popup_back_kitchen", name = "create_mode", fit = true,

	SetStyle(C3DialogBodyStyle),
	CharWindow { x = 585, y = 38, name = "main_tedd", happiness = _AllCharacters["main_tedd"]:GetHappiness() },

	SetStyle(C3DialogBodyStyle),
	Text { x = 336, y = 39, w = 275, h = 110, name = "feedback", label = "invent_instructions", font = { uiFontName, 18, BlackColor }, flags = kHAlignLeft + kVAlignCenter },

	Text { x = 68, y = 23, w = 194, h = 24, label = "nowinventing", flags = kHAlignCenter + kVAlignCenter },

	SetStyle(C3ButtonStyle),
	Button { x = 328, y = 148, name = "clear_recipe", label = "clear_recipe", command = function() ClearAllSlots() end },
	Button { x = 470, y = 148, name = "design_recipe", label = "design_recipe", command = function() DesignMode() end },

	-- Machinery Category Toggles
	BeginGroup(),
	AppendStyle { tx = 30, type = kRadio, graphics = { "image/kitchen_category_unselected", "image/kitchen_category_selected", "image/kitchen_category_unselected", "image/kitchen_category_selected" } },
	Button { x = 26, y = 58,  name = "bar", label = "bar", command = function() SetTargetCategory("bar") end },
	Button { x = 173, y = 58, name = "beverage", label = "kitchen_category_beverage", command = function() SetTargetCategory("beverage") end },
	Button { x = 26, y = 91,  name = "infusion", label = "infusion", command = function() SetTargetCategory("infusion") end },
	Button { x = 173, y = 91, name = "truffle", label = "truffle", command = function() SetTargetCategory("truffle") end },
	Button { x = 26, y = 124, name = "blend", label = "kitchen_category_blend", command = function() SetTargetCategory("blend") end },
	Button { x = 173, y = 124, name = "exotic", label = "exotic", command = function() SetTargetCategory("exotic") end },

	-- Visual Bowls
	Bitmap { x = 50, y = 249,  name = "bowl_6", image = "image/kitchen_bowl" },
	Bitmap { x = 140, y = 249, name = "bowl_5", image = "image/kitchen_bowl" },
	Bitmap { x = 230, y = 249, name = "bowl_4", image = "image/kitchen_bowl" },
	Bitmap { x = 320, y = 249, name = "bowl_3", image = "image/kitchen_bowl" },
	Bitmap { x = 410, y = 249, name = "bowl_2", image = "image/kitchen_bowl" },
	Bitmap { x = 500, y = 249, name = "bowl_1", image = "image/kitchen_bowl" },

	-- Dynamic Slot Modifiers
	SetStyle(C3SmallRoundButtonStyle),
	Button { x = 590, y = 185, name = "remove_slot_button", label = "#-", command = RemoveIngredientSlot },
	Button { x = 630, y = 185, name = "add_slot_button", label = "#+", command = AddIngredientSlot },

	SetStyle(C3ButtonMediumStyle),
	Button { x = 601, y = 242, scale = 0.8, label = "invent_taste", command = function() TasteIt() end },

	-- Load a compatible Community Creation into the Test Kitchen.
	SetStyle(C3ButtonMediumStyle),
	Button { x = 601, y = 278, scale = 0.8, label = "#" .. GetString("load_creation"), command = LoadCreation },

	-- Active Slots
	AppendStyle { type = kPush, graphics = {} },
	Button { x = 65,  y = 196, w = 64, h = 64, Bitmap { x = 0, y = 0, name = "slot_6" }, command = function() ClearSlot(6) end },
	Button { x = 155, y = 196, w = 64, h = 64, Bitmap { x = 0, y = 0, name = "slot_5" }, command = function() ClearSlot(5) end },
	Button { x = 245, y = 196, w = 64, h = 64, Bitmap { x = 0, y = 0, name = "slot_4" }, command = function() ClearSlot(4) end },
	Button { x = 335, y = 196, w = 64, h = 64, Bitmap { x = 0, y = 0, name = "slot_3" }, command = function() ClearSlot(3) end },
	Button { x = 425, y = 196, w = 64, h = 64, Bitmap { x = 0, y = 0, name = "slot_2" }, command = function() ClearSlot(2) end },
	Button { x = 515, y = 196, w = 64, h = 64, Bitmap { x = 0, y = 0, name = "slot_1" }, command = function() ClearSlot(1) end },

	-- Ingredient Drawers
	-- Six full-width drawers fit comfortably between the scroll arrows.  The two
	-- banks overlap by three categories so moving left/right feels continuous:
	--   Page 1: Cacao, Coffee, Tea, Dairy, Sugar, Fruits
	--   Page 2: Dairy, Sugar, Fruits, Nuts, Flavors, Liqueurs
	Window { x = 0, y = 0, name = "drawer_tabs_page_1", fit = true,
		BeginGroup(),
		AppendStyle { tx = 8, ty = 4, tw = 91, th = 17, flags = kVAlignCenter + kHAlignCenter, graphics = { "image/kitchen_drawer_closed" } },
		Button { x = 70,  y = 320, label = GetDrawerLabel("cacao"),   font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_cacao_p1") end },
		Button { x = 177, y = 320, label = GetDrawerLabel("coffee"),  font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_coffee_p1") end },
		Button { x = 284, y = 320, label = GetDrawerLabel("tea"),     font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_tea_p1") end },
		Button { x = 391, y = 320, label = GetDrawerLabel("dairy"),   font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_dairy_p1") end },
		Button { x = 498, y = 320, label = GetDrawerLabel("sugar"),   font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_sugar_p1") end },
		Button { x = 605, y = 320, label = GetDrawerLabel("fruit"),   font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_fruit_p1") end },
	},

	Window { x = 0, y = 0, name = "drawer_tabs_page_2", fit = true,
		BeginGroup(),
		AppendStyle { tx = 8, ty = 4, tw = 91, th = 17, flags = kVAlignCenter + kHAlignCenter, graphics = { "image/kitchen_drawer_closed" } },
		Button { x = 70,  y = 320, label = GetDrawerLabel("dairy"), font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_dairy_p2") end },
		Button { x = 177, y = 320, label = GetDrawerLabel("sugar"), font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_sugar_p2") end },
		Button { x = 284, y = 320, label = GetDrawerLabel("fruit"), font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_fruit_p2") end },
		Button { x = 391, y = 320, label = GetDrawerLabel("nut"),     font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_nut_p2") end },
		Button { x = 498, y = 320, label = GetDrawerLabel("flavor"),  font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_flavor_p2") end },
		Button { x = 605, y = 320, label = GetDrawerLabel("liqueur"), font = { labelFontName, 14, BlackColor }, command = function() ToggleDrawer("drawer_liqueur_p2") end },
	},

	-- Dedicated drawer-bank navigation.  These use existing arrow artwork rather
	-- than squeezing the drawer tabs narrower.
	Button { x = 18,  y = 319, name = "drawer_scroll_left",  scale = 0.65,
		graphics = { "image/button_arrow_left_up", "image/button_arrow_left_down", "image/button_arrow_left_over", "image/button_arrow_left_down" },
		command = function() ScrollDrawers(-1) end },
	Button { x = 739, y = 319, name = "drawer_scroll_right", scale = 0.65,
		graphics = { "image/button_arrow_right_up", "image/button_arrow_right_down", "image/button_arrow_right_over", "image/button_arrow_right_down" },
		command = function() ScrollDrawers(1) end },

	-- Page-specific open-drawer windows keep the open drawer graphic physically
	-- aligned to the current tab position without resizing any art assets.
	IngredientDrawer { x = 70,  y = 320, name = "cacao",   window_name = "drawer_cacao_p1" },
	IngredientDrawer { x = 177, y = 320, name = "coffee",  window_name = "drawer_coffee_p1" },
	IngredientDrawer { x = 284, y = 320, name = "tea",     window_name = "drawer_tea_p1" },
	IngredientDrawer { x = 391, y = 320, name = "dairy",   window_name = "drawer_dairy_p1" },
	IngredientDrawer { x = 498, y = 320, name = "sugar",   window_name = "drawer_sugar_p1" },
	IngredientDrawer { x = 605, y = 320, name = "fruit",   window_name = "drawer_fruit_p1" },

	IngredientDrawer { x = 70,  y = 320, name = "dairy",   window_name = "drawer_dairy_p2" },
	IngredientDrawer { x = 177, y = 320, name = "sugar",   window_name = "drawer_sugar_p2" },
	IngredientDrawer { x = 284, y = 320, name = "fruit",   window_name = "drawer_fruit_p2" },
	IngredientDrawer { x = 391, y = 320, name = "nut",     window_name = "drawer_nut_p2" },
	IngredientDrawer { x = 498, y = 320, name = "flavor",  window_name = "drawer_flavor_p2" },
	IngredientDrawer { x = 605, y = 320, name = "liqueur", window_name = "drawer_liqueur_p2" },
}

-------------------------------------------------------------------------------

local clearProduct = true
if productName then clearProduct = false
else productName = defaultProductName
end

local clearDescription = true
if productDescription then clearDescription = false
else productDescription = defaultProductDescription
end

local whiteLabelFont = { labelFontName, 20, WhiteColor }

local leftArrowGraphics = { "image/button_arrow_left_up", "image/button_arrow_left_down", "image/button_arrow_left_over", "image/button_arrow_left_down" }
local rightArrowGraphics = { "image/button_arrow_right_up", "image/button_arrow_right_down", "image/button_arrow_right_over", "image/button_arrow_right_down" }

local DesignModeWindow = BSGWindow
{
	x = 0, y = 0, w = 782, h = 479, swallowmouse = true, fill = false, fit = true, color = { 0, 0, 0, -1 },
	name = "design_mode",
	RecipeDesigner { x = 0, y = 0, fit = true, Bitmap
	{
		x = 6, y = 16, w = 782, h = 467, image = "image/popup_back_designer",

		SetStyle(C3ButtonStyle),

		-- Layer 1 Toggles
		Button { x = 73, y = 37, graphics = leftArrowGraphics, command = function() DecLayer(1) end },
		Bitmap { x = 114, y = 41, image = "image/designer_custom_window",
			BitmapTint { x = 13, y = 13, w = 64, h = 64, name = "option_layer0", scale = 0.5 },
			Bitmap { x = 13, y = 13, w = 64, h = 64, name = "option_highlight0", scale = 0.5 } },
		Button { x = 207, y = 37, graphics = rightArrowGraphics, command = function() IncLayer(1) end },
		Button { x = 120, y = 133, scale = 0.6, command = function() SelectTint(1, 32.5, 185) end,
			Rectangle { name = "tint1", x = 10, y = 6, w = kMax - 12, h = kMax - 11, color = colorOptions[1] },
		},

		-- Layer 2 Toggles
		Button { x = 73, y = 162, graphics = leftArrowGraphics, command = function() DecLayer(2) end },
		Bitmap { x = 114, y = 166, image = "image/designer_custom_window",
			BitmapTint { x = 13, y = 13, w = 64, h = 64, name = "option_layer1", scale = 0.5 },
			Bitmap { x = 13, y = 13, w = 64, h = 64, name = "option_highlight1", scale = 0.5 } },
		Button { x = 207, y = 162, graphics = rightArrowGraphics, command = function() IncLayer(2) end },
		Button { x = 120, y = 258, scale = 0.6, command = function() SelectTint(2, 32.5, 308) end,
			Rectangle { name = "tint2", x = 10, y = 6, w = kMax - 12, h = kMax - 11, color = colorOptions[1] },
		},

		-- Layer 3 Toggles
		Button { x = 536, y = 37, graphics = leftArrowGraphics, command = function() DecLayer(3) end },
		Bitmap { x = 577, y = 41, image = "image/designer_custom_window",
			BitmapTint { x = 13, y = 13, w = 64, h = 64, name = "option_layer2", scale = 0.5 },
			Bitmap { x = 13, y = 13, w = 64, h = 64, name = "option_highlight2", scale = 0.5 } },
		Button { x = 670, y = 37, graphics = rightArrowGraphics, command = function() IncLayer(3) end },
		Button { x = 583, y = 133, scale = 0.6, command = function() SelectTint(3, 495.5, 185) end,
			Rectangle { name = "tint3", x = 10, y = 6, w = kMax - 12, h = kMax - 11, color = colorOptions[1] },
		},

		-- Layer 4 Toggles
		Button { x = 536, y = 162, graphics = leftArrowGraphics, command = function() DecLayer(4) end },
		Bitmap { x = 577, y = 166, image = "image/designer_custom_window",
			BitmapTint { x = 13, y = 13, w = 64, h = 64, name = "option_layer3", scale = 0.5 },
			Bitmap { x = 13, y = 13, w = 64, h = 64, name = "option_highlight3", scale = 0.5 } },
		Button { x = 670, y = 162, graphics = rightArrowGraphics, command = function() IncLayer(4) end },
		Button { x = 583, y = 258, scale = 0.6, command = function() SelectTint(4, 495.5, 308) end,
			Rectangle { name = "tint4", x = 10, y = 6, w = kMax - 12, h = kMax - 11, color = colorOptions[1] },
		},

		-- Master Preview Display
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_layer0", scale = 0.5 },
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_highlight0", scale = 0.5 },
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_layer1", scale = 0.5 },
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_highlight1", scale = 0.5 },

		Bitmap { x = 327, y = 85, w = 128, h = 128, name = "display_mug", scale = 0.5 },
		Bitmap { x = 327, y = 85, w = 128, h = 128, name = "display_rim_outer", scale = 0.5 },

		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_layer2", scale = 0.5 },
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_highlight2", scale = 0.5 },
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_layer3", scale = 0.5 },
		BitmapTint { x = 327, y = 85, w = 128, h = 128, name = "display_highlight3", scale = 0.5 },

		Bitmap { x = 327, y = 85, w = 128, h = 128, name = "display_rim_inner", scale = 0.5 },

		-- Name Input
		Text { x = 18, y = 322, w = 184, h = 41, label = "recipe_name", font = whiteLabelFont, flags = kVAlignCenter + kHAlignCenter },
		Bitmap { x = 202, y = 322, image = "image/designer_textentry_window",
			TextEdit { x = 3, y = 3, w = kMax - 6, h = kMax - 6, name = "product_name", clearinitial = clearProduct, label = productName,
				utf8 = true, length = 100, ignore = kIllegalProductChars,
				font = { uiFontName, 25, WhiteColor }, flags = kVAlignCenter + kHAlignLeft,
			},
		},

		-- Description Input
		Text { x = 18, y = 372, w = 184, h = 41, label = "recipe_description", font = whiteLabelFont, flags = kVAlignCenter + kHAlignCenter },
		Bitmap { x = 202, y = 372, image = "image/designer_textentry_window",
			TextEdit { x = 3, y = 3, w = kMax - 6, h = kMax - 6, name = "product_desc", clearinitial = clearDescription, label = productDescription,
				utf8 = true, length = 400, ignore = kIllegalProductChars,
				font = { uiFontName, 16, WhiteColor }, flags = kVAlignCenter + kHAlignLeft,
			},
		},

		Button { x = 324, y = 253, label = "randomize", command = function() RandomDesign() end },
		Button { x = 604, y = 321, label = "taste_recipe", command = function() CreateMode() end },
		Button { x = 604, y = 371, label = "save_recipe", command = function() ConfirmRecipeCreation() end },
	} }
}

-------------------------------------------------------------------------------
-- Dialogue Assembly & Render Loop
-------------------------------------------------------------------------------

local nameplateFont = { labelFontName, 30, Color(255, 255, 255, 255) }

MakeDialog
{
	Window
	{
		x = 1000, y = 9, name = "kitchen", fit = true,
		CreationModeWindow,
		DesignModeWindow,

		Bitmap { image = "image/popup_nameplate", x = 230, y = 0,
			Text { x = 34, y = 10, w = 270, h = 38, name = "nameplate", label = "title_kitchen", font = nameplateFont, flags = kVAlignCenter + kHAlignCenter },
		},

		AppendStyle(C3ButtonStyle),
		Button { x = 660, y = 10, name = "ok", label = "cancel", cancel = true, command = function() FadeCloseWindow("kitchen", "ok") end },

		SetStyle(C3RoundButtonStyle),
		Button { x = 734, y = 53, name = "help", label = "#?", command = function()
			if mode == "create_mode" then HelpDialog("help_kitchen")
			else HelpDialog("help_design")
			end
		end },
	},
}

-- Post-Render Initialization
for _, drawerWindow in ipairs({
	"drawer_cacao_p1", "drawer_coffee_p1", "drawer_tea_p1", "drawer_dairy_p1", "drawer_sugar_p1", "drawer_fruit_p1",
	"drawer_dairy_p2", "drawer_sugar_p2", "drawer_fruit_p2", "drawer_nut_p2", "drawer_flavor_p2", "drawer_liqueur_p2",
}) do
	EnableWindow(drawerWindow, false)
end

-- Begin with the leftmost bank visible.
EnableWindow("drawer_tabs_page_1", true)
EnableWindow("drawer_tabs_page_2", false)
EnableWindow("design_recipe", false)

-- Block tabs based on the player's progression state
if not Player.categoryCount["bar"] then EnableWindow("bar", false) end
if not Player.categoryCount["beverage"] then EnableWindow("beverage", false) end
if not Player.categoryCount["infusion"] then EnableWindow("infusion", false) end
if not Player.categoryCount["truffle"] then EnableWindow("truffle", false) end
if not Player.categoryCount["blend"] then EnableWindow("blend", false) end
if not Player.categoryCount["exotic"] then EnableWindow("exotic", false) end

SetTargetCategory(targetCategory)

-- Automatically open Cacao on the first bank to hint the drawer interaction.
openDrawer = nil
ToggleDrawer("drawer_cacao_p1")

UpdateRecipeButtons()
CreateMode()
SetDynamicFeedbackText(GetRandomString("invent_instructions"))

-- Developer import compatibility.
if startupCommunityCreation then
	QueueCommand(function()
		ApplyCommunityCreationToWorkspace(startupCommunityCreation, startupCommunityCreationId)
	end)
end

local building = gDialogTable.building
if building and not Player.buildingsVisited[building.name] then
	DebugOut("PLAYER", string.format("Recorded first visit to the Secret Test Kitchen: %s", building.name))
	Player.buildingsVisited[building.name] = true
end

OpenBuilding("kitchen", gDialogTable.building)
