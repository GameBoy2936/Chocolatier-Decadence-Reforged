--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Player Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- The "Player" class is the repository for all player-specific game state.
-- This singleton table tracks everything from inventory to quest progression.
Player =
{
	-- ==========================================
	-- Core Identity & Progression
	-- ==========================================
	name = nil,						-- Player name
	time = nil,						-- Current game time (WEEKS since start date)
	subticks = nil,					-- Number of sub-ticks (transactions/actions)
	money = nil,					-- Current wealth
	
	stringTable = {},				-- Player-specific replacement strings (e.g., custom names)
	
	rank = 1,						-- Current rank tier (Determines travel range, title, etc.)
	medals = {},					-- Table of awarded medals { medal_key = true }
	lastMedal = nil,				-- The most recently received medal
	
	-- ==========================================
	-- Travel & Navigation
	-- ==========================================
	portName = nil,					-- Current port NAME (e.g., "zurich")
	destination = nil,				-- Port the player is currently traveling to
	portsAvailable = {},			-- Port availability states ("new", "open", "locked", "hidden", "factory", etc.)
	portsCost = {},					-- Cost to travel to the specified port from the current location
	portsVisited = {},				-- Set of { port_name = true } for ports visited
	portVisitCount = 0,				-- Total number of unique ports visited
	lastVisitTime = {},				-- Tracks the last week the player visited a port { port_name = week_number }
	lastPort = nil,					-- The name of the port the player was last in
	encounterTimer = nil,			-- Countdown to forced travel encounters (e.g., bandits/events)
	
	-- ==========================================
	-- Inventory & Recipes
	-- ==========================================
	ingredients = {},				-- Set of { name = count } for player ingredient inventory
	products = {},					-- Set of { code = count } for player product inventory
	useTimes = {},					-- Set of { name/code = count } tracking the last time an item was used
	
	knownRecipes = {},				-- Set of { code = true } for recipes the player has gathered
	categoryCount = {},				-- Set of { name = count } for number of recipes known in each category
	categoryMadeCount = {},			-- Set of { name = count } for number of recipes made in each category
	customSlots = nil,				-- Number of available recipe creation slots
	
	labIngredients = {},			-- Set of { name = true } for player's lab/kitchen ingredients inventory
	labFirstUse = {},				-- Teddy's memory of first-time ingredient uses
	lastTastedRecipeCode = nil,		-- Teddy's memory of the last bad recipe tasted
	ingredientsAvailable = {},		-- Set of { name = true/false } to override default ingredient availability
	
	-- ==========================================
	-- Buildings, Factories & Shops
	-- ==========================================
	buildingsOwned = {},			-- Buildings owned { name = true }
	buildingsEnabled = {},			-- Buildings enabled { name = true }
	buildingsBlocked = {},			-- Buildings blocked { name = true }
	buildingsVisited = {},		  	-- Buildings visited { name = true }
	buildingCharacters = {},		-- Temporary character placement { building = { characterName = true } }
	buildingLastVisitTime = {},	 	-- Tracks the last week the player visited a specific building
	
	factoriesOwned = nil,			-- Number of factories owned
	factoryAcquiredTime = {},		-- Tracks the week each factory was acquired { factory_name = week_number }
	factoryTopProduct = {},			-- Tracks the best product made at each factory { factory_name = { code="b01", count=50 } }
	factoryTotalProduction = {},	-- Tracks total cases produced at each factory { factory_name = total_cases }
	factories = {},					-- Factory configurations { name={ current=<product>, supply=<n>, stall=<t/f>, needs={}, output={} } }
	
	powerups = {},					-- Set of { key = true } for powerup settings
	needs = {},						-- Ingredient needs to keep all factories going for one tick
	supply = {},					-- Number of ticks worth of ingredients available for full consumption
	shopsOwned = nil,				-- Number of shops owned
	
	-- ==========================================
	-- Economy & Commerce Data
	-- ==========================================
	itemPrices = {},				-- Current prices of all items { code/name = price }
	itemsMade = {},					-- Set of { code = count } for products made globally
	itemsSold = {},					-- Set of { code = count } for products sold globally
	
	lastSeenPort = {},				-- Set of { item_key = port_name } for "last seen in" port info
	lastSeenPrice = {},				-- Set of { item_key = price } for "last seen/sold for" price info
	lowPrice = {},					-- Set of { item_key = price } for historical low price tracking
	highPrice = {},					-- Set of { item_key = port_name } for historical high price tracking
	
	firstEverBuy = {},				-- Tracks the absolute first time buying an ingredient { ingredient_name = true }
	firstEverSell = {},				-- Tracks the absolute first time selling a product { product_code = true }
	firstBuy = {},					-- Tracks first time buying an ingredient FROM A SPECIFIC PORT {[port_name] = { [ingredient_name] = true } }
	firstSell = {},					-- Tracks first time selling a product TO A SPECIFIC PORT { [port_name] = { [product_code] = true } }
	firstSellCategory = {},			-- Tracks first time selling a product from a category {[port_name] = { [category_name] = true } }
	
	itemRecipes = {},				-- Set of { index = code_table } for custom invented recipes
	itemAppearance = {},			-- Set of { code = product_layers } for invented recipes
	itemNames = {},					-- Set of { code = name } for player-named products
	itemDescriptions = {},			-- Set of { code = description } for player-named products
	itemMachinery = {},				-- Set of { code = machinery_name } for invented recipes
	
	-- ==========================================
	-- Quests & Orders
	-- ==========================================
	questPrimary = nil,				-- NAME of "primary" quest selected for display on the ledger
	questStarters = {},				-- Set of { quest_name = char_name } for starters of active quests
	questOfferText = {},			-- Set of offer text for quests
	questsActive = {},				-- Set of { name = startTime } for active quests
	questsWaiting = {},				-- Set of { name = targetTime } for quests waiting for a particular time
	questsComplete = {},			-- Set of { name = endTime } for completed OR REJECTED quests
	questsDeferred = {},			-- Set of { name = availableTime } for deferred quests
	questVariables = {},			-- Set of { name = value } variables for use by quest scripting
	questDifficulty = {},			-- Set of { name = difficulty } for active quests
	questHintCooldowns = {},		-- Set of { quest_name = endTime } for hint cooldowns
	
	lastOfferTime = nil,			-- Time of last offered quest
	lastAcceptTime = nil,			-- Time of last accepted quest
	lastCompleteTime = nil,			-- Time of last completed quest
	lastOrderTime = nil,			-- Time of last special order
	
	shopOrderData = {},	 			-- Stores { chance=X } for each owned shop
	pendingSpecialOrders = {},	 	-- A queue for generated orders waiting for delivery
	orderEligibleChars = {},		-- Characters explicitly allowed to receive orders
	orderBannedChars = {},		  	-- Characters temporarily banned from receiving orders
	orderBannedBuildings = {},	  	-- Buildings temporarily banned from being order locations
	
	-- ==========================================
	-- Characters, Holidays & Meta
	-- ==========================================
	charHappiness = {},				-- Character happiness levels
	charHappinessTime = {},			-- Last time character happiness was set
	
	currentHolidays = {},		   	-- Table of currently active holidays { holidayName = true }
	holidayAnnouncements = {},	  	-- Tracks the last year a holiday was announced { holidayName = year }
	
	activeTips = {},				-- Table for active tutorial tips
	pendingAnnouncements = {},	  	-- Table for tips waiting to be announced
	
	catalogue = {},					-- Master table for all catalogue data (Unlocked entries, met characters, etc.)
	
	options = {},					-- Player option settings (e.g., languages, UI toggles)
	difficulty = 1,					-- 1 = Easy, 2 = Medium, 3 = Hard
	haggleDisable = {},				-- Player haggle options (name = true to disable, otherwise enabled)
}

