--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Difficulty Selector)
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local titleFont = { uiFontName, 24, BlackColor } 
local difficultyFont = { labelFontName, 22, BlackColor }

-- Internal state tracking the current selection before the player confirms it
local selectedDifficulty = 1 -- 1 = Easy, 2 = Medium, 3 = Hard

-------------------------------------------------------------------------------
-- Interface Logic
-------------------------------------------------------------------------------

-- Visually updates the radio-button-style lights based on the current active selection.
local function UpdateSelectionVisuals()
	SetBitmap("easy_light", "image/indicatorlight_blank")
	SetBitmap("medium_light", "image/indicatorlight_blank")
	SetBitmap("hard_light", "image/indicatorlight_blank")

	if selectedDifficulty == 1 then
		SetBitmap("easy_light", "image/indicatorlight_green")
	elseif selectedDifficulty == 2 then
		SetBitmap("medium_light", "image/indicatorlight_yellow")
	elseif selectedDifficulty == 3 then
		SetBitmap("hard_light", "image/indicatorlight_red")
	end
end

-- Invoked when clicking the button row.
local function SelectDifficulty(level)
	selectedDifficulty = level
	UpdateSelectionVisuals() 
end

-- Invoked when the player officially confirms their choice.
local function okFunction()
	DebugOut("UI", string.format("Difficulty selected: Tier %d", selectedDifficulty))
	FadeCloseWindow("difficulty_select", selectedDifficulty)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "difficulty_select",
		x = 1000, y = kCenter, image = "image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x = 20, y = 42, w = 459, h = 50, label = "#" .. GetString("difficulty_prompt"), font = titleFont, flags = kVAlignCenter + kHAlignCenter },
		
		-- Tier 1: Easy (Standard)
		Button { 
			x = kCenter - 150, y = 106, w = 140, h = 80, graphics = {},
			command = function() SelectDifficulty(1) end,
			Group {
				Bitmap { x = kCenter, y = 10, name = "easy_light", image = "image/indicatorlight_blank" },
				Text { x = kCenter, y = 50, w = 140, h = 30, label = "#" .. GetString("difficulty_easy"), font = difficultyFont, flags = kVAlignCenter + kHAlignCenter },
			}
		},

		-- Tier 2: Medium (10%-25% tougher economy margins)
		Button { 
			x = kCenter, y = 106, w = 140, h = 80, graphics = {},
			command = function() SelectDifficulty(2) end,
			Group {
				Bitmap { x = kCenter, y = 10, name = "medium_light", image = "image/indicatorlight_blank" },
				Text { x = kCenter, y = 50, w = 140, h = 30, label = "#" .. GetString("difficulty_medium"), font = difficultyFont, flags = kVAlignCenter + kHAlignCenter },
			}
		},

		-- Tier 3: Hard (Aggressive, predatory economy constraints)
		Button { 
			x = kCenter + 150, y = 106, w = 140, h = 80, graphics = {},
			command = function() SelectDifficulty(3) end,
			Group {
				Bitmap { x = kCenter, y = 10, name = "hard_light", image = "image/indicatorlight_blank" },
				Text { x = kCenter, y = 50, w = 140, h = 30, label = "#" .. GetString("difficulty_hard"), font = difficultyFont, flags = kVAlignCenter + kHAlignCenter },
			}
		},
		
		SetStyle(C3ButtonStyle),
		Button { x = 113, y = 237, name = "ok", label = "done", command = okFunction, default = true },
		Button { x = 256, y = 237, name = "cancel", label = "cancel", command = function() FadeCloseWindow("difficulty_select", nil) end, cancel = true },
	}
}

CenterFadeIn("difficulty_select")

-- Force initial visual initialization
UpdateSelectionVisuals()