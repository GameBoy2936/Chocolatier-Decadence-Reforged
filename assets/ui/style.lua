--[[---------------------------------------------------------------------------
	Chocolatier Three: UI Stylesheet
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

kScreenCenterX = (kScreenWidth - kGameWidth) / 2
kScreenCenterY = (kScreenHeight - kGameHeight) / 2
kLedgerPositionX = kScreenCenterX + 3
kLedgerPositionY = kScreenCenterY + 329

local HaggleGreenColor = {74,160,8}
local HaggleRedColor = {193,12,12}
BetterPriceColor = string.format("<font color='%02x%02x%02x'>", HaggleGreenColor[1], HaggleGreenColor[2], HaggleGreenColor[3])
WorsePriceColor = string.format("<font color='%02x%02x%02x'>", HaggleRedColor[1], HaggleRedColor[2], HaggleRedColor[3])

kItemSize = 32
kItemBigSize = 64

kIgnoreBadProductNameChars = "!@#$%^&*()><\\\"\'[]{}|?/+=~`.,;:-"
kNumbersOnly = "`~!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/¡¢£¤¥¦§¨©ª«¬®¯°±´µ¶·¸º»÷×¿ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"

function TightText( t )
	return function()
		t.typename = "TightText";
		t.w = 800
		t.h = 600
		DoWindow(t)
	end
end

rolloverColor = Color(255,215,171,255)
marketColor = Color(160,210,121,255)
shopColor = Color(191,127,171,255)
characterColor = Color(157,87,115,255)
fadeDialogColor = Color(217,165,134,0)
dialogColor = Color(217,165,134,255)

labelFontName = labelFontName or "fonts/choco3.mvec"
standardFont = standardFont or "fonts/fertigo.mvec"

BlackColor = Color(0,0,0,255);
BlueColor = Color(77,115,178,255);
DarkBlueColor = Color(40,60,120,255);
WhiteColor = Color(255,255,255,255);
MenuButtonFontColor = Color(255,255,255,255);

DookieDropperFont = { standardFont, 14, BlackColor };
DookieDropperCounterFont = { standardFont, 14, WhiteColor };

devMenuStyle =
{
	font = { "fonts/arial.mvec", 14, BlackColor },
	graphics = {}, type=kPush, flags=kHAlignLeft+kVAlignTop,
}

StandardButtonGraphics = {
	"controls/buttonup",
	"controls/buttondown",
	"controls/buttonrollover"
};

LongButtonGraphics = {
	"hiscore/long_button_up.png",
	"hiscore/long_button_down.png",
	"hiscore/long_button_over.png"
};

CheckboxButtonGraphics = {
	"controls/checkup",
	"controls/checkdown",
	"controls/checkover",
	"controls/checkdownover"
};

dialogFont = {
  standardFont,
  30,
  BlackColor
};

ScoreFont = {
  standardFont,
  20,
  WhiteColor
};

StandardButtonFont = {
  standardFont,
  18,
  BlackColor
};

MenuButtonFont = {
  standardFont,
  22,
  MenuButtonFontColor
};

DialogTitleFont = {
  standardFont,
  20,
  BlackColor
};

DialogBodyFont = {
  standardFont,
  18,
  BlackColor
};

DefaultStyle = {
	font=DialogBodyFont
};

DialogTitleText = {
	parent=DefaultStyle,
	font = DialogTitleFont,
	flags = kVAlignCenter + kHAlignLeft,
	x=16,y=12,w=kMax,h=30
};

DialogBodyText = {
	parent=DefaultStyle,
	font = DialogBodyFont,
	flags = kVAlignCenter + kHAlignCenter,
	x=0,y=46,w=kMax,h=kMax-60
};

SliderStyle =
{
	parent=DefaultStyle,
	railtop = "slider/sliderrailtop",
	railmid = "slider/sliderrailmid",
	railbot = "slider/sliderrailbot",
	sliderimage = "slider/sliderknob",
	sliderrollimage = "slider/sliderknobover",

	yoffset = -1, -- scoot the slider down by one pixel to center it.
};

--kDefaultcontrolSound="audio/sfx/buttonclick.ogg";

MenucontrolStyle = {
	parent = DefaultStyle,
	font = MenuButtonFont,
	sound = kDefaultcontrolSound,
	graphics = {},
	w=169, h=40
};

controlStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	sound = kDefaultcontrolSound,
	type= kPush,
	graphics = StandardButtonGraphics,
};

LongcontrolStyle = {
	parent = controlStyle,
	graphics = LongButtonGraphics
};

CheckboxcontrolStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	type = kToggle,
	sound = kDefaultcontrolSound,
	graphics = CheckboxButtonGraphics,
};

