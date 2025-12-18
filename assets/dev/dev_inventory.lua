--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Inventory
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

gDevSelectedItems = gDevSelectedItems or {}
gDevMultiSelect = gDevMultiSelect or false

-------------------------------------------------------------------------------
-- Configuration & State
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local col_widths = { 125, 125, 185, 185, 185 }
local col_x_positions = { 0, 125, 250, 435, 620 }
local y_start = 4 * h
local y_max = 550

local selectedColor = "20A020" -- Green
local items = {}

-------------------------------------------------------------------------------
-- Action Functions (Now support multiple items)
-------------------------------------------------------------------------------

local function SelectItem(item)
    if not gDevMultiSelect then
        -- Single-select mode: clear previous selection and visually reset them
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
        -- If already selected, de-select it and reset its label
        table.remove(gDevSelectedItems, selectedIndex)
        SetLabel(buttonName, item:GetName())
        DebugOut("DEV", "'" .. item:GetName() .. "' de-selected.")
    else
        -- If not selected, add it to the selection and highlight its label
        table.insert(gDevSelectedItems, item)
        local newLabel = string.format("<font color='%s'><b>%s</b></font>", selectedColor, item:GetName())
        SetLabel(buttonName, newLabel)
        DebugOut("DEV", "'" .. item:GetName() .. "' selected.")
    end
end

local function SelectCategory(categoryOrType)
    if not gDevMultiSelect then
        gDevSelectedItems = {}
    end

    local itemsToSelect = {}
    if categoryOrType == "INGREDIENTS" then
        for _, ing in ipairs(_IngredientOrder) do table.insert(itemsToSelect, ing) end
    elseif categoryOrType == "PRODUCTS" then
        for _, prod in pairs(_AllProducts) do if prod.category.name ~= "user" then table.insert(itemsToSelect, prod) end end
    else -- It's a specific product category object
        for _, prod in ipairs(categoryOrType.products) do table.insert(itemsToSelect, prod) end
    end

    local allSelected = true
    for _, item in ipairs(itemsToSelect) do
        local found = false
        for _, selectedItem in ipairs(gDevSelectedItems) do
            if item == selectedItem then found = true; break; end
        end
        if not found then allSelected = false; break; end
    end

    if allSelected then
        local newSelection = {}
        for _, selectedItem in ipairs(gDevSelectedItems) do
            local shouldKeep = true
            for _, item in ipairs(itemsToSelect) do
                if selectedItem == item then shouldKeep = false; break; end
            end
            if shouldKeep then table.insert(newSelection, selectedItem) end
        end
        gDevSelectedItems = newSelection
        DebugOut("DEV", "De-selected all items in category: " .. (categoryOrType.name or categoryOrType))
    else
        for _, item in ipairs(itemsToSelect) do
            local found = false
            for _, selectedItem in ipairs(gDevSelectedItems) do
                if item == selectedItem then found = true; break; end
            end
            if not found then table.insert(gDevSelectedItems, item) end
        end
        DebugOut("DEV", "Selected all items in category: " .. (categoryOrType.name or categoryOrType))
    end

    CloseWindow()
    QueueCommand(function() DisplayDialog { "dev/dev_inventory.lua", x=gDialogTable.x, y=gDialogTable.y } end)
end

local function ApplyToAction(action, amount)
    if table.getn(gDevSelectedItems) == 0 then
        DebugOut("DEV", "No items selected for action.")
        return
    end
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

local function SetCustomInventory()
    if table.getn(gDevSelectedItems) > 0 then
        local prompt
        if table.getn(gDevSelectedItems) == 1 then
            prompt = "Set amount for " .. gDevSelectedItems[1]:GetName() .. ":"
        else
            prompt = "Set amount for " .. table.getn(gDevSelectedItems) .. " selected items:"
        end
        
        DisplayDialog {
            "dev/dev_enter_amount.lua",
            prompt = prompt,
            initialValue = "0",
            onOk = function(amount) ApplyToAction("set", amount) end
        }
    else
        DebugOut("DEV", "No item selected to set inventory amount.")
    end
end

