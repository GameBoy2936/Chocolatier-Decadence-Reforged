--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]--------------------------------------------------------------------------

-- Right now, this is using 128x128 images and scaling them
-- so the big "Story Mode" button is 150x150 and the smaller buttons are 90x90
-- If the final art is that size, just change these numbers:
local largeButtonSize = 150		-- this could be 150
local smallButtonSize = 128		-- this could be 90

-- { UP button image, DOWN button image, ROLLOVER button image }
local storyButton = { "image/button_mm_story_up","image/button_mm_story_down","image/button_mm_story_over" }
local changeButton = { "image/button_mm_change_up","image/button_mm_change_down","image/button_mm_change_over" }
local helpButton = { "image/button_mm_help_up","image/button_mm_help_down","image/button_mm_help_over" }
local optionsButton = { "image/button_mm_options_up","image/button_mm_options_down","image/button_mm_options_over" }
local scoresButton = { "image/button_mm_scores_up","image/button_mm_scores_down","image/button_mm_scores_over" }
local quitButton =  { "image/button_mm_quit_up","image/button_mm_quit_down","image/button_mm_quit_over" }
local moreButton = C3ButtonStyle.graphics

local function OutlineLabel(k)
	return "<outline color='000000' size=2>"..GetString(k)
end

local f1 = { uiFontName, 40, WhiteColor }
local f3 = { uiFontName, 22, WhiteColor }

-------------------------------------------------------------------------------

function Update()
	if GetNumUsers() == 0 then
		EnableWindow("welcome", false)
		EnableWindow("choose_player", false)
		EnableWindow("choose_player_disable", true)
		EnableWindow("choose_label", false)
	else
		local playerName = GetCurrentUserName()
		local welcomeText = GetString("welcome", playerName)
		SetLabel("welcome", welcomeText)

		EnableWindow("welcome", true)
		EnableWindow("choose_player", true)
		EnableWindow("choose_player_disable", false)
		EnableWindow("choose_label", true)
	end

	if not CheckConfig("xsell") then
		EnableWindow("xsell", false)
--		EnableWindow("xsell_label", false)
	end
end

-------------------------------------------------------------------------------

local function LaunchGameSequence()
	SetCurrentGameMode(0)
	
	local q = _AllQuests["tut_01"]
	if q:IsComplete() or q:IsActive() then
		SwapToModal("ui/mapview.lua")
	else
--			SetState("IntroMovieTime",1)		-- FIRST PEEK
		SoundEvent("Stop_Music")
		-- DisplaySplash("splash/intro_movie.swf", "splash/playfirst_logo",0)
--			SetState("IntroMovieTime",0)		-- FIRST PEEK
		
		SoundEvent("zurich_sting")			-- Zurich music
		SoundEvent("zurich")				-- Zurich environment
		SwapToModal("ui/portview.lua")
		q:Offer(main_alex, zur_station)
	end
end

function StoryMode()
	-- Case 1: New User
	if GetNumUsers() == 0 then
		local name = DisplayDialog { "ui/ui_entername.lua" }
		if name then
			local difficultyChoice = DisplayDialog { "ui/ui_difficulty.lua" }
			if difficultyChoice then 
				CreateNewUser(name)
				Player:Reset()
				Player.name = GetCurrentUserName()
				Player.stringTable.player = Player.name
				Player.difficulty = difficultyChoice
				Player:SetPort("zurich")
				Player:SaveGame()
			end 
		end
	end
	
	-- Case 2: User exists (Load the game with transition)
	if GetNumUsers() > 0 then
        -- 1. Disable input
        gButtonsDisabled = true
        SoundEvent("ui_click") 
        
        -- 2. Fade out visuals
        FadeOut { "game_logo", time=500 }
        FadeOut { "welcome", time=500 }
        FadeOut { "copyright", time=500 }
        FadeOut { "buttons", time=500 }

        -- 3. Fade out the background, then launch
        FadeOut { 
            "main_background", 
            time=500, 
            onend = function() 
                gButtonsDisabled = false
                LaunchGameSequence() 
            end 
        }
	end
end

function ChangePlayer()
	DisplayDialog { "ui/ui_changeplayer.lua" }
	Update()
end

function Options()
	DisplayDialog { "ui/ui_options.lua", mainmenu=true }
end

function Help()
	HelpDialog(nil,true)
end

function HighScores()
--	DisplayDialog { "ui/ui_highscore.lua" }
	DisplayDialog { "ui/hiscore.lua" }
end


-------------------------------------------------------------------------------

