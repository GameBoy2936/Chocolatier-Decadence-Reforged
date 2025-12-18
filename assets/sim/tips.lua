--[[--------------------------------------------------------------------------
	Chocolatier Three: Price Fluctuation Event System (Tips)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane.
--]]--------------------------------------------------------------------------

Tips =
{
	chancePerWeek = 20,			-- Percentage chance of a new tip each week
	tipDuration = 8,			-- Duration of standard tips in weeks
	
	priceModifierUp = 1.5,		-- Price multiplier for "Up" events
	priceModifierDown = 0.5,	-- Price multiplier for "Down" events
	seasonalModifier = 1.25,	-- Global multiplier for seasonal events
	
	-- Characters who will invert tip information (lie) to the player
	evilCharacters = {
		evil_kath = true,
		evil_tyso = true,
		evil_wolf = true,
		evil_bian = true,
	},
}

------------------------------------------------------------------------------
-- Helpers

local function GetRandomEventKey(baseKey)
	local count = 1
	while GetString(baseKey .. "_" .. (count + 1)) ~= "#####" do
		count = count + 1
	end
	if count == 1 and GetString(baseKey .. "_1") == "#####" then return baseKey end
	
	local randomIndex = RandRange(1, count)
	return baseKey .. "_" .. randomIndex
end

-- Helper to check if an ingredient is sold at a market.
local function IsIngredientInMarket(market, ingredientName)
	if not market or not market.inventory then return false end
	for _, ing in ipairs(market.inventory) do
		if ing.name == ingredientName then
			return true
		end
	end
	return false
end

-- Helper to check if a product's recipe uses any ingredient from a given market.
local function DoesProductUseMarketIngredient(market, product)
	if not market or not product or not product.recipe then return false end
	for ingredientName, _ in pairs(product.counts) do
		if IsIngredientInMarket(market, ingredientName) then
			return true
		end
	end
	return false
end

------------------------------------------------------------------------------
-- Tip Generation

function Tips.GenerateSeasonalTip()
	if not Player.currentHolidays then return nil end
	
    -- Initialize history tracker if missing (safety check)
    Player.holidayAnnouncements = Player.holidayAnnouncements or {}

    -- Calculate current game year (Year 1, Year 2, etc.)
    local currentYear = Floor(Player.time / 52) + 1

	-- Iterate through active holidays in the Player state
	for holidayName, isActive in pairs(Player.currentHolidays) do
		if isActive then
            -- Check if we have already announced this holiday THIS YEAR
            local lastAnnouncedYear = Player.holidayAnnouncements[holidayName] or -1
            
            if lastAnnouncedYear ~= currentYear then
                -- 30% chance per week to announce the holiday news.
                -- This prevents it from always firing on the exact first hour of the holiday,
                -- but ensures it usually fires at least once during a multi-week holiday.
                if RandRange(1, 100) <= 30 then
                    local seasonal_key = "ev_season_" .. holidayName
                    
                    DebugOut("TIP", "Generating news announcement for holiday: " .. holidayName .. " (Year " .. currentYear .. ")")
                    
                    -- Mark as announced for this year so we don't repeat it
                    Player.holidayAnnouncements[holidayName] = currentYear

                    return {
                        seasonal_key = seasonal_key,
                        key = GetRandomEventKey(seasonal_key),
                        endTime = Player.time + 1, 
                        type = "up"
                    }
                end
            end
		end
	end

	return nil
end

function Tips.GenerateIngredientTip()
	-- 1. Find a valid market
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
	
	-- 2. Pick an ingredient sold there
	local availableIngredients = {}
	for _, ingredient in ipairs(market.inventory) do 
		if ingredient:IsAvailable() then 
			table.insert(availableIngredients, ingredient) 
		end 
	end
	
	if table.getn(availableIngredients) == 0 then return nil end
	local ingredient = availableIngredients[RandRange(1, table.getn(availableIngredients))]
	
	-- 3. Get keeper name for %4%
	local keeperName = nil
	local charList = market:GetCharacterList()
	if charList and charList[1] then keeperName = charList[1].name end

	local tip = { 
		port = market.port.name, 
		building = market.name,
		keeper = keeperName,
		item = ingredient.name, 
		endTime = Player.time + Tips.tipDuration 
	}
	
	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_ing_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_ing_pricedown")
	end
	
	DebugOut("TIP", "Generated Ingredient Tip: " .. tip.item .. " at " .. tip.building)
	return tip
