--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
		
	Bitmap { x=20,y=3, image="image/recipes_category_1_enabled", 
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[1].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },
	Bitmap { x=127,y=3, image="image/recipes_category_2_enabled",
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[2].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },
	Bitmap { x=227,y=3, image="image/recipes_category_3_enabled",
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[3].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },
	Bitmap { x=327,y=4, image="image/recipes_category_4_enabled",
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[4].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },
	Bitmap { x=427,y=3, image="image/recipes_category_5_enabled",
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[5].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },
	Bitmap { x=527,y=3, image="image/recipes_category_6_enabled",
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[6].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },
	Bitmap { x=627,y=3, image="image/recipes_category_7_enabled",
		Text{ x=0,y=14,w=kMax,h=kMax, label="#"..GetString(_CategoryOrder[7].name), flags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont } },

	Text { x=10,y=80,w=729,h=324, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_recipes_text") },
		
	Bitmap { x=35,y=145, image="items/sugar_big", Bitmap { x=0,y=0, image="image/missing_ingredient" } },
	Text { x=105,y=145,w=590,h=64, label="#"..GetString("help_recipes_missing") },
	Text { x=25,y=220,w=700,h=64, label="#"..GetString("help_recipes_creations"), flags=kVAlignTop+kHAlignCenter },
	Text { x=25,y=265,w=700,h=64, label="#"..GetString("help_recipes_factory"), flags=kVAlignTop+kHAlignCenter },
}