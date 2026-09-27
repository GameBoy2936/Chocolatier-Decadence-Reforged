--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Main Menu)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- UI Styling & Scale Configuration
-------------------------------------------------------------------------------
-- The engine dynamically scales standard 128x128 UI assets to fit the specific
-- emphasis of the main menu (Story Mode is larger, secondary buttons are smaller).

-- Load Community transport with the main menu so bridge discovery starts early.
require("community/transport.lua")
ClearStringCache()

local largeButtonSize = 150
local smallButtonSize = 128

-- Button Image States: { UP, DOWN, ROLLOVER }
local storyButton   = { "image/button_mm_story_up", "image/button_mm_story_down", "image/button_mm_story_over" }
local freeButton    = { "image/button_mm_free_up", "image/button_mm_free_down", "image/button_mm_free_over" }
local changeButton  = { "image/button_mm_change_up", "image/button_mm_change_down", "image/button_mm_change_over" }
local helpButton    = { "image/button_mm_help_up", "image/button_mm_help_down", "image/button_mm_help_over" }
local optionsButton = { "image/button_mm_options_up", "image/button_mm_options_down", "image/button_mm_options_over" }
local scoresButton  = { "image/button_mm_scores_up", "image/button_mm_scores_down", "image/button_mm_scores_over" }
local quitButton    = { "image/button_mm_quit_up", "image/button_mm_quit_down", "image/button_mm_quit_over" }
local moreButton    = C3ButtonStyle.graphics

-- Helper function to generate standardized HTML outline tags for the menu labels
local function OutlineLabel(k)
	return "<outline color='000000' size=2>" .. GetString(k)
end

local f1 = { uiFontName, 40, WhiteColor }
local f3 = { uiFontName, 22, WhiteColor }

-------------------------------------------------------------------------------
-- State Evaluation & Updates
-------------------------------------------------------------------------------

-- Refreshes the active/inactive state of the menu buttons based on saved profiles
function Update()
	if GetNumUsers() == 0 then
		-- Free Play belongs to a Story profile, matching Chocolatier 1/2.
		EnableWindow("welcome", false)
		EnableWindow("choose_player", false)
		EnableWindow("choose_player_disable", true)
		EnableWindow("choose_label", false)
		EnableWindow("free_play", false)
		EnableWindow("free_play_disable", true)
		EnableWindow("free_play_label", false)
	else
		-- Profile exists. Greet the player and enable the roster switcher.
		local playerName = GetCurrentUserName()
		local welcomeText = GetString("welcome", playerName)
		SetLabel("welcome", welcomeText)

		EnableWindow("welcome", true)
		EnableWindow("choose_player", true)
		EnableWindow("choose_player_disable", false)
		EnableWindow("choose_label", true)
		EnableWindow("free_play", true)
		EnableWindow("free_play_disable", false)
		EnableWindow("free_play_label", true)
	end

	-- Legacy cross-sell promotional button
	if not CheckConfig("xsell") then
		EnableWindow("xsell", false)
	end
end

-------------------------------------------------------------------------------
-- Navigation & Action Handlers
-------------------------------------------------------------------------------

local function LaunchStorySequence()
	Player:SetGameMode("story")

	-- Check if the player is still in the Rank 1 Tutorial (Quest 01)
	local q = _AllQuests["tut_01"]
	if q:IsComplete() or q:IsActive() then
		-- Tutorial passed. Proceed to the standard World Map.
		DebugOut("UI", "Transitioning to World Map.")
		SwapToModal("ui/mapview.lua")
	else
		-- Tutorial active. Force them to the Zurich train station to meet Alex Fletcher.
		DebugOut("UI", "Transitioning to Tutorial Sequence in Zurich.")
		SoundEvent("Stop_Music")
		SoundEvent("zurich_sting")
		SoundEvent("zurich")
		SwapToModal("ui/portview.lua")

		QueueCommand(function()
			q:Offer(main_alex, zur_station)
		end)
	end
end

