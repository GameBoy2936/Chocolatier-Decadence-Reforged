--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- An "Ingredient" is an atomic item that can be purchased in stores but
-- can never be manufactured by the player

Ingredient =
{
	name = nil,						-- Ingredient name
	code = nil,						-- A unique identifier (unique 3-letter code across the Chocolatier universe)
	category = nil,					-- Ingredient category
    unit_singular = "sack",			-- Property for custom unit
    unit_plural = "sacks",			-- Property for custom units
	locked = nil,					-- Is ingredient locked?
	
	-- Pricing
	price_low = nil,				-- Low price in season
	price_high = nil,				-- High price in season
	season_start = nil,				-- Season start day
	season_end = nil,				-- Season end day
	price_low_notinseason = nil,	-- Low price out of season
	price_high_notinseason = nil,	-- High price out of season
}

Ingredient.__tostring = function(t) return "{Ingredient:"..tostring(t.name).."}" end

_AllIngredients = {}			-- Match by ingredient names
_IngredientCodes = {}			-- Match by ingredient codes
_IngredientCategories = {}		-- Lists of ingredients by category name, category={...}
_IngredientOrder = {}			-- Ordered ingredients

--function IngredientOrderFunction(a,b) return a.price_low < b.price_low end
function IngredientOrderFunction(a,b) return a.name < b.name end

function IngredientAlphabetizeFunction(a,b) return a:GetName() < b:GetName() end

------------------------------------------------------------------------------
-- Player-specific accessors/modifiers

function Ingredient:GetPrice()
	return Player.itemPrices[self.name] or 0
end

function Ingredient:SetPrice(n)
    local oldPrice = Player.itemPrices[self.name] or 0
    if oldPrice ~= n then
        DebugOut("ECONOMY", "Price for " .. self:GetName() .. " changed from " .. Dollars(oldPrice) .. " to " .. Dollars(n))
    end
	Player.itemPrices[self.name] = (n or 0)
end

function Ingredient:GetName()
	return GetString(self.name)
end

function Ingredient:Buy(count)
	local cost = self:GetPrice() * count
	if cost <= Player.money then
        DebugOut("PLAYER", "Buying " .. count .. " sacks of " .. self:GetName() .. " for " .. Dollars(cost))
		self:AdjustInventory(count)
		if count > 0 then Player.useTimes[self.name] = Player.time end
		Player:SubtractMoney(cost)
		Player:UpdateSupplies()
		UpdateLedger("all")
--		Player:QueueMessage("msg_buy_ingredient", count, GetString(self.name), self:GetPrice())
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Ingredient:Create(t)
	if not t then
		DebugOut("ERROR", "Ingredient:Create called with nil definition table.")
	elseif not t.name then
		DebugOut("ERROR", "Ingredient:Create called without a name.")
	elseif _AllIngredients[t.name] then
		DebugOut("ERROR", "Ingredient:Create detected duplicate ingredient name: '" .. t.name .. "'. Ignoring.")
	elseif not t.code then
		DebugOut("ERROR", "Ingredient:Create called without a code for '" .. t.name .. "'.")
	elseif _IngredientCodes[t.code] then
		DebugOut("ERROR", "Ingredient:Create detected duplicate ingredient code: '" .. t.code .. "' (already used by " .. _IngredientCodes[t.code].name .. ").")
	elseif _G[t.name] then
		DebugOut("ERROR", "Ingredient:Create detected global variable collision for '" .. t.name .. "'.")
	else
		DebugOut("LOAD", "Created ingredient: " .. t.name)
		
		setmetatable(t, self) self.__index = self
		_AllIngredients[t.name] = t
		_IngredientCodes[t.code] = t
		_G[t.name] = t
		
		table.insert(_IngredientOrder, t)
		_IngredientCategories[t.category] = _IngredientCategories[t.category] or {}
		table.insert(_IngredientCategories[t.category], t)
		
		-- If XML provided <unit_type>, it's in 't'. If not, default to "unit_sack".
		t.unit_type = t.unit_type or "unit_sack"
		
		-- Certain values parsed from XML should be numbers
		t.price_low = tonumber(t.price_low)
		t.price_high = tonumber(t.price_high)
		t.season_start = tonumber(t.season_start)
		t.season_end = tonumber(t.season_end)
		t.price_low_notinseason = tonumber(t.price_low_notinseason)
		t.price_high_notinseason = tonumber(t.price_high_notinseason)
		
		-- Certain values parsed from XML should be other types
		if t.locked == "true" then t.locked = true else t.locked = nil end
	end
	return t
