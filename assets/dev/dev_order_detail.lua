--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Special Order Editor)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local orderData = gDialogTable.orderData
local initial_x = gDialogTable.x
local initial_y = gDialogTable.y

-------------------------------------------------------------------------------
-- Data Normalization
-------------------------------------------------------------------------------

-- Support Legacy save files: Converts single-product schema to multi-item format
if not orderData.items then
	orderData.items = {
		{ product = orderData.product, count = orderData.count, price = orderData.price }
	}
end

-- Fix sparse arrays: If items 1 or 2 are empty but 3 is full, shift them upwards
local cleanItems = {}
for i = 1, 10 do 
	if orderData.items[i] then table.insert(cleanItems, orderData.items[i]) end
end
orderData.items = cleanItems

-------------------------------------------------------------------------------
-- Action Manipulators
-------------------------------------------------------------------------------

local function RefreshPanel()
	CloseWindow()
	QueueCommand(function() DisplayDialog { "dev/dev_order_detail.lua", x = initial_x, y = initial_y, orderData = orderData } end)
end

-- ----------------------------------------------------------------------------
-- Algorithm: Auto-Calculate Order Math
-- ----------------------------------------------------------------------------
-- Synthesizes the exact math used by the global quest generator to formulate 
-- a fair market price and timeline based on the items placed in this draft container.
local function AutoCalculateOrder()
	DebugOut("DEV", string.format("Admin Action: Auto-calculating fair market price and deadline for: %s", orderData.name))
	
	local totalPrice = 0
	local numItems = table.getn(orderData.items)
	local usedFactories = {}
	
	if numItems == 0 then return end

	-- Part 1: Calculate raw margins
	for _, item in ipairs(orderData.items) do
		local prod = _AllProducts[item.product]
		if prod then
			-- Base price is standard max retail * 3 (A premium order payload)
			local basePrice = Floor(prod.price_high * 3) * item.count
			
			-- Apply global difficulty constraints
			if Player.difficulty == 2 then 
				basePrice = Floor(basePrice * 0.9)
			elseif Player.difficulty == 3 then 
				basePrice = Floor(basePrice * 0.6) 
			end
			
			totalPrice = totalPrice + basePrice
			
			if prod.category and prod.category.factory then
				usedFactories[prod.category.factory] = true
			end
		end
	end

	-- Part 2: Apply Complexity Multipliers (Multi-item logistical hassle)
	if numItems > 1 then
		local complexityBonus = 1.0 + ((numItems - 1) * 0.15)
		
		local numFactories = 0
		for _ in pairs(usedFactories) do numFactories = numFactories + 1 end
		
		-- If they have to use BOTH a Coffee and Chocolate factory, charge an extra 10% premium
		if numFactories > 1 then complexityBonus = complexityBonus + 0.10 end
		
		totalPrice = Floor(totalPrice * complexityBonus)
	end
	
	orderData.price = totalPrice

	-- Part 3: Calculate Time Limit Deadline
	local baseWeeks = 8
	if Player.rank == 2 then baseWeeks = RandRange(16, 20)
	elseif Player.rank == 3 then baseWeeks = RandRange(12, 16)
	elseif Player.rank == 4 then baseWeeks = RandRange(10, 14)
	elseif Player.rank >= 5 then baseWeeks = RandRange(8, 12) end
	
	local totalWeeks = baseWeeks * 2
	
	-- Grant an extra 4 weeks of grace period for every additional item line in the order
	if numItems > 1 then totalWeeks = totalWeeks + (numItems - 1) * 4 end
	
	-- Severely compress time limits on higher difficulties
	if Player.difficulty == 2 then totalWeeks = Floor(totalWeeks * 0.75)
	elseif Player.difficulty == 3 then totalWeeks = Floor(totalWeeks * 0.5) end
	
	orderData.expires = totalWeeks
	RefreshPanel()
end

-- ----------------------------------------------------------------------------
-- UI Input Proxies
-- ----------------------------------------------------------------------------