MakeDialog
{
	name="mainmenu",
	Bitmap
	{
        name="main_background",
		image="image/title_background", x=kScreenCenterX,y=kScreenCenterY, w=kScreenWidth,h=kScreenHeight,
		fit=false,
		
        Bitmap { name="game_logo", image="image/title_logo", x=kCenter, y=000, flags=kHAlignCenter+kVAlignCenter },
		
		SetStyle(C3ButtonStyle),
--[[
		Button { x=kCenter,y=200, label="story_mode", command=StoryMode },
		Button { x=kCenter,y=245, label="change_player", command=ChangePlayer },
		Button { x=kCenter,y=290, label="options", command=Options },
		Button { x=kCenter,y=335, label="help", command=Help },
		Button { x=kCenter,y=380, label="high_scores", command=HighScores },
		Button { x=kCenter,y=425, label="quit", command=AskQuit },
]]--
		Window { x=0,y=0,w=kMax,h=kMax, name="buttons", fit=true,
			AppendStyle { rolloversound="sfx/main_rollover.ogg" },
			Button { x=400-75,y=315-75+30, scale=150/largeButtonSize, graphics=storyButton, command=StoryMode },
			Button { x=117-45,y=417-45, scale=90/smallButtonSize, graphics=changeButton, name="choose_player", command=ChangePlayer},
			Bitmap { x=117-45,y=417-45, scale=90/smallButtonSize, image="image/button_mm_change_inactive", name="choose_player_disable", },
			Button { x=250-45,y=455-45, scale=90/smallButtonSize, graphics=helpButton, command=Help},
--			Button { x=457-45,y=475-45, scale=90/smallButtonSize, graphics=helpButton, command=Help},
			Button { x=400-45,y=475-45, scale=90/smallButtonSize, graphics=scoresButton, command=HighScores},
			Button { x=550-45,y=455-45, scale=90/smallButtonSize, graphics=optionsButton, command=Options},
			Button { x=683-45,y=417-45, scale=90/smallButtonSize, graphics=quitButton, command=AskQuit},
--			Button { x=80-45*.8,y=520-45*.8, scale=90/smallButtonSize, graphics=moreButton, name="xsell", command=function() DoModal("xsell/xsell.lua") end },
			Button { x=5,y=550, graphics=moreButton, name="xsell", label="moregames", command=function() DoModal("xsell/xsell.lua") end },

			Text { x=400-100,y=320+32+30, w=200,h=kMax, label="#"..OutlineLabel("story_mode"), flags=kVAlignTop+kHAlignCenter, font=f1 },
			Text { x=117-100,y=417+32, w=200,h=kMax, label="#"..OutlineLabel("change_player"), name="choose_label", flags=kVAlignTop+kHAlignCenter, font=f3 },
			Text { x=250-100,y=455+32, w=200,h=kMax, label="#"..OutlineLabel("help"), flags=kVAlignTop+kHAlignCenter, font=f3 },
--			Text { x=457-100,y=475+32, w=200,h=kMax, label="#"..OutlineLabel("help"), flags=kVAlignTop+kHAlignCenter, font=f3 },
			Text { x=400-100,y=475+32, w=200,h=kMax, label="#"..OutlineLabel("high_scores"), flags=kVAlignTop+kHAlignCenter, font=f3 },
			Text { x=550-100,y=455+32, w=200,h=kMax, label="#"..OutlineLabel("options"), flags=kVAlignTop+kHAlignCenter, font=f3 },
			Text { x=683-100,y=417+32, w=200,h=kMax, label="#"..OutlineLabel("quit"), flags=kVAlignTop+kHAlignCenter, font=f3 },
--			Text { x=0,y=550+32*.8, w=160,h=kMax, label="#"..OutlineLabel("moregames"), name="xsell_label", flags=kVAlignTop+kHAlignCenter, font=f3 },
		},
	

		Text { x=0,y=560, w=kMax,h=20, name="welcome", flags=kHAlignCenter + kVAlignBottom,
			font = { uiFontName, 20, WhiteColor },
			},
		Text { x=0,y=580, w=kMax,h=20, name="copyright", label="#"..GetString("copyright"), flags=kHAlignCenter + kVAlignBottom,
			font = { uiFontName, 15, WhiteColor },
			},
	}
}

-------------------------------------------------------------------------------
-- STARTUP ANIMATION SEQUENCE
-------------------------------------------------------------------------------

-- 1. Initialize Audio
SoundEvent("Stop_Environments")
SoundEvent("main_menu")

-- 2. Prepare UI for Transition
-- Disable input immediately
gButtonsDisabled = true

-- Instantly hide everything (Alpha 0)
FadeOut { "main_background", time=0 }
FadeOut { "buttons", time=0 }
FadeOut { "game_logo", time=0 }
FadeOut { "welcome", time=0 }
FadeOut { "copyright", time=0 }

-- 3. Queue the Animation Sequence
QueueCommand(function()
    -- Fade in Background
    FadeIn { "main_background", time=1000 }

    -- Fade in Logo & Copyright
    FadeIn { "game_logo", time=1000 }
    FadeIn { "copyright", time=1000 }
    
    -- Fade in Welcome Text
    FadeIn { "welcome", time=1000 }
    
    -- Fade in Buttons and enable input
    FadeIn { 
        "buttons", 
        time=800, 
        onend = function() 
            -- Update() logic runs HERE to ensure button states (visible/hidden)
            -- are applied correctly AFTER the fade-in of the parent container.
            Update() 
            
            -- Re-enable input
            gButtonsDisabled = false 
        end 
    }
end)