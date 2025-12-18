--[[---------------------------------------------------------------------------
	Chocolatier Three - Test Kitchen
	Copyleft (c) 2006-2008 Big Splash Games, LLC. All lefts Reserved.
--]]---------------------------------------------------------------------------

local targetCategory = gDialogTable.targetCategory or "bar"
local usedSlotCount = gDialogTable.usedSlotCount or 3
local ingredients = gDialogTable.ingredients or {}
local colors = gDialogTable.colors or {1,1,1,1}
local openDrawer = gDialogTable.openDrawer
local design = gDialogTable.design or {0,0,0,0}
local productName = gDialogTable.productName or productName
local productDescription = gDialogTable.productDescription or productDescription
local autoRandomize = true

local defaultProductName = GetString("recipe_name_default")
local defaultProductDescription = GetString("recipe_description_default")

local kBottleWidth = 40

local colorOptions = 
{
	
	-- Browns and Tans (Chocolate Colors)
	Color(40, 22, 8, 255), Color(67, 29, 8, 255), Color(82, 35, 7, 255), Color(99, 41, 16, 255), Color(116, 50, 28, 255), Color(154, 81, 46, 255),
	Color(244,224,151, 255), Color(225,187,116, 255), Color(238,178,106, 255), Color(204,127,35, 255), Color(160,119,89, 255), Color(138, 87, 69, 255),
	
	-- White, Greys and Blacks
	Color(0, 0, 0, 255), Color(59, 59, 59, 255), Color(115, 115, 115, 255), Color(176, 176, 176, 255), Color(227, 227, 227, 255), Color(255, 255, 255, 255),

	-- Reds
	Color(255, 184, 184, 255), Color(237, 78, 78, 255), Color(209, 2, 2, 255), Color(145, 12, 12, 255), Color(87, 3, 3, 255), Color(31, 0, 0, 255),

	-- Oranges
	Color(33, 11, 2, 255), Color(87, 36, 10, 255), Color(174, 72, 20, 255), Color(250, 99, 35, 255), Color(255, 133, 84, 255), Color(255, 200, 184, 255),
	Color(255, 224, 189, 255), Color(255, 176, 87, 255), Color(250, 141, 10, 255), Color(204, 127, 35, 255), Color(77, 42, 0, 255), Color(28, 17, 3, 255),

	-- Yellows
	Color(31, 18, 0, 255), Color(106, 74, 11, 255), Color(201, 133, 4, 255), Color(245, 162, 7, 255), Color(255, 191, 107, 255), Color(255, 217, 184, 255),
	Color(255, 235, 184, 255), Color(255, 232, 107, 255), Color(247, 228, 30, 255), Color(191, 175, 0, 255), Color(128, 117, 0, 255), Color(31, 27, 0, 255),

	-- Greens
	Color(24, 31, 0, 255), Color(92, 106, 11, 255), Color(149, 174, 20, 255), Color(204, 235, 56, 255), Color(224, 255, 107, 255), Color(245, 255, 184, 255),
	Color(217, 255, 184, 255), Color(179, 255, 107, 255), Color(153, 235, 56, 255), Color(103, 174, 20, 255), Color(61, 106, 11, 255), Color(15, 31, 0, 255),
	Color(6, 31, 0, 255), Color(30, 106, 11, 255), Color(56, 174, 20, 255), Color(102, 235, 56, 255), Color(140, 255, 107, 255), Color(200, 255, 184, 255),
	Color(184, 255, 200, 255), Color(107, 255, 140, 255), Color(56, 235, 102, 255), Color(20, 174, 56, 255), Color(11, 106, 30, 255), Color(0, 31, 4, 255),

	-- Cyans
	Color(0, 31, 13, 255), Color(11, 106, 61, 255), Color(20, 174, 103, 255), Color(56, 235, 153, 255), Color(107, 255, 209, 255), Color(184, 255, 217, 255),
	Color(184, 255, 245, 255), Color(107, 255, 224, 255), Color(56, 235, 204, 255), Color(20, 174, 149, 255), Color(11, 106, 92, 255), Color(0, 31, 24, 255),
	Color(0, 31, 31, 255), Color(11, 106, 106, 255), Color(20, 174, 174, 255), Color(56, 235, 235, 255), Color(107, 255, 255, 255), Color(184, 255, 255, 255),

	-- Blues
	Color(184, 245, 255, 255), Color(107, 224, 255, 255), Color(56, 204, 235, 255), Color(20, 149, 174, 255), Color(11, 92, 106, 255), Color(0, 24, 31, 255),
	Color(0, 13, 31, 255), Color(11, 61, 106, 255), Color(20, 103, 174, 255), Color(56, 153, 235, 255), Color(107, 209, 255, 255), Color(184, 217, 255, 255),
	Color(184, 200, 255, 255), Color(107, 140, 255, 255), Color(56, 102, 235, 255), Color(20, 56, 174, 255), Color(11, 30, 106, 255), Color(0, 4, 31, 255),

	-- Purples
	Color(6, 0, 31, 255), Color(30, 11, 106, 255), Color(56, 20, 174, 255), Color(102, 56, 235, 255), Color(140, 107, 255, 255), Color(200, 184, 255, 255),
	Color(217, 184, 255, 255), Color(179, 107, 255, 255), Color(153, 56, 235, 255), Color(103, 20, 174, 255), Color(61, 11, 106, 255), Color(15, 0, 31, 255),

	-- Magentas
	Color(24, 0, 31, 255), Color(92, 11, 106, 255), Color(149, 20, 174, 255), Color(204, 56, 235, 255), Color(224, 107, 255, 255), Color(245, 184, 255, 255),
	Color(255, 184, 235, 255), Color(255, 107, 232, 255), Color(235, 56, 219, 255), Color(174, 20, 177, 255), Color(106, 11, 102, 255), Color(31, 0, 27, 255),

	-- Pinks and Crimsons
	Color(31, 0, 18, 255), Color(106, 11, 74, 255), Color(174, 20, 125, 255), Color(235, 56, 165, 255), Color(255, 107, 191, 255), Color(255, 184, 217, 255),
	Color(255, 184, 200, 255), Color(255, 107, 149, 255), Color(235, 56, 111, 255), Color(174, 20, 72, 255), Color(106, 11, 43, 255), Color(31, 0, 9, 255),

}

