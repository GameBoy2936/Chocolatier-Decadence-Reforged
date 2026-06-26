--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Credits Dialog)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Execution Hook
-------------------------------------------------------------------------------

local function okFunction()
	DebugOut("UI", "Player dismissed the Credits overlay.")
	FadeCloseWindow("credits", "ok")
end

-------------------------------------------------------------------------------
-- UI Construction & Render
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "credits",
		x = 1000, y = kCenter, image = "image/popup_back_generic_tall",
		
		SetStyle(C3DialogBodyStyle),
		
		-- Generates an animated scrolling overlay reading from an external text file
		CreditsWindow
		{
			x = 21, y = 54, w = 458, h = 347,
			
			-- Typographical Styling
			font = uiFontName,
			fontsize = 16,
			fontcolor = BlackColor,
			headercolor = BlackColor,
			
			-- Column/Grid Spacing
			columngap = 10,
			columnwidth = 224,
			
			-- Timers
			time = 30000, 		-- Total time to cycle through the text block (ms)
			intropause = 3000, 	-- Artificial pause delay before scrolling begins (ms)
			
			file = "credits.txt",
		},
		
		-- Pull the dynamically assigned Engine revision version string
		Text { x = 21, y = 411, w = 458, h = 20, label = "gVersionString" },
		
		SetStyle(C3ButtonStyle),
		Button { x = kCenter, y = 424, name = "ok", command = okFunction, label = "ok", default = true, cancel = true },
	}
}

DebugOut("UI", "Credits sequence initialized and rolling.")

CenterFadeIn("credits")