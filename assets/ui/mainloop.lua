--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Main Initialization)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Core Dependencies
-------------------------------------------------------------------------------
require("ui/helpers.lua")
require("ui/debug.lua")
require("sim/sim.lua")

-------------------------------------------------------------------------------
-- Core Helper Functions
-------------------------------------------------------------------------------

function LoadProductCategories()
	DebugOut("LOAD", "Executing items/categories.lua to define product hierarchies.")
	dofile("items/categories.lua")
end

-- Prompts once for a graceful save-and-quit sequence.
function AskQuit()
	-- Prevent stacked confirmation dialogs.
	if (not gQuitActive) and (not gTravelActive) then
		DebugOut("UI", "Prompting player for quit confirmation.")
		gQuitActive = true

		local yn = DisplayDialog { "ui/ui_generic_yn.lua", text="confirm_quit" }

		if yn == "yes" then
			DebugOut("SAVE", "Player confirmed quit. Saving game state.")
			Player:SaveGame()
			PostMessage(CreateNamedMessage(kQuitNow, "Quit"))
		else
			DebugOut("UI", "Player canceled quit prompt.")
			gQuitActive = false
		end
	end
end

-- Logs a compact startup count and optionally retains the full payload in developer mode.
local function LogLoadedItems(categoryName, itemTable, keyField)
	keyField = keyField or "code"
	local count = 0
	local codes = {}

	for _, item in ipairs(itemTable) do
		count = count + 1
		table.insert(codes, item[keyField])
	end

	-- Retain the full item list only when debug payload logging is enabled.
	DebugOut("LOAD", string.format("Loaded %d %s.", count, categoryName), { items = codes })
end

