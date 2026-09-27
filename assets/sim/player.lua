--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Player Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-- The "Player" class is the repository for all player-specific game state.
-- This singleton table tracks everything from inventory to quest progression.
Player =
{
	-- ==========================================
	-- Core Identity & Progression
	-- ==========================================
	name = nil,						-- Player name
	mode = "story",					-- "story" or "free"; native mode flag only (Free Play persistence is Reforged-owned)
	freePlayVersion = 0,				-- Free Play save/migration marker
	freePlayProfileId = "",			-- Stable local profile token used to bind the Free Play sidecar across renames
	deliveryDeadlineVersion = 1,		-- Special Order deadline/migration marker
		highScoreDisplayName = "",		-- Public community leaderboard alias
		highScoreNationality = "",		-- Optional public community leaderboard flag code
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
	buildingCharacters = {},		-- Temporary/scripted character placement { building = { characterName = true } }
	characterLocations = {},		-- Living-world mobility state { characterName = { mode=..., ... } }
	characterLocks = {},			-- Mobility ownership locks { characterName = { kind, owner, ... } }
	questLocations = {},			-- Active stay-where-met quest locations { questName = { character, building, port } }
	characterMobilityVersion = 0,	-- Save migration marker for the living-character system
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

	-- Free Play keeps its own unlimited Player.itemRecipes. Story creations are
	-- mirrored separately and rebuilt into the live user category as read-only
	-- products whenever Free Play loads.
	storyCreationLibrary = {
		recipes = {}, appearance = {}, names = {}, descriptions = {},
		prices = {}, machinery = {}, retained = {},
	},

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
	questsAcceptedEver = {},		-- Set of { name = first/last accepted time } for migration/repair logic
	questVariables = {},			-- Set of { name = value } variables for use by quest scripting
	questDifficulty = {},			-- Set of { name = difficulty } for active quests
	questHintCooldowns = {},		-- Set of { quest_name = endTime } for hint cooldowns

	lastOfferTime = nil,			-- Time of last offered quest
	lastAcceptTime = nil,			-- Time of last accepted quest
	lastCompleteTime = nil,			-- Time of last completed quest
	lastOrderTime = nil,			-- Time of last special order

	shopOrderData = {},	 			-- Stores Special Order chance/cooldown state for eligible origin shops
	pendingSpecialOrders = {},	 	-- A queue for generated orders waiting for delivery
	pendingAftermaths = {},			-- Building-scoped special-order aftermath dialogue queues
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

	-- Competitive save-integrity metadata. This is persisted with the Player
	-- table so leaderboard eligibility follows the campaign rather than the
	-- current settings.xml state alone.
	integrity = nil,

	-- Reforged high-score statistics and personal-best history.
	stats = nil,
}

-- Dedicated Reforged statistics / score model. Kept in its own script so the
-- campaign-save format, score formula, and Score Details UI have one source of truth.
require("sim/hiscore_model.lua")

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
-- Ranked Campaign / Save Integrity
------------------------------------------------------------------------------

local kIntegrityVersion = 1
local kIntegrityRanked = "ranked"
local kIntegrityLegacy = "legacy_unverified"
local kIntegrityDev = "unranked_dev"

local function CopyPlainTable(value)
	if type(value) ~= "table" then return value end
	local out = {}
	for k, v in pairs(value) do out[k] = CopyPlainTable(v) end
	return out
end

local function CurrentNativeMode(mode)
	if mode == "free" then return 1 end
	return 0
end

local function SafeFileToken(value)
	value = string.lower(tostring(value or "player"))
	value = string.gsub(value, "[^a-z0-9_-]", "_")
	value = string.gsub(value, "_+", "_")
	value = string.gsub(value, "^_+", "")
	value = string.gsub(value, "_+$", "")
	if value == "" then value = "player" end
	return string.sub(value, 1, 32)
end

local function NewFreePlayProfileId()
	local userIndex = 0
	if GetCurrentUser then
		local ok, value = pcall(function() return GetCurrentUser() end)
		if ok and type(value) == "number" then userIndex = value end
	end
	local stamp = 0
	if CurrentTime then
		local ok, value = pcall(function() return CurrentTime() end)
		if ok and type(value) == "number" then stamp = value end
	end
	local name = GetCurrentUserName and GetCurrentUserName() or Player.name or "player"
	return string.format("%s_%d_%d", SafeFileToken(name), userIndex, stamp)
end

function Player:EnsureFreePlayProfileId()
	local value = tostring(self.freePlayProfileId or "")
	if value == "" then
		value = NewFreePlayProfileId()
		self.freePlayProfileId = value
		DebugOut("FREEPLAY", "Assigned local Free Play profile token: " .. value)
	end
	return value
end

function Player:GetFreePlaySaveFileName(profileId)
	profileId = tostring(profileId or self:EnsureFreePlayProfileId())
	return "reforged_freeplay_" .. SafeFileToken(profileId) .. ".choco3"
end

local function DecodeSaveString(saveString)
	if type(saveString) ~= "string" or saveString == "" then return nil end
	local loader = loadstring(saveString)
	if type(loader) ~= "function" then return nil end
	local ok, value = pcall(loader)
	if ok and type(value) == "table" then return value end
	return nil
end

function Player:IsFreePlay()
	return self.mode == "free"
end

function Player:SetGameMode(mode)
	if mode ~= "free" then mode = "story" end
	self.mode = mode
	SetCurrentGameMode(CurrentNativeMode(mode))
end

function Player:GetCreationCapacity()
	if self:IsFreePlay() then return nil end -- nil means unlimited
	return self.customSlots or 0
end

-- The shipped Playground layer exposes developer mode through CheckConfig("dev")
-- in this game. Keep this defensive because the exact native config surface can
-- differ between builds.
function Player:IsDevModeActive()
	if IsDevModeEnabled then
		local ok, enabled = pcall(function() return IsDevModeEnabled() end)
		if ok and enabled then return true end
	end

	if CheckConfig then
		local ok, enabled = pcall(function() return CheckConfig("dev") end)
		if ok and enabled then return true end
	end

	return false
end

local function NewIntegrityTable(status)
	return {
		version = kIntegrityVersion,
		status = status,
		firstTaintedWeek = nil,
		lastReason = nil,
		devSessions = 0,
	}
end

-- Strict policy: a campaign that is loaded or saved while developer/cheat mode
-- is active becomes permanently unranked. This deliberately avoids pretending
-- that every possible developer mutation can be intercepted in moddable Lua.
function Player:MarkUnrankedForDev(reason)
	if type(self.integrity) ~= "table" then
		self.integrity = NewIntegrityTable(kIntegrityDev)
	end

	local wasDev = self.integrity.status == kIntegrityDev
	self.integrity.version = kIntegrityVersion
	self.integrity.status = kIntegrityDev
	self.integrity.firstTaintedWeek = self.integrity.firstTaintedWeek or (self.time or 1)
	self.integrity.lastReason = reason or "dev_mode_active"

	if not wasDev then
		DebugOut("PLAYER", string.format(
			"Campaign integrity changed to UNRANKED at week %d (%s).",
			self.integrity.firstTaintedWeek or 1, self.integrity.lastReason
		))
	end
end

function Player:InitializeIntegrity(savedIntegrity, restoring)
	if type(savedIntegrity) == "table" and savedIntegrity.status then
		self.integrity = {
			version = tonumber(savedIntegrity.version) or kIntegrityVersion,
			status = tostring(savedIntegrity.status),
			firstTaintedWeek = savedIntegrity.firstTaintedWeek,
			lastReason = savedIntegrity.lastReason,
			devSessions = tonumber(savedIntegrity.devSessions) or 0,
		}
	else
		-- Saves created before integrity tracking cannot honestly be certified.
		self.integrity = NewIntegrityTable(restoring and kIntegrityLegacy or kIntegrityRanked)
	end

	if self:IsDevModeActive() then
		self.integrity.devSessions = (self.integrity.devSessions or 0) + 1
		self:MarkUnrankedForDev("dev_mode_active")
	end
