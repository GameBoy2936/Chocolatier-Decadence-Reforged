--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Tip Manager & Creator)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Global draft object to persist UI state across sub-window navigations
gDevTipDraft = gDevTipDraft or {
	type = "ingredient", 	-- Target Classification: ingredient, product, category, port, seasonal
	target = "sugar",    	-- Target Identifier: code/name of item/category
	port = "zurich",	 	-- Target Geography
	effect = "down",     	-- Economic Shift: up, down
	duration = 8		 	-- Total Time (Weeks)
}

-- ----------------------------------------------------------------------------
-- Layout Geometry
-- ----------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 780 
local col_left_w = 400
local col_right_w = 350
local col_right_x = col_left_w + 20
local y_start = 2 * h
local y_max = 550

-- Inherit layout coordinates from the parent developer overlay
local xDialog = gDialogTable.x or 0
local yDialog = gDialogTable.y or h

-------------------------------------------------------------------------------
-- Helper Logic & Generic Selection Wrappers
-------------------------------------------------------------------------------

local function RefreshPanel()
	CloseWindow()
	QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end)
end

-- Generic Grid Selector (Primarily used for string-only arrays like Categories and Seasons)
local function OpenGridSelector(title, dataList, onSelect, labelFunc)
	local items = {}
	local ly = h
	local lx = 0
	local selector_col_w = 150
	local max_y = 550
	
	-- Sort alphabetically based on the resolved localized label
	table.sort(dataList, function(a, b) 
		local sa = labelFunc and labelFunc(a) or tostring(a)
		local sb = labelFunc and labelFunc(b) or tostring(b)
		return sa < sb 
	end)

	for _, item in ipairs(dataList) do
		-- Column-major snake layout handling
		if ly > max_y then ly = h; lx = lx + selector_col_w end
		
		local label = labelFunc and labelFunc(item) or tostring(item)
		local tempItem = item
		
		table.insert(items, Button {
			x = lx, y = ly, w = selector_col_w, h = h,
			label = "#" .. label,
			command = function() 
				DebugOut("DEV", string.format("Admin UI: Draft target updated to '%s'.", label))
				onSelect(tempItem)
				CloseWindow()
				
				-- Return focus to the master Tip Manager overlay
				QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end) 
			end
		})
		ly = ly + h
	end

	MakeDialog {
		name = "dev_grid_selector",
		BSGWindow { 
			x = xDialog, y = yDialog, w = 800, h = 600, fit = true, color = { 1, 1, 1, 0.9 }, SetStyle(devMenuStyle),
			
			Button { 
				x = 0, y = 0, w = selector_col_w, h = h, label = "#<b>CANCEL</b>", default = true, cancel = true, 
				command = function() 
					CloseWindow()
					QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end) 
				end 
			},
			Text { x = selector_col_w + 10, y = 0, w = 400, h = h, label = "#<b>SELECT: " .. title .. "</b>", flags = kVAlignCenter + kHAlignLeft },
			Group(items)
		}
	}
	
	CloseWindow()
	QueueCommand(function() CenterFadeIn("dev_grid_selector") end)
end

-------------------------------------------------------------------------------
-- Active Manager Controls
-------------------------------------------------------------------------------

local function DeleteTip(index)
	local tip = Player.activeTips[index]
	if tip then
		DebugOut("DEV", string.format("Admin Action: Force-deleted active event hook: %s", (tip.key or tip.seasonal_key)))
		
		-- Purge from active evaluation pool
		table.remove(Player.activeTips, index)
		
		-- Purge from the dynamic dialogue pipeline
		for i, p_tip in ipairs(Player.pendingAnnouncements) do
			if p_tip == tip then
				table.remove(Player.pendingAnnouncements, i)
				break
			end
		end
		
		-- Force a global UI economy recalculation to scrub the price modifier instantly
		Player:RecalculatePricesForCurrentPort()
		RefreshPanel()
	end
end