end

function Tips.GenerateProductTip()
	-- 1. Find products the player has actually made
	local madeProducts = {}
	for code, _ in pairs(Player.itemsMade) do table.insert(madeProducts, _AllProducts[code]) end
	if table.getn(madeProducts) == 0 then return nil end
	
	local product = madeProducts[RandRange(1, table.getn(madeProducts))]
	local categoryName = product:GetMachinery().name
	
	-- 2. Find a shop that buys this category
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

	-- 3. Get keeper name for %4%
	local keeperName = nil
	local charList = shop:GetCharacterList()
	if charList and charList[1] then keeperName = charList[1].name end

	local tip = { 
		port = shop.port.name, 
		building = shop.name,
		keeper = keeperName,
		item = product.code, 
		endTime = Player.time + Tips.tipDuration 
	}
	
	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_prod_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_prod_pricedown")
	end
	
	DebugOut("TIP", "Generated Product Tip: " .. tip.item .. " at " .. tip.building)
	return tip
end

function Tips.GenerateCategoryTip()
	-- 1. Pick a category the player knows
	local categories = {}
	for _, cat in ipairs(_CategoryOrder) do
		if cat.name ~= "user" and (Player.categoryCount[cat.name] or 0) > 0 then
			table.insert(categories, cat)
		end
	end
	if table.getn(categories) == 0 then return nil end
	local category = categories[RandRange(1, table.getn(categories))]
	
	-- 2. Find a shop
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

	local keeperName = nil
	local charList = shop:GetCharacterList()
	if charList and charList[1] then keeperName = charList[1].name end

	local tip = { 
		port = shop.port.name, 
		building = shop.name,
		keeper = keeperName,
		category = category.name, 
		endTime = Player.time + Tips.tipDuration 
	}
	
	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_prod_priceup") -- Reusing generic keys
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_prod_pricedown")
	end
	
	DebugOut("TIP", "Generated Category Tip: " .. tip.category .. " at " .. tip.building)
	return tip
end

function Tips.GeneratePortTip()
	-- 1. Pick a random market
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

	local keeperName = nil
	local charList = market:GetCharacterList()
	if charList and charList[1] then keeperName = charList[1].name end

	local tip = { 
		port = market.port.name, 
		building = market.name,
		keeper = keeperName,
		port_wide = true, 
		endTime = Player.time + Tips.tipDuration 
	}
	
	if RandRange(1, 2) == 1 then
		tip.type = "up"
		tip.key = GetRandomEventKey("ev_ing_all_priceup")
	else
		tip.type = "down"
		tip.key = GetRandomEventKey("ev_ing_all_pricedown")
	end
	
	DebugOut("TIP", "Generated Port-Wide Tip: " .. tip.port)
	return tip
end

------------------------------------------------------------------------------
-- Main Update Loop

