--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]--------------------------------------------------------------------------

-- The "Player" class is the repository for all player-specific game state
Player =
{
	name = nil,						-- Player name
	time = nil,						-- Current game time (WEEKS since start date)
	subticks = nil,					-- Number of sub-ticks (transactions)
	money = nil,					-- Current wealth
	
	stringTable = {},				-- Player-specific replacement strings
	
	rank = 1,						-- Current rank (whatever this means)
	medals = {},					-- Medals awarded
	lastMedal = nil,				-- Last medal received
	
	portName = nil,					-- Current port NAME
	destination = nil,
	portsAvailable = {},			-- Port availability, set of name="new"/"open"/"locked"/"hidden"/"factory"/"factory_stall"/"shop"
	portsCost = {},					-- Cost to travel to the specified port from here
	portsVisited = {},				-- Set of name=true for ports visited
	portVisitCount = 0,
	lastVisitTime = {},				-- Tracks the last week the player visited a port { port_name = week_number }
	lastPort = nil,					-- The name of the port the player was last in
	
	ingredients = {},				-- Set of name=count for player ingredient inventory
	products = {},					-- Set of code=count for player product inventory
	lastSeenPort = {},				-- Set of <ing name/prod code>=<port name> for "last seen in" port information
	lastSeenPrice = {},				-- Set of <ing name/prod code>=<price> for "last seen/sold for" price information
	lowPrice = {},					-- Set of <ing name/prod code>=<price> for low price information
	highPrice = {},					-- Set of <ing name/prod code>=<port name> for high price information
	useTimes = {},					-- Set of name/code=count for last time the ingredient/product was used
	knownRecipes = {},				-- Set of code=true for recipes the player has gathered
	categoryCount = {},				-- Set of name=<#> for number of recipes known in each category
	categoryMadeCount = {},			-- Set of name=<#> for number of recipes made in each category
	ingredientsAvailable = {},		-- Set of name=true or name=false to override default ingredient availability
	labIngredients = {},			-- Set of name=true for player's lab/kitchen ingredients inventory
	labFirstUse = {},				-- Teddy's memory of first-time ingredient uses
	lastTastedRecipeCode = nil,		-- Teddy's memory of the last bad recipe tasted
	
	buildingsOwned = {},			-- Buildings owned, set of name=true
	buildingsEnabled = {},			-- Buildings enabled, set of name=true
	buildingsBlocked = {},			-- Buildings blocked, set of name=true
	buildingsVisited = {},		  -- Buildings visited, set of name=true
	buildingCharacters = {},		-- Temporary character placement, set of building = { characterName = true }
	factoriesOwned = nil,			-- Number of factories owned
	factoryAcquiredTime = {},		-- Tracks the week each factory was acquired { factory_name = week_number }
	factoryTopProduct = {},			-- Tracks the best product made at each factory { factory_name = { code="b01", count=50 } }
	factoryTotalProduction = {},	-- Tracks total cases produced at each factory { factory_name = total_cases }
	shopsOwned = nil,				-- Number of shops owned
	
	factories = {},					-- Factory configuration, set of name={ current=<product>, supply=<n>, stall=<t/f>, needs={<ingredient_name>=<number>}, output={<product_code>=<number>} }
									-- Also includes machinery information, set of <category name>=true
	powerups = {},					-- Set of key=true for powerup settings
	needs = {},						-- Ingredient needs to keep all factories going one tick
	supply = {},					-- Number of ticks worth of ingredients available for all factories using them at full consumption
	
	itemPrices = {},				-- Current prices of all items, set of code/name=price
	itemRecipes = {},				-- Set of index=<code table> for invented recipes
	itemsMade = {},					-- Set of code=<#> for products made
	itemsSold = {},					-- Set of code=<#> for products sold
	firstEverBuy = {},				-- Tracks the absolute first time buying an ingredient { ingredient_name = true }
	firstEverSell = {},				-- Tracks the absolute first time selling a product { product_code = true }
	firstBuy = {},					-- Tracks first time buying an ingredient FROM A SPECIFIC PORT { [port_name] = { [ingredient_name] = true } }
	firstSell = {},					-- Tracks first time selling a product TO A SPECIFIC PORT { [port_name] = { [product_code] = true } }
	firstSellCategory = {},			-- Tracks first time selling a product from a category { [port_name] = { [category_name] = true } }
	itemAppearance = {},			-- Set of code=<product layers> for invented recipes
	itemNames = {},					-- Set of code=name for player-named products
	itemDescriptions = {},			-- Set of code=description for player-named products
	itemMachinery = {},				-- Set of code=<machinery name> for invented recipes
	customSlots = nil,				-- Number of available recipe creation slots
	
	questPrimary = nil,				-- NAME of "primary" quest selected for display on the ledger
	questStarters = {},				-- Set of quest_name=char_name for starters of active quests
	questOfferText = {},			-- Set of offer text for quests
	questsActive = {},				-- Set of name=startTime for active quests
	questsWaiting = {},				-- Set of name=targetTime for (active) quests waiting for a particular time
	questsComplete = {},			-- Set of name=endTime for completed OR REJECTED quests
	questsDeferred = {},			-- Set of name=availableTime for deferred quests
	questVariables = {},			-- Set of name=value variables for use by quest scripting
	questDifficulty = {},			-- Set of name=difficulty for active quests
	questHintCooldowns = {},		-- Set of quest_name=endTime for hint cooldowns
	lastOfferTime = nil,			-- Time of last offered quest
	lastAcceptTime = nil,			-- Time of last accepted quest
	lastCompleteTime = nil,			-- Time of last completed quest
	lastOrderTime = nil,			-- Time of last special order
	shopOrderData = {},	 		-- Stores {chance=X} for each owned shop
	pendingSpecialOrders = {},	 	-- A queue for generated orders waiting for delivery
	orderEligibleChars = {},		-- Characters explicitly allowed to receive orders
	orderBannedChars = {},		  -- Characters temporarily banned from receiving orders
	orderBannedBuildings = {},	  -- Buildings temporarily banned from being order locations
	encounterTimer = nil,			-- Countdown to forced travel encounter
	activeTips = {},				-- Table for active tips
	pendingAnnouncements = {},	  -- Table for tips waiting to be announced
	
	catalogue = {},					-- Master table for all catalogue data
	
	charHappiness = {},				-- Character happiness levels
	charHappinessTime = {},			-- Last time character happiness was set
	
	-- HOLIDAY SYSTEM STATE
	currentHolidays = {},		   -- Table of currently active holidays { holidayName = true }
	holidayAnnouncements = {},	  -- Tracks the last year a holiday was announced { holidayName = year }
	
--	sign = {},						-- Sign information
	
	options = {},					-- Player option settings
	difficulty = 1,					-- 1=Easy, 2=Medium, 3=Hard
	haggleDisable = {},				-- Player haggle options (name=true to disable, otherwise enabled)
	
	-- NEW: Repeat Visit Logic (Added to Reset function below as well)
	buildingLastVisitTime = {},	 -- Tracks the last week the player visited a specific building
}

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function GetDifficultyValue(easy, medium, hard)
	local difficulty = Player.difficulty or 1
	
	if difficulty == 3 then
		return hard
	elseif difficulty == 2 then
		return medium
	else -- Default to Easy
		return easy
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

