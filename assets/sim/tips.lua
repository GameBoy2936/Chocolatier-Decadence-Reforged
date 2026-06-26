--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Tips & Events System)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script manages the entire system for dynamic economic events, referred
-- to internally as "Tips". It handles the creation, lifecycle, and application of
-- temporary price modifiers for ingredients and products throughout the game world,
-- as well as the dynamic dialogue system used by NPCs to announce these events.

Tips = {}

-------------------------------------------------------------------------------
-- System Configuration & Balances
-------------------------------------------------------------------------------

Tips.chancePerWeek = 25			-- Percentage chance (1-100) each week for a new random tip to generate.

-- Base ranges for randomized tip attributes
Tips.durationMin = 6			-- Minimum duration (in weeks) a tip lasts.
Tips.durationMax = 12			-- Maximum duration (in weeks) a tip lasts.

Tips.modUpMin = 1.25			-- Weakest "Price Up" multiplier (1.25x).
Tips.modUpMax = 1.80			-- Strongest "Price Up" multiplier (1.80x).

Tips.modDownMin = 0.35			-- Strongest "Price Down" multiplier (0.35x - Massive Crash).
Tips.modDownMax = 0.70			-- Weakest "Price Down" multiplier (0.70x - Mild Drop).

Tips.seasonalModifier = 1.25	-- Global price boost multiplier for all chocolate products during recognized holidays.

-- Identification of "evil" antagonist characters who will deliberately lie to the player
-- about market trends, flipping "good" tips into bad advice.
Tips.evilCharacters = {
	evil_kath = true,
	evil_tyso = true,
	evil_wolf = true,
	evil_bian = true,
}

-------------------------------------------------------------------------------
-- Antagonist & Trust Mechanics
-------------------------------------------------------------------------------

-- Evaluates if a character should lie to the player.
function Tips.IsCharacterEvil(charName)
	if not Tips.evilCharacters[charName] then return false end
	
	-- Character Arc Override: Katherine Carpo stops lying and becomes a reliable ally 
	-- once her bribery/defection quest is successfully completed.
	if charName == "evil_kath" and Player.questsComplete["rank4_kath_bribe"] then
		return false
	end
	
	return true
end

-------------------------------------------------------------------------------
-- Text Processing & Localization Helpers
-------------------------------------------------------------------------------

-- Replaces dynamic placeholder tokens (e.g., {item}, {port}) in string files 
-- with the actual localized names relevant to the active tip.
local function SubstituteTipParams(text, tip, character)
	if not text or not tip then return "" end

	local map = {}
	
	-- 1. Location Context
	local port = _AllPorts[tip.port]
	if port then
		map["port"] = GetString(port.name)
		map["region"] = port.region and GetString("region_" .. port.region) or ""
		map["country"] = port.country and GetString("country_" .. port.country) or ""
	end

	-- 2. Item/Product Context
	local itemName = GetString("all_ingredients")
	local item = _AllIngredients[tip.item] or _AllProducts[tip.item]
	local category = _AllCategories[tip.category]
	
	if item then 
		itemName = item:GetName()
	elseif category then 
		itemName = GetString(category.name) 
	end
	map["item"] = itemName

	-- 3. Source Context
	map["building"] = tip.building and GetString(tip.building) or ""
	map["character"] = tip.keeper and GetString(tip.keeper) or ""

	-- 4. Temporal Context
	local weeksRemaining = (tip.endTime or Player.time) - Player.time
	if weeksRemaining < 0 then weeksRemaining = 0 end
	map["weeks_left"] = tostring(weeksRemaining)

	-- 5. Perform the Regex Substitution
	local result = string.gsub(text, "{(.-)}", function(key)
		return map[key] or "{" .. key .. "}"
	end)
	
	-- 6. Legacy Player Name Injection
	if string.find(result, "<player>") then
		result = string.gsub(result, "<player>", Player.name or "")
	end

	return result
end