local function EditOrderValue(key, prompt, itemIndex)
	local initialVal
	if itemIndex then
		if orderData.items[itemIndex] then
			initialVal = tostring(orderData.items[itemIndex][key])
		else
			initialVal = "0"
		end
	else
		initialVal = tostring(orderData[key])
	end

	local valueWasChanged = false
	DisplayDialog {
		"dev/dev_enter_amount.lua",
		prompt = prompt,
		initialValue = initialVal,
		
		onOk = function(newValue)
			local numVal = tonumber(newValue)
			
			if itemIndex and orderData.items[itemIndex] then
				 orderData.items[itemIndex][key] = numVal
				 
				 -- Synchronize root metadata if we edited the primary item line
				 if itemIndex == 1 and key == "count" then orderData.count = numVal end
				 DebugOut("DEV", string.format("Order Editor: Replaced slot %d key '%s' with %s", itemIndex, key, tostring(newValue)))
			else
				orderData[key] = numVal
				DebugOut("DEV", string.format("Order Editor: Replaced global key '%s' with %s", key, tostring(newValue)))
			end
			valueWasChanged = true
		end
	}
	
	if valueWasChanged then RefreshPanel() end
end

-- Uses the in-game Recipe Book UI to visually select a product for the slot
local function EditOrderProduct(itemIndex)
	local valueWasChanged = false
	local currentCode = "b01"
	
	if orderData.items[itemIndex] then
		currentCode = orderData.items[itemIndex].product
	end

	gRecipeSelection = _AllProducts[currentCode]
	gCategorySelection = gRecipeSelection.category
	
	local ok = DisplayDialog { "ui/ui_recipes.lua" }

	if ok and gRecipeSelection then
		if not orderData.items[itemIndex] then
			orderData.items[itemIndex] = { product = gRecipeSelection.code, count = 25, price = 0 }
			DebugOut("DEV", string.format("Order Editor: Injected new item slot %d -> %s", itemIndex, gRecipeSelection.code))
		else
			orderData.items[itemIndex].product = gRecipeSelection.code
			DebugOut("DEV", string.format("Order Editor: Replaced product in slot %d -> %s", itemIndex, gRecipeSelection.code))
		end
		
		if itemIndex == 1 then orderData.product = gRecipeSelection.code end
		valueWasChanged = true
	end
	
	if valueWasChanged then RefreshPanel() end
end

local function RemoveItem(itemIndex)
	if orderData.items[itemIndex] then
		DebugOut("DEV", string.format("Order Editor: Purged slot %d", itemIndex))
		table.remove(orderData.items, itemIndex)
		
		if itemIndex == 1 and orderData.items[1] then
			orderData.product = orderData.items[1].product
			orderData.count = orderData.items[1].count
		end
		RefreshPanel()
	end
end

-- ----------------------------------------------------------------------------
-- Geography & Network Logic Modifiers
-- ----------------------------------------------------------------------------

-- Transfers a character explicitly from one backend array to another
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

-- Determines if a character is a World Wanderer or an Empty Building placeholder
local function GetCharacterSourcePool(charName)
	for _, travName in ipairs(_TravelCharacters) do if travName == charName then return "_travelers" end end
	for _, emptyName in ipairs(_EmptyCharacters) do if emptyName == charName then return "_empty" end end
	return nil
end

local function EditStarterBuilding()
	DisplayDialog {
		"dev/dev_select_building.lua",
		prompt = "Select new starting building:",
		onOk = function(newBuilding)
			orderData.startbuilding = newBuilding.name
			local starterChar = newBuilding:GetCharacterList()[1]
			orderData.starter = starterChar and starterChar.name or nil
			RefreshPanel()
		end
	}
end