-------------------------------------------------------------------------------
-- Slots

local function SetDynamicFeedbackText(text)
    -- This function dynamically adjusts the font size of the feedback text box
    -- by finding the largest possible font size that fits the text. (LUA 5.0 COMPATIBLE)

    local function Ceil(x)
        return Floor(x + 0.99999)
    end

    -- 1. Define our rules: font sizes, their character-per-line estimates, and their max line thresholds.
    local font_sizes_to_check = {18, 16, 14, 12} -- Check from largest to smallest
    local chars_per_line_map = {
        [18] = 38,
        [16] = 50, -- A size 16 font fits more characters
        [14] = 62, -- A size 14 font fits even more
        [12] = 74, -- A size 12 font fits the most
    }
    local line_thresholds = {
        [18] = 5, -- Size 18 is only allowed if it takes 5 lines or less
        [16] = 6, -- Size 16 is only allowed if it takes 6 lines or less
        [14] = 7, -- Size 14 is only allowed if it takes 7 lines or less
        [12] = 999, -- Size 12 is the fallback, it's always allowed
    }

    -- 2. Manually split the string by the "<br>" delimiter (Lua 5.0 compatible).
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

    -- 3. Iterate through our font sizes to find the best fit.
    local final_font_size = 12 -- Default to the smallest size as a fallback
    for _, current_font_size in ipairs(font_sizes_to_check) do
        local chars_per_line = chars_per_line_map[current_font_size]
        local line_threshold = line_thresholds[current_font_size]
        
        -- Calculate the total lines based on THIS font size's character estimate
        local total_lines = table.getn(segments) - 1
        for _, segment in ipairs(segments) do
            total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
        end

        -- If the calculated lines are within the threshold for this font size, we've found our winner.
        if total_lines <= line_threshold then
            final_font_size = current_font_size
            break -- Exit the loop since we found the largest size that works
        end
    end

    DebugOut("UI", "Feedback text requires font size " .. final_font_size .. ".")

    -- 4. Apply the final font size and the text to the UI element.
    local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
    SetLabel("feedback", formatted_text)
end

local function UpdateRecipeButtons()
	EnableWindow("clear_recipe", false)
	EnableWindow("add_recipe", true)
	for i=1,usedSlotCount do
		if ingredients[i] then EnableWindow("clear_recipe", true)		-- Allow "clear all" if at least one is full
		else EnableWindow("add_recipe", false)							-- Disallow "add recipe" if not all are full
		end
	end
end

local function ClearSlot(i)
	SetBitmap("slot_"..i, "")
	ingredients[i] = nil
	UpdateRecipeButtons()
	EnableWindow("design_recipe", false)
