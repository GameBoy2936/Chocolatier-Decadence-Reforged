--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Master Ledger UI)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- The Ledger is the persistent UI panel overlay at the bottom of the screen.
-- It provides access to all sub-menus and displays real-time factory data.

local fullLedgerHeight = 237
local badgeWidth = 162
local badgeHeight = 106

------------------------------------------------------------------------------
-- Main Menu Routing Handlers
------------------------------------------------------------------------------

local function InventoryButton()
	DebugOut("UI", "Ledger Navigation: Opened Player Inventory.")
	if gTravelActive then PauseTravel() end
	DisplayDialog{ "ui/inventory.lua" }
	if gTravelActive then ResumeTravel() end
end

local function RecipesButton()
	DebugOut("UI", "Ledger Navigation: Opened Recipe Book.")
	if gTravelActive then PauseTravel() end
	DisplayDialog{ "ui/ui_recipes.lua" }
	if gTravelActive then ResumeTravel() end
end

local function QuestButton()
	DebugOut("UI", "Ledger Navigation: Opened Quest Log.")
	if gTravelActive then PauseTravel() end
	DisplayDialog{ "ui/ui_questlog.lua" }
	if gTravelActive then ResumeTravel() end
end

local function DoMapPortButton()
	DebugOut("UI", "Ledger Navigation: Toggled Map/Port View.")
	if not gTravelActive then 
		SwapMapPortScreens() 
	end
end

local function PauseButton()
	DebugOut("UI", "Ledger Navigation: Opened System Pause Menu.")
	if gTravelActive then PauseTravel() end
	DisplayDialog{ "ui/ui_pause.lua" }
	if gTravelActive then ResumeTravel() end
end

local function MedalsButton()
	DebugOut("UI", "Ledger Navigation: Opened Medals & Awards.")
	if gTravelActive then PauseTravel() end
	DisplayDialog{ "ui/ui_medals.lua" }
	if gTravelActive then ResumeTravel() end
end

------------------------------------------------------------------------------
-- Factory Automation (Dookie Droppers)
------------------------------------------------------------------------------

-- Handles the "Remote Telegraph" interaction, allowing players who own the 
-- telephone upgrade to reconfigure factories without physically traveling to them.
local function FactoryPhone(factory)
	if factory:IsOwned() and Player.questVariables.ownphone == 1 then
		DebugOut("UI", string.format("Remote Telegraph invoked for factory: %s", factory.name))
		
		gCurrentFactory = factory
		local info = Player.factories[factory.name]
		gRecipeSelection = _AllProducts[info.current]
		
		-- Open the recipe book filtered for this factory
		local ok = DisplayDialog { "ui/ui_recipes.lua", factory = factory, building = factory }
		
		local product = gRecipeSelection
		gRecipeSelection = nil
		
		if product and ok then
			DebugOut("UI", string.format("Remote Telegraph: Successfully transmitted new configuration -> %s", product:GetName()))
			factory:SetProduction(product)
		else
			DebugOut("UI", "Remote Telegraph: Configuration change cancelled by player.")
		end
		
		gCurrentFactory = nil
	end
end

-- Constructs the visual tracking tubes (internally called "Dookie Droppers") 
-- for each factory. They display the active product color and supply levels.
local function AddDookieDropper(x, y, f)
	local factory = f
	return DookieDropper { 
		x = x, y = y, w = 79, h = 132, 
		name = factory.name, 
		factory = factory,
		
		-- Displays the standard tooltip when hovering
		contents = factory.name .. ":LedgerRolloverPopup()",
		
		-- Clicking the dropper attempts to trigger the remote configuration hook
		command = function() FactoryPhone(f) end,
		
		Text { x = 0, y = 0, w = kMax, h = 14, name = "port", label = "#" .. GetString(factory.port.name), flags = kVAlignCenter + kHAlignCenter },
		Text { x = 34, y = 70, w = kMax, h = 32, name = "count", label = "", flags = kVAlignCenter + kHAlignCenter, font = DookieDropperCounterFont },

		itemx = 18, itemy = 86,
		countx = 57, county = 86,
		ingredienty = 58, barHeight = 42,
	}
end

------------------------------------------------------------------------------
-- Visual Layout Construction
------------------------------------------------------------------------------

-- Covers obscure the Dookie Droppers until the player actually purchases the corresponding factory
local covers = {}
table.insert(covers, Bitmap { x = 229, y = 150, name = "zur_factory_cover", image = "image/ledger_cover_1" })
table.insert(covers, Bitmap { x = 311, y = 150, name = "cap_factory_cover", image = "image/ledger_cover_2" })
table.insert(covers, Bitmap { x = 391.5, y = 150, name = "tok_factory_cover", image = "image/ledger_cover_3" })
table.insert(covers, Bitmap { x = 472, y = 150, name = "san_factory_cover", image = "image/ledger_cover_4" })
table.insert(covers, Bitmap { x = 555, y = 150, name = "tor_factory_cover", image = "image/ledger_cover_5" })
table.insert(covers, Bitmap { x = 637, y = 150, name = "wel_factory_cover", image = "image/ledger_cover_6" })