------------------------------------------------------------------------------
-- Core Setup & Helpers
------------------------------------------------------------------------------

-- Utility function to easily pull difficulty-scaled values
function GetDifficultyValue(easy, medium, hard)
	local difficulty = Player.difficulty or 1
	
	if difficulty == 3 then
		return hard
	elseif difficulty == 2 then
		return medium
	else 
		-- Default to Easy
		return easy
	end
end

------------------------------------------------------------------------------
-- Localization & Strings
------------------------------------------------------------------------------

-- Ability to support multiple languages dynamically
function Player:ReloadStrings()
	DebugOut("LOAD", "Initiating localized string reload sequence.")
	
	local coreFiles = {
		"strings.xml",
		"dialogue_strings.xml",
		"catalogue_strings.xml"
	}

	-- Gather quest-specific localization
	local questLuaFiles = {}
	LoadQuestFileList(questLuaFiles)
	
	local allFilesToLoad = {}
	for _, file in ipairs(coreFiles) do table.insert(allFilesToLoad, file) end
	for _, luaFile in ipairs(questLuaFiles) do
		-- Convert .lua script names to their expected .xml string file counterparts
		table.insert(allFilesToLoad, (string.gsub(luaFile, ".lua", "_strings.xml")))
	end
	
	-- 1. FLUSH CACHE: Clear the old strings before loading new ones to prevent bleed-over.
	ClearStringCache()

	-- 2. Load the ROOT (English default) assets as a base
	for _, filename in ipairs(allFilesToLoad) do
		bsgLoadStringFile(filename)
	end

	-- 3. Load the LANGUAGE overrides on top of the root assets
	local lang = self.options.language or "en"
	if lang ~= "en" then
		DebugOut("LOAD", string.format("Applying translation files for language override: '%s'", lang))
		local pathPrefix = "languages/" .. lang .. "/"
		for _, filename in ipairs(allFilesToLoad) do
			bsgLoadStringFile(pathPrefix .. filename)
		end
	end
	
	DebugOut("LOAD", "String reload complete.")
end

------------------------------------------------------------------------------
-- State Restoration & Save Initializing
------------------------------------------------------------------------------

