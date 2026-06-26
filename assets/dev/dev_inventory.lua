--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Dev Inventory Editor)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This tool allows administrators to arbitrarily modify the stock levels of 
-- both raw ingredients and finished manufactured products.

-- Maintain selection state across UI refreshes
gDevSelectedItems = gDevSelectedItems or {}
gDevMultiSelect = gDevMultiSelect or false

-------------------------------------------------------------------------------
-- Configuration & State
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]

-- Defines a 5-column layout matrix specifically scaled to fit within the 800px window
local col_widths = { 125, 125, 185, 185, 185 }
local col_x_positions = { 0, 125, 250, 435, 620 }
local y_start = 3 * h
local y_max = 570

local selectedColor = "20A020" -- Standard UI Green
local items = {}

-------------------------------------------------------------------------------
-- Selection Handlers
-------------------------------------------------------------------------------

-- Toggles the selection state of a specific item
local function SelectItem(item)
	if not gDevMultiSelect then
		-- Single-select mode: Purge the old selection array and reset visual labels
		for _, oldItem in ipairs(gDevSelectedItems) do
			local oldButtonName = "dev_item_" .. (oldItem.code or oldItem.name)
			SetLabel(oldButtonName, oldItem:GetName())
		end
		gDevSelectedItems = {}
	end

	local isAlreadySelected = false
	local selectedIndex = nil
	for i, selectedItem in ipairs(gDevSelectedItems) do
		if selectedItem == item then
			isAlreadySelected = true
			selectedIndex = i
			break
		end
	end

	local buttonName = "dev_item_" .. (item.code or item.name)
	if isAlreadySelected then
		-- De-select it and clear the green highlight font tags
		table.remove(gDevSelectedItems, selectedIndex)
		SetLabel(buttonName, item:GetName())
		DebugOut("DEV", string.format("Inventory Editor: De-selected item '%s'.", item:GetName()))
	else
		-- Select it and apply the green highlight font tags
		table.insert(gDevSelectedItems, item)
		local newLabel = string.format("<font color='%s'><b>%s</b></font>", selectedColor, item:GetName())
		SetLabel(buttonName, newLabel)
		DebugOut("DEV", string.format("Inventory Editor: Selected item '%s'.", item:GetName()))
	end
end

-- Toggles an entire category of items (e.g. clicking "ALL PRODUCTS")
local function SelectCategory(categoryOrType)
	if not gDevMultiSelect then
		gDevSelectedItems = {}
	end

	local itemsToSelect = {}
	
	if categoryOrType == "INGREDIENTS" then
		for _, ing in ipairs(_IngredientOrder) do table.insert(itemsToSelect, ing) end
	elseif categoryOrType == "PRODUCTS" then
		-- Exclude User-Generated Recipes from batch operations to prevent logic errors
		for _, prod in pairs(_AllProducts) do 
			if prod.category.name ~= "user" then table.insert(itemsToSelect, prod) end 
		end
	else 
		-- Specific product category object
		for _, prod in ipairs(categoryOrType.products) do table.insert(itemsToSelect, prod) end
	end

	-- Check if every item in this category is already selected
	local allSelected = true
	for _, item in ipairs(itemsToSelect) do
		local found = false
		for _, selectedItem in ipairs(gDevSelectedItems) do
			if item == selectedItem then found = true; break; end
		end
		if not found then allSelected = false; break; end
	end

	if allSelected then
		-- Bulk De-select: Remove all items matching this category from the global selection array
		local newSelection = {}
		for _, selectedItem in ipairs(gDevSelectedItems) do
			local shouldKeep = true
			for _, item in ipairs(itemsToSelect) do
				if selectedItem == item then shouldKeep = false; break; end
			end
			if shouldKeep then table.insert(newSelection, selectedItem) end
		end
		gDevSelectedItems = newSelection
		DebugOut("DEV", string.format("Inventory Editor: Bulk De-selected category '%s'.", (categoryOrType.name or categoryOrType)))
	else
		-- Bulk Select: Add any missing items from this category to the selection array
		for _, item in ipairs(itemsToSelect) do
			local found = false
			for _, selectedItem in ipairs(gDevSelectedItems) do
				if item == selectedItem then found = true; break; end
			end
			if not found then table.insert(gDevSelectedItems, item) end
		end
		DebugOut("DEV", string.format("Inventory Editor: Bulk Selected category '%s'.", (categoryOrType.name or categoryOrType)))
	end

	-- Force full UI redraw to catch all the new label highlight states
	CloseWindow()
	QueueCommand(function() DisplayDialog { "dev/dev_inventory.lua", x = gDialogTable.x, y = gDialogTable.y } end)
end

-------------------------------------------------------------------------------
-- Mathematical Operations
-------------------------------------------------------------------------------

-- Dispatches the numeric delta against all currently selected items
local function ApplyToAction(action, amount)
	if table.getn(gDevSelectedItems) == 0 then
		DebugOut("DEV", "Inventory Action Failed: No items selected.")
		return
	end
	
	DebugOut("DEV", string.format("Admin Action: Applying bulk %s (%d) to %d items.", string.upper(action), amount, table.getn(gDevSelectedItems)))
	
	for _, item in ipairs(gDevSelectedItems) do
		if action == "set" then
			local currentAmount = item:GetInventory()
			item:AdjustInventory(amount - currentAmount)
		elseif action == "add" then
			item:AdjustInventory(amount)
		elseif action == "remove" then
			item:AdjustInventory(-amount)
		end
	end
end