-- Safely finds a random variation of a string key from a numbered sequence 
-- (e.g., "ev_prod_priceup_1", "ev_prod_priceup_2").
local function GetRandomEventKey(baseKey)
	local count = 1
	-- Check existence against "#####" to avoid falling into the missing-string trap
	while GetString(baseKey .. "_" .. (count + 1)) ~= "#####" and GetString(baseKey .. "_" .. (count + 1)) ~= (baseKey .. "_" .. (count + 1)) do
		count = count + 1
	end
	
	-- If no _1 exists, assume it's just a single base key.
	if count == 1 and (GetString(baseKey .. "_1") == "#####" or GetString(baseKey .. "_1") == (baseKey .. "_1")) then 
		return baseKey 
	end
	
	local randomIndex = RandRange(1, count)
	return baseKey .. "_" .. randomIndex
end

-------------------------------------------------------------------------------
-- Tip Data Generation
-------------------------------------------------------------------------------

-- Helper to apply RNG variance to the strength and duration of a newly minted tip.
local function FinalizeTipVariance(tip)
	tip.endTime = Player.time + RandRange(Tips.durationMin, Tips.durationMax)
	
	if tip.type == "up" then
		tip.modifier = RandRange(Tips.modUpMin * 100, Tips.modUpMax * 100) / 100
	else
		tip.modifier = RandRange(Tips.modDownMin * 100, Tips.modDownMax * 100) / 100
	end
	
	return tip
end

-- Checks global holiday statuses and returns a seasonal tip if applicable.
function Tips.GenerateSeasonalTip()
	local active_key = nil
	
	-- We iterate all available ports to see if a holiday is triggering anywhere in the world.
	for portName, _ in pairs(_AllPorts) do
		local holiday = Player:GetActiveHolidayForPort(portName)
		if holiday then
			active_key = "ev_season_" .. holiday
			break
		end
	end

	if active_key then
		-- Prevent duplicating an already active seasonal tip
		for _, tip in ipairs(Player.activeTips) do
			if tip.seasonal_key == active_key then return nil end
		end
		
		DebugOut("TIP", string.format("Activating seasonal price event: %s", active_key))
		return {
			seasonal_key = active_key,
			key = GetRandomEventKey(active_key),
			endTime = Player.time + 4, -- Seasonal events have a fixed base duration extension
			type = "up"
		}
	end
	return nil
end

-- Generates a price fluctuation for a specific raw ingredient.
function Tips.GenerateIngredientTip()
	local markets = {}
	
	-- Find all accessible markets
	for _, port in pairs(_AllPorts) do 
		if port:IsAvailable() then 
			for _, building in ipairs(port.buildings) do 
				if building.type == "market" or building.type == "farm" then 
					table.insert(markets, building) 
				end 
			end 
		end 
	end
	
	if table.getn(markets) == 0 then return nil end
	local market = markets[RandRange(1, table.getn(markets))]
	
	-- Pick an ingredient actually sold at that market
	local availableIngredients = {}
	for _, ingredient in ipairs(market.inventory) do 
		if ingredient:IsAvailable() then table.insert(availableIngredients, ingredient) end 
	end
	
	if table.getn(availableIngredients) == 0 then return nil end
	local ingredient = availableIngredients[RandRange(1, table.getn(availableIngredients))]
	
	local tip = { 
		port = market.port.name, 
		building = market.name,
		keeper = market.name .. "keep",
		item = ingredient.name 
	}

	-- 50/50 Chance to go up or down
	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_ing_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_ing_pricedown")
	end
	
	local finalizedTip = FinalizeTipVariance(tip)
	DebugOut("TIP", string.format("Generated Ingredient Event: %s prices trending %s in %s (Mod: %.2f)", finalizedTip.item, finalizedTip.type, finalizedTip.port, finalizedTip.modifier))
	return finalizedTip
end