end

local function ClearAllSlots()
    DebugOut("RECIPE", "All recipe slots cleared by player.")
	for i=1,6 do
		SetBitmap("slot_"..i, "")
		ingredients[i] = nil
	end
	EnableWindow("new_recipe", false)
	EnableWindow("add_recipe", false)
	EnableWindow("design_recipe", false)
	SetDynamicFeedbackText(GetString("invent_instructions"))
end

local function UpdateBowlAndSlotVisibility()
	for i=1,6 do
		if i <= usedSlotCount then
			EnableWindow("bowl_"..i, true)
			EnableWindow("slot_"..i, true)
		else
			EnableWindow("bowl_"..i, false)
			EnableWindow("slot_"..i, false)
			-- Also clear the ingredient from any slot we're hiding
			if ingredients[i] then
				ingredients[i] = nil
				SetBitmap("slot_"..i, "")
			end
		end
	end
	UpdateRecipeButtons()

    local category = _AllCategories[targetCategory]
    if category then
        -- Enable the '-' button ONLY if the current slot count is greater than the minimum allowed.
        EnableWindow("remove_slot_button", usedSlotCount > tonumber(category.min_ingredients))
        
        -- Enable the '+' button ONLY if the current slot count is less than the maximum allowed.
        EnableWindow("add_slot_button", usedSlotCount < tonumber(category.max_ingredients))
    else
        -- As a fallback, disable both if the category isn't found for some reason.
        EnableWindow("remove_slot_button", false)
        EnableWindow("add_slot_button", false)
    end
end

-- MOD: Command for the '+' button
function AddIngredientSlot()
	local category = _AllCategories[targetCategory]
	-- Ensure we are comparing numbers, not strings
	if usedSlotCount < tonumber(category.max_ingredients) then
		usedSlotCount = usedSlotCount + 1
        DebugOut("RECIPE", "Added ingredient slot. Total slots: " .. usedSlotCount)
		UpdateBowlAndSlotVisibility()
	end
end

-- MOD: Command for the '-' button
function RemoveIngredientSlot()
	local category = _AllCategories[targetCategory]
	-- Ensure we are comparing numbers, not strings
	if usedSlotCount > tonumber(category.min_ingredients) then
		-- Clear the last active slot before removing it
		ClearSlot(usedSlotCount)
		usedSlotCount = usedSlotCount - 1
        DebugOut("RECIPE", "Removed ingredient slot. Total slots: " .. usedSlotCount)
		UpdateBowlAndSlotVisibility()
	end
end

local function SetTargetCategory(cat)
	SetButtonToggleState(cat, true)
	targetCategory = cat
	autoRandomize = true
	
    DebugOut("RECIPE", "Player selected recipe category: " .. cat)

	-- MOD: Set the initial number of slots to the original default values
	if cat == "bar" then usedSlotCount = 3
	elseif cat == "beverage" then usedSlotCount = 3
	elseif cat == "infusion" then usedSlotCount = 4
	elseif cat == "truffle" then usedSlotCount = 6
	elseif cat == "blend" then usedSlotCount = 4
	elseif cat == "exotic" then usedSlotCount = 5
	end
	
	-- MOD: Update the UI using our new helper function
	UpdateBowlAndSlotVisibility()
	
	ClearAllSlots()
end

local function AddSlotIngredient(ing, slot)
	-- Find an empty slot
	local success = false
	for i=1,usedSlotCount do
		if not ingredients[i] then
			success = true
			ingredients[i] = ing
			SetBitmap("slot_"..i, "items/"..ing.name.."_big")
            DebugOut("RECIPE", "Player added '" .. ing.name .. "' to slot " .. i)
			break
		end
	end
	if success then UpdateRecipeButtons() end
	return success
end

-------------------------------------------------------------------------------
-- Colors

function SetRecipeTint(layer,index)
	if index > table.getn(colorOptions) then index = Mod(index, table.getn(colorOptions)) + 1 end
	
	colors[layer] = index
	SetRectangleColor("tint"..layer, colorOptions[index])
	BTSetTint("option_layer"..(layer-1), colorOptions[index])
	BTSetTint("display_layer"..(layer-1), colorOptions[index])
end

local function SelectTint(layer,x,y)
	newColor = DisplayDialog { "ui/ui_colorselect.lua", image=ingredients[layer], colors=colorOptions, x=x,y=y }
	if newColor then SetRecipeTint(layer,newColor) end
end

-------------------------------------------------------------------------------
-- Drawers

