--[[---------------------------------------------------------------------------
	Chocolatier Three: Generic Telegram
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local from
local char = gDialogTable.char
if char then
	from = "#"..GetString("telegram_from", GetString(char.name))
end

local text = gDialogTable.text

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=500,h=333, name="telegram",
		Bitmap
		{
			x=0,y=0, image="image/telegram",
			SetStyle(controlStyle),
			
			SetStyle(C3CharacterDialogStyle),
			Text { x=20,y=115,w=457,h=20, label=from, flags=kVAlignTop+kHAlignLeft },
			Text { x=20,y=135,w=457,h=135, label=text, flags=kVAlignTop+kHAlignLeft },
			
			SetStyle(C3ButtonStyle),
			Button { x=101,y=275, name="ok", label="ok", default=true, cancel=true, command=CloseWindow },
		},
	}
}

CenterFadeIn("telegram")
