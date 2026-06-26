--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (UI Stylesheet)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script defines the global constants, colors, typography, and custom UI 
-- widget constructors used by the C++ Engine to render dialogs.

-------------------------------------------------------------------------------
-- 1. Screen Geometry & Layout Constants
-------------------------------------------------------------------------------

kScreenCenterX = (kScreenWidth - kGameWidth) / 2
kScreenCenterY = (kScreenHeight - kGameHeight) / 2
kLedgerPositionX = kScreenCenterX + 3
kLedgerPositionY = kScreenCenterY + 329

kItemSize = 32
kItemBigSize = 64

-------------------------------------------------------------------------------
-- 2. Input Validation Rulesets
-------------------------------------------------------------------------------

kIgnoreBadProductNameChars = "!@#$%^&*()><\\\"\'[]{}|?/+=~`.,;:-"
kIllegalNameChars = "!@#$%^&*()><\\\"\'[]{}|?/+=~`.,;:-"
kIllegalProductChars = "><\\\""
kNumbersOnly = "`~!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/¡¢£¤¥¦§¨©ª«¬®¯°±´µ¶·¸º»÷×¿ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"

-------------------------------------------------------------------------------
-- 3. Color Palettes
-------------------------------------------------------------------------------

BlackColor = Color(0, 0, 0, 255)
WhiteColor = Color(255, 255, 255, 255)
BlueColor = Color(77, 115, 178, 255)
DarkBlueColor = Color(40, 60, 120, 255)
MaroonColor = Color(79, 9, 9, 255)

rolloverColor = Color(255, 215, 171, 255)
marketColor = Color(160, 210, 121, 255)
shopColor = Color(191, 127, 171, 255)
characterColor = Color(157, 87, 115, 255)
fadeDialogColor = Color(217, 165, 134, 0)
dialogColor = Color(217, 165, 134, 255)
MenuButtonFontColor = Color(255, 255, 255, 255)

-- Dynamic Haggle UI Colors
local HaggleGreenColor = { 74, 160, 8 }
local HaggleRedColor = { 193, 12, 12 }

-- Synthesize standard HTML Hex color tags for dynamic string injection
BetterPriceColor = string.format("<font color='%02x%02x%02x'>", HaggleGreenColor[1], HaggleGreenColor[2], HaggleGreenColor[3])
WorsePriceColor = string.format("<font color='%02x%02x%02x'>", HaggleRedColor[1], HaggleRedColor[2], HaggleRedColor[3])

-------------------------------------------------------------------------------
-- 4. Typography & Font Stacks
-------------------------------------------------------------------------------

-- Fallback to the universally configured UI font if specific labels are undefined
labelFontName = labelFontName or "fonts/choco3.mvec"
standardFont = standardFont or "fonts/fertigo.mvec"
uiFontName = standardFont 

dialogFont = { standardFont, 30, BlackColor }
ScoreFont = { standardFont, 20, WhiteColor }
StandardButtonFont = { standardFont, 18, BlackColor }
MenuButtonFont = { standardFont, 22, MenuButtonFontColor }
DialogTitleFont = { standardFont, 20, BlackColor }
DialogBodyFont = { standardFont, 18, BlackColor }
DookieDropperFont = { standardFont, 14, BlackColor }
DookieDropperCounterFont = { standardFont, 14, WhiteColor }

dialogBodyFont = { uiFontName, 18, BlackColor }
characterBodyFont = { uiFontName, 16, BlackColor }
rolloverInfoFont = { uiFontName, 18, BlackColor }

characterNameFont = { labelFontName, 12, Color(164, 23, 5, 255) }
characterNameSmallFont = { labelFontName, 7.5, Color(164, 23, 5, 255) }

nameplateFont = { labelFontName, 30, Color(255, 255, 255, 255) }
portLabelFont = { uiFontName, 18, BlackColor }
factoryStatusFont = { labelFontName, 20, BlackColor }
portNameRolloverFont = { labelFontName, 18, Color(208, 208, 208, 255) }

