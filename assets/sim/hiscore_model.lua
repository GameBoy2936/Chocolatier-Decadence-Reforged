--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	High Score Model / Campaign Statistics

	Reforged score architecture v1.
	This module deliberately separates:
	  * persistent campaign statistics,
	  * a point-in-time score snapshot,
	  * the public Company Score shown on leaderboards.
---------------------------------------------------------------------------]]

HighScoreModel = HighScoreModel or {}

HighScoreModel.statsVersion = 1
HighScoreModel.snapshotVersion = 1
HighScoreModel.scoreVersion = 1
HighScoreModel.maxPBHistory = 10

local function Int(value)
	value = tonumber(value) or 0
	-- Playground exposes Floor() as an engine-global helper; the standard
	-- Lua math table is not loaded by Chocolatier. Truncate toward zero.
	if value >= 0 then return Floor(value) end
	return -Floor(-value)
end

local function MaxValue(a, b)
	if a > b then return a end
	return b
end

local function Clamp(value, low, high)
	if value < low then return low end
	if value > high then return high end
	return value
end

local function CountKeys(t)
	local n = 0
	if type(t) ~= "table" then return 0 end
	for _, value in pairs(t) do
		if value then n = n + 1 end
	end
	return n
end

local function CountPositive(t)
	local n = 0
	if type(t) ~= "table" then return 0 end
	for _, value in pairs(t) do
		if tonumber(value) and tonumber(value) > 0 then n = n + 1 end
	end
	return n
end

local function SumPositive(t)
	local n = 0
	if type(t) ~= "table" then return 0 end
	for _, value in pairs(t) do
		value = tonumber(value) or 0
		if value > 0 then n = n + value end
	end
	return Int(n)
end

local function CopySnapshot(source)
	local copy = {}
	if type(source) ~= "table" then return copy end
	for k, v in pairs(source) do
		if type(v) ~= "table" then copy[k] = v end
	end
	return copy
end

function HighScoreModel:FormatNumber(value)
	local n = Int(value)
	local sign = ""
	if n < 0 then sign = "-"; n = -n end
	local s = tostring(n)
	local out = ""
	while string.len(s) > 3 do
		out = "," .. string.sub(s, -3) .. out
		s = string.sub(s, 1, string.len(s) - 3)
	end
	return sign .. s .. out
end

function HighScoreModel:DifficultyNameKey(difficulty)
	difficulty = tonumber(difficulty) or 1
	if difficulty == 3 then return "difficulty_hard" end
	if difficulty == 2 then return "difficulty_medium" end
	return "difficulty_easy"
end

function HighScoreModel:DifficultyMultiplier(difficulty)
	difficulty = tonumber(difficulty) or 1
	if difficulty == 3 then return 1.25 end
	if difficulty == 2 then return 1.10 end
	return 1.00
end

local function NewStats(player, restoring)
	local week = tonumber(player and player.time) or 1
	local money = tonumber(player and player.money) or 0
	local rank = tonumber(player and player.rank) or 1
	return {
		version = HighScoreModel.statsVersion,
		trackingStartedWeek = week,
		legacyBaseline = restoring and true or false,

		moneyIn = 0,
		moneyOut = 0,
		salesRevenue = 0,
		questRevenue = 0,
		specialOrderRevenue = 0,
		gamblingRevenue = 0,
		otherRevenue = 0,

		ingredientSpend = 0,
		travelSpend = 0,
		machinerySpend = 0,
		factorySpend = 0,
		gamblingSpend = 0,
		otherSpend = 0,

		highestCash = money,
		largestIncome = 0,
		largestExpense = 0,
		largestSale = 0,
		largestSpecialOrder = 0,

		salesTransactions = 0,
		ingredientUnitsBought = 0,
		travelTrips = 0,
		travelWeeks = 0,
		questsCompleted = 0,
		specialOrdersCompleted = 0,
		specialOrdersFailed = 0,

		rankReachedWeek = { [rank] = week },

		currentSnapshot = nil,
		personalBest = nil,
		pbHistory = {},
	}
end