function Player:Reset(restoreTable)
	DebugOut("PLAYER", "Initiating Player:Reset(). Rebuilding state from save data or fresh start.")

	-- First, restore any saved delivery quests
	if restoreTable and restoreTable.deliveries then
		for _,t in ipairs(restoreTable.deliveries) do CreateDeliveryQuest(t) end
		restoreTable.deliveries = nil
	end
	
	-- Clear out the current player's custom recipes from the global product list 
	-- to prevent old session bleed. (Re-added further below)
	for _,code in ipairs(self.itemRecipes) do _AllProducts[code] = nil end
	
	local t = restoreTable or {}
	
	-- Core Data
	self.name = t.name or nil
	self.time = t.time or 1
	self.subticks = t.subticks or 0
	self.money = t.money or 0
	self.rank = t.rank or 1
	self.medals = t.medals or {}
	self.lastMedal = t.lastMedal or nil
	
	-- Navigation Data
	self.portName = t.portName or t.destination
	if self.portName == "error" then 
		self.portName = nil 
	end
	self.destination = nil
	self.portsAvailable = t.portsAvailable
	self.portsCost = t.portsCost
	self.portsVisited = t.portsVisited or {}
	self.portVisitCount = t.portVisitCount or 0
	self.lastVisitTime = t.lastVisitTime or {}
	self.lastPort = t.lastPort or nil
	
	-- Inventory & Market Trackers
	self.ingredients = t.ingredients or {}
	self.products = t.products or {}
	self.lastSeenPort = t.lastSeenPort or {}
	self.lastSeenPrice = t.lastSeenPrice or {}
	self.lowPrice = t.lowPrice or {}
	self.highPrice = t.highPrice or {}
	
	-- Recipe Knowledge
	self.useTimes = t.useTimes or {}
	self.knownRecipes = t.knownRecipes or { b01=true,b02=true,b03=true,b04=true,b05=true,b06=true,b07=true,b08=true,b09=true,b10=true,b11=true,b12=true }
	self.categoryCount = t.categoryCount or { bar=12 }
	self.categoryMadeCount = t.categoryMadeCount or {}
	self.ingredientsAvailable = t.ingredientsAvailable or {}
	self.labIngredients = t.labIngredients or {}
	self.labFirstUse = t.labFirstUse or {}
	self.lastTastedRecipeCode = t.lastTastedRecipeCode or nil
	
	-- Buildings & Factories
	self.buildingsOwned = t.buildingsOwned or {}
	self.buildingsEnabled = t.buildingsEnabled or {}
	self.buildingsBlocked = t.buildingsBlocked or {}
	self.buildingsVisited = t.buildingsVisited or {}
	self.buildingCharacters = t.buildingCharacters or {}
	self.factoriesOwned = t.factoriesOwned or 0
	self.factoryAcquiredTime = t.factoryAcquiredTime or {}
	self.factoryTopProduct = t.factoryTopProduct or {}
	self.factoryTotalProduction = t.factoryTotalProduction or {}
	self.shopsOwned = t.shopsOwned or 0
	
	self.factories = t.factories or {}
	self.powerups = t.powerups or {}
	self.needs = t.needs or {}
	self.supply = t.supply or {}
	
	-- Economy & Creation
	self.itemPrices = t.itemPrices or {}
	self.itemRecipes = t.itemRecipes or {}
	self.itemsMade = t.itemsMade or {}
	self.itemsSold = t.itemsSold or {}
	self.firstEverBuy = t.firstEverBuy or {}
	self.firstEverSell = t.firstEverSell or {}
	self.firstBuy = t.firstBuy or {}
	self.firstSell = t.firstSell or {}
	self.firstSellCategory = t.firstSellCategory or {}
	self.itemAppearance = t.itemAppearance or {}
	self.itemNames = t.itemNames or {}
	self.itemDescriptions = t.itemDescriptions or {}
	self.itemMachinery = t.itemMachinery or {}
	self.customSlots = t.customSlots or 0
	
	-- Quests
	self.questPrimary = t.questPrimary or nil
	self.questStarters = t.questStarters or {}
	self.questOfferText = t.questOfferText or {}
	self.questsActive = t.questsActive or {}
	self.questsWaiting = t.questsWaiting or {}
	self.questsComplete = t.questsComplete or {}
	self.questsDeferred = t.questsDeferred or {}
	self.questDifficulty = t.questDifficulty or {}
	self.questVariables = t.questVariables or { ugr_slots=0 }
	self.questHintCooldowns = t.questHintCooldowns or {}
	self.lastOfferTime = t.lastOfferTime or 0
	self.lastAcceptTime = t.lastAcceptTime or 0
	self.lastCompleteTime = t.lastCompleteTime or 0
	self.lastOrderTime = t.lastOrderTime or 0
	self.shopOrderData = t.shopOrderData or {}
	self.pendingSpecialOrders = t.pendingSpecialOrders or {}
	self.orderEligibleChars = t.orderEligibleChars or {}
	self.orderBannedChars = t.orderBannedChars or {}
	self.orderBannedBuildings = t.orderBannedBuildings or {}
	self.encounterTimer = t.encounterTimer or 10
	self.activeTips = t.activeTips or {}
	self.pendingAnnouncements = t.pendingAnnouncements or {}
	
	-- Characters & Environment
	self.charHappiness = t.charHappiness or {}
	self.charHappinessTime = t.charHappinessTime or {}
	
	self.currentHolidays = t.currentHolidays or {}
	self.holidayAnnouncements = t.holidayAnnouncements or {}
	self.buildingLastVisitTime = t.buildingLastVisitTime or {}
	
	-- Catalogue Data
	self.catalogue = t.catalogue or {}
	self.catalogue.unlockedHistory = self.catalogue.unlockedHistory or {}
	self.catalogue.unlockedCharacters = self.catalogue.unlockedCharacters or {}
	self.catalogue.unlockedIngredients = self.catalogue.unlockedIngredients or {}
	self.catalogue.charactersMet = self.catalogue.charactersMet or {}
	self.catalogue.unlockedPorts = self.catalogue.unlockedPorts or {}
	self.catalogue.discoveredBuildings = self.catalogue.discoveredBuildings or {}
	self.catalogue.discoveredIngredientLocations = self.catalogue.discoveredIngredientLocations or {}
	self.catalogue.discoveredIngredientSeasons = self.catalogue.discoveredIngredientSeasons or {}
	
	-- Settings
	self.options = t.options or { showCompletedQuests=false, tut_stall=true }
	self.difficulty = t.difficulty or 1
	self.haggleDisable = t.haggleDisable or {}

	-- Prepare ports available info for a new game if missing
	if not t.portsAvailable then
		self.portsAvailable = {}
		for name,port in pairs(_AllPorts) do
			if port.hidden then self.portsAvailable[name] = "hidden"
			elseif port.locked then self.portsAvailable[name] = "locked"
			else self.portsAvailable[name] = "new"
			end
		end
	end
	
	if not t.portsCost then
		PrepareTravelPrices()
	end
	
	-- Prepare _travelers and _empty characters for a new game
	if (self.time == 1) or (not self.buildingCharacters._travelers) then
		self.buildingCharacters._travelers = {}
		for _,name in ipairs(_TravelCharacters) do
			self.buildingCharacters._travelers[name] = true
		end
	end
	if (self.time == 1) or (not self.buildingCharacters._empty) then
		self.buildingCharacters._empty = {}
		for _,name in ipairs(_EmptyCharacters) do
			self.buildingCharacters._empty[name] = true
		end
	end
	
	-- Prepare player's replacement strings
	self.stringTable = { player = self.name }

	-- Restore player-created custom recipes
	local category = _AllCategories["user"]
	category:Clear()
	self.categoryCount["user"] = 0
	
	for i, codeTable in ipairs(self.itemRecipes) do
		local prod = BuildCustomProduct(codeTable)
		self.stringTable["user"..tostring(i)] = prod:GetName()
		DebugOut("RECIPE", string.format("Restored custom recipe '%s' from save data.", prod:GetName()))
	end
	self.questVariables.ugr_slots = self.customSlots - (self.categoryCount.user or 0)
	
	-- Reset the recipe book view pointers
	gCategorySelection = nil
	gRecipeSelection = nil
	
	-- Initial location handling
	if not restoreTable or not self.portName then
		DebugOut("PLAYER", "Starting a completely fresh game. Routing to Zurich.")
		self:SetPort("zurich")
	end

	-- Catalogue Default Unlocks
	if not restoreTable then
		DebugOut("CATALOGUE", "New game detected. Unlocking default catalogue ingredient entries.")
		for _, ing in ipairs(_IngredientOrder) do
			if not ing.locked then
				self.catalogue.unlockedIngredients[ing.name] = true
			end
		end
	else
		-- This is a LOADED GAME. Perform a one-time migration check to fix older saves
		for _, ing in ipairs(_IngredientOrder) do
			if not ing.locked and not self.catalogue.unlockedIngredients[ing.name] then
				self.catalogue.unlockedIngredients[ing.name] = true
				DebugOut("CATALOGUE", string.format("MIGRATION: Retroactively unlocked default ingredient '%s'.", ing.name))
			end
		end
	end
	
	-- Synchronize holiday states immediately on load
	self:UpdateHolidays()

	-- CRITICAL FIX: Reload strings NOW that options and difficulty are fully set.
	self:ReloadStrings()
	
	DebugOut("PLAYER", string.format("Player Reset complete. Name: %s, Money: %s, Rank: %d", tostring(self.name or "N/A"), Dollars(self.money), self.rank))
end

------------------------------------------------------------------------------
-- External Service Logging
------------------------------------------------------------------------------

local PFMedalKeys =
{
	"chocolatier-decadence-design_up_comer_cup",
	"chocolatier-decadence-design_chocolate",
	"chocolatier-decadence-design_coffee",
	"chocolatier-decadence-design_creative",
	"chocolatier-decadence-design_2ndshop",
	"chocolatier-decadence-design_factories",
	"chocolatier-decadence-design_achievement",
	"chocolatier-decadence-design_port",
	"chocolatier-decadence-design_recipe"
}