MenuButtonStyle = {
	parent = DefaultStyle,
	font = MenuButtonFont,
	sound = kDefaultButtonSound,
	graphics = {},
	w=169, h=40
};

ButtonStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	sound = kDefaultButtonSound,
	type= kPush,
	graphics = StandardButtonGraphics,
};

LongButtonStyle = {
	parent = ButtonStyle,
	graphics = LongButtonGraphics
};

CheckboxButtonStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	type = kToggle,
	sound = kDefaultButtonSound,
	graphics = CheckboxButtonGraphics,
	tx=28,
};

SetDefaultStyle(DefaultStyle);

-- Create a TButton with a label
--
-- We're overriding the default "Button" here with
-- some custom behavior. Specifically, we're layering
-- a Text{} object on top of every button, and it's placed
-- on all layers (up, down, roll-over).
function PlaygroundButton( button )
	return function()
		-- Grab the label from the button or current style
		if (GetTag(button,"label")) then

			-- Look for text dimensions
			local tx = GetTag(button,"tx");
			local ty = GetTag(button,"ty");
			local tw = GetTag(button,"tw");
			local th = GetTag(button,"th");

			-- Set defaults
			if (not tx) then
				tx = 0;
			end
			if (not ty) then
				ty = 0;
			end
			if (not tw) then
				tw=kMax ;
			end
			if (not th) then
				th=kMax ;
			end

			-- Get the label
			local label = GetTag(button,"label");

			local defflags = kPushButtonAlignment ;
			if (GetTag(button,"type")==kToggle) then
				defflags = kToggleButtonAlignment ;
			elseif (GetTag(button,"type")==kRadio) then
				defflags = kRadioButtonAlignment ;
			end

			local textfactory = GetTag(button,"textfactory");
			if (not textfactory) then
				textfactory = "_text"
			end
			table.insert(button,
				SelectLayer( kAllLayers )
			);
			-- Grow our window to encompass any children we've added
			-- already.
			table.insert(button,
				FitToChildren()
			);

			table.insert(button,
				AppendStyle{ font=button.font; flags=button.flags; }
			);

			table.insert(button,
				Text
				{
					label=label,
					x=tx, y=ty, w=tw, h=th,
					name='label',
					defflags =defflags
				}
			)
		end

		-- Type name of window to create; in our case, "Button".
		-- If you want to create a derived button type, you can do that here.
		button.typename='Button';
		DoWindow( button )
	end
end

-- Create several bits of text that combine to make a blended shadow
function ColorShadowText( x,y,size, label, color )
	return Group(
		{
		-- Add these traits to the current style
			AppendStyle{ x=x, y=y, w=kMax, h=kMax, label=label },
			AppendStyle{ font = { standardFont, size, Color(0,0,0,40)} },
			Text{ y=y+4 },
			AppendStyle{ font = { standardFont, size, Color(0,0,0,255)} },
			Text{ y=y+2 },
			AppendStyle{ font = { standardFont, size, color } } ,
			Text{},
		}
	)
end

kMenuButtonFontSize = 22;

