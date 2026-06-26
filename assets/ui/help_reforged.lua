--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local introFont = { uiFontName, 16, BlackColor }
local bodyFont = { uiFontName, 15, BlackColor }
local linkFont = { uiFontName, 14, BlackColor }

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	
	-- Top Section: Intro and Logo
	Text { x=15, y=5, w=480, h=85, flags=kVAlignTop+kHAlignLeft, font=introFont, label="#"..GetString("help_reforged_text") },
	Bitmap { x=500, y=5, image="image/title_logo", scale=0.3 },
	
	-- Left Column: Mechanics and Modding Details
	Text { x=15, y=95, w=480, h=100, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_reforged_mechanics") },
	Text { x=15, y=190, w=480, h=110, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_reforged_modding_text") },
	
	-- Right Column: Community Links and QR Code
	Text { x=510, y=95, w=215, h=220, flags=kVAlignTop+kHAlignLeft, font=linkFont, label="#"..GetString("help_reforged_upsell") },
	Bitmap { x=535, y=205, image="image/discord_qrcode", scale=1 },
}