local categorized = { cacao={}, coffee={}, dairy={}, sugar={}, fruit={}, nut={}, flavor={}, special={} }

-- Gather available ingredients by category
for n,ing in ipairs(_IngredientOrder) do
--	if Player.labIngredients[ing.name] then
		table.insert(categorized[ing.category], ing)
--	end
end

-- Hack: Put truffle powder in the cacao drawer
--if Player.labIngredients.powder then
	table.insert(categorized.cacao, _AllIngredients.powder)
--end

local function ToggleDrawer(name)
	if name == openDrawer then name = nil end
	if openDrawer then
		EnableWindow(openDrawer, false)
		openDrawer = nil
	end
	if name then
		openDrawer = name
		EnableWindow(openDrawer, true)
        DebugOut("UI", "Player opened ingredient drawer: " .. name)
	end
end

local function IngredientDrawer(t)
	local name = t.name
	
	local vials = {}
	local y = 32

    local ingredients_in_drawer = categorized[name]
    local num_ingredients = table.getn(ingredients_in_drawer)
    local max_per_row = 17 -- Approximately how many vials fit on one row

    if num_ingredients > max_per_row then
        -- THIS IS A MULTI-ROW DRAWER (like Flavors)
        -- Use your new offset wrapping logic for a nicer look.
        local x_start = 5
        local x = x_start
        local row_num = 1

        for _,ing in ipairs(ingredients_in_drawer) do
            local temp = ing
            
            if Player.labIngredients[ing.name] then
                table.insert(vials,
                    Rollover {x=x,y=y, fit=true,
                        Bitmap { x=0,y=0, image="image/kitchen_jar",
                            Bitmap { x=5,y=14, image="items/"..ing.name, },
                        },
                        contents=ing.name..":InventoryRolloverContents()",
                        command=function() AddSlotIngredient(temp) end,
                    })
            else
                table.insert(vials, Bitmap { x=x,y=y, image="image/kitchen_jar_space", })
            end
            
            x = x + kBottleWidth
            if x + kBottleWidth > 773 then
                y = y + 60
                row_num = row_num + 1
                -- Alternate the starting offset for a triangular effect
                if Mod(row_num, 2) == 0 then
                    x = x_start + 20
                else
                    x = x_start
                end
            end
        end
    else
        -- THIS IS A SINGLE-ROW DRAWER (like Dairy)
        -- Use the original centering logic.
        local w = num_ingredients * kBottleWidth
        local x = t.x + 55 - w/2
        if x < 5 then x=5 end
        if x+w > 773 then x=773 - w end

        for _,ing in ipairs(ingredients_in_drawer) do
            local temp = ing
            
            if Player.labIngredients[ing.name] then
                table.insert(vials,
                    Rollover {x=x,y=y, fit=true,
                        Bitmap { x=0,y=0, image="image/kitchen_jar",
                            Bitmap { x=5,y=14, image="items/"..ing.name, },
                        },
                        contents=ing.name..":InventoryRolloverContents()",
                        command=function() AddSlotIngredient(temp) end,
                    })
            else
                table.insert(vials, Bitmap { x=x,y=y, image="image/kitchen_jar_space", })
            end
            
            x = x + kBottleWidth
        end
    end

	return Window
	{
		x=0,y=t.y,name=name, fit=true,
		Bitmap { x=t.x,y=0, image="image/kitchen_drawer_open",
			Text { x=8,y=130,w=91,h=17, label=name, font={labelFontName, 16, BlackColor}},
		},
		Group(vials),
	}
end

-------------------------------------------------------------------------------
-- Tasting

function TasteIt()
	-- Make sure all slots are used
	local allFull = true
	for i=1,usedSlotCount do
		if not ingredients[i] then allFull = false break end
	end
	
	if not allFull then
		SetLabel("feedback", GetString("taster_fillslots"))
	else
        DebugOut("RECIPE", "Player clicked 'Taste It'.")
		local productCategory = _AllCategories[targetCategory]
		local feedback
		feedback,r,low,high,allow = EvaluatePlayerRecipe(productCategory, ingredients, usedSlotCount)
		SetDynamicFeedbackText(tostring(feedback))
		
		-- If slots are available, allow the player to design the recipe
		local category = _AllCategories.user
		if category and table.getn(category.products) < Player.customSlots then EnableWindow("design_recipe", true) end
		if not allow then EnableWindow("design_recipe", false) end
		
--		FirstPeekTasteIt(targetCategory, ingredients)		-- FIRST PEEK
	end
end