-- New modded function (2025): ability to support multiple languages instead of exclusively English)
function Player:ReloadStrings()
	-- Define the list of all core string files.
	local coreFiles = {
		"strings.xml",
		"dialogue_strings.xml",
		"catalogue_strings.xml"
	}

	-- Get the list of all quest-specific string files.
	local questStringFiles = {}
	local questLuaFiles = {}
	LoadQuestFileList(questLuaFiles) -- This C++ function populates the table with quest script paths
	for _, luaFile in ipairs(questLuaFiles) do
		-- Convert the .lua path to its corresponding .xml path
		table.insert(questStringFiles, (string.gsub(luaFile, ".lua", "_strings.xml")))
	end

	-- Combine the core files and quest files into one master list
	local allFilesToLoad = {}
	for _, file in ipairs(coreFiles) do table.insert(allFilesToLoad, file) end
	for _, file in ipairs(questStringFiles) do table.insert(allFilesToLoad, file) end

	-- Determine the current language. Default to "en" (English).
	local lang = "en"
	if self.options and self.options.language then
		lang = self.options.language
	end
	DebugOut("STRINGS", "Loading language: " .. lang)

	-- First, load all the default English files from the root assets folder.
	-- The custom bsgLoadStringFile function will handle adding/overwriting strings.
	for _, filename in ipairs(allFilesToLoad) do
		bsgLoadStringFile(filename)
	end

	-- Now, if a different language is selected, attempt to load the override files.
	-- bsgLoadStringFile will silently fail if a file doesn't exist,
	-- but if it does, its strings will overwrite the English defaults.
	if lang ~= "en" then
		local pathPrefix = "languages/" .. lang .. "/"
		DebugOut("STRINGS", "Loading override files from: " .. pathPrefix)
		for _, filename in ipairs(allFilesToLoad) do
			bsgLoadStringFile(pathPrefix .. filename)
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Player:Reset(restoreTable)
	-- First, restore any saved delivery quests
	if restoreTable and restoreTable.deliveries then
		for _,t in ipairs(restoreTable.deliveries) do CreateDeliveryQuest(t) end
		restoreTable.deliveries = nil
	end
	
	-- Make sure all the current player's custom recipes are cleared from the _AllProducts list
	-- (Player-created recipe category will be cleared below)
	for _,code in ipairs(self.itemRecipes) do _AllProducts[code] = nil end
	
	local t = restoreTable or {}
	
	self.name = t.name or nil
	self.time = t.time or 1
	self.subticks = t.subticks or 0
	self.money = t.money or 0
	
	self.rank = t.rank or 1
	self.medals = t.medals or {}
	self.lastMedal = t.lastMedal or nil
	
	self.portName = t.portName or t.destination
