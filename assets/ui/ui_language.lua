--[[---------------------------------------------------------------------------
	Chocolatier Three: Language Selection Dialog
	Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- 1. Define specific font paths.
-- Ensure these .mvec files exist in your assets/fonts/ folder!
local FontLatin		= "fonts/fertigo.mvec"				-- Standard Western
local FontGreek		= "fonts/arima.mvec"				-- Greek
local FontCyrillic	= "fonts/gabriela.mvec"				-- Russian, Ukrainian, etc.
local FontJapanese	= "fonts/shipporimincho.mvec"		-- Japanese
local FontChineseS	= "fonts/notoserif-sc.mvec"			-- Chinese, Simplified
local FontChineseT	= "fonts/notoserif-tc.mvec"			-- Chinese, Traditional
local FontKorean	= "fonts/nanummyeongjo.mvec"		-- Korean
local FontThai		= "fonts/trirong.mvec"				-- Thai
local FontHindi		= "fonts/notoserifdevanagari.mvec"	-- Hindi
local FontBengali	= "fonts/notoserifbengali.mvec"		-- Bengali

-- 2. Map languages to fonts. 
-- If a font is nil, it will fall back to the currently active game font (uiFontName).
local availableLanguages = {
	{ code = "en", key = "lang_en", font = FontLatin },
	{ code = "fr", key = "lang_fr", font = FontLatin },
	{ code = "de", key = "lang_de", font = FontLatin },
	{ code = "nl", key = "lang_nl", font = FontLatin },
	{ code = "it", key = "lang_it", font = FontLatin },
	{ code = "es_eu", key = "lang_es_eu", font = FontLatin },
	{ code = "es_lt", key = "lang_es_lt", font = FontLatin },
	{ code = "pt_eu", key = "lang_pt_eu", font = FontLatin },
	{ code = "pt_br", key = "lang_pt_br", font = FontLatin },
	{ code = "ca", key = "lang_ca", font = FontLatin },
	{ code = "mt", key = "lang_mt", font = FontLatin },
	{ code = "pl", key = "lang_pl", font = FontLatin },
	{ code = "cz", key = "lang_cz", font = FontLatin },
	{ code = "hu", key = "lang_hu", font = FontLatin },
	{ code = "ro", key = "lang_ro", font = FontLatin },
	{ code = "hr", key = "lang_hr", font = FontLatin },
	{ code = "sr", key = "lang_sr", font = FontCyrillic },
	{ code = "bg", key = "lang_bg", font = FontCyrillic },
	{ code = "da", key = "lang_da", font = FontLatin },
	{ code = "is", key = "lang_is", font = FontLatin },
	{ code = "no", key = "lang_no", font = FontLatin },
	{ code = "sv", key = "lang_sv", font = FontLatin },
	{ code = "fi", key = "lang_fi", font = FontLatin },
	{ code = "ru", key = "lang_ru", font = FontCyrillic },
	{ code = "uk", key = "lang_uk", font = FontCyrillic },
	{ code = "el", key = "lang_el", font = FontGreek },
	{ code = "tr", key = "lang_tr", font = FontLatin },
	{ code = "zhs", key = "lang_zhs", font = FontChineseS },
	{ code = "zht", key = "lang_zht", font = FontChineseT },
	{ code = "ko", key = "lang_ko",  font = FontKorean },
	{ code = "ja", key = "lang_ja",  font = FontJapanese },
	{ code = "th", key = "lang_th", font = FontThai },
	{ code = "vi", key = "lang_vi", font = FontLatin },
	{ code = "id", key = "lang_id", font = FontLatin },
	{ code = "ms", key = "lang_ms", font = FontLatin },
	{ code = "tl", key = "lang_tl", font = FontLatin },
}

local function SelectLanguage(langCode)
	DebugOut("UI", "Language selected: " .. langCode)
	
	if Player.options.language ~= langCode then
		Player.options.language = langCode
		Player:SaveGame()
		DisplayDialog { "ui/ui_generic.lua", text="language_restart_needed" }
	else
		FadeCloseWindow("language_select", "cancel")
	end
end

-------------------------------------------------------------------------------

local buttons = {}

-- Layout Configuration for 4 Columns
local columnWidth = 113
local xStart = 24
local yStart = 70
local ySpacing = 36

for i, langData in ipairs(availableLanguages) do
	local tempCode = langData.code
	
	-- Calculate column (0 to 3) and row
	local column = Mod(i - 1, 4)
	local row = Floor((i - 1) / 4)
	
	-- Calculate position
	local xPos = xStart + (column * columnWidth)
	local yPos = yStart + (row * ySpacing)
	
	local labelStr = langData.key
	if string.sub(labelStr, 1, 5) == "lang_" then
		labelStr = "#" .. GetString(labelStr)
	else
		labelStr = "#" .. labelStr
	end

	-- DYNAMIC FONT SELECTION
	-- If the language entry has a specific font, use it.
	-- Otherwise, fall back to the global uiFontName (whatever is currently active).
	local targetFontName = langData.font or uiFontName
	
	-- Create a font style table: { FontFile, Size, Color }
	-- We use 14pt (or maybe 12pt for CJK/Thai to fit better)
	local fontSize = 16
	if langData.font == FontCJK or langData.font == FontThai then
		fontSize = 16 -- Slightly smaller for complex scripts to prevent clipping
	end
	
	local buttonFont = { targetFontName, fontSize, BlackColor }

	table.insert(buttons, Button {
		x = xPos,
		y = yPos,
		w = 96,
		h = 30,
		scale = 0.85, 
		
		label = labelStr,
		font = buttonFont, -- Apply the specific font here
		
		command = function() SelectLanguage(tempCode) end
	})
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="language_select",
		x=1000, y=kCenter, image="image/popup_back_generic_tall",

		SetStyle(C3DialogBodyStyle),
		Text { x=20, y=35, w=459, h=30, label="#"..GetString"select_language", font={ uiFontName, 24, BlackColor }, flags=kVAlignCenter+kHAlignCenter },

		SetStyle(C3ButtonStyle),
		Group(buttons),
		
		Button { x=kCenter, y=417, name="cancel", label="cancel", cancel=true, command=function() FadeCloseWindow("language_select", "cancel") end },
	}
}

CenterFadeIn("language_select")