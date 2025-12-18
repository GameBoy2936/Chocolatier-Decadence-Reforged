--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),

	Text { x=15,y=5,w=749,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_kitchen_text") },

	Bitmap { x=5,y=60, image="image/kitchen_drawer_open", Text { x=8,y=130,w=91,h=17, flags=kVAlignCenter+kHAlignCenter, label="#"..GetString("cacao"), }, },
	Bitmap { x=5,y=92, image="image/kitchen_jar", Bitmap { x=6,y=14, image="items/cacao", }, },
	Bitmap { x=47,y=92, image="image/kitchen_jar", Bitmap { x=6,y=14, image="items/bal_cacao", }, },
	Bitmap { x=82,y=92, image="image/kitchen_jar_space" },
	Bitmap { x=127,y=92, image="image/kitchen_jar_space" },
	Bitmap { x=167,y=92, image="image/kitchen_jar_space" },
	Text { x=124,y=50,w=620,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_kitchen_drawers") },
	
	Bitmap { x=290,y=150, image="image/kitchen_bowl" },
	Bitmap { x=305,y=97, image="items/sugar_big" },
	Bitmap { x=380,y=150, image="image/kitchen_bowl" },
	Bitmap { x=395,y=97, image="items/cacao_big" },
	Bitmap { x=470,y=150, image="image/kitchen_bowl" },
	Bitmap { x=485,y=97, image="items/milk_big" },
	Text { x=124,y=200,w=620,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_kitchen_create") },

	Text { x=65,y=270,w=600,h=kMax, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_kitchen_next") },
}