-- Calculates how "relevant" a product is to the player's current game state.
-- Used to weight the RNG so tips are actually useful/impactful to the player's active economy.
local function GetProductRelevanceScore(product)
	local score = 1 -- Base score to prevent zero-division errors
	
	-- 1. INVENTORY SCORE (Realized Profit)
	-- Weighted High (0.5): The value of finished goods sitting in the warehouse.
	local inventoryCount = product:GetInventory()
	if inventoryCount > 0 then
		local value = inventoryCount * product.price_high
		score = score + (value * 0.5)
	end

	-- 2. PRODUCTION SCORE (Active Income)
	-- Weighted Very High (2.0): If a factory is actively making this, a price shift is CRITICAL.
	for name, info in pairs(Player.factories) do
		if info.current == product.code and not info.stall then
			local weeklyValue = info.production * product.price_high
			score = score + (weeklyValue * 2)
		end
	end

	-- 3. POTENTIAL YIELD SCORE (Raw Potential)
	-- Weighted Moderate (0.2): Checks if we hold the raw ingredients to pivot and manufacture this.
	local potentialCount = 999999
	local hasRecipeData = false

	if product.counts then
		hasRecipeData = true
		for ingName, amountNeeded in pairs(product.counts) do
			local playerHas = Player.ingredients[ingName] or 0
			
			-- If we are missing ANY required ingredient, the potential yield is zero.
			if playerHas < amountNeeded then
				potentialCount = 0
				break
			end
			
			local canMake = Floor(playerHas / amountNeeded)
			if canMake < potentialCount then potentialCount = canMake end
		end
	else
		potentialCount = 0
	end

	if not hasRecipeData then potentialCount = 0 end

	if potentialCount > 0 then
		local potentialValue = potentialCount * product.price_high
		score = score + (potentialValue * 0.2)
	end

	-- 4. TIER BIAS
	-- Biases towards higher-tier items to make the late game feel more economically high-stakes.
	local catName = product.category.name
	if catName == "exotic" then score = score * 2.0
	elseif catName == "truffle" or catName == "blend" then score = score * 1.5
	elseif catName == "infusion" then score = score * 1.2
	end

	-- 5. RECENCY BIAS
	-- Products the player interacted with recently stay relevant in the market memory.
	local lastUsed = Player.useTimes[product.code] or 0
	if (Player.time - lastUsed) < 8 then
		score = score * 1.25
	elseif (Player.time - lastUsed) > 52 then
		-- Decay score for old, forgotten products.
		-- Note: A massive sudden influx of ingredients (Potential Yield) can easily override this decay.
		score = score * 0.1
	end

	return score
end

-- Generates a price fluctuation for a specific finished product, weighted by player relevance.
function Tips.GenerateProductTip()
	local candidates = {}
	local totalWeight = 0
	
	-- 1. Gather all potential products from known recipes and inventory
	for code, _ in pairs(Player.knownRecipes) do
		local prod = _AllProducts[code]
		
		-- Only consider products that shops actually buy (Sanity check)
		local categoryName = prod:GetMachinery().name
		local shopsExist = false
		for _, port in pairs(_AllPorts) do
			if port:IsAvailable() then
				for _, b in ipairs(port.buildings) do
					if b.type == "shop" and b.buys[categoryName] then
						shopsExist = true
						break
					end
				end
			end
			if shopsExist then break end
		end

		if shopsExist then
			local relevance = GetProductRelevanceScore(prod)
			
			-- Only add to the pool if it has some economic relevance, OR if it's a 
			-- custom User-Generated Recipe (which players always care about).
			if relevance > 100 or prod.category.name == "user" then
				if prod.category.name == "user" then relevance = relevance * 2.0 end
				
				table.insert(candidates, { product = prod, weight = relevance })
				totalWeight = totalWeight + relevance
			end
		end
	end

	if table.getn(candidates) == 0 then return nil end

	-- 2. Weighted Random Selection
	local selectedProduct = nil
	local roll = RandRange(1, Floor(totalWeight))
	local current = 0
	
	for _, cand in ipairs(candidates) do
		current = current + cand.weight
		if roll <= current then
			selectedProduct = cand.product
			break
		end
	end
	
	if not selectedProduct then selectedProduct = candidates[1].product end

	DebugOut("TIP", string.format("Selected product for tip target: %s (Relevance Score: %.2f)", selectedProduct:GetName(), GetProductRelevanceScore(selectedProduct)))

	-- 3. Find a suitable shop in the world that buys this category
	local categoryName = selectedProduct:GetMachinery().name
	local suitableShops = {}
	
	for _, port in pairs(_AllPorts) do 
		if port:IsAvailable() then 
			for _, building in ipairs(port.buildings) do 
				if building.type == "shop" and building.buys[categoryName] then 
					table.insert(suitableShops, building) 
				end 
			end 
		end 
	end
	
	if table.getn(suitableShops) == 0 then return nil end
	local shop = suitableShops[RandRange(1, table.getn(suitableShops))]

	-- 4. Construct the Tip
	local tip = { 
		port = shop.port.name, 
		building = shop.name,
		keeper = shop.name .. "keep",
		item = selectedProduct.code 
	}

	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_prod_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_prod_pricedown")
	end
	
	local finalizedTip = FinalizeTipVariance(tip)
	DebugOut("TIP", string.format("Generated Product Event: %s prices trending %s in %s (Mod: %.2f)", finalizedTip.item, finalizedTip.type, finalizedTip.port, finalizedTip.modifier))
	return finalizedTip