end

function Player:SyncIntegrityWithRuntime()
	if type(self.integrity) ~= "table" then
		self:InitializeIntegrity(nil, true)
	end

	if self:IsDevModeActive() then
		self:MarkUnrankedForDev("dev_mode_active")
	end
end

function Player:GetIntegrityStatus()
	self:SyncIntegrityWithRuntime()
	-- Story and Free Play are separate leaderboard families, but they share the
	-- same integrity rules. Free Play is not inherently unranked.
	return (self.integrity and self.integrity.status) or kIntegrityLegacy
end

function Player:IsRankedEligible()
	return self:GetIntegrityStatus() == kIntegrityRanked and not self:IsDevModeActive()
end

function Player:GetIntegrityServerData(snapshot)
	local status = self:GetIntegrityStatus()
	return HighScoreModel:BuildServerMetadata(self, snapshot, status, kIntegrityVersion)
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
		"catalogue_strings.xml",
		"kitchen_strings.xml"
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

-- Public Reforged v1 used the ingredient id/code pepper/PEP. v2 replaces that
-- ingredient with cayenne/CAY. A raw v1 save can therefore contain the retired
-- identifier in inventory, Catalogue discovery, factory needs, active market
-- tips and (most importantly) player-created recipe signatures. Migrate those
-- identifiers before delivery quests or custom products are reconstructed.
local function MergeTableMissing(destination, source)
	if type(destination) ~= "table" or type(source) ~= "table" then return destination end
	for key, value in pairs(source) do
		if destination[key] == nil then destination[key] = value end
	end
	return destination
end

local function MoveSaveKey(t, oldKey, newKey, mergeMode)
	if type(t) ~= "table" or t[oldKey] == nil then return false end
	local oldValue = t[oldKey]
	local newValue = t[newKey]

	if newValue == nil then
		t[newKey] = oldValue
	elseif mergeMode == "sum" and type(newValue) == "number" and type(oldValue) == "number" then
		t[newKey] = newValue + oldValue
	elseif mergeMode == "bool" then
		t[newKey] = (newValue and true) or (oldValue and true) or false
	elseif mergeMode == "table" and type(newValue) == "table" and type(oldValue) == "table" then
		MergeTableMissing(newValue, oldValue)
	end

	t[oldKey] = nil
	return true
end

local function MoveNestedSaveKey(t, oldKey, newKey, mergeMode)
	if type(t) ~= "table" then return end
	for _, nested in pairs(t) do
		if type(nested) == "table" then MoveSaveKey(nested, oldKey, newKey, mergeMode) end
	end
end

local function RemoveQuestState(t, questName)
	if type(t) ~= "table" then return end
	local fields = {
		"questStarters", "questOfferText", "questsActive", "questsWaiting",
		"questsComplete", "questsDeferred", "questsAcceptedEver", "questDifficulty",
		"questHintCooldowns", "questLocations",
	}
	for _, field in ipairs(fields) do
		if type(t[field]) == "table" then t[field][questName] = nil end
	end
	if t.questPrimary == questName then t.questPrimary = nil end
end

local function BuildMigratedCustomRecipeCodeMap(t)
	local mapping = {}
	if type(t.itemRecipes) ~= "table" then return mapping end

	for _, codeTable in ipairs(t.itemRecipes) do
		if type(codeTable) == "table" and table.getn(codeTable) >= 2 then
			local oldCode = string.lower(table.concat(codeTable, "_"))
			local changed = false
			local ingredientCodes = {}
			for i = 2, table.getn(codeTable) do
				local code = codeTable[i]
				if code == "PEP" then code = "CAY"; changed = true end
				table.insert(ingredientCodes, code)
			end
			if changed then
				table.sort(ingredientCodes)
				for i = 1, table.getn(ingredientCodes) do codeTable[i + 1] = ingredientCodes[i] end
				local newCode = string.lower(table.concat(codeTable, "_"))
				mapping[oldCode] = newCode
			end
		end
	end
	return mapping
end

local function MigrateSavedProductCode(t, oldCode, newCode)
	local keyedTables = {
		"products", "lastSeenPort", "lastSeenPrice", "lowPrice", "highPrice", "useTimes",
		"knownRecipes", "itemPrices", "itemsMade", "itemsSold", "firstEverSell",
		"itemAppearance", "itemNames", "itemDescriptions", "itemMachinery",
	}
	for _, field in ipairs(keyedTables) do
		if type(t[field]) == "table" then MoveSaveKey(t[field], oldCode, newCode) end
	end

	MoveNestedSaveKey(t.firstSell, oldCode, newCode)

	if t.lastTastedRecipeCode == oldCode then t.lastTastedRecipeCode = newCode end

	for _, top in pairs(t.factoryTopProduct or {}) do
		if type(top) == "table" and top.code == oldCode then top.code = newCode end
	end
	for _, factory in pairs(t.factories or {}) do
		if type(factory) == "table" then
			if factory.current == oldCode then factory.current = newCode end
			if type(factory.output) == "table" then MoveSaveKey(factory.output, oldCode, newCode, "sum") end
		end
	end

	local function MigrateOrderProduct(order)
		if type(order) ~= "table" then return end
		if order.product == oldCode then order.product = newCode end
		for _, item in ipairs(order.items or {}) do
			if type(item) == "table" and item.product == oldCode then item.product = newCode end
		end
	end

	for _, delivery in ipairs(t.deliveries or {}) do MigrateOrderProduct(delivery) end
	for _, order in ipairs(t.pendingSpecialOrders or {}) do MigrateOrderProduct(order) end
	for _, tip in ipairs(t.activeTips or {}) do if tip.item == oldCode then tip.item = newCode end end
	for _, tip in ipairs(t.pendingAnnouncements or {}) do if type(tip) == "table" and tip.item == oldCode then tip.item = newCode end end
end

