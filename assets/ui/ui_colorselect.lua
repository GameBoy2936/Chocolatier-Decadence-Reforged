--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Color Palette Picker)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script renders a popup grid of colors. It is primarily utilized by 
-- the custom recipe creator allowing players to tint their chocolates.

local xDialog = gDialogTable.x or kCenter
local yDialog = gDialogTable.y or kCenter
local colors = gDialogTable.colors

-------------------------------------------------------------------------------
-- Dynamic Grid Generation
-------------------------------------------------------------------------------

local buttons = {}
for n, c in ipairs(colors) do
	-- Calculate grid position: 12 colors per row
	local x = Mod(n - 1, 12)
	local y = Floor((n - 1) / 12)
	
	-- Each swatch is 20x20 pixels with a 2-pixel margin (22px total footprint)
	x = x * 22
	y = y * 22
	
	local index = n
	
	table.insert(buttons,
		Button { 
			x = x, y = y, w = 20, h = 20, 
			graphics = {}, 
			Rectangle { x = 0, y = 0, w = 20, h = 20, color = c },
			command = function() 
				DebugOut("UI", string.format("Color selected: Index %d", index))
				CloseWindow(index) 
			end,
		}
	)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	BSGWindow
	{
		name = "colors", 
		x = xDialog, y = yDialog, 
		fit = true, 
		frame = "controls/rollover", 
		color = WhiteColor, 
		pad = 2,
		
		Group(buttons),
	}
}