end

function CreateIngredient(t) return Ingredient:Create(t) end

------------------------------------------------------------------------------
-- Ingredient stats

function Ingredient:GetInventory()
	return Player.ingredients[self.name] or 0
end

function Ingredient:AdjustInventory(n)
	Player:AddIngredient(self.name, n)
	return self:GetInventory()
--[[
	local count = Player.ingredients[self.name] or 0
	if n < 0 then
		n = -n
		if n > count then count = nil
		else count = count - n
		end
	else
		count = count + n
	end
	Player.ingredients[self.name] = count
	return count or 0
]]--
end

function Ingredient:Lock()
    if self:IsAvailable() then DebugOut("PLAYER", "Ingredient locked: " .. self:GetName()) end
	Player.ingredientsAvailable[self.name] = false
end

function Ingredient:Unlock()
    if not self:IsAvailable() then DebugOut("PLAYER", "Ingredient unlocked: " .. self:GetName()) end
	Player.ingredientsAvailable[self.name] = true
end

function Ingredient:IsAvailable()
	local available = Player.ingredientsAvailable[self.name]
	if available == nil then
		available = (not self.locked) or false
	end
	return available
end

function Ingredient:IsInSeason(week)
	week = week or Player.time
	week = Mod(week,52) + 1
	return (self.season_start == self.season_end) or
		(self.season_start < self.season_end and self.season_start <= week and week <= self.season_end) or
		(self.season_start > self.season_end and self.season_start <= week or week <= self.season_end)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Ingredient:GetAppearanceBig(x,y)
	x=x or 0
	y=y or 0
	return Bitmap { x=x,y=y, image="items/"..self.name.."_big" }
end

function Ingredient:GetAppearance(x,y)
	x=x or 0
	y=y or 0
	return Bitmap { x=x,y=y, image="items/"..self.name }
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Ingredient:GetUnitName(count)
    return GetLocalizedUnit(self.unit_type, count)
end

function Ingredient:RolloverContents(strings)
    local invCount = self:GetInventory()
    
    local unit_string = self:GetUnitName(invCount)
    
    -- Inventory information
    local inventory = GetText("ing_inventory", tostring(invCount), unit_string)

	-- "High/Low" price information
	local priceRange = nil
	if Player.lowPrice[self.name] and Player.highPrice[self.name] then
		priceRange = GetText("price_range", Dollars(Player.lowPrice[self.name]), Dollars(Player.highPrice[self.name]))
	end
	
	-- "Last seen" information
	local lastSeen = GetString("ingredient_never_seen")
    if Player.lastSeenPort[self.name] then
        local singular_unit = self:GetUnitName(1) 
        lastSeen = GetText("ingredient_lastseen", GetText(Player.lastSeenPort[self.name]), Dollars(Player.lastSeenPrice[self.name]), singular_unit)
    end
	
	local text = {}
	table.insert(text, TightText { x=64,y=0, label="#<b> "..self:GetName().."</b>", })
	table.insert(text, TightText { x=64,y=16, label="# "..inventory, })
	local y = 32
	if priceRange then
		table.insert(text, TightText { x=64,y=y, label="# "..priceRange, })
		y = y + 16
	end
	table.insert(text, TightText { x=64,y=y, label="# "..lastSeen, })
	y = y + 16

	if strings then
		if type(strings) == "table" then
			for _,s in ipairs(strings) do
				table.insert(text, TightText { x=64,y=y, label="# "..s, })
				y = y + 16
			end
		else
			table.insert(text, TightText { x=64,y=y, label="# "..tostring(strings), })
			y = y + 16
		end
	end

	return MakeDialog
	{
		BSGWindow
		{
			x=0,y=0, fit=true, color=rolloverColor, frame="controls/rollover",
			Bitmap { x=4,y=0, image="items/"..self.name.."_big" },
			AppendStyle { font=rolloverInfoFont, flags=kVAlignTop+kHAlignLeft, },
			Group(text),
		}
	}
end

function Ingredient:MarketRolloverContents()
	return self:RolloverContents(GetString("click_buy"))
end

Ingredient.InventoryRolloverContents = Ingredient.RolloverContents
Ingredient.BuySellRolloverContents = Ingredient.RolloverContents
Ingredient.RecipeBookRolloverContents = Ingredient.InventoryRolloverContents