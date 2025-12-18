--[[--------------------------------------------------------------------------
	Chocolatier Three - Shops
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

require("sim/player.lua")

-- A "Shop" is a Building where things are bought

Shop =
{
	buys = {},				-- Set of product categories this shop purchases, set of <category name>=true
--	cadikey = "shop",
	cadikey = "market",		-- Reuse same audio environment for both shops and markets
	type = "shop",
}

setmetatable(Shop, Building)
Shop.__index = Shop
Shop.__tostring = function(t) return "{Shop:"..tostring(t.name).."}" end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Shop:Create(name, port)
	local t = Building:Create(name, port)
	setmetatable(t, self) self.__index = self
	port.hasShop = t
	return t
end

------------------------------------------------------------------------------
-- Click Management

function Shop:EnterBuilding(char, somethingHappened)
	-- Always open the shop, even if a quest just started or finished
--	char = char or self:RandomCharacter()
	char = self:RandomCharacter()
    DebugOut("BUILDING", "Player entering shop: " .. self.name)
	DisplayDialog { "ui/ui_shop.lua", shop=self, char=char, ok="ok" }
	return true
end

------------------------------------------------------------------------------
-- Ownership

function Shop:MarkOwned()
    Building.MarkOwned(self)
    Player.portsAvailable[self.port.name] = "shop"
    Player.shopsOwned = (Player.shopsOwned or 0) + 1
    
    -- Initialize the order generation data for this new shop
    if not Player.shopOrderData[self.name] then
        Player.shopOrderData[self.name] = { chance = 0 }
        DebugOut("PLAYER", "Initialized special order data for new shop: " .. self.name)
    end

    if Player.portName == self.port.name then
        Player:RecalculatePricesForCurrentPort()
    end
end

------------------------------------------------------------------------------
-- Haggling

-- Compute the average reasonableness of all ingredients for sale here
-- The "reasonableness" R of a current price is a measure of where the
-- current price lies between the item low and high prices. A lower
-- value of R indicates prices are skewed in the player's favor.
function Shop:ComputeReasonableness()
	local count = 0
	local R = 0
	for code,_ in pairs(Player.products) do
		local prod = _AllProducts[code]
		if prod and prod:GetInventory() > 0 then
			-- Get the unmodified "Easy" base price range first
            local category = prod:GetMachinery()
			local low = Floor(prod.cost_low * category.markup + .5)
			local high = Floor(prod.cost_high * category.markup + .5)
            
            -- Apply the difficulty penalty to this true base range
            local price_penalty = 1.0
            if Player.difficulty == 2 then price_penalty = 0.90
            elseif Player.difficulty == 3 then price_penalty = 0.75
            end

            if price_penalty < 1.0 then
                low = Floor(low * price_penalty)
                high = Floor(high * price_penalty)
            end
			
			-- High prices are better and lead to lower R values
			-- Compare the current price against the correct difficulty-adjusted range
			local prodR = (high - prod:GetPrice()) / (high - low)
            -- Add a clamp to prevent invalid scores
            if prodR > 1.0 then prodR = 1.0 end
            if prodR < 0 then prodR = 0 end

			R = R + prodR
			count = count + 1
		end
	end
	
	if (count == 0) then return 50
	else
        local finalR = (R * 100) / count
        DebugOut("HAGGLE", "Shop '" .. self.name .. "' reasonableness score: " .. string.format("%.2f", finalR))
        return finalR
	end
end

function Shop:HaggleSuccess()
    DebugOut("HAGGLE", "Haggle SUCCESS at shop '" .. self.name .. "'. Prices increasing.")

    -- Adjust success reward
    local success_factor = 0.5 -- Easy: Prices move 50% of the way towards the maximum
    if Player.difficulty == 2 then -- Medium
        success_factor = 0.35 -- Medium: Prices move 35% of the way
    elseif Player.difficulty == 3 then -- Hard
        success_factor = 0.25 -- Hard: Prices move only 25% of the way
    end

	-- Product prices trend upwards towards their high
	for code,count in pairs(Player.products) do
		local prod = _AllProducts[code]
		if prod and prod:GetInventory() > 0 then
			local newPrice = Floor(prod:GetPrice() + (prod.price_high - prod:GetPrice()) * success_factor)
			prod:SetPrice(newPrice)
			SetLabel(prod.code.."_price", BetterPriceColor..Dollars(prod:GetPrice()))
		end
	end
end

function Shop:HaggleFailure()
    DebugOut("HAGGLE", "Haggle FAILURE at shop '" .. self.name .. "'. Prices dropping.")

    -- Adjust failure penalty
    local failure_penalty = 1.0 -- Easy: Prices go to their minimum
    if Player.difficulty == 2 then -- Medium
        failure_penalty = 0.80 -- Medium: Prices go to 80% of their minimum
    elseif Player.difficulty == 3 then -- Hard
        failure_penalty = 0.60 -- Hard: Prices go to 60% of their minimum
    end

	-- Product prices plummet to their minimums (or below on higher difficulties)
	for code,count in pairs(Player.products) do
		local prod = _AllProducts[code]
		if prod and prod:GetInventory() > 0 then
			prod:SetPrice(Floor(prod.price_low * failure_penalty))
			SetLabel(prod.code.."_price", WorsePriceColor..Dollars(prod:GetPrice()))
		end
	end
end