end

-- Generates a price fluctuation affecting an entire class of products (e.g., "All Truffles")
function Tips.GenerateCategoryTip()
	local categories = {}
	
	-- Only pick categories the player actually knows how to make
	for _, cat in ipairs(_CategoryOrder) do
		if cat.name ~= "user" and (Player.categoryCount[cat.name] or 0) > 0 then
			table.insert(categories, cat)
		end
	end
	
	if table.getn(categories) == 0 then return nil end
	local category = categories[RandRange(1, table.getn(categories))]
	
	-- Find a shop that sells this category
	local suitableShops = {}
	for _, port in pairs(_AllPorts) do
		if port:IsAvailable() then
			for _, building in ipairs(port.buildings) do
				if building.type == "shop" and building.buys[category.name] then
					table.insert(suitableShops, building)
				end
			end
		end
	end
	
	if table.getn(suitableShops) == 0 then return nil end
	local shop = suitableShops[RandRange(1, table.getn(suitableShops))]

	local tip = { 
		port = shop.port.name, 
		building = shop.name,
		keeper = shop.name .. "keep",
		category = category.name 
	}

	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_prod_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_prod_pricedown")
	end
	
	local finalizedTip = FinalizeTipVariance(tip)
	DebugOut("TIP", string.format("Generated Category Event: All %s prices trending %s in %s (Mod: %.2f)", finalizedTip.category, finalizedTip.type, finalizedTip.port, finalizedTip.modifier))
	return finalizedTip
end

-- Generates a massive global price shift affecting all raw ingredients in a single port.
function Tips.GeneratePortTip()
	local markets = {}
	for _, port in pairs(_AllPorts) do 
		if port:IsAvailable() then 
			for _, building in ipairs(port.buildings) do 
				if building.type == "market" or building.type == "farm" then 
					table.insert(markets, building) 
				end 
			end 
		end 
	end
	
	if table.getn(markets) == 0 then return nil end
	local market = markets[RandRange(1, table.getn(markets))]

	local tip = { 
		port = market.port.name, 
		building = market.name,
		keeper = market.name .. "keep",
		port_wide = true 
	}

	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_ing_all_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_ing_all_pricedown")
	end
	
	local finalizedTip = FinalizeTipVariance(tip)
	DebugOut("TIP", string.format("Generated Global Port Event: All ingredient prices trending %s in %s (Mod: %.2f)", finalizedTip.type, finalizedTip.port, finalizedTip.modifier))
	return finalizedTip
end

-------------------------------------------------------------------------------
-- Master Update & Modifier Application Logic
-------------------------------------------------------------------------------

