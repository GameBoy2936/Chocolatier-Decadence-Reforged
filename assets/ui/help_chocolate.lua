--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	
	Bitmap { x=5,y=5, image="image/gun_help" },
	Text { x=155,y=5,w=440,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_chocolate_text1") },
	Text { x=15,y=150,w=580,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_chocolate_text2") },
	Text { x=65,y=250,w=570,h=kMax, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_chocolate_text3") },

	Bitmap { x=560,y=0, image="image/machine_1", scale=0.75,
		Bitmap { x=57,y=55, image="image/tray3", scale=0.75 },
		Bitmap { x=101,y=63, image="items/cacao", scale=0.75 },
		Bitmap { x=71,y=118, image="items/milk", scale=0.75 },
		Bitmap { x=133,y=118, image="items/sugar", scale=0.75 },
	},
	Bitmap { x=640,y=230, image="items/b01_big", scale=0.5 },
}