function MenuButtonLabel( label, color, colorHighlight )

	if not color then
		color =Color(192,207,255,255);	-- the default colors
		colorHighlight=Color(255,255,255,255)
	end

	return Group{
		Bitmap
		{
			image="backgrounds/bar",
			x=0,y=0,scale=1
		},
		SelectLayer(0),
		ColorShadowText(5,8,kMenuButtonFontSize, label, color ),
		SelectLayer(1),
		ColorShadowText(5,8,kMenuButtonFontSize, label, colorHighlight ),
		SelectLayer(2),
		ColorShadowText(5,8,kMenuButtonFontSize, label, colorHighlight )
	}

end

-- Create a more limited-use button type here; the label is defined inline
-- with MenuButtonLabel above
function MenuButton( button )
	return function()
		-- Type name of window to create; in our case, "Button".
		-- If you want to create a derived button type, you can do that here.
		button.typename='Button';
		DoWindow( button )
	end
end

------------------------------------------------------------------------------

kIllegalNameChars = "!@#$%^&*()><\\\"\'[]{}|?/+=~`.,;:-"
kIllegalProductChars = "><\\\""

------------------------------------------------------------------------------

--uiFontName = "fonts/arial.mvec"
--uiFontName = "fonts/fertigo.mvec"
--labelFontName = "fonts/airconditioner.mvec"
--labelFontName = "fonts/hoodornament.mvec"
--labelFontName = "fonts/choco3.mvec"
uiFontName = standardFont -- Use the font stack
-- labelFontName = labelFontName -- Use the font stack

BlackColor = Color(0,0,0,255)
MaroonColor = Color(79,9,9,255)

dialogBodyFont = { uiFontName, 18, BlackColor }
characterBodyFont = { uiFontName, 16, BlackColor }
rolloverInfoFont = { uiFontName, 18, BlackColor }

--characterNameFont = { labelFontName, 18, Color(164,23,5,255) }
--characterNameFont = { labelFontName, 15, Color(164,23,5,255) }
characterNameFont = { labelFontName, 12, Color(164,23,5,255) }
--characterNameSmallFont = { labelFontName, 8, Color(164,23,5,255) }
characterNameSmallFont = { labelFontName, 7.5, Color(164,23,5,255) }
--nameplateFont = { labelFontName, 38, Color(255,255,255,255)}
nameplateFont = { labelFontName, 30, Color(255,255,255,255)}

factoryStatusFont = { labelFontName, 20, BlackColor }
--portNameRolloverFont = { labelFontName, 22, Color(208,208,208,255) }
portNameRolloverFont = { labelFontName, 18, Color(208,208,208,255) }

--roundButtonFont = { labelFontName, 18, BlackColor }
roundButtonFont = { labelFontName, 17, BlackColor }

--buttonFont = { uiFontName, 18, BlackColor }
buttonFont = { uiFontName, 17, BlackColor }
--buttonHighlightFont = nil
--buttonHighlightFont = { labelFontName, 16, WhiteColor }
questUnselectedFont = { uiFontName, 16, Color(0,0,0,255)}
questSelectedFont = { uiFontName, 18, Color(0,0,0,255)}

--jukeboxCategoryFont = { labelFontName, 16, BlackColor }
--jukeboxCategoryHighlightFont = { labelFontName, 16, WhiteColor }
jukeboxCategoryFont = { labelFontName, 13, BlackColor }
jukeboxCategoryHighlightFont = { labelFontName, 13, WhiteColor }

mapPortButtonFont = { labelFontName, 25, Color(206,206,206,255) }
mapPortButtonHighlightFont = { labelFontName, 25, WhiteColor }

LedgerButtonFont = { labelFontName, 25, BlackColor }
LedgerButtonHighlightFont = { labelFontName, 25, WhiteColor }
LedgerButtonDownFont = { labelFontName, 25, Color(212,0,0,255) }
LedgerButtonLabelFont = { uiFontName, 15, BlackColor }