roundButtonFont = { labelFontName, 17, BlackColor }
buttonFont = { uiFontName, 17, BlackColor }

questUnselectedFont = { uiFontName, 16, Color(0, 0, 0, 255) }
questSelectedFont = { uiFontName, 18, Color(0, 0, 0, 255) }

jukeboxCategoryFont = { labelFontName, 13, BlackColor }
jukeboxCategoryHighlightFont = { labelFontName, 13, WhiteColor }

mapPortButtonFont = { labelFontName, 25, Color(206, 206, 206, 255) }
mapPortButtonHighlightFont = { labelFontName, 25, WhiteColor }

LedgerButtonFont = { labelFontName, 25, BlackColor }
LedgerButtonHighlightFont = { labelFontName, 25, WhiteColor }
LedgerButtonDownFont = { labelFontName, 25, Color(212, 0, 0, 255) }
LedgerButtonLabelFont = { uiFontName, 15, BlackColor }

SmallLedgerButtonFont = { labelFontName, 18, BlackColor }
SmallLedgerButtonHighlightFont = { labelFontName, 18, WhiteColor }
SmallLedgerButtonDownFont = { labelFontName, 18, Color(212, 0, 0, 255) }
SmallLedgerButtonLabelFont = { uiFontName, 15, BlackColor }

-------------------------------------------------------------------------------
-- 5. Base UI Styles
-------------------------------------------------------------------------------

DefaultStyle = { font = DialogBodyFont }

-- Force global fallback mappings for missing properties
SetDefaultStyle(DefaultStyle)

DialogTitleText = {
	parent = DefaultStyle,
	font = DialogTitleFont,
	flags = kVAlignCenter + kHAlignLeft,
	x = 16, y = 12, w = kMax, h = 30
}

DialogBodyText = {
	parent = DefaultStyle,
	font = DialogBodyFont,
	flags = kVAlignCenter + kHAlignCenter,
	x = 0, y = 46, w = kMax, h = kMax - 60
}

SliderStyle = {
	parent = DefaultStyle,
	railtop = "slider/sliderrailtop",
	railmid = "slider/sliderrailmid",
	railbot = "slider/sliderrailbot",
	sliderimage = "slider/sliderknob",
	sliderrollimage = "slider/sliderknobover",
	yoffset = -1, -- Shift the slider down by one pixel to center it vertically
}

devMenuStyle = {
	font = { "fonts/arial.mvec", 14, BlackColor },
	graphics = {}, type = kPush, flags = kHAlignLeft + kVAlignTop,
}

-------------------------------------------------------------------------------
-- 6. Button Graphics & Archetypes
-------------------------------------------------------------------------------

StandardButtonGraphics = {
	"controls/buttonup",
	"controls/buttondown",
	"controls/buttonrollover"
}

LongButtonGraphics = {
	"hiscore/long_button_up.png",
	"hiscore/long_button_down.png",
	"hiscore/long_button_over.png"
}

CheckboxButtonGraphics = {
	"controls/checkup",
	"controls/checkdown",
	"controls/checkover",
	"controls/checkdownover"
}

MenucontrolStyle = {
	parent = DefaultStyle,
	font = MenuButtonFont,
	sound = kDefaultcontrolSound,
	graphics = {},
	w = 169, h = 40
}

controlStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	sound = kDefaultcontrolSound,
	type = kPush,
	graphics = StandardButtonGraphics,
}

LongcontrolStyle = {
	parent = controlStyle,
	graphics = LongButtonGraphics
}

CheckboxcontrolStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	type = kToggle,
	sound = kDefaultcontrolSound,
	graphics = CheckboxButtonGraphics,
}

MenuButtonStyle = {
	parent = DefaultStyle,
	font = MenuButtonFont,
	sound = kDefaultButtonSound,
	graphics = {},
	w = 169, h = 40
}

ButtonStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	sound = kDefaultButtonSound,
	type = kPush,
	graphics = StandardButtonGraphics,
}

LongButtonStyle = {
	parent = ButtonStyle,
	graphics = LongButtonGraphics
}

CheckboxButtonStyle = {
	parent = DefaultStyle,
	font = StandardButtonFont,
	type = kToggle,
	sound = kDefaultButtonSound,
	graphics = CheckboxButtonGraphics,
	tx = 28,
}

-- Custom Game Button Styles

C3ButtonStyle = {
	parent = DefaultStyle,
	font = buttonFont,
	highlightfont = buttonHighlightFont,
	type = kPush,
	graphics = { "controls/button_generic_up", "controls/button_generic_down", "controls/button_generic_over", "controls/button_generic_down" },
	sound = "cadi/ui_click.ogg",
}

C3ButtonMediumGraphics = { "controls/button_generic_medium_up", "controls/button_generic_medium_down", "controls/button_generic_medium_over", "controls/button_generic_medium_down" }
C3ButtonLongGraphics = { "controls/button_generic_long_up", "controls/button_generic_long_down", "controls/button_generic_long_over", "controls/button_generic_long_down" }
C3ButtonExtraLongGraphics = { "controls/button_generic_extralong_up", "controls/button_generic_extralong_down", "controls/button_generic_extralong_over", "controls/button_generic_extralong_down" }

C3ButtonMediumStyle = { parent = C3ButtonStyle, graphics = C3ButtonMediumGraphics, sound = "cadi/ui_click.ogg" }
C3ButtonLongStyle = { parent = C3ButtonStyle, graphics = C3ButtonLongGraphics, sound = "cadi/ui_click.ogg" }
C3ButtonExtraLongStyle = { parent = C3ButtonStyle, graphics = C3ButtonExtraLongGraphics, sound = "cadi/ui_click.ogg" }

C3RoundButtonStyle = {
	parent = DefaultStyle,
	font = roundButtonFont,
	type = kPush,
	graphics = { "image/button_generic_round_up", "image/button_generic_round_down", "image/button_generic_round_over", "image/button_generic_round_down" },
	mask = "image/button_generic_round_clickmask",
	sound = "cadi/ui_click.ogg",
}

C3SmallRoundButtonStyle = {
	parent = DefaultStyle,
	font = roundButtonFont,
	type = kPush,
	graphics = { "image/button_round_small_up", "image/button_round_small_selected", "image/button_round_small_over", "image/button_round_small_selected" },
	mask = "image/button_round_small_clickmask",
	sound = "cadi/ui_click.ogg",
}

C3LargeRoundButtonStyle = {
	parent = DefaultStyle,
	font = buttonFont,
	highlightfont = buttonHighlightFont,
	type = kPush,
	graphics = { "image/button_round_large_up", "image/button_round_large_selected", "image/button_round_large_over", "image/button_round_large_selected" },
	mask = "image/button_round_large_clickmask",
	sound = "cadi/ui_click.ogg",
}

C3DialogBodyStyle = {
	parent = DefaultStyle,
	font = dialogBodyFont,
	flags = kVAlignCenter + kHAlignLeft,
}

C3CharacterDialogStyle = {
	parent = DefaultStyle,
	font = characterBodyFont,
	flags = kVAlignCenter + kHAlignLeft,
}

C3CharacterNameStyle = {
	parent = DefaultStyle,
	font = characterNameFont,
	flags = kVAlignCenter + kHAlignCenter,
}

-------------------------------------------------------------------------------
-- 7. Custom Visual Elements & Helper Constructs
-------------------------------------------------------------------------------

-- Compresses text within a rigid container box
function TightText(t)
	return function()
		t.typename = "TightText"
		t.w = 800
		t.h = 600
		DoWindow(t)
	end
end

