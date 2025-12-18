--[[---------------------------------------------------------------------------
	Chocolatier Three "Missing Ingredients" Dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local ok = gDialogTable.ok or "ok"
local text = gDialogTable.text or "#NOT YET IMPLEMENTED"

-------------------------------------------------------------------------------

local missingIngredients = {}
local x=40
local y=100
for _,name in ipairs(gDialogTable.missing) do
	table.insert(missingIngredients, Bitmap { x=x,y=y, image="items/"..name })
	table.insert(missingIngredients, Text { x=x+40,y=y,w=190,h=32, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString(name) })
	y = y + 32
	if y > 190 then
		x = 250
		y = 100
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="missing",
		x=1000,y=kCenter,image="image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x=20,y=50,w=459,h=50, label="#"..GetString"factory_insufficient", flags=kVAlignCenter+kHAlignCenter },
		
		Group(missingIngredients),
		
		SetStyle(C3ButtonStyle),
		Button { x=kCenter,y=237, name="ok", label=ok, command=function() FadeCloseWindow("missing", "ok") end, default=true, cancel=true },
	}
}

CenterFadeIn("missing")
