--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Pending Order Detail
	Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local orderData = gDialogTable.orderData
local initial_x = gDialogTable.x
local initial_y = gDialogTable.y

-------------------------------------------------------------------------------
-- Action Functions

-- Helper to refresh the panel
local function RefreshPanel()
    CloseWindow()
    QueueCommand(function() DisplayDialog { "dev/dev_order_detail.lua", x=initial_x, y=initial_y, orderData=orderData } end)
end

-- Helper for numeric values
local function EditOrderValue(key, prompt)
    local valueWasChanged = false
    DisplayDialog {
        "dev/dev_enter_amount.lua",
        prompt = prompt,
        initialValue = tostring(orderData[key]),
        onOk = function(newValue)
            orderData[key] = tonumber(newValue)
            DebugOut("DEV", "Edited order '" .. orderData.name .. "'. Set " .. key .. " to " .. tostring(newValue))
            valueWasChanged = true
        end
    }
    if valueWasChanged then RefreshPanel() end
end

-- Helper for product selection
local function EditOrderProduct()
    local valueWasChanged = false
    local originalProduct = _AllProducts[orderData.product]
    gRecipeSelection = originalProduct
    gCategorySelection = originalProduct.category
    
    local ok = DisplayDialog { "ui/ui_recipes.lua" }

    if ok and gRecipeSelection and gRecipeSelection ~= originalProduct then
        orderData.product = gRecipeSelection.code
        DebugOut("DEV", "Changed order '" .. orderData.name .. "' product to: " .. gRecipeSelection:GetName())
        valueWasChanged = true
    end
    
    if valueWasChanged then RefreshPanel() end
end

-- Helper function to move a non-resident character
local function MoveNonResident(charName, fromBuildingName, toBuildingName)
    local fromBuilding = _AllBuildings[fromBuildingName]
    local toBuilding = _AllBuildings[toBuildingName]
    if fromBuilding and Player.buildingCharacters[fromBuilding.name] then
        Player.buildingCharacters[fromBuilding.name][charName] = nil
    end
    if toBuilding then
        Player.buildingCharacters[toBuilding.name] = Player.buildingCharacters[toBuilding.name] or {}
        Player.buildingCharacters[toBuilding.name][charName] = true
    end
end

local function GetCharacterSourcePool(charName)
    for _, travName in ipairs(_TravelCharacters) do
        if travName == charName then return "_travelers" end
    end
    for _, emptyName in ipairs(_EmptyCharacters) do
        if emptyName == charName then return "_empty" end
    end
    return nil -- Character is a resident of a physical building
end

-- Function to edit the starter
local function EditStarterBuilding()
    local valueWasChanged = false
    DisplayDialog {
        "dev/dev_select_building.lua",
        prompt = "Select a new starting building for the order:",
        onOk = function(newBuilding)
            orderData.startbuilding = newBuilding.name
            local starterChar = newBuilding:GetCharacterList()[1]
            if starterChar then
                orderData.starter = starterChar.name
            else
                orderData.starter = nil -- Building is empty
            end
            DebugOut("DEV", "Changed order starter building to " .. newBuilding.name)
            valueWasChanged = true
        end
    }
    if valueWasChanged then RefreshPanel() end
end

-- Function to edit the ender building and character
local function EditEnderBuilding()
    local valueWasChanged = false
    DisplayDialog {
        "dev/dev_select_building.lua",
        prompt = "Select a new destination building for the order:",
        onOk = function(newBuilding)
            -- First, move the OLD non-resident character back home before we change anything.
            if not orderData.isResident then
                MoveNonResident(orderData.ender, orderData.endbuilding, orderData.sourcePool)
            end

            orderData.endbuilding = newBuilding.name
            local enderChar = newBuilding:GetCharacterList()[1]
            
            if enderChar then
                -- The new building has a resident, so use them.
                orderData.ender = enderChar.name
                orderData.isResident = true
                orderData.sourcePool = "N/A"
            else
                -- The new building is empty, so pick a random traveler and place them there.
                local traveler = _travelers:RandomCharacter()
                orderData.ender = traveler.name
                orderData.isResident = false
                orderData.sourcePool = "_travelers"
                MoveNonResident(orderData.ender, orderData.sourcePool, orderData.endbuilding)
            end

            DebugOut("DEV", "Changed order ender building to " .. newBuilding.name .. ", new ender is " .. orderData.ender)
            valueWasChanged = true
        end
    }
    if valueWasChanged then RefreshPanel() end
