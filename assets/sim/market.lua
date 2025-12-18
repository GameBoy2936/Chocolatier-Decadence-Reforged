--[[--------------------------------------------------------------------------
	Chocolatier Three - Markets
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Market" is a Building where things are sold, a "Farm" is a Market with
-- different audio

Market =
{
	inventory = {},
	cadikey = "market",
	type = "market",
}

setmetatable(Market, Building)
Market.__index = Market
Market.__tostring = function(t) return "{Market:"..tostring(t.name).."}" end

Farm =
{
	cadikey = "plantation",
	type = "farm",
}
setmetatable(Farm, Market)
Farm.__index = Farm
Farm.__tostring = function(t) return "{Farm:"..tostring(t.name).."}" end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Market:Create(name, port)
	local t = Building:Create(name, port)
	setmetatable(t, self) self.__index = self
	return t
end

------------------------------------------------------------------------------
-- Click Management

function Market:EnterBuilding(char, somethingHappened)
	-- Always open the market, even if a quest just started or finished
--	char = char or self:RandomCharacter()
	char = self:RandomCharacter()
    DebugOut("BUILDING", "Player entering market: " .. self.name)
	DisplayDialog { "ui/ui_market.lua", market=self, char=char, ok="ok" }
	return true
end

------------------------------------------------------------------------------
-- Haggling

-- Compute the average reasonableness of all ingredients for sale here
-- The "reasonableness" R of a current price is a measure of where the
-- current price lies between the item low and high prices. A lower
-- value of R indicates prices are skewed in the player's favor.
function Market:ComputeReasonableness()
	local count = 0
	local R = 0
	for _,ing in ipairs(self.inventory) do
		if ing:IsAvailable() then
			-- Get the unmodified base prices from the master list
            local true_base_ing = _AllIngredients[ing.name]
			local low = true_base_ing.price_low
			local high = true_base_ing.price_high
			if (not ing:IsInSeason()) then
				low = true_base_ing.price_low_notinseason
				high = true_base_ing.price_high_notinseason
			end

            -- Now we apply the difficulty multiplier to this true base range
            -- to create the correct context for the current difficulty.
            local cost_multiplier = 1.0
            if Player.difficulty == 2 then cost_multiplier = 1.25
            elseif Player.difficulty == 3 then cost_multiplier = 1.50
            end
            
            if cost_multiplier > 1.0 then
                low = Floor(low * cost_multiplier)
                high = Floor(high * cost_multiplier)
            end
			
			-- Low prices are better and lead to lower R values.
            -- Now we are correctly comparing the current price against the
            -- full possible price range for the current difficulty.
			local ingR = (ing:GetPrice() - low) / (high - low)
            -- Add a clamp to prevent scores > 1 due to floating point rounding
            if ingR > 1.0 then ingR = 1.0 end
            if ingR < 0 then ingR = 0 end

			R = R + ingR
			count = count + 1
		end
	end
	
	if (count == 0) then return 50
	else 
        local finalR = (R * 100) / count
        DebugOut("HAGGLE", "Market '" .. self.name .. "' reasonableness score: " .. string.format("%.2f", finalR))
        return finalR
	end
end

function Market:HaggleSuccess()
    DebugOut("HAGGLE", "Haggle SUCCESS at market '" .. self.name .. "'. Prices dropping.")
	
	-- Adjust success reward
    local success_factor = 0.5 -- Easy: Prices move 50% towards the minimum
    if Player.difficulty == 2 then -- Medium
        success_factor = 0.35 -- Medium: Prices move 35% towards the minimum
    elseif Player.difficulty == 3 then -- Hard
        success_factor = 0.25 -- Hard: Prices move only 25% towards the minimum
    end
	
	-- Ingredient prices trend downwards 50% towards their low
	for _,ing in ipairs(self.inventory) do
		local low = ing.price_low
		if not ing:IsInSeason() then low = ing.price_low_notinseason end
		local newPrice = Floor(ing:GetPrice() - (ing:GetPrice() - low) * success_factor)
		
		ing:SetPrice(newPrice)
		SetLabel(ing.name.."_price", BetterPriceColor..Dollars(ing:GetPrice()))
	end
end

function Market:HaggleFailure()
    DebugOut("HAGGLE", "Haggle FAILURE at market '" .. self.name .. "'. Prices increasing.")
	
	-- Adjust failure penalty
    local failure_penalty = 1.0 -- Easy: Prices go to their maximum
    if Player.difficulty == 2 then -- Medium
        failure_penalty = 1.25 -- Medium: Prices go to 125% of their maximum
    elseif Player.difficulty == 3 then -- Hard
        failure_penalty = 1.50 -- Hard: Prices go to 150% of their maximum
    end
	
	-- Ingredient prices rocket to their maximums
	for _,ing in ipairs(self.inventory) do
		local high = ing.price_high
		if not ing:IsInSeason() then high = ing.price_high_notinseason end

		ing:SetPrice(Floor(high * failure_penalty))
		SetLabel(ing.name.."_price", WorsePriceColor..Dollars(ing:GetPrice()))
	end
end