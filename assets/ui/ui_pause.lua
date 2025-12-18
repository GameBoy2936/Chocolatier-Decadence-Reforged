--[[---------------------------------------------------------------------------
	Chocolatier Three: Pause dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

Player:SaveGame()

local function okFunction()
	if ResumeTravel then ResumeTravel() end
	FadeCloseWindow("pause", "ok")
	gUIPaused = false
end

if PauseTravel then PauseTravel() end

-- Use the same font styles as the difficulty selection screen for consistency
local titleFont = { labelFontName, 24, BlackColor }
local difficultyFont = { labelFontName, 20, BlackColor }

-- This function updates the visual state of the three indicator lights
local function UpdateDifficultyButtons()
    local currentDifficulty = Player.difficulty or 1
    SetBitmap("difficulty_easy_light", "image/indicatorlight_blank")
    SetBitmap("difficulty_medium_light", "image/indicatorlight_blank")
    SetBitmap("difficulty_hard_light", "image/indicatorlight_blank")

    if currentDifficulty == 1 then
        SetBitmap("difficulty_easy_light", "image/indicatorlight_green")
    elseif currentDifficulty == 2 then
        SetBitmap("difficulty_medium_light", "image/indicatorlight_yellow")
    elseif currentDifficulty == 3 then
        SetBitmap("difficulty_hard_light", "image/indicatorlight_red")
    end
end

-- This function is called when a difficulty button is clicked
local function SetDifficulty(level)
    if Player.difficulty ~= level then
        Player.difficulty = level
        DebugOut("PLAYER", "Difficulty changed to: " .. level)
        UpdateDifficultyButtons()
        -- Recalculate prices immediately to reflect the change
        if Player:GetPort() then
            Player:RecalculatePricesForCurrentPort()
        end
    end
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="pause",
		x=1000,y=kCenter, image="image/popup_back_generic_2",
		
		-- Left Column: Difficulty Settings
		Window { x=30, y=45, w=180, h=240,
            Text { x=kCenter, y=20, w=kMax, h=40, label="#"..GetString"difficulty", font=titleFont, flags=kVAlignCenter+kHAlignCenter },
            
            -- Easy Button
            Button { x=kCenter, y=55, w=150, h=50, graphics={},
                command=function() SetDifficulty(1) end,
                Group {
                    Bitmap { x=10, y=kCenter, name="difficulty_easy_light", image="image/indicatorlight_blank" },
                    Text { x=45, y=kCenter, w=160, h=30, label="#"..GetString"difficulty_easy", font=difficultyFont, flags=kVAlignCenter+kHAlignLeft },
                }
            },
            -- Medium Button
            Button { x=kCenter, y=100, w=150, h=50, graphics={},
                command=function() SetDifficulty(2) end,
                Group {
                    Bitmap { x=10, y=kCenter, name="difficulty_medium_light", image="image/indicatorlight_blank" },
                    Text { x=45, y=kCenter, w=160, h=30, label="#"..GetString"difficulty_medium", font=difficultyFont, flags=kVAlignCenter+kHAlignLeft },
                }
            },
            -- Hard Button
            Button { x=kCenter, y=145, w=150, h=50, graphics={},
                command=function() SetDifficulty(3) end,
                Group {
                    Bitmap { x=10, y=kCenter, name="difficulty_hard_light", image="image/indicatorlight_blank" },
                    Text { x=45, y=kCenter, w=160, h=30, label="#"..GetString"difficulty_hard", font=difficultyFont, flags=kVAlignCenter+kHAlignLeft },
                }
            },
        },

        -- Right Column: Game Menu Buttons
		SetStyle(C3ButtonStyle),
		Button { x=kCenter+25,y=95, name="options", label="options", command=function() DisplayDialog { "ui/ui_options.lua" } end },
		Button { x=kCenter+152,y=117.5, name="high_scores", label="high_scores", command=function() DisplayDialog { "ui/hiscore.lua" } end },
		Button { x=kCenter+25,y=140, name="help", label="help", command=function() HelpDialog() end},
		Button { x=kCenter+152,y=162.5, name="main_menu", label="main_menu", command=function() SwapToModal("ui/mainmenu.lua") end },
		Button { x=kCenter+25,y=185, name="resume_game", label="resume_game", command=okFunction, cancel=true },

		SetStyle(C3SmallRoundButtonStyle),
--[[
		AppendStyle { font=C3DialogBodyStyle.font },
		Button { x=40,y=65, label="1", command=function() Player:LoadGameFromFile("usability_1.choco3") end },
		Button { x=40,y=100, label="2", command=function() Player:LoadGameFromFile("usability_2.choco3") end },
		Button { x=40,y=135, label="3", command=function() Player:LoadGameFromFile("usability_3.choco3") end },
]]--
--		Button { x=40,y=205, label="#D", command=function() if (gDebugMenu == 0) then gDebugMenu = 1 else gDebugMenu = 0 end; SwapToModal("ui/mapview.lua"); end },
	}
}

if gTravelActive then EnableWindow("main_menu", false) end

CenterFadeIn("pause")
gUIPaused = true
UpdateDifficultyButtons()