local function EditEnderBuilding()
	DisplayDialog {
		"dev/dev_select_building.lua",
		prompt = "Select new destination building:",
		onOk = function(newBuilding)
			if not orderData.isResident then 
				MoveNonResident(orderData.ender, orderData.endbuilding, orderData.sourcePool) 
			end
			
			orderData.endbuilding = newBuilding.name
			local enderChar = newBuilding:GetCharacterList()[1]
			
			if enderChar then
				orderData.ender = enderChar.name
				orderData.isResident = true
				orderData.sourcePool = "N/A"
			else
				local traveler = _travelers:RandomCharacter()
				orderData.ender = traveler.name
				orderData.isResident = false
				orderData.sourcePool = "_travelers"
				MoveNonResident(orderData.ender, orderData.sourcePool, orderData.endbuilding)
			end
			RefreshPanel()
		end
	}
end

local function EditEnderCharacter()
	DisplayDialog {
		"dev/dev_select_character.lua",
		prompt = "Select recipient character:",
		onOk = function(newChar)
			if not orderData.isResident then 
				MoveNonResident(orderData.ender, orderData.endbuilding, orderData.sourcePool) 
			end
			
			orderData.ender = newChar.name
			local newSourcePool = GetCharacterSourcePool(newChar.name)
			
			if newSourcePool then
				orderData.isResident = false
				orderData.sourcePool = newSourcePool
				MoveNonResident(orderData.ender, orderData.sourcePool, orderData.endbuilding)
			else
				orderData.isResident = true
				orderData.sourcePool = "N/A"
			end
			RefreshPanel()
		end
	}
end

-- ----------------------------------------------------------------------------
-- Explicit Force Execution Hooks
-- ----------------------------------------------------------------------------

local function DoDelete()
	for i, order in ipairs(Player.pendingSpecialOrders) do
		if order.name == orderData.name then
			if not order.isResident then
				if Player.buildingCharacters[order.endbuilding] then Player.buildingCharacters[order.endbuilding][order.ender] = nil end
				Player.buildingCharacters[order.sourcePool] = Player.buildingCharacters[order.sourcePool] or {}
				Player.buildingCharacters[order.sourcePool][order.ender] = true
				Player.orderBannedChars[order.ender] = nil
				Player.orderBannedBuildings[order.endbuilding] = nil
			end
			
			table.remove(Player.pendingSpecialOrders, i)
			DebugOut("DEV", string.format("Admin Action: Aborted and scrubbed special order '%s'.", orderData.name))
			break
		end
	end
end

local function DoForceOfferStarter()
	local startBuilding = _AllBuildings[orderData.startbuilding]
	OfferDeliveryQuestInPerson(orderData, startBuilding:GetCharacterList()[1], startBuilding)
end

local function DoForceOfferEnder()
	OfferDeliveryQuestInPerson(orderData, _AllCharacters[orderData.ender], _AllBuildings[orderData.endbuilding])
end

local function DoForceTelegram()
	local quest = CreateDeliveryQuest(orderData, orderData.isResident, orderData.sourcePool)
	quest:Offer()
end

local function DoExpireEarlyOffer()
	for _, order in ipairs(Player.pendingSpecialOrders) do
		if order.name == orderData.name then 
			order.earlyOfferCutoff = Player.time - 1
			break 
		end
	end
	RefreshPanel()
end

-------------------------------------------------------------------------------
-- UI Construction Layout Array
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local total_width = 800
local total_height = 260
local padding = 10

local col_width_left = 300
local col_width_mid = 225
local col_width_right = 225

local col_x_left = padding
local col_x_mid = col_x_left + col_width_left + padding
local col_x_right = col_x_mid + col_width_mid + padding

local info_area_height = total_height - (3 * h)
local items = {}

local starterName = orderData.starter and GetString(orderData.starter) or "[EMPTY]"

-- ============================================================================
-- Column 1: Order Item Configuration
-- ============================================================================
local y = 0
table.insert(items, Text { x = col_x_left, y = y, w = col_width_left, h = h, label = "#<b>ORDER DETAILS</b>", flags = kVAlignCenter + kHAlignLeft })
y = y + h * 2