function Player:MigrateV1SaveIdentifiers(t)
	if type(t) ~= "table" then return end
	local touched = false

	-- Build this map before changing PEP inside the code tables so every other
	-- saved reference to a custom product can follow its new v2 signature.
	local customCodeMap = BuildMigratedCustomRecipeCodeMap(t)
	for oldCode, newCode in pairs(customCodeMap) do
		MigrateSavedProductCode(t, oldCode, newCode)
		touched = true
		DebugOut("MIGRATION", string.format("V1 custom recipe id migrated: %s -> %s.", oldCode, newCode))
	end

	-- Ingredient-keyed state. Public v1 cannot legitimately contain a cayenne
	-- key, but the merge modes keep this migration idempotent for later migrated saves.
	if MoveSaveKey(t.ingredients, "pepper", "cayenne", "sum") then touched = true end
	if MoveSaveKey(t.ingredientsAvailable, "pepper", "cayenne", "bool") then touched = true end
	if MoveSaveKey(t.labIngredients, "pepper", "cayenne", "bool") then touched = true end
	if MoveSaveKey(t.labFirstUse, "pepper", "cayenne", "bool") then touched = true end
	if MoveSaveKey(t.firstEverBuy, "pepper", "cayenne", "bool") then touched = true end
	if MoveSaveKey(t.needs, "pepper", "cayenne", "sum") then touched = true end
	if MoveSaveKey(t.supply, "pepper", "cayenne", "sum") then touched = true end
	if MoveSaveKey(t.itemPrices, "pepper", "cayenne") then touched = true end
	if MoveSaveKey(t.lastSeenPort, "pepper", "cayenne") then touched = true end
	if MoveSaveKey(t.lastSeenPrice, "pepper", "cayenne") then touched = true end
	if MoveSaveKey(t.lowPrice, "pepper", "cayenne") then touched = true end
	if MoveSaveKey(t.highPrice, "pepper", "cayenne") then touched = true end
	if MoveSaveKey(t.useTimes, "pepper", "cayenne") then touched = true end
	MoveNestedSaveKey(t.firstBuy, "pepper", "cayenne", "bool")

	for _, factory in pairs(t.factories or {}) do
		if type(factory) == "table" and type(factory.needs) == "table" then
			if MoveSaveKey(factory.needs, "pepper", "cayenne", "sum") then touched = true end
		end
	end

	for _, tip in ipairs(t.activeTips or {}) do
		if type(tip) == "table" and tip.item == "pepper" then tip.item = "cayenne"; touched = true end
	end
	for _, tip in ipairs(t.pendingAnnouncements or {}) do
		if type(tip) == "table" and tip.item == "pepper" then tip.item = "cayenne"; touched = true end
	end

	if type(t.catalogue) == "table" then
		if MoveSaveKey(t.catalogue.unlockedIngredients, "pepper", "cayenne", "bool") then touched = true end
		if MoveSaveKey(t.catalogue.discoveredIngredientLocations, "pepper", "cayenne", "table") then touched = true end
		if MoveSaveKey(t.catalogue.discoveredIngredientSeasons, "pepper", "cayenne", "table") then touched = true end
	end

	-- History documents added as rewards in v2 need a retroactive grant when a
	-- public v1 save has already passed the corresponding story beat.
	t.catalogue = t.catalogue or {}
	t.catalogue.unlockedHistory = t.catalogue.unlockedHistory or {}
	local historyUnlocks = {
		{ quest = "tut_over", article = "catalogue_history_letter_alex_sean_1" },
		{ quest = "tut_over_notut", article = "catalogue_history_letter_alex_sean_1" },
		{ quest = "rank2_coffee01", article = "catalogue_history_journal_felix_coffee" },
		{ quest = "rank4_story_tok_mountainkeep_2", article = "catalogue_history_letter_hardy_sean" },
	}
	for _, data in ipairs(historyUnlocks) do
		if type(t.questsComplete) == "table" and t.questsComplete[data.quest] ~= nil
			and not t.catalogue.unlockedHistory[data.article] then
			t.catalogue.unlockedHistory[data.article] = true
			touched = true
			DebugOut("MIGRATION", string.format("Retroactively unlocked history article '%s' from v1 quest '%s'.", data.article, data.quest))
		end
	end

	-- The Tangiers-only reminder was retired in v2. It carried no lasting reward
	-- beyond its reminder counter, so stale active/waiting/deferred state should be
	-- discarded rather than left pointing at a quest definition that no longer exists.
	local hadRetiredQuest =
		(t.questPrimary == "tan_shop_owned_00") or
		(type(t.questsActive) == "table" and t.questsActive.tan_shop_owned_00 ~= nil) or
		(type(t.questsWaiting) == "table" and t.questsWaiting.tan_shop_owned_00 ~= nil) or
		(type(t.questsDeferred) == "table" and t.questsDeferred.tan_shop_owned_00 ~= nil) or
		(type(t.questsComplete) == "table" and t.questsComplete.tan_shop_owned_00 ~= nil)
	RemoveQuestState(t, "tan_shop_owned_00")
	if hadRetiredQuest then touched = true; DebugOut("MIGRATION", "Removed retired v1 quest state: tan_shop_owned_00.") end

	if touched then DebugOut("MIGRATION", "Reforged v1 identifier migration completed.") end
end

-- Reforged v2 originally treated delivery deadlines inconsistently at the weekly
-- boundary: dialogue could still display "0 weeks left" while the order's timing
-- hint had already failed. Delivery quests now have a final arrival grace week.
-- This migration also rescues older saves that were parked at the recipient with
-- the full shipment in inventory after the old logic had already pushed the order
-- farther past its deadline.
local kDeliveryDeadlineVersion = 1

local function SavedDeliveryShipmentReady(saveTable, delivery)
	local products = (saveTable and saveTable.products) or {}
	if type(delivery.items) == "table" and table.getn(delivery.items) > 0 then
		for _, item in ipairs(delivery.items) do
			if (products[item.product] or 0) < (item.count or 0) then return false end
		end
		return true
	end
	return (products[delivery.product] or 0) >= (delivery.count or 0)
end

local function RepairSavedDeliveryDeadlines(saveTable)
	if type(saveTable) ~= "table" then return end
	if (saveTable.deliveryDeadlineVersion or 0) >= kDeliveryDeadlineVersion then return end

	local currentPort = saveTable.portName or saveTable.destination
	local active = saveTable.questsActive or {}
	local now = saveTable.time or 1
	local repaired = 0

	for _, delivery in ipairs(saveTable.deliveries or {}) do
		local accepted = active[delivery.name]
		local endBuilding = delivery.endbuilding and _AllBuildings and _AllBuildings[delivery.endbuilding] or nil
		local endPort = endBuilding and endBuilding.port and endBuilding.port.name or nil
		if accepted and delivery.expires and currentPort and endPort == currentPort
		   and SavedDeliveryShipmentReady(saveTable, delivery) then
			local weeksPassed = now - accepted
			local weeksLeft = delivery.expires - weeksPassed
			if weeksLeft < -1 then
				-- Move only this already-stranded order forward to the new final arrival
				-- window. The next week will expire it normally if the player still does
				-- not hand the shipment to the recipient.
				delivery.expires = delivery.expires + ((-1) - weeksLeft)
				repaired = repaired + 1
				DebugOut("MIGRATION", string.format(
					"Recovered overdue Special Order '%s' for one final delivery window in %s.",
					tostring(delivery.name), tostring(currentPort)))
			end
		end
	end

	saveTable.deliveryDeadlineVersion = kDeliveryDeadlineVersion
	if repaired > 0 then
		DebugOut("MIGRATION", string.format("Recovered %d stranded Special Order(s) under delivery deadline v%d.", repaired, kDeliveryDeadlineVersion))
	end
end

