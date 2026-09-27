--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Profile Flag Preview)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("ui/hiscore_countries.lua")

local code = tostring(gCommunityProfilePreviewNationality or "")
if code == "" then
	if gCommunityProfile and gCommunityProfile.nationality then code = gCommunityProfile.nationality
	elseif gCommunityAuth and gCommunityAuth.nationality then code = gCommunityAuth.nationality end
end
local country = HighScoreCountries:Get(code)
local contents = {}

if country then
	table.insert(contents, Bitmap { x = 0, y = 6, image = HighScoreCountries:GetFlag(code), scale = 0.20 })
	table.insert(contents, Text { x = 42, y = 0, w = 160, h = 28,
		label = "#" .. HighScoreCountries:GetName(code), font = { standardFont, 13, BlackColor },
		flags = kHAlignLeft + kVAlignCenter })
else
	table.insert(contents, Text { x = 0, y = 0, w = 202, h = 28,
		label = "#" .. GetString("community_profile_no_flag"), font = { standardFont, 13, BlackColor },
		flags = kHAlignLeft + kVAlignCenter })
end
MakeDialog(contents)