function StoryMode()
	DebugOut("UI", "'Story Mode' button clicked.")

	-- Case 1: First Time Player (No saved users exist)
	if GetNumUsers() == 0 then
		local name = DisplayDialog { "ui/ui_entername.lua" }

		if name then
			local difficultyChoice = DisplayDialog { "ui/ui_difficulty.lua" }
			if difficultyChoice then
				DebugOut("SAVE", string.format("Initializing new player profile: '%s' (Difficulty: %d)", name, difficultyChoice))
				CreateNewUser(name)
				Player:Reset()
				Player:SetGameMode("story")
				Player.name = GetCurrentUserName()
				Player.stringTable.player = Player.name
				Player.difficulty = difficultyChoice
				Player:SetPort("zurich")
				Player:SaveGame()
			end
		end
	end

	-- Case 2: User exists. If Free Play is currently active, save it first and
	-- restore this profile's separate Story slot.
	if GetNumUsers() > 0 then
		if Player:IsFreePlay() then
			Player:SaveGame()
			if not Player:LoadGame("story") then return end
		else
			Player:SetGameMode("story")
		end
		-- Disable input immediately to prevent double-clicking
		gButtonsDisabled = true
		SoundEvent("ui_click")

		-- Fade out the foreground UI elements
		FadeOut { "game_logo", time = 500 }
		FadeOut { "welcome", time = 500 }
		FadeOut { "copyright", time = 500 }
		FadeOut { "buttons", time = 500 }

		-- Fade out the background, then trigger the game launch script
		FadeOut {
			"main_background",
			time = 500,
			onend = function()
				gButtonsDisabled = false
				LaunchStorySequence()
			end
		}
	end
end

function FreePlayMode()
	DebugOut("UI", "'Free Play' button clicked.")
	if GetNumUsers() == 0 then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("freeplay_requires_story") }
		return
	end

	-- Save whichever mode is currently resident in memory, then load/create the
	-- Reforged-owned Free Play sidecar and synchronize Story unlocks one-way.
	Player:SaveGame()
	if not Player:LoadGame("free") then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("freeplay_requires_story") }
		return
	end
	-- Player:Reset() already reloads localized strings for the incoming save.
	SoundEvent("ui_click")
	gButtonsDisabled = true
	FadeOut { "game_logo", time = 500 }
	FadeOut { "welcome", time = 500 }
	FadeOut { "copyright", time = 500 }
	FadeOut { "buttons", time = 500 }
	FadeOut {
		"main_background", time = 500,
		onend = function()
			gButtonsDisabled = false
			SwapToModal("ui/mapview.lua")
		end
	}
end

function ChangePlayer()
	DebugOut("UI", "'Change Player' button clicked.")
	DisplayDialog { "ui/ui_changeplayer.lua" }
	Update()
end

function Options()
	DebugOut("UI", "'Options' button clicked.")
	DisplayDialog { "ui/ui_options.lua", mainmenu = true }
end

function Help()
	DebugOut("UI", "'Help' button clicked.")
	HelpDialog(nil, true)
end

