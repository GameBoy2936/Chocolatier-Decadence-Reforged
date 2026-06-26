--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Minigame Game Over)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- Retrieves the final case count from the C++ object to display to the user
local score = GetScore()
local scoreText = GetString("factory_gameover", tostring(score))

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x = 20, y = 42, w = 459, h = 177, label = "#" .. scoreText, flags = kVAlignCenter + kHAlignCenter },
	
	SetStyle(C3ButtonStyle),
	Button { x = 113, y = 237, label = "try_again", command = function() StartGame() end },
	
	-- Passes the final score back up to the main Lua logic loop
	Button { x = 256, y = 237, label = "done", cancel = true, command = function() CloseWindow(score) end },
}