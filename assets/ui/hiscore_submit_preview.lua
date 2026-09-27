--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Tiny nationality preview used by the dedicated score-submission dialog.
---------------------------------------------------------------------------]]

require("ui/hiscore_countries.lua")
local code = (gHighScoreSubmit and gHighScoreSubmit.nationality) or ""
local country = HighScoreCountries:Get(code)
local contents = {}

if country then
	table.insert(contents, Bitmap {
		x = 0, y = 6,
		image = HighScoreCountries:GetFlag(code),
		scale = 0.20,
	})
	table.insert(contents, Text {
		x = 42, y = 0, w = 135, h = 28,
		label = "#" .. HighScoreCountries:GetName(code),
		font = { standardFont, 13, BlackColor },
		flags = kHAlignLeft + kVAlignCenter,
	})
else
	table.insert(contents, Text {
		x = 0, y = 0, w = 177, h = 28,
		label = "hiscore_country_none",
		font = { standardFont, 13, BlackColor },
		flags = kHAlignLeft + kVAlignCenter,
	})
end

MakeDialog(contents)
