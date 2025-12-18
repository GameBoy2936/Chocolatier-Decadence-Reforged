--[[---------------------------------------------------------------------------
	Chocolatier Three: Quest Offer
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local quest = gDialogTable.quest
local text = "#"..quest:GetIntro()

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=500,h=333, name="quest_offer",
		Bitmap
		{
			x=0,y=0, image="image/telegram",
			SetStyle(controlStyle),
			
			SetStyle(C3CharacterDialogStyle),
			Text { x=20,y=115,w=457,h=175, label=text, flags=kVAlignTop+kHAlignLeft },
			
			SetStyle(C3ButtonStyle),
			Button { x=101,y=275, name="accept", label=quest.accept, default=true, command=function() quest:Accept(char); CloseWindow() end },
			Button { x=264,y=275, name="reject", label=quest.reject, cancel=true, command=function() quest:Reject(char); CloseWindow() end },
		},
	}
}

if quest.reject == "none" then EnableWindow("reject", false) end
OpenBuilding("quest_offer", gDialogTable.building)