function Player:Reset(restoreTable)
	DebugOut("PLAYER", "Resetting player state from save data or a fresh profile.")

	-- Normalize identifiers retired/renamed since public Reforged v1 before any
	-- saved delivery quest or custom recipe is reconstructed.
	if restoreTable then self:MigrateV1SaveIdentifiers(restoreTable) end
	if restoreTable then RepairSavedDeliveryDeadlines(restoreTable) end

	-- First, restore any saved delivery quests
	if restoreTable and restoreTable.deliveries then
		for _,t in ipairs(restoreTable.deliveries) do CreateDeliveryQuest(t) end
		restoreTable.deliveries = nil
	end

	-- Clear the live user-product registry before changing save modes/profiles.
	-- Player.itemRecipes stores code tables, not product-code strings, and Free
	-- Play also exposes mirrored Story products that are not in itemRecipes at all.
	-- Clearing from the category is therefore the reliable anti-bleed boundary.
	local previousUserCategory = _AllCategories and _AllCategories["user"]
	if previousUserCategory then
		for _, prod in ipairs(previousUserCategory.products or {}) do
			if prod and prod.code then _AllProducts[prod.code] = nil end
		end
		previousUserCategory:Clear()
	end

	local t = restoreTable or {}

	-- Core Data
	self.name = t.name or nil
	self.mode = t.mode or "story"
	self.freePlayVersion = t.freePlayVersion or 0
	self.freePlayProfileId = tostring(t.freePlayProfileId or "")
	self.deliveryDeadlineVersion = t.deliveryDeadlineVersion or kDeliveryDeadlineVersion
	self.highScoreDisplayName = t.highScoreDisplayName or self.name or ""
	-- UI preference only; the high-score UI validates the code against its own registry.
	self.highScoreNationality = t.highScoreNationality or ""
	-- Cloud Save linkage belongs to the campaign; account credentials do not.
	self.communityCloudSaveId = t.communityCloudSaveId or ""
	self.communityCloudRevision = t.communityCloudRevision or 0
	self.communityCloudLastSync = t.communityCloudLastSync or ""
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
	self.characterLocations = t.characterLocations or {}
	self.characterLocks = t.characterLocks or {}
	self.questLocations = t.questLocations or {}
	self.characterMobilityVersion = t.characterMobilityVersion or 0
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
	self.storyCreationLibrary = t.storyCreationLibrary or { recipes = {}, appearance = {}, names = {}, descriptions = {}, prices = {}, machinery = {}, retained = {} }
	self.storyCreationLibrary.recipes = self.storyCreationLibrary.recipes or {}
	self.storyCreationLibrary.appearance = self.storyCreationLibrary.appearance or {}
	self.storyCreationLibrary.names = self.storyCreationLibrary.names or {}
	self.storyCreationLibrary.descriptions = self.storyCreationLibrary.descriptions or {}
	self.storyCreationLibrary.prices = self.storyCreationLibrary.prices or {}
	self.storyCreationLibrary.machinery = self.storyCreationLibrary.machinery or {}
	self.storyCreationLibrary.retained = self.storyCreationLibrary.retained or {}
	self.customSlots = t.customSlots or 0

	-- Quests
	self.questPrimary = t.questPrimary or nil
	self.questStarters = t.questStarters or {}
	self.questOfferText = t.questOfferText or {}
	self.questsActive = t.questsActive or {}
	self.questsWaiting = t.questsWaiting or {}
	self.questsComplete = t.questsComplete or {}
	self.questsDeferred = t.questsDeferred or {}
	self.questsAcceptedEver = t.questsAcceptedEver or {}
	self.questDifficulty = t.questDifficulty or {}
	self.questVariables = t.questVariables or { ugr_slots=0 }
	self.questHintCooldowns = t.questHintCooldowns or {}
	self.lastOfferTime = t.lastOfferTime or 0
	self.lastAcceptTime = t.lastAcceptTime or 0
	self.lastCompleteTime = t.lastCompleteTime or 0
	self.lastOrderTime = t.lastOrderTime or 0
	self.shopOrderData = t.shopOrderData or {}
	self.pendingSpecialOrders = t.pendingSpecialOrders or {}
	self.pendingAftermaths = t.pendingAftermaths or {}
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
	if self:IsFreePlay() then self.options.noQuests = true end
	self.difficulty = t.difficulty or 1
	self.haggleDisable = t.haggleDisable or {}

	-- Integrity is restored after core campaign state so any taint records the
	-- correct campaign week. A nil restoreTable means a genuinely new campaign.
	self:InitializeIntegrity(t.integrity, restoreTable ~= nil)

	-- Statistics are versioned separately. Existing saves receive a truthful
	-- baseline at their current week; new campaigns begin full lifetime tracking
	-- from week 1.
	HighScoreModel:EnsureStats(self, t.stats, restoreTable ~= nil)

	-- Prepare/backfill port availability. Older saves may predate newly added ports;
	-- a missing state must inherit the port's current default instead of implicitly
	-- behaving as unlocked.
	if not t.portsAvailable then
		self.portsAvailable = {}
	end
	for name, port in pairs(_AllPorts) do
		if self.portsAvailable[name] == nil then
			if port.hidden then self.portsAvailable[name] = "hidden"
			elseif port.locked then self.portsAvailable[name] = "locked"
			else self.portsAvailable[name] = "new"
			end
		end
	end

	if not t.portsCost then
		PrepareTravelPrices()
	end

	-- Initialize / migrate the living-character world state. The old ghost pools
	-- remain compatibility views maintained by CharacterMobility.
	if CharacterMobility then
		CharacterMobility:Initialize(self, restoreTable ~= nil)
	end

	-- Prepare player's replacement strings
	self.stringTable = { player = self.name }

	-- Restore player-created custom recipes. Free Play has two live views:
	-- a read-only Story library and an unlimited Free Play library. Both are
	-- registered as normal Product objects so factories can manufacture either.
	local category = _AllCategories["user"]
	category:Clear()
	self.categoryCount["user"] = 0

	if self:IsFreePlay() then
		for _, codeTable in ipairs(self.storyCreationLibrary.recipes or {}) do
			local code = string.lower(table.concat(codeTable, "_"))
			self.itemAppearance[code] = self.storyCreationLibrary.appearance[code] or self.itemAppearance[code]
			self.itemNames[code] = self.storyCreationLibrary.names[code] or self.itemNames[code]
			self.itemDescriptions[code] = self.storyCreationLibrary.descriptions[code] or self.itemDescriptions[code]
			self.itemPrices[code] = self.itemPrices[code] or self.storyCreationLibrary.prices[code]
			self.itemMachinery[code] = self.storyCreationLibrary.machinery[code] or self.itemMachinery[code]
			local prod = BuildCustomProduct(codeTable, self.itemAppearance[code], "story")
			if prod then prod.creationLibrary = "story" end
		end
	end

	for i, codeTable in ipairs(self.itemRecipes) do
		local prod = BuildCustomProduct(codeTable, nil, self:IsFreePlay() and "free" or "story")
		if prod then
			prod.creationLibrary = self:IsFreePlay() and "free" or "story"
			self.stringTable["user"..tostring(i)] = prod:GetName()
			DebugOut("RECIPE", string.format("Restored %s creation '%s' from save data.", prod.creationLibrary, prod:GetName()))
		end
	end
	if self:IsFreePlay() then
		self.questVariables.ugr_slots = 999999
	else
		self.questVariables.ugr_slots = self.customSlots - (self.categoryCount.user or 0)
	end

	-- Reset the recipe book view pointers
	gCategorySelection = nil
	gRecipeSelection = nil

	-- Initial location handling
	if not restoreTable or not self.portName then
		DebugOut("PLAYER", "Starting a completely fresh game. Routing to Zurich.")
		self:SetPort("zurich")
	end

	-- Catalogue Ingredient Migration
	if not restoreTable then
		DebugOut("CATALOGUE", "New game detected. Unlocking default catalogue ingredient entries.")

		for _, ing in ipairs(_IngredientOrder) do
			if not ing.locked then
				self.catalogue.unlockedIngredients[ing.name] = true
			end
		end
	else
		local migratedCount = 0

		-- 1. Default ingredients
		-- Any ingredient that is not marked locked in the ingredient data should
		-- always have a visible catalogue entry.
		for _, ing in ipairs(_IngredientOrder) do
			if not ing.locked and not self.catalogue.unlockedIngredients[ing.name] then
				self.catalogue.unlockedIngredients[ing.name] = true
				migratedCount = migratedCount + 1

				DebugOut("CATALOGUE", string.format("Retroactively unlocked default ingredient catalogue entry: %s", ing.name))
			end
		end

		-- 2. Quest-unlocked ingredients from older saves
		-- If an older save already has an ingredient available in markets, the
		-- Catalogue should also show its article.
		for ingredientName, available in pairs(self.ingredientsAvailable or {}) do
			if available and _AllIngredients[ingredientName] and not self.catalogue.unlockedIngredients[ingredientName] then
				self.catalogue.unlockedIngredients[ingredientName] = true
				migratedCount = migratedCount + 1

				DebugOut("CATALOGUE", string.format("Retroactively unlocked catalogue entry for available ingredient: %s", ingredientName))
			end
		end

		-- 3. Inventory-backed discovery
		-- If the player already owns the ingredient, has placed it in the lab,
		-- or has bought it before, the article should not remain blacked out.
		for _, ing in ipairs(_IngredientOrder) do
			local ingredientName = ing.name
			local hasInventory = (self.ingredients[ingredientName] or 0) > 0
			local hasLabEntry = self.labIngredients and self.labIngredients[ingredientName]
			local hasBoughtBefore = self.firstEverBuy and self.firstEverBuy[ingredientName]

			if (hasInventory or hasLabEntry or hasBoughtBefore) and not self.catalogue.unlockedIngredients[ingredientName] then
				self.catalogue.unlockedIngredients[ingredientName] = true
				migratedCount = migratedCount + 1

				DebugOut("CATALOGUE", string.format("Retroactively unlocked catalogue entry for previously handled ingredient: %s", ingredientName))
			end
		end

		if migratedCount > 0 then
			DebugOut("CATALOGUE", string.format("Ingredient catalogue migration completed. Added %d missing entries.", migratedCount))
		else
			DebugOut("CATALOGUE", "Ingredient catalogue migration completed. No missing entries found.")
		end
	end

	-- Apply deterministic compatibility/repair passes after all core state is restored.
	if restoreTable then
		self:ApplyV2IngredientMigration()
		self:RepairKnownProgressionStates()
	end

	-- Synchronize holiday states immediately on load
	self:UpdateHolidays()

	-- Reload strings NOW that options and difficulty are fully set.
	self:ReloadStrings()

	DebugOut("PLAYER", string.format("Player Reset complete. Name: %s, Money: %s, Rank: %d", tostring(self.name or "N/A"), Dollars(self.money), self.rank))