function Community()
	DebugOut("UI", "'Community' button clicked.")
	DisplayDialog { "ui/community_hub.lua", source = "mainmenu" }
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	name = "mainmenu",
	Bitmap
	{
		name = "main_background",
		image = "image/title_background", x = kScreenCenterX, y = kScreenCenterY, w = kScreenWidth, h = kScreenHeight,
		fit = false,

		Bitmap { name = "game_logo", image = "image/title_logo", x = kCenter, y = 000, flags = kHAlignCenter + kVAlignCenter },

		SetStyle(C3ButtonStyle),

		Window {
			x = 0, y = 0, w = kMax, h = kMax, name = "buttons", fit = true,
			AppendStyle { rolloversound = "sfx/main_rollover.ogg" },

			-- Story and Free Play are separate saves under the same player profile.
			Button { x = 310 - 75, y = 315 - 75 + 30, scale = 150/largeButtonSize, graphics = storyButton, command = StoryMode },
			Button { x = 490 - 75, y = 315 - 75 + 30, graphics = freeButton, name = "free_play", command = FreePlayMode },
			Button { x = 117 - 45, y = 417 - 45, scale = 90/smallButtonSize, graphics = changeButton, name = "choose_player", command = ChangePlayer },

			-- Inactive Button Silhouettes
			Bitmap { x = 490 - 75, y = 315 - 75 + 30, image = "image/button_mm_free_disabled", name = "free_play_disable" },
			Bitmap { x = 117 - 45, y = 417 - 45, scale = 90/smallButtonSize, image = "image/button_mm_change_inactive", name = "choose_player_disable" },

			Button { x = 250 - 45, y = 455 - 45, scale = 90/smallButtonSize, graphics = helpButton, command = Help },
			Button { x = 400 - 45, y = 475 - 45, scale = 90/smallButtonSize, graphics = scoresButton, command = Community },
			Button { x = 550 - 45, y = 455 - 45, scale = 90/smallButtonSize, graphics = optionsButton, command = Options },
			Button { x = 683 - 45, y = 417 - 45, scale = 90/smallButtonSize, graphics = quitButton, command = AskQuit },

			Button { x = 5, y = 550, graphics = moreButton, name = "xsell", label = "moregames", command = function() DoModal("xsell/xsell.lua") end },

			-- Outline Text Labels
			Text { x = 310 - 95, y = 320 + 32 + 30, w = 190, h = kMax, label = "#" .. OutlineLabel("story_mode"), flags = kVAlignTop + kHAlignCenter, font = f3 },
			Text { x = 490 - 95, y = 320 + 32 + 30, w = 190, h = kMax, name = "free_play_label", label = "#" .. OutlineLabel("free_mode"), flags = kVAlignTop + kHAlignCenter, font = f3 },
			Text { x = 117 - 100, y = 417 + 32, w = 200, h = kMax, label = "#" .. OutlineLabel("change_player"), name = "choose_label", flags = kVAlignTop + kHAlignCenter, font = f3 },
			Text { x = 250 - 100, y = 455 + 32, w = 200, h = kMax, label = "#" .. OutlineLabel("help"), flags = kVAlignTop + kHAlignCenter, font = f3 },
			Text { x = 400 - 100, y = 475 + 32, w = 200, h = kMax, label = "#" .. OutlineLabel("community_menu"), flags = kVAlignTop + kHAlignCenter, font = f3 },
			Text { x = 550 - 100, y = 455 + 32, w = 200, h = kMax, label = "#" .. OutlineLabel("options"), flags = kVAlignTop + kHAlignCenter, font = f3 },
			Text { x = 683 - 100, y = 417 + 32, w = 200, h = kMax, label = "#" .. OutlineLabel("quit"), flags = kVAlignTop + kHAlignCenter, font = f3 },
		},

		Text {
			x = 0, y = 560, w = kMax, h = 20, name = "welcome", flags = kHAlignCenter + kVAlignBottom,
			font = { uiFontName, 20, WhiteColor },
		},
		Text {
			x = 0, y = 580, w = kMax, h = 20, name = "copyright", label = "#" .. GetString("copyright"), flags = kHAlignCenter + kVAlignBottom,
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
-- Disable input immediately so players don't click anything while it's invisible
gButtonsDisabled = true

-- Instantly hide everything (opacity alpha 0)
FadeOut { "main_background", time = 0 }
FadeOut { "buttons", time = 0 }
FadeOut { "game_logo", time = 0 }
FadeOut { "welcome", time = 0 }
FadeOut { "copyright", time = 0 }

-- 3. Queue the Animation Sequence
QueueCommand(function()
	-- Fade in Background
	FadeIn { "main_background", time = 1000 }

	-- Fade in Logo & Copyright
	FadeIn { "game_logo", time = 1000 }
	FadeIn { "copyright", time = 1000 }

	-- Fade in Welcome Text
	FadeIn { "welcome", time = 1000 }

	-- Fade in Buttons and enable input
	FadeIn {
		"buttons",
		time = 800,
		onend = function()
			-- Update() logic runs HERE to ensure button states (visible/hidden)
			-- are applied correctly AFTER the fade-in of the parent container.
			Update()

			-- Re-enable input
			gButtonsDisabled = false
		end
	}
end)