-- Called weekly by the simulator to progress timers and roll for new events.
function Tips.Update()
	Player.activeTips = Player.activeTips or {}
	Player.pendingAnnouncements = Player.pendingAnnouncements or {}

	-- 1. Expire outdated tips
	local i = 1
	while i <= table.getn(Player.activeTips) do
		if Player.activeTips[i].endTime <= Player.time then
			local expiredTip = Player.activeTips[i]
			DebugOut("TIP", string.format("Tip duration expired. Removing from active economy: %s", expiredTip.key or expiredTip.seasonal_key))
			
			-- Scrub from the announcement queue if no one ever announced it
			for j, p_tip in ipairs(Player.pendingAnnouncements) do
				if p_tip == Player.activeTips[i] then
					table.remove(Player.pendingAnnouncements, j)
					break
				end
			end
			table.remove(Player.activeTips, i)
		else
			i = i + 1
		end
	end

	-- 2. Restrict tips during the Rank 1 Tutorial phase
	if Player.rank == 1 then return end

	-- 3. Check for Holiday Events
	Player:UpdateHolidays()
	local newTip = Tips.GenerateSeasonalTip()
	
	-- 4. Roll for standard randomized market events
	if not newTip and RandRange(1, 100) <= Tips.chancePerWeek then
		local roll = RandRange(1, 100)
		if roll <= 10 then 
			newTip = Tips.GeneratePortTip()
		elseif roll <= 20 then 
			newTip = Tips.GenerateCategoryTip()
		else
			if RandRange(1, 2) == 1 then 
				newTip = Tips.GenerateIngredientTip()
			else 
				newTip = Tips.GenerateProductTip() 
			end
		end
	end

	-- 5. Validation and Activation
	if newTip then
		local isDuplicate = false
		local hasConflict = false

		-- Validate the new tip against currently running events to prevent overlapping logic errors
		for _, existingTip in ipairs(Player.activeTips) do
			if (existingTip.port == newTip.port and (existingTip.item == newTip.item or existingTip.category == newTip.category or existingTip.port_wide == newTip.port_wide)) or (existingTip.seasonal_key and existingTip.seasonal_key == newTip.seasonal_key) then
				isDuplicate = true
				break
			end

			-- Prevent conflicting trends (e.g., Cocoa going UP and DOWN, or All Truffles UP but Honey Truffles DOWN)
			if existingTip.port == newTip.port and existingTip.type and newTip.type and existingTip.type ~= newTip.type then
				
				-- Direct Matches
				if existingTip.item and existingTip.item == newTip.item then hasConflict = true; break; end
				if existingTip.category and existingTip.category == newTip.category then hasConflict = true; break; end
				if existingTip.port_wide and newTip.port_wide then hasConflict = true; break; end
				
				-- Scope Overlaps (Item vs Category/Port-Wide)
				if newTip.item then
					local itemObj = _AllProducts[newTip.item] or _AllIngredients[newTip.item]
					if existingTip.port_wide and _AllIngredients[newTip.item] then hasConflict = true; break; end
					if existingTip.category and itemObj and itemObj.category and itemObj.category.name == existingTip.category then hasConflict = true; break; end
				end
				
				if existingTip.item then
					local itemObj = _AllProducts[existingTip.item] or _AllIngredients[existingTip.item]
					if newTip.port_wide and _AllIngredients[existingTip.item] then hasConflict = true; break; end
					if newTip.category and itemObj and itemObj.category and itemObj.category.name == newTip.category then hasConflict = true; break; end
				end
			end
		end

		if not isDuplicate and not hasConflict then
			table.insert(Player.activeTips, newTip)
			
			-- Seasonal tips are announced globally via UI, not via NPC dialogue, so we skip the pending queue.
			if not newTip.seasonal_key then
				table.insert(Player.pendingAnnouncements, newTip)
			end
		end
	end
end

-- Interrogates the active tips table and calculates the final cumulative price multiplier for an item.
function Tips.GetPriceModifier(itemCode, portName)
	local finalModifier = 1.0
	if not Player.activeTips then return finalModifier end
	
	local item = _AllIngredients[itemCode] or _AllProducts[itemCode]
	if not item then return finalModifier end

	-- 1. Apply Global Holiday modifiers (e.g., Christmas boosting all chocolate sales globally)
	local holiday = Player:GetActiveHolidayForPort(portName)
	if holiday and item.category and item.category.factory == "chocolate" then
		finalModifier = finalModifier * Tips.seasonalModifier
	end

	-- 2. Apply Specific Event Modifiers
	for _, tip in ipairs(Player.activeTips) do
		if tip.port == portName then
			local tipApplied = false
			
			if tip.item == itemCode then
				tipApplied = true
			elseif tip.category and item.category and item.category.name == tip.category then
				tipApplied = true
			elseif tip.port_wide and _AllIngredients[itemCode] then
				tipApplied = true
			end

			if tipApplied then
				finalModifier = finalModifier * (tip.modifier or 1.0)
			end
		end
	end
	
	return finalModifier
end

-------------------------------------------------------------------------------
-- Dialogue & Announcement Rendering
-------------------------------------------------------------------------------

