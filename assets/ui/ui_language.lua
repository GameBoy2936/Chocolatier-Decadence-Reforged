--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Language Engine Menu)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Dynamic Typography Configuration
-------------------------------------------------------------------------------
-- The default Latin fonts used by the game (Fertigo and Choco3) do not natively 
-- support complex character sets. When a button requires an exotic script, we 
-- manually inject these fallback MVEC engine fonts so the button renders correctly.

local FontLatin		= "fonts/fertigo.mvec"				-- Standard Western Alphabet
local FontGreek		= "fonts/arima.mvec"				-- Greek Alphabet
local FontCyrillic	= "fonts/gabriela.mvec"				-- Russian, Ukrainian, Bulgarian, etc.
local FontJapanese	= "fonts/shipporimincho.mvec"		-- Japanese Kanji/Kana
local FontChineseS	= "fonts/notoserif-sc.mvec"			-- Simplified Chinese
local FontChineseT	= "fonts/notoserif-tc.mvec"			-- Traditional Chinese
local FontKorean	= "fonts/nanummyeongjo.mvec"		-- Korean Hangul
local FontThai		= "fonts/trirong.mvec"				-- Thai Script
local FontHindi		= "fonts/notoserifdevanagari.mvec"	-- Hindi Devanagari
local FontBengali	= "fonts/notoserifbengali.mvec"		-- Bengali Script

-- Defines all languages supported by the translation mod files, and maps 
-- them to the specific font required to render their localized names correctly.
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

-------------------------------------------------------------------------------
-- Application Logic
-------------------------------------------------------------------------------

local function SelectLanguage(langCode)
	DebugOut("UI", string.format("Player triggered language swap to: %s", langCode))
	
	-- Verify we actually changed languages before forcing a save and reboot prompt
	if Player.options.language ~= langCode then
		Player.options.language = langCode
		Player:SaveGame()
		
		-- Strings are parsed on initial Engine Boot, so hot-swapping requires a restart
		DisplayDialog { "ui/ui_generic.lua", text = "language_restart_needed" }
	else
		DebugOut("UI", "Language swap aborted: Target language is already active.")
		FadeCloseWindow("language_select", "cancel")
	end
end

-------------------------------------------------------------------------------
-- Grid Logic & Layout Rendering
-------------------------------------------------------------------------------

local buttons = {}

-- Layout Configuration (Calculated for 4 even columns)
local columnWidth = 113
local xStart = 24
local yStart = 70
local ySpacing = 36

for i, langData in ipairs(availableLanguages) do
	local tempCode = langData.code
	
	-- Calculate the rigid grid coordinate offsets for this button
	local column = Mod(i - 1, 4)
	local row = Floor((i - 1) / 4)
	local xPos = xStart + (column * columnWidth)
	local yPos = yStart + (row * ySpacing)
	
	-- Fetch the localized name for this language (e.g. "lang_fr" -> "Français")
	local labelStr = langData.key
	if string.sub(labelStr, 1, 5) == "lang_" then
		labelStr = "#" .. GetString(labelStr)
	else
		labelStr = "#" .. labelStr
	end

	-- Override the display font based on the language's specific requirements
	local targetFontName = langData.font or uiFontName
	
	local fontSize = 16
	-- Complex scripts are slightly taller in engine space, so we shrink them to prevent 
	-- their ascenders/descenders from clipping out of the UI bounding box.
	if langData.font == FontCJK or langData.font == FontThai then
		fontSize = 16 
	end
	
	local buttonFont = { targetFontName, fontSize, BlackColor }

	table.insert(buttons, Button {
		x = xPos, y = yPos, w = 96, h = 30, scale = 0.85, 
		label = labelStr,
		font = buttonFont,
		command = function() SelectLanguage(tempCode) end
	})
end

-------------------------------------------------------------------------------
-- Main UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "language_select",
		x = 1000, y = kCenter, image = "image/popup_back_generic_tall",

		SetStyle(C3DialogBodyStyle),
		Text { x = 20, y = 35, w = 459, h = 30, label = "#" .. GetString("select_language"), font = { uiFontName, 24, BlackColor }, flags = kVAlignCenter + kHAlignCenter },

		SetStyle(C3ButtonStyle),
		Group(buttons),
		
		Button { x = kCenter, y = 417, name = "cancel", label = "cancel", cancel = true, command = function() FadeCloseWindow("language_select", "cancel") end },
	}
}

CenterFadeIn("language_select")