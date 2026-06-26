--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	MODIFIED (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local introFont = { uiFontName, 17, BlackColor }
local bodyFont = { uiFontName, 16, BlackColor }

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	
	Text { x=15, y=5, w=720, h=50, flags=kVAlignTop+kHAlignLeft, font=introFont, label="#"..GetString("help_kitchen_text") },

	-- Left Column: Drawers
	Bitmap { x=5, y=55, image="image/kitchen_drawer_open", 
		Text { x=8, y=130, w=91, h=17, flags=kVAlignCenter+kHAlignCenter, font=bodyFont, label="#"..GetString("cacao") }, 
	},
	Bitmap { x=5, y=87, image="image/kitchen_jar", Bitmap { x=5, y=14, image="items/cacao" } },
	Bitmap { x=47, y=87, image="image/kitchen_jar", Bitmap { x=5, y=14, image="items/bal_cacao" } },
	Bitmap { x=89, y=87, image="image/kitchen_jar_space" },
	Bitmap { x=121, y=87, image="image/kitchen_jar_space" },
	Bitmap { x=153, y=87, image="image/kitchen_jar_space" },
	
	Text { x=140, y=45, w=590, h=kMax, flags=kVAlignTop+kHAlignLeft, font=introFont, label="#"..GetString("help_kitchen_drawers") },
	
	-- Center/Right: Bowls and Variable Slots
	Bitmap { x=195, y=155, image="image/kitchen_bowl" },
	Bitmap { x=210, y=100, image="items/sugar_big" },
	
	Bitmap { x=285, y=155, image="image/kitchen_bowl" },
	Bitmap { x=300, y=100, image="items/cacao_big" },
	
	Bitmap { x=375, y=155, image="image/kitchen_bowl" },
	Bitmap { x=390, y=100, image="items/milk_big" },

	-- Visual representation of our new Variable Slots feature
	SetStyle(C3SmallRoundButtonStyle),
	Button { x=465, y=140, name="remove_slot_help", label="#-", scale=1 },
	Button { x=505, y=140, name="add_slot_help", label="#+", scale=1 },
	
	SetStyle(C3DialogBodyStyle),
	Text { x=140, y=205, w=590, h=kMax, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_kitchen_create") },

	Text { x=15, y=275, w=720, h=kMax, flags=kVAlignTop+kHAlignCenter, font=bodyFont, label="#"..GetString("help_kitchen_next") },
}