function Player:LogScore()
	local time = self.time or 1
	local money = self.money or 0
	local rank = self.rank or 1
	local score = Floor(money / time)
	
	if score > 0 then
		-- Prepare server data string: R-WWWWWWWWW-MMMMMMMMMMMM
		local stringData = string.format("%d-%09d-%012.0f", rank, time, money)
		
		-- Construct XML blob for achieved medals
		local medalXML = ""
		for i=1, 9 do
			local key = "medal_0"..tostring(i)
			if self.medals[key] then
				medalXML = medalXML .. "<medal name='" .. PFMedalKeys[i] .. "' per='game' />"
			end
		end
		
		DebugOut("PLAYER", string.format("Logging final score to platform: %d (Data: %s)", score, stringData))
		LogScore(score, stringData, medalXML)
	end
end

-------------------------------------------------------------------------------
-- Reforged v2 Ingredient Migration
-------------------------------------------------------------------------------
-- This table retroactively unlocks v2 ingredients for players migrating from
-- Reforged v1 saves. Each row corresponds to the quest event that now unlocks
-- the ingredient in the v2 quest files.
--
-- trigger = "accepted"
--     Unlock if the quest is active, completed, or recorded as accepted-ever.
--     Used for ingredients awarded from onaccept/onaccept_medium/onaccept_hard.
--
-- trigger = "completed"
--     Unlock only if the quest is completed.
--     Used for ingredients awarded from oncomplete/oncomplete_medium/oncomplete_hard.
-------------------------------------------------------------------------------

local migrationUnlocks =
{
	-- Rank 2 / early-mid progression
	{ quest = "rank2_07", ingredient = "apricot", stage = "completed" },
	{ quest = "tokyo_02", ingredient = "apricot", stage = "completed" },
	{ quest = "rank2_38", ingredient = "chamomile", stage = "completed" },
	{ quest = "ugr_03", ingredient = "cranberry", stage = "accepted" },
	{ quest = "hav_shop_01", ingredient = "guava", stage = "accepted" },
	{ quest = "rank2_coffee19", ingredient = "ice_cream", stage = "completed" },
	{ quest = "open_bali", ingredient = "jasmine", stage = "accepted" },
	{ quest = "rank2_32", ingredient = "lemongrass", stage = "completed" },
	{ quest = "rank2_sanfrancisco", ingredient = "marshmallow", stage = "accepted" },
	{ quest = "rank2_coffee03", ingredient = "oat", stage = "completed" },
	{ quest = "rank2_tokyo", ingredient = "pear", stage = "accepted" },
	{ quest = "rank2_30", ingredient = "plum", stage = "accepted" },
	{ quest = "rank2_39", ingredient = "rosemary", stage = "completed" },

	-- Rank 3 progression
	{ quest = "off_to_whitney", ingredient = "earl_grey", stage = "accepted" },
	{ quest = "rank3_03", ingredient = "peach", stage = "accepted" },
	{ quest = "rank3_09", ingredient = "rhubarb", stage = "completed" },
	{ quest = "rank3_06", ingredient = "rooibos", stage = "accepted" },
	{ quest = "rank3_02", ingredient = "tamarind", stage = "completed" },
	{ quest = "meta_joseph", ingredient = "wafer", stage = "accepted" },
	{ quest = "rank3_05", ingredient = "jasmine", stage = "completed" },

	-- Rank 4 / plot progression
	{ quest = "rank4_sean_return", ingredient = "dragonfruit", stage = "completed" },
	{ quest = "plot_points_07", ingredient = "yuzu", stage = "accepted" },
}

function Player:ApplyV2IngredientMigration()
	self.catalogue = self.catalogue or {}
	self.catalogue.unlockedIngredients = self.catalogue.unlockedIngredients or {}
	self.ingredientsAvailable = self.ingredientsAvailable or {}
	self.questsActive = self.questsActive or {}
	self.questsComplete = self.questsComplete or {}
	self.questsAcceptedEver = self.questsAcceptedEver or {}

	local migratedCount = 0

	for _, data in ipairs(migrationUnlocks) do
		local questName = data.quest
		local ingredientName = data.ingredient
		local ing = _AllIngredients[ingredientName]

		if ing then
			local questMatches = false

			if data.trigger == "accepted" then
				questMatches =
					self.questsAcceptedEver[questName] ~= nil or
					self.questsActive[questName] ~= nil or
					self.questsComplete[questName] ~= nil
			else
				questMatches = self.questsComplete[questName] ~= nil
			end

			local ingredientMissing =
				(not ing:IsAvailable()) or
				(not self.catalogue.unlockedIngredients[ingredientName])

			if questMatches and ingredientMissing then
				ing:Unlock()
				self.catalogue.unlockedIngredients[ingredientName] = true
				migratedCount = migratedCount + 1

				DebugOut("MIGRATION", string.format(
					"V2 ingredient migration: unlocked '%s' from quest '%s' (%s).",
					ingredientName,
					questName,
					data.trigger
				))
			end
		else
			DebugOut("ERROR", string.format(
				"V2 ingredient migration references undefined ingredient '%s' for quest '%s'.",
				tostring(ingredientName),
				tostring(questName)
			))
		end
	end

	if migratedCount > 0 then
		DebugOut("MIGRATION", string.format(
			"V2 ingredient migration complete. Retroactively unlocked %d ingredient(s).",
			migratedCount
		))
	end
end

------------------------------------------------------------------------------
-- Save / Load Functions
------------------------------------------------------------------------------

-- Recursive helper to construct a valid Lua string representation of a table
local function AppendTableToString(t, stringTable)
	for k,v in pairs(t) do
		-- If key is a sequential number, omit the explicit key assignment
		local key
		if type(k) == "number" then key = ""
		else key = k.."="
		end
		
		if type(v) == "string" then
			table.insert(stringTable, string.format("%s%q,", key, v))
		elseif type(v) == "number" or type(v) == "boolean" then
			table.insert(stringTable, string.format("%s%s,", key, tostring(v)))
		elseif type(v) == "table" then
			table.insert(stringTable, string.format("%s{", key))
			AppendTableToString(v, stringTable)
			table.insert(stringTable, "},")
		elseif type(v) == "function" then
			-- Functions are skipped intentionally
		end
	end
end

function Player:BuildSaveGameString()
	DebugOut("SAVE", "Constructing save game data string.")
	local saveStringTable = { "return {", }
	AppendTableToString(Player, saveStringTable)
	
	-- Build specialized save tables for active delivery quests
	table.insert(saveStringTable, "deliveries={")
	for name,_ in pairs(self.questsActive) do
		local q = _AllQuests[name]
		if q.GetSaveTable then
			local t = q:GetSaveTable()
			table.insert(saveStringTable, "{")
			AppendTableToString(t, saveStringTable)
			table.insert(saveStringTable, "},")
		end
	end
	table.insert(saveStringTable, "}}")
	
	return table.concat(saveStringTable)
end

