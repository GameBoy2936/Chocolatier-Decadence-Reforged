--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Factory Configuration Content)
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- This script renders the dynamic inner-window content inside the main factory UI.

local factory = gCurrentFactory
local count, current = factory:GetProduction()

-------------------------------------------------------------------------------
-- Formatting Setup
-------------------------------------------------------------------------------

local countFont = { uiFontName, 50, Color(255, 41, 77) }

-- Coffee blends require a slightly different vertical alignment due to their sprite shape
local currentAlignment = kHAlignCenter + kVAlignBottom
if current and current:GetMachinery().name == "blend" then 
	currentAlignment = kHAlignCenter + kVAlignCenter 
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	x = 0, y = 0, w = kMax, h = kMax, fit = true,
	SetStyle(C3CharacterDialogStyle),

	-- Performance Timer / Gauge Face
	Bitmap { 
		x = 147, y = 60, w = 128, h = 128, name = "timer_face", image = "image/timer_face", scale = 128/148,
		Bitmap { image = "image/timer_hand", scale = 128/148 },
		Text { x = 0, y = 32, w = 128, h = 64, flags = kVAlignTop + kHAlignCenter, label = "#" .. GetString("cases"), font = { uiFontName, 18, Color(255, 1, 17) } },
		Text { x = 0, y = 0, w = 128, h = 128, name = "current_count", label = "#" .. tostring(count), flags = kHAlignCenter + kVAlignCenter, font = countFont },
		Text { x = 0, y = 80, w = 128, h = 20, label = "#" .. GetString("cases_per"), flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 12, Color(255, 1, 17) } },
	},

	-- Product Icon and Label
	current:GetAppearanceHuge(7, 50),
	Text { x = 7, y = 0, w = 276, h = 20, label = "#" .. GetString("now_making"), flags = kHAlignCenter + kVAlignCenter },
	Text { x = 7, y = 20, w = 276, h = 40, name = "current_product", label = "#" .. current:GetName(), flags = currentAlignment, font = factoryStatusFont },
}