SmallLedgerButtonFont = { labelFontName, 18, BlackColor }
SmallLedgerButtonHighlightFont = { labelFontName, 18, WhiteColor }
SmallLedgerButtonDownFont = { labelFontName, 18, Color(212,0,0,255) }
SmallLedgerButtonLabelFont = { uiFontName, 15, BlackColor }

C3ButtonStyle =
{
	parent = DefaultStyle,
	font = buttonFont,
	highlightfont = buttonHighlightFont,
	type= kPush,
	graphics = { "controls/button_generic_up","controls/button_generic_down","controls/button_generic_over","controls/button_generic_down" },
	sound = "cadi/ui_click.ogg",
}

C3ButtonMediumGraphics = { "controls/button_generic_medium_up","controls/button_generic_medium_down","controls/button_generic_medium_over","controls/button_generic_medium_down" }
C3ButtonLongGraphics = { "controls/button_generic_long_up","controls/button_generic_long_down","controls/button_generic_long_over","controls/button_generic_long_down" }
C3ButtonExtraLongGraphics = { "controls/button_generic_extralong_up","controls/button_generic_extralong_down","controls/button_generic_extralong_over","controls/button_generic_extralong_down" }

C3ButtonMediumStyle = {
	parent = C3ButtonStyle,
	graphics = C3ButtonMediumGraphics,
	sound = "cadi/ui_click.ogg",
}

C3ButtonLongStyle = {
	parent = C3ButtonStyle,
	graphics = C3ButtonLongGraphics,
	sound = "cadi/ui_click.ogg",
}

C3ButtonExtraLongStyle = {
	parent = C3ButtonStyle,
	graphics = C3ButtonExtraLongGraphics,
	sound = "cadi/ui_click.ogg",
}

C3RoundButtonStyle =
{
	parent = DefaultStyle,
	font = roundButtonFont,
	type= kPush,
	graphics = { "image/button_generic_round_up","image/button_generic_round_down","image/button_generic_round_over","image/button_generic_round_down" },
	mask = "image/button_generic_round_clickmask",
	sound = "cadi/ui_click.ogg",
}

C3SmallRoundButtonStyle =
{
	parent = DefaultStyle,
	font = roundButtonFont,
	type= kPush,
	graphics = { "image/button_round_small_up","image/button_round_small_selected","image/button_round_small_over","image/button_round_small_selected" },
	mask = "image/button_round_small_clickmask",
	sound = "cadi/ui_click.ogg",
}

C3LargeRoundButtonStyle =
{
	parent = DefaultStyle,
	font = buttonFont,
	highlightfont = buttonHighlightFont,
	type= kPush,
	graphics = { "image/button_round_large_up","image/button_round_large_selected","image/button_round_large_over","image/button_round_large_selected" },
	mask = "image/button_round_large_clickmask",
	sound = "cadi/ui_click.ogg",
}

C3DialogBodyStyle =
{
	parent = DefaultStyle,
	font = dialogBodyFont,
	flags = kVAlignCenter + kHAlignLeft,
}

C3CharacterDialogStyle =
{
	parent = DefaultStyle,
	font = characterBodyFont,
	flags = kVAlignCenter + kHAlignLeft,
}

C3CharacterNameStyle =
{
	parent = DefaultStyle,
	font = characterNameFont,
	flags = kVAlignCenter + kHAlignCenter,
}

------------------------------------------------------------------------------