function Player:AutoSave()
	-- Auto save every 4 minutes of real time
	local elapsedTime = CurrentTime() - (self.lastSave or CurrentTime())
	local remain = (4 * 60 * 1000) - elapsedTime
	
	if remain <= 0 then 
		DebugOut("SAVE", "Autosave timer triggered.")
		self:SaveGame() 
	end
end

function Player:SaveGame()
	if GetNumUsers() > 0 then
		local saveString = Player:BuildSaveGameString()
		SaveGameString(saveString)
		DebugOut("SAVE", "Game saved for player " .. tostring(self.name or "N/A"))
	end
	self.lastSave = CurrentTime()
end

function Player:LoadGame()
	local saveString = LoadGameString()
	if saveString and saveString ~= "" then
		DebugOut("LOAD", "Loading game from default internal save slot.")
		local loadTable = loadstring(saveString)
		if type(loadTable) == "function" then loadTable = loadTable() end
		if type(loadTable) == "table" then Player:Reset(loadTable) end
		
		local name = GetCurrentUserName()
		if name then
			Player.name = name
			Player.stringTable.player = Player.name
		end
		
		UpdateLedger("newplayer")
		self.lastSave = CurrentTime()
	else
		DebugOut("LOAD", "No save data found in default slot.")
	end
end

function Player:SaveGameToFile(fileName)
	if not fileName then fileName = DisplayDialog { "ui/ui_entername.lua" } end
	if fileName and fileName ~= "" then
		fileName = fileName .. ".choco3"
		local saveString = Player:BuildSaveGameString()
		WriteToFile(fileName, saveString)
		DebugOut("SAVE", "Game successfully saved to explicitly named file: " .. fileName)
	end
end

function Player:LoadGameFromFile(fileName)
	local f = nil
	local s = ReadFromFile(fileName)
	if s then f = loadstring(s) end
	if type(f) == "function" then f = f() end
	
	if type(f) == "table" then
		DebugOut("LOAD", "Loading game from explicitly named file: " .. tostring(fileName))
		local tSave = f
		
		-- Maintain the current player's username
		tSave.name = Player.name or tSave.name
		Player:Reset(tSave)
		
		UpdateLedger("newplayer")
		SwapToModal("ui/mapview.lua")
	else
		DebugOut("ERROR", "Failed to load game from file: " .. tostring(fileName))
	end
end

------------------------------------------------------------------------------
-- Medals & Achievements
------------------------------------------------------------------------------

function Player:AwardMedal(key)
	if not Player.medals[key] then
		Player.medals[key] = true
		Player.lastMedal = key
		
		DebugOut("PLAYER", string.format("Medal awarded: %s", GetString(key)))

		if key == "medal_07" then SoundEvent("major_award_fanfare")
		else SoundEvent("award_fanfare")
		end
		
		DisplayDialog { "ui/ui_medals.lua", headline="new_medal" }
	end
end

------------------------------------------------------------------------------
-- Factory & Manufacturing Core Logic
------------------------------------------------------------------------------

function Player:UpdateSupplies()
	local newStall = false
	
	-- Compute global supply levels (weeks of supply remaining) for all ingredients
	self.supply = {}
	for name, need in pairs(self.needs) do
		local have = self.ingredients[name] or 0
		-- NOTE: `production` here relies on a global variable or might be nil.
		-- Maintained exactly as original logic per instructions.
		if (production == 0) or (need == 0) then 
			self.supply[name] = 0
		elseif need > 0 then 
			self.supply[name] = have / need
		else 
			self.supply[name] = 0
		end
	end

	-- Project weeks of full production available for each specific factory
	-- Updates the UI stalling indicators when supplies drop below needs.
	for name, info in pairs(self.factories) do
		local factory = _AllBuildings[name]
		local prodAmount = factory:GetProduction()
		info.supply = 999999
		local stall = false
		
		for ingName, _ in pairs(info.needs) do
			local have = self.ingredients[ingName] or 0
			if self.supply[ingName] < info.supply then 
				info.supply = Floor(self.supply[ingName]) 
			end
			if have < info.needs[ingName] then 
				stall = true 
			end
		end
		
		if stall and not info.stall then
			newStall = true
			DebugOut("FACTORY", string.format("Factory '%s' has stalled due to lack of ingredients.", factory.name))
		end
		info.stall = stall

		if info.stall then 
			Player.portsAvailable[factory.port.name] = "factory_stall"
		else 
			Player.portsAvailable[factory.port.name] = "factory"
		end
	end
	
	UpdateLedger("factory")
end

function Player:UpdateNeeds()
	-- Gather combined ingredient needs of all factories for one tick of full production
	self.needs = {}
	for _, info in pairs(self.factories) do
		if info.current then
			for name, count in pairs(info.needs) do
				local n = self.needs[name] or 0
				self.needs[name] = n + (count * info.production)
			end
		end
	end
	
	-- Immediately refresh supply durations based on the newly calculated needs
	self:UpdateSupplies()
end

function Player:RunFactories()
	local stall = false
	for name, info in pairs(self.factories) do
		local factory = _AllBuildings[name]
		
		if info.current then
			-- Determine how many cases we can make using current inventory
			-- Capped at the factory's maximum production rate.
			local produce = info.production or 0
			local possible = 0
			
			for ingName, need in pairs(info.needs) do
				local have = self.ingredients[ingName] or 0
				possible = Floor(have / need)
				if possible < produce then produce = possible end
			end
			
			-- Consume the appropriate ingredients and create product
			if produce > 0 then
				local currentProd = _AllProducts[info.current]
				DebugOut("FACTORY", string.format("Factory '%s' produced %d cases of %s.", factory.name, produce, currentProd:GetName()))

				info.stall = false
				for ingName, count in pairs(info.needs) do
					local consume = count * produce
					self:AddIngredient(ingName, -consume, true)	-- defer recalculation for batching
					self.useTimes[ingName] = self.time
				end
				
				currentProd:AdjustInventory(produce)
				currentProd:RecordMade(produce)
				self.useTimes[info.current] = self.time
			end
			
			-- Flag stalling if we produced less than optimal capacity
			if produce < info.production then
				info.stall = true
				stall = true
			end
			
			if info.stall then 
				Player.portsAvailable[factory.port.name] = "factory_stall"
			else 
				Player.portsAvailable[factory.port.name] = "factory"
			end
		end
	end
	
	-- After the first ever stall, trigger a tutorial tip for the player
	if stall and Player.options.tut_stall then
		UpdateLedger("factory")
		Player.options.tut_stall = false
		DebugOut("UI", "Triggering tutorial dialog for factory stalling.")
		DisplayDialog { "ui/ui_generic.lua", text="factory_stalled", noFade=true }
	end
end