function HighScoreModel:EnsureStats(player, savedStats, restoring)
	if not player then return nil end

	local defaults = NewStats(player, restoring)
	local source = type(savedStats) == "table" and savedStats or nil
	local stats = {}

	for key, value in pairs(defaults) do
		if source and source[key] ~= nil then
			stats[key] = source[key]
		else
			stats[key] = value
		end
	end

	-- Preserve future/additional fields rather than dropping them on load.
	if source then
		for key, value in pairs(source) do
			if stats[key] == nil then stats[key] = value end
		end
	end

	stats.version = self.statsVersion
	stats.trackingStartedWeek = tonumber(stats.trackingStartedWeek) or (player.time or 1)
	stats.highestCash = MaxValue(tonumber(stats.highestCash) or 0, tonumber(player.money) or 0)
	stats.rankReachedWeek = type(stats.rankReachedWeek) == "table" and stats.rankReachedWeek or {}
	stats.pbHistory = type(stats.pbHistory) == "table" and stats.pbHistory or {}

	player.stats = stats
	return stats
end

function HighScoreModel:RecordMoney(player, delta, source)
	if not player or not player.stats then return end
	local stats = player.stats
	delta = tonumber(delta) or 0
	source = source or "other"

	if delta > 0 then
		stats.moneyIn = (stats.moneyIn or 0) + delta
		stats.largestIncome = MaxValue(stats.largestIncome or 0, delta)

		if source == "product_sale" then
			stats.salesRevenue = (stats.salesRevenue or 0) + delta
		elseif source == "quest_reward" then
			stats.questRevenue = (stats.questRevenue or 0) + delta
		elseif source == "special_order" then
			stats.specialOrderRevenue = (stats.specialOrderRevenue or 0) + delta
			stats.largestSpecialOrder = MaxValue(stats.largestSpecialOrder or 0, delta)
		elseif source == "gambling" then
			stats.gamblingRevenue = (stats.gamblingRevenue or 0) + delta
		else
			stats.otherRevenue = (stats.otherRevenue or 0) + delta
		end
	elseif delta < 0 then
		local spent = -delta
		stats.moneyOut = (stats.moneyOut or 0) + spent
		stats.largestExpense = MaxValue(stats.largestExpense or 0, spent)

		if source == "ingredient_purchase" then
			stats.ingredientSpend = (stats.ingredientSpend or 0) + spent
		elseif source == "travel" then
			stats.travelSpend = (stats.travelSpend or 0) + spent
		elseif source == "machinery" or source == "recycler" then
			stats.machinerySpend = (stats.machinerySpend or 0) + spent
		elseif source == "factory_purchase" then
			stats.factorySpend = (stats.factorySpend or 0) + spent
		elseif source == "gambling" then
			stats.gamblingSpend = (stats.gamblingSpend or 0) + spent
		else
			stats.otherSpend = (stats.otherSpend or 0) + spent
		end
	end

	stats.highestCash = MaxValue(stats.highestCash or 0, tonumber(player.money) or 0)
end

function HighScoreModel:RecordSale(player, count, total)
	if not player or not player.stats then return end
	count = tonumber(count) or 0
	total = tonumber(total) or 0
	player.stats.salesTransactions = (player.stats.salesTransactions or 0) + 1
	if total > (player.stats.largestSale or 0) then player.stats.largestSale = total end
end

function HighScoreModel:RecordIngredientPurchase(player, count)
	if not player or not player.stats then return end
	count = tonumber(count) or 0
	if count > 0 then
		player.stats.ingredientUnitsBought = (player.stats.ingredientUnitsBought or 0) + count
	end
end

function HighScoreModel:RecordTravel(player, weeks)
	if not player or not player.stats then return end
	player.stats.travelTrips = (player.stats.travelTrips or 0) + 1
	player.stats.travelWeeks = (player.stats.travelWeeks or 0) + MaxValue(0, tonumber(weeks) or 0)
end

function HighScoreModel:RecordRank(player, rank)
	if not player or not player.stats then return end
	rank = tonumber(rank) or 1
	player.stats.rankReachedWeek = player.stats.rankReachedWeek or {}
	if player.stats.rankReachedWeek[rank] == nil then
		player.stats.rankReachedWeek[rank] = tonumber(player.time) or 1
	end
end

