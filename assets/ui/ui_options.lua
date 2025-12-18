--[[---------------------------------------------------------------------------
	Chocolatier Three Options Dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

SliderFont = {
  labelFontName,
  16,
  BlackColor
};

-------------------------------------------------------------------------------

function okFunction()
    DebugOut("UI", "Options OK button clicked. Saving volume settings.")
	SaveVolumes()
	FadeCloseWindow("optionsmenu", "ok")
end

local function ReplayIntro()
    DebugOut("UI", "Replay Intro button clicked.")
--	SetState("IntroMovieTime",1)		-- FIRST PEEK
	SoundEvent("Stop_Music")
	DisplaySplash("splash/intro_movie.swf", "splash/playfirst_logo",0)
--	SetState("IntroMovieTime",0)		-- FIRST PEEK

	if gDialogTable.mainmenu then
		SoundEvent("main_menu")
	end
end

local function ToggleFullscreen()
    local success = ToggleFullScreen()
    DebugOut("UI", "Fullscreen toggled. Success: " .. tostring(success))
    if not success then
        DisplayDialog { "ui/ui_generic.lua", text ="screenswitchfailed" }
    end
end

local function MuteSound()
    -- We get the state *before* toggling to know what action was taken.
    local wasMuted = IsSoundMuted()
    ToggleSoundMute()
    DebugOut("UI", "Mute All Sound toggled. Was muted: " .. tostring(wasMuted) .. ". Is now muted: " .. tostring(not wasMuted))
end

local function ShowCredits()
    DebugOut("UI", "Credits button clicked.")
    DoModal("ui/ui_credits.lua")
end

local function ShowLanguages()
    DebugOut("UI", "Language button clicked.")
    DisplayDialog("ui/ui_language.lua")
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="optionsmenu",
	Bitmap
	{
		name="options",
		x=1000,y=kCenter, image="image/popup_back_generic_1",

		OptionsWindow
		{
			x=0,y=0,w=kMax,h=kMax,
			SetStyle(C3DialogBodyStyle),
			Text { x=30,y=40,w=100,h=40, name = "sfx", label="#"..GetString"sfxlevel", font = SliderFont, flags = kHAlignCenter + kVAlignCenter, },
			Text { x=30,y=80,w=100,h=40, name = "music", label="#"..GetString"musiclevel", font = SliderFont, flags = kHAlignCenter + kVAlignCenter, },
			Text { x=30,y=120,w=100,h=40, name = "ambient", label="#"..GetString"ambientlevel", font = SliderFont, flags = kHAlignCenter + kVAlignCenter, },

			SetStyle(C3SmallRoundButtonStyle),
			AppendStyle { font=C3DialogBodyStyle.font },
			Button { x=74,y=155, name="fullscreen", type=kToggle,
				command = ToggleFullscreen
			},
			Text { x=135,y=180,w=150,h=32, label="#"..GetString("fullscreen"), },
			
			Button{ x=249,y=155, name="mutebox", command = MuteSound, type=kToggle },
			Text{ x=310,y=180, w=175,h=32, label = "#"..GetString("mutesound") },

			SetStyle(C3ButtonStyle),
			Button { x=kCenter-133,y=230, name="replay_intro", label="replay_intro",
				command=ReplayIntro},
			Button { x=kCenter,y=230, name="credits", label="credits", type = kPush,
				command = ShowCredits },
				
			Button { x=kCenter+133,y=230, name="language", label="language", type = kPush,
				command = function() DisplayDialog { "ui/ui_language.lua" } end },

			SetStyle(SliderStyle),
			Slider { x = 134, y = 40, w = 270, name="sfxlevelslider", },
			Slider { x = 134, y = 80, w = 270, name="musiclevelslider", },
			Slider { x = 134, y = 120, w = 270, name="ambientlevelslider", },
		},
		
		AppendStyle(C3RoundButtonStyle),
		Button { x=445,y=251, name="ok", command=okFunction, label="ok", default=true, cancel=true },
	},
}

CenterFadeIn("options")