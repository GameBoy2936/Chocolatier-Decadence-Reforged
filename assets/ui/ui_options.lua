--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Options Settings)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

SliderFont = { labelFontName, 16, BlackColor }

-------------------------------------------------------------------------------
-- Audio & Display Operations
-------------------------------------------------------------------------------

-- Persists the master audio sliders to the engine's config file upon exit
local function okFunction()
	DebugOut("UI", "Options OK button clicked. Saving volume profiles to registry.")
	SaveVolumes()
	FadeCloseWindow("optionsmenu", "ok")
end

-- Triggers the C++ function to force a display bounds change
local function ToggleFullscreen()
	local success = ToggleFullScreen()
	
	if success then
		DebugOut("UI", "Fullscreen toggle successful.")
	else
		DebugOut("ERROR", "Fullscreen toggle failed. Target monitor resolution might be incompatible.")
		DisplayDialog { "ui/ui_generic.lua", text = "screenswitchfailed" }
	end
end

local function MuteSound()
	ToggleSoundMute()
	DebugOut("UI", "Master audio Mute toggled.")
end

-------------------------------------------------------------------------------
-- Content Links
-------------------------------------------------------------------------------

local function ReplayIntro()
	DebugOut("UI", "Replay Intro button clicked. Triggering splash sequence.")
	
	SoundEvent("Stop_Music")
	DisplaySplash("splash/intro_movie.swf", "splash/playfirst_logo", 0)

	-- If triggered from the main menu, resume the main menu track.
	-- If triggered in-game, it will resume normally upon exit.
	if gDialogTable.mainmenu then
		SoundEvent("main_menu")
	end
end

local function ShowCredits()
	DebugOut("UI", "Credits button clicked. Spooling text sequence.")
	DoModal("ui/ui_credits.lua")
end

local function ShowLanguages()
	DebugOut("UI", "Language selector button clicked.")
	DisplayDialog { "ui/ui_language.lua" }
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	name = "optionsmenu",
	Bitmap
	{
		name = "options",
		x = 1000, y = kCenter, image = "image/popup_back_generic_1",

		-- Render dynamic options layer for Engine bindings
		OptionsWindow
		{
			x = 0, y = 0, w = kMax, h = kMax,
			
			-- Sound Mixers
			SetStyle(C3DialogBodyStyle),
			Text { x = 30, y = 40, w = 100, h = 40, name = "sfx", label = "#" .. GetString("sfxlevel"), font = SliderFont, flags = kHAlignCenter + kVAlignCenter },
			Text { x = 30, y = 80, w = 100, h = 40, name = "music", label = "#" .. GetString("musiclevel"), font = SliderFont, flags = kHAlignCenter + kVAlignCenter },
			Text { x = 30, y = 120, w = 100, h = 40, name = "ambient", label = "#" .. GetString("ambientlevel"), font = SliderFont, flags = kHAlignCenter + kVAlignCenter },

			SetStyle(SliderStyle),
			Slider { x = 134, y = 40, w = 270, name = "sfxlevelslider" },
			Slider { x = 134, y = 80, w = 270, name = "musiclevelslider" },
			Slider { x = 134, y = 120, w = 270, name = "ambientlevelslider" },

			-- Toggles
			SetStyle(C3SmallRoundButtonStyle),
			AppendStyle { font = C3DialogBodyStyle.font },
			
			Button { x = 74, y = 155, name = "fullscreen", type = kToggle, command = ToggleFullscreen },
			Text { x = 135, y = 180, w = 150, h = 32, label = "#" .. GetString("fullscreen") },
			
			Button { x = 249, y = 155, name = "mutebox", type = kToggle, command = MuteSound },
			Text { x = 310, y = 180, w = 175, h = 32, label = "#" .. GetString("mutesound") },

			-- Content Sub-Menus
			SetStyle(C3ButtonStyle),
			Button { x = kCenter - 133, y = 230, name = "replay_intro", label = "replay_intro", command = ReplayIntro },
			Button { x = kCenter, y = 230, name = "credits", label = "credits", type = kPush, command = ShowCredits },
			Button { x = kCenter + 133, y = 230, name = "language", label = "language", type = kPush, command = ShowLanguages },
		},
		
		-- Finalize OK Button
		AppendStyle(C3RoundButtonStyle),
		Button { x = 445, y = 251, name = "ok", command = okFunction, label = "ok", default = true, cancel = true },
	},
}

CenterFadeIn("options")