if self.portName == "error" then self.portName = nil end
	self.destination = nil
	self.portsAvailable = t.portsAvailable		-- leave nil and initialize below
	self.portsCost = t.portsCost				-- leave nil and initialize later
	self.portsVisited = t.portsVisited or {}
	self.portVisitCount = t.portVisitCount or 0
	self.lastVisitTime = t.lastVisitTime or {}
	self.lastPort = t.lastPort or nil
	
	self.ingredients = t.ingredients or {}
	self.products = t.products or {}
	self.lastSeenPort = t.lastSeenPort or {}
	self.lastSeenPrice = t.lastSeenPrice or {}
	self.lowPrice = t.lowPrice or {}
	self.highPrice = t.highPrice or {}
	
	self.useTimes = t.useTimes or {}
	self.knownRecipes = t.knownRecipes or { b01=true,b02=true,b03=true,b04=true,b05=true,b06=true,b07=true,b08=true,b09=true,b10=true,b11=true,b12=true, }
	self.categoryCount = t.categoryCount or { bar=12 }
	self.categoryMadeCount = t.categoryMadeCount or {}
	self.ingredientsAvailable = t.ingredientsAvailable or {}
	self.labIngredients = t.labIngredients or {}
	self.labFirstUse = t.labFirstUse or {}
	self.lastTastedRecipeCode = t.lastTastedRecipeCode or nil
	
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
	
	self.charHappiness = t.charHappiness or {}
	self.charHappinessTime = t.charHappinessTime or {}
	
	-- Holiday State
	self.currentHolidays = t.currentHolidays or {}
	self.holidayAnnouncements = t.holidayAnnouncements or {}
	
	-- Building Visits
	self.buildingLastVisitTime = t.buildingLastVisitTime or {}
	
	self.catalogue = t.catalogue or {}
	self.catalogue.unlockedHistory = self.catalogue.unlockedHistory or {}
	self.catalogue.unlockedCharacters = self.catalogue.unlockedCharacters or {}
	self.catalogue.unlockedIngredients = self.catalogue.unlockedIngredients or {}
	self.catalogue.charactersMet = self.catalogue.charactersMet or {}
	self.catalogue.unlockedPorts = self.catalogue.unlockedPorts or {}
	self.catalogue.discoveredBuildings = self.catalogue.discoveredBuildings or {}
	self.catalogue.discoveredIngredientLocations = self.catalogue.discoveredIngredientLocations or {}
	self.catalogue.discoveredIngredientSeasons = self.catalogue.discoveredIngredientSeasons or {}
	
	self.options = t.options or { showCompletedQuests=false, tut_stall=true, }
	self.difficulty = t.difficulty or 1
	self.haggleDisable = t.haggleDisable or {}
	
	-- TODO: Other default signage
--	self.sign = t.sign or { background="bg1", logo="logo1", name="", font=uiFontName, fontsize=30, text="" }

	-- Prepare ports available info for a new game
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
	
	-- Prepare _travelers and _empty characters for new game
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
	self.stringTable = { player=self.name }

	-- Restore player-created recipes
	local category = _AllCategories["user"]
	category:Clear()
	self.categoryCount["user"] = 0
	for i,codeTable in ipairs(self.itemRecipes) do
		local prod = BuildCustomProduct(codeTable)
		self.stringTable["user"..tostring(i)] = prod:GetName()
		DebugOut("RECIPE", "Restored custom recipe '" .. prod:GetName() .. "' from save data.")
	end
	self.questVariables.ugr_slots = self.customSlots - (self.categoryCount.user or 0)
	
	-- Reset the player's recipe book view
	gCategorySelection = nil
	gRecipeSelection = nil
	
	-- If starting a completely new game, kick it off in Zurich
	if not restoreTable or not self.portName then
		-- Starting a fresh game
		self:SetPort("zurich")
	end

	if not restoreTable then
		-- This is a NEW GAME. Unlock default catalogue entries
		DebugOut("PLAYER", "New game detected. Unlocking default catalogue entries.")
		for _, ing in ipairs(_IngredientOrder) do
			if not ing.locked then
				self.catalogue.unlockedIngredients[ing.name] = true
				DebugOut("CATALOGUE", "Default ingredient unlocked in catalogue: " .. ing.name)
			end
		end
	else
		-- This is a LOADED GAME. Perform a one-time check to fix existing saves
		for _, ing in ipairs(_IngredientOrder) do
			if not ing.locked and not self.catalogue.unlockedIngredients[ing.name] then
				-- If an ingredient is unlocked by default but is NOT unlocked in the save's catalogue, fix it
				self.catalogue.unlockedIngredients[ing.name] = true
				DebugOut("CATALOGUE", "MIGRATION: Retroactively unlocked default ingredient in catalogue: " .. ing.name)
			end
		end
	end
	
	-- Ensure holidays are updated immediately on load/reset
	self:UpdateHolidays()

	-- CRITICAL FIX: Reload strings NOW that options and difficulty are set.
	self:ReloadStrings()

	-- FIRST PEEK
--	SetState("Rank", self.rank)			-- FIRST PEEK
--	SetState("Money", self.money)		-- FIRST PEEK
--	SetState("GameWeeks", self.time)		-- FIRST PEEK
	
	DebugOut("PLAYER", "Reset complete. Player: " .. (self.name or "N/A") .. ", Money: " .. Dollars(self.money) .. ", Rank: " .. self.rank)
end

