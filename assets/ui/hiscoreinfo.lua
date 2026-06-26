--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Submission Policy Dialog)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "policy",
		x = 1000, y = kCenter, image = "image/popup_back_generic_tall",
		
		SetStyle(C3DialogBodyStyle),
		Text { x = 40, y = 42, w = 419, h = 358, label = "highscorecompleteinfo", flags = kVAlignCenter + kHAlignCenter },
		
		SetStyle(C3ButtonStyle),
		Button { x = kCenter, y = 418, name = "ok", label = "ok", command = function() FadeCloseWindow("policy", "ok") end, default = true, cancel = true },

		-- Invisible overlay button that triggers OS-level web browser to open the EULA URL
		Button { x = 0, y = 0, w = 0, h = 0, graphics = {}, name = "privacypolicy", command = function() LaunchPrivacyPolicy() end },
	}
}

DebugOut("UI", "Loaded Privacy Policy / High Score Info overlay.")
CenterFadeIn("policy")