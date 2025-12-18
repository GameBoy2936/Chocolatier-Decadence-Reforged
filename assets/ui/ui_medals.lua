--[[---------------------------------------------------------------------------
	Chocolatier Three: Medals Dialog
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local headline = gDialogTable.headline

-------------------------------------------------------------------------------

local function SetMedal(key)
	if key then
		SetBitmap("medal_image", "image/"..key)
		SetLabel("medal_title", GetString(key))
		SetLabel("medal_description", GetString(key.."_desc"))
	else
		SetLabel("medal_description", GetString("no_medals"))
	end
end

-------------------------------------------------------------------------------

local medalKeys = { "medal_01", "medal_02", "medal_03", "medal_04", "medal_05", "medal_06", "medal_08", "medal_09", "medal_07", }
local currentKey = nil

local x=34
local medals = {}
for _,key in ipairs(medalKeys) do
	local tempKey = key
	if Player.medals[key] then
		currentKey = key
		table.insert(medals, Button { x=x,y=45, w=75,h=75, graphics = {},
			Bitmap { x=0,y=0,image="image/"..tempKey, scale=75/260},
			command=function() SetMedal(tempKey) end })
	else
		table.insert(medals, BitmapTint { x=x,y=45,image="image/"..tempKey, scale=75/260, tint=Color(0,0,0,255) })
	end
	x = x + 80
end

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=9,name="medals",fit=true,
		Bitmap
		{
			x=0,y=13,image="image/popup_back_awards",

			SetStyle(C3DialogBodyStyle),
			Bitmap { x=60,y=155,w=260,h=260, name="medal_image" },

			Text { x=330,y=130,w=410,h=30, flags=kHAlignCenter+kVAlignCenter, label=headline },
			Text { x=330,y=170,w=410,h=100, flags=kHAlignCenter+kVAlignCenter, name="medal_title", font= { uiFontName, 28, BlackColor } },
			Text { x=350,y=275,w=370,h=145, flags=kHAlignLeft+kVAlignTop, name="medal_description" },
			
			SetStyle(C3ButtonStyle),
			Group(medals),
		},
		Bitmap { image="image/popup_nameplate", x=223,y=0,
			Text { x=34,y=10,w=270,h=38, label="#"..GetString"title_medals", font=nameplateFont, flags=kVAlignCenter+kHAlignCenter },
		},
		
		SetStyle(C3RoundButtonStyle),
		Button { x=704,y=426, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("medals", "ok") end },
	},
	FireworksWindow { x=0,y=0,w=kMax,h=kMax },
}

SetMedal(Player.lastMedal or currentKey)
if Player.medals.medal_07 then StartFireworks() end
CenterFadeIn("medals")
