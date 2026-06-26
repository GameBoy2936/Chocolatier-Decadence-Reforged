--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Dev Quests Content List)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local y_max = 530 -- Bottom margin constraint

-- Font Definitions
local nonRealQuestFont = { devMenuStyle.font[1], devMenuStyle.font[2], Color(98, 98, 98, 255) }
local headerFont = { devMenuStyle.font[1], devMenuStyle.font[2], Color(0, 0, 0, 255) }

-------------------------------------------------------------------------------
-- Search Logic
-------------------------------------------------------------------------------

-- Evaluates if a given quest/order object contains the string typed in the search bar.
-- It recursively checks the ID, product name, destination, and NPC recipient.
local function MatchesSearch(item)
	if type(gDevQuestSearchTerm) ~= "string" or gDevQuestSearchTerm == "" then return true end
	local term = string.lower(gDevQuestSearchTerm)
	
	-- 1. Match Internal Key Name
	if item.name and string.find(string.lower(tostring(item.name)), term) then return true end
	
	-- 2. Match Target Product Name
	if item.product then
		local prod = _AllProducts[item.product]
		if prod then
			local prodName = prod:GetName()
			if type(prodName) == "string" and string.find(string.lower(prodName), term) then return true end
		end
	end
	
	-- 3. Match Destination Building or Character
	if item.endbuilding and string.find(string.lower(tostring(item.endbuilding)), term) then return true end
	if item.ender and string.find(string.lower(tostring(item.ender)), term) then return true end
	
	return false
end

-------------------------------------------------------------------------------
-- Administrator Action Hooks
-------------------------------------------------------------------------------

local function Refresh() DevQuestRefreshList() end

local function AddRandomOrder()
	DebugOut("DEV", "Admin Action: Generated and injected random delivery quest into pending orders.")
	local orderQuest = RandomDeliveryQuest()
	if orderQuest then
		local questData = orderQuest:GetSaveTable()
		questData.earlyOfferCutoff = Player.time + 6
		table.insert(Player.pendingSpecialOrders, questData)
	end
	Refresh()
end

local function CreateManualOrder()
	local template = {
		product = "b01", count = 10, price = 1000,
		startbuilding = "zur_shop", starter = "zur_shopkeep",
		ender = "zur_stationkeep", endbuilding = "zur_station",
		expires = 20, earlyOfferCutoff = Player.time + 6,
		isResident = true, sourcePool = "N/A",
		name = "manual_order_" .. tostring(Player.time)
	}
	DebugOut("DEV", string.format("Admin Action: Created manual debug order schema: %s", template.name))
	table.insert(Player.pendingSpecialOrders, template)
	Refresh()
end

local function DeleteAllPending()
	DebugOut("DEV", "Admin Action: Purged all pending special orders from queue.")
	Player.pendingSpecialOrders = {}
	Refresh()
end

local function ExpireAllOffers()
	DebugOut("DEV", "Admin Action: Forced expiration of all early-offer windows for pending orders.")
	for _, order in ipairs(Player.pendingSpecialOrders) do 
		order.earlyOfferCutoff = Player.time - 1 
	end
	Refresh()
end

local function ResetNonResidents()
	DebugOut("DEV", "Admin Action: Reset non-resident wanderer pools.")
	Player.buildingCharacters = {}
	Player.buildingCharacters._travelers = {}
	for _, name in ipairs(_TravelCharacters) do Player.buildingCharacters._travelers[name] = true end
	
	Player.buildingCharacters._empty = {}
	for _, name in ipairs(_EmptyCharacters) do Player.buildingCharacters._empty[name] = true end
	Refresh()
end

-------------------------------------------------------------------------------
-- Data Collation & Filter Routing
-------------------------------------------------------------------------------

local questList = {}

-- FILTER 1: ACTIVE & ELIGIBLE (The primary gameplay view)
if gDevQuestFilter == "Active & Eligible" then
	
	local activeQuests = {}
	for name, _ in pairs(Player.questsActive) do
		if _AllQuests[name] and MatchesSearch(_AllQuests[name]) then table.insert(activeQuests, _AllQuests[name]) end
	end
	table.sort(activeQuests, function(a, b) return a.name < b.name end)
	
	if table.getn(activeQuests) > 0 then
		table.insert(questList, { isHeader = true, name = "ACTIVE QUESTS" })
		for _, q in ipairs(activeQuests) do table.insert(questList, q) end
	end

	local eligibleQuests = {}
	for name, quest in pairs(_AllQuests) do
		if quest:IsEligible() and MatchesSearch(quest) then table.insert(eligibleQuests, quest) end
	end
	table.sort(eligibleQuests, function(a, b) 
		if a.priority ~= b.priority then return a.priority < b.priority
		else return a.name < b.name end
	end)
	
	if table.getn(eligibleQuests) > 0 then
		table.insert(questList, { isHeader = true, name = "ELIGIBLE QUESTS" })
		for _, q in ipairs(eligibleQuests) do table.insert(questList, q) end
	end