local function ForceAnnounce(index)
	local tip = Player.activeTips[index]
	if tip then
		CloseWindow()
		QueueCommand(function()
			DisplayDialog {
				"dev/dev_select_character.lua",
				prompt = "Select Announcer:",
				onOk = function(char)
					DebugOut("DEV", string.format("Admin Action: Forcing announcement for tip '%s' via NPC: %s", (tip.key or tip.seasonal_key), char.name))
					
					-- Translate the tip into localized dialogue context specific to this NPC (Evaluates "Evil" deception logic)
					local text = Tips.GetDynamicTipString(tip, char)
					
					-- Launch the modal UI overlay
					DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. text }
					
					-- Return to the Tip Manager automatically once the dialogue box is dismissed
					QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end)
				end
			}
		end)
	end
end

-------------------------------------------------------------------------------
-- Creator Controls & Draft Configuration
-------------------------------------------------------------------------------

local function SetType(newType)
	gDevTipDraft.type = newType
	
	-- Inject sensible fallback defaults to prevent logic crashes if a dev fires the 
	-- event immediately after switching the classification type.
	if newType == "ingredient" then gDevTipDraft.target = "sugar"
	elseif newType == "product" then gDevTipDraft.target = "b01"
	elseif newType == "category" then gDevTipDraft.target = "bar"
	elseif newType == "seasonal" then gDevTipDraft.target = "ev_season_christmas"
	end
	
	RefreshPanel()
end

local function PickPort()
	CloseWindow()
	QueueCommand(function()
		DisplayDialog {
			"dev/dev_select_port.lua",
			prompt = "Select Target Geography:",
			onOk = function(val) 
				gDevTipDraft.port = val.name
				QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end)
			end
		}
	end)
end

local function PickTarget()
	if gDevTipDraft.type == "ingredient" then
		CloseWindow()
		QueueCommand(function()
			DisplayDialog {
				"dev/dev_select_ingredient.lua",
				prompt = "Select Target Ingredient:",
				onOk = function(val) 
					gDevTipDraft.target = val.name
					QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end)
				end
			}
		end)

	elseif gDevTipDraft.type == "product" then
		-- Hijack the core game Recipe Book UI to select a product
		CloseWindow()
		QueueCommand(function()
			local currentProd = _AllProducts[gDevTipDraft.target]
			if currentProd then 
				gRecipeSelection = currentProd 
				gCategorySelection = currentProd.category
			end
			
			local ok = DisplayDialog { "ui/ui_recipes.lua" }
			
			if ok and gRecipeSelection then
				gDevTipDraft.target = gRecipeSelection.code
			end
			
			QueueCommand(function() DisplayDialog{"dev/dev_tips.lua", x = xDialog, y = yDialog} end)
		end)

	elseif gDevTipDraft.type == "category" then
		OpenGridSelector("Category", _CategoryOrder, 
			function(val) gDevTipDraft.target = val.name end,
			function(val) return GetString(val.name) end
		)

	elseif gDevTipDraft.type == "seasonal" then
		local seasons = { "ev_season_valentine", "ev_season_easter", "ev_season_halloween", "ev_season_christmas" }
		OpenGridSelector("Season", seasons, function(val) gDevTipDraft.target = val end)
	end
end

local function ToggleEffect()
	if gDevTipDraft.effect == "up" then 
		gDevTipDraft.effect = "down"
	else 
		gDevTipDraft.effect = "up" 
	end
	RefreshPanel()
end

local function EditDuration()
	DisplayDialog {
		"dev/dev_enter_amount.lua",
		prompt = "Set Global Duration (Weeks):",
		initialValue = tostring(gDevTipDraft.duration),
		onOk = function(val) 
			gDevTipDraft.duration = tonumber(val)
			RefreshPanel()
		end
	}
end

