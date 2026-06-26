--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Shop Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

require("sim/player.lua")

-- A "Shop" is a Building where manufactured products are sold to the public.

Shop =
{
	buys = {},				-- Table of product categories this shop will purchase { [category_name] = true }
	cadikey = "market",		-- Reuses the same audio environment logic as markets
	type = "shop",
}

setmetatable(Shop, Building)
Shop.__index = Shop
Shop.__tostring = function(t) return "{Shop:" .. tostring(t.name) .. "}" end

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

function Shop:Create(name, port)
	local t = Building:Create(name, port)
	setmetatable(t, self) 
	self.__index = self
	
	-- Flag the parent port as possessing a shop
	port.hasShop = t
	return t
end

------------------------------------------------------------------------------
-- Building Interaction
------------------------------------------------------------------------------

function Shop:EnterBuilding(char, somethingHappened)
	char = self:RandomCharacter()
	DebugOut("BUILDING", string.format("Player entering shop: %s", self.name))
	DisplayDialog { "ui/ui_shop.lua", shop = self, char = char, ok = "ok" }
	return true
end

------------------------------------------------------------------------------
-- Ownership & Economics
------------------------------------------------------------------------------

-- Called when the player purchases a shop, unlocking features and stabilizing local prices.
function Shop:MarkOwned()
	Building.MarkOwned(self)
	
	Player.portsAvailable[self.port.name] = "shop"
	Player.shopsOwned = (Player.shopsOwned or 0) + 1
	
	-- Initialize the background data required to generate Special Orders from this shop
	if not Player.shopOrderData[self.name] then
		Player.shopOrderData[self.name] = { chance = 0 }
		DebugOut("ECONOMY", string.format("Initialized Special Order generation parameters for newly acquired shop: %s", self.name))
	end

	-- Immediately recalculate local market prices to reflect the new 20% markup benefit
	if Player.portName == self.port.name then
		Player:RecalculatePricesForCurrentPort()
	end
end

------------------------------------------------------------------------------
-- Haggling Mathematics
------------------------------------------------------------------------------

-- Computes the average "Reasonableness" (R) of products the player is selling.
-- 
-- NOTE FOR SELLING: Math is inverted compared to Markets. High prices are better
-- for the player. The formula is (High - Current) / Range.
-- Therefore, if Price == High, R = 0. A lower R value is still best for the player.
function Shop:ComputeReasonableness()
	local count = 0
	local R = 0
	
	for code, _ in pairs(Player.products) do
		local prod = _AllProducts[code]
		if prod and prod:GetInventory() > 0 then
			
			-- 1. Get the unmodified base selling price range
			local category = prod:GetMachinery()
			local low = Floor(prod.cost_low * category.markup + .5)
			local high = Floor(prod.cost_high * category.markup + .5)
			
			-- 2. Apply the difficulty penalty
			-- Selling is heavily nerfed on higher difficulties
			local price_penalty = 1.0
			if Player.difficulty == 2 then 
				price_penalty = 0.90
			elseif Player.difficulty == 3 then 
				price_penalty = 0.75
			end

			if price_penalty < 1.0 then
				low = Floor(low * price_penalty)
				high = Floor(high * price_penalty)
			end
			
			-- 3. Calculate R for this specific product
			-- Inverts the check: (High - Current). If selling at max price, R is 0.
			local prodR = (high - prod:GetPrice()) / (high - low)
			
			-- Clamp bounds to prevent math errors
			if prodR > 1.0 then prodR = 1.0 end
			if prodR < 0 then prodR = 0 end

			R = R + prodR
			count = count + 1
		end
	end
	
	-- 4. Calculate Final Average
	if count == 0 then 
		return 50 -- Default to completely neutral if inventory is empty
	else
		local finalR = (R * 100) / count
		DebugOut("HAGGLE", string.format("Shop '%s' Reasonableness Score (R): %.2f", self.name, finalR))
		return finalR
	end
end

-- Invoked when the player successfully negotiates to sell their chocolate for a higher price
function Shop:HaggleSuccess()
	DebugOut("HAGGLE", string.format("Haggle SUCCESS at shop '%s'. Product sale prices increasing.", self.name))

	-- Determine how far selling prices will rise based on game difficulty
	local success_factor = 0.5 -- Easy: Prices move 50% of the way towards the maximum
	
	if Player.difficulty == 2 then 
		success_factor = 0.35  -- Medium: Prices move 35% of the way
	elseif Player.difficulty == 3 then 
		success_factor = 0.25  -- Hard: Prices move only 25% of the way
	end

	-- Apply the boost to all products in the player's inventory
	for code, count in pairs(Player.products) do
		local prod = _AllProducts[code]
		if prod and prod:GetInventory() > 0 then
			local newPrice = Floor(prod:GetPrice() + (prod.price_high - prod:GetPrice()) * success_factor)
			prod:SetPrice(newPrice)
			SetLabel(prod.code .. "_price", BetterPriceColor .. Dollars(prod:GetPrice()))
		end
	end
end

-- Invoked when the player angers the shopkeeper, tanking the value of their goods
function Shop:HaggleFailure()
	DebugOut("HAGGLE", string.format("Haggle FAILURE at shop '%s'. Product sale prices dropping.", self.name))

	-- Determine the severity of the price drop based on game difficulty
	local failure_penalty = 1.0 -- Easy: Prices snap to their standard minimum
	
	if Player.difficulty == 2 then 
		failure_penalty = 0.80  -- Medium: Prices plummet to 80% of their minimum
	elseif Player.difficulty == 3 then 
		failure_penalty = 0.60  -- Hard: Prices plummet to 60% of their minimum
	end

	-- Apply the crash to all products in the player's inventory
	for code, count in pairs(Player.products) do
		local prod = _AllProducts[code]
		if prod and prod:GetInventory() > 0 then
			prod:SetPrice(Floor(prod.price_low * failure_penalty))
			SetLabel(prod.code .. "_price", WorsePriceColor .. Dollars(prod:GetPrice()))
		end
	end
end