end

-- Repairs saves produced by earlier Reforged builds where rank2_40 could be marked active
-- before AwardText crashed, preventing the mandatory Las Vegas/strawberry unlocks.
function Player:RepairKnownProgressionStates()
	local touched = false
	local rank240Seen = (self.questsAcceptedEver and self.questsAcceptedEver.rank2_40) or self.questsActive.rank2_40 or self.questsComplete.rank2_40

	if rank240Seen then
		local vegas = _AllPorts["lasvegas"]
		local vegasState = self.portsAvailable and self.portsAvailable["lasvegas"]
		if vegas and (vegasState == nil or vegasState == "locked" or vegasState == "hidden") then
			self.portsAvailable["lasvegas"] = "new"
			touched = true
			DebugOut("MIGRATION", "rank2_40 repair: restored Las Vegas unlock for an already-accepted quest.")
		end

		local strawberry = _AllIngredients["strawberry"]
		if strawberry and not strawberry:IsAvailable() then
			strawberry:Unlock()
			self.catalogue.unlockedIngredients["strawberry"] = true
			touched = true
			DebugOut("MIGRATION", "rank2_40 repair: restored strawberry availability for an already-accepted quest.")
		end
	end

	if touched then DebugOut("MIGRATION", "Known progression-state repair completed.") end
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
	self:SyncIntegrityWithRuntime()
	HighScoreModel:EnsureStats(self, self.stats, false)

	local snapshot = HighScoreModel:BuildSnapshot(self)
	if not snapshot or (snapshot.companyScore or 0) <= 0 then return end

	HighScoreModel:UpdatePersonalBest(self, snapshot)

	-- Preserve the original rank/week/cash game-data layout. The compiled 2009
	-- HiscoreWindow still uses it for the small descriptive line under each row.
	local stringData = string.format("%d-%09d-%012.0f", snapshot.rank, snapshot.week, snapshot.money)

	local medalXML = ""
	for i=1, 9 do
		local key = "medal_0"..tostring(i)
		if self.medals[key] then
			medalXML = medalXML .. "<medal name='" .. PFMedalKeys[i] .. "' per='game' />"
		end
	end
	medalXML = medalXML .. self:GetIntegrityServerData(snapshot)

	DebugOut("PLAYER", string.format(
		"Logging Reforged Company Score: %d (Value: %s, Pace: %s/week, Integrity: %s)",
		snapshot.companyScore, Dollars(snapshot.companyValue), Dollars(snapshot.earningsPace), self:GetIntegrityStatus()
	))

	-- Company Score v1 replaces cash/week as the public ranking integer.
	LogScore(snapshot.companyScore, stringData, medalXML)
end

-------------------------------------------------------------------------------
-- Reforged v2 Ingredient Migration
-------------------------------------------------------------------------------
-- This table retroactively unlocks v2 ingredients for players migrating from
-- Reforged v1 saves. Each row corresponds to the quest event that now unlocks
-- the ingredient in the v2 quest files.

-- trigger = "accepted"
--     Unlock if the quest is active, completed, or recorded as accepted-ever.
--     Used for ingredients awarded from onaccept/onaccept_medium/onaccept_hard.

-- trigger = "completed"
--     Unlock only if the quest is completed.
--     Used for ingredients awarded from oncomplete/oncomplete_medium/oncomplete_hard.
-------------------------------------------------------------------------------