-------------------------------------------------------------------------------
-- Design Layers

local function IncLayer(field)
	design[field] = SetLayer(field-1, design[field]+1)
end

local function DecLayer(field)
	design[field] = SetLayer(field-1, design[field]-1)
end

-------------------------------------------------------------------------------
-- Mode Swap

local mode = "create_mode"

function CreateMode()
	mode = "create_mode"
	EnableWindow("design_mode", false)
	EnableWindow("create_mode", true)
	SetLabel("nameplate", GetString("title_kitchen"))
    DebugOut("UI", "Switched to Test Kitchen 'Creation Mode'.")
end

function DesignMode()
	mode = "design_mode"
	SetRecipeType(targetCategory)
	EnableWindow("create_mode", false)
	EnableWindow("design_mode", true)
	SetLabel("nameplate", GetString("title_marketing"))
    DebugOut("UI", "Switched to Test Kitchen 'Marketing Mode'.")
	if autoRandomize then
		autoRandomize = false
		RandomDesign()
	end
end

-------------------------------------------------------------------------------

local function DoRecipeCreation()
	-- Copy the ingredients table so it can be sorted and manipulated
	local ings = {}
	for i=1,usedSlotCount do
		if ingredients[i] then table.insert(ings, ingredients[i]) end
	end
	
	-- TODO: Make sure there's a minimum number of ingredients
	-- TODO: Make sure name is not empty
	productName = GetLabel("product_name")
	productDescription = GetLabel("product_desc")
	
	-- Gather appearance
	local appearance = {}
	for i=0,3 do
		local image = GetLayerImage(i)
		local tint = colors[i+1]
		tint = colorOptions[tint]
		if image and string.len(image) then
			table.insert(appearance, { image, tint[1], tint[2], tint[3] })
		end
	end
	
	-- Create the recipe
	local recipe = CreateCustomRecipe(productName, productDescription, ings, appearance, targetCategory)
--	FirstPeekCreate(targetCategory, ings, productName)		-- FIRST PEEK
	
	-- TODO: Pop up errors
	
	if recipe then
		gRecipeSelection = recipe
		QueueCommand( function() DisplayDialog{"ui/ui_recipes.lua"} end )
		CloseWindow()
	end
end

local function ConfirmRecipeCreation()
	productName = GetLabel("product_name")
	productDescription = GetLabel("product_desc")
	
	if productName == "" or productName == defaultProductName or productDescription == "" or productDescription == defaultProductDescription then
		DisplayDialog { "ui/ui_generic.lua", text="invent_noname" }
	else
		-- See if any product exists with this same name
		local nameOk = true
		local lowerName = string.lower(productName)
		for code,prod in pairs(_AllProducts) do
			local s = string.lower(prod:GetName())
			if lowerName == s then
				nameOk = false
				-- If this is a UGR, make sure it's a UGR for THIS player
				if (not nameOk) and (prod.category.name == "user") and (not Player.itemNames[prod.code]) then nameOk = true end
				if (not nameOk) then break end
			end
		end
		
		if nameOk then
			local yn = DisplayDialog { "ui/ui_generic_yn.lua", text="invent_confirm" }
			if yn == "yes" then DoRecipeCreation() end
		else
			DisplayDialog { "ui/ui_generic.lua", text="invent_name_inuse" }
		end
	end
end

-------------------------------------------------------------------------------

function LoadCreation()
    DebugOut("UI", "Load Creation button clicked.")
    local loadedData = DisplayDialog { "ui/ui_load_creation.lua" }
    if loadedData then
        DebugOut("RECIPE", "Loading creation '" .. loadedData.name .. "' into the kitchen.")
        
        -- This is our new function to apply the loaded data
        ClearAllSlots()
        SetTargetCategory(loadedData.category)
        usedSlotCount = table.getn(loadedData.ingredients)
        UpdateBowlAndSlotVisibility()

        for i, ingName in ipairs(loadedData.ingredients) do
            local ingObj = _AllIngredients[ingName]
            if ingObj then
                ingredients[i] = ingObj
                SetBitmap("slot_"..i, "items/"..ingObj.name.."_big")
            end
        end
        
        -- Pre-fill the design and marketing info
        appearance = loadedData.appearance
        productName = loadedData.name
        productDescription = loadedData.description
        autoRandomize = false -- Prevent randomization from overwriting our loaded design

        UpdateRecipeButtons()
        DesignMode() -- Switch to marketing mode to show the loaded design
    else
        DebugOut("UI", "Load Creation was cancelled.")
    end
