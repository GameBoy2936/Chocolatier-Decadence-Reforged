--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local introFont = { uiFontName, 17, BlackColor }
local bodyFont = { uiFontName, 15, BlackColor }

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	
	Text { x=15, y=5, w=720, h=70, flags=kVAlignTop+kHAlignLeft, font=introFont, label="#"..GetString("help_catalogue_text") },
	
	-- History (Tab 1)
	Bitmap { x=15, y=75, image="items/b03_big", scale=0.4 },
	Text { x=70, y=75, w=280, h=95, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_catalogue_history") },
	
	-- Characters (Tab 2)
	Bitmap { x=15, y=175, image="items/almond_big", scale=0.8 },
	Bitmap { x=15, y=215, image="items/mint_big", scale=0.8 },
	Text { x=440, y=75, w=280, h=95, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_catalogue_characters") },
	
	-- Ingredients (Tab 3)
	CharWindow { x=370,y=75, name="zur_shopkeep", scale=0.4 },
	Text { x=70, y=175, w=280, h=95, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_catalogue_ingredients") },

	-- Ports (Tab 4)
	Bitmap { x=362, y=170, image="image/catalogue_thumb_zurich", scale=0.8 },
	Text { x=440, y=175, w=280, h=95, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_catalogue_ports") },

	-- Locked Disclaimer
	Text { x=15, y=270, w=719, h=44, flags=kVAlignTop+kHAlignCenter, font=bodyFont, label="#"..GetString("help_catalogue_locked") },
}