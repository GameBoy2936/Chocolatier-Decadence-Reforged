--[[---------------------------------------------------------------------------
	Chocolatier Three: Help dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local screens = { "help_general", "help_map", "help_port", "help_market", "help_shop", "help_recipes", "help_chocolate", "help_coffee", "help_quests", "help_kitchen", "help_design" }

local current = 1
if gDialogTable.helpScreen then
	for i,key in ipairs(screens) do
		if key == gDialogTable.helpScreen then
			current = i
			break
		end
	end
end

-------------------------------------------------------------------------------

local function UpdateScreen()
	EnableWindow("next", (current < table.getn(screens)))
	EnableWindow("prev", (current > 1))
	FillWindow("help_contents", "ui/"..screens[current]..".lua")
	SetLabel("title", GetString(screens[current]))
	SetLabel("title_highlight", "<outline color='FFFFFF' size=2>"..GetString(screens[current]))
end

local function nextFunction()
	if current < table.getn(screens) then
		current = current + 1
		UpdateScreen()
	end
end

local function prevFunction()
	if current > 1 then
		current = current - 1
		UpdateScreen()
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=kCenter,name="help",fit=true,
		Bitmap
		{
			x=0,y=0,image="image/popup_back_awards",

			SetStyle(C3DialogBodyStyle),
			Window { name="help_contents", x=17,y=129,w=749,h=324, },
			
			Text { x=155,y=20,w=470,h=100, name="title_highlight", label="",
				font = { labelFontName, 50, WhiteColor },
				flags=kVAlignCenter+kHAlignCenter },
			Text { x=155,y=20,w=470,h=100, name="title", label="#HELP TEST",
				font = { labelFontName, 50, BlackColor },
				flags=kVAlignCenter+kHAlignCenter },

			SetStyle(C3ButtonStyle),
			Button { x=30,y=60, name="prev", label="previous", command=prevFunction },
			Button { x=625,y=60, name="next", label="next", command=nextFunction },
		},
		SetStyle(C3RoundButtonStyle),
		Button { x=704,y=416, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("help", "ok") end },
	},
}

UpdateScreen()
CenterFadeIn("help")
