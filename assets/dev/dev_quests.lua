--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Quests (REFINED v11 - UI POLISH)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Configuration & State
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 115 
local y_start = 2 * h -- Adjusted for new filter bar
local y_max = 570

gDevQuestFilter = gDevQuestFilter or "Active & Eligible" -- New default filter
local questList = {}

local activeFilterFont = { devMenuStyle.font[1], devMenuStyle.font[2], Color(32, 160, 32, 255) } -- Green
local nonRealQuestFont = { devMenuStyle.font[1], devMenuStyle.font[2], Color(98, 98, 98, 255) } -- Gray for tease/hint quests
local headerFont = { devMenuStyle.font[1], devMenuStyle.font[2], Color(0, 0, 0, 255) }

-------------------------------------------------------------------------------
-- Core Logic Functions
-------------------------------------------------------------------------------

local function RefreshPanel()
    CloseWindow()
    QueueCommand(function() DisplayDialog { "dev/dev_quests.lua", x=gDialogTable.x, y=gDialogTable.y } end)
end

local function ApplyFilter()
    questList = {}
    
    if gDevQuestFilter == "Active & Eligible" then
        -- Add Active quests first
        local activeQuests = {}
        for name, _ in pairs(Player.questsActive) do
            if _AllQuests[name] then table.insert(activeQuests, _AllQuests[name]) end
        end
        table.sort(activeQuests, function(a,b) return a.name < b.name end)
        if table.getn(activeQuests) > 0 then
            table.insert(questList, {isHeader = true, name = "<b>ACTIVE QUESTS</b>"})
            for _, q in ipairs(activeQuests) do table.insert(questList, q) end
        end

        -- Add Eligible quests second
        local eligibleQuests = {}
        for name, quest in pairs(_AllQuests) do
            if quest:IsEligible() then table.insert(eligibleQuests, quest) end
        end
        -- Sort eligible quests by priority, then by name
        table.sort(eligibleQuests, function(a,b) 
            if a.priority ~= b.priority then return a.priority < b.priority
            else return a.name < b.name end
        end)
        if table.getn(eligibleQuests) > 0 then
            table.insert(questList, {isHeader = true, name = "<b>ELIGIBLE QUESTS</b>"})
            for _, q in ipairs(eligibleQuests) do table.insert(questList, q) end
        end

    elseif gDevQuestFilter == "Other" then
        for name, quest in pairs(_AllQuests) do
            if not quest:IsActive() and not quest:IsEligible() and not quest:IsComplete() then
                table.insert(questList, quest)
            end
        end
        table.sort(questList, function(a,b) return a.name < b.name end)
    elseif gDevQuestFilter == "Completed" then
        for name, _ in pairs(Player.questsComplete) do
            if _AllQuests[name] then table.insert(questList, _AllQuests[name]) end
        end
        table.sort(questList, function(a,b) return a.name < b.name end)
    elseif gDevQuestFilter == "Order Management" then
        -- This logic remains the same
        local pendingHeaderDone = false
        local activeHeaderDone = false
        local tempOrderList = {}
        for _, orderData in ipairs(Player.pendingSpecialOrders) do
            orderData.isPending = true
            table.insert(tempOrderList, orderData)
        end
        for name, _ in pairs(Player.questsActive) do
            local quest = _AllQuests[name]
            if quest and quest.delivery then
                quest.isPending = false
                table.insert(tempOrderList, quest)
            end
        end
        table.sort(tempOrderList, function(a, b)
            if a.isPending and not b.isPending then return true
            elseif not a.isPending and b.isPending then return false
            else return a.name < b.name end
        end)
        questList = tempOrderList
    end
end

local function SetFilter(filterName)
    gDevQuestFilter = filterName
    RefreshPanel()
end

local function InspectItem(item)
    CloseWindow()
    if item.isPending then
        QueueCommand(function() DisplayDialog { "dev/dev_order_detail.lua", x=gDialogTable.x, y=gDialogTable.y, orderData=item } end)
    else
        QueueCommand(function() DisplayDialog { "dev/dev_quest_detail.lua", x=gDialogTable.x, y=gDialogTable.y, quest=item } end)
    end
end

-- (All other functions like AddRandomOrder, CreateManualOrder, etc. remain unchanged)
local function AddRandomOrder()
    DebugOut("DEV", "Attempting to generate a random special order...")
    local orderQuest = RandomDeliveryQuest()
    if orderQuest then
        local questData = orderQuest:GetSaveTable()
        questData.earlyOfferCutoff = Player.time + 6
        table.insert(Player.pendingSpecialOrders, questData)
        DebugOut("DEV", "Successfully generated and queued new order: " .. questData.name)
    else
        DebugOut("DEV", "Failed to generate random order. (Not enough data?)")
    end
    RefreshPanel()
