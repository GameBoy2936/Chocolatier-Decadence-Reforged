--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Language Engine Menu)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Dynamic Typography Configuration
-------------------------------------------------------------------------------
-- The main language list uses the currently loaded XML strings and UI font.
-- Per-language fonts are kept here only so the confirmation window can render
-- the selected language's native-script confirmation line when the player clicks
-- a language.

local FontLatin			= "fonts/fertigo.mvec"					-- Standard Western Alphabet
local FontGreek			= "fonts/arima.mvec"					-- Greek Alphabet
local FontCyrillic		= "fonts/gabriela.mvec"					-- Russian, Ukrainian, Bulgarian, Serbian, etc.
local FontJapanese		= "fonts/shipporimincho.mvec"			-- Japanese Kanji/Kana
local FontChineseS		= "fonts/notoserif-sc.mvec"				-- Simplified Chinese
local FontChineseT		= "fonts/notoserif-tc.mvec"				-- Traditional Chinese
local FontKorean		= "fonts/nanummyeongjo.mvec"			-- Korean Hangul
local FontThai			= "fonts/trirong.mvec"					-- Thai Script
local FontHindi			= "fonts/notoserifdevanagari.mvec"		-- Devanagari
local FontBengali		= "fonts/notoserifbengali.mvec"			-- Bengali Script

-- These font names are pre-wired for future localizations. Only uncomment the
-- matching language entries once the font file exists and the XML is localized.
local FontArabic		= "fonts/notonaskharabic.mvec"			-- Arabic, Persian, Urdu
local FontHebrew		= "fonts/notoserifhebrew.mvec"			-- Hebrew
local FontGeorgian		= "fonts/notoserifgeorgian.mvec"		-- Georgian
local FontArmenian		= "fonts/notoserifarmenian.mvec"		-- Armenian
local FontEthiopic		= "fonts/notoserifethiopic.mvec"		-- Amharic
local FontGujarati		= "fonts/notoserifgujarati.mvec"		-- Gujarati
local FontTamil			= "fonts/notoseriftamil.mvec"			-- Tamil
local FontTelugu		= "fonts/notoseriftelugu.mvec"			-- Telugu
local FontKannada		= "fonts/notoserifkannada.mvec"			-- Kannada
local FontMalayalam		= "fonts/notoserifmalayalam.mvec"		-- Malayalam
local FontLao			= "fonts/notoseriflao.mvec"				-- Lao
local FontKhmer			= "fonts/notoserifkhmer.mvec"			-- Khmer
local FontMyanmar		= "fonts/notoserifmyanmar.mvec"			-- Burmese / Myanmar
local FontMongolian		= "fonts/notoserifmongolian.mvec"		-- Mongolian

-------------------------------------------------------------------------------
-- Language Data
-------------------------------------------------------------------------------
-- Active entries appear in the language list.
-- Commented entries are pre-defined and ready to uncomment once localized.
--
-- The list label comes from XML via lang_*. That means it appears in the
-- currently loaded UI language and uses uiFontName. The native/font data is only
-- used after click, inside ui_language_confirm.lua.