local uiColor = Color(208, 208, 208, 255)

MakeDialog
{
	name = "ledger",

	SetStyle(controlStyle),
	Bitmap { 
		x = kLedgerPositionX, y = kLedgerPositionY, 
		image = "image/badge_and_ledger", 
		name = "ledger_background",
		
		-- Primary Quest Tracking Banner
		Bitmap { x = 181, y = 29, name = "ledger_questgoals", image = "image/badge_button_indicator_incomplete" },
		Button { 
			x = 267, y = 78, w = 442, h = 34, 
			graphics = {}, 
			command = function() 
				DebugOut("UI", "Ledger Quest Banner clicked."); 
				DisplayDialog { "ui/ui_questlog.lua" } 
			end,
			Text { x = 0, y = 0, w = kMax, h = kMax, name = "questText", flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 17, Color(0, 0, 0, 255) } },
		},
		
		-- Compile the factory indicators
		AppendStyle { font = DookieDropperFont, flags = kVAlignCenter + kHAlignCenter },
		AddDookieDropper(229, 150, zur_factory),
		AddDookieDropper(311, 150, cap_factory),
		AddDookieDropper(393, 150, tok_factory),
		AddDookieDropper(475, 150, san_factory),
		AddDookieDropper(557, 150, tor_factory),
		AddDookieDropper(639, 150, wel_factory),
		Group(covers),

		-- Compile Badge Metadeta (Wallet, Time, Score)
		Text { name = "money", x = 46, y = 145, w = 150, h = 30, label = "#" .. Dollars(Player.money), flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 30, uiColor } },
		Text { name = "day", x = 51, y = 175, w = 140, h = 15, label = "#" .. Date(Player.time), flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 15, uiColor } },
		Text { name = "rank", x = 51, y = 190, w = 140, h = 15, label = "", flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 15, uiColor } },
		Text { name = "score", x = 58, y = 210, w = 126, h = 15, label = "", flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 15, uiColor } },
		Text { name = "rawtime", x = 58, y = 245, w = 126, h = 15, label = "", flags = kHAlignCenter + kVAlignCenter, font = { uiFontName, 15, BlackColor } },
	},
	
	-- Compile Navigational Badge Buttons
	SetStyle(C3ButtonStyle),
	AppendStyle { graphics = { "image/badge_button_big_up_blank", "image/badge_button_big_down_blank", "image/badge_button_big_over_blank" }, mask = "image/badge_button_big_mask" },
	
	LargeLedgerButton { x = kLedgerPositionX + 65, y = kLedgerPositionY - 19, name = "inventory", label = "inventory", command = InventoryButton },
	LargeLedgerButton { x = kLedgerPositionX - 3, y = kLedgerPositionY + 3, name = "recipes", label = "recipes", command = RecipesButton },
	LargeLedgerButton { x = kLedgerPositionX + 134, y = kLedgerPositionY + 3, name = "quest_log", label = "quest_log", command = QuestButton },
	
	-- The Map/Port buttons overlay each other and toggle visibility based on the current scene
	MapPortButton { 
		x = kLedgerPositionX + 45, y = kLedgerPositionY + 36, 
		name = "map_port", command = DoMapPortButton,
		graphics = { "image/badge_button_map_up_blank", "image/badge_button_map_down_blank", "image/badge_button_map_over_blank" },
		label = "ledger_port",
		mask = "image/badge_button_map_mask" 
	},
	MapPortButton { 
		x = kLedgerPositionX + 45, y = kLedgerPositionY + 36, 
		name = "port_map", command = DoMapPortButton,
		graphics = { "image/badge_button_map_up_blank", "image/badge_button_map_down_blank", "image/badge_button_map_over_blank" },
		label = "ledger_map",
		mask = "image/badge_button_map_mask" 
	},

	AppendStyle { graphics = { "image/badge_button_small_up_blank", "image/badge_button_small_down_blank", "image/badge_button_small_over_blank" }, mask = "image/badge_button_small_round_mask" },
	
	SmallLedgerButton { x = kLedgerPositionX - 3, y = kLedgerPositionY + 174, name = "mainmenu", label = "menu", command = PauseButton, cancel = true },
	SmallLedgerButton { x = kLedgerPositionX + 70, y = kLedgerPositionY + 194, name = "catalogue", label = "ledger_catalogue", command = function() DisplayDialog{ "ui/ui_catalogue.lua" } end },
	SmallLedgerButton { x = kLedgerPositionX + 140, y = kLedgerPositionY + 174, name = "medals", label = "ledger_medals", command = MedalsButton },
}

-- Force the UI to refresh its text fields immediately upon rendering
QueueCommand(function() UpdateLedger("newplayer") end)