--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Ingredient Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- An "Ingredient" is a raw atomic item (like Cacao, Sugar, Milk) that can 
-- be purchased at Markets or Farms, but can never be manufactured by the player.

Ingredient =
{
	-- ==========================================
	-- Identity & Properties
	-- ==========================================
	name = nil,						-- Internal localization key (e.g., "sugar")
	code = nil,						-- A unique 3-letter identifier
	category = nil,					-- The ingredient family (e.g., "cacao", "dairy", "fruit")
	unit_singular = "sack",			-- Fallback localized unit syntax (singular)
	unit_plural = "sacks",			-- Fallback localized unit syntax (plural)
	locked = nil,					-- TRUE if the ingredient is undiscovered
	
	-- ==========================================
	-- Pricing & Seasonality
	-- ==========================================
	price_low = nil,				-- Lowest possible price when IN season
	price_high = nil,				-- Highest possible price when IN season
	
	season_start = nil,				-- Week number (1-52) when season begins
	season_end = nil,				-- Week number (1-52) when season ends
	
	price_low_notinseason = nil,	-- Lowest possible price when OUT of season
	price_high_notinseason = nil,	-- Highest possible price when OUT of season

	-- ==========================================
	-- Dietary Flags
	-- ==========================================
	alcohol = nil,					-- TRUE if this ingredient contains alcohol (used for NPC dietary checks)
}

-- Metamethod for debug logging
Ingredient.__tostring = function(t) return "{Ingredient:" .. tostring(t.name) .. "}" end

-- Global Registries
_AllIngredients = {}			-- Lookup by ingredient name
_IngredientCodes = {}			-- Lookup by 3-letter ingredient code
_IngredientCategories = {}		-- Arrays of ingredients grouped by category
_IngredientOrder = {}			-- Sequentially ordered array of all ingredients

-- Sorting hooks for UI lists
function IngredientOrderFunction(a, b) return a.name < b.name end
function IngredientAlphabetizeFunction(a, b) return a:GetName() < b:GetName() end

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

-- Factory method: Creates and registers a raw ingredient from an XML definition
function Ingredient:Create(t)
	if not t then
		DebugOut("ERROR", "Ingredient:Create called with nil definition table.")
		return nil
	elseif not t.name then
		DebugOut("ERROR", "Ingredient:Create called without a name.")
		return nil
	elseif _AllIngredients[t.name] then
		DebugOut("ERROR", string.format("Duplicate ingredient name detected: '%s'. Ignoring.", t.name))
		return nil
	elseif not t.code then
		DebugOut("ERROR", string.format("Ingredient:Create called without a code for '%s'.", t.name))
		return nil
	elseif _IngredientCodes[t.code] then
		DebugOut("ERROR", string.format("Duplicate ingredient code detected: '%s' (Already used by %s).", t.code, _IngredientCodes[t.code].name))
		return nil
	elseif _G[t.name] then
		DebugOut("ERROR", string.format("Global variable collision detected for '%s'.", t.name))
		return nil
	else
		DebugOut("LOAD", string.format("Created ingredient definition: %s", t.name))
		
		-- Bind the metatable
		setmetatable(t, self) 
		self.__index = self
		
		-- Register globally
		_AllIngredients[t.name] = t
		_IngredientCodes[t.code] = t
		_G[t.name] = t
		
		table.insert(_IngredientOrder, t)
		_IngredientCategories[t.category] = _IngredientCategories[t.category] or {}
		table.insert(_IngredientCategories[t.category], t)
		
		-- Assign base units from XML, or fallback to sacks
		t.unit_type = t.unit_type or "unit_sack"
		
		-- Cast XML string parameters to rigid numbers, with safe fallbacks
		t.price_low = tonumber(t.price_low) or 0
		t.price_high = tonumber(t.price_high) or 0
		
		-- Default to year-round (Week 1 to 52) if seasonality is omitted
		t.season_start = tonumber(t.season_start) or 1
		t.season_end = tonumber(t.season_end) or 52
		
		-- Fall back to standard prices if out-of-season prices aren't defined
		t.price_low_notinseason = tonumber(t.price_low_notinseason) or t.price_low
		t.price_high_notinseason = tonumber(t.price_high_notinseason) or t.price_high
		
		-- Cast XML booleans
		if t.locked == "true" then t.locked = true else t.locked = nil end
		if t.alcohol == "true" then t.alcohol = true else t.alcohol = nil end
	end
	
	return t