local function AddCustomInventory()
    if table.getn(gDevSelectedItems) > 0 then
        local prompt
        if table.getn(gDevSelectedItems) == 1 then
            prompt = "Enter amount to add for " .. gDevSelectedItems[1]:GetName() .. ":"
        else
            prompt = "Enter amount to add for " .. table.getn(gDevSelectedItems) .. " selected items:"
        end

        DisplayDialog {
            "dev/dev_enter_amount.lua",
            prompt = prompt,
            onOk = function(amount) ApplyToAction("add", amount) end
        }
    else
        DebugOut("DEV", "No item selected to add to inventory.")
    end
end

local function RemoveCustomInventory()
    if table.getn(gDevSelectedItems) > 0 then
        local prompt
        if table.getn(gDevSelectedItems) == 1 then
            prompt = "Enter amount to remove for " .. gDevSelectedItems[1]:GetName() .. ":"
        else
            prompt = "Enter amount to remove for " .. table.getn(gDevSelectedItems) .. " selected items:"
        end

        DisplayDialog {
            "dev/dev_enter_amount.lua",
            prompt = prompt,
            onOk = function(amount) ApplyToAction("remove", amount) end
        }
    else
        DebugOut("DEV", "No item selected to remove from inventory.")
    end
end

local function ToggleMultiSelect()
    gDevMultiSelect = not gDevMultiSelect
    if not gDevMultiSelect and table.getn(gDevSelectedItems) > 1 then
        gDevSelectedItems = { gDevSelectedItems[table.getn(gDevSelectedItems)] }
    end
    CloseWindow()
    QueueCommand(function() DisplayDialog { "dev/dev_inventory.lua", x=gDialogTable.x, y=gDialogTable.y } end)
end

-------------------------------------------------------------------------------
-- Unified Item List Generation and Rendering Loop
-------------------------------------------------------------------------------

local allItems = {}
table.insert(allItems, { isHeader = true, name = "INGREDIENTS", command = function() SelectCategory("INGREDIENTS") end })
for _, ing in ipairs(_IngredientOrder) do table.insert(allItems, ing) end

table.insert(allItems, { isHeader = true, name = "ALL PRODUCTS", command = function() SelectCategory("PRODUCTS") end })
for _, cat in ipairs(_CategoryOrder) do
    local tempCat = cat
    table.insert(allItems, { isHeader = true, name = string.upper(GetString(cat.name)), command = function() SelectCategory(tempCat) end })
    for _, prod in ipairs(cat.products) do table.insert(allItems, prod) end
end

local current_col = 1
local x = col_x_positions[current_col]
local y = y_start

for _, item in ipairs(allItems) do
    if y > y_max then
        current_col = current_col + 1
        if current_col > table.getn(col_x_positions) then break end
        x = col_x_positions[current_col]
        y = y_start
    end
    local w = col_widths[current_col]

    if item.isHeader then
        if y > y_start then y = y + (h / 2) end
        if y > y_max then
            current_col = current_col + 1
            if current_col > table.getn(col_x_positions) then break end
            x = col_x_positions[current_col]
            y = y_start
        end
        table.insert(items, Button { x=x, y=y, w=w, h=h, label="#<b>"..item.name.."</b>", command=item.command })
        y = y + h
    else
        local label = "#" .. item:GetName()
        for _, selectedItem in ipairs(gDevSelectedItems) do
            if item == selectedItem then
                label = "#" .. string.format("<font color='%s'><b>%s</b></font>", selectedColor, item:GetName())
                break
            end
        end
        local tempItem = item
        local buttonName = "dev_item_" .. (item.code or item.name)
        table.insert(items, Button { x=x, y=y, w=w, h=h, name=buttonName, label=label, command=function() SelectItem(tempItem) end })
        y = y + h
    end
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_inventory",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=800,h=600, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=125,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		TightText { x=0,y=h,w=400,h=h, label="#<b>Click an item, then choose an action.</b>" },
		Button { x=0,y=2*h,w=125,h=h, label="#<b>Set Amount...</b>", command=SetCustomInventory },
        Button { x=125,y=2*h,w=125,h=h, label="#<b>Add Amount...</b>", command=AddCustomInventory },
        Button { x=250,y=2*h,w=125,h=h, label="#<b>Remove Amount...</b>", command=RemoveCustomInventory },
        
        SetStyle(CheckboxButtonStyle),
        Button { x=400, y=h*2, w=150, h=h, name="multiSelectToggle", label="Multi-Select", type=kToggle, command=ToggleMultiSelect },
		
        SetStyle(devMenuStyle),
		Group(items),
	},
}

SetButtonToggleState("multiSelectToggle", gDevMultiSelect)