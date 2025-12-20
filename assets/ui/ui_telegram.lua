--[[---------------------------------------------------------------------------
	Chocolatier Three: Generic Telegram
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local char = gDialogTable.char
local building = gDialogTable.building
local text = gDialogTable.text

local header = {}

-- TO: Line (Always the player)
table.insert(header, GetString("telegram_to", Player.name))

-- FROM: Line
if char then
    table.insert(header, GetString("telegram_from", GetString(char.name)))
end

-- LOCATION: Line
if building and building.port then
    local location_string = GetString(building.name) .. " - " .. GetString(building.port.name)
    table.insert(header, GetString("telegram_where", location_string))
end

-- Combine the header lines with line breaks
local full_text = table.concat(header, "<br>") .. "<br><br>" .. text

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=500,h=333, name="telegram",
		Bitmap
		{
			x=0,y=0, image="image/telegram",
			
			SetStyle(C3CharacterDialogStyle),
			Text { x=20,y=115,w=457,h=175, label="#"..string.upper(full_text), flags=kVAlignTop+kHAlignLeft },
			
			SetStyle(C3ButtonStyle),
			Button { x=101,y=275, name="ok", label="ok", default=true, cancel=true, command=CloseWindow },
		},
	}
}

CenterFadeIn("telegram")