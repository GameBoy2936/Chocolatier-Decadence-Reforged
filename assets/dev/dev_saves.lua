--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Save Games
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 120
local x = 0
local y = 2*h
local saveGames = {}

local s = NextSaveFileName()
while s ~= "" do
	local g = s..".choco3"
	s = "#"..s
	table.insert(saveGames, Button { x=x,y=y,w=w,h=h, label=s, command=function() Player:LoadGameFromFile(g) end })
	y = y + h
	s = NextSaveFileName()
	if y > 550 then
		x = x + w
		y = 2 * h
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_saves",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		Button { x=0,y=h,w=w,h=h, label="#<b>SAVE GAME</b>", command=function() Player:SaveGameToFile() end },
		Button { x=0,y=2*h,w=w,h=h },
		Group(saveGames),
	},
}