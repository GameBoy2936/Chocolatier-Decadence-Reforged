--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Generic Telegram Dialog)
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local char = gDialogTable.char
local building = gDialogTable.building
local text = gDialogTable.text

-- ----------------------------------------------------------------------------
-- Telegram Header Construction
-- ----------------------------------------------------------------------------
-- Synthesizes the physical telegraph printout formatting

local header = {}

-- TO: (The Player)
table.insert(header, GetString("telegram_to", Player.name))

-- FROM: (The Sender)
if char then
	table.insert(header, GetString("telegram_from", GetString(char.name)))
end

-- LOCATION: (Origin Point)
if building and building.port then
	local location_string = GetString(building.name) .. " - " .. GetString(building.port.name)
	table.insert(header, GetString("telegram_where", location_string))
end

-- Compile the header with HTML line breaks, followed by a double break, then the message body
local full_text = table.concat(header, "<br>") .. "<br><br>" .. text

DebugOut("UI", string.format("Rendering Generic Telegram UI (Sender: %s).", char and char.name or "Unknown"))

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x = 1000, y = 35, w = 500, h = 333, name = "telegram",
		Bitmap
		{
			x = 0, y = 0, image = "image/telegram",
			
			SetStyle(C3CharacterDialogStyle),
			-- Force Telegrams into screaming UPPERCASE for period authenticity
			Text { x = 20, y = 115, w = 457, h = 175, label = "#" .. string.upper(full_text), flags = kVAlignTop + kHAlignLeft },
			
			SetStyle(C3ButtonStyle),
			Button { x = 101, y = 275, name = "ok", label = "ok", default = true, cancel = true, command = CloseWindow },
		},
	}
}

CenterFadeIn("telegram")