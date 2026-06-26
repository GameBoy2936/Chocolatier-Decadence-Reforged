--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (High Score Viewer)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Immediately log the player's current score to memory so their latest
-- achievements appear in the local boards when they open this screen.
Player:LogScore()

-------------------------------------------------------------------------------
-- Font & Style Definitions
-------------------------------------------------------------------------------

HeaderFont             = { standardFont, 70, BlueColor }
TableInfoFont          = { standardFont, 30, BlackColor }
EligibleFont           = { standardFont, 18, BlackColor }
EligibleAsteriskFont   = { standardFont, 12, BlackColor }
ConnectingToServerFont = { standardFont, 18, BlackColor }
TableHeaderFont        = { standardFont, 30, BlackColor }
ScoreInfoFont          = { standardFont, 18, BlackColor }
ScoreFont              = { standardFont, 18, BlackColor }
PlayerInfoFont         = { standardFont, 14, BlackColor }
RankFont               = { standardFont, 26, BlackColor }

local LeftButtonGraphics = {
	"hiscore/arrowleft_up",
	"hiscore/arrowleft_down",
	"hiscore/arrowleft_over"
}

-------------------------------------------------------------------------------
-- Layout Offsets
-------------------------------------------------------------------------------

local kScoreRowSpace = 32
local kRowY = 95
local kLeftX = 5
local kNumberX = kLeftX + 37
local kNameX = 57
local kInfoX = kNameX + 10
local kScoreX = 470
local kP1X = kNumberX + 1

local kNameW = 400
local kNameH = 21

-------------------------------------------------------------------------------
-- Screen States & View Controller
-------------------------------------------------------------------------------

local eLocalView             = 0
local eRequestingCategories  = 1
local eRequestingScores      = 2
local eSubmitting            = 3
local eGlobalView            = 4
local eError                 = 5

-- Called continuously by the underlying C++ Engine to disable/enable UI buttons
-- depending on whether the game is currently pulling data from the server.
function UpdateButtons()
	local state = GetState()
	local localHS = IsEnabled(kHiscoreLocalOnly)
	local anonHS = IsEnabled(kHiscoreAnonymous)
	local fullHS = (not localHS) and (not anonHS)

	-- Default all interactive elements to disabled while state resolves
	EnableWindow("view", false)
	EnableWindow("viewlocal", false)
	EnableWindow("submit", false)
	EnableWindow("categoryleft", false)
	EnableWindow("categoryright", false)
	
	if state == eLocalView then
		-- Only allow profile-bound (non-anonymous) players to see the "More Info" web links
		if fullHS then
			EnableWindow("moreinfo", true)
		else 
			EnableWindow("moreinfo", false)
		end
		
		-- If local-only mode isn't forced, allow transitioning to the global leaderboards
		if not localHS then
			EnableWindow("view", true)

			-- If the player has a score that qualifies for the leaderboards, allow submission
			if ScoreAvailable() then
				EnableWindow("submit", true)
			end
		end
		
	elseif state == eGlobalView then
		EnableWindow("viewlocal", true)
		EnableWindow("categoryleft", true)
		EnableWindow("categoryright", true)
		
	elseif state == eError then
		-- If the server connection timed out or failed, trap them in Local View
		EnableWindow("viewlocal", true)
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

-- Helper to rapidly generate identical layout syntax for all 10 leaderboard slots
local function GenerateScoreSlot(index)
	local yOffset = kRowY + ((index - 1) * kScoreRowSpace)
	return Group {
		Text   { y = yOffset, name = tostring(index), label = tostring(index) .. ".", x = kLeftX, w = kNumberX, h = 20, font = ScoreFont, flags = kHAlignRight + kVAlignTop },
		Bitmap { y = yOffset, name = "p1_" .. index, x = kP1X, image = "hiscore/p1icon" },
		Text   { y = yOffset, name = "name" .. index, font = ScoreFont, x = kNameX, w = kNameW, h = kNameH, flags = kHAlignLeft + kVAlignTop, label = "name" },
		Text   { y = yOffset, name = "score" .. index, font = ScoreFont, x = 0, w = kScoreX, h = kMax, flags = kHAlignRight + kVAlignTop, label = "#" .. GetString("12345") },
		Text   { y = yOffset + 18, name = "info" .. index, font = PlayerInfoFont, x = kInfoX, w = kScoreX, h = kMax, flags = kHAlignLeft + kVAlignTop, label = "#" .. GetString("#More info goes here") }
	}
end

