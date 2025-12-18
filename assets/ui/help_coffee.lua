--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local mac_scale = 0.6

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=180,y=5,w=390,h=324, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_coffee_text1") },
	Text { x=25,y=225,w=600,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_coffee_text2") },
	Text { x=65,y=270,w=570,h=kMax, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_coffee_text3") },
	
	Bitmap { x=560,y=0, image="image/machine_2", scale=0.75,
		Bitmap { x=95,y=59, image="items/coffee", scale=0.75 },
		Bitmap { x=95,y=108, image="items/cream", scale=0.75 },
		Bitmap { x=95,y=158, image="items/sugar", scale=0.75 },
	},
	Bitmap { x=640,y=230, image="items/c01_big", scale=0.5 },
	
	Bitmap { x=0,y=0, image="image/conveyor_belt_narrow", scale=mac_scale,
		Bitmap { x=20*mac_scale,y=60*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=65*mac_scale,y=60*mac_scale, image="items/coffee", scale=mac_scale },
--		Bitmap { x=110*mac_scale,y=60*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=155*mac_scale,y=60*mac_scale, image="items/cream", scale=mac_scale },
--		Bitmap { x=200*mac_scale,y=60*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=245*mac_scale,y=60*mac_scale, image="items/sugar", scale=mac_scale },

		Bitmap { x=20*mac_scale,y=105*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=65*mac_scale,y=105*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=110*mac_scale,y=105*mac_scale, image="items/cream", scale=mac_scale },
		Bitmap { x=155*mac_scale,y=105*mac_scale, image="items/cream", scale=mac_scale },
		Bitmap { x=200*mac_scale,y=105*mac_scale, image="items/sugar", scale=mac_scale },
--		Bitmap { x=245*mac_scale,y=105*mac_scale, image="items/coffee", scale=mac_scale },
		
--		Bitmap { x=20*mac_scale,y=150*mac_scale, image="items/coffee", scale=mac_scale },
--		Bitmap { x=65*mac_scale,y=150*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=110*mac_scale,y=150*mac_scale, image="items/cream", scale=mac_scale },
--		Bitmap { x=155*mac_scale,y=150*mac_scale, image="items/cream", scale=mac_scale },
		Bitmap { x=200*mac_scale,y=150*mac_scale, image="items/sugar", scale=mac_scale },
--		Bitmap { x=245*mac_scale,y=150*mac_scale, image="items/coffee", scale=mac_scale },

--		Bitmap { x=20*mac_scale,y=195*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=65*mac_scale,y=195*mac_scale, image="items/sugar", scale=mac_scale },
		Bitmap { x=110*mac_scale,y=195*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=155*mac_scale,y=195*mac_scale, image="items/cream", scale=mac_scale },
		Bitmap { x=200*mac_scale,y=195*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=245*mac_scale,y=195*mac_scale, image="items/coffee", scale=mac_scale },

		Bitmap { x=20*mac_scale,y=240*mac_scale, image="items/sugar", scale=mac_scale },
		Bitmap { x=65*mac_scale,y=240*mac_scale, image="items/sugar", scale=mac_scale },
		Bitmap { x=110*mac_scale,y=240*mac_scale, image="items/coffee", scale=mac_scale },
--		Bitmap { x=155*mac_scale,y=240*mac_scale, image="items/cream", scale=mac_scale },
--		Bitmap { x=200*mac_scale,y=240*mac_scale, image="items/coffee", scale=mac_scale },
--		Bitmap { x=245*mac_scale,y=240*mac_scale, image="items/coffee", scale=mac_scale },

--		Bitmap { x=20*mac_scale,y=285*mac_scale, image="items/coffee", scale=mac_scale },
--		Bitmap { x=65*mac_scale,y=285*mac_scale, image="items/sugar", scale=mac_scale },
		Bitmap { x=110*mac_scale,y=285*mac_scale, image="items/sugar", scale=mac_scale },
		Bitmap { x=155*mac_scale,y=285*mac_scale, image="items/sugar", scale=mac_scale },
--		Bitmap { x=200*mac_scale,y=285*mac_scale, image="items/coffee", scale=mac_scale },
		Bitmap { x=245*mac_scale,y=285*mac_scale, image="items/cream", scale=mac_scale },
	},
}