local migrationUnlocks =
{
	-- Rank 2 / early-mid progression
	{ quest = "rank2_07", ingredient = "apricot", trigger = "completed" },
	{ quest = "tokyo_02", ingredient = "apricot", trigger = "completed" },
	{ quest = "rank2_38", ingredient = "chamomile", trigger = "completed" },
	{ quest = "ugr_03", ingredient = "cranberry", trigger = "accepted" },
	{ quest = "hav_shop_01", ingredient = "guava", trigger = "accepted" },
	{ quest = "rank2_coffee19", ingredient = "ice_cream", trigger = "completed" },
	{ quest = "open_bali", ingredient = "jasmine", trigger = "accepted" },
	{ quest = "rank2_32", ingredient = "lemongrass", trigger = "completed" },
	{ quest = "rank2_sanfrancisco", ingredient = "marshmallow", trigger = "accepted" },
	{ quest = "rank2_coffee03", ingredient = "oat", trigger = "completed" },
	{ quest = "rank2_tokyo", ingredient = "pear", trigger = "accepted" },
	{ quest = "rank2_30", ingredient = "plum", trigger = "accepted" },
	{ quest = "rank2_39", ingredient = "rosemary", trigger = "completed" },

	-- Rank 3 progression
	{ quest = "off_to_whitney", ingredient = "earl_grey", trigger = "accepted" },
	{ quest = "rank3_03", ingredient = "peach", trigger = "accepted" },
	{ quest = "rank3_09", ingredient = "rhubarb", trigger = "completed" },
	{ quest = "rank3_06", ingredient = "rooibos", trigger = "accepted" },
	{ quest = "rank3_02", ingredient = "tamarind", trigger = "completed" },
	{ quest = "meta_joseph", ingredient = "wafer", trigger = "accepted" },
	{ quest = "rank3_05", ingredient = "jasmine", trigger = "completed" },

	-- Rank 4 / plot progression
	{ quest = "rank4_sean_return", ingredient = "dragonfruit", trigger = "completed" },
	{ quest = "plot_points_07", ingredient = "yuzu", trigger = "accepted" },
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
-- Free Play Synchronization
------------------------------------------------------------------------------

local function CreationCode(codeTable)
	if type(codeTable) ~= "table" then return "" end
	return string.lower(table.concat(codeTable, "_"))
end

function Player:IsFreePlayProductInUse(code)
	if not code or code == "" then return false end
	if (self.products and (self.products[code] or 0) > 0) then return true end
	for _, factory in pairs(self.factories or {}) do
		if type(factory) == "table" then
			if factory.current == code then return true end
			if type(factory.output) == "table" and (factory.output[code] or 0) > 0 then return true end
		end
	end
	return false
end

function Player:SyncStoryCreationLibrary(story)
	if not self:IsFreePlay() or type(story) ~= "table" then return end
	local old = self.storyCreationLibrary or {}
	local library = {
		recipes = {}, appearance = {}, names = {}, descriptions = {},
		prices = {}, machinery = {}, retained = {},
	}
	local present = {}
	local freeCodes = {}
	for _, freeCodeTable in ipairs(self.itemRecipes or {}) do
		local freeCode = CreationCode(freeCodeTable)
		if freeCode ~= "" then freeCodes[freeCode] = true end
	end
	for _, codeTable in ipairs(story.itemRecipes or {}) do
		local copied = CopyPlainTable(codeTable)
		local code = CreationCode(copied)
		-- The engine cannot register two user products with the same signature. If
		-- Free Play already has that recipe, its local Creation remains authoritative.
		if code ~= "" and not present[code] and not freeCodes[code] then
			present[code] = true
			table.insert(library.recipes, copied)
			library.appearance[code] = CopyPlainTable((story.itemAppearance or {})[code])
			library.names[code] = (story.itemNames or {})[code]
			library.descriptions[code] = (story.itemDescriptions or {})[code]
			library.prices[code] = (story.itemPrices or {})[code]
			library.machinery[code] = (story.itemMachinery or {})[code]
		end
	end

	-- If Story later deletes a Creation that an existing Free Play factory or
	-- warehouse still references, retain a snapshot instead of breaking that save.
	for _, oldCodeTable in ipairs(old.recipes or {}) do
		local code = CreationCode(oldCodeTable)
		if code ~= "" and not present[code] and self:IsFreePlayProductInUse(code) then
			present[code] = true
			table.insert(library.recipes, CopyPlainTable(oldCodeTable))
			library.appearance[code] = CopyPlainTable((old.appearance or {})[code])
			library.names[code] = (old.names or {})[code]
			library.descriptions[code] = (old.descriptions or {})[code]
			library.prices[code] = (old.prices or {})[code]
			library.machinery[code] = (old.machinery or {})[code]
			library.retained[code] = true
		end
	end
	self.storyCreationLibrary = library
end

function Player:SyncFreePlayFromStory(story)
	if not self:IsFreePlay() or type(story) ~= "table" then return end

	-- The sidecar belongs to the local Story profile, not to the display name.
	-- This stable token survives profile renames and is never copied backwards.
	local storyProfileId = tostring(story.freePlayProfileId or "")
	if storyProfileId ~= "" then self.freePlayProfileId = storyProfileId end
	self:EnsureFreePlayProfileId()

	-- Story determines access and discovery. Free Play keeps ownership, money,
	-- inventory, factories, sales, time and its own Creation library independent.
	self.rank = tonumber(story.rank) or self.rank or 1
	self.difficulty = tonumber(story.difficulty) or self.difficulty or 1
	self.medals = CopyPlainTable(story.medals or self.medals or {})

	for code, known in pairs(story.knownRecipes or {}) do
		if known then self.knownRecipes[code] = true end
	end
	for categoryName, count in pairs(story.categoryCount or {}) do
		if categoryName ~= "user" then
			local existingCount = tonumber(self.categoryCount[categoryName]) or 0
			local storyCount = tonumber(count) or 0
			if storyCount > existingCount then self.categoryCount[categoryName] = storyCount end
		end
	end
	for name, available in pairs(story.ingredientsAvailable or {}) do
		if available then self.ingredientsAvailable[name] = true end
	end
	for name, available in pairs(story.labIngredients or {}) do
		if available then self.labIngredients[name] = true end
	end

	-- Port access is one-way Story -> Free Play. Ownership states such as
	-- "factory" or "shop" never cross the boundary. Free Play itself may own
	-- factories, but shops are always independent under the v4 sandbox rules.
	for name, port in pairs(_AllPorts or {}) do
		local storyState = (story.portsAvailable or {})[name]
		if storyState == "locked" or storyState == "hidden" or storyState == nil then
			self.portsAvailable[name] = storyState or (port.hidden and "hidden" or "locked")
		else
			local freeState = self.portsAvailable[name]
			if freeState == "shop" then
				-- Repair older sidecars that ever recorded shop ownership.
				self.portsAvailable[name] = self.portsVisited[name] and "open" or "new"
			elseif freeState ~= "factory" and freeState ~= "factory_stall" and freeState ~= "open" then
				self.portsAvailable[name] = "new"
			end
		end
	end
	-- Zurich is the universal starting base in DBD Free Play.
	self.portsAvailable.zurich = self.portsAvailable.zurich or "new"

	-- Feature unlocks are inherited, but purchases and plot variables are not.
	for name, enabled in pairs(story.buildingsEnabled or {}) do
		if enabled then self.buildingsEnabled[name] = true end
	end
	self.questVariables.ownphone = ((story.questVariables or {}).ownphone == 1) and 1 or self.questVariables.ownphone
	self.questVariables.ownplane = ((story.questVariables or {}).ownplane == 1) and 1 or self.questVariables.ownplane

	-- Catalogue knowledge is useful context, not Story progression, so merge it
	-- one-way while keeping discoveries made independently in Free Play.
	local storyCatalogue = story.catalogue or {}
	self.catalogue = self.catalogue or {}
	for _, field in ipairs({"unlockedHistory","unlockedCharacters","unlockedIngredients","charactersMet","unlockedPorts","discoveredBuildings","discoveredIngredientLocations","discoveredIngredientSeasons"}) do
		self.catalogue[field] = self.catalogue[field] or {}
		for key, value in pairs(storyCatalogue[field] or {}) do
			if type(value) == "table" then
				self.catalogue[field][key] = self.catalogue[field][key] or {}
				for k2, v2 in pairs(value) do self.catalogue[field][key][k2] = CopyPlainTable(v2) end
			elseif value then
				self.catalogue[field][key] = value
			end
		end
	end

	self:SyncStoryCreationLibrary(story)
	self.options = self.options or {}
	local storyOptions = story.options or {}
	self.options.language = storyOptions.language or self.options.language
	self.options.showCompletedQuests = storyOptions.showCompletedQuests
	self.options.tut_stall = storyOptions.tut_stall
	self.options.noQuests = true
	-- Normal Story quests cannot become eligible in Free Play. Dynamic Special
	-- Orders are separate DeliveryQuest objects and are allowed to persist.
	self.questPrimary = nil
	-- Story synchronization may run every time Free Play is loaded. Never roll a
	-- newer Free Play migration marker backwards when syncing inherited progress.
	if (tonumber(self.freePlayVersion) or 0) < 2 then self.freePlayVersion = 2 end

	local unlockedPorts = 0
	for _, state in pairs(self.portsAvailable or {}) do
		if state ~= "locked" and state ~= "hidden" then unlockedPorts = unlockedPorts + 1 end
	end
	local storyCreations = table.getn((self.storyCreationLibrary or {}).recipes or {})
	DebugOut("FREEPLAY", string.format(
		"Story synchronization complete: Rank %d, %d accessible port(s), %d Story Creation(s).",
		tonumber(self.rank) or 1, unlockedPorts, storyCreations))
end

function Player:RebuildCreationProducts()
	local category = _AllCategories["user"]
	if not category then return end
	for _, prod in ipairs(category.products or {}) do
		if prod and prod.code then _AllProducts[prod.code] = nil end
	end
	category:Clear()
	self.categoryCount["user"] = 0

	if self:IsFreePlay() then
		for _, codeTable in ipairs((self.storyCreationLibrary or {}).recipes or {}) do
			local code = CreationCode(codeTable)
			self.itemAppearance[code] = (self.storyCreationLibrary.appearance or {})[code] or self.itemAppearance[code]
			self.itemNames[code] = (self.storyCreationLibrary.names or {})[code] or self.itemNames[code]
			self.itemDescriptions[code] = (self.storyCreationLibrary.descriptions or {})[code] or self.itemDescriptions[code]
			self.itemPrices[code] = self.itemPrices[code] or (self.storyCreationLibrary.prices or {})[code]
			self.itemMachinery[code] = (self.storyCreationLibrary.machinery or {})[code] or self.itemMachinery[code]
			local prod = BuildCustomProduct(codeTable, self.itemAppearance[code], "story")
			if prod then prod.creationLibrary = "story" end
		end
	end
	for _, codeTable in ipairs(self.itemRecipes or {}) do
		local prod = BuildCustomProduct(codeTable, nil, self:IsFreePlay() and "free" or "story")
		if prod then prod.creationLibrary = self:IsFreePlay() and "free" or "story" end
	end
	if self:IsFreePlay() then self.questVariables.ugr_slots = 999999
	else self.questVariables.ugr_slots = self.customSlots - (self.categoryCount.user or 0) end
end

local function GetFreePlayStartingMoney(difficulty)
	local d = tonumber(difficulty) or 1
	if d >= 3 then return 30000 end
	if d == 2 then return 25000 end
	return 20000
end

local function EnsureFreePlayStarterRecycler()
	if not zur_factory or not zur_factory:IsOwned() then return false end
	local barCategory = _AllCategories and _AllCategories["bar"]
	if not barCategory then
		DebugOut("WARNING", "Could not install the Free Play starter recycler: bar category is unavailable.")
		return false
	end
	if not zur_factory:HasPowerup(barCategory, "recycler") then
		zur_factory:EnablePowerup(barCategory, "recycler")
		return true
	end
	return false
end

-- Free Play never owns shops. This repair is intentionally idempotent so it can
-- protect old older sidecars as well as any future accidental write.
function Player:NormalizeFreePlayShopOwnership()
	if not self:IsFreePlay() then return false end

	local changed = false
	self.buildingsOwned = self.buildingsOwned or {}
	for buildingName, _ in pairs(self.buildingsOwned) do
		local building = _AllBuildings and _AllBuildings[buildingName]
		if building and building.type == "shop" then
			self.buildingsOwned[buildingName] = nil
			changed = true
			DebugOut("FREEPLAY", string.format("Removed stale Free Play shop ownership: %s", buildingName))
		end
	end

	if (tonumber(self.shopsOwned) or 0) ~= 0 then changed = true end
	self.shopsOwned = 0

	for portName, state in pairs(self.portsAvailable or {}) do
		if state == "shop" then
			self.portsAvailable[portName] = (self.portsVisited and self.portsVisited[portName]) and "open" or "new"
			changed = true
		end
	end

	return changed
end

function Player:MigrateFreePlayV3StarterPackage()
	if not self:IsFreePlay() then return false end
	local version = tonumber(self.freePlayVersion) or 0
	if version >= 3 then return false end

	-- Every pre-v3 Free Play sidecar started from the old fixed $20,000 baseline.
	-- Apply only the missing difficulty delta directly to cash so this migration
	-- does not count as revenue, income or Company Score earnings.
	local intendedStart = GetFreePlayStartingMoney(self.difficulty)
	local bonus = intendedStart - 20000
	if bonus > 0 then
		self.money = (tonumber(self.money) or 0) + bonus
	end

	local recyclerInstalled = EnsureFreePlayStarterRecycler()
	self.freePlayVersion = 3
	DebugOut("FREEPLAY", string.format(
		"Free Play v3 starter migration applied: difficulty %d, cash correction %s, Zurich bar recycler %s.",
		tonumber(self.difficulty) or 1, Dollars(bonus), recyclerInstalled and "installed" or "already present"))
	return true
end

function Player:MigrateFreePlayV4ShopNetwork()
	if not self:IsFreePlay() then return false end
	local version = tonumber(self.freePlayVersion) or 0
	if version >= 4 then
		-- Still enforce the invariant in case an older build or script wrote
		-- ownership after migration.
		return self:NormalizeFreePlayShopOwnership()
	end

	local repairedOwnership = self:NormalizeFreePlayShopOwnership()
	self.shopOrderData = self.shopOrderData or {}
	self.freePlayVersion = 4
	DebugOut("FREEPLAY", string.format(
		"Free Play v4 shop-network migration applied: independent shops enabled, stale ownership %s.",
		repairedOwnership and "removed" or "not present"))
	return true
end

function Player:CreateNewFreePlay(story)
	DebugOut("FREEPLAY", "No Free Play sidecar exists yet. Creating a new independent company.")
	self:Reset()
	self:SetGameMode("free")
	self.freePlayProfileId = tostring((story or {}).freePlayProfileId or self.freePlayProfileId or "")
	self:EnsureFreePlayProfileId()
	self.options.noQuests = true
	self:SetPort("zurich")
	self:SyncFreePlayFromStory(story)

	-- Free Play inherits Story difficulty, then receives the intended starter
	-- bankroll: Easy $20,000, Medium $25,000, Hard $30,000.
	self.money = GetFreePlayStartingMoney(self.difficulty)

	-- SyncFreePlayFromStory mirrors Story Creation definitions and recipe knowledge,
	-- but Player:Reset() has already cleared the live user Product registry. Rebuild
	-- those products now so first-session systems (including weekly Tips) can safely
	-- resolve every known custom recipe through _AllProducts.
	self:RebuildCreationProducts()

	-- Free Play shops are independent clients rather than player property. Keep
	-- ownership at zero even if future Story synchronization data changes shape.
	self:NormalizeFreePlayShopOwnership()

	-- The predecessors always provided one starter factory. Reforged follows the
	-- same rule: Zurich is owned; every later factory must be purchased.
	if zur_factory and not zur_factory:IsOwned() then zur_factory:MarkOwned() end

	-- The Zurich starter factory includes the bar recycler immediately. This is a
	-- starter perk only; recyclers for other machinery/factories remain purchases.
	EnsureFreePlayStarterRecycler()
	self.freePlayVersion = 4

	-- Re-roll the living world only after Story port access has been synchronized.
	if CharacterMobility then
		self.characterLocations = {}
		self.characterLocks = {}
		self.questLocations = {}
		self.characterMobilityVersion = 0
		CharacterMobility:Initialize(self, false)
	end
end

local function LoadNativeStoryTable()
	SetCurrentGameMode(0)
	local saveString = LoadGameString()
	return DecodeSaveString(saveString)
end

-- Permanently replaces the current Free Play sidecar with a fresh company while
-- preserving the parent Story profile and all one-way Story unlocks.
function Player:RestartFreePlay()
	if not self:IsFreePlay() then
		DebugOut("WARNING", "Free Play restart ignored because the active campaign is not Free Play.")
		return false
	end

	local storyTable = LoadNativeStoryTable()
	if type(storyTable) ~= "table" then
		-- LoadNativeStoryTable temporarily selects native mode 0. Restore the
		-- Free Play runtime if the Story payload unexpectedly cannot be read.
		self:SetGameMode("free")
		DebugOut("ERROR", "Free Play restart aborted: Story Mode save could not be loaded.")
		return false
	end

	DebugOut("FREEPLAY", string.format(
		"Restarting Free Play for profile %s from Week 1.",
		tostring(self.name or GetCurrentUserName() or "N/A")))

	-- CreateNewFreePlay performs the full clean initialization: Story unlock sync,
	-- difficulty-scaled starter cash, Zurich ownership, the Bar recycler, Creation
	-- reconstruction and a fresh living-world roll. Save immediately so the old
	-- sidecar is atomically replaced before the player resumes.
	self:CreateNewFreePlay(storyTable)
	self:SaveGame()
	return true
end

local function RepairAlpha12StoryContamination(story)
	if type(story) ~= "table" or story.mode ~= "free" then return false end
	DebugOut("FREEPLAY", "Detected a pre-release Free Play state in the native Story slot; normalizing Story-only fields.")
	story.mode = "story"
	story.freePlayVersion = 0
	story.options = story.options or {}
	story.options.noQuests = nil

	-- Pre-release Free Play builds could mirror Story Creations into itemRecipes before writing the
	-- same native slot. The read-only Story library is the cleanest surviving
	-- snapshot of the pre-Free-Play Creation list, so restore that list when present.
	local library = story.storyCreationLibrary
	if type(library) == "table" and type(library.recipes) == "table" then
		-- Even an empty Story library is authoritative: pre-release Free Play
		-- creations must not leak back into Story Mode.
		story.itemRecipes = CopyPlainTable(library.recipes)
	end
	return true
end

local function LoadFreePlaySidecarTable(profileId)
	profileId = tostring(profileId or "")
	if profileId == "" then return nil, nil end
	local fileName = Player:GetFreePlaySaveFileName(profileId)
	local saveString = ReadFromFile(fileName)
	local value = DecodeSaveString(saveString)
	if type(value) ~= "table" then
		DebugOut("FREEPLAY", "No Free Play sidecar found at " .. fileName .. ".")
		return nil, fileName
	end
	if value.mode ~= "free" then
		DebugOut("WARNING", "Ignoring Free Play sidecar with invalid mode marker: " .. fileName)
		return nil, fileName
	end
	DebugOut("FREEPLAY", string.format(
		"Loaded Free Play sidecar '%s' (week %d, money %s).",
		fileName, tonumber(value.time) or 1, Dollars(tonumber(value.money) or 0)))
	return value, fileName
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
	-- Developer mode is a campaign-level integrity boundary, not merely a
	-- submission-time check. Persist the taint before serializing the save.
	self:SyncIntegrityWithRuntime()

	-- Keep score history current even if the player has not opened High Scores.
	HighScoreModel:EnsureStats(self, self.stats, false)
	HighScoreModel:UpdatePersonalBest(self, HighScoreModel:BuildSnapshot(self))

	DebugOut("SAVE", "Constructing save game data string.")
	local saveStringTable = { "return {", }
	AppendTableToString(Player, saveStringTable)

	-- Build specialized save tables for active delivery quests
	table.insert(saveStringTable, "deliveries={")
	for name,_ in pairs(self.questsActive) do
		local q = _AllQuests[name]
		if q and q.GetSaveTable then
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
		self:SetGameMode(self.mode or "story")
		-- Persist a stable sidecar binding in Story before serializing either mode.
		self:EnsureFreePlayProfileId()
		local saveString = Player:BuildSaveGameString()
		if self:IsFreePlay() then
			local fileName = self:GetFreePlaySaveFileName()
			local ok = WriteToFile(fileName, saveString)
			if ok == false then
				DebugOut("ERROR", "Free Play sidecar save failed: " .. fileName)
			else
				DebugOut("SAVE", string.format("Free Play sidecar saved for %s: %s", tostring(self.name or "N/A"), fileName))
			end
		else
			SetCurrentGameMode(0)
			SaveGameString(saveString)
			DebugOut("SAVE", string.format("Story game saved for player %s", tostring(self.name or "N/A")))
		end
	end
	self.lastSave = CurrentTime()
end

function Player:LoadGame(mode)
	mode = (mode == "free") and "free" or "story"
	local storyTable = LoadNativeStoryTable()
	local repairedAlpha12Story = false

	if type(storyTable) == "table" then
		repairedAlpha12Story = RepairAlpha12StoryContamination(storyTable)
	end

	if mode == "free" then
		-- Free Play is deliberately unavailable until this profile has a Story save,
		-- matching Chocolatier 2's progression-authority model.
		if type(storyTable) ~= "table" then
			SetCurrentGameMode(0)
			DebugOut("FREEPLAY", "Free Play load rejected: Story Mode save does not exist.")
			return false
		end

		-- Free Play no longer trusts DBD's native mode-1 storage. Real executable
		-- testing showed LoadGameString() returned the Story payload in both modes.
		local profileId = tostring(storyTable.freePlayProfileId or self.freePlayProfileId or "")
		if profileId == "" then
			self.freePlayProfileId = ""
			profileId = self:EnsureFreePlayProfileId()
			storyTable.freePlayProfileId = profileId
		end

		local freeTable = LoadFreePlaySidecarTable(profileId)
		if type(freeTable) == "table" then
			freeTable.freePlayProfileId = profileId
			Player:Reset(freeTable)
			Player:SetGameMode("free")
			Player:SyncFreePlayFromStory(storyTable)
			Player:RebuildCreationProducts()
			local freePlayMigrated = false
			if Player:MigrateFreePlayV3StarterPackage() then freePlayMigrated = true end
			if Player:MigrateFreePlayV4ShopNetwork() then freePlayMigrated = true end
			if freePlayMigrated then
				-- Persist immediately so one-time migration repairs cannot be replayed
				-- after a crash before the next normal save.
				Player:SaveGame()
			end
		else
			Player:CreateNewFreePlay(storyTable)
			Player:SaveGame()
		end
		DebugOut("FREEPLAY", string.format(
			"Free Play ready: week %d, money %s, rank %d, sidecar isolation active.",
			tonumber(Player.time) or 1, Dollars(tonumber(Player.money) or 0), tonumber(Player.rank) or 1))
	else
		SetCurrentGameMode(0)
		if type(storyTable) == "table" then
			Player:Reset(storyTable)
			Player:SetGameMode("story")
			Player.options = Player.options or {}
			Player.options.noQuests = nil
			Player.questVariables = Player.questVariables or {}
			Player.questVariables.ugr_slots = (Player.customSlots or 0) - (Player.categoryCount.user or 0)
			if repairedAlpha12Story then
				DebugOut("FREEPLAY", "Persisting repaired Story slot after pre-release Free Play contamination cleanup.")
				Player:SaveGame()
			end
			DebugOut("LOAD", string.format(
				"Story Mode ready: week %d, money %s, rank %d.",
				tonumber(Player.time) or 1, Dollars(tonumber(Player.money) or 0), tonumber(Player.rank) or 1))
		else
			DebugOut("LOAD", "No Story Mode save data found in default slot.")
			return false
		end
	end

	local name = GetCurrentUserName()
	if name then
		Player.name = name
		Player.stringTable.player = Player.name
	end
	UpdateLedger("newplayer")
	self.lastSave = CurrentTime()
	return true
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
	HighScoreModel:RecordRank(self, rank)
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

function Player:SetMoney(newMoney, silent, source)
	newMoney = tonumber(newMoney) or 0
	if newMoney < 0 then newMoney = 0 end
	local oldMoney = tonumber(self.money) or 0

	if oldMoney ~= newMoney then
		if not silent then
			if newMoney > oldMoney then SoundEvent("money_in_account") end
		end

		self.money = newMoney
		HighScoreModel:RecordMoney(self, newMoney - oldMoney, source)
		UpdateLedger("money")
	end
end

function Player:AddMoney(money, silent, source)
	money = tonumber(money) or 0
	local newMoney = (tonumber(self.money) or 0) + money
	if newMoney < 0 then newMoney = 0 end
	if not silent then DebugOut("PLAYER", string.format("Money changed by %s. New total: %s", Dollars(money), Dollars(newMoney))) end
	self:SetMoney(newMoney, silent, source or "other")
end

function Player:SubtractMoney(money, silent, source)
	money = tonumber(money) or 0
	local newMoney = (tonumber(self.money) or 0) - money
	if newMoney < 0 then newMoney = 0 end
	if not silent then DebugOut("PLAYER", string.format("Money changed by -%s. New total: %s", Dollars(money), Dollars(newMoney))) end
	self:SetMoney(newMoney, silent, source or "other")
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

		-- If dev mode is enabled, update the dev bar at top of screen
		if devUpdateQuest then
			devUpdateQuest()
		end
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