-- Generates multiple layers of text to artificially create a drop-shadow effect
function ColorShadowText(x, y, size, label, color)
	return Group(
		{
			AppendStyle{ x = x, y = y, w = kMax, h = kMax, label = label },
			AppendStyle{ font = { standardFont, size, Color(0, 0, 0, 40) } },
			Text{ y = y + 4 },
			AppendStyle{ font = { standardFont, size, Color(0, 0, 0, 255) } },
			Text{ y = y + 2 },
			AppendStyle{ font = { standardFont, size, color } } ,
			Text{},
		}
	)
end

local kMenuButtonFontSize = 22

function MenuButtonLabel(label, color, colorHighlight)
	if not color then
		color = Color(192, 207, 255, 255)
		colorHighlight = Color(255, 255, 255, 255)
	end

	return Group{
		Bitmap { image = "backgrounds/bar", x = 0, y = 0, scale = 1 },
		SelectLayer(0), ColorShadowText(5, 8, kMenuButtonFontSize, label, color),
		SelectLayer(1), ColorShadowText(5, 8, kMenuButtonFontSize, label, colorHighlight),
		SelectLayer(2), ColorShadowText(5, 8, kMenuButtonFontSize, label, colorHighlight)
	}
end

function MenuButton(button)
	return function()
		button.typename = 'Button'
		DoWindow(button)
	end
end

-------------------------------------------------------------------------------
-- 8. Core Game UI Widget Constructors
-------------------------------------------------------------------------------
-- These constructors wrap the base C++ Engine UI elements, injecting custom 
-- layers, dynamic stroke/outlines, logging hooks, and multi-state logic.

function PlaygroundButton(button)
	return function()
		if GetTag(button, "label") then
			local tx = GetTag(button, "tx") or 0
			local ty = GetTag(button, "ty") or 0
			local tw = GetTag(button, "tw") or kMax
			local th = GetTag(button, "th") or kMax
			local label = GetTag(button, "label")

			local defflags = kPushButtonAlignment
			if GetTag(button, "type") == kToggle then defflags = kToggleButtonAlignment
			elseif GetTag(button, "type") == kRadio then defflags = kRadioButtonAlignment end

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, FitToChildren())
			table.insert(button, AppendStyle{ font = button.font; flags = button.flags })
			table.insert(button, Text { label = label, x = tx, y = ty, w = tw, h = th, name = 'label', defflags = defflags })
		end
		
		button.typename = 'Button'
		DoWindow(button)
	end
end

-- Overrides the standard global Button constructor to inject automatic DebugOut 
-- logging hooks, and handles dynamic text outline rendering for highlights.
function Button(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			-- Intercept the command to inject global console logging for telemetry
			local btnLogName = GetTag(button, "name") or GetTag(button, "label") or "Unnamed"
			
			button.command = function() 
				if not gButtonsDisabled then 
					DebugOut("UI", string.format("UI Interaction: Button '%s' triggered.", tostring(btnLogName)))
					command() 
				end 
			end
		end
		
		local label = GetTag(button, "label")
		if label then
			local labelString = GetString(label)
			if labelString == "#####" then labelString = label end
			
			local tx = GetTag(button, "tx") or 0
			local ty = GetTag(button, "ty") or 0
			local tw = GetTag(button, "tw") or kMax
			local th = GetTag(button, "th") or kMax

			local defflags = kPushButtonAlignment
			if GetTag(button, "type") == kToggle then defflags = kToggleButtonAlignment
			elseif GetTag(button, "type") == kRadio then defflags = kRadioButtonAlignment end
			
			local font = GetTag(button, "font")
			local highlightfont = GetTag(button, "highlightfont")

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, FitToChildren())
			table.insert(button, AppendStyle{ font = button.font, flags = button.flags })
			
			-- Render stroke outline underneath text for hover states
			if highlightfont then 
				table.insert(button, Text { x = tx, y = ty, w = tw, h = th, name = 'highlight', defflags = defflags, label = "#<outline color='ffffff' size=2>" .. labelString, font = highlightfont }) 
			end
			table.insert(button, Text { x = tx, y = ty, w = tw, h = th, name = 'label', defflags = defflags, label = "#" .. labelString, font = font })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

