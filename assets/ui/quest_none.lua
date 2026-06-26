--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Empty Quest Log Detail)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- Simple dummy block rendered when the player has absolutely zero active quests.

MakeDialog
{
	x = 0, y = 0, w = 455, h = 435,

	SetStyle(C3CharacterDialogStyle),
	Text { x = 0, y = 0, w = kMax, h = kMax, label = "#" .. GetString("no_active_quests"), font = { uiFontName, 18, BlackColor }, flags = kVAlignCenter + kHAlignCenter },
}