local availableLanguages = {
	-- Currently localized / active
	{ code = "en",		key = "lang_en",		native = "English",						font = FontLatin },
	{ code = "fr",		key = "lang_fr",		native = "Français",					font = FontLatin },
	{ code = "de",		key = "lang_de",		native = "Deutsch",						font = FontLatin },
	{ code = "nl",		key = "lang_nl",		native = "Nederlands",					font = FontLatin },
	{ code = "it",		key = "lang_it",		native = "Italiano",					font = FontLatin },
	{ code = "es_eu",	key = "lang_es_eu",		native = "Español (Latinoamérica)",		font = FontLatin },
	{ code = "es_lt",	key = "lang_es_lt",		native = "Español (España)",			font = FontLatin },
	{ code = "pt_eu",	key = "lang_pt_eu",		native = "Português (Portugal)",		font = FontLatin },
	{ code = "pt_br",	key = "lang_pt_br",		native = "Português (Brasil)",			font = FontLatin },
	{ code = "ca",		key = "lang_ca",		native = "Català",						font = FontLatin },
	{ code = "mt",		key = "lang_mt",		native = "Malti",						font = FontLatin },
	{ code = "pl",		key = "lang_pl",		native = "Polski",						font = FontLatin },
	{ code = "cz",		key = "lang_cz",		native = "Čeština",					font = FontLatin },
	{ code = "hu",		key = "lang_hu",		native = "Magyar",						font = FontLatin },
	{ code = "ro",		key = "lang_ro",		native = "Română",						font = FontLatin },
	{ code = "hr",		key = "lang_hr",		native = "Hrvatski",					font = FontLatin },
	{ code = "sr",		key = "lang_sr",		native = "Српски",						font = FontCyrillic },
	{ code = "bg",		key = "lang_bg",		native = "Български",					font = FontCyrillic },
	{ code = "da",		key = "lang_da",		native = "Dansk",						font = FontLatin },
	{ code = "is",		key = "lang_is",		native = "Íslenska",					font = FontLatin },
	{ code = "no",		key = "lang_no",		native = "Norsk",						font = FontLatin },
	{ code = "sv",		key = "lang_sv",		native = "Svenska",					font = FontLatin },
	{ code = "fi",		key = "lang_fi",		native = "Suomi",						font = FontLatin },
	{ code = "ru",		key = "lang_ru",		native = "Русский",					font = FontCyrillic },
	{ code = "uk",		key = "lang_uk",		native = "Українська",					font = FontCyrillic },
	{ code = "el",		key = "lang_el",		native = "Ελληνικά",					font = FontGreek },
	{ code = "tr",		key = "lang_tr",		native = "Türkçe",						font = FontLatin },
	{ code = "zhs",		key = "lang_zhs",		native = "中文（简体）",					font = FontChineseS },
	{ code = "zht",		key = "lang_zht",		native = "中文（繁體）",					font = FontChineseT },
	{ code = "ko",		key = "lang_ko",		native = "한국어",						font = FontKorean },
	{ code = "ja",		key = "lang_ja",		native = "日本語",						font = FontJapanese },
	{ code = "th",		key = "lang_th",		native = "ไทย",						font = FontThai },
	{ code = "vi",		key = "lang_vi",		native = "Tiếng Việt",					font = FontLatin },
	{ code = "id",		key = "lang_id",		native = "Bahasa Indonesia",			font = FontLatin },
	{ code = "ms",		key = "lang_ms",		native = "Bahasa Melayu",				font = FontLatin },
	{ code = "tl",		key = "lang_tl",		native = "Filipino",					font = FontLatin },

	-- Pre-defined future localizations. Uncomment once each language has
	-- complete XML strings, a tested font, and a verified mainloop font route.

	-- { code = "gl",	key = "lang_gl",		native = "Galego",						font = FontLatin },
	-- { code = "eu",	key = "lang_eu",		native = "Euskara",						font = FontLatin },
	-- { code = "ga",	key = "lang_ga",		native = "Gaeilge",						font = FontLatin },
	-- { code = "cy",	key = "lang_cy",		native = "Cymraeg",						font = FontLatin },
	-- { code = "sk",	key = "lang_sk",		native = "Slovenčina",					font = FontLatin },
	-- { code = "sl",	key = "lang_sl",		native = "Slovenščina",					font = FontLatin },
	-- { code = "mk",	key = "lang_mk",		native = "Македонски",					font = FontCyrillic },
	-- { code = "lt",	key = "lang_lt",		native = "Lietuvių",					font = FontLatin },
	-- { code = "lv",	key = "lang_lv",		native = "Latviešu",					font = FontLatin },
	-- { code = "et",	key = "lang_et",		native = "Eesti",						font = FontLatin },
	-- { code = "be",	key = "lang_be",		native = "Беларуская",					font = FontCyrillic },
	-- { code = "ka",	key = "lang_ka",		native = "ქართული",						font = FontGeorgian },
	-- { code = "hy",	key = "lang_hy",		native = "Հայերեն",						font = FontArmenian },
	-- { code = "az",	key = "lang_az",		native = "Azərbaycanca",				font = FontLatin },
	-- { code = "am",	key = "lang_am",		native = "አማርኛ",						font = FontEthiopic },
	-- { code = "yo",	key = "lang_yo",		native = "Yorùbá",						font = FontLatin },
	-- { code = "ig",	key = "lang_ig",		native = "Igbo",						font = FontLatin },
	-- { code = "sw",	key = "lang_sw",		native = "Kiswahili",					font = FontLatin },
	-- { code = "af",	key = "lang_af",		native = "Afrikaans",					font = FontLatin },
	-- { code = "zu",	key = "lang_zu",		native = "isiZulu",						font = FontLatin },
	-- { code = "mg",	key = "lang_mg",		native = "Malagasy",					font = FontLatin },
	-- { code = "he",	key = "lang_he",		native = "עברית",						font = FontHebrew },
	-- { code = "ar",	key = "lang_ar",		native = "العربية",						font = FontArabic },
	-- { code = "fa",	key = "lang_fa",		native = "فارسی",						font = FontArabic },
	-- { code = "hi",	key = "lang_hi",		native = "हिन्दी",						font = FontHindi },
	-- { code = "ur",	key = "lang_ur",		native = "اردو",						font = FontArabic },
	-- { code = "bn",	key = "lang_bn",		native = "বাংলা",						font = FontBengali },
	-- { code = "pa",	key = "lang_pa",		native = "ਪੰਜਾਬੀ",						font = FontHindi },
	-- { code = "gu",	key = "lang_gu",		native = "ગુજરાતી",						font = FontGujarati },
	-- { code = "mr",	key = "lang_mr",		native = "मराठी",						font = FontHindi },
	-- { code = "ta",	key = "lang_ta",		native = "தமிழ்",						font = FontTamil },
	-- { code = "te",	key = "lang_te",		native = "తెలుగు",						font = FontTelugu },
	-- { code = "kn",	key = "lang_kn",		native = "ಕನ್ನಡ",						font = FontKannada },
	-- { code = "ml",	key = "lang_ml",		native = "മലയാളം",						font = FontMalayalam },
	-- { code = "kk",	key = "lang_kk",		native = "Қазақша",						font = FontCyrillic },
	-- { code = "mn",	key = "lang_mn",		native = "Монгол",						font = FontCyrillic },
	-- { code = "lo",	key = "lang_lo",		native = "ລາວ",						font = FontLao },
	-- { code = "km",	key = "lang_km",		native = "ខ្មែរ",						font = FontKhmer },
	-- { code = "my",	key = "lang_my",		native = "မြန်မာ",						font = FontMyanmar },
	-- { code = "mi",	key = "lang_mi",		native = "Māori",						font = FontLatin },
}

