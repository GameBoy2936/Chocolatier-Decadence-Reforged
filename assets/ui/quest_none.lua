--[[---------------------------------------------------------------------------
	Chocolatier Three: "No Quests Available" Log Detail
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	x=0,y=0,w=455,h=435,

	-- Summary
	SetStyle(C3CharacterDialogStyle),
	Text { x=0,y=0, w=kMax,h=kMax, label="#"..GetString"no_active_quests", font= { uiFontName, 18, BlackColor }, flags=kVAlignCenter+kHAlignCenter },
}