function HighScoreModel:RecordQuestCompletion(player, quest)
	if not player or not player.stats or not quest then return end
	if quest.IsReal and quest:IsReal() then
		player.stats.questsCompleted = (player.stats.questsCompleted or 0) + 1
	end
	if quest.delivery then
		player.stats.specialOrdersCompleted = (player.stats.specialOrdersCompleted or 0) + 1
		if tonumber(quest.price) and tonumber(quest.price) > (player.stats.largestSpecialOrder or 0) then
			player.stats.largestSpecialOrder = tonumber(quest.price)
		end
	end
end

function HighScoreModel:RecordQuestFailure(player, quest)
	if not player or not player.stats or not quest then return end
	if quest.delivery then
		player.stats.specialOrdersFailed = (player.stats.specialOrdersFailed or 0) + 1
	end
end

function HighScoreModel:IngredientInventoryValue(player)
	local value = 0
	if not player or type(player.ingredients) ~= "table" then return 0 end
	for name, count in pairs(player.ingredients) do
		local ing = _AllIngredients and _AllIngredients[name]
		count = tonumber(count) or 0
		if ing and count > 0 then
			local low = tonumber(ing.price_low) or 0
			local high = tonumber(ing.price_high) or low
			value = value + count * ((low + high) / 2)
		end
	end
	return Int(value)
end

function HighScoreModel:ProductInventoryValue(player)
	local value = 0
	if not player or type(player.products) ~= "table" then return 0 end
	for code, count in pairs(player.products) do
		local prod = _AllProducts and _AllProducts[code]
		count = tonumber(count) or 0
		if prod and count > 0 then
			-- Value finished stock at manufacturing cost, not its current local
			-- selling price. This keeps Company Value stable when the player travels.
			local low = tonumber(prod.cost_low) or 0
			local high = tonumber(prod.cost_high) or low
			value = value + count * ((low + high) / 2)
		end
	end
	return Int(value)
end

function HighScoreModel:MachineryValue(player)
	local value = 0
	if not player or type(player.factories) ~= "table" then return 0 end
	for _, factoryData in pairs(player.factories) do
		if type(factoryData) == "table" then
			for categoryName, category in pairs(_AllCategories or {}) do
				if factoryData[categoryName] then
					value = value + (tonumber(category.machinecost) or 0)
				end
			end
		end
	end
	return Int(value)
end

function HighScoreModel:CountRecipesKnown(player)
	return CountKeys(player and player.knownRecipes)
end

function HighScoreModel:CountRecipesMade(player)
	return CountPositive(player and player.itemsMade)
end

function HighScoreModel:CountCustomRecipes(player)
	if not player or type(player.itemRecipes) ~= "table" then return 0 end
	return table.getn(player.itemRecipes)
end

function HighScoreModel:CountMedals(player)
	return CountKeys(player and player.medals)
end