-------------------------------------------------------------------------------
-- Layout & Pagination State
-------------------------------------------------------------------------------

local kLanguageColumns = 3
local kLanguageRows = 7
local kLanguageVisibleCount = kLanguageColumns * kLanguageRows

local kColumnWidth = 150
local kXStart = 24
local kYStart = 4
local kYSpacing = 42

local kButtonW = 128
local kButtonH = 34
local kButtonScale = 0.86
local kLightXOffset = -15
local kButtonXOffset = 18

gLanguageScrollOffset = gLanguageScrollOffset or 0

-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

local function ClampLanguageScroll()
	local maxOffset = table.getn(availableLanguages) - kLanguageVisibleCount
	if maxOffset < 0 then maxOffset = 0 end

	if gLanguageScrollOffset < 0 then
		gLanguageScrollOffset = 0
	elseif gLanguageScrollOffset > maxOffset then
		gLanguageScrollOffset = maxOffset
	end
end

local function GetSavedLanguage()
	if Player and Player.options and Player.options.language then
		return Player.options.language
	end

	return "en"
end

local function GetLoadedLanguage()
	return gLoadedLanguage or GetSavedLanguage()
end

local function GetLanguageDisplayName(langData)
	if not langData then return "Unknown" end

	local label = GetString(langData.key)

	-- If the string is missing or falls back to the key name, use the native
	-- hardcoded label so the language remains readable.
	if not label or label == "#####" or label == langData.key then
		label = langData.native or langData.code
	end

	return label
end

local function GetLanguageIndicatorImage(langCode)
	local savedLang = GetSavedLanguage()
	local loadedLang = GetLoadedLanguage()

	-- Green is the saved target language the player has selected.
	if langCode == savedLang then
		return "image/indicatorlight_green"
	end

	-- Yellow is the language currently loaded into memory, if different.
	if langCode == loadedLang and loadedLang ~= savedLang then
		return "image/indicatorlight_yellow"
	end

	return "image/indicatorlight_blank"
end

local function CanScrollUp()
	return gLanguageScrollOffset > 0
end

local function CanScrollDown()
	return (gLanguageScrollOffset + kLanguageVisibleCount) < table.getn(availableLanguages)
end

local function UpdateLanguageScrollButtons()
	EnableWindow("language_scrollUp", CanScrollUp())
	EnableWindow("language_scrollDown", CanScrollDown())
end

local function RefreshLanguageList()
	ClampLanguageScroll()

	-- Re-render only the language list sub-window.
	gLanguageListOnly = true
	FillWindow("language_list", "ui/ui_language.lua")
	gLanguageListOnly = false

	QueueCommand(function()
		UpdateLanguageScrollButtons()
	end)
end

-------------------------------------------------------------------------------
-- Application Logic
-------------------------------------------------------------------------------