function Player:ExpireInventory()
	-- Gradually expire inventory at 20% per week after a set period of non-use.
	
	-- Spoilage timer scales strictly based on selected difficulty.
	local spoilage_timer = 32 -- Default to Easy
	if Player.difficulty == 2 then 
		spoilage_timer = 24   -- Medium
	elseif Player.difficulty == 3 then 
		spoilage_timer = 16   -- Hard
	end
	
	-- Expire Ingredients
	for name, count in pairs(self.ingredients) do
		local age = self.time - (self.useTimes[name] or self.time)
		if age > spoilage_timer then
			-- TODO: Implement non-expiring exceptions if needed?
			local expire = Floor(count * .2 + 0.99)
			if expire > 0 then 
				DebugOut("ECONOMY", string.format("%d sacks of %s spoiled and were removed.", expire, GetString(name))) 
				self:AddIngredient(name, -expire, true)
			end
		end
	end

	-- Expire Products
	for code, count in pairs(self.products) do
		local prod = _AllProducts[code]
		
		-- Custom User-Generated Recipes (UGRs) never expire.
		if prod.category.name ~= "user" then
			local age = self.time - (self.useTimes[code] or self.time)
			if age > spoilage_timer then
				local expire = Floor(count * .2 + 0.99)
				if expire > 0 then 
					DebugOut("ECONOMY", string.format("%d cases of %s expired from inventory.", expire, prod:GetName())) 
					self:AddProduct(code, -expire, true)
				end
			end
		end
	end
end

------------------------------------------------------------------------------
-- Catalogue & Character Interaction
------------------------------------------------------------------------------

function Player:MeetCharacter(char)
	if not char or not char.name then return end

	local charKey = char.name
	
	-- Safely initialize the character's catalogue data block if it doesn't exist
	if not self.catalogue.unlockedCharacters[charKey] then
		self.catalogue.unlockedCharacters[charKey] = {
			met = false,
			unlocked = false,
			discovered_likes = {},
			discovered_dislikes = {},
			undiscovered_dislikes_pool = {}
		}
	end

	-- Only proceed if they haven't been marked as 'met' previously
	if not self.catalogue.unlockedCharacters[charKey].met then
		self.catalogue.unlockedCharacters[charKey].met = true
		DebugOut("CATALOGUE", string.format("First meeting with '%s' recorded. (Met Stage 1)", char.name))
	end
end

------------------------------------------------------------------------------
-- Economy, Markets & Travel
------------------------------------------------------------------------------

function Player:SetRank(rank)
	self.rank = rank
	DebugOut("PLAYER", string.format("Player promoted to Rank %d: %s", rank, GetString("rank"..rank)))
	UpdateLedger("rank")
end

function Player:GetPort()
	local name = Player.portName -- fallback destination lookup removed natively
	return _AllPorts[name]
end

function Player:RecalculatePricesForCurrentPort()
	local port = self:GetPort()
	if not port then return end

	local portName = port.name
	DebugOut("ECONOMY", string.format("Recalculating item prices for arrival at port '%s'.", portName))
	
	-- Clear out the previous port's market prices
	self.itemPrices = {}
	
	-- -----------------------------------------------------
	-- 1. Determine Ingredient Prices (Markets & Farms)
	-- -----------------------------------------------------
	if port.buildings then
		for _, building in ipairs(port.buildings) do
			if building.inventory then
				for _, ing in ipairs(building.inventory) do
					local price = 1
					local low, high

					-- Resolve seasonality (invert season if in the opposite hemisphere)
					if ing:IsInSeason(nil, port.hemisphere) then
						low = ing.price_low
						high = ing.price_high
					else
						low = ing.price_low_notinseason
						high = ing.price_high_notinseason
					end
					
					-- Apply difficulty penalty (Ingredients cost more on harder difficulties)
					local cost_multiplier = 1.0
					if Player.difficulty == 2 then cost_multiplier = 1.15 end
					if Player.difficulty == 3 then cost_multiplier = 1.30 end
					
					if cost_multiplier > 1.0 then
						low = Floor(low * cost_multiplier)
						high = Floor(high * cost_multiplier)
					end

					price = RandRange(low, high)
					
					-- Apply tutorial or specialized tips modifier last
					local modifier = Tips.GetPriceModifier(ing.name, portName)
					price = Floor(price * modifier)
					
					self.itemPrices[ing.name] = price
				end
			end
		end
	end

	-- -----------------------------------------------------
	-- 2. Determine Product Sale Prices
	-- -----------------------------------------------------
	-- Check if the player owns a shop in this location
	local ownedShop = false
	for _,b in ipairs(port.buildings) do
		if b.type == "shop" and b:IsOwned() then 
			ownedShop = true
			break 
		end
	end
	
	for code, prod in pairs(_AllProducts) do
		local sold = prod:NumberSold()
		local low = prod.price_low
		local high = prod.price_high
		
		-- Apply difficulty penalty (Players earn less on harder difficulties)
		local price_penalty = 1.0
		if Player.difficulty == 2 then price_penalty = 0.90 end
		if Player.difficulty == 3 then price_penalty = 0.80 end

		if price_penalty < 1.0 then
			low = Floor(low * price_penalty)
			high = Floor(high * price_penalty)
		end

		if ownedShop then
			-- At owned shops, flat 20% markup, and prices stay strictly in the upper third bracket.
			low = low * 1.2
			high = high * 1.2
			low = low + (high - low) * .66
		end
		
		local price = RandRange(low, high)
		local middle = (low + high) / 2
		
		-- Custom User-Generated Recipes (UGRs) are immune to market deterioration
		if prod.category.name == "user" then sold = 0 end

		-- Apply demand/decay mechanics based on volume sold and difficulty.
		local decay_mod = 1.0
		local floor_mod = 0.9
		if Player.difficulty == 2 then 
			decay_mod = 1.5 
			floor_mod = 0.8 
		elseif Player.difficulty == 3 then 
			decay_mod = 2.0 
			floor_mod = 0.7 
		end

		if sold <= (2000 / decay_mod) then
			-- Healthy market: Tend towards "middle" price over the first N sales
			price = price + (middle - price) * (sold * decay_mod) / 2000
		elseif sold < (7000 / decay_mod) then
			-- Saturating market: Tend towards the "lowest" price over the next N sales
			price = middle + (low - middle) * ((sold - (2000 / decay_mod)) * decay_mod) / 5000
		elseif prod.category.name == "truffle" or prod.category.name == "blend" then
			-- Truffles and Blends sell at cost forever (no bottom drop-out), relying strictly on owned-shop markups
			price = low
		else
			-- Saturated market: The bottom drops out completely; sold below cost at non-owned shops
			price = Floor(low * floor_mod + .5)
		end

		-- Finally, factor in any active tips or rumors
		local modifier = Tips.GetPriceModifier(code, portName)
		price = Floor(price * modifier)
		
		self.itemPrices[code] = price
	end
	
	-- -----------------------------------------------------
	-- 3. Tutorial Specific Overrides (Rank 1 / Zurich / Douala)
	-- -----------------------------------------------------
	if self.rank == 1 then
		if portName == "zurich" then
			self.itemPrices[_AllIngredients["sugar"].name] = 7
			self.itemPrices[_AllIngredients["cacao"].name] = 11
			self.itemPrices[_AllIngredients["milk"].name] = Floor(_AllIngredients["milk"].price_low + .2 * (_AllIngredients["milk"].price_high - _AllIngredients["milk"].price_low))
			self.itemPrices[_AllIngredients["caramel"].name] = Floor(_AllIngredients["caramel"].price_low + .2 * (_AllIngredients["caramel"].price_high - _AllIngredients["caramel"].price_low))

			self.itemPrices[_AllProducts["b01"].code] = 85
			self.itemPrices[_AllProducts["b02"].code] = Floor(_AllProducts["b02"].price_low + .8 * (_AllProducts["b02"].price_high - _AllProducts["b02"].price_low))
			self.itemPrices[_AllProducts["b03"].code] = Floor(_AllProducts["b03"].price_low + .8 * (_AllProducts["b03"].price_high - _AllProducts["b03"].price_low))
			
		elseif portName == "douala" then
			self.itemPrices[_AllIngredients["sugar"].name] = 9
			self.itemPrices[_AllIngredients["cacao"].name] = 11
		end
	end