------------------------------------------------------------------------------
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
		
		-- medals:
		local medalXML = ""
		for i=1,9 do
			local key = "medal_0"..tostring(i)
			if self.medals[key] then
				medalXML = medalXML .. "<medal name='" ..PFMedalKeys[i].. "' per='game' />"
			end
		end
--		DebugOut("MEDALS:"..tostring(medalXML))
		
		LogScore(score, stringData, medalXML)
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

local function AppendTableToString(t, stringTable)
	for k,v in pairs(t) do
		-- If key is a number, just leave it off
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
--			DebugOut("skipping " ..tostring(k))
		end
	end
end

function Player:BuildSaveGameString()
	local saveStringTable = { "return {", }
	AppendTableToString(Player, saveStringTable)
	
	-- Build save tables for active delivery quests
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
	local saveString = table.concat(saveStringTable)
--	DebugOut(saveString)
	return saveString
end

function Player:AutoSave()
	-- Auto save every 4 minutes
	local elapsedTime = CurrentTime() - (self.lastSave or CurrentTime())
	local remain = (4 * 60 * 1000) - elapsedTime
	if remain <= 0 then self:SaveGame() end
end

function Player:SaveGame()
	if GetNumUsers() > 0 then
		local saveString = Player:BuildSaveGameString()
		SaveGameString(saveString)
		DebugOut("SAVE", "Game saved for player " .. (self.name or "N/A"))
	end
	self.lastSave = CurrentTime()
end

function Player:LoadGame()
	local saveString = LoadGameString()
	if saveString and saveString ~= "" then
		DebugOut("LOAD", "Loading game from default save slot...")
		local loadTable = loadstring(saveString)
		if type(loadTable) == "function" then loadTable = loadTable() end
		if type(loadTable) == "table" then Player:Reset(loadTable) end
		
		local name = GetCurrentUserName()
		if name then
			Player.name = name
			Player.stringTable.player = Player.name
		end
		
		-- CRITICAL FIX: Strings are already reloaded in Reset(), so we don't need to call it here.
		-- UpdateLedger is now safe to call.
		UpdateLedger("newplayer")
		self.lastSave = CurrentTime()
	end
end

-------------------------------------------------------------------------------

function Player:SaveGameToFile(fileName)
	if not fileName then fileName = DisplayDialog { "ui/ui_entername.lua" } end
	if fileName and fileName ~= "" then
		fileName = fileName .. ".choco3"
		local saveString = Player:BuildSaveGameString()
		WriteToFile(fileName, saveString)
		DebugOut("SAVE", "Game saved to named file: " .. fileName)
	end
end

function Player:LoadGameFromFile(fileName)
	local f = nil
	local s = ReadFromFile(fileName)
	if s then f = loadstring(s) end
	if type(f) == "function" then f = f() end
	if type(f) == "table" then
--		DebugOut("Loading: "..tostring(fileName))
		DebugOut("LOAD", "Loading game from named file: " .. fileName)
		local tSave = f
		
		-- Keep the player's name
		tSave.name = Player.name or tSave.name
		Player:Reset(tSave)
		
		-- CRITICAL FIX: Strings are already reloaded in Reset().
		UpdateLedger("newplayer")
		SwapToModal("ui/mapview.lua")
	end
end

------------------------------------------------------------------------------
-- Medals

function Player:AwardMedal(key)
	if not Player.medals[key] then
		Player.medals[key] = true
		Player.lastMedal = key
		
		DebugOut("PLAYER", "Medal awarded: " .. GetString(key))

		if key == "medal_07" then SoundEvent("major_award_fanfare")
		else SoundEvent("award_fanfare")
		end
		DisplayDialog { "ui/ui_medals.lua", headline="new_medal" }
	end
end

------------------------------------------------------------------------------
-- Factory Support

function Player:UpdateSupplies()
	local newStall = false
	
	-- Compute supply levels (amount of time) of all ingredients based on total needs
	self.supply = {}
	for name,need in pairs(self.needs) do
		local have = self.ingredients[name] or 0
		if (production == 0) or (need == 0) then self.supply[name] = 0
		elseif need > 0 then self.supply[name] = have / need
		else self.supply[name] = 0
		end
	end

	-- Project weeks of full production available for each factory
	-- Also watch for factory to stall when supply goes below individual factory needs
	for name,info in pairs(self.factories) do
		local factory = _AllBuildings[name]
		local production = factory:GetProduction()
		info.supply = 999999
		local stall = false
		for name,_ in pairs(info.needs) do
			local have = self.ingredients[name] or 0
			if self.supply[name] < info.supply then info.supply = Floor(self.supply[name]) end
			if have < info.needs[name] then stall = true end
		end
		
		if stall and not info.stall then
			newStall = true
			DebugOut("FACTORY", "Factory '" .. factory.name .. "' has stalled due to lack of ingredients.")
		end
		info.stall = stall

		if info.stall then Player.portsAvailable[factory.port.name] = "factory_stall"
		else Player.portsAvailable[factory.port.name] = "factory"
		end
	end
	
	UpdateLedger("factory")
end