end

local function EditEnderCharacter()
    local valueWasChanged = false
    DisplayDialog {
        "dev/dev_select_character.lua",
        prompt = "Select a new character to receive the order:",
        onOk = function(newChar)
            -- First, move the OLD non-resident character back home.
            if not orderData.isResident then
                MoveNonResident(orderData.ender, orderData.endbuilding, orderData.sourcePool)
            end

            orderData.ender = newChar.name
            
            local newSourcePool = GetCharacterSourcePool(newChar.name)
            if newSourcePool then
                -- The selected character is a non-resident.
                orderData.isResident = false
                orderData.sourcePool = newSourcePool
                -- Move them from their pool to the destination building.
                MoveNonResident(orderData.ender, orderData.sourcePool, orderData.endbuilding)
            else
                -- The selected character is a resident of some building.
                -- For the purpose of this dev tool, we will treat them as a resident
                -- of the destination building, even if it's not their "home".
                orderData.isResident = true
                orderData.sourcePool = "N/A"
            end

            DebugOut("DEV", "Manually changed order ender to " .. newChar.name)
            valueWasChanged = true
        end
    }
    if valueWasChanged then RefreshPanel() end
end

local function DoDelete()
    DebugOut("DEV", "Force deleting pending order: " .. orderData.name)
    QueueCommand(function()
        for i, order in ipairs(Player.pendingSpecialOrders) do
            if order.name == orderData.name then
                if not order.isResident then
                    DebugOut("DEV", "Returning non-resident ender '" .. order.ender .. "' to pool '" .. order.sourcePool .. "'")
                    if Player.buildingCharacters[order.endbuilding] then
                        Player.buildingCharacters[order.endbuilding][order.ender] = nil
                    end
                    Player.buildingCharacters[order.sourcePool] = Player.buildingCharacters[order.sourcePool] or {}
                    Player.buildingCharacters[order.sourcePool][order.ender] = true
                    Player.orderBannedChars[order.ender] = nil
                    Player.orderBannedBuildings[order.endbuilding] = nil
                end
                table.remove(Player.pendingSpecialOrders, i)
                break
            end
        end
    end)
end
local function DoForceOfferStarter()
    DebugOut("DEV", "Force offering order '" .. orderData.name .. "' via starter.")
    QueueCommand(function()
        local startBuilding = _AllBuildings[orderData.startbuilding]
        local starterChar = startBuilding:GetCharacterList()[1]
        OfferDeliveryQuestInPerson(orderData, starterChar, startBuilding)
    end)
end
local function DoForceOfferEnder()
    DebugOut("DEV", "Force offering order '" .. orderData.name .. "' via ender.")
    QueueCommand(function()
        local endBuilding = _AllBuildings[orderData.endbuilding]
        local enderChar = _AllCharacters[orderData.ender]
        OfferDeliveryQuestInPerson(orderData, enderChar, endBuilding)
    end)
end
local function DoForceTelegram()
    DebugOut("DEV", "Force offering order '" .. orderData.name .. "' via telegram.")
    QueueCommand(function()
        local quest = CreateDeliveryQuest(orderData, orderData.isResident, orderData.sourcePool)
        quest:Offer()
    end)