end
local function CreateManualOrder()
    DebugOut("DEV", "Creating a new manual order template...")
    local template = {
        product = "b01", count = 10, price = 1000,
        startbuilding = "zur_shop", starter = "zur_shopkeep",
        ender = "zur_stationkeep", endbuilding = "zur_station",
        expires = 20, earlyOfferCutoff = Player.time + 6,
        isResident = true, sourcePool = "N/A",
        name = "manual_order_"..tostring(Player.time)
    }
    table.insert(Player.pendingSpecialOrders, template)
    RefreshPanel()
end
local function DeleteAllPending()
    DebugOut("DEV", "Deleting all pending special orders.")
    for _, order in ipairs(Player.pendingSpecialOrders) do
        if not order.isResident then
            MoveNonResident(order.ender, order.endbuilding, order.sourcePool)
        end
    end
    Player.pendingSpecialOrders = {}
    RefreshPanel()
end
local function ExpireAllOffers()
    DebugOut("DEV", "Expiring all early offer windows.")
    for _, order in ipairs(Player.pendingSpecialOrders) do
        order.earlyOfferCutoff = Player.time - 1
    end
    RefreshPanel()
end
local function ResetNonResidents()
    DebugOut("DEV", "Resetting all non-resident characters to their home pools.")
    Player.buildingCharacters = {}
	Player.buildingCharacters._travelers = {}
	for _,name in ipairs(_TravelCharacters) do Player.buildingCharacters._travelers[name] = true end
	Player.buildingCharacters._empty = {}
	for _,name in ipairs(_EmptyCharacters) do Player.buildingCharacters._empty[name] = true end
    RefreshPanel()
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local items = {}
local x = 0
local y = y_start

ApplyFilter()

-- This single loop now handles all filter types
for _, item in ipairs(questList) do
    if y > y_max then x = x + w; y = y_start; end

    if item.isHeader then
        if y > y_start then y = y + (h/2) end
        if y > y_max then x = x + w; y = y_start; end
        table.insert(items, Text { x=x, y=y, w=w, h=h, label="#<b>"..item.name.."</b>", font=headerFont })
        y = y + h
    else
        local label = "#" .. item.name
        local font = devMenuStyle.font
        if item.priority == 1 then label = "#*" .. item.name end
        if not item.isPending and not item:IsReal() then font = nonRealQuestFont end
        local tempItem = item
        table.insert(items, Button { x=x, y=y, w=w, h=h, name = "dev_quest_" .. tempItem.name, label = label, font = font, command = function() InspectItem(tempItem) end })
        y = y + h
    end
end

local filterButtons = {}
local filters = {"Active & Eligible", "Other", "Completed", "Order Management"}
for i, filterName in ipairs(filters) do
    local tempFilter = filterName
    local font = devMenuStyle.font
    if gDevQuestFilter == tempFilter then font = activeFilterFont end
    table.insert(filterButtons, Button { 
        x = w * (i-1) + 75, y = 0, w = w, h = h,
        label = "#<b>" .. tempFilter .. "</b>", 
        font = font,
        command = function() SetFilter(tempFilter) end 
    })
end

local managementToolbar = {}
if gDevQuestFilter == "Order Management" then
    local toolbar_y = h + 5 
    table.insert(managementToolbar, Button { x=0, y=toolbar_y, w=120, h=h, label="#Add Random", command=AddRandomOrder })
    table.insert(managementToolbar, Button { x=125, y=toolbar_y, w=120, h=h, label="#Create New...", command=CreateManualOrder })
    table.insert(managementToolbar, Button { x=250, y=toolbar_y, w=120, h=h, label="#Delete All Pending", command=DeleteAllPending })
    table.insert(managementToolbar, Button { x=375, y=toolbar_y, w=120, h=h, label="#Expire All Offers", command=ExpireAllOffers })
    table.insert(managementToolbar, Button { x=500, y=toolbar_y, w=150, h=h, label="#Reset Non-Residents", command=ResetNonResidents })
end

MakeDialog
{
	name="dev_quests",
	BSGWindow { x=gDialogTable.x, y=gDialogTable.y, w=w*5, h=600, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		
        Button { x=0, y=0, w=60, h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
        Group(filterButtons),
        Group(managementToolbar),

		Group(items),
	},
}