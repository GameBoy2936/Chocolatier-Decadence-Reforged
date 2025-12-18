--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=15,y=5,w=720,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_design_text") },
	
	SetStyle(C3ButtonStyle),
	Bitmap { x=3,y=42,  image="image/button_arrow_left_up" },
	Bitmap { x=44,y=46, image="image/designer_custom_window",
		BitmapTint { x=13,y=13,w=64,h=64, name="option_layer0", scale=0.5, image="custom/bar/layer1_02", tint=Color(86,44,22,255) },
		Bitmap { x=13,y=13,w=64,h=64, name="option_highlight0", scale=0.5, image="custom/bar/layer1_02_highlight" } },
	Bitmap { x=137,y=42, image="image/button_arrow_right_up", },
	Bitmap { x=50,y=138, scale=.6, image=C3ButtonStyle.graphics[1], Rectangle { name="tint1", x=10,y=6,w=kMax-12,h=kMax-11, color=Color(86,44,22,255) }, },
	Text { x=180,y=47,w=560,h=119, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString("help_design_graphics") },

	Text { x=15,y=175,w=720,h=kMax, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_design_add") },
}