end

function SaveCreation()
    DebugOut("UI", "Save Creation button clicked.")
    local currentName = GetLabel("product_name")
    local currentDesc = GetLabel("product_desc")

    if currentName == "" or currentName == defaultProductName or currentDesc == "" or currentDesc == defaultProductDescription then
        DisplayDialog { "ui/ui_generic.lua", text="invent_noname" }
        return
    end

    -- Gather all the necessary data into a table
    local creationData = {}
    creationData.name = currentName
    creationData.description = currentDesc
    creationData.category = targetCategory
    
    creationData.ingredients = {}
    for i=1,usedSlotCount do
        if ingredients[i] then
            table.insert(creationData.ingredients, ingredients[i].name)
        end
    end

    creationData.appearance = {}
	for i=0,3 do
		local image = GetLayerImage(i)
		local tintIndex = colors[i+1]
		local tint = colorOptions[tintIndex]
		if image and string.len(image) > 0 then
			table.insert(creationData.appearance, { image, tint[1], tint[2], tint[3] })
		end
	end

    -- Call our new global helper function
    SaveCreationToFile(creationData)
end

-------------------------------------------------------------------------------

local CreationModeWindow = Bitmap
{
	x=6,y=16, image="image/popup_back_kitchen", name="create_mode", fit=true,

	SetStyle(C3DialogBodyStyle),
	CharWindow { x=585,y=38, name="main_tedd", happiness=_AllCharacters["main_tedd"]:GetHappiness() },

	SetStyle(C3DialogBodyStyle),
	Text { x=336,y=39,w=275,h=110, name="feedback", label="invent_instructions", font={uiFontName, 18, BlackColor}, flags=kHAlignLeft+kVAlignCenter },

	Text { x=68,y=23,w=194,h=24, label="nowinventing", flags=kHAlignCenter+kVAlignCenter },

	SetStyle(C3ButtonStyle),
	Button { x=328,y=148, name="clear_recipe", label="clear_recipe", command=function() ClearAllSlots() end },
	Button { x=470,y=148, name="design_recipe", label="design_recipe", command=function() DesignMode() end },
	
	-- Types
	BeginGroup(),
	AppendStyle { tx=30, type=kRadio, graphics= { "image/kitchen_category_unselected","image/kitchen_category_selected","image/kitchen_category_unselected","image/kitchen_category_selected" } },
	Button { x=26,y=58, name="bar", label="bar", command=function() SetTargetCategory("bar") end },
	Button { x=173,y=58, name="beverage", label="beverage", command=function() SetTargetCategory("beverage") end },
	Button { x=26,y=91, name="infusion", label="infusion", command=function() SetTargetCategory("infusion") end },
	Button { x=173,y=91, name="truffle", label="truffle", command=function() SetTargetCategory("truffle") end },
	Button { x=26,y=124, name="blend", label="blend", command=function() SetTargetCategory("blend") end },
	Button { x=173,y=124, name="exotic", label="exotic", command=function() SetTargetCategory("exotic") end },

	-- Bowls
	Bitmap { x=50,y=249,  name="bowl_6", image="image/kitchen_bowl" },
	Bitmap { x=140,y=249, name="bowl_5", image="image/kitchen_bowl" },
	Bitmap { x=230,y=249, name="bowl_4", image="image/kitchen_bowl" },
	Bitmap { x=320,y=249, name="bowl_3", image="image/kitchen_bowl" },
	Bitmap { x=410,y=249, name="bowl_2", image="image/kitchen_bowl" },
	Bitmap { x=500,y=249, name="bowl_1", image="image/kitchen_bowl" },

	-- MOD: Add new buttons for variable slots
	SetStyle(C3SmallRoundButtonStyle),
	Button { x=590, y=185, name="remove_slot_button", label="#-", command=RemoveIngredientSlot },
	Button { x=630, y=185, name="add_slot_button", label="#+", command=AddIngredientSlot },
	
	SetStyle(C3ButtonStyle),
--	AppendStyle { type=kPush, graphics= { "image/kitchen_tastebowl" }, },
--	Button { x=601,y=192, label="invent_taste", command=function() TasteIt() end },
	Button { x=601,y=242, label="invent_taste", command=function() TasteIt() end },
	
	-- Slots
	AppendStyle { type=kPush, graphics={} },
	Button { x=65,y=196,  w=64,h=64, Bitmap { x=0,y=0, name="slot_6", }, command=function() ClearSlot(6) end },
	Button { x=155,y=196, w=64,h=64, Bitmap { x=0,y=0, name="slot_5", }, command=function() ClearSlot(5) end },
	Button { x=245,y=196, w=64,h=64, Bitmap { x=0,y=0, name="slot_4", }, command=function() ClearSlot(4) end },
	Button { x=335,y=196, w=64,h=64, Bitmap { x=0,y=0, name="slot_3", }, command=function() ClearSlot(3) end },
	Button { x=425,y=196, w=64,h=64, Bitmap { x=0,y=0, name="slot_2", }, command=function() ClearSlot(2) end },
	Button { x=515,y=196, w=64,h=64, Bitmap { x=0,y=0, name="slot_1", }, command=function() ClearSlot(1) end },
	
	-- Drawers
	BeginGroup(),
	AppendStyle { tx=8,ty=4,tw=91,th=17, flags=kVAlignCenter+kHAlignCenter, graphics={ "image/kitchen_drawer_closed" } },
	Button { x=16,y=320,  label="cacao", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("cacao") end },
	Button { x=123,y=320, label="coffee", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("coffee") end },
	Button { x=230,y=320, label="dairy", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("dairy") end },
	Button { x=337,y=320, label="sugar", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("sugar") end },
	Button { x=444,y=320, label="fruit", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("fruit") end },
	Button { x=551,y=320, label="nut", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("nut") end },
	Button { x=658,y=320, label="flavor", font={labelFontName, 16, BlackColor}, command=function() ToggleDrawer("flavor") end },
	
	IngredientDrawer { x=16,y=320,  name="cacao" },
	IngredientDrawer { x=123,y=320, name="coffee" },
	IngredientDrawer { x=230,y=320, name="dairy" },
	IngredientDrawer { x=337,y=320, name="sugar" },
	IngredientDrawer { x=444,y=320, name="fruit" },
	IngredientDrawer { x=551,y=320, name="nut" },
	IngredientDrawer { x=658,y=320, name="flavor" },
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
	x=0,y=0, w=782,h=479, swallowmouse=true,fill=false,fit=true, color={0,0,0,-1},
	name="design_mode", 
	RecipeDesigner { x=0,y=0,fit=true, Bitmap
	{
		x=6,y=16, w=782,h=467, image="image/popup_back_designer",
		
		SetStyle(C3ButtonStyle),
		Button { x=73,y=37,  graphics=leftArrowGraphics, command=function() DecLayer(1) end },
		Bitmap { x=114,y=41, image="image/designer_custom_window",
			BitmapTint { x=13,y=13,w=64,h=64, name="option_layer0", scale=0.5 },
			Bitmap { x=13,y=13,w=64,h=64, name="option_highlight0", scale=0.5 } },
		Button { x=207,y=37, graphics=rightArrowGraphics, command=function() IncLayer(1) end },
		Button { x=120,y=133, scale=.6, command=function() SelectTint(1,32.5,185) end,
			Rectangle { name="tint1", x=10,y=6,w=kMax-12,h=kMax-11, color=colorOptions[1] },
		 },
		
		Button { x=73,y=162,  graphics=leftArrowGraphics, command=function() DecLayer(2) end },
		Bitmap { x=114,y=166, image="image/designer_custom_window",
			BitmapTint { x=13,y=13,w=64,h=64, name="option_layer1", scale=0.5 },
			Bitmap { x=13,y=13,w=64,h=64, name="option_highlight1", scale=0.5 } },
		Button { x=207,y=162, graphics=rightArrowGraphics, command=function() IncLayer(2) end },
		Button { x=120,y=258, scale=.6, command=function() SelectTint(2,32.5,308) end,
			Rectangle { name="tint2", x=10,y=6,w=kMax-12,h=kMax-11, color=colorOptions[1] },
		 },
		
		Button { x=536,y=37, graphics=leftArrowGraphics, command=function() DecLayer(3) end },
		Bitmap { x=577,y=41, image="image/designer_custom_window",
			BitmapTint { x=13,y=13,w=64,h=64, name="option_layer2", scale=0.5 },
			Bitmap { x=13,y=13,w=64,h=64, name="option_highlight2", scale=0.5 } },
		Button { x=670,y=37, graphics=rightArrowGraphics, command=function() IncLayer(3) end },
		Button { x=583,y=133, scale=.6, command=function() SelectTint(3,495.5,185) end,
			Rectangle { name="tint3", x=10,y=6,w=kMax-12,h=kMax-11, color=colorOptions[1] },
		 },

		Button { x=536,y=162, graphics=leftArrowGraphics, command=function() DecLayer(4) end },
		Bitmap { x=577,y=166, image="image/designer_custom_window",
			BitmapTint { x=13,y=13,w=64,h=64, name="option_layer3", scale=0.5 },
			Bitmap { x=13,y=13,w=64,h=64, name="option_highlight3", scale=0.5 } },
		Button { x=670,y=162, graphics=rightArrowGraphics, command=function() IncLayer(4) end },
		Button { x=583,y=258, scale=.6, command=function() SelectTint(4,495.5,308) end,
			Rectangle { name="tint4", x=10,y=6,w=kMax-12,h=kMax-11, color=colorOptions[1] },
		 },
		
		BitmapTint { x=327,y=85,w=128,h=128, name="display_layer0", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_highlight0", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_layer1", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_highlight1", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_layer2", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_highlight2", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_layer3", scale=0.5 },
		BitmapTint { x=327,y=85,w=128,h=128, name="display_highlight3", scale=0.5 },

		Text { x=18,y=322,w=184,h=41, label="recipe_name", font=whiteLabelFont, flags=kVAlignCenter+kHAlignCenter },
		Bitmap { x=202,y=322, image="image/designer_textentry_window",
			TextEdit { x=3,y=3,w=kMax-6,h=kMax-6, name="product_name", clearinitial=clearProduct, label=productName,
                utf8 = true,
				length=100, ignore=kIllegalProductChars,
				font= { uiFontName, 25, WhiteColor }, flags=kVAlignCenter+kHAlignLeft,
			},
		},
		Text { x=18,y=372,w=184,h=41, label="recipe_description", font=whiteLabelFont, flags=kVAlignCenter+kHAlignCenter },
		Bitmap { x=202,y=372, image="image/designer_textentry_window",
			TextEdit { x=3,y=3,w=kMax-6,h=kMax-6, name="product_desc", clearinitial=clearDescription, label=productDescription,
                utf8 = true,
				length=400, ignore=kIllegalProductChars,
				font= { uiFontName, 16, WhiteColor }, flags=kVAlignCenter+kHAlignLeft,
			 },
		},

--		SetStyle(C3ButtonStyle),
		Button { x=324,y=253, label="randomize", command=function() RandomDesign() end },
		Button { x=604,y=321, label="taste_recipe", command=function() CreateMode() end },
		Button { x=604,y=371, label="save_recipe", command=function() ConfirmRecipeCreation() end },
	} }
}