function Button( button )
	return function()
		local command = GetTag(button,"command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end
		
		-- Grab the label from the button or current style
		local label = GetTag(button,"label")
		if label then
			local labelString = GetString(label)
			if labelString == "#####" then labelString = label end
			
			-- Look for text dimensions
			local tx = GetTag(button,"tx") or 0
			local ty = GetTag(button,"ty") or 0
			local tw = GetTag(button,"tw") or kMax
			local th = GetTag(button,"th") or kMax

			local defflags = kPushButtonAlignment
			if (GetTag(button,"type")==kToggle) then
				defflags = kToggleButtonAlignment
			elseif (GetTag(button,"type")==kRadio) then
				defflags = kRadioButtonAlignment
			end
			
			local font = GetTag(button, "font")
			local highlightfont = GetTag(button, "highlightfont")

			local textfactory = GetTag(button,"textfactory") or "_text"
			table.insert(button, SelectLayer( kAllLayers ) )
			table.insert(button, FitToChildren())
			table.insert(button, AppendStyle{ font=button.font, flags=button.flags } )
			if highlightfont then table.insert(button, Text { x=tx,y=ty, w=tw,h=th, name='highlight', defflags=defflags, label="#<outline color='ffffff' size=2>"..labelString, font=highlightfont } ) end
			table.insert(button, Text { x=tx,y=ty, w=tw,h=th, name='label', defflags=defflags, label="#"..labelString, font=font } )
		end

		-- Type name of window to create; in our case, "Button".
		-- If you want to create a derived button type, you can do that here.
		button.typename='Button'
		DoWindow( button )
	end
end

function JukeboxCategoryButton( button )
	return function()
		local command = GetTag(button,"command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end
		
		-- Grab the label from the button or current style
		local label = GetTag(button,"label")
		if label then
			label = GetString(label)
			
			-- Look for text dimensions
			local tx = GetTag(button,"tx") or 0
			local ty = GetTag(button,"ty") or 0
			local tw = GetTag(button,"tw") or kMax
			local th = GetTag(button,"th") or kMax

			local defflags = kPushButtonAlignment
			if (GetTag(button,"type")==kToggle) then
				defflags = kToggleButtonAlignment
			elseif (GetTag(button,"type")==kRadio) then
				defflags = kRadioButtonAlignment
			end

			local textfactory = GetTag(button,"textfactory") or "_text"

			-- Text in layers
			table.insert(button, SelectLayer( kAllLayers ))
			table.insert(button, AppendStyle { x=tx,y=ty+14, w=tw,h=th, defflags=kVAlignCenter+kHAlignCenter, font=jukeboxCategoryFont })
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name="label", label="#"..label })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y=ty+20, name="label", label="#<outline color='ffffff' size=2>"..label, font=jukeboxCategoryHighlightFont })
			table.insert(button, Text{ y=ty+20, name="label", label="#"..label })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name="label", label="#"..label })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y=ty+20, name="label", label="#<outline color='ffffff' size=2>"..label, font=jukeboxCategoryHighlightFont })
			table.insert(button, Text{ y=ty+20, name="label", label="#"..label })
		end

		button.typename='Button'
		DoWindow( button )
	end
end

function QuestSelectButton( button )
	return function()
		local command = GetTag(button,"command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end

		-- Grab the label from the button or current style
		local label = GetTag(button,"label")
		if label then
			-- Look for text dimensions
			local tx = GetTag(button,"tx") or 0
			local ty = GetTag(button,"ty") or 0
			local tw = GetTag(button,"tw") or kMax
			local th = GetTag(button,"th") or kMax

			local defflags = kPushButtonAlignment
			if (GetTag(button,"type")==kToggle) then
				defflags = kToggleButtonAlignment
			elseif (GetTag(button,"type")==kRadio) then
				defflags = kRadioButtonAlignment
			end

			local textfactory = GetTag(button,"textfactory") or "_text"

			-- Text in layers
			table.insert(button, SelectLayer( kAllLayers ))
			table.insert(button, AppendStyle { defflags=kVAlignCenter+kHAlignLeft })
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ x=tx+27,y=ty, w=tw,h=th, name="label0", label="#"..label, font=questUnselectedFont })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ x=tx+3,y=ty, w=tw,h=th, name="label1", label="#"..label, font=questSelectedFont })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ x=tx+27,y=ty, w=tw,h=th, name="label2", label="#"..label, font=questUnselectedFont })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ x=tx+3,y=ty, w=tw,h=th, name="label3", label="#"..label, font=questSelectedFont })
		end

		button.typename='Button'
		DoWindow( button )
	end
end