function HighScoreModel:BuildSnapshot(player)
	if not player then return nil end
	if not player.stats then self:EnsureStats(player, nil, true) end

	local money = MaxValue(0, tonumber(player.money) or 0)
	local week = MaxValue(1, tonumber(player.time) or 1)
	local rank = Clamp(tonumber(player.rank) or 1, 1, 5)
	local difficulty = Clamp(tonumber(player.difficulty) or 1, 1, 3)

	local ingredientValue = self:IngredientInventoryValue(player)
	local productValue = self:ProductInventoryValue(player)
	local machineryValue = self:MachineryValue(player)
	local companyValue = Int(money + ingredientValue + productValue + machineryValue)

	local casesMade = SumPositive(player.itemsMade)
	local casesSold = SumPositive(player.itemsSold)
	local factories = MaxValue(0, tonumber(player.factoriesOwned) or 0)
	local shops = MaxValue(0, tonumber(player.shopsOwned) or 0)
	local ports = MaxValue(0, tonumber(player.portVisitCount) or CountKeys(player.portsVisited))
	local recipesKnown = self:CountRecipesKnown(player)
	local recipesMade = self:CountRecipesMade(player)
	local customRecipes = self:CountCustomRecipes(player)
	local medals = self:CountMedals(player)
	local earningsPace = Int(money / week)

	-- Score Formula v1 -------------------------------------------------------
	-- 1 point / $100 of durable company value.
	local valuePoints = Int(companyValue / 100)

	-- Production is deliberately worth less than a sale; unsold stock still
	-- reflects operational scale, while sold cases prove commercial success.
	local commercePoints = Int((casesMade * 0.5) + casesSold)

	-- Expansion rewards building an actual worldwide company rather than
	-- hoarding cash. These are fixed, documented progression values.
	local expansionPoints = Int((factories * 12000) + (shops * 8000) + (ports * 750))

	local campaignMode = (player.IsFreePlay and player:IsFreePlay()) and "free" or "story"
	local masteryPoints = 0
	local progressionPoints = 0
	local operationsPoints = 0

	if campaignMode == "free" then
		-- Free Play deliberately does not score inherited Story rank, medals or
		-- recipe unlocks. It rewards what this sandbox company actually does.
		-- Unlimited Creation slots are capped here so simply spamming recipes
		-- cannot create an unlimited leaderboard score.
		masteryPoints = Int((recipesMade * 500) + (Clamp(customRecipes, 0, 20) * 750))
		operationsPoints = Int((tonumber(player.stats.specialOrdersCompleted) or 0) * 2500)
	else
		-- Story Mode retains the established v1 formula byte-for-byte.
		masteryPoints = Int((recipesKnown * 150) + (recipesMade * 300) + (customRecipes * 1500) + (medals * 2500))
		progressionPoints = Int(rank * 4000)
	end

	-- Preserve the familiar old $/week idea as a capped bonus rather than the
	-- whole score. Long-running sandbox saves therefore stop decaying forever.
	local efficiencyPoints = Clamp(Int(earningsPace / 2), 0, 75000)

	local baseScore = valuePoints + commercePoints + expansionPoints + masteryPoints + progressionPoints + operationsPoints + efficiencyPoints
	local difficultyMultiplier = self:DifficultyMultiplier(difficulty)
	local multiplierPercent = 100
	if difficulty == 2 then multiplierPercent = 110 end
	if difficulty == 3 then multiplierPercent = 125 end
	local companyScore = Int(((baseScore * multiplierPercent) + 50) / 100)

	return {
		snapshotVersion = self.snapshotVersion,
		scoreVersion = self.scoreVersion,
		campaignMode = campaignMode,
		companyScore = companyScore,
		baseScore = baseScore,
		difficultyMultiplier = difficultyMultiplier,

		valuePoints = valuePoints,
		commercePoints = commercePoints,
		expansionPoints = expansionPoints,
		masteryPoints = masteryPoints,
		progressionPoints = progressionPoints,
		operationsPoints = operationsPoints,
		efficiencyPoints = efficiencyPoints,

		companyValue = companyValue,
		money = Int(money),
		ingredientValue = ingredientValue,
		productValue = productValue,
		machineryValue = machineryValue,
		earningsPace = earningsPace,

		week = Int(week),
		rank = Int(rank),
		difficulty = Int(difficulty),
		casesMade = Int(casesMade),
		casesSold = Int(casesSold),
		factories = Int(factories),
		shops = Int(shops),
		portsVisited = Int(ports),
		recipesKnown = Int(recipesKnown),
		recipesMade = Int(recipesMade),
		customRecipes = Int(customRecipes),
		medals = Int(medals),

		highestCash = Int(player.stats.highestCash or money),
		lifetimeRevenue = Int(player.stats.moneyIn or 0),
		lifetimeSpend = Int(player.stats.moneyOut or 0),
		salesRevenue = Int(player.stats.salesRevenue or 0),
		specialOrderRevenue = Int(player.stats.specialOrderRevenue or 0),
		questsCompleted = Int(player.stats.questsCompleted or 0),
		specialOrdersCompleted = Int(player.stats.specialOrdersCompleted or 0),
		specialOrdersFailed = Int(player.stats.specialOrdersFailed or 0),
		largestSale = Int(player.stats.largestSale or 0),
		largestSpecialOrder = Int(player.stats.largestSpecialOrder or 0),
		salesTransactions = Int(player.stats.salesTransactions or 0),
		travelTrips = Int(player.stats.travelTrips or 0),
		ingredientSpend = Int(player.stats.ingredientSpend or 0),
		travelSpend = Int(player.stats.travelSpend or 0),
		machinerySpend = Int(player.stats.machinerySpend or 0),
		factorySpend = Int(player.stats.factorySpend or 0),
		trackingStartedWeek = Int(player.stats.trackingStartedWeek or week),
		statsLegacyBaseline = player.stats.legacyBaseline and true or false,
	}