-- Triggers the generic numeric entry popup and routes the callback to 'set'
local function SetCustomInventory()
	if table.getn(gDevSelectedItems) > 0 then
		local prompt
		if table.getn(gDevSelectedItems) == 1 then
			prompt = "Set exact inventory amount for " .. gDevSelectedItems[1]:GetName() .. ":"
		else
			prompt = "Set exact amount for " .. table.getn(gDevSelectedItems) .. " selected items:"
		end
		
		DisplayDialog {
			"dev/dev_enter_amount.lua",
			prompt = prompt,
			initialValue = "0",
			onOk = function(amount) ApplyToAction("set", amount) end
		}
	end
end

-- Triggers the numeric popup and routes the callback to 'add'
local function AddCustomInventory()
	if table.getn(gDevSelectedItems) > 0 then
		local prompt
		if table.getn(gDevSelectedItems) == 1 then
			prompt = "Enter amount to ADD to " .. gDevSelectedItems[1]:GetName() .. ":"
		else
			prompt = "Enter amount to ADD for " .. table.getn(gDevSelectedItems) .. " selected items:"
		end

		DisplayDialog {
			"dev/dev_enter_amount.lua",
			prompt = prompt,
			onOk = function(amount) ApplyToAction("add", amount) end
		}
	end
end

-- Triggers the numeric popup and routes the callback to 'remove'
local function RemoveCustomInventory()
	if table.getn(gDevSelectedItems) > 0 then
		local prompt
		if table.getn(gDevSelectedItems) == 1 then
			prompt = "Enter amount to REMOVE from " .. gDevSelectedItems[1]:GetName() .. ":"
		else
			prompt = "Enter amount to REMOVE for " .. table.getn(gDevSelectedItems) .. " selected items:"
		end

		DisplayDialog {
			"dev/dev_enter_amount.lua",
			prompt = prompt,
			onOk = function(amount) ApplyToAction("remove", amount) end
		}
	end
end

local function ToggleMultiSelect()
	gDevMultiSelect = not gDevMultiSelect
	
	-- Purge bulk selections down to the most recent target if reverting to single-select mode
	if not gDevMultiSelect and table.getn(gDevSelectedItems) > 1 then
		gDevSelectedItems = { gDevSelectedItems[table.getn(gDevSelectedItems)] }
	end
	
	CloseWindow()
	QueueCommand(function() DisplayDialog { "dev/dev_inventory.lua", x = gDialogTable.x, y = gDialogTable.y } end)
end

-------------------------------------------------------------------------------
-- Unified Item List Generation and Rendering Engine
-------------------------------------------------------------------------------

local allItems = {}

-- Compile Ingredients Header and Body
table.insert(allItems, { isHeader = true, name = "INGREDIENTS", command = function() SelectCategory("INGREDIENTS") end })
for _, ing in ipairs(_IngredientOrder) do table.insert(allItems, ing) end

-- Compile Products Header, Sub-Headers, and Body
table.insert(allItems, { isHeader = true, name = "ALL PRODUCTS", command = function() SelectCategory("PRODUCTS") end })
for _, cat in ipairs(_CategoryOrder) do
	local tempCat = cat
	table.insert(allItems, { isHeader = true, name = string.upper(GetString(cat.name)), command = function() SelectCategory(tempCat) end })
	
	for _, prod in ipairs(cat.products) do 
		table.insert(allItems, prod) 
	end
end

-- Execute Grid Rendering (Column-Major Snake Pattern)
local current_col = 1
local x = col_x_positions[current_col]
local y = y_start

for _, item in ipairs(allItems) do
	-- Shift right to a new column if we hit the floor bound
	if y > y_max then
		current_col = current_col + 1
		if current_col > table.getn(col_x_positions) then break end
		x = col_x_positions[current_col]
		y = y_start
	end
	local w = col_widths[current_col]

	if item.isHeader then
		-- Render Header Button
		if y > y_start then y = y + (h / 2) end
		
		-- Redo column check to prevent orphans clipping off the bottom
		if y > y_max then
			current_col = current_col + 1
			if current_col > table.getn(col_x_positions) then break end
			x = col_x_positions[current_col]
			y = y_start
		end
		
		table.insert(items, Button { x = x, y = y, w = w, h = h, label = "#<b>" .. item.name .. "</b>", command = item.command })
		y = y + h
	else
		-- Render Item Button
		local label = "#" .. item:GetName()
		
		-- Detect highlight state
		for _, selectedItem in ipairs(gDevSelectedItems) do
			if item == selectedItem then
				label = "#" .. string.format("<font color='%s'><b>%s</b></font>", selectedColor, item:GetName())
				break
			end
		end
		
		local tempItem = item
		local buttonName = "dev_item_" .. (item.code or item.name)
		
		table.insert(items, Button { x = x, y = y, w = w, h = h, name = buttonName, label = label, command = function() SelectItem(tempItem) end })
		y = y + h
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	name = "dev_inventory",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = 800, h = 600, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = 75, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		TightText { x = 150, y = 0, w = 100, h = h, label = "#<b>Click an item, then choose an action.</b>" },
		
		-- Control Toolbar
		Button { x = 0, y = 1 * h, w = 125, h = h, label = "#<b>Set Amount...</b>", command = SetCustomInventory },
		Button { x = 125, y = 1 * h, w = 125, h = h, label = "#<b>Add Amount...</b>", command = AddCustomInventory },
		Button { x = 250, y = 1 * h, w = 125, h = h, label = "#<b>Remove Amount...</b>", command = RemoveCustomInventory },
		
		SetStyle(CheckboxButtonStyle),
		Button { x = 400, y = h * 0, w = 150, h = h, name = "multiSelectToggle", label = "Multi-Select", type = kToggle, command = ToggleMultiSelect },
		
		SetStyle(devMenuStyle),
		Group(items),
	},
}

SetButtonToggleState("multiSelectToggle", gDevMultiSelect)