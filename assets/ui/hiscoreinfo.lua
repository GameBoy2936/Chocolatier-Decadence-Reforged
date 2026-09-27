--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Leaderboard Information)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
	Reforged high-score UI presentation pass v0.1.7.
--]]---------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "leaderboardinfo",
		x = 1000, y = kCenter, image = "image/popup_back_generic_tall",

		Text { x = 40, y = 42, w = 419, h = 42, label = "hiscore_info_header", font = { standardFont, 28, BlackColor }, flags = kVAlignCenter + kHAlignCenter },

		SetStyle(C3DialogBodyStyle),
		Text { x = 48, y = 96, w = 403, h = 304, label = "hiscore_info_text", font = { standardFont, 14, BlackColor }, flags = kVAlignTop + kHAlignLeft },

		SetStyle(C3ButtonStyle),
		Button { x = kCenter, y = 410, name = "ok", label = "ok", command = function() FadeCloseWindow("leaderboardinfo", "ok") end, default = true, cancel = true },
	}
}

CenterFadeIn("leaderboardinfo")