-------------------------------------------------------------------------------
-- Main Game Execution Loop
-------------------------------------------------------------------------------
function Main()
	DebugOut("GENERAL", "Initializing game main loop.")

	---------------------------------------------------------------------------
	-- 1. Splash Screens
	---------------------------------------------------------------------------
	DebugOut("UI", "Displaying introductory splash screens.")
	DisplaySplash("splash/playfirst_animated_logo.swf", "splash/playfirst_logo", 4000)
	DisplaySplash("splash/bigsplash_logo.jpg", "splash/bigsplash_logo", 3000)
	DisplaySplash("splash/distributor_logo.jpg", "splash/distributor_logo", 3000)

	-- Freeze on the title background while simulation data loads into memory
	DisplaySplash("", "image/title_background", 1)

	---------------------------------------------------------------------------
	-- 2. Data Initialization & Asset Loading
	---------------------------------------------------------------------------
	DebugOut("LOAD", "Beginning static asset payload execution.")

	-- Load standard ingredients
	LoadIngredients()
	LogLoadedItems("ingredients", _IngredientOrder, "code")

	-- Load categorization data
	LoadProductCategories()
	LogLoadedItems("categories", _CategoryOrder, "name")

	-- Load final products
	LoadProducts()
	local productCount = 0
	local productCodes = {}
	for code, _ in pairs(_AllProducts) do
		productCount = productCount + 1
		table.insert(productCodes, code)
	end
	table.sort(productCodes)
	DebugOut("LOAD", string.format("Loaded %d products.", productCount), { codes = productCodes })

	-- Load cities and locations
	LoadPorts()
	local portCount = 0
	local portNames = {}
	for name, _ in pairs(_AllPorts) do
		portCount = portCount + 1
		table.insert(portNames, name)
	end
	table.sort(portNames)
	DebugOut("LOAD", string.format("Loaded %d ports.", portCount), { names = portNames })

	-- Ensure required fallback categories exist.
	if not _AllCategories.user then
		DebugOut("LOAD", "User category missing; creating fallback 'user' category.")
		CreateCategory { name="user" }
	end

	-- Load mission definitions
	LoadQuests()
	local questCount = 0
	for _ in pairs(_AllQuests) do
		questCount = questCount + 1
	end
	DebugOut("LOAD", string.format("Loaded %d quests.", questCount))

	-- Load travel network
	dofile("ports/portroutes.lua")
	DebugOut("LOAD", "Port travel routes defined successfully.")

	-- Sort ingredients by ascending price.
	table.sort(_IngredientOrder, IngredientOrderFunction)

	---------------------------------------------------------------------------
	-- 3. Cross-Referencing & Data Bindings
	---------------------------------------------------------------------------
	DebugOut("LOAD", "Building game data cross-references.")
	PrepareCharactersForBuildings()
	PrepareCharactersForQuests()

	dofile("characters/character_data.lua")
	ApplyCharacterData()

	AssignProductCategories()
	DebugOut("LOAD", "Data cross-references built and applied.")

	-- Sort products within their assigned categories sequentially by product code
	for _, cat in pairs(_AllCategories) do
		table.sort(cat.products, function(a, b) return a.code < b.code end)
	end

	---------------------------------------------------------------------------
	-- 4. Simulator State Reset / Restoration
	---------------------------------------------------------------------------
	if GetNumUsers() > 0 then
		DebugOut("SAVE", "Existing user profiles detected. Loading current game state.")
		Player:LoadGame("story")
	else
		DebugOut("SAVE", "No user profiles detected. Resetting simulator for a fresh start.")
		Player:Reset()
	end

	-- Keep Catalogue preference discoveries aligned with the current character
	-- matrix when loading an older save.
	if ReconcileCharacterPreferenceDiscovery then
		ReconcileCharacterPreferenceDiscovery()
	end

	---------------------------------------------------------------------------
	-- 5. Localization & Dynamic Font Resolution
	---------------------------------------------------------------------------
	-- Load strings immediately after player/options are ready,
	-- but BEFORE the UI styles are loaded. This prevents Missing String errors
	-- from cascading through the UI upon launch.
	DebugOut("LOAD", "Reloading strings to match player options.")
	Player:ReloadStrings()

	-- With ingredients, categories, stock products, player state and localization
	-- all live, perform one read-only cross-reference of the simulation data.
	if ValidateSimulationData then ValidateSimulationData() end

	-- Determine target language (fallback to English)
	local lang = "en"
	if Player and Player.options and Player.options.language then
		lang = Player.options.language
	end

	-- Tracks the language currently loaded into the running string/font session.
	-- If the player changes language in Options, Player.options.language changes
	-- immediately, but gLoadedLanguage remains the old language until reboot.
	gLoadedLanguage = lang

	DebugOut("FONT", "Evaluating font mapping for active language.", { activeLanguage = lang })

	-- New modded addition: multi-language dynamic font support
	if lang == "ja" then
		standardFont = "fonts/shipporimincho.mvec"
		labelFontName = "fonts/shipporimincho.mvec"
		DebugOut("FONT", "Japanese language detected. Using Shippori Mincho as primary font.")

	elseif lang == "zhs" then
		standardFont = "fonts/notoserif-sc.mvec"
		labelFontName = "fonts/notoserif-sc.mvec"
		DebugOut("FONT", "Chinese (Simplified) detected. Using Noto Serif SC as primary font.")

	elseif lang == "zht" then
		standardFont = "fonts/notoserif-tc.mvec"
		labelFontName = "fonts/notoserif-tc.mvec"
		DebugOut("FONT", "Chinese (Traditional) detected. Using Noto Serif TC as primary font.")

	elseif lang == "ko" then
		standardFont = "fonts/nanummyeongjo.mvec"
		labelFontName = "fonts/nanummyeongjo.mvec"
		DebugOut("FONT", "Korean language detected. Using Nanum Myeongjo as primary font.")

	elseif lang == "ru" or lang == "uk" or lang == "sr" or lang == "bg" then
		standardFont = "fonts/gabriela.mvec"
		labelFontName = "fonts/gabriela.mvec"
		DebugOut("FONT", "Cyrillic language detected. Using Gabriela as primary font.")

	elseif lang == "el" then
		standardFont = "fonts/arima.mvec"
		labelFontName = "fonts/arima.mvec"
		DebugOut("FONT", "Greek language detected. Using Arima as primary font.")

	elseif lang == "hi" then
		standardFont = "fonts/notoserifdevanagari.mvec"
		labelFontName = "fonts/yatraone.mvec"
		DebugOut("FONT", "Hindi language detected. Using Noto Serif Devanagari (Body) and Yatra One (Display).")

	elseif lang == "bn" then
		standardFont = "fonts/notoserifbengali.mvec"
		labelFontName = "fonts/notoserifbengali.mvec"
		DebugOut("FONT", "Bengali language detected. Using Noto Serif Bengali as primary font.")

	elseif lang == "th" then
		standardFont = "fonts/trirong.mvec"
		labelFontName = "fonts/srisakdi.mvec"
		DebugOut("FONT", "Thai language detected. Using Trirong (Body) and Srisakdi (Display).")

	else
		standardFont = "fonts/fertigo.mvec"
		labelFontName = "fonts/choco3.mvec"
		DebugOut("FONT", "Default language detected. Using standard legacy game fonts.")
	end

	---------------------------------------------------------------------------
	-- 6. UI Rendering & Developer Tools
	---------------------------------------------------------------------------
	-- Now that global font variables are set safely, we can load the UI styles
	-- and the developer menu (if cheat mode is active).
	DebugOut("LOAD", "Injecting UI styles and Dev Menu assets.")
	require("ui/style.lua")

	if gDebugEnabled then
		require("dev/dev_menu.lua")
	else
		-- Safe no-op fallback. Map and Port screens call devMenu() directly,
		-- so this lets those files remain unchanged in normal player builds.
		function devMenu()
			return Group {}
		end
	end

	DebugOut("GENERAL", "All assets loaded successfully. Transitioning to main menu loop.")

	-- Push the game selection screen indefinitely
	while true do
		-- Maintained here to support potential dynamic reloading routines if implemented later,
		-- but the initial load step above handles the vital startup safety.
		Player:ReloadStrings()

		-- Launch the base menu panel
		DoMainWindow("ui/mainmenu.lua")

		-- NOTE: DoMainWindow will exit ONLY if there are NO windows pushed onto the stack.
		-- A PopModal() / PushModal() combination handles transitions safely without
		-- causing this to infinite-loop wildly.
	end
end

-------------------------------------------------------------------------------
-- Script Return
-------------------------------------------------------------------------------
-- Return the main execution function to be handled in an engine thread
return Main
