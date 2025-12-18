--[[--------------------------------------------------------------------------
	Chocolatier Three
	Minigame Pause Dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

local text = gPauseText
if (not text) or text == "" then text = "game_paused" end
gPauseText = nil

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=20,y=42,w=459,h=177, label="#"..GetString(text), flags=kVAlignCenter+kHAlignCenter },
	SetStyle(C3ButtonStyle),
	Button { x=kCenter,y=240, name="ok", label="ok", command=ResumeGame, },
}