function MapPortButton( button )
	return function()
		local command = GetTag(button,"command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end
		
		-- Grab the label from the button or current style
		local label = GetTag(button,"label")
		if label then
			label = GetString(label)
			
			-- Look for text dimensions
			local tx = GetTag(button,"tx") or 12
			local ty = GetTag(button,"ty") or 51
			local tw = GetTag(button,"tw") or 125
			local th = GetTag(button,"th") or 39

			-- Text in layers
			table.insert(button, SelectLayer( kAllLayers ))
			table.insert(button, AppendStyle { x=tx,y=ty, w=tw,h=th, defflags=kVAlignCenter+kHAlignCenter, font=mapPortButtonFont })
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name="label", label="#<outline color='2f2f2f' size=1>"..label })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y=ty+2, name="label", label="#"..label })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name="label", label="#<outline color='ffffff' size=1>"..label })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y=ty+2, name="label", label="#"..label })
		end

		button.typename='Button'
		DoWindow( button )
	end
end

function LargeLedgerButton( button )
	return function()
		local command = GetTag(button,"command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end
		
		-- Grab the label from the button or current style
		local labelKey = GetTag(button,"label")
		if labelKey then
			local label = GetString(labelKey)
			
			-- Look for a specific "_letter" string.
			-- If it exists, use it. If not, fall back to the old behavior for English.
			local letter = GetString(labelKey .. "_letter")
			if letter == "#####" then
				label = string.upper(label)
				letter = string.sub(label,1,1)
			end
			
			-- Look for text dimensions
			local tx = GetTag(button,"tx") or 32
			local ty = GetTag(button,"ty") or 39
			local tw = GetTag(button,"tw") or 45
			local th = GetTag(button,"th") or 45

			-- Text in layers
			table.insert(button, SelectLayer( kAllLayers ))
			table.insert(button, AppendStyle { x=tx,y=ty, w=tw,h=th, defflags=kVAlignCenter+kHAlignCenter, font=LedgerButtonFont })
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name="label", label="#<outline color='ffffff' size=1>"..letter })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y=ty+2, name="label", label="#<outline color='000000' size=1>"..letter, font=LedgerButtonDownFont })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name="label", label="#<outline color='000000' size=1>"..letter, font=LedgerButtonHighlightFont })
			table.insert(button, Text{ x=9,y=12,w=89,h=20, name="full", label="#"..label, font=LedgerButtonLabelFont, })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y=ty+2, name="label", label="#"..letter })
		end

		button.typename='Button'
		DoWindow( button )
	end
end

function SmallLedgerButton( button )
	return function()
		local command = GetTag(button,"command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end
		
		-- Grab the label from the button or current style
		local labelKey = GetTag(button,"label")
		if labelKey then
			local label = GetString(labelKey)

			-- Look for a specific "_letter" string.
			local letter = GetString(labelKey .. "_letter")
			if letter == "#####" then
				label = string.upper(label)
				letter = string.sub(label,1,1)
			end
			
			-- Look for text dimensions
			local tx = GetTag(button,"tx") or 24
			local ty = GetTag(button,"ty") or 36
			local tw = GetTag(button,"tw") or 55
			local th = GetTag(button,"th") or 55

			-- Text in layers
			table.insert(button, SelectLayer( kAllLayers ))
			table.insert(button, AppendStyle { x=tx,y=ty, w=tw,h=th, defflags=kVAlignCenter+kHAlignCenter, font=SmallLedgerButtonFont })
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name="label", label="#<outline color='ffffff' size=1>"..letter })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y=ty+2, name="label", label="#<outline color='000000' size=1>"..letter, font=SmallLedgerButtonDownFont })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name="label", label="#<outline color='000000' size=1>"..letter, font=SmallLedgerButtonHighlightFont })
			table.insert(button, Text{ x=6,y=20,w=89,h=20, name="full", label="#"..label, font=SmallLedgerButtonLabelFont, })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y=ty+2, name="label", label="#"..letter })
		end

		button.typename='Button'
		DoWindow( button )
	end
end