MakeDialog
{
	Window
	{
		x = 1000, y = 9, name = "hiscorescreen", fit = true,
		Bitmap
		{
			x = 0, y = 13, image = "image/popup_back_highscores",
			
			-- Binds to the C++ Hiscore Controller Object
			HiscoreWindow
			{
				x = 0, y = 0, h = kMax, w = kMax,
				
				-- Titles (Only one is visible at a time depending on state)
				Text { x = 17, y = 35, w = 455, h = 40, name = "local", label = "#" .. GetString("localhighscores"), font = TableHeaderFont, flags = kVAlignCenter + kHAlignCenter },
				Text { x = 17, y = 35, w = 455, h = 40, name = "global", label = "#" .. GetString("globalhighscores"), font = TableHeaderFont, flags = kVAlignCenter + kHAlignCenter },

				-- 10 Leaderboard Slots
				GenerateScoreSlot(1), GenerateScoreSlot(2), GenerateScoreSlot(3), GenerateScoreSlot(4), GenerateScoreSlot(5),
				GenerateScoreSlot(6), GenerateScoreSlot(7), GenerateScoreSlot(8), GenerateScoreSlot(9), GenerateScoreSlot(10),

				-- Sub-Panel: Global Leaderboard View Context
				Window
				{
					x = 477, y = 0, w = kMax, h = kMax, name = "rightpanelsmall",

					Text { x = 20, y = 75, w = 249, h = kMax, name = "yourrankglobalinfo", label = "#" .. GetString("globalhighscoreinfo"), font = ScoreInfoFont, flags = kVAlignTop + kHAlignCenter },
					Text { x = 20, y = 155, w = 249, h = kMax, name = "yourrank", label = "#" .. GetString("yourrank"), font = RankFont, flags = kVAlignTop + kHAlignCenter },
					Text { x = 20, y = 195, w = 249, h = kMax, name = "congratulations", label = "#" .. GetString("congratshighscore"), font = RankFont, flags = kVAlignTop + kHAlignCenter },
					Text { x = 20, y = 195, w = 249, h = kMax, name = "dnq", label = "#" .. GetString("scorednq"), font = RankFont, flags = kVAlignTop + kHAlignCenter },
				},

				-- Sub-Panel: Local View & Submission Options
				Window
				{
					x = 477, y = 0, w = kMax, h = kMax, name = "rightpanel",
					
					Text { x = 0, y = 25, w = 289, h = 40, name = "globalinfoheader", label = "#" .. GetString("globalhighscores"), font = TableHeaderFont, flags = kVAlignCenter + kHAlignCenter },
					Text { x = 20, y = 75, w = 249, h = kMax, name = "info", label = "#" .. GetString("globalhighscoreinfo"), font = ScoreInfoFont, flags = kVAlignTop + kHAlignCenter },
					Text { x = 20, y = 155, w = 249, h = kMax, name = "eligible", label = "#" .. GetString("eligible"), font = EligibleFont, flags = kVAlignTop + kHAlignCenter },

					SetStyle(C3ButtonStyle),
					Button { x = kCenter, y = 210, name = "moreinfo", label = "#" .. GetString("moreinfo"), command = function() DoModal("ui/hiscoreinfo.lua") end },
					
					Button { x = kCenter, y = 250, name = "submit", label = "#" .. GetString("submit"),
						command = function()
							-- Securely gather server keys and execute the submission overlay
							local vars = loadstring(GetLuaServerSubmitSetupVars(false))
							vars()
							local val = DoModal("ui/serversubmit.lua")
							
							if val == 'qualified' then
								SubmissionDone(true)
							elseif val == 'success' then
								SubmissionDone(false)
							end
						end
					},
						
					Text { font = ConnectingToServerFont, name = "server", x = 20, y = 210, w = 249, h = 80, flags = kHAlignCenter + kVAlignCenter, label = "connectingtoserver" },
					Text { font = ConnectingToServerFont, name = "error", x = 20, y = 210, w = 249, h = 80, flags = kHAlignCenter + kVAlignCenter, },
				},

				-- Pagination & Filter Controls
				Text { font = ScoreFont, name = "category", x = 141, y = 66, w = 208, h = 40, flags = kHAlignCenter + kVAlignTop },
				SetStyle(C3ButtonStyle),
				Button { graphics = LeftButtonGraphics, name = "categoryleft", x = 138, y = 60, scale = 0.6 },
				Button { graphics = LeftButtonGraphics, name = "categoryright", x = 308, y = 60, scale = 0.6, hflip = true },

				Button { graphics = LeftButtonGraphics, rotate = true, name = "scrollup", x = 425, y = 65, scale = 0.4 },
				Button { graphics = LeftButtonGraphics, rotate = true, hflip = true, name = "scrolldown", x = 425, y = 415, scale = 0.4 },

				SetStyle(LongButtonStyle),
				Button { align = kHAlignRight, x = 731, y = kMax - 56 - 65, name = "viewlocal", label = "viewlocal", scale = 1.1 },
				Button { align = kHAlignRight, x = 731, y = kMax - 56 - 65, name = "view", label = "viewglobal", scale = 1.1 },
			}
		},
		
		Bitmap { image = "image/popup_nameplate", x = 223, y = 0,
			Text { x = 34, y = 10, w = 270, h = 38, label = "#" .. GetString("highscoreheader"), font = nameplateFont, flags = kVAlignCenter + kHAlignCenter },
		},
		
		SetStyle(C3RoundButtonStyle),
		Button { x = 704, y = 426, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("hiscorescreen", "ok") end },
	}
}

CenterFadeIn("hiscorescreen")