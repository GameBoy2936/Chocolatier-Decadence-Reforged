--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

require("ui/helpers.lua")
require("sim/sim.lua")

-- Global DebugOut override and log table initialization
gDebugLog = gDebugLog or {}
if not gOriginalDebugOut then
    gOriginalDebugOut = DebugOut
end

function DebugOut(category, message, object)
    -- If only one argument is passed, treat it as the message
    if message == nil then
        message = category
        category = "GENERAL" -- Default to Generic category
    end

    table.insert(gDebugLog, {
        timestamp = Player.time or 0,
        category = string.upper(category or "GENERAL"),
        message = tostring(message),
        object = object
    })
    
    if gOriginalDebugOut then
        -- Ensure message is not nil before formatting
        gOriginalDebugOut(string.format("[%s] %s", category or "GEN", message or "nil"))
    end
end

-- Global state for console filters
gDebugFilters = gDebugFilters or {
    searchTerm = "",
    categories = {
        SIM = true, PLAYER = true, QUEST = true, CHAR = true, BUILDING = true,
        HAGGLE = true, RECIPE = true, TIP = true, DEV = true, DIALOGUE = true,
        CATALOGUE = true, GENERAL = true, LOAD = true, ECONOMY = true, UI = true,
        AUDIO = true, FACTORY = true, SAVE = true, ERROR = true,
    }
}

function LoadProductCategories()
	dofile("items/categories.lua")
end

function AskQuit()
	-- Lock out quit confirmation, ask only once globally
	if (not gQuitActive) and (not gTravelActive) then
		gQuitActive = true
		local yn = DisplayDialog { "ui/ui_generic_yn.lua", text="confirm_quit" }
		if yn == "yes" then
			Player:SaveGame()
			PostMessage(CreateNamedMessage(kQuitNow, "Quit"))
		else
			gQuitActive = false
		end
	end
end

-- Helper function for detailed logging
local function LogLoadedItems(categoryName, itemTable, keyField)
    keyField = keyField or "code"
    local count = 0
    local codes = {}
    for _, item in ipairs(itemTable) do
        count = count + 1
        table.insert(codes, item[keyField])
    end
    DebugOut("LOAD", count .. " " .. categoryName .. " loaded: " .. table.concat(codes, ", "))
end

-- Main game loop
function Main()
	DisplaySplash( "splash/playfirst_animated_logo.swf", "splash/playfirst_logo", 4000 )
	DisplaySplash("splash/bigsplash_logo.jpg", "splash/bigsplash_logo",3000)
	DisplaySplash("splash/distributor_logo.jpg", "splash/distributor_logo",3000)

	-- Freeze on the title background while stuff loads...
	DisplaySplash("", "image/title_background",1)

	-- Prepare game data
	-- TODO: Load this stuff asynchronously?
	LoadIngredients()
    LogLoadedItems("ingredients", _IngredientOrder, "code")

	LoadProductCategories()
    LogLoadedItems("categories", _CategoryOrder, "name")

	LoadProducts()
    local productCount = 0
    local productCodes = {}
    for code,_ in pairs(_AllProducts) do
        productCount = productCount + 1
        table.insert(productCodes, code)
    end
    table.sort(productCodes)
    DebugOut("LOAD", productCount .. " products loaded.")

	LoadPorts()
    local portCount = 0
    local portNames = {}
    for name,_ in pairs(_AllPorts) do
        portCount = portCount + 1
        table.insert(portNames, name)
    end
    table.sort(portNames)
    DebugOut("LOAD", portCount .. " ports loaded.")
	
	-- Ensure some necessities
	if not _AllCategories.user then CreateCategory { name="user" } end

	LoadQuests()
    local questCount = 0
    for _ in pairs(_AllQuests) do questCount = questCount + 1 end
    DebugOut("LOAD", questCount .. " quests loaded.")
	
	dofile("ports/portroutes.lua")
	DebugOut("LOAD", "Port routes defined.")
	
	-- Sort ingredients by ascending price
	table.sort(_IngredientOrder, IngredientOrderFunction)
	
	-- Build game data cross-references
	PrepareCharactersForBuildings()
	PrepareCharactersForQuests()
	AssignProductCategories()
	DebugOut("LOAD", "Data cross-references built.")
	
	-- Sort products within categories by product code
	for _,cat in pairs(_AllCategories) do
		table.sort(cat.products, function(a,b) return a.code < b.code end)
	end
	
	-- Reset the simulator
	if GetNumUsers() > 0 then
		Player:LoadGame()
	else
		Player:Reset()
	end
	
    -- CRITICAL FIX: Load strings immediately after player/options are ready,
    -- but BEFORE the UI styles are loaded. This prevents "Missing String" errors
    -- during startup.
    Player:ReloadStrings()

	local lang = "en"
    if Player and Player.options and Player.options.language then
        lang = Player.options.language
    end
	
	-- New modded addition: multi-language support
    if lang == "ja" then
        standardFont = "fonts/shipporimincho.mvec"
        labelFontName = "fonts/shipporimincho.mvec"
        DebugOut("FONT", "Japanese language detected. Using Shippori Mincho as primary font.")
    elseif lang == "zhs" then
        standardFont = "fonts/notoserif-sc.mvec"
        labelFontName = "fonts/notoserif-sc.mvec"
        DebugOut("FONT", "Chinese (Simplified) language detected. Using Noto Serif SC as primary font.")
    elseif lang == "zht" then
        standardFont = "fonts/notoserif-tc.mvec"
        labelFontName = "fonts/notoserif-tc.mvec"
        DebugOut("FONT", "Chinese (Traditional) language detected. Using Noto Serif TC as primary font.")
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
        DebugOut("FONT", "Hindi language detected. Using Noto Serif Devanagari as primary font and Yatra One as display font.")
    elseif lang == "bn" then
        standardFont = "fonts/notoserifbengali.mvec"
        labelFontName = "fonts/notoserifbengali.mvec"
        DebugOut("FONT", "Bengali language detected. Using Noto Serif Bengali as primary font.")
    elseif lang == "th" then
        standardFont = "fonts/trirong.mvec"
        labelFontName = "fonts/srisakdi.mvec"
        DebugOut("FONT", "Thai language detected. Using Trirong as primary font and Srisakdi as display font.")
    else
        standardFont = "fonts/fertigo.mvec"
        labelFontName = "fonts/choco3.mvec"
        DebugOut("FONT", "Default language detected. Using standard game fonts.")
    end
	
    -- Now that the global font variables are set, we can load the style script and developer menu if cheat mode is on.
    require("ui/style.lua")
	require("dev/dev_menu.lua")
	
    DebugOut("LOAD", "All assets loaded. Entering main menu loop.")

	-- Push the game selection screen
	while true do
        -- We keep this here to support dynamic reloading if added later,
        -- but the initial load above handles the startup safety.
        Player:ReloadStrings()
		DoMainWindow("ui/mainmenu.lua");
		-- DoMainWindow will exit only if there are NO windows pushed on the stack, so
		-- a PopModal()/PushModal() combination will not cause this to loop.
    end
end

-- Return a function to be executed in a thread
return Main