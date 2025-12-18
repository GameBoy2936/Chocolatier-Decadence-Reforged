--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Buildings
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 140
local x = 0
local y = h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	if y > 400 then
		x = x + w
		y = h
	end
end

-------------------------------------------------------------------------------

AddItem( Button { x=x,y=y,w=w,h=h, label="#Cape Town Factory", command=function() cap_factory:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#San Francisco Factory", command=function() san_factory:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Tokyo Factory", command=function() tok_factory:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Toronto Factory", command=function() tor_factory:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Wellington Factory", command=function() wel_factory:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Zürich Factory", command=function() zur_factory:MarkOwned() end } )

AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Baghdad", command=function() bag_shop:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Bogotá", command=function() bog_shop:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Douala", command=function() dou_shop:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Havana", command=function() hav_shop:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Kona", command=function() kon_shop:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Lima", command=function() lim_shop:MarkOwned() end } )
AddItem( Button { x=x,y=y,w=w,h=h, label="#Shop: Tangiers", command=function() tan_shop:MarkOwned() end } )

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_buildings",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		Group(items),
	},
}