-- Determines if the specified NPC is legally allowed to announce a specific tip to the player.
function Tips.CanCharacterAnnounceTip(character, building, tip)
	if not character or not building or not tip then return false end

	-- Deception Logic: Evil characters will flip the text of the tip to give the player terrible advice.
	if Tips.IsCharacterEvil(character.name) then
		-- Determine if this is a "helpful" tip (Prices rising on goods you sell, dropping on goods you buy)
		local isGoodTip = (tip.type == "up" and (tip.item and _AllProducts[tip.item] or tip.category)) or
						  (tip.type == "down" and (tip.item and _AllIngredients[tip.item] or tip.port_wide))
		
		if isGoodTip then
			tip.inverted = true
			DebugOut("TIP", string.format("DECEPTION: %s is deliberately lying about the market trend to trick the player.", character.name))
		end
	end

	-- Universal Exception: Local residents always know the gossip about their own home port.
	if building.port and tip.port == building.port.name then
		return true
	end

	-- Global Announcers: World travelers, factory chiefs, and antagonists can gossip about anywhere.
	local global_keywords = {"factorykeep", "announcer", "evil", "main", "trav", "bldg", "riverkeep"}
	for _, keyword in ipairs(global_keywords) do
		if string.find(character.name, keyword) then return true end
	end
	
	return false
end

-- Constructs the most specific dialogue string possible for an NPC to say.
-- The localization string tables are searched hierarchically, falling back to more generic lines
-- if a highly specific one (e.g., a specific character talking about a specific item in a specific port) doesn't exist.
function Tips.GetDynamicTipString(tip, character)
	if not tip then return "..." end
	
	if tip.seasonal_key then
		local rawSeasonal = GetString(tip.key)
		return SubstituteTipParams(rawSeasonal, tip, character)
	end

	local port = _AllPorts[tip.port]
	if not port then return "..." end

	-- Strip the trailing randomizer digit to find the true base key
	local baseEventKey = string.gsub(tip.key, "_%d+$", "")
	local keys_to_try = {}
	
	-- 1. SPECIFIC ITEM HIERARCHY
	if tip.item then
		if character then 
			-- Character + Item + Port (e.g., ev_prod_pricedown_wel_shopkeep_e04_wellington)
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.item .. "_" .. port.name)
			-- Character + Item (e.g., ev_prod_pricedown_wel_shopkeep_e04)
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.item)
		end
		-- Item + Port (e.g., ev_prod_pricedown_e04_wellington)
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.item .. "_" .. port.name)
		-- Item (e.g., ev_prod_pricedown_e04)
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.item)

	-- 2. CATEGORY HIERARCHY
	elseif tip.category then
		if character then 
			-- Character + Category + Port
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.category .. "_" .. port.name)
			-- Character + Category
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.category)
		end
		-- Category + Port
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.category .. "_" .. port.name)
		-- Category
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.category)
	end
	
	-- 3. GENERAL CONTEXT HIERARCHY (Location and Personality fallbacks)
	if character then
		-- Character + Port (e.g., ev_prod_pricedown_wel_shopkeep_wellington)
		table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. port.name)
		-- Character Base Identity (e.g., ev_prod_pricedown_wel_shopkeep)
		table.insert(keys_to_try, baseEventKey .. "_" .. character.name)
	end

	-- Port only (e.g., ev_prod_pricedown_wellington)
	table.insert(keys_to_try, baseEventKey .. "_" .. port.name)
	
	-- Global Generic Catch-all (e.g., ev_prod_pricedown)
	table.insert(keys_to_try, baseEventKey)

	-- Search the fallback list top-to-bottom for the best matching string key
	local finalKey = nil
	for _, key in ipairs(keys_to_try) do
		-- Safe check to see if the key exists in the localized table at all
		local text = GetString(key .. "_1")
		if text ~= "#####" and text ~= (key .. "_1") then
			
			-- Discover how many randomized variations of this specific string exist
			local count = 1
			while GetString(key .. "_" .. (count + 1)) ~= "#####" and GetString(key .. "_" .. (count + 1)) ~= (key .. "_" .. (count + 1)) do
				count = count + 1
			end
			
			finalKey = key .. "_" .. RandRange(1, count)
			break
		end
	end

	-- Retrieve the raw string from the table, utilizing the fundamental tip key if nothing else matched
	local rawText = GetString(finalKey or tip.key)
	
	-- Execute token substitution (e.g., replacing {item} with the true localized item name)
	return SubstituteTipParams(rawText, tip, character)
end