function Player:UpdateNeeds()
	-- Gather combined ingredient needs of all factories for one tick of full production
	self.needs = {}
	for _,info in pairs(self.factories) do
		if info.current then
			for name,count in pairs(info.needs) do
				local n = self.needs[name] or 0
				self.needs[name] = n + count * info.production
			end
		end
	end
	
	-- Make sure supplies are computed along with needs
	self:UpdateSupplies()
end

function Player:RunFactories()
	local stall = false
	for name,info in pairs(self.factories) do
		local factory = _AllBuildings[name]
		if info.current then
			-- Determine how many items we can make using current inventory, max out at factory production rate
			local produce = info.production or 0
			local possible = 0
			for name,need in pairs(info.needs) do
				local have = self.ingredients[name] or 0
				possible = Floor(have / need)
				if possible < produce then produce = possible end
			end
			
			-- Consume the appropriate ingredients
			if produce > 0 then
				local currentProd = _AllProducts[info.current]
				DebugOut("FACTORY", "Factory '" .. factory.name .. "' produced " .. produce .. " cases of " .. currentProd:GetName())

				info.stall = false
				for name,count in pairs(info.needs) do
					local consume = count * produce
					self:AddIngredient(name, -consume, true)		-- consume ingredients, defer update
					self.useTimes[name] = self.time
				end
				
				local current = _AllProducts[info.current]
				current:AdjustInventory(produce)
				current:RecordMade(produce)
				self.useTimes[info.current] = self.time
			end
			if produce < info.production then
				info.stall = true
				stall = true
			end
			
			if info.stall then Player.portsAvailable[factory.port.name] = "factory_stall"
			else Player.portsAvailable[factory.port.name] = "factory"
			end
		end
	end
	
	-- After first stall, pop up a warning to the player
	if stall and Player.options.tut_stall then
		UpdateLedger("factory")
		Player.options.tut_stall = false
		DisplayDialog { "ui/ui_generic.lua", text="factory_stalled", noFade=true }
	end
end

function Player:ExpireInventory()
	-- After 32 weeks of non-use, gradually expire inventory at 20% per week
	
	-- Set spoilage timer based on difficulty
	local spoilage_timer = 32 -- Default to Easy
	if Player.difficulty == 2 then -- Medium
		spoilage_timer = 24
	elseif Player.difficulty == 3 then -- Hard
		spoilage_timer = 16
	end
	
	for name,count in pairs(self.ingredients) do
		local age = self.time - (self.useTimes[name] or self.time)
		if age > spoilage_timer then
			-- TODO: Don't expire certain ingredients ?
			local expire = Floor(count * .2 + 0.99)
			if expire > 0 then DebugOut("PLAYER", expire .. " sacks of " .. GetString(name) .. " expired from inventory.") end
			self:AddIngredient(name, -expire, true)
		end
	end

	for code,count in pairs(self.products) do
		-- TODO: Don't expire certain products ?
		-- UGRs don't expire
		local prod = _AllProducts[code]
		if prod.category.name ~= "user" then
			local age = self.time - (self.useTimes[code] or self.time)
			if age > spoilage_timer then
				local expire = Floor(count * .2 + 0.99)
				if expire > 0 then DebugOut("PLAYER", expire .. " cases of " .. prod:GetName() .. " expired from inventory.") end
				self:AddProduct(code, -expire, true)
			end
		end
	end
end

------------------------------------------------------------------------------

function Player:MeetCharacter(char)
	if not char or not char.name then return end

	local charKey = char.name
	
	-- Initialize the character's data if it doesn't exist
	if not self.catalogue.unlockedCharacters[charKey] then
		self.catalogue.unlockedCharacters[charKey] = {
			met = false,
			unlocked = false,
			discovered_likes = {},
			discovered_dislikes = {},
			undiscovered_dislikes_pool = {}
		}
	end

	-- Only proceed if they haven't been marked as 'met' before
	if not self.catalogue.unlockedCharacters[charKey].met then
		-- Mark them as met (Stage 1 discovery)
		self.catalogue.unlockedCharacters[charKey].met = true
		DebugOut("PLAYER", "First meeting with '" .. char.name .. "'. Character has been 'Met'.")
	end
end

------------------------------------------------------------------------------

function Player:SetRank(rank)
	self.rank = rank
--	Player:QueueMessage("msg_rank", GetString("rank"..rank))
	DebugOut("PLAYER", "Player promoted to Rank " .. rank .. ": " .. GetString("rank"..rank))
	UpdateLedger("rank")

--	SetState("Rank", self.rank)		-- FIRST PEEK
end

function Player:GetPort()
	local name = Player.portName -- or Player.destination
	return _AllPorts[name]
end