-- Loop for 3 theoretical product slots (The game hard caps orders at 3 variations)
for i = 1, 3 do
	local index = i 
	local item = orderData.items[index]
	
	if item then
		local prodName = _AllProducts[item.product] and _AllProducts[item.product]:GetName() or "Unknown"
		
		table.insert(items, Text { x = col_x_left, y = y, w = col_width_left - 60, h = h, label = "#<b>Item " .. index .. ":</b> " .. prodName, flags = kVAlignCenter + kHAlignLeft })
		table.insert(items, Button { x = col_x_left + col_width_left - 60, y = y, w = 60, h = h, label = "#[Edit]", command = function() EditOrderProduct(index) end })
		
		y = y + h
		
		table.insert(items, Text { x = col_x_left + 10, y = y, w = col_width_left - 70, h = h, label = "#  Count: " .. item.count, flags = kVAlignCenter + kHAlignLeft })
		table.insert(items, Button { x = col_x_left + col_width_left - 60, y = y, w = 60, h = h, label = "#[Edit]", command = function() EditOrderValue("count", "New count:", index) end })
		
		if index > 1 then
			 table.insert(items, Button { x = col_x_left + col_width_left - 115, y = y, w = 50, h = h, label = "#[Clear]", command = function() RemoveItem(index) end })
		end
		
		y = y + h * 1.5 
	else
		table.insert(items, Text { x = col_x_left, y = y, w = col_width_left - 60, h = h, label = "#<b>Item " .. index .. ":</b> [Empty]", flags = kVAlignCenter + kHAlignLeft })
		table.insert(items, Button { x = col_x_left + col_width_left - 60, y = y, w = 60, h = h, label = "#[Add...]", command = function() EditOrderProduct(index) end })
		y = y + h * 2.5
	end
end

-- Footer Financials
table.insert(items, Text { x = col_x_left, y = y, w = col_width_left - 60, h = h, label = "#<b>Payment:</b> " .. Dollars(orderData.price), flags = kVAlignCenter + kHAlignLeft })
table.insert(items, Button { x = col_x_left + col_width_left - 60, y = y, w = 60, h = h, label = "#[Edit]", command = function() EditOrderValue("price", "New payment:") end })
y = y + h * 1.5

table.insert(items, Text { x = col_x_left, y = y, w = col_width_left - 60, h = h, label = "#<b>Deadline:</b> " .. orderData.expires .. " weeks", flags = kVAlignCenter + kHAlignLeft })
table.insert(items, Button { x = col_x_left + col_width_left - 60, y = y, w = 60, h = h, label = "#[Edit]", command = function() EditOrderValue("expires", "New deadline:") end })
y = y + h * 1.5

table.insert(items, Button { x = col_x_left, y = y, w = col_width_left, h = h, label = "#<b>[-- AUTO-CALCULATE PRICE & TIME --]</b>", command = AutoCalculateOrder })

-- ============================================================================
-- Column 2: Geographic Network Participants
-- ============================================================================
y = 0
table.insert(items, Text { x = col_x_mid, y = y, w = col_width_mid, h = h, label = "#<b>PARTICIPANTS</b>", flags = kVAlignCenter + kHAlignLeft })
y = y + h * 2

table.insert(items, Text { x = col_x_mid, y = y, w = col_width_mid - 60, h = h, label = "#<b>Starter:</b>", flags = kVAlignCenter + kHAlignLeft })
table.insert(items, Button { x = col_x_mid + col_width_mid - 60, y = y, w = 60, h = h, label = "#[Edit]", command = EditStarterBuilding })
y = y + h

table.insert(items, Text { x = col_x_mid + 10, y = y, w = col_width_mid, h = h * 2, label = "#  " .. starterName .. "<br>  at " .. GetString(orderData.startbuilding), flags = kVAlignTop + kHAlignLeft })
y = y + h * 3

table.insert(items, Text { x = col_x_mid, y = y, w = col_width_mid - 60, h = h, label = "#<b>Ender:</b>", flags = kVAlignCenter + kHAlignLeft })
table.insert(items, Button { x = col_x_mid + col_width_mid - 60, y = y, w = 60, h = h, label = "#[Bldg]", command = EditEnderBuilding })
table.insert(items, Button { x = col_x_mid + col_width_mid - 60, y = y + h, w = 60, h = h, label = "#[Char]", command = EditEnderCharacter })
y = y + h

