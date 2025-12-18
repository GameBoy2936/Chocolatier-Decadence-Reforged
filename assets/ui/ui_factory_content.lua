--[[---------------------------------------------------------------------------
	Chocolatier Three: Factory Configuration Dynamic Content
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local factory = gCurrentFactory
local count,current = factory:GetProduction()

-------------------------------------------------------------------------------

--[[
local y = 55
local machines = {}
for _,cat in ipairs(_CategoryOrder) do
	local name = cat.name
	if not factory:IsEquipped(name) then
		name = "#<font color='C0C0C0'>"..GetString(name)
	end
	table.insert(machines, Text { x=kMax-90,y=y,w=90,h=20, label=name })
	y = y + 20
end
]]--

-------------------------------------------------------------------------------

local count,current = factory:GetProduction()
--local countFont = { uiFontName, 120, MaroonColor }
local countFont = { uiFontName, 50, Color(255,41,77) }

local currentAlignment = kHAlignCenter+kVAlignBottom
if current and current:GetMachinery().name == "blend" then currentAlignment = kHAlignCenter+kVAlignCenter end

MakeDialog
{
	x=0,y=0,w=kMax,h=kMax,fit=true,
	SetStyle(C3CharacterDialogStyle),

--	Text { x=147,y=50,w=128,h=128, name="current_count", label="#"..tostring(count), flags=kHAlignCenter+kVAlignCenter, font=countFont },
--	Text { x=147,y=148,w=128,h=20, label="cases_per", flags=kHAlignCenter+kVAlignCenter },
	Bitmap { x=147,y=60,w=128,h=128, name="timer_face", image="image/timer_face", scale=128/148,
		Bitmap { image="image/timer_hand", scale=128/148, },
--		Text { x=0,y=0,w=128,h=128, name="current_count", label="#"..tostring(count), flags=kHAlignCenter+kVAlignCenter, font=countFont },
		Text { x=0,y=32,w=128,h=64,flags=kVAlignTop+kHAlignCenter,label="#"..GetString"cases",font={uiFontName,18,Color(255,1,17)} },
		Text { x=0,y=0,w=128,h=128, name="current_count", label="#"..tostring(count), flags=kHAlignCenter+kVAlignCenter, font=countFont },
--		Text { x=0,y=98,w=128,h=20, label="cases_per", flags=kHAlignCenter+kVAlignCenter },
		Text { x=0,y=80,w=128,h=20, label="#"..GetString"cases_per", flags=kHAlignCenter+kVAlignCenter,font={uiFontName,12,Color(255,1,17)} },
	},

--	Group(machines),

	current:GetAppearanceHuge(7,50),
	Text { x=7,y=0,w=276,h=20, label="#"..GetString"now_making", flags=kHAlignCenter+kVAlignCenter },
	Text { x=7,y=20,w=276,h=40, name="current_product", label="#"..current:GetName(), flags=currentAlignment, font=factoryStatusFont },

--	Text { x=64,y=42,w=kMax,h=20, name="current_count", label="#"..GetString("cases_per", tostring(count)) },
}