end

function Player:SetPort(portName)
	if portName then
		if self.portName ~= portName then
			-- Store previous port history
			if self.portName and self.portName ~= "enroute" then 
				self.lastPort = self.portName 
			end
			self.lastVisitTime[portName] = self.time

			self.portName = portName
			self.destination = nil
			
			DebugOut("PLAYER", string.format("Arrived at port: %s", GetString(portName)))

			self:RecalculatePricesForCurrentPort()
			PrepareTravelPrices()
			
			-- Reset haggle limitations for characters in the new port
			self.haggleDisable = {}
		end
	else
		self.portName = nil
	end
end

------------------------------------------------------------------------------
-- General Inventory & Wealth Modifiers
------------------------------------------------------------------------------

function Player:SetMoney(newMoney, silent)
	if self.money ~= newMoney then
		if not silent then
			if newMoney > self.money then SoundEvent("money_in_account") end
			-- TODO: Play alternative sounds for money loss
		end

		self.money = newMoney
		UpdateLedger("money")
	end
end

function Player:AddMoney(money, silent)
	local newMoney = self.money + money
	if newMoney < 0 then newMoney = 0 end
	if not silent then DebugOut("PLAYER", string.format("Money changed by %s. New total: %s", Dollars(money), Dollars(newMoney))) end
	self:SetMoney(newMoney, silent)
end

function Player:SubtractMoney(money, silent)
	local newMoney = self.money - money
	if newMoney < 0 then newMoney = 0 end
	if not silent then DebugOut("PLAYER", string.format("Money changed by -%s. New total: %s", Dollars(money), Dollars(newMoney))) end
	self:SetMoney(newMoney, silent)
end

function Player:AddIngredient(name, count, deferRecalculation)
	local newCount = self.ingredients[name] or 0
	newCount = newCount + count
	if newCount < 0 then newCount = 0 end
	self.ingredients[name] = newCount
	
	if not deferRecalculation then
		local action = (count > 0) and "Added " or "Removed "
		local ingName = GetString(name)
		local absCount = (count > 0) and count or -count
		DebugOut("PLAYER", string.format("%s%d %s. New total: %d", action, absCount, ingName, newCount))
	end

	-- Immediately refresh supply numbers if this ingredient is used in active factories
	if (not deferRecalculation) and Player.needs[name] then
		Player:UpdateSupplies()
	end
end

function Player:AddProduct(code, count)
	local newCount = self.products[code] or 0
	newCount = newCount + count
	if newCount < 0 then newCount = 0 end
	self.products[code] = newCount
	
	local prod = _AllProducts[code]
	if prod then
		local action = (count > 0) and "Added " or "Removed "
		local prodName = prod:GetName()
		local absCount = (count > 0) and count or -count
		DebugOut("PLAYER", string.format("%s%d %s. New total: %d", action, absCount, prodName, newCount))
	end
end

------------------------------------------------------------------------------
-- Recipe Analytics
------------------------------------------------------------------------------

function Player:GetKnownRecipeCount(categoryName)
	local n = 0
	if categoryName then 
		n = Player.categoryCount[categoryName] or 0
	else
		for _, count in pairs(Player.categoryCount) do n = n + count end
	end
	return n
end

function Player:GetMadeRecipeCount(categoryName)
	local n = 0
	if categoryName then 
		n = Player.categoryMadeCount[categoryName] or 0
	else
		for _, count in pairs(Player.categoryMadeCount) do n = n + count end
	end
	return n
end

------------------------------------------------------------------------------
-- Quest Utilities
------------------------------------------------------------------------------

function Player:GetPrimaryQuest()
	local q = nil
	if self.questPrimary then q = _AllQuests[self.questPrimary] end
	return q
end

function Player:SetPrimaryQuest(questName)
	-- If no name is supplied, auto-assign the most recently acquired active quest
	if not questName then
		local t = -1
		for name, time in pairs(self.questsActive) do
			if time > t then
				questName  = name
				t = time
			end
		end
	end

	if self.questPrimary ~= questName then
		self.questPrimary = questName
		if questName then
			DebugOut("QUEST", string.format("Primary quest explicitly tracked: %s", questName))
		else
			DebugOut("QUEST", "Primary quest tracking cleared.")
		end
		
		UpdateLedger("quest")
		FadeIn{"questText"}
		devUpdateQuest()
	end

	UpdateActiveQuestGoalsComplete()
end

------------------------------------------------------------------------------
-- Date Math & Real-Time Holidays Simulation
------------------------------------------------------------------------------

-- Calculates exact Day, Month, and Year by extrapolating from Player.time (weeks).
-- Base line is historically June 27th, 1946.
function Player:GetDateComponents()
	local start_year = 1946
	local start_day_offset = 178 -- Approx day of year for June 27th
	local days_elapsed = ((self.time or 1) - 1) * 7
	local days_remaining = start_day_offset + days_elapsed
	local current_year = start_year
	
	local function IsLeapYear(y)
		return (Mod(y, 4) == 0) and ((Mod(y, 100) ~= 0) or (Mod(y, 400) == 0))
	end
	
	-- Roll over years
	while true do
		local days_in_this_year = IsLeapYear(current_year) and 366 or 365
		if days_remaining <= days_in_this_year then break end
		days_remaining = days_remaining - days_in_this_year
		current_year = current_year + 1
	end
	
	-- Pinpoint month
	local months = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	local month_index = 1
	for i, standard_days in ipairs(months) do
		local days_in_month = (i == 2 and IsLeapYear(current_year)) and 29 or standard_days
		
		if days_remaining <= days_in_month then
			month_index = i
			break
		else
			days_remaining = days_remaining - days_in_month
		end
	end
	
	DebugOut("SIM", string.format("Date components evaluated: %02d/%02d/%04d", month_index, days_remaining, current_year))
	return days_remaining, month_index, current_year
