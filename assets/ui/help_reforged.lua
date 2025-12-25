--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=15,y=5,w=729,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_quests_text") },
	
	Bitmap { x=120,y=130, image="image/indicatorlight_off", },
	Text { x=155,y=128,w=470,h=36, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString("help_quests_incomplete") },
	
	Bitmap { x=120,y=166, image="image/indicatorlight_green", },
	Text { x=155,y=164,w=470,h=36, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString("help_quests_complete") },
	
	Bitmap { x=120,y=202, image="image/indicatorlight_blank", },
	Text { x=155,y=200,w=470,h=36, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString("help_quests_hint") },
	
	Bitmap { x=50,y=205, image="image/ledger_help",
		Bitmap { x=0,y=9, image="image/badge_button_indicator_complete" },
		Text { x=86,y=58,w=442,h=34, flags=kHAlignCenter+kVAlignCenter, font = { uiFontName, 17, Color(0,0,0,255) },
			label="#"..GetString("help_quests_ledger") },
	},
}