function Player:RecalculatePricesForCurrentPort()
	local port = self:GetPort()
	if not port then return end

	local portName = port.name
	
	-- Clear the current item prices and recalculate for the new port
	self.itemPrices = {}
	
	-- Prepare Ingredient Prices for this specific port
	if port.buildings then
		for _, building in ipairs(port.buildings) do
			if building.inventory then -- This is a market or farm
				for _, ing in ipairs(building.inventory) do
					local price = 1
					local low, high -- Declare local variables for price range

					-- Pass hemisphere to IsInSeason for inversion
					if ing:IsInSeason(nil, port.hemisphere) then
						low = ing.price_low
						high = ing.price_high
					else
						low = ing.price_low_notinseason
						high = ing.price_high_notinseason
					end
					
					-- Apply ingredient cost multiplier
					local cost_multiplier = 1.0
					if Player.difficulty == 2 then -- Medium
						cost_multiplier = 1.20 -- Ingredients are 20% more expensive
					elseif Player.difficulty == 3 then -- Hard
						cost_multiplier = 1.40 -- Ingredients are 40% more expensive
					end
					
					if cost_multiplier > 1.0 then
						low = Floor(low * cost_multiplier)
						high = Floor(high * cost_multiplier)
					end

					price = RandRange(low, high)
					
					-- Apply tip modifier for this specific port
					local modifier = Tips.GetPriceModifier(ing.name, portName)
					price = Floor(price * modifier)
					self.itemPrices[ing.name] = price
				end
			end
		end
	end

	-- Prepare Product Prices for this specific port
	local ownedShop = false
	for _,b in ipairs(port.buildings) do
		if b.type == "shop" and b:IsOwned() then ownedShop = true; break; end
	end
	
	for code,prod in pairs(_AllProducts) do
		local sold = prod:NumberSold()
		local low = prod.price_low
		local high = prod.price_high
		
		-- Apply product sale price penalty
		local price_penalty = 1.0
		if Player.difficulty == 2 then -- Medium
			price_penalty = 0.90 -- Player earns only 90% of the normal sale price
		elseif Player.difficulty == 3 then -- Hard
			price_penalty = 0.80 -- Player earns only 80% of the normal sale price
		end

		if price_penalty < 1.0 then
			low = Floor(low * price_penalty)
			high = Floor(high * price_penalty)
		end

		if ownedShop then
			-- At owned shops, there's a 20% markup, and prices are guaranteed in the upper third of the resulting range
			low = low * 1.2
			high = high * 1.2
			low = low + (high - low) * .66
		end
		local price = RandRange(low, high)
		local middle = (low + high) / 2
		
		-- TODO: In ChocoTwo, once you won the game, prices reverted to completely random forever...
		
		-- In Choco Three, prices on UGRs don't deteriorate -- here, that means they always behave
		-- as though you haven't sold any...
		if prod.category.name == "user" then sold = 0 end

		-- Apply product pricing rules as product sells
		-- Apply difficulty-based price decay
		local decay_mod = 1.0
		local floor_mod = 0.9
		if Player.difficulty == 2 then -- Medium
			decay_mod = 1.5 -- Decay happens 50% faster
			floor_mod = 0.8 -- Bottom price is 80% of cost
		elseif Player.difficulty == 3 then -- Hard
			decay_mod = 2.0 -- Decay happens twice as fast
			floor_mod = 0.7 -- Bottom price is 70% of cost
		end

		if sold <= (2000 / decay_mod) then
			-- Tend towards "middle" price over the first N sales
			price = price + (middle - price) * (sold * decay_mod) / 2000
		elseif sold < (7000 / decay_mod) then
			-- Tend towards the "lowest" price over the next N sales
			price = middle + (low - middle) * ((sold - (2000 / decay_mod)) * decay_mod) / 5000
		elseif prod.category.name == "truffle" or prod.category.name == "blend" then
			-- Truffles and Blends sell at cost forever, rely on "owned shop" markup forever
			price = low
		else
			-- After selling N, the bottom drops out of the market and everything sells
			-- below cost at non-owned shops
			price = Floor(low * floor_mod + .5)
		end

		-- Apply tip modifier at the very end
		local modifier = Tips.GetPriceModifier(code, portName)
		price = Floor(price * modifier)
		
		self.itemPrices[code] = price
	end
	
	-- Tutorial Price Overrides
	if self.rank == 1 then
		if portName == "zurich" then
			local ing = _AllIngredients["sugar"]
			self.itemPrices[ing.name] = 7		--Floor(ing.price_low + .2 * (ing.price_high - ing.price_low))
			ing = _AllIngredients["cacao"]
			self.itemPrices[ing.name] = 11	--Floor(ing.price_low + .2 * (ing.price_high - ing.price_low))
			ing = _AllIngredients["milk"]
			self.itemPrices[ing.name] = Floor(ing.price_low + .2 * (ing.price_high - ing.price_low))
			ing = _AllIngredients["caramel"]
			self.itemPrices[ing.name] = Floor(ing.price_low + .2 * (ing.price_high - ing.price_low))

			local prod = _AllProducts["b01"]
			self.itemPrices[prod.code] = 85	--Floor(prod.price_low + .8 * (prod.price_high - prod.price_low))
			prod = _AllProducts["b02"]
			self.itemPrices[prod.code] = Floor(prod.price_low + .8 * (prod.price_high - prod.price_low))
			prod = _AllProducts["b03"]
			self.itemPrices[prod.code] = Floor(prod.price_low + .8 * (prod.price_high - prod.price_low))
			
		elseif portName == "douala" then
			local ing = _AllIngredients["sugar"]
			self.itemPrices[ing.name] = 9		--Floor(ing.price_low + .2 * (ing.price_high - ing.price_low))
			ing = _AllIngredients["cacao"]
			self.itemPrices[ing.name] = 11	--Floor(ing.price_low + .2 * (ing.price_high - ing.price_low))
		end
	end
