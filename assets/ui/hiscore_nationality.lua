--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Community High-Score Nationality / Flag Selector
---------------------------------------------------------------------------]]

local kColumns = 3
local kRows = 7
local kVisible = kColumns * kRows
local kColumnWidth = 132
local kXStart = 27
local kYStart = 2
local kYSpacing = 42
local kButtonW = 116
local kButtonH = 34
local kButtonScale = 0.7
local kFlagScale = 0.2

local selected = (gDialogTable and gDialogTable.selected) or ""
local selectorEntries = HighScoreCountries:GetSelectorEntries()

-- Each fresh selector opens around the player's current flag. FillWindow()
-- re-executes this file with gHighScoreCountryListOnly=true, so preserve the
-- live scroll position during list refreshes.
if not gHighScoreCountryListOnly then
	gHighScoreCountryOffset = 0
	if selected ~= "" then
		for index, country in ipairs(selectorEntries) do
			if country.code == selected then
				gHighScoreCountryOffset = Floor((index - 1) / kColumns) * kColumns
				break
			end
		end
	end
end
gHighScoreCountryOffset = gHighScoreCountryOffset or 0

local function ClampOffset()
	local maxOffset = table.getn(selectorEntries) - kVisible
	if maxOffset < 0 then maxOffset = 0 end
	if gHighScoreCountryOffset < 0 then gHighScoreCountryOffset = 0 end
	if gHighScoreCountryOffset > maxOffset then gHighScoreCountryOffset = maxOffset end
end

local function CanUp() return gHighScoreCountryOffset > 0 end
local function CanDown() return (gHighScoreCountryOffset + kVisible) < table.getn(selectorEntries) end

local function UpdateScrollButtons()
	EnableWindow("country_scrollup", CanUp())
	EnableWindow("country_scrolldown", CanDown())
end

local function RefreshList()
	ClampOffset()
	gHighScoreCountryListOnly = true
	FillWindow("country_list", "ui/hiscore_nationality.lua")
	gHighScoreCountryListOnly = false
	QueueCommand(function() UpdateScrollButtons() end)
end

local function SelectCountry(country)
	if not country then return end
	FadeCloseWindow("country_select", country.code)
end

local function BuildCountryButtons()
	ClampOffset()
	local contents = {}
	for slot=1,kVisible do
		local index = gHighScoreCountryOffset + slot
		local country = selectorEntries[index]
		if country then
			local col = Mod(slot - 1, kColumns)
			local row = Floor((slot - 1) / kColumns)
			local x = kXStart + (col * kColumnWidth)
			local y = kYStart + (row * kYSpacing)
			local temp = country
			local name = HighScoreCountries:GetName(country.code)
			table.insert(contents, Group {
				Bitmap { x=x, y=y+7, image=HighScoreCountries:GetFlag(country.code), scale=kFlagScale },
				Button {
					x=x+35, y=y, w=kButtonW, h=kButtonH, scale=kButtonScale,
					graphics=C3ButtonStyle.graphics,
					command=function() SelectCountry(temp) end,
					Text {
						x=5, y=3, w=Floor(kButtonW*kButtonScale), h=Floor(kButtonH*kButtonScale),
						label="#" .. name, font={ standardFont, 12, BlackColor },
						flags=kVAlignCenter + kHAlignCenter,
					}
				},
				Text {
					x=x+18, y=y-5, w=18, h=14,
					label=(selected == country.code) and "#>" or "",
					font={ labelFontName, 12, MaroonColor }, flags=kHAlignCenter + kVAlignCenter,
				},
			})
		end
	end
	return contents
end

if gHighScoreCountryListOnly then
	MakeDialog(BuildCountryButtons())
	return
end

MakeDialog {
	Bitmap {
		name="country_select", x=1000, y=kCenter, image="image/popup_back_generic_tall",
		Text { x=24, y=28, w=451, h=36, label="hiscore_choose_nationality", font={ labelFontName, 22, MaroonColor }, flags=kHAlignCenter+kVAlignCenter },
		Text { x=35, y=66, w=430, h=28, label="hiscore_nationality_help", font={ standardFont, 12, BlackColor }, flags=kHAlignCenter+kVAlignTop },
		Window { name="country_list", x=24, y=88, w=465, h=296 },
		SetStyle(C3ButtonStyle),
		Button { x=318, y=374, name="country_scrollup", command=function() gHighScoreCountryOffset=gHighScoreCountryOffset-kColumns; RefreshList() end, graphics={"image/button_arrow_up_up","image/button_arrow_up_down","image/button_arrow_up_over"}, scale=0.72 },
		Button { x=378, y=374, name="country_scrolldown", command=function() gHighScoreCountryOffset=gHighScoreCountryOffset+kColumns; RefreshList() end, graphics={"image/button_arrow_down_up","image/button_arrow_down_down","image/button_arrow_down_over"}, scale=0.72 },
		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter - 88, y=417, label="hiscore_no_flag", command=function() FadeCloseWindow("country_select", "") end },
		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter + 88, y=417, label="cancel", cancel=true, command=function() FadeCloseWindow("country_select", nil) end },
	}
}
CenterFadeIn("country_select")
QueueCommand(function() RefreshList(); UpdateScrollButtons() end)
