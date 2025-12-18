--[[--------------------------------------------------------------------------
	Chocolatier Three
	Minigame Pause Dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

local score = GetScore()
local scoreText = GetString("factory_gameover", tostring(score))

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=20,y=42,w=459,h=177, label="#"..scoreText, flags=kVAlignCenter+kHAlignCenter },
	
	SetStyle(C3ButtonStyle),
	Button { x=113,y=237, label="try_again", command=function() StartGame() end },
	Button { x=256,y=237, label="done", cancel=true, command=function() CloseWindow(score) end },
}
