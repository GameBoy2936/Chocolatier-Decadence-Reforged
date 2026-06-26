--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Ingredient Selector)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local onOkCallback = gDialogTable.onOk
local promptText = gDialogTable.prompt or "Select an Ingredient:"

-- Grid Layout Config
local h = devMenuStyle.font[2]
local col_w = 162 
local num_cols = 5 
local row_h = 30   
local y_start = 1.4 * h
local y_max = 580

-- Standardized Hex mapping to color-code ingredients by their root classification
local categoryColors = {
	cacao =   "8B4513", -- SaddleBrown
	coffee =  "4B3621", -- Dark Coffee Brown
	sugar =   "708090", -- SlateGray
	dairy =   "191970", -- MidnightBlue
	fruit =   "C71585", -- MediumVioletRed
	nut =     "CD853F", -- Peru
	flavor =  "008000", -- Green
	special = "000000", -- Black
	default = "000000"
}

-------------------------------------------------------------------------------
-- Data Collation & Alphabetization
-------------------------------------------------------------------------------

local ingredients = {}
for _, ing in ipairs(_IngredientOrder) do
	table.insert(ingredients, ing)
end
-- Sort explicitly by localized display name
table.sort(ingredients, function(a, b) return GetString(a.name) < GetString(b.name) end)

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local items = {}
local x = 0
local y = y_start

for _, ing in ipairs(ingredients) do
	-- Shift to a new column once we breach the Y-Axis margin limit
	if y > y_max then
		x = x + col_w
		y = y_start
	end
	
	local tempIng = ing
	local cat = ing.category or "default"
	local color = categoryColors[cat] or categoryColors.default
	
	-- Synthesize dual-line label format: Colored Name (Large) over Category (Small)
	local nameLabel = string.format("<b><font color='%s' size='15'>%s</font></b>", color, GetString(ing.name))
	local catLabel = string.format("<font size='11' color='000000'>%s</font>", string.upper(GetString(cat)))
	local label = "#" .. nameLabel .. "<br>" .. catLabel

	table.insert(items, Button { 
		x = x, y = y, w = col_w, h = row_h, 
		graphics = {}, -- Transparent backdrop for cleaner list look
		
		command = function() 
			DebugOut("DEV", string.format("Admin Selection: Chose ingredient '%s'.", tempIng.name))
			if type(onOkCallback) == "function" then onOkCallback(tempIng) end
			CloseWindow()
		end,
		
		-- 32px scaled asset icon 
		Bitmap { x = 2, y = 5, w = 32, h = 32, image = "items/" .. ing.name, scale = 0.8 }, 
		
		-- Offset text bounds dynamically based on icon footprint
		Text { x = 38, y = 0, w = col_w - 40, h = row_h, label = label, flags = kVAlignCenter + kHAlignLeft }
	})
	
	y = y + row_h
end

MakeDialog
{
	name = "dev_select_ingredient",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = col_w * num_cols, h = 600, fit = true, color = { 1, 1, 1, 0.9 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = col_w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Text { x = col_w, y = 0, w = col_w * (num_cols - 1), h = h, label = "#" .. promptText, flags = kVAlignCenter + kHAlignLeft },
		
		Group(items),
	}
}