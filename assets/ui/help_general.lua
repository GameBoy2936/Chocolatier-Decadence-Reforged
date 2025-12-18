--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=165,y=5,w=420,h=290, flags=kVAlignTop+kHAlignCenter, label="#"..GetString("help_general_text"), },
		
	CharWindow { x=0,y=25, name="main_alex", happiness=100 },
	CharWindow { x=582,y=25, name="main_sean", happiness=100 },
	
	SetStyle(C3ButtonStyle),
	Button { x=kCenter,y=275, name="replay_intro", label="replay_intro",
		command=function()
			SoundEvent("Stop_Music")
			DisplaySplash("splash/intro_movie.swf", "splash/playfirst_logo",0)
			if gDialogTable.mainmenu then SoundEvent("main_menu") end
		end},
}