-------------------------------------------------------------------------------

local nameplateFont = { labelFontName, 30, Color(255,255,255,255)}


MakeDialog
{
	Window
	{
		x=1000,y=9, name="kitchen", fit=true,
		CreationModeWindow,
		DesignModeWindow,

		Bitmap { image="image/popup_nameplate", x=230,y=0,
			Text { x=34,y=10,w=270,h=38, name="nameplate", label="title_kitchen", font=nameplateFont, flags=kVAlignCenter+kHAlignCenter },
		},
--		AppendStyle(C3RoundButtonStyle),
--		Button { x=704,y=426, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("kitchen", "ok") end },
		AppendStyle(C3ButtonStyle),
		Button { x=660,y=10, name="ok", label="cancel", cancel=true, command=function() FadeCloseWindow("kitchen", "ok") end },

		SetStyle(C3RoundButtonStyle),
		Button { x=734,y=53, name="help", label="#?", command=function()
			if mode == "create_mode" then HelpDialog("help_kitchen")
			else HelpDialog("help_design")
			end
		end },
	},
}

EnableWindow("cacao", false)
EnableWindow("coffee", false)
EnableWindow("dairy", false)
EnableWindow("sugar", false)
EnableWindow("fruit", false)
EnableWindow("nut", false)
EnableWindow("flavor", false)

EnableWindow("design_recipe", false)

if not Player.categoryCount["bar"] then EnableWindow("bar", false) end
if not Player.categoryCount["beverage"] then EnableWindow("beverage", false) end
if not Player.categoryCount["infusion"] then EnableWindow("infusion", false) end
if not Player.categoryCount["truffle"] then EnableWindow("truffle", false) end
if not Player.categoryCount["blend"] then EnableWindow("blend", false) end
if not Player.categoryCount["exotic"] then EnableWindow("exotic", false) end

SetTargetCategory(targetCategory)
if not openDrawer then ToggleDrawer("cacao") end
UpdateRecipeButtons()

CreateMode()
OpenBuilding("kitchen", gDialogTable.building)