end

function Player:SetPort(portName)
	if portName then
		if self.portName ~= portName then
			-- Store the previous port before updating to the new one
			if self.portName and self.portName ~= "enroute" then 
				self.lastPort = self.portName 
			end
			-- Record the time of arrival at the new port
			self.lastVisitTime[portName] = self.time

			self.portName = portName
			self.destination = nil
			
			DebugOut("PLAYER", "Arrived at port: " .. GetString(portName))

			self:RecalculatePricesForCurrentPort()
			
			PrepareTravelPrices()
			
			-- Anyone will haggle
			self.haggleDisable = {}
		end
	else
		self.portName = nil
	end
end

function Player:GetPrimaryQuest()
	local q = nil
	if self.questPrimary then q = _AllQuests[self.questPrimary] end
	return q
end

function Player:SetPrimaryQuest(questName)
	if not questName then
		local t = -1
		for name,time in pairs(self.questsActive) do
			if time > t then
				questName  = name
				t = time
			end
		end
	end

	if self.questPrimary ~= questName then
		self.questPrimary = questName
		if questName then
			DebugOut("QUEST", "Primary quest set to: " .. questName)
		else
			DebugOut("QUEST", "Primary quest cleared.")
		end
		UpdateLedger("quest")
		FadeIn{"questText"}
		
		devUpdateQuest()
	end

	UpdateActiveQuestGoalsComplete()
end

function Player:SetMoney(newMoney, silent)
	if self.money ~= newMoney then
		if not silent then
			if newMoney > self.money then SoundEvent("money_in_account") end
			-- TODO: Play "money going up" or "money going down" sound
		end

		self.money = newMoney
		UpdateLedger("money")
		
--		SetState("Money", self.money)		-- FIRST PEEK
	end
end

function Player:AddMoney(money, silent)
	local newMoney = self.money + money
	if newMoney < 0 then newMoney = 0 end
	if not silent then DebugOut("PLAYER", "Money changed by " .. Dollars(money) .. ". New total: " .. Dollars(newMoney)) end
	self:SetMoney(newMoney, silent)
end

function Player:SubtractMoney(money, silent)
	local newMoney = self.money - money
	if newMoney < 0 then newMoney = 0 end
	if not silent then DebugOut("PLAYER", "Money changed by -" .. Dollars(money) .. ". New total: " .. Dollars(newMoney)) end
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
		DebugOut("PLAYER", action .. absCount .. " " .. ingName .. ". New total: " .. newCount)
	end

	-- Update supply numbers for this ingredient if it is currently in use
	if (not deferRecalculation) and Player.needs[name] then
		Player:UpdateSupplies()
	end
	
	-- TODO: Signal inventory change?
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
		DebugOut("PLAYER", action .. absCount .. " " .. prodName .. ". New total: " .. newCount)
	end

	-- TODO: Signal inventory change?
end

function Player:GetKnownRecipeCount(categoryName)
	local n = 0
	if categoryName then n = Player.categoryCount[categoryName] or 0
	else
		-- Count all categories
		for name,count in pairs(Player.categoryCount) do
			n = n + count
		end
	end
	return n
end

function Player:GetMadeRecipeCount(categoryName)
	local n = 0
	if categoryName then n = Player.categoryMadeCount[categoryName] or 0
	else
		-- Count all categories
		for name,count in pairs(Player.categoryMadeCount) do
			n = n + count
		end
	end
	return n
end

------------------------------------------------------------------------------

-- Define holiday weeks (1-52)
-- Q1: The Post-Holiday Slump & Recovery
-- Q2: Spring
-- Q3: The Heat (Hemisphere Dependent)
-- Q4: The Golden Quarter
local HolidayCalendar = {
	{ name = "resolutions",	startWeek = 1,  endWeek = 3 },   -- Dieting (Negative)
	{ name = "lunar_new_year", startWeek = 4,  endWeek = 5 },   -- (Positive)
	{ name = "valentine",	  startWeek = 6,  endWeek = 6 },   -- (Positive)
	{ name = "carnival",	   startWeek = 8,  endWeek = 8 },   -- (Positive)
	{ name = "lent",		   startWeek = 8,  endWeek = 13 },  -- Fasting (Negative)
	{ name = "easter",		 startWeek = 14, endWeek = 15 },  -- (Positive)
	{ name = "dog_days_n",	 startWeek = 27, endWeek = 34, hemisphere="north" }, -- Summer Slump North (Negative)
	{ name = "dog_days_s",	 startWeek = 1,  endWeek = 8,  hemisphere="south" }, -- Summer Slump South (Negative)
	{ name = "ramadan",		startWeek = 35, endWeek = 38 },  -- Fasting (Negative)
	{ name = "eid_ul_fitr",	startWeek = 39, endWeek = 39 },  -- Feasting (Positive)
	{ name = "halloween",	  startWeek = 43, endWeek = 44 },  -- (Positive)
	{ name = "di_de_muertos",  startWeek = 44, endWeek = 44 },  -- (Positive)
	{ name = "diwali",		 startWeek = 45, endWeek = 45 },  -- (Positive)
	{ name = "thanksgiving",   startWeek = 47, endWeek = 47 },  -- (Positive)
	{ name = "christmas",	  startWeek = 50, endWeek = 52 },  -- (Positive)
}

