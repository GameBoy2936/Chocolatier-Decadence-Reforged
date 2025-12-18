--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=15,y=5,w=510,h=150, flags=kVAlignTop+kHAlignLeft, label="#"..GetString("help_port_text") },

	Bitmap { x=0,y=140, image="ports/tokyo/tok_shop", scale=1 },
	Bitmap { x=190,y=190, image="ports/tangiers/tan_market", scale=1 },
	Bitmap { x=525,y=25, image="ports/zurich/zur_bank", scale=1 },
}