-- FILTER 2: OTHER (Waiting, Blocked, Broken)
elseif gDevQuestFilter == "Other" then
	for name, quest in pairs(_AllQuests) do
		if not quest:IsActive() and not quest:IsEligible() and not quest:IsComplete() and MatchesSearch(quest) then
			table.insert(questList, quest)
		end
	end
	table.sort(questList, function(a, b) return a.name < b.name end)

-- FILTER 3: COMPLETED
elseif gDevQuestFilter == "Completed" then
	for name, _ in pairs(Player.questsComplete) do
		if _AllQuests[name] and MatchesSearch(_AllQuests[name]) then table.insert(questList, _AllQuests[name]) end
	end
	table.sort(questList, function(a, b) return a.name < b.name end)

-- FILTER 4: ORDER MANAGEMENT
elseif gDevQuestFilter == "Order Management" then
	local tempOrderList = {}
	
	-- Extract pending/invisible background orders
	for _, orderData in ipairs(Player.pendingSpecialOrders) do
		orderData.isPending = true
		if MatchesSearch(orderData) then table.insert(tempOrderList, orderData) end
	end
	
	-- Extract officially active delivery quests
	for name, _ in pairs(Player.questsActive) do
		local quest = _AllQuests[name]
		if quest and quest.delivery and MatchesSearch(quest) then
			quest.isPending = false
			table.insert(tempOrderList, quest)
		end
	end
	
	-- Sort pending at the top, active below
	table.sort(tempOrderList, function(a, b)
		if a.isPending and not b.isPending then return true
		elseif not a.isPending and b.isPending then return false
		else return a.name < b.name end
	end)
	
	questList = tempOrderList
end

-------------------------------------------------------------------------------
-- UI Construction & Column-Major Layout Engine
-------------------------------------------------------------------------------
-- We iterate the final array and render it in a top-to-bottom, left-to-right 
-- snake pattern, so the UI is visually dense without needing scroll bars.

local items = {}
table.insert(items, SetStyle(devMenuStyle))

local x = 0
local y = 0

-- Contextual View Layout Variables
local col_width = 115 
local item_height = h

-- The Order Management view is much more robust, rendering multi-line data
if gDevQuestFilter == "Order Management" then
	col_width = 250 
	item_height = h * 2.5 
	
	-- Inject the specific administrative toolbar 
	table.insert(items, Button { x = 0, y = y, w = 120, h = h, label = "#Add Random Order", command = AddRandomOrder })
	table.insert(items, Button { x = 125, y = y, w = 120, h = h, label = "#Create New Order...", command = CreateManualOrder })
	table.insert(items, Button { x = 250, y = y, w = 120, h = h, label = "#Delete All Order", command = DeleteAllPending })
	table.insert(items, Button { x = 375, y = y, w = 120, h = h, label = "#Expire All Offers", command = ExpireAllOffers })
	table.insert(items, Button { x = 500, y = y, w = 150, h = h, label = "#Reset Non-Residents", command = ResetNonResidents })
	
	y = y + h + 10
end

local y_reset = y -- Mark the top bounds of the rendering block

for _, item in ipairs(questList) do
	
	-- Column-Major Grid Wrap logic
	if y > y_max then 
		x = x + col_width
		y = y_reset 
	end

	if item.isHeader then
		-- Render category headers
		if y > y_reset then y = y + (h / 2) end
		table.insert(items, Text { x = x, y = y, w = col_width, h = h, label = "#<b>" .. item.name .. "</b>", font = headerFont, flags = kVAlignCenter + kHAlignLeft })
		y = y + h
	else
		-- Render interactive data nodes
		local label = "#" .. item.name
		local font = devMenuStyle.font
		
		if gDevQuestFilter == "Order Management" then
			-- Format: [STATUS] 20x Product -> Dest ($Price)
			local prod = _AllProducts[item.product]
			local prodName = prod and prod:GetName() or item.product
			if string.len(prodName) > 30 then prodName = string.sub(prodName, 1, 23) .. "..." end
			
			local status = item.isPending and "<font color='AAAAAA'>[PEND]</font>" or "<font color='20A020'>[ACTV]</font>"
			local dest = GetString(item.endbuilding)
			
			label = string.format("#%s <b>%dx %s</b><br><font size='11'>-> %s (%s)</font>", status, item.count, prodName, dest, Dollars(item.price))
		else
			-- Format standard Story Quests
			if item.priority == 1 then label = "#*" .. item.name end
			if not item.isPending and not item:IsReal() then font = nonRealQuestFont end
		end

		local tempName = item.name
		local tempPending = item.isPending
		
		table.insert(items, Button { 
			x = x, y = y, w = col_width - 2, h = item_height, 
			name = "dev_quest_" .. tempName, 
			label = label, font = font, 
			flags = kHAlignLeft + kHAlignLeft,
			command = function() DevQuestInspectItem(tempName, tempPending) end 
		})
		
		y = y + item_height
	end
end

MakeDialog(items)