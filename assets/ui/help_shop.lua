--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local reg_scale = 0.75

local ask = Dollars(b01.price_high)
ask = "#"..GetString("sell_howmany", b01:GetName(), ask, tostring(10))

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=15,y=5,w=440,h=100, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_shop_text") },
	Bitmap { x=0,y=103, image="image/button_box_up",
		Bitmap { x=35,y=46, image="items/b01_big", scale=0.5 } },
	Text { x=135,y=103,w=320,h=145, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString("help_shop_sell") },
	Text { x=55,y=255,w=640,h=130, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_shop_misc") },

	Bitmap
	{
		x=470,y=0, name="ui_register", image="image/popup_back_register", scale=reg_scale,
		
		SetStyle(C3CharacterDialogStyle),
		b01:GetAppearance(30*reg_scale,24*reg_scale),
		Text { x=110*reg_scale,y=18*reg_scale,w=245*reg_scale,h=78*reg_scale,
			flags=kHAlignLeft+kVAlignCenter, font={characterBodyFont[1],characterBodyFont[2]*reg_scale,characterBodyFont[3]},
			label=ask,
		},
		
		Bitmap { x=70*reg_scale,y=104*reg_scale, image="image/popup_back_register_entryfield", scale=reg_scale,
			Text { x=4*reg_scale,y=0, w=114*reg_scale,h=kMax, label="0", flags=kVAlignCenter+kHAlignRight, font= {uiFontName,18*reg_scale,WhiteColor} },
		},
		
		Bitmap { x=7*reg_scale,y=86*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#C", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=23*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#1", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=62*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#2", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=101*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#3", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=140*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#4", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=179*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#5", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=7*reg_scale,y=169*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#6", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=46*reg_scale,y=169*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#7", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=85*reg_scale,y=169*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#8", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=124*reg_scale,y=169*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#9", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=163*reg_scale,y=169*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#0", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },

		Bitmap { x=232*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#+10", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=280*reg_scale,y=132*reg_scale, image=C3SmallRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#+100", font={roundButtonFont[1], roundButtonFont[2]*reg_scale, roundButtonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },

		Bitmap { x=137*reg_scale,y=228*reg_scale, image=C3LargeRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#"..GetString("sell"), font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },

		Bitmap { x=9*reg_scale,y=258*reg_scale, image=C3ButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#"..GetString("sell_all"), font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
		Bitmap { x=232*reg_scale,y=258*reg_scale, image=C3ButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#"..GetString("cancel"), font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
	},
}