table.insert(items, Text { x = col_x_mid + 10, y = y, w = col_width_mid, h = h * 2, label = "#  " .. GetString(orderData.ender) .. "<br>  at " .. GetString(orderData.endbuilding), flags = kVAlignTop + kHAlignLeft })

-- ============================================================================
-- Column 3: Backend System Status Data
-- ============================================================================
y = 0
table.insert(items, Text { x = col_x_right, y = y, w = col_width_right, h = h, label = "#<b>SYSTEM DATA</b>", flags = kVAlignCenter + kHAlignLeft })
y = y + h * 2

table.insert(items, Text { x = col_x_right, y = y, w = col_width_right - 60, h = h, label = "#<b>Offer Cutoff:</b> Wk " .. orderData.earlyOfferCutoff, flags = kVAlignCenter + kHAlignLeft })
table.insert(items, Button { x = col_x_right + col_width_right - 60, y = y, w = 60, h = h, label = "#[Edit]", command = function() EditOrderValue("earlyOfferCutoff", "New cutoff:") end })
y = y + h * 1.5

table.insert(items, Text { x = col_x_right, y = y, w = col_width_right, h = h, label = "#<b>Resident Ender:</b> " .. tostring(orderData.isResident), flags = kVAlignCenter + kHAlignLeft })
y = y + h * 1.5

table.insert(items, Text { x = col_x_right, y = y, w = col_width_right, h = h, label = "#<b>Source Pool:</b> " .. (orderData.sourcePool or "N/A"), flags = kVAlignCenter + kHAlignLeft })
y = y + h * 1.5

local evilStatus = orderData.isEvilScheme and "<font color='FF0000'>TRUE</font>" or "FALSE"
table.insert(items, Text { x = col_x_right, y = y, w = col_width_right, h = h, label = "#<b>Evil Scheme:</b> " .. evilStatus, flags = kVAlignCenter + kHAlignLeft })

-- ============================================================================
-- Footer Array: Force Execution Triggers
-- ============================================================================
local footer_items = {}
local footer_y = total_height - (2 * h) - padding

table.insert(footer_items, Button { x = padding, y = footer_y, w = 150, h = h, label = "#<b>[- Force Starter Offer -]</b>", command = DoForceOfferStarter, close = true })
table.insert(footer_items, Button { x = padding + 150, y = footer_y, w = 150, h = h, label = "#<b>[- Force Ender Offer -]</b>", command = DoForceOfferEnder, close = true })
table.insert(footer_items, Button { x = padding + 297, y = footer_y, w = 160, h = h, label = "#<b>[- Force Telegram Offer -]</b>", command = DoForceTelegram, close = true })
table.insert(footer_items, Button { x = padding + 460, y = footer_y, w = 170, h = h, label = "#<b>[- Expire Offer Window -]</b>", command = DoExpireEarlyOffer, close = true })
table.insert(footer_items, Button { x = padding + 634, y = footer_y, w = 150, h = h, label = "#<b>[-- DELETE ORDER --]</b>", command = DoDelete, close = true })

-------------------------------------------------------------------------------

MakeDialog
{
	name = "dev_order_detail",
	BSGWindow { 
		x = initial_x, y = initial_y, w = total_width, h = total_height, fit = true, color = { 1, 1, 1, 0.9 }, SetStyle(devMenuStyle),
		
		Text { x = padding, y = 0, w = total_width, h = h, label = "#<b>PENDING ORDER: " .. orderData.name .. "</b>", flags = kVAlignCenter + kHAlignLeft },
		
		Button { 
			x = total_width - 150 - padding, y = 0, w = 150, h = h, label = "#<b>BACK TO LIST</b>", default = true, cancel = true, 
			command = function() 
				CloseWindow(); 
				QueueCommand(function() DisplayDialog { "dev/dev_quests.lua", x = initial_x, y = initial_y } end)
			end 
		},
		
		Window { x = 0, y = h + padding, w = total_width, h = info_area_height, Group(items) },
		Group(footer_items)
	},
}