end
local function DoExpireEarlyOffer()
    DebugOut("DEV", "Force expiring early offer window for: " .. orderData.name)
    QueueCommand(function()
        for _, order in ipairs(Player.pendingSpecialOrders) do
            if order.name == orderData.name then
                order.earlyOfferCutoff = Player.time - 1
                break
            end
        end
    end)
end

-------------------------------------------------------------------------------
-- UI Layout Configuration

local h = devMenuStyle.font[2]
local total_width = 800
local total_height = 220
local padding = 10

local col_width_left = 300
local col_width_mid = 225
local col_width_right = 225

local col_x_left = padding
local col_x_mid = col_x_left + col_width_left + padding
local col_x_right = col_x_mid + col_width_mid + padding

local info_area_height = total_height - (3 * h)

-------------------------------------------------------------------------------
-- Build the UI Elements for Each Column

local items = {}
local product = _AllProducts[orderData.product]
local starterBuilding = _AllBuildings[orderData.startbuilding]
local starterName = "[STARTER NOT FOUND]"
if orderData.starter then
    starterName = GetString(orderData.starter)
end

-- Column 1: Order Details
local y = 0
table.insert(items, Text { x=col_x_left, y=y, w=col_width_left, h=h, label="#<b>ORDER DETAILS</b>", flags=kVAlignCenter+kHAlignLeft })
y = y + h*2
table.insert(items, Text { x=col_x_left, y=y, w=col_width_left-60, h=h*2, label="#<b>Product:</b> " .. product:GetName(), flags=kVAlignTop+kHAlignLeft })
table.insert(items, Button { x=col_x_left+col_width_left-60, y=y, w=60, h=h, label="#[Edit...]", command=EditOrderProduct })
y = y + h*2
table.insert(items, Text { x=col_x_left, y=y, w=col_width_left-60, h=h, label="#<b>Count:</b> " .. orderData.count .. " cases", flags=kVAlignCenter+kHAlignLeft })
table.insert(items, Button { x=col_x_left+col_width_left-60, y=y, w=60, h=h, label="#[Edit...]", command=function() EditOrderValue("count", "Enter new case count:") end })
y = y + h*2
table.insert(items, Text { x=col_x_left, y=y, w=col_width_left-60, h=h, label="#<b>Payment:</b> " .. Dollars(orderData.price), flags=kVAlignCenter+kHAlignLeft })
table.insert(items, Button { x=col_x_left+col_width_left-60, y=y, w=60, h=h, label="#[Edit...]", command=function() EditOrderValue("price", "Enter new total payment:") end })
y = y + h*2
table.insert(items, Text { x=col_x_left, y=y, w=col_width_left-60, h=h, label="#<b>Deadline:</b> " .. orderData.expires .. " weeks", flags=kVAlignCenter+kHAlignLeft })
table.insert(items, Button { x=col_x_left+col_width_left-60, y=y, w=60, h=h, label="#[Edit...]", command=function() EditOrderValue("expires", "Enter new deadline (weeks):") end })


-- Column 2: Participants
y = 0
table.insert(items, Text { x=col_x_mid, y=y, w=col_width_mid, h=h, label="#<b>PARTICIPANTS</b>", flags=kVAlignCenter+kHAlignLeft })
y = y + h*2
table.insert(items, Text { x=col_x_mid, y=y, w=col_width_mid-60, h=h, label="#<b>Starter:</b>", flags=kVAlignCenter+kHAlignLeft })
table.insert(items, Button { x=col_x_mid+col_width_mid-60, y=y, w=60, h=h, label="#[Edit...]", command=EditStarterBuilding })
y = y + h
table.insert(items, Text { x=col_x_mid+10, y=y, w=col_width_mid, h=h*2, label="#  " .. starterName .. "<br>  at " .. GetString(starterBuilding.name), flags=kVAlignTop+kHAlignLeft })
y = y + h*3
table.insert(items, Text { x=col_x_mid, y=y, w=col_width_mid-60, h=h, label="#<b>Ender:</b>", flags=kVAlignCenter+kHAlignLeft })
table.insert(items, Button { x=col_x_mid+col_width_mid-60, y=y, w=60, h=h, label="#[Edit...]", command=EditEnderBuilding })
table.insert(items, Button { x=col_x_mid+col_width_mid-60, y=y+h, w=60, h=h, label="#[Char...]", command=EditEnderCharacter })
y = y + h
table.insert(items, Text { x=col_x_mid+10, y=y, w=col_width_mid, h=h*2, label="#  " .. GetString(orderData.ender) .. "<br>  at " .. GetString(orderData.endbuilding), flags=kVAlignTop+kHAlignLeft })


