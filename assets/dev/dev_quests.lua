--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Dev Quests Container)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script renders the parent shell for the Developer Quest Manager. 
-- It houses the search bar and filter tabs, and uses a sub-window to render 
-- the actual scrolling list of quests dynamically without losing search focus.

-------------------------------------------------------------------------------
-- Configuration & State
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]

-- Layout constraints
local w = 112 
local y_content_start = 45

-- Persist search state across UI reloads
gDevQuestFilter = gDevQuestFilter or "Active & Eligible"
gDevQuestSearchTerm = gDevQuestSearchTerm or ""

local activeFilterFont = { devMenuStyle.font[1], devMenuStyle.font[2], Color(32, 160, 32, 255) }
local searchBoxFont = { devMenuStyle.font[1], devMenuStyle.font[2], BlackColor }

-------------------------------------------------------------------------------
-- Global Actions (Callable from the content sub-script)
-------------------------------------------------------------------------------

-- Reloads ONLY the content panel, keeping the main window (and cursor focus) alive.
function DevQuestRefreshList()
	FillWindow("quest_content_panel", "dev/dev_quests_content.lua")
end

-- Switches the active tab and triggers a content reload
function DevQuestSetFilter(filterName)
	DebugOut("DEV", string.format("Quest Manager filter changed to: %s", filterName))
	gDevQuestFilter = filterName
	DevQuestRefreshList()
end

-- Interrogates the clicked item to determine if it's a standard Quest or a 
-- Special Order, and routes to the correct detail inspector UI.
function DevQuestInspectItem(itemName, isPending)
	local item = nil
	
	if isPending then
		-- Target is a queued special order
		for _, order in ipairs(Player.pendingSpecialOrders) do
			if order.name == itemName then item = order; break end
		end
		
		if item then
			DebugOut("DEV", string.format("Opening Order Inspector for: %s", itemName))
			CloseWindow() 
			QueueCommand(function() DisplayDialog { "dev/dev_order_detail.lua", x = gDialogTable.x, y = gDialogTable.y, orderData = item } end)
		end
	else
		-- Target is a standard quest
		item = _AllQuests[itemName]
		if item then
			DebugOut("DEV", string.format("Opening Quest Inspector for: %s", itemName))
			CloseWindow() 
			QueueCommand(function() DisplayDialog { "dev/dev_quest_detail.lua", x = gDialogTable.x, y = gDialogTable.y, quest = item } end)
		end
	end
end

-------------------------------------------------------------------------------
-- Local UI Logic
-------------------------------------------------------------------------------

local function UpdateSearch()
	gDevQuestSearchTerm = tostring(GetLabel("quest_search_box") or "")
	DevQuestRefreshList()
end

local function ClearSearch()
	gDevQuestSearchTerm = ""
	SetLabel("quest_search_box", "")
	DevQuestRefreshList()
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local filterButtons = {}
local filters = { "Active & Eligible", "Other", "Completed", "Order Management" }
local filter_w = 135 

for i, filterName in ipairs(filters) do
	local tempFilter = filterName
	table.insert(filterButtons, Button { 
		x = filter_w * (i - 1) + 75, y = 0, w = filter_w, h = h,
		label = "#<b>" .. tempFilter .. "</b>", 
		command = function() DevQuestSetFilter(tempFilter) end 
	})
end

MakeDialog
{
	name = "dev_quests",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = 800, h = 600, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		-- Header & Tabs
		Button { x = 0, y = 0, w = 60, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Group(filterButtons),
		
		-- Search Bar (Persistent)
		Window { 
			x = 0, y = h + 5, w = 400, h = h,
			Bitmap { 
				x = 0, y = 0, w = 200, h = h, image = "image/textfield",
				TextEdit { 
					x = 5, y = 0, w = 190, h = h, 
					name = "quest_search_box", 
					label = gDevQuestSearchTerm, 
					length = 30, 
					onkey = UpdateSearch, 
					font = searchBoxFont,
				},
			},
			Button { x = 205, y = 0, w = 20, h = h, label = "#X", command = ClearSearch },
			Text { x = 230, y = 0, w = 150, h = h, label = "#<font color='555555'>Search Names/Details</font>", flags = kVAlignCenter + kHAlignLeft, font = { devMenuStyle.font[1], 12, BlackColor } }
		},

		-- The Dynamic Content Sub-Panel Hook
		Window { name = "quest_content_panel", x = 0, y = y_content_start, w = 800, h = 600 },
	},
}

-- Initial Population
DevQuestRefreshList()