local function CreateTip()
	local draft = gDevTipDraft
	local tip = {
		type = draft.effect,
		endTime = Player.time + draft.duration,
		port = draft.port
	}
	
	-- Configure the event type bindings and base localization strings
	if draft.type == "ingredient" then
		tip.item = draft.target
		if draft.effect == "up" then tip.key = "ev_ing_priceup" else tip.key = "ev_ing_pricedown" end
	
	elseif draft.type == "product" then
		tip.item = draft.target
		if draft.effect == "up" then tip.key = "ev_prod_priceup" else tip.key = "ev_prod_pricedown" end
	
	elseif draft.type == "category" then
		tip.category = draft.target
		if draft.effect == "up" then tip.key = "ev_prod_priceup" else tip.key = "ev_prod_pricedown" end
	
	elseif draft.type == "port" then
		tip.port_wide = true
		if draft.effect == "up" then tip.key = "ev_ing_all_priceup" else tip.key = "ev_ing_all_pricedown" end
	
	elseif draft.type == "seasonal" then
		tip.seasonal_key = draft.target
		tip.key = draft.target
		tip.port = nil -- Seasonal overrides ignore specific geography
	end
	
	-- Synthesize the randomized suffix logic to pick a valid variation of the text
	if not tip.seasonal_key then
		local count = 1
		while GetString(tip.key .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
		local randomIndex = RandRange(1, count)
		tip.key = tip.key .. "_" .. randomIndex
	else
		local base = tip.key
		local count = 1
		while GetString(base .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
		tip.key = base .. "_" .. RandRange(1, count)
	end
	
	-- Publish the newly synthesized tip to the global simulation arrays
	table.insert(Player.activeTips, tip)
	
	if not tip.seasonal_key then
		table.insert(Player.pendingAnnouncements, tip)
	end
	
	-- Recalculate global prices instantly to reflect the administrative injection
	Player:RecalculatePricesForCurrentPort()
	
	DebugOut("DEV", string.format("Admin Action: Successfully constructed and deployed custom tip: %s", tip.key))
	RefreshPanel()
end

-------------------------------------------------------------------------------
-- UI CONSTRUCTION & RENDER MAP
-------------------------------------------------------------------------------

local items = {}

-- ============================================================================
-- LEFT COLUMN: ACTIVE TIPS LIST MANAGER
-- ============================================================================
local y_list = y_start

if Player.activeTips and table.getn(Player.activeTips) > 0 then
	for i, tip in ipairs(Player.activeTips) do
		local desc = ""
		
		if tip.seasonal_key then
			desc = "SEASONAL: " .. tip.seasonal_key
		else
			local portName = GetString(tip.port)
			local typeStr = (tip.type == "up") and "UP" or "DOWN"
			local colorHex = (tip.type == "up") and "D82C2C" or "3A8E1D"
			
			local targetName = "ALL"
			if tip.item then 
				local obj = _AllIngredients[tip.item] or _AllProducts[tip.item]
				targetName = obj and obj:GetName() or tip.item
			elseif tip.category then
				targetName = GetString(tip.category)
			end
			
			desc = string.format("<font color='%s'><b>%s</b></font> %s in %s", colorHex, typeStr, targetName, portName)
		end
		
		local weeksLeft = tip.endTime - Player.time
		desc = desc .. " (" .. weeksLeft .. " wks)"
		
		table.insert(items, Text { x = 10, y = y_list, w = col_left_w - 140, h = h, label = "#" .. desc, flags = kHAlignLeft + kHAlignLeft })
		
		-- Append Action Sub-Controls
		local tempIndex = i 
		table.insert(items, Button { x = col_left_w - 140, y = y_list, w = 80, h = h, label = "#[ANNOUNCE]", command = function() ForceAnnounce(tempIndex) end })
		table.insert(items, Button { x = col_left_w - 60, y = y_list, w = 60, h = h, label = "#[DELETE]", command = function() DeleteTip(tempIndex) end })
		
		y_list = y_list + h + 5
	end
else
	table.insert(items, Text { x = 10, y = y_list, w = col_left_w, h = h, label = "#No active economic events.", flags = kVAlignCenter + kHAlignLeft })
end

-- ============================================================================
-- RIGHT COLUMN: DRAFT CREATOR FORM
-- ============================================================================

-- Row 1: Type Selectors
local types = { "ingredient", "product", "category", "port" }
local typeX = col_right_x
local typeY = y_start
local typeW = 100 

table.insert(items, Text { x = typeX, y = typeY - h - 5, w = col_right_w, h = h, label = "#<b>CREATE NEW EVENT</b>", flags = kVAlignCenter + kHAlignCenter, font = { devMenuStyle.font[1], 18, BlackColor } })

for _, t in ipairs(types) do
	local label = string.upper(t)
	if gDevTipDraft.type == t then
		label = "<font color='20A020'><b>" .. label .. "</b></font>"
	else
		label = "<font color='999999'>" .. label .. "</font>"
	end
	
	local tempType = t
	table.insert(items, Button { x = typeX, y = typeY, w = typeW, h = h, label = "#" .. label, command = function() SetType(tempType) end })
	typeX = typeX + typeW - 5 
end

-- String formatting fallbacks for UI readouts
local targetLabel = "N/A"
local portLabel = GetString(gDevTipDraft.port)

if gDevTipDraft.type == "ingredient" then 
	targetLabel = GetString(gDevTipDraft.target)
elseif gDevTipDraft.type == "product" then 
	local p = _AllProducts[gDevTipDraft.target]
	targetLabel = p and p:GetName() or gDevTipDraft.target
elseif gDevTipDraft.type == "category" then 
	targetLabel = GetString(gDevTipDraft.target)
elseif gDevTipDraft.type == "port" then 
	targetLabel = "ALL INGREDIENTS"
elseif gDevTipDraft.type == "seasonal" then 
	targetLabel = gDevTipDraft.target
end

local effectColor = (gDevTipDraft.effect == "up") and "D82C2C" or "3A8E1D"
local effectLabel = (gDevTipDraft.effect == "up") and "PRICE UP" or "PRICE DOWN"
if gDevTipDraft.type == "seasonal" then effectLabel = "SEASONAL BOOST" end

local y_form = y_start + h + 10
local label_w = 80
local val_w = 250
local val_x = col_right_x + label_w + 10

-- Row 2: Target Binding (Hidden if Port-wide)
if gDevTipDraft.type ~= "port" then
	table.insert(items, Text { x = col_right_x, y = y_form, w = label_w, h = h, label = "#<b>Target:</b>", flags = kVAlignCenter + kHAlignRight })
	table.insert(items, Button { x = val_x, y = y_form, w = val_w, h = h, label = "#[ " .. targetLabel .. " ]", command = PickTarget })
	y_form = y_form + h + 5
end

-- Row 3: Geography Binding (Hidden if Seasonal Event)
if gDevTipDraft.type ~= "seasonal" then
	table.insert(items, Text { x = col_right_x, y = y_form, w = label_w, h = h, label = "#<b>Port:</b>", flags = kVAlignCenter + kHAlignRight })
	table.insert(items, Button { x = val_x, y = y_form, w = val_w, h = h, label = "#[ " .. portLabel .. " ]", command = PickPort })
	y_form = y_form + h + 5
end

-- Row 4: Effect Binding
if gDevTipDraft.type ~= "seasonal" then
	table.insert(items, Text { x = col_right_x, y = y_form, w = label_w, h = h, label = "#<b>Effect:</b>", flags = kVAlignCenter + kHAlignRight })
	table.insert(items, Button { x = val_x, y = y_form, w = val_w, h = h, label = "#<font color='" .. effectColor .. "'><b>[ " .. effectLabel .. " ]</b></font>", command = ToggleEffect })
	y_form = y_form + h + 5
end

-- Row 5: Duration Binding
table.insert(items, Text { x = col_right_x, y = y_form, w = label_w, h = h, label = "#<b>Duration:</b>", flags = kVAlignCenter + kHAlignRight })
table.insert(items, Button { x = val_x, y = y_form, w = val_w, h = h, label = "#[ " .. gDevTipDraft.duration .. " Weeks ]", command = EditDuration })
y_form = y_form + h + 20

-- Footer: Creation Dispatcher
table.insert(items, Button { x = col_right_x + 50, y = y_form, w = col_right_w - 100, h = h * 1.5, label = "#<b>+ CREATE</b>", command = CreateTip })

-------------------------------------------------------------------------------
-- Dynamic Window Height Resolution
-------------------------------------------------------------------------------
-- Determine which column (List or Form) is currently taller and bind window height to it.
local final_y = y_list
if y_form > final_y then final_y = y_form end

MakeDialog
{
	name = "dev_tips",
	BSGWindow { 
		x = xDialog, y = yDialog, w = w, h = final_y + 50, fit = false, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		-- Master Header
		Button { x = 0, y = 0, w = 100, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Text { x = 110, y = 0, w = 300, h = h, label = "#<b>ACTIVE TIPS</b>", flags = kHAlignLeft + kHAlignLeft, font = { devMenuStyle.font[1], 20, BlackColor } },
		
		-- Mid-Screen Splitter Mask Line
		Rectangle { x = col_left_w + 5, y = y_start, w = 2, h = 400, color = { 0, 0, 0, 0.2 } },

		Group(items),
	},
}