function Tips.Update()
	Player.activeTips = Player.activeTips or {}
	Player.pendingAnnouncements = Player.pendingAnnouncements or {}

	-- 1. Expire old tips
	local i = 1
	while i <= table.getn(Player.activeTips) do
		if Player.activeTips[i].endTime <= Player.time then
			local expiredTip = Player.activeTips[i]
			DebugOut("TIP", "Tip expired: " .. (expiredTip.key or expiredTip.seasonal_key))
			-- Remove from announcement queue if pending
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

	-- 2. No tips during tutorial
	if Player.rank == 1 then return end

	-- 3. Generate new tips
	-- We try to generate a seasonal tip first (News only).
	local newTip = Tips.GenerateSeasonalTip()
	
	-- If no seasonal tip generated (because it's not a holiday OR we already have one),
	-- roll for a standard economic tip.
	if not newTip and RandRange(1, 100) <= Tips.chancePerWeek then
		local roll = RandRange(1, 100)
		if roll <= 10 then newTip = Tips.GeneratePortTip()
		elseif roll <= 20 then newTip = Tips.GenerateCategoryTip()
		else
			if RandRange(1, 2) == 1 then newTip = Tips.GenerateIngredientTip()
			else newTip = Tips.GenerateProductTip() end
		end
	end

	-- 4. Validate and Activate
	if newTip then
		local isDuplicate = false
		local hasConflict = false

		for _, existingTip in ipairs(Player.activeTips) do
			if (existingTip.port == newTip.port and (existingTip.item == newTip.item or existingTip.category == newTip.category or existingTip.port_wide == newTip.port_wide)) or (existingTip.seasonal_key and existingTip.seasonal_key == newTip.seasonal_key) then
				isDuplicate = true
				break
			end

			-- Check for conflicting types (Up vs Down) on the same item/location
			if existingTip.port == newTip.port and existingTip.type and newTip.type and existingTip.type ~= newTip.type then
				if existingTip.item and existingTip.item == newTip.item then hasConflict = true; break; end
				if existingTip.category and existingTip.category == newTip.category then hasConflict = true; break; end
				if existingTip.port_wide and newTip.port_wide then hasConflict = true; break; end
				-- Conflict between port-wide and specific item
				if (existingTip.port_wide and newTip.item and _AllIngredients[newTip.item]) then hasConflict = true; break; end
				if (newTip.port_wide and existingTip.item and _AllIngredients[existingTip.item]) then hasConflict = true; break; end
			end
		end

		if not isDuplicate and not hasConflict then
			table.insert(Player.activeTips, newTip)
			if not newTip.seasonal_key then
				table.insert(Player.pendingAnnouncements, newTip)
			else
				-- Seasonal tips are also announced, just like normal tips.
				table.insert(Player.pendingAnnouncements, newTip)
			end
			
			-- Force immediate price update so the new tip takes effect this week
			if Player:GetPort() then
				Player:RecalculatePricesForCurrentPort()
				DebugOut("TIP", "Prices recalculated for current port due to new tip.")
			end
		end
	end
end

------------------------------------------------------------------------------
-- Price Modifiers

function Tips.GetPriceModifier(itemCode, portName)
    local finalModifier = 1.0
    local item = _AllIngredients[itemCode] or _AllProducts[itemCode]
    if not item then return finalModifier end

    local port = _AllPorts[portName]
    
    -- 1. Holiday Modifiers (from Player.lua)
    local holiday = Player:GetActiveHolidayForPort(portName)
    
    if holiday then
        -- NEGATIVE / DEFLATIONARY EVENTS
        if holiday == "resolutions" then
            -- People avoiding sweets
            if item.category and (item.category.factory == "chocolate" or item.category.name == "sugar") then 
                finalModifier = finalModifier * 0.8 
            end

        elseif holiday == "lent" then
            -- Giving up luxuries (Alcohol, Chocolate, Sweets)
            local luxury = { rum=true, whiskey=true, brandy=true, kahlua=true, amaretto=true, grand_marnier=true }
            if luxury[item.name] or (item.category and item.category.factory == "chocolate") then
                finalModifier = finalModifier * 0.85
            end

        elseif holiday == "ramadan" then
            if item.category and item.category.factory == "chocolate" then finalModifier = finalModifier * 0.8 end

        elseif holiday == "dog_days_n" or holiday == "dog_days_s" then
            -- Summer Heat Check
            -- We only apply this if the port matches the hemisphere of the heatwave
            local isHeatwave = false
            if holiday == "dog_days_n" and port.hemisphere == "north" then isHeatwave = true end
            if holiday == "dog_days_s" and port.hemisphere == "south" then isHeatwave = true end
            
            if isHeatwave then
                -- Chocolate melts/is heavy. Demand drops.
                if item.category and item.category.factory == "chocolate" then
                    finalModifier = finalModifier * 0.75
                end
                -- Fruit and Drinks are refreshing. Demand rises.
                if item.category and (item.category.name == "fruit" or item.category.name == "beverage") then
                    finalModifier = finalModifier * 1.15
                end
            end

        -- POSITIVE / INFLATIONARY EVENTS
        elseif holiday == "eid_ul_fitr" then
            if item.category and item.category.factory == "chocolate" then finalModifier = finalModifier * 1.5 end
        elseif holiday == "lunar_new_year" then
             if item.category == "fruit" or item.name == "strawberry" or item.name == "raspberry" or item.name == "cherry" then finalModifier = finalModifier * 1.4 end
        elseif holiday == "diwali" then
             if item.category == "sugar" or item.category == "milk" or item.category == "nut" then finalModifier = finalModifier * 1.4 end
        elseif holiday == "carnival" then
            local booze = { rum=true, whiskey=true, brandy=true, kahlua=true, amaretto=true, grand_marnier=true }
            if booze[item.name] then finalModifier = finalModifier * 1.6 end
        elseif holiday == "thanksgiving" then
            local bake = { pumpkin=true, pecan=true, cinnamon=true, nutmeg=true, clove=true, currant=true }
            if bake[item.name] then finalModifier = finalModifier * 1.5 end
        elseif holiday == "valentine" then
             if item.category and item.category.factory == "chocolate" then finalModifier = finalModifier * 1.3 end
        elseif holiday == "christmas" then
             if item.category and item.category.factory == "chocolate" then finalModifier = finalModifier * 1.4 end
        elseif holiday == "easter" then
             if item.category and item.category.factory == "chocolate" then finalModifier = finalModifier * 1.3 end
        end
    end

	-- 2. Active Tips
	-- We iterate active tips for random events (fire, strike, bumper crop).
	if Player.activeTips then
		for _, tip in ipairs(Player.activeTips) do
			-- Ignore seasonal tips here, they are handled by block #1 above.
			if not tip.seasonal_key then
				if tip.port == portName then
					local tipApplied = false
					if tip.item == itemCode then tipApplied = true
					elseif tip.category and item.category and item.category.name == tip.category then tipApplied = true
					elseif tip.port_wide and _AllIngredients[itemCode] then tipApplied = true
					end
		
					if tipApplied then
						local tipType = tip.type
						
						-- Deception logic: Check if the tip was inverted by a lying character
						if tip.inverted then
							if tipType == "up" then tipType = "down"
							elseif tipType == "down" then tipType = "up"
							end
						end
		
						if tipType == "up" then finalModifier = finalModifier * Tips.priceModifierUp
						elseif tipType == "down" then finalModifier = finalModifier * Tips.priceModifierDown
						end
					end
				end
			end
			
			-- Fallback for global seasonal tips that aren't caught by the culture system
			if tip.seasonal_key and item.category and item.category.factory == "chocolate" then
				finalModifier = finalModifier * Tips.seasonalModifier
			end
		end
	end
	
	return finalModifier
end

------------------------------------------------------------------------------
-- Character Announcement Logic

-- This function determines if a specific character in a specific building
-- is allowed to announce a given tip, making the world feel more logical.
function Tips.CanCharacterAnnounceTip(character, building, tip)
	if not character or not building or not tip then return false end

	-- Evil Character Deception
	if Tips.evilCharacters[character.name] then
		-- A "good" tip is one that benefits the player (product price up, ingredient price down).
		local isGoodTip = (tip.type == "up" and (tip.item and _AllProducts[tip.item] or tip.category)) or
						  (tip.type == "down" and (tip.item and _AllIngredients[tip.item] or tip.port_wide))
		
		if isGoodTip then
			tip.inverted = true
			DebugOut("TIP", "DECEPTION! " .. character.name .. " is inverting a good tip.")
		end
	end

	-- Universal Exception: Any character can announce a tip about their own port.
	if building.port and tip.port == building.port.name then
		return true
	end

	-- Rule 1: Excluded Buildings
	if building.type == "casino" or building.type == "kitchen" then
		return false
	end

	-- Rule 2: Market Keepers
	if building.type == "market" or building.type == "farm" then
		local isBasicMarket = true
		local basicCommodities = { sugar=true, milk=true, cacao=true }
		for _, ing in ipairs(building.inventory) do
			if not basicCommodities[ing.name] then
				isBasicMarket = false
				break
			end
		end
		if isBasicMarket and (tip.item and _AllProducts[tip.item] or tip.category) then
			return false -- Basic markets cannot give product or category tips.
		end

		if tip.item and _AllIngredients[tip.item] then
			return IsIngredientInMarket(building, tip.item)
		elseif tip.port_wide then
			return true
		elseif tip.item and _AllProducts[tip.item] then
			return DoesProductUseMarketIngredient(building, _AllProducts[tip.item])
		elseif tip.category then
			if building.type == "farm" then
				local sells_cacao_or_coffee = false
				for _, ing in ipairs(building.inventory) do
					if ing.category == "cacao" or ing.category == "coffee" then
						sells_cacao_or_coffee = true
						break
					end
				end
				if sells_cacao_or_coffee then return true end
			end
		end
	end

	-- Rule 3: Shop Keepers
	if building.type == "shop" then
		if tip.category then
			return building.buys[tip.category] or false
		end
		if tip.item and _AllProducts[tip.item] then
			local categoryName = _AllProducts[tip.item]:GetMachinery().name
			return building.buys[categoryName] or false
		end
	end

	-- Rule 4: Global Announcers (Travelers, Main Characters)
	local global_keywords = {"factorykeep", "bankkeep", "stationkeep", "barkeep", "portkeep", "hotelkeep", "announcer", "evil", "main"}
	for _, keyword in ipairs(global_keywords) do
		if string.find(character.name, keyword) then return true end
	end
	if string.sub(character.name, 1, 4) == "main" then return true end
	for _, travName in ipairs(_TravelCharacters) do if travName == character.name then return true end end
	for _, emptyName in ipairs(_EmptyCharacters) do if character.name == emptyName then return true end end
	
	return false
end

------------------------------------------------------------------------------
-- Dynamic String Generation

function Tips.GetDynamicTipString(tip, character)
	if not tip then return "An interesting rumor is going around..." end
	
	if tip.seasonal_key then
		return GetText(tip.key) 
	end

	local port = _AllPorts[tip.port]
	if not port then return "An interesting rumor is going around..." end

	-- 1. Determine Keys
	local finalKey = tip.key 
	local baseEventKey = string.gsub(tip.key, "_%d+$", "")
	local keys_to_try = {}
	
	-- Helper to add character-specific variations
	local function AddKeys(base)
		if character then
			table.insert(keys_to_try, base .. "_" .. character.name)
		end
		table.insert(keys_to_try, base)
	end
	
	-- Build key list based on specificity
	if tip.item then
		if character then
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.item .. "_" .. port.name)
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.item)
		end
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.item .. "_" .. port.name)
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.item)
	elseif tip.category then
		if character then
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.category .. "_" .. port.name)
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. tip.category)
		end
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.category .. "_" .. port.name)
		table.insert(keys_to_try, baseEventKey .. "_" .. tip.category)
	elseif tip.port_wide then
		if character then
			table.insert(keys_to_try, baseEventKey .. "_" .. character.name .. "_" .. port.name)
		end
		table.insert(keys_to_try, baseEventKey .. "_" .. port.name)
	end
	
	if character then
		table.insert(keys_to_try, baseEventKey .. "_" .. character.name)
	end

	-- 2. Select Key
	for _, key in ipairs(keys_to_try) do
		if GetString(key .. "_1") ~= "#####" then
			local count = 1
			while GetString(key .. "_" .. (count + 1)) ~= "#####" do
				count = count + 1
			end
			local randomIndex = RandRange(1, count)
			finalKey = key .. "_" .. randomIndex
			break
		end
	end

	-- 3. Gather Parameters
	local itemName = "all ingredients"
	local item = _AllIngredients[tip.item] or _AllProducts[tip.item]
	local category = _AllCategories[tip.category]
	
	if item then itemName = item:GetName()
	elseif category then itemName = GetString(category.name) end
	
	-- Resolve %3% (Building) and %4% (Keeper) and %5% (Region)
	local buildingName = ""
	local keeperName = ""
	local regionName = ""
	
	if tip.building then buildingName = GetString(tip.building) end
	if tip.keeper then keeperName = GetString(tip.keeper) end
	if port.region then 
		regionName = GetString("region_" .. port.region) 
	end

	-- %6% = Duration/Weeks Remaining
	local weeksRemaining = (tip.endTime or Player.time) - Player.time
	
	-- 4. Format String
	local finalString = GetText(finalKey, 
		itemName, 
		GetString(port.name), 
		buildingName, 
		keeperName,
		regionName,
		tostring(weeksRemaining)
	)

	if finalString and string.find(finalString, "<player>") then
		finalString = string.gsub(finalString, "<player>", Player.name or "")
	end

	return finalString
end