-- The top tabs in the Recipe Book UI
function JukeboxCategoryButton(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			local btnLogName = GetTag(button, "name") or "JukeboxTab"
			button.command = function() 
				if not gButtonsDisabled then 
					DebugOut("UI", string.format("UI Interaction: Category Tab '%s' triggered.", tostring(btnLogName)))
					command() 
				end 
			end
		end
		
		local label = GetTag(button, "label")
		if label then
			label = GetString(label)
			local tx = GetTag(button, "tx") or 0
			local ty = GetTag(button, "ty") or 0
			local tw = GetTag(button, "tw") or kMax
			local th = GetTag(button, "th") or kMax

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, AppendStyle { x = tx, y = ty + 14, w = tw, h = th, defflags = kVAlignCenter + kHAlignCenter, font = jukeboxCategoryFont })
			
			-- State 0: Normal
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name = "label", label = "#" .. label })
			
			-- State 1: Down
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y = ty + 20, name = "label", label = "#<outline color='ffffff' size=2>" .. label, font = jukeboxCategoryHighlightFont })
			table.insert(button, Text{ y = ty + 20, name = "label", label = "#" .. label })
			
			-- State 2: Hover Over
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name = "label", label = "#" .. label })
			
			-- State 3: Selected Lock
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y = ty + 20, name = "label", label = "#<outline color='ffffff' size=2>" .. label, font = jukeboxCategoryHighlightFont })
			table.insert(button, Text{ y = ty + 20, name = "label", label = "#" .. label })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

-- The left-hand navigation list items inside the Quest Log
function QuestSelectButton(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			local btnLogName = GetTag(button, "name") or "QuestSelector"
			button.command = function() 
				if not gButtonsDisabled then 
					DebugOut("UI", string.format("UI Interaction: Quest Selector '%s' triggered.", tostring(btnLogName)))
					command() 
				end 
			end
		end

		local label = GetTag(button, "label")
		if label then
			local tx = GetTag(button, "tx") or 0
			local ty = GetTag(button, "ty") or 0
			local tw = GetTag(button, "tw") or kMax
			local th = GetTag(button, "th") or kMax

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, AppendStyle { defflags = kVAlignCenter + kHAlignLeft })
			
			-- Apply dynamic unselected/selected font shifting
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ x = tx + 27, y = ty, w = tw, h = th, name = "label0", label = "#" .. label, font = questUnselectedFont })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ x = tx + 3, y = ty, w = tw, h = th, name = "label1", label = "#" .. label, font = questSelectedFont })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ x = tx + 27, y = ty, w = tw, h = th, name = "label2", label = "#" .. label, font = questUnselectedFont })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ x = tx + 3, y = ty, w = tw, h = th, name = "label3", label = "#" .. label, font = questSelectedFont })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

-- The toggle button transitioning between World Map and Local Port views
function MapPortButton(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			button.command = function() 
				if not gButtonsDisabled then 
					DebugOut("UI", "UI Interaction: Map/Port toggle triggered.")
					command() 
				end 
			end
		end
		
		local label = GetTag(button, "label")
		if label then
			label = GetString(label)
			local tx = GetTag(button, "tx") or 12
			local ty = GetTag(button, "ty") or 51
			local tw = GetTag(button, "tw") or 125
			local th = GetTag(button, "th") or 39

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, AppendStyle { x = tx, y = ty, w = tw, h = th, defflags = kVAlignCenter + kHAlignCenter, font = mapPortButtonFont })
			
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name = "label", label = "#<outline color='2f2f2f' size=1>" .. label })
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y = ty + 2, name = "label", label = "#" .. label })
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name = "label", label = "#<outline color='ffffff' size=1>" .. label })
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y = ty + 2, name = "label", label = "#" .. label })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