end

function HighScoreModel:UpdatePersonalBest(player, snapshot)
	if not player then return false end
	if not player.stats then self:EnsureStats(player, nil, true) end
	snapshot = snapshot or self:BuildSnapshot(player)
	if not snapshot then return false end

	player.stats.currentSnapshot = CopySnapshot(snapshot)
	local previous = player.stats.personalBest
	local isPB = (type(previous) ~= "table") or ((snapshot.companyScore or 0) > (previous.companyScore or 0))

	if isPB then
		player.stats.personalBest = CopySnapshot(snapshot)
		local history = player.stats.pbHistory or {}
		table.insert(history, CopySnapshot(snapshot))
		while table.getn(history) > self.maxPBHistory do table.remove(history, 1) end
		player.stats.pbHistory = history
		DebugOut("PLAYER", string.format(
			"New Reforged Company Score personal best: %d at week %d.",
			snapshot.companyScore or 0, snapshot.week or 1
		))
	end

	return isPB
end

function HighScoreModel:BuildServerMetadata(player, snapshot, integrityStatus, integrityVersion)
	snapshot = snapshot or self:BuildSnapshot(player)
	if not snapshot then return "" end

	-- Keep this as one self-contained XML child in the legacy serverData blob.
	-- The compatibility server stores the fields in normal SQLite columns/JSON;
	-- the original Playground client simply transports the node.
	return string.format(
		"<reforged integrity='%s' integrityVersion='%d' scoreVersion='%d' snapshotVersion='%d' campaignMode='%s' nationality='%s' legacyBaseline='%d' companyValue='%d' money='%d' week='%d' rank='%d' difficulty='%d' casesMade='%d' casesSold='%d' factories='%d' shops='%d' ports='%d' recipesKnown='%d' recipesMade='%d' customRecipes='%d' medals='%d' earningsPace='%d' highestCash='%d' lifetimeRevenue='%d' lifetimeSpend='%d' ingredientValue='%d' productValue='%d' machineryValue='%d' salesRevenue='%d' specialOrderRevenue='%d' questsCompleted='%d' specialOrdersCompleted='%d' specialOrdersFailed='%d' largestSale='%d' largestSpecialOrder='%d' salesTransactions='%d' travelTrips='%d' ingredientSpend='%d' travelSpend='%d' machinerySpend='%d' factorySpend='%d' trackingWeek='%d' />",
		tostring(integrityStatus or "legacy_unverified"),
		tonumber(integrityVersion) or 0,
		snapshot.scoreVersion or 0,
		snapshot.snapshotVersion or 0,
		tostring(snapshot.campaignMode or ((player and player.IsFreePlay and player:IsFreePlay()) and "free" or "story")),
		tostring((player and player.highScoreNationality) or ""),
		snapshot.statsLegacyBaseline and 1 or 0,
		snapshot.companyValue or 0,
		snapshot.money or 0,
		snapshot.week or 1,
		snapshot.rank or 1,
		snapshot.difficulty or 1,
		snapshot.casesMade or 0,
		snapshot.casesSold or 0,
		snapshot.factories or 0,
		snapshot.shops or 0,
		snapshot.portsVisited or 0,
		snapshot.recipesKnown or 0,
		snapshot.recipesMade or 0,
		snapshot.customRecipes or 0,
		snapshot.medals or 0,
		snapshot.earningsPace or 0,
		snapshot.highestCash or 0,
		snapshot.lifetimeRevenue or 0,
		snapshot.lifetimeSpend or 0,
		snapshot.ingredientValue or 0,
		snapshot.productValue or 0,
		snapshot.machineryValue or 0,
		snapshot.salesRevenue or 0,
		snapshot.specialOrderRevenue or 0,
		snapshot.questsCompleted or 0,
		snapshot.specialOrdersCompleted or 0,
		snapshot.specialOrdersFailed or 0,
		snapshot.largestSale or 0,
		snapshot.largestSpecialOrder or 0,
		snapshot.salesTransactions or 0,
		snapshot.travelTrips or 0,
		snapshot.ingredientSpend or 0,
		snapshot.travelSpend or 0,
		snapshot.machinerySpend or 0,
		snapshot.factorySpend or 0,
		snapshot.trackingStartedWeek or snapshot.week or 1
	)
end
