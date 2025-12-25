--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local reg_scale = 0.75

local blueberry = _AllIngredients["blueberry"]
local unit_string = blueberry:GetUnitName(2)

local ask = Dollars(blueberry.price_high)
ask = "#"..GetText("buy_howmany", blueberry:GetName(), ask, unit_string)

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=15,y=5,w=440,h=100, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_market_text") },
	Bitmap { x=0,y=103, image="image/button_sack_up",
		Bitmap { x=33,y=42, image="items/blueberry_big" } },
	Text { x=135,y=103,w=320,h=135, flags=kVAlignCenter+kHAlignLeft, label="#"..GetString("help_market_buy") },
	Text { x=55,y=255,w=640,h=130, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_market_misc") },

	Bitmap
	{
		x=470,y=0, name="ui_register", image="image/popup_back_register", scale=reg_scale,
		
		SetStyle(C3CharacterDialogStyle),
		blueberry:GetAppearance(40*reg_scale,24*reg_scale),
		Text { x=110*reg_scale,y=18*reg_scale,w=245*reg_scale,h=78*reg_scale,
			flags=kHAlignLeft+kVAlignCenter, font={characterBodyFont[1],characterBodyFont[2]*reg_scale,characterBodyFont[3]},
			label=ask,
		},
		
		Bitmap { x=70*reg_scale,y=104*reg_scale, image="image/popup_back_register_entryfield", scale=reg_scale,
			Text { x=4*reg_scale,y=0, w=114*reg_scale,h=kMax, label="0", flags=kVAlignCenter+kHAlignRight, font= {uiFontName,18*reg_scale,WhiteColor} },
		},
		
		-- Keypad Buttons (Round)
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

		-- Increment Buttons (Rectangular, Vertical Layout)
		-- Matched to ui/ui_buysell.lua layout (x=251, y starts at 134, increments of 25)
		Bitmap { x=251*reg_scale, y=134*reg_scale, image=C3ButtonStyle.graphics[1], scale=0.6*reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#+1", font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
			
		Bitmap { x=251*reg_scale, y=159*reg_scale, image=C3ButtonStyle.graphics[1], scale=0.6*reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#+10", font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
			
		Bitmap { x=251*reg_scale, y=184*reg_scale, image=C3ButtonStyle.graphics[1], scale=0.6*reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#+100", font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
			
		Bitmap { x=251*reg_scale, y=209*reg_scale, image=C3ButtonStyle.graphics[1], scale=0.6*reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#+1000", font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },

		-- Action Buttons
		Bitmap { x=137*reg_scale,y=228*reg_scale, image=C3LargeRoundButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#"..GetString("buy"), font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },

		Bitmap { x=232*reg_scale,y=258*reg_scale, image=C3ButtonStyle.graphics[1], scale=reg_scale,
			Text { x=0,y=0,w=kMax,h=kMax, label="#"..GetString("cancel"), font={buttonFont[1], buttonFont[2]*reg_scale, buttonFont[3]}, flags=kVAlignCenter+kHAlignCenter }, },
	},
}