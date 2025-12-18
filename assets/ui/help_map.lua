--[[---------------------------------------------------------------------------
	Chocolatier Three: Help
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local label = "#"..GetString("trip_time_single").."<br>"..GetString("trip_cost", Dollars(592))

MakeDialog
{
	SetStyle(C3DialogBodyStyle),
	Text { x=15,y=5,w=719,h=110, flags=kVAlignCenter+kHAlignCenter, label="#"..GetString("help_map_text") },
	
	Bitmap { x=5,y=120, image="image/factory_help" },
	Bitmap { x=40,y=120, image="image/factory_idle_help" },
	Text { x=75,y=120, w=kMax,h=32, label="#"..GetString("help_map_factory"), flags=kVAlignCenter+kHAlignLeft },

	Bitmap { x=21,y=155, image="image/icon_shop" },
	Text { x=75,y=155, w=kMax,h=32, label="#"..GetString("help_map_shop"), flags=kVAlignCenter+kHAlignLeft },

	Bitmap { x=21,y=190, image="image/port_locked_help" },
	Text { x=75,y=190, w=kMax,h=40, label="#"..GetString("help_map_locked"), flags=kVAlignCenter+kHAlignLeft },
	
	Bitmap { x=21,y=225, image="image/port_help" },
	Text { x=75,y=224, w=355,h=74, label="#"..GetString("help_map_port"), flags=kVAlignCenter+kHAlignLeft },
	
	Bitmap { x=435,y=225, image="image/traveltag", fit=true,
		Text { x=0,y=2,w=kMax,h=25, label="#"..GetString("zurich"), font=portNameRolloverFont, flags=kVAlignCenter+kHAlignCenter, },
		Text { x=24,y=25,w=201,h=40, label=label, font=rolloverInfoFont, flags=kVAlignTop+kHAlignCenter, }
	},
}