--[[---------------------------------------------------------------------------
	Chocolatier Three: Credits dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local function okFunction()
	FadeCloseWindow("credits", "ok")
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="credits",
		x=1000,y=kCenter,image="image/popup_back_generic_tall",
		
		SetStyle(C3DialogBodyStyle),
		CreditsWindow
		{
			x=21,y=54,w=458,h=347,
			font=uiFontName,
			fontsize = 16,
			fontcolor = BlackColor,
			headercolor = BlackColor,
			columngap = 10,
			columnwidth = 224,
			time = 30000, 		-- Time to play credits in milliseconds
			intropause = 3000, 	-- Time to pause credits at start, in ms
			file = "credits.txt",
		},
		Text { x=21,y=411,w=458,h=20, label="gVersionString" },
		
		SetStyle(C3ButtonStyle),
		Button { x=kCenter,y=424, name="ok", command=okFunction, label="ok", default=true, cancel=true },
	}
}

CenterFadeIn("credits")