-- The primary navigation tabs on the Global Ledger (Inventory, Quests, Recipes)
function LargeLedgerButton(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			local btnLogName = GetTag(button, "label") or "LargeLedger"
			button.command = function() 
				if not gButtonsDisabled then 
					DebugOut("UI", string.format("UI Interaction: Ledger Button '%s' triggered.", tostring(btnLogName)))
					command() 
				end 
			end
		end
		
		local labelKey = GetTag(button, "label")
		if labelKey then
			local label = GetString(labelKey)
			
			-- -----------------------------------------------------
			-- UI Localized Monogram Evaluation
			-- -----------------------------------------------------
			-- Looks for a specific localized "_letter" string in the XML.
			-- E.g., The "Inventory" button needs to display an 'I' inside the badge. 
			-- If translated to French ("Inventaire"), it falls back smoothly to grabbing 
			-- the first letter of the translated string automatically.
			local letter = GetString(labelKey .. "_letter")
			if letter == "#####" then
				label = string.upper(label)
				letter = string.sub(label, 1, 1)
			end
			
			local tx = GetTag(button, "tx") or 32
			local ty = GetTag(button, "ty") or 39
			local tw = GetTag(button, "tw") or 45
			local th = GetTag(button, "th") or 45

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, AppendStyle { x = tx, y = ty, w = tw, h = th, defflags = kVAlignCenter + kHAlignCenter, font = LedgerButtonFont })
			
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name = "label", label = "#<outline color='ffffff' size=1>" .. letter })
			
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y = ty + 2, name = "label", label = "#<outline color='000000' size=1>" .. letter, font = LedgerButtonDownFont })
			
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name = "label", label = "#<outline color='000000' size=1>" .. letter, font = LedgerButtonHighlightFont })
			table.insert(button, Text{ x = 9, y = 12, w = 89, h = 20, name = "full", label = "#" .. label, font = LedgerButtonLabelFont })
			
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y = ty + 2, name = "label", label = "#" .. letter })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

-- The secondary navigation tabs on the Global Ledger (Menu, Medals, Catalogue)
function SmallLedgerButton(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			local btnLogName = GetTag(button, "label") or "SmallLedger"
			button.command = function() 
				if not gButtonsDisabled then 
					DebugOut("UI", string.format("UI Interaction: Ledger Menu Button '%s' triggered.", tostring(btnLogName)))
					command() 
				end 
			end
		end
		
		local labelKey = GetTag(button, "label")
		if labelKey then
			local label = GetString(labelKey)

			-- Dynamically resolve the internal monogram letter for the badge icon
			local letter = GetString(labelKey .. "_letter")
			if letter == "#####" then
				label = string.upper(label)
				letter = string.sub(label, 1, 1)
			end
			
			local tx = GetTag(button, "tx") or 24
			local ty = GetTag(button, "ty") or 36
			local tw = GetTag(button, "tw") or 55
			local th = GetTag(button, "th") or 55

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, AppendStyle { x = tx, y = ty, w = tw, h = th, defflags = kVAlignCenter + kHAlignCenter, font = SmallLedgerButtonFont })
			
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ name = "label", label = "#<outline color='ffffff' size=1>" .. letter })
			
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ y = ty + 2, name = "label", label = "#<outline color='000000' size=1>" .. letter, font = SmallLedgerButtonDownFont })
			
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ name = "label", label = "#<outline color='000000' size=1>" .. letter, font = SmallLedgerButtonHighlightFont })
			table.insert(button, Text{ x = 6, y = 20, w = 89, h = 20, name = "full", label = "#" .. label, font = SmallLedgerButtonLabelFont })
			
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ y = ty + 2, name = "label", label = "#" .. letter })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

DebugOut("LOAD", "Global UI Stylesheet parsed and injected successfully.")