local function SelectLanguage(langData)
	local langCode = langData.code
	local savedLang = GetSavedLanguage()
	local loadedLang = GetLoadedLanguage()

	DebugOut("UI", string.format("Player selected language candidate: %s", langCode))

	-- The selected language is already saved.
	-- If it is also loaded, the player is already playing in this language.
	-- If it is saved but not loaded, the player already chose it and only needs
	-- to restart the game.
	if savedLang == langCode then
		if loadedLang == langCode then
			DebugOut("UI", "Language swap aborted: Target language is already active and loaded.")
			DisplayDialog { "ui/ui_generic.lua", text = "language_samechoice" }
		else
			DebugOut("UI", "Language swap reminder: Target language is saved but not currently loaded.")
			DisplayDialog { "ui/ui_generic.lua", text = "language_restart_samechoice" }
		end
		return
	end

	local result = DisplayDialog {
		"ui/ui_language_confirm.lua",
		langCode = langCode,
		langKey = langData.key,
		langName = GetLanguageDisplayName(langData),
		nativeName = langData.native or GetLanguageDisplayName(langData),
		langFont = langData.font or uiFontName,
	}

	if result == "yes" then
		DebugOut("UI", string.format("Language swap confirmed: %s", langCode))

		Player.options.language = langCode
		Player:SaveGame()

		RefreshLanguageList()

		-- Strings are parsed on initial Engine Boot, so hot-swapping requires a restart.
		DisplayDialog { "ui/ui_generic.lua", text = "language_restart_needed" }
	else
		DebugOut("UI", string.format("Language swap canceled: %s", langCode))
	end
end

local function ScrollLanguages(delta)
	gLanguageScrollOffset = gLanguageScrollOffset + delta
	RefreshLanguageList()
end

-------------------------------------------------------------------------------
-- List Rendering
-------------------------------------------------------------------------------

local function BuildLanguageButtons()
	ClampLanguageScroll()

	local buttons = {}

	for slot = 1, kLanguageVisibleCount do
		local langIndex = gLanguageScrollOffset + slot
		local langData = availableLanguages[langIndex]

		if langData then
			local column = Mod(slot - 1, kLanguageColumns)
			local row = Floor((slot - 1) / kLanguageColumns)

			local xBase = kXStart + (column * kColumnWidth)
			local yBase = kYStart + (row * kYSpacing)

			local tempLangData = langData
			local labelStr = GetLanguageDisplayName(langData)

			-- The main language list uses the currently loaded UI language.
			-- It does not load each language's native script font until clicked.
			local targetFont = { uiFontName, 15, BlackColor }

			table.insert(buttons,
				Group {
					-- Status indicator sits outside the button, not underneath it.
					Bitmap {
						x = xBase + kLightXOffset,
						y = yBase + 2,
						name = "language_light_" .. slot,
						image = GetLanguageIndicatorImage(langData.code),
					},

					Button {
						x = xBase + kButtonXOffset,
						y = yBase,
						w = kButtonW,
						h = kButtonH,
						scale = kButtonScale,
						graphics = C3ButtonStyle.graphics,
						command = function() SelectLanguage(tempLangData) end,

						Text {
							x = 0,
							y = 4,
							w = Floor(kButtonW * kButtonScale),
							h = Floor(kButtonH * kButtonScale),
							label = "#" .. labelStr,
							font = targetFont,
							flags = kVAlignCenter + kHAlignCenter,
						}
					}
				}
			)
		end
	end

	return buttons
end

-- Self-refresh branch. When RefreshLanguageList() calls FillWindow() against the
-- language_list sub-window, this same file is executed in list-only mode.
if gLanguageListOnly then
	MakeDialog(BuildLanguageButtons())
	return
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
		Text {
			x = 20, y = 34, w = 459, h = 30,
			label = "#" .. GetString("select_language"),
			font = { uiFontName, 24, BlackColor },
			flags = kVAlignCenter + kHAlignCenter
		},

		-- Scrollable language list.
		Window {
			name = "language_list",
			x = 18, y = 72, w = 463, h = 302,
		},

		-- List Pagination
		SetStyle(C3ButtonStyle),
		Button {
			x = 319, y = 372,
			name = "language_scrollUp",
			command = function() ScrollLanguages(-kLanguageColumns) end,
			graphics = { "image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over" },
			scale = 0.8
		},

		Button {
			x = 381, y = 372,
			name = "language_scrollDown",
			command = function() ScrollLanguages(kLanguageColumns) end,
			graphics = { "image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over" },
			scale = 0.8
		},

		-- Legend
		Text {
			x = 30, y = 384, w = 345, h = 18,
			label = "#" .. GetString("select_language_legend"),
			font = { uiFontName, 12, BlackColor },
			flags = kVAlignCenter + kHAlignLeft
		},

		SetStyle(C3ButtonStyle),
		Button {
			x = kCenter, y = 417,
			name = "cancel",
			label = "cancel",
			cancel = true,
			command = function() FadeCloseWindow("language_select", "cancel") end
		},
	}
}

CenterFadeIn("language_select")

-- Fill the list after the parent window exists.
QueueCommand(function()
	RefreshLanguageList()
	UpdateLanguageScrollButtons()
end)
