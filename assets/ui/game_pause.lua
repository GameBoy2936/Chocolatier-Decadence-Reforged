--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Minigame Pause)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- Allows the game to supply custom text (e.g. "Game Paused" vs "Coffee Maker Overheating!")
local text = gPauseText
if (not text) or text == "" then text = "game_paused" end

-- Clear the global text hook immediately so it doesn't bleed into future pauses
gPauseText = nil

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x = 20, y = 42, w = 459, h = 177, label = "#" .. GetString(text), flags = kVAlignCenter + kHAlignCenter },
	
	SetStyle(C3ButtonStyle),
	Button { x = kCenter, y = 240, name = "ok", label = "ok", command = ResumeGame },
}