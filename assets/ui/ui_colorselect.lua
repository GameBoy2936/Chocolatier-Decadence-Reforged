--[[---------------------------------------------------------------------------
	Chocolatier Three Color Select Dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local xDialog = gDialogTable.x or kCenter
local yDialog = gDialogTable.y or kCenter
local colors = gDialogTable.colors

-------------------------------------------------------------------------------

local buttons = {}
for n,c in ipairs(colors) do
	local x = Mod(n - 1, 12)
	local y = Floor((n - 1) / 12)
	x = x * 22
	y = y * 22
	local index=n
	table.insert(buttons,
		Button { x=x,y=y,w=20,h=20, graphics={}, Rectangle { x=0,y=0,w=20,h=20, color=c },
			command = function() CloseWindow(index) end,
		})
end

-------------------------------------------------------------------------------

MakeDialog
{
	BSGWindow
	{
		name = "colors", x=xDialog,y=yDialog, fit=true, frame="controls/rollover", color=WhiteColor, pad=2,
		Group(buttons),
	}
}