-- Column 3: System Data
y = 0
table.insert(items, Text { x=col_x_right, y=y, w=col_width_right, h=h, label="#<b>SYSTEM DATA</b>", flags=kVAlignCenter+kHAlignLeft })
y = y + h*2
table.insert(items, Text { x=col_x_right, y=y, w=col_width_right-60, h=h, label="#<b>Early Offer Cutoff:</b> Week " .. orderData.earlyOfferCutoff, flags=kVAlignCenter+kHAlignLeft })
table.insert(items, Button { x=col_x_right+col_width_right-60, y=y, w=60, h=h, label="#[Edit...]", command=function() EditOrderValue("earlyOfferCutoff", "Enter new cutoff week:") end })
y = y + h*2
table.insert(items, Text { x=col_x_right, y=y, w=col_width_right, h=h, label="#<b>Ender is Resident:</b> " .. tostring(orderData.isResident), flags=kVAlignCenter+kHAlignLeft })
y = y + h*2
table.insert(items, Text { x=col_x_right, y=y, w=col_width_right, h=h, label="#<b>Ender Source Pool:</b> " .. (orderData.sourcePool or "N/A"), flags=kVAlignCenter+kHAlignLeft })


-- Footer / Action Buttons (with your new layout)
local footer_items = {}
local footer_y = total_height - (2 * h) - padding
table.insert(footer_items, Button { x=padding, y=footer_y, w=150, h=h, label="#<b>[- Force Offer via Starter -]</b>", command=DoForceOfferStarter, close=true })
table.insert(footer_items, Button { x=padding + 150, y=footer_y, w=150, h=h, label="#<b>[- Force Offer via Ender -]</b>", command=DoForceOfferEnder, close=true })
table.insert(footer_items, Button { x=padding + 297.5, y=footer_y, w=160, h=h, label="#<b>[- Force Offer via Telegram -]</b>", command=DoForceTelegram, close=true })
table.insert(footer_items, Button { x=padding + 462, y=footer_y, w=170, h=h, label="#<b>[- Expire Early Offer Window -]</b>", command=DoExpireEarlyOffer, close=true })
table.insert(footer_items, Button { x=padding + 634, y=footer_y, w=150, h=h, label="#<b>[-- DELETE ORDER --]</b>", command=DoDelete, close=true })

-------------------------------------------------------------------------------

MakeDialog
{
    name="dev_order_detail",
    BSGWindow { x=initial_x, y=initial_y, w=total_width, h=total_height, fit=true, color={1,1,1,.9}, SetStyle(devMenuStyle),
        -- Header
        Text { x=padding, y=0, w=total_width, h=h, label="#<b>PENDING ORDER: " .. orderData.name .. "</b>", flags=kVAlignCenter+kHAlignLeft },
        Button { x=total_width - 150 - padding, y=0, w=150, h=h, label="#<b>BACK TO LIST</b>", default=true, cancel=true, 
            command=function() 
                CloseWindow(); 
                QueueCommand(function() DisplayDialog { "dev/dev_quests.lua", x=initial_x, y=initial_y } end)
            end 
        },
        -- Main Content Area
        Window { x=0, y=h+padding, w=total_width, h=info_area_height,
            Group(items)
        },
        -- Footer
        Group(footer_items)
    },
}