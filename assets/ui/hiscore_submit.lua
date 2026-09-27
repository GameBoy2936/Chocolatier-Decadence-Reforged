--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Dedicated Community High-Score Submission UI

	Visual presentation is intentionally separate from serversubmit.lua, which
	owns the native submission/controller compatibility layer.
---------------------------------------------------------------------------]]

require("ui/serversubmit.lua")
HighScoreSubmitController:Initialize()

local HeaderFont       = { labelFontName, 25, MaroonColor }
local IntroFont        = { standardFont, 13, BlackColor }
local SectionFont      = { labelFontName, 14, MaroonColor }
local LabelFont        = { standardFont, 14, BlackColor }
local ScoreLabelFont   = { standardFont, 14, BlackColor }
local ScoreFont        = { standardFont, 31, MaroonColor }
local HelpFont         = { standardFont, 12, BlackColor }
local StatusLabelFont  = { standardFont, 12, BlackColor }
local StatusFont       = { labelFontName, 13, MaroonColor }
local WaitFont         = { standardFont, 23, BlackColor }
local RuleColor        = Color(116, 82, 54, 65)

local state = gHighScoreSubmit or {}
local kDefaultDisplayName = state.displayName or ""
local kIntegrityKey = state.integrityKey or "hiscore_integrity_legacy"

MakeDialog
{
	name = "hiscoresubmitscreen",
	Bitmap
	{
		name = "hiscoresubmitpanel",
		image = "image/popup_back_generic_1",
		x = 1000, y = kCenter,

		SubmitWindow
		{
			x = kCenter, y = 0, h = kMax, w = 415,
			SetStyle(DefaultStyle),

			-- Static presentation layer. Interactive/native controls remain
			-- direct children of SubmitWindow to preserve the proven native
			-- control lookup contract.
			Window
			{
				name = "submitcontent", x = 0, y = 0, w = kMax, h = kMax,

				Text { font = HeaderFont, x = 15, y = 24, w = 385, h = 42, flags = kHAlignCenter + kVAlignCenter, label = "submitglobal" },
				Text { font = IntroFont, x = 30, y = 69, w = 355, h = 34, flags = kHAlignCenter + kVAlignTop, label = "hiscore_submission_intro" },
				Rectangle { x = 42, y = 98, w = 331, h = 1, color = RuleColor },

				-- Featured score block.
				Text { font = ScoreLabelFont, x = 35, y = 104, w = 345, h = 22, flags = kHAlignCenter + kVAlignCenter, label = "hiscore_company_score" },
				Text { font = ScoreFont, x = 35, y = 124, w = 345, h = 42, flags = kHAlignCenter + kVAlignCenter, label = "#" .. HighScoreModel:FormatNumber(gEligibleScore) },

				Rectangle { x = 42, y = 170, w = 331, h = 1, color = RuleColor },
				Text { font = HelpFont, x = 36, y = 186, w = 343, h = 26, flags = kHAlignCenter + kVAlignTop, label = "hiscore_privacy_notice" },
			},

			-- Invisible compatibility control required by the native SubmitWindow
			-- when nameedit becomes empty. PlayFirst account UI remains removed.
			TextEdit {
				name = "accountedit",
				x = -2000, y = -2000, w = 1, h = 1,
				label = "",
				length = 1,
			},

			Text { font = WaitFont, name = "submitconnect", x = 25, y = 80, w = 365, h = 300, flags = kHAlignCenter + kVAlignCenter, label = "connectingtoserver" },
			Text { font = WaitFont, name = "submiterror", x = 25, y = 80, w = 365, h = 260, flags = kHAlignCenter + kVAlignCenter, label = "" },

			SetStyle(C3ButtonMediumStyle),
			Button {
				x = kCenter - 90, y = 237, name = "submittoserver", label = "hiscore_submit_score",
				hotkey = "alt-s", type = kPush, default = true,
				command = state.Submit,
			},
			Button {
				x = kCenter + 90, y = 237, name = "submitcancel", label = "cancel", cancel = true, type = kPush,
				command = function()
					DebugOut("HISCORE", "Player cancelled score submission.")
					FadeCloseWindow("hiscoresubmitpanel", "cancel")
				end,
			},
			Button {
				x = kCenter, y = 237, name = "submiterrorok", label = "ok", type = kPush,
				command = function()
					EnableWindow("submiterrorok", false)
					EnableWindow("submiterror", false)
					SwitchModes(false)
				end,
			},
		},
	},
}

EnableWindow("submitconnect", false)
EnableWindow("submiterror", false)
EnableWindow("submiterrorok", false)
EnableWindow("accountedit", false)

SwitchModes(false)
QueueCommand(function()
	if gHighScoreSubmit and gHighScoreSubmit.RefreshNationality then
		gHighScoreSubmit.RefreshNationality()
	end
end)
CenterFadeIn("hiscoresubmitpanel")