end

function CreateIngredient(t) 
	return Ingredient:Create(t) 
end

------------------------------------------------------------------------------
-- Player Economics & Market Transactions
------------------------------------------------------------------------------

-- Retrieves the currently active market price in the player's local port
function Ingredient:GetPrice()
	return Player.itemPrices[self.name] or 0
end

-- Sets the local market price
function Ingredient:SetPrice(n)
	local oldPrice = Player.itemPrices[self.name] or 0
	if oldPrice ~= n then
		DebugOut("ECONOMY", string.format("Market price for %s shifted from %s to %s", self:GetName(), Dollars(oldPrice), Dollars(n)))
	end
	Player.itemPrices[self.name] = (n or 0)
end

-- Retrieves the fully localized display name
function Ingredient:GetName()
	return GetString(self.name)
end

-- Executes a purchase transaction and triggers Catalogue discovery logic
function Ingredient:Buy(count)
	local cost = self:GetPrice() * count
	
	if cost <= Player.money then
		DebugOut("ECONOMY", string.format("Purchased %d %s of %s for %s.", count, self:GetUnitName(count), self:GetName(), Dollars(cost)))
		
		self:AdjustInventory(count)
		
		-- Flag recent usage to prevent spoilage mechanics
		if count > 0 then Player.useTimes[self.name] = Player.time end
		
		Player:SubtractMoney(cost)
		Player:UpdateSupplies()
		UpdateLedger("all")

		-- -----------------------------------------------------
		-- Catalogue Discovery Logic
		-- -----------------------------------------------------
		if count > 0 then
			local currentWeek = Mod(Player.time, 52) + 1
			
			-- Only learn seasonal dates if we bought it while it was actively IN season.
			-- (Year-round items, where start==1 and end==52, don't need discovery).
			if self:IsInSeason(currentWeek) and not (self.season_start == 1 and self.season_end == 52) then
				
				if not Player.catalogue.discoveredIngredientSeasons[self.name] then
					Player.catalogue.discoveredIngredientSeasons[self.name] = {}
				end
				
				local seasonData = Player.catalogue.discoveredIngredientSeasons[self.name]
				
				-- Calculate total season length (handling December->January wrap arounds)
				local sStart = self.season_start
				local sEnd = self.season_end
				local length = 0
				
				if sStart <= sEnd then
					length = sEnd - sStart
				else
					length = (52 - sStart) + sEnd
				end
				
				-- Calculate our relative position within that season
				local weeksIn = 0
				if currentWeek >= sStart then
					weeksIn = currentWeek - sStart
				else
					weeksIn = (52 - sStart) + currentWeek
				end
				
				-- If we bought it during the FIRST half of the season, reveal the Start Date.
				if weeksIn <= (length / 2) then
					if not seasonData.start then
						seasonData.start = true
						DebugOut("CATALOGUE", string.format("Discovered season START date for: %s", self.name))
					end
				else
					-- If we bought it during the SECOND half of the season, reveal the End Date.
					if not seasonData.end_ then
						seasonData.end_ = true
						DebugOut("CATALOGUE", string.format("Discovered season END date for: %s", self.name))
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------
-- Inventory & State Management
------------------------------------------------------------------------------

function Ingredient:GetInventory()
	return Player.ingredients[self.name] or 0
end

-- Safely adds or removes an amount of this ingredient from the player's stock
function Ingredient:AdjustInventory(n)
	Player:AddIngredient(self.name, n)
	return self:GetInventory()
end

function Ingredient:Lock()
	if self:IsAvailable() then 
		DebugOut("PLAYER", string.format("Ingredient locked from generation: %s", self:GetName())) 
	end
	Player.ingredientsAvailable[self.name] = false
end

function Ingredient:Unlock()
	if not self:IsAvailable() then 
		DebugOut("PLAYER", string.format("Ingredient unlocked for generation: %s", self:GetName())) 
	end
	Player.ingredientsAvailable[self.name] = true
end

function Ingredient:IsAvailable()
	local available = Player.ingredientsAvailable[self.name]
	if available == nil then
		available = (not self.locked) or false
	end
	return available
end

-- Checks if the ingredient is currently "In Season" based on the world clock.
-- Correctly handles wrap-around dates (e.g., a winter item spanning Week 45 to Week 8).
function Ingredient:IsInSeason(week)
	week = week or Player.time
	week = Mod(week, 52) + 1
	
	return (self.season_start == self.season_end) or
		(self.season_start < self.season_end and self.season_start <= week and week <= self.season_end) or
		(self.season_start > self.season_end and (self.season_start <= week or week <= self.season_end))
end

------------------------------------------------------------------------------
-- UI Rendering & Tooltips
------------------------------------------------------------------------------

function Ingredient:GetAppearanceBig(x, y)
	x = x or 0
	y = y or 0
	return Bitmap { x = x, y = y, image = "items/" .. self.name .. "_big" }
end

function Ingredient:GetAppearance(x, y)
	x = x or 0
	y = y or 0
	return Bitmap { x = x, y = y, image = "items/" .. self.name }
end

function Ingredient:GetUnitName(count)
	return GetLocalizedUnit(self.unit_type, count)
end

-- Master function for generating the informational tooltip shown on hover
function Ingredient:RolloverContents(strings)
	local invCount = self:GetInventory()
	local unit_string = self:GetUnitName(invCount)
	
	-- Assemble localized text blocks
	local inventory = GetText("ing_inventory", tostring(invCount), unit_string)

	-- Show historical price range if the player has tracked it
	local priceRange = nil
	if Player.lowPrice[self.name] and Player.highPrice[self.name] then
		priceRange = GetText("price_range", Dollars(Player.lowPrice[self.name]), Dollars(Player.highPrice[self.name]))
	end
	
	-- Show last seen port
	local lastSeen = GetString("ingredient_never_seen")
	if Player.lastSeenPort[self.name] then
		local singular_unit = self:GetUnitName(1) 
		lastSeen = GetText("ingredient_lastseen", GetText(Player.lastSeenPort[self.name]), Dollars(Player.lastSeenPrice[self.name]), singular_unit)
	end
	
	-- Build visual layout list
	local text = {}
	table.insert(text, TightText { x = 64, y = 0, label = "#<b> " .. self:GetName() .. "</b>" })
	table.insert(text, TightText { x = 64, y = 16, label = "# " .. inventory })
	
	local y = 32
	if priceRange then
		table.insert(text, TightText { x = 64, y = y, label = "# " .. priceRange })
		y = y + 16
	end
	table.insert(text, TightText { x = 64, y = y, label = "# " .. lastSeen })
	y = y + 16

	-- Append optional context-specific action strings (like "Click to Buy")
	if strings then
		if type(strings) == "table" then
			for _, s in ipairs(strings) do
				table.insert(text, TightText { x = 64, y = y, label = "# " .. s })
				y = y + 16
			end
		else
			table.insert(text, TightText { x = 64, y = y, label = "# " .. tostring(strings) })
			y = y + 16
		end
	end

	return MakeDialog
	{
		BSGWindow
		{
			x = 0, y = 0, fit = true, color = rolloverColor, frame = "controls/rollover",
			Bitmap { x = 4, y = 0, image = "items/" .. self.name .. "_big" },
			AppendStyle { font = rolloverInfoFont, flags = kVAlignTop + kHAlignLeft },
			Group(text),
		}
	}
end

-- Contextual aliases for UI elements
function Ingredient:MarketRolloverContents() return self:RolloverContents(GetString("click_buy")) end
Ingredient.InventoryRolloverContents = Ingredient.RolloverContents
Ingredient.BuySellRolloverContents = Ingredient.RolloverContents
Ingredient.RecipeBookRolloverContents = Ingredient.InventoryRolloverContents