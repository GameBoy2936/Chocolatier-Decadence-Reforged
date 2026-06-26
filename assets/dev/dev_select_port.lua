--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Port Selector)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local onOkCallback = gDialogTable.onOk
local promptText = gDialogTable.prompt or "Select a Port:"

-- Grid Layout Constraints
local h = devMenuStyle.font[2]
local col_w = 200
local num_cols = 4
local row_h = 83
local y_start = 1.2 * h
local y_max = 560

-------------------------------------------------------------------------------
-- Data Collation & Alphabetization
-------------------------------------------------------------------------------

local ports = {}
for _, p in pairs(_AllPorts) do
	table.insert(ports, p)
end
table.sort(ports, function(a, b) return GetString(a.name) < GetString(b.name) end)

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local items = {}
local x = 0
local y = y_start

for _, port in ipairs(ports) do
	-- Shift column once the Y-bound is breached
	if y > y_max then
		x = x + col_w
		y = y_start
	end
	
	local tempPort = port
	
	-- Dynamically resolve all environmental locale tags 
	local portName = GetString(port.name)
	local hemisphereKey = port.hemisphere or "unknown"
	local hemisphereName = GetString("hemisphere_" .. hemisphereKey)
	local regionKey = port.region or "unknown"
	local regionName = GetString("region_" .. regionKey)
	local countryKey = port.country or "unknown"
	local countryName = GetString("country_" .. countryKey)
	local cultureKey = port.culture or "unknown"
	local cultureName = GetString("culture_" .. cultureKey)
	
	-- Synthesize the 5-layer label string. The layout utilizes <br> HTML breaks 
	-- to stack the metadata neatly to the right of the thumbnail.
	local label = string.format("<b><font size='16'>%s</font></b><br><font size='12' color='555555'>%s</font><br><font size='12' color='555555'>%s</font><br><font size='12' color='555555'>%s</font><br><font size='12' color='555555'>%s</font>", portName, hemisphereName, regionName, countryName, cultureName)

	table.insert(items, Button { 
		x = x, y = y, w = col_w, h = row_h, 
		graphics = {}, 
		
		command = function() 
			DebugOut("DEV", string.format("Admin Selection: Chose port '%s'.", tempPort.name))
			if type(onOkCallback) == "function" then onOkCallback(tempPort) end
			CloseWindow()
		end,
		
		-- In-game rendered Thumbnail Icon
		Bitmap { x = 2, y = 2, image = "image/catalogue_thumb_" .. port.name, scale = 0.8 },
		
		-- Formatted Multi-line HTML Text Stack
		Text { x = 82, y = 0, w = col_w - 50, h = row_h, label = "#" .. label, flags = kVAlignCenter + kHAlignLeft }
	})
	
	y = y + row_h
end

MakeDialog
{
	name = "dev_select_port",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = col_w * num_cols, h = 600, fit = true, color = { 1, 1, 1, 0.9 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = col_w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Text { x = col_w, y = 0, w = col_w * (num_cols - 1), h = h, label = "#" .. promptText, flags = kVAlignCenter + kHAlignLeft },
		
		Group(items),
	}
}