end

function Player:UpdateHolidays()
	local day, month, year = self:GetDateComponents()
	self.currentHolidays = {} -- Reset states for this tick
	
	-- -----------------------------------------------------
	-- 1. FIXED DATE HOLIDAYS (Gregorian Calendar)
	-- -----------------------------------------------------
	if month == 2 and day <= 14 then self.currentHolidays.valentine = true end
	if month == 10 and day >= 15 then self.currentHolidays.halloween = true end
	if month == 11 and day >= 15 then self.currentHolidays.thanksgiving = true end
	if month == 12 and day >= 15 then self.currentHolidays.christmas = true end

	-- -----------------------------------------------------
	-- 2. VARIABLE / LUNAR HOLIDAYS (Algorithmic Drift)
	-- -----------------------------------------------------
	-- Lunar years are roughly 354 days long, meaning holidays fall ~11 days earlier each solar year.
	local yearDiff = year - 1946
	local lunarShift = Mod(yearDiff * 11, 365)
	
	local function CheckLunarWindow(baseStartDay, duration)
		local currentDayOfYear = 0
		local daysInMonths = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
		for i=1, month-1 do currentDayOfYear = currentDayOfYear + daysInMonths[i] end
		currentDayOfYear = currentDayOfYear + day
		
		local startDay = baseStartDay - lunarShift
		if startDay < 1 then startDay = startDay + 365 end
		
		local endDay = startDay + duration
		if endDay > 365 then
			-- Window wraps around New Year's Eve
			return (currentDayOfYear >= startDay) or (currentDayOfYear <= (endDay - 365))
		else
			return (currentDayOfYear >= startDay) and (currentDayOfYear <= endDay)
		end
	end

	-- Ramadan: Base Day 210 (Late July in 1946)
	if CheckLunarWindow(210, 30) then self.currentHolidays.ramadan = true end
	-- Eid ul-Fitr: Immediately follows Ramadan
	if CheckLunarWindow(241, 3) then self.currentHolidays.eid_ul_fitr = true end
	-- Lunar New Year: Base Feb 5
	if CheckLunarWindow(36, 15) then self.currentHolidays.lunar_new_year = true end
	-- Diwali: Base Oct 25
	if CheckLunarWindow(298, 5) then self.currentHolidays.diwali = true end
	
	-- Easter (Fixed window approximation for Spring)
	if month == 4 and day >= 1 and day <= 14 then self.currentHolidays.easter = true end
	-- Lent (40 days before Easter)
	if (month == 2 and day >= 20) or (month == 3) or (month == 4 and day < 1) then self.currentHolidays.lent = true end
	-- Carnival (Week before Lent)
	if month == 2 and day >= 13 and day < 20 then self.currentHolidays.carnival = true end
end

-- Matches active global holidays against the cultural profile of a specific port
function Player:GetActiveHolidayForPort(portName)
	local port = _AllPorts[portName]
	if not port then return nil end
	
	local culture = port.culture or "western"
	
	-- Determine prioritized holiday display
	if self.currentHolidays.christmas and (culture == "western" or culture == "european" or culture == "north_american" or culture == "latin") then return "christmas" end
	if self.currentHolidays.ramadan and culture == "muslim" then return "ramadan" end
	if self.currentHolidays.eid_ul_fitr and culture == "muslim" then return "eid_ul_fitr" end
	if self.currentHolidays.lunar_new_year and (culture == "east_asian" or portName == "sanfrancisco") then return "lunar_new_year" end
	if self.currentHolidays.diwali and culture == "hindu" then return "diwali" end
	if self.currentHolidays.thanksgiving and culture == "north_american" then return "thanksgiving" end
	if self.currentHolidays.carnival and culture == "latin" then return "carnival" end
	if self.currentHolidays.lent and (culture == "western" or culture == "european" or culture == "latin") then return "lent" end
	if self.currentHolidays.easter and (culture == "western" or culture == "european" or culture == "north_american" or culture == "latin") then return "easter" end
	
	-- Global non-denominational holidays
	if self.currentHolidays.valentine then return "valentine" end
	if self.currentHolidays.halloween then return "halloween" end
	
	return nil
end

------------------------------------------------------------------------------
-- Achievement Evaluation
------------------------------------------------------------------------------

-- Called periodically to evaluate if gameplay metrics meet medal criteria
function Player:CheckMedals()
	-- 1: Finished second rank quests
	if not self.medals.medal_01 and Player.questVariables.rank2_work and Player.questVariables.rank2_work > 1 then 
		return "medal_01" 
	end
	
	-- 2: Manufacture 8 unique standard chocolate recipes
	if not self.medals.medal_02 then
		local total = (Player.categoryMadeCount.bar or 0) + (Player.categoryMadeCount.infusion or 0) + (Player.categoryMadeCount.truffle or 0) + (Player.categoryMadeCount.exotic or 0)
		if total >= 8 then return "medal_02" end
	end
	
	-- 3: Manufacture 10 unique coffee/beverage recipes
	if not self.medals.medal_03 then
		local total = (Player.categoryMadeCount.beverage or 0) + (Player.categoryMadeCount.blend or 0)
		if total >= 10 then return "medal_03" end
	end
	
	-- 4: Sell at least 3 custom user-generated recipes
	if not self.medals.medal_04 then
		local n = 0
		for code, _ in pairs(self.itemNames) do
			if self.itemsSold[code] and self.itemsSold[code] > 0 then n = n + 1 end
		end
		if n >= 3 then return "medal_04" end
	end
	
	-- 5: Own 3 shops globally
	if not self.medals.medal_05 and self.shopsOwned >= 3 then 
		return "medal_05" 
	end
	
	-- 6: Own all 6 factories
	if not self.medals.medal_06 and self.factoriesOwned == 6 then 
		return "medal_06" 
	end
	
	-- 7: Reach maximum rank tier (5)
	if not self.medals.medal_07 and self.rank >= 5 then 
		return "medal_07" 
	end
	
	-- 8: Visit 20 unique ports
	if not self.medals.medal_08 and self.portVisitCount >= 20 then 
		return "medal_08" 
	end
	
	-- 9: Fill all 12 custom UGR recipe slots
	if not self.medals.medal_09 and self.categoryCount.user == 12 then 
		return "medal_09" 
	end
	
	return nil
end