function Player:UpdateHolidays()
	-- Calculate calendar week (1-52) based on start date June 27 (Week 26 approx)
	local calendar_week = Mod(self.time + 25, 52) + 1 
	
	self.currentHolidays = {}
	
	for _, h in ipairs(HolidayCalendar) do
		if calendar_week >= h.startWeek and calendar_week <= h.endWeek then
			self.currentHolidays[h.name] = true
			DebugOut("SIM", "Active holiday: " .. h.name)
		end
	end
end

-- Helper to check if a specific port celebrates the current holiday
function Player:GetActiveHolidayForPort(portName)
	local port = _AllPorts[portName]
	
	-- MOD: Look up culture/hemisphere on the port object itself
	local culture = "western"
	local hemisphere = "north"
	
	if port then
		if port.culture then culture = port.culture end
		if port.hemisphere then hemisphere = port.hemisphere end
	end

	local hols = self.currentHolidays
	if not hols then return nil end

	-- Hemisphere Checks
	if hols.dog_days_n and hemisphere == "north" then return "dog_days_n" end
	if hols.dog_days_s and hemisphere == "south" then return "dog_days_s" end

	-- Culture-Specific Overrides
	if hols.eid_ul_fitr and culture == "muslim" then return "eid_ul_fitr" end
	if hols.ramadan and culture == "muslim" then return "ramadan" end
	
	if hols.lunar_new_year then
		-- San Francisco has a unique dual-culture status due to Chinatown
		if culture == "east_asian" or portName == "sanfrancisco" then return "lunar_new_year" end
	end
	
	if hols.diwali and culture == "hindu" then return "diwali" end
	
	if hols.di_de_muertos and culture == "latin" then return "di_de_muertos" end
	if hols.carnival and culture == "latin" then return "carnival" end
	
	if hols.thanksgiving and culture == "north_american" then return "thanksgiving" end
	
	-- Global/Western Fallbacks
	-- Muslim/Hindu/East Asian ports generally don't celebrate Western religious holidays in this era
	if hols.christmas and culture ~= "muslim" and culture ~= "east_asian" and culture ~= "hindu" then return "christmas" end
	if hols.easter and culture ~= "muslim" and culture ~= "east_asian" and culture ~= "hindu" then return "easter" end
	
	-- Broad Cultural Events
	if hols.resolutions and (culture == "western" or culture == "north_american" or culture == "european" or culture == "latin" or culture == "commonwealth") then return "resolutions" end
	if hols.lent and (culture == "western" or culture == "north_american" or culture == "european" or culture == "latin") then return "lent" end
	
	-- Halloween is treated as secular, but Latin America gets Day of the Dead instead
	if hols.halloween and culture ~= "latin" then return "halloween" end 
	
	-- Valentine is treated as a global secular event
	if hols.valentine then return "valentine" end

	return nil
end

------------------------------------------------------------------------------

function Player:CheckMedals()
	-- 1: quest variable rank2_work > 1
	if (not self.medals.medal_01) then
		if Player.questVariables.rank2_work and Player.questVariables.rank2_work > 1 then return "medal_01" end
	end
	
	-- 2: manufacture 8 BSG chocolate recipes
	if (not self.medals.medal_02) then
		local total = (Player.categoryMadeCount.bar or 0) + (Player.categoryMadeCount.infusion or 0)
			+ (Player.categoryMadeCount.truffle or 0) + (Player.categoryMadeCount.exotic or 0)
		if total >= 8 then return "medal_02" end
	end
	
	-- 3: manufacture 10 of "our" coffee recipes
	if (not self.medals.medal_03) then
		local total = (Player.categoryMadeCount.beverage or 0) + (Player.categoryMadeCount.blend or 0)
		if total >= 10 then return "medal_03" end
	end
	
	-- 4: 3 UGRs _sold_
	if (not self.medals.medal_04) then
		local n = 0
		for code,name in pairs(self.itemNames) do
			if self.itemsSold[code] and self.itemsSold[code] > 0 then n = n + 1 end
		end
		if n >= 3 then return "medal_04" end
	end
	
	-- 5: 3 shops owned
	if (not self.medals.medal_05) then
		if self.shopsOwned >= 3 then return "medal_05" end
	end
	
	-- 6: 6 factories owned (all factories)
	if (not self.medals.medal_06) then
		if self.factoriesOwned == 6 then return "medal_06" end
	end
	
	-- 7: rank is 5
	if (not self.medals.medal_07) then
		if self.rank >= 5 then return "medal_07" end
	end
	
	-- 8: 20 ports visited (all ports)
	if (not self.medals.medal_08) then
		if self.portVisitCount >= 20 then return "medal_08" end
	end
	
	-- 9: 12 UGR slots filled (all slots)
	if (not self.medals.medal_09) then
		if self.categoryCount.user == 12 then return "medal_09" end
	end
	
	return nil
end