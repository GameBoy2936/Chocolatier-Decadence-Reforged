--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Port List Panel)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local function Mod(a, n)
	if n == 0 then return a end
	return a - (n * Floor(a / n))
end

local function SelectPort(port)
	-- Strict Verification: The player is completely blocked from reading the 
	-- detail pane of a port they haven't manually visited yet.
	if port and Player.catalogue.unlockedPorts[port.name] then
		if gCatalogueSelection ~= port then
			gCatalogueSelection = port
			DebugOut("UI", string.format("Catalogue selection changed to Port: %s", port.name))
			
			FillWindow("catalogue_list", "ui/catalogue_port_list.lua")
			FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
		end
	end
end

-------------------------------------------------------------------------------
-- Data Assembly
-------------------------------------------------------------------------------

local portList = {}
for name, port in pairs(_AllPorts) do
	table.insert(portList, port)
end

-- Sort the list alphabetically by localized display name
table.sort(portList, function(a, b) return GetString(a.name) < GetString(b.name) end)

-------------------------------------------------------------------------------
-- Grid Layout & Thumbnails
-------------------------------------------------------------------------------

local contents = {}

-- Generates a 4x5 grid of image thumbnails
local layout = {
	x_start = 0, y_start = 0,
	x_spacing = 65, y_spacing = 80,
	items_per_row = 4,
	rows_per_page = 5,
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page
gCatalogueLayout = layout

local thumbScale = 0.70

local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
	local port = portList[i]
	if port then
		local tempPort = port
		local isUnlocked = Player.catalogue.unlockedPorts[port.name]

		local label = isUnlocked and GetString(port.name) or GetString("catalogue_locked_title")
		local imagePath = "image/catalogue_thumb_" .. port.name .. ".png"
		
		local portDisplay
		if isUnlocked then
			portDisplay = Bitmap { image = imagePath, scale = thumbScale }
		else
			portDisplay = BitmapTint { image = imagePath, tint = Color(0, 0, 0, 255), scale = thumbScale }
		end

		table.insert(contents,
			Button { 
				x = x, y = y, w = 95, h = 95, graphics = {},
				command = function() SoundEvent("cadi/ui_click.ogg"); SelectPort(tempPort) end,
				
				-- Dynamic Background Highlight
				Bitmap { x = 0, y = 0, image = (gCatalogueSelection == tempPort) and "image/button_recipes_selected" or "image/button_recipes_up" },
				
				-- Bounded Thumbnail Container
				Window { x = 15, y = 15, w = 74, h = 74, portDisplay },

				-- Text label underneath
				Text { x = 2, y = 80, w = 95, h = 20, label = "#" .. label, font = { uiFontName, 12, BlackColor }, flags = kVAlignCenter + kHAlignCenter }
			}
		)

		items_drawn_this_page = items_drawn_this_page + 1
		x = x + layout.x_spacing
		if Mod(items_drawn_this_page, layout.items_per_row) == 0 then
			x = layout.x_start
			y = y + layout.y_spacing
		end
	end
end

MakeDialog(contents)

local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(portList)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)