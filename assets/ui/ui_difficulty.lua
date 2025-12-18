--[[---------------------------------------------------------------------------
	Chocolatier Three: Difficulty Selection Dialog (Polished Version)
	MOD (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local titleFont = { uiFontName, 24, BlackColor } -- Use the cursive font for the title
local difficultyFont = { labelFontName, 22, BlackColor }

-- This local variable will store the player's selection within this dialog
local selectedDifficulty = 1 -- Default to Easy

-------------------------------------------------------------------------------
-- UI LOGIC FUNCTIONS
-------------------------------------------------------------------------------

-- This function updates the indicator lights based on the current selection
local function UpdateSelectionVisuals()
	-- First, set all lights to their blank/off state
	SetBitmap("easy_light", "image/indicatorlight_blank")
	SetBitmap("medium_light", "image/indicatorlight_blank")
	SetBitmap("hard_light", "image/indicatorlight_blank")

	-- Then, turn on the currently selected one
	if selectedDifficulty == 1 then
		SetBitmap("easy_light", "image/indicatorlight_green")
	elseif selectedDifficulty == 2 then
		SetBitmap("medium_light", "image/indicatorlight_yellow")
	elseif selectedDifficulty == 3 then
		SetBitmap("hard_light", "image/indicatorlight_red")
	end
end

-- This function is called when a difficulty button is clicked
local function SelectDifficulty(level)
	selectedDifficulty = level
	UpdateSelectionVisuals() -- Update the UI to show the new selection
end

-- This function is called ONLY when the "Ok" button is pressed
local function okFunction()
	-- Close the window and return the final selected difficulty
	FadeCloseWindow("difficulty_select", selectedDifficulty)
end

-------------------------------------------------------------------------------
-- UI CONSTRUCTION
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="difficulty_select",
		x=1000,y=kCenter,image="image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x=20,y=42,w=459,h=50, label="#"..GetString"difficulty_prompt", font=titleFont, flags=kVAlignCenter+kHAlignCenter },
		
		-- Easy Button
		Button { x=kCenter-150, y=106, w=140, h=80, graphics={},
			command=function() SelectDifficulty(1) end,
			Group {
				Bitmap { x=kCenter, y=10, name="easy_light", image="image/indicatorlight_blank" },
				Text { x=kCenter, y=50, w=140, h=30, label="#"..GetString"difficulty_easy", font=difficultyFont, flags=kVAlignCenter+kHAlignCenter },
			}
		},

		-- Medium Button
		Button { x=kCenter, y=106, w=140, h=80, graphics={},
			command=function() SelectDifficulty(2) end,
			Group {
				Bitmap { x=kCenter, y=10, name="medium_light", image="image/indicatorlight_blank" },
				Text { x=kCenter, y=50, w=140, h=30, label="#"..GetString"difficulty_medium", font=difficultyFont, flags=kVAlignCenter+kHAlignCenter },
			}
		},

		-- Hard Button
		Button { x=kCenter+150, y=106, w=140, h=80, graphics={},
			command=function() SelectDifficulty(3) end,
			Group {
				Bitmap { x=kCenter, y=10, name="hard_light", image="image/indicatorlight_blank" },
				Text { x=kCenter, y=50, w=140, h=30, label="#"..GetString"difficulty_hard", font=difficultyFont, flags=kVAlignCenter+kHAlignCenter },
			}
		},
		
		SetStyle(C3ButtonStyle),
		Button { x=113,y=237, name="ok", label="done", command=okFunction, default=true },
		Button { x=256,y=237, name="cancel", label="cancel", command=function() FadeCloseWindow("difficulty_select", nil) end, cancel=true },
	}
}

CenterFadeIn("difficulty_select")

-- Call this once at the end to set the initial visual state (Easy selected)
UpdateSelectionVisuals()