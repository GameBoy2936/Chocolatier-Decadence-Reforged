--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Market & Farm Classes)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Market" is a Building where ingredients are purchased.
-- A "Farm" functions identically to a Market but utilizes different ambient audio.

Market =
{
	inventory = {},
	cadikey = "market",
	type = "market",
}

setmetatable(Market, Building)
Market.__index = Market
Market.__tostring = function(t) return "{Market:" .. tostring(t.name) .. "}" end

Farm =
{
	cadikey = "plantation",
	type = "farm",
}
setmetatable(Farm, Market)
Farm.__index = Farm
Farm.__tostring = function(t) return "{Farm:" .. tostring(t.name) .. "}" end

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

function Market:Create(name, port)
	local t = Building:Create(name, port)
	setmetatable(t, self) 
	self.__index = self
	return t
end

------------------------------------------------------------------------------
-- Building Interaction
------------------------------------------------------------------------------

function Market:EnterBuilding(char, somethingHappened)
	-- Always open the market UI upon entry, even if a quest just triggered
	char = self:RandomCharacter()
	DebugOut("BUILDING", string.format("Player entering market/farm: %s", self.name))
	
	DisplayDialog { "ui/ui_market.lua", market = self, char = char, ok = "ok" }
	return true
end

------------------------------------------------------------------------------
-- Haggling Mathematics
------------------------------------------------------------------------------

-- Computes the average "Reasonableness" (R) of all ingredients currently for sale here.
-- The R value is a measure of where the current price lies between the item's 
-- historical low and high prices.
-- 
-- NOTE FOR BUYING: A *lower* value of R indicates prices are near their minimum,
-- which means they are skewed in the player's favor.
function Market:ComputeReasonableness()
	local count = 0
	local R = 0
	
	for _, ing in ipairs(self.inventory) do
		if ing:IsAvailable() then
			-- 1. Get the unmodified base prices from the master definition list
			local true_base_ing = _AllIngredients[ing.name]
			local low = true_base_ing.price_low
			local high = true_base_ing.price_high
			
			if not ing:IsInSeason() then
				low = true_base_ing.price_low_notinseason
				high = true_base_ing.price_high_notinseason
			end

			-- 2. Apply the difficulty multiplier to this true base range
			-- This creates the correct pricing context for the current game difficulty.
			local cost_multiplier = 1.0
			if Player.difficulty == 2 then 
				cost_multiplier = 1.25
			elseif Player.difficulty == 3 then 
				cost_multiplier = 1.50
			end
			
			if cost_multiplier > 1.0 then
				low = Floor(low * cost_multiplier)
				high = Floor(high * cost_multiplier)
			end
			
			-- 3. Calculate R for this specific ingredient
			-- If Price == Low, R = 0 (Perfect for buying).
			local ingR = (ing:GetPrice() - low) / (high - low)
			
			-- Clamp bounds to prevent scores > 1.0 due to floating point rounding errors
			if ingR > 1.0 then ingR = 1.0 end
			if ingR < 0 then ingR = 0 end

			R = R + ingR
			count = count + 1
		end
	end
	
	-- 4. Calculate Final Average
	if count == 0 then 
		return 50 -- Default to completely neutral if inventory is empty
	else 
		local finalR = (R * 100) / count
		DebugOut("HAGGLE", string.format("Market '%s' Reasonableness Score (R): %.2f", self.name, finalR))
		return finalR
	end
end

-- Invoked when the player successfully negotiates with the merchant
function Market:HaggleSuccess()
	DebugOut("HAGGLE", string.format("Haggle SUCCESS at market '%s'. Ingredient prices dropping.", self.name))
	
	-- Determine how far prices will drop based on game difficulty
	local success_factor = 0.5 -- Easy: Prices move 50% towards the minimum
	
	if Player.difficulty == 2 then 
		success_factor = 0.35  -- Medium: Prices move 35% towards the minimum
	elseif Player.difficulty == 3 then 
		success_factor = 0.25  -- Hard: Prices move only 25% towards the minimum
	end
	
	-- Apply the drop to all ingredients in the market
	for _, ing in ipairs(self.inventory) do
		local low = ing.price_low
		if not ing:IsInSeason() then low = ing.price_low_notinseason end
		
		local newPrice = Floor(ing:GetPrice() - (ing:GetPrice() - low) * success_factor)
		
		ing:SetPrice(newPrice)
		SetLabel(ing.name .. "_price", BetterPriceColor .. Dollars(ing:GetPrice()))
	end
end

-- Invoked when the player angers the merchant during negotiation
function Market:HaggleFailure()
	DebugOut("HAGGLE", string.format("Haggle FAILURE at market '%s'. Ingredient prices increasing.", self.name))
	
	-- Determine the severity of the price spike based on game difficulty
	local failure_penalty = 1.0 -- Easy: Prices snap to their standard maximum
	
	if Player.difficulty == 2 then 
		failure_penalty = 1.25  -- Medium: Prices spike to 125% of their maximum
	elseif Player.difficulty == 3 then 
		failure_penalty = 1.50  -- Hard: Prices spike to 150% of their maximum
	end
	
	-- Apply the spike to all ingredients in the market
	for _, ing in ipairs(self.inventory) do
		local high = ing.price_high
		if not ing:IsInSeason() then high = ing.price_high_notinseason end

		ing:SetPrice(Floor(high * failure_penalty))
		SetLabel(ing.name .. "_price", WorsePriceColor .. Dollars(ing:GetPrice()))
	end
end