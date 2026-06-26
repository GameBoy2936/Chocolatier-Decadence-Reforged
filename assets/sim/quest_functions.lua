--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Quest Functions)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script houses all the atomic building blocks used to construct Quests.
-- The engine categorizes these into two distinct types:
-- 1. REWARDS (Prefixed with 'Award'): Executed when a quest completes.
-- 2. REQUIREMENTS (Prefixed with 'Require'): Evaluated constantly to see if a quest's goals are met.

-------------------------------------------------------------------------------
-- Base Helpers
-------------------------------------------------------------------------------

-- Retrieves a product object safely using its string code.
-- Crucially, it parses dynamic "user" codes (e.g., "user1", "user2") to fetch 
-- custom player-created UGRs from the category arrays, preventing crashes when
-- a quest asks for a product that didn't exist at launch.
local function GetProductByCode(code)
	local prod = _AllProducts[code]
	
	if not prod then
		-- Search the string for the "user" prefix
		local first, last = string.find(code, "user", 1, true)
		if first then
			-- Extract the numerical index (e.g., "user3" -> 3)
			local i = tonumber(string.sub(code, last + 1))
			local products = _AllCategories["user"].products
			
			-- Verify the player actually has a recipe in that slot
			if products and i <= table.getn(products) then 
				prod = products[i] 
			end
		end
	end
	
	return prod
end

-------------------------------------------------------------------------------
-- Cash / Wealth Modifiers
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardMoney
-- Injects raw cash directly into the player's wallet.
-- ==========================================
local _AwardMoney = {
	DebugDescription = function(self) return "Cash: " .. Dollars(self.money) end,
	Description = function(self) return GetText("award_money", Dollars(self.money)) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Deposit %s into player account.", Dollars(self.money)))
		Player:AddMoney(self.money)
		return true
	end,
}
function AwardMoney(money) return CreateObject(_AwardMoney, { money = tonumber(money) }) end

-- ==========================================
-- REQUIREMENT: RequireMinMoney
-- Checks if the player's bank balance is ABOVE a specific threshold.
-- ==========================================
local _MinMoney = {
	DebugDescription = function(self) return "Cash >= " .. Dollars(self.money) end,
	Description = function(self) return GetText("require_min_money", Dollars(self.money)) end,
	Evaluate = function(self, quest)
		return (Player.money >= self.money)
	end,
}
function RequireMinMoney(money) return CreateObject(_MinMoney, { money = tonumber(money) }) end

-- ==========================================
-- REQUIREMENT: RequireMaxMoney
-- Checks if the player's bank balance is BELOW a specific threshold.
-- (Used to trigger poverty/bankruptcy quests).
-- ==========================================
local _MaxMoney = {
	DebugDescription = function(self) return "Cash <= " .. Dollars(self.money) end,
	Description = function(self) return GetText("require_max_money", Dollars(self.money)) end,
	Evaluate = function(self, quest)
		return (Player.money <= self.money)
	end,
}
function RequireMaxMoney(money) return CreateObject(_MaxMoney, { money = tonumber(money) }) end

-- ==========================================
-- REQUIREMENT: RequireMoneyRange
-- Checks if the player's balance sits within a specific bracket.
-- ==========================================
local _RequireMoneyRange = {
	DebugDescription = function(self) return "Cash: " .. Dollars(self.min) .. " - " .. Dollars(self.max) end,
	Description = function(self) return GetText("require_min_money", Dollars(self.min)) .. " and " .. GetText("require_max_money", Dollars(self.max)) end,
	Evaluate = function(self, quest)
		return (Player.money >= self.min and Player.money <= self.max)
	end,
}
function RequireMoneyRange(minMoney, maxMoney) return CreateObject(_RequireMoneyRange, { min = tonumber(minMoney), max = tonumber(maxMoney) }) end

-------------------------------------------------------------------------------
-- Rank Progression
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardRank
-- Hard-sets the player's corporate rank tier (1-5).
-- This drives dialogue, map access, and game difficulty parameters.
-- ==========================================
local _AwardRank = {
	DebugDescription = function(self) return "Rank " .. self.rank end,
	Description = function(self) return GetString("award_rank") end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Set Player Rank to Tier %d.", self.rank))
		Player:SetRank(self.rank)
		return true
	end
}
function AwardRank(rank) return CreateObject(_AwardRank, { rank = rank }) end

-- ==========================================
-- REQUIREMENT: RequireMinRank
-- Validates the player has reached or exceeded a specific progression tier.
-- ==========================================
local _MinRank = {
	Description = function(self) return "Rank >= " .. self.rank end,
	Evaluate = function(self, quest)
		return (Player.rank >= self.rank)
	end,
}
function RequireMinRank(rank) return CreateObject(_MinRank, { rank = tonumber(rank) }) end

-- ==========================================
-- REQUIREMENT: RequireMaxRank
-- Restricts a quest so it only triggers for lower-tier players.
-- ==========================================
local _MaxRank = {
	Description = function(self) return "Rank <= " .. self.rank end,
	Evaluate = function(self, quest)
		return (Player.rank <= self.rank)
	end,
}
function RequireMaxRank(rank) return CreateObject(_MaxRank, { rank = tonumber(rank) }) end

-------------------------------------------------------------------------------
-- Inventory Manipulation (Ingredients & Products)
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardIngredient
-- Adds a specific volume of a raw ingredient to the warehouse.
-- ==========================================
local _AwardIngredient = {
	DebugDescription = function(self) return tostring(self.count) .. " sacks " .. tostring(self.name) end,
	Description = function(self) return GetText("award_ingredient", tostring(self.count), GetText(self.name)) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Adding %d sacks of raw %s.", self.count, self.name))
		Player:AddIngredient(self.name, self.count)
		return true
	end,
	-- Ensures the script engine doesn't crash if a typo exists in the quest XML
	CrossCheck = function(self) if _AllIngredients[self.name] then return nil else return "UNDEFINED INGREDIENT: " .. self.name end end
}

-- ==========================================
-- REWARD: AwardProduct
-- Adds a specific volume of manufactured product to the warehouse.
-- ==========================================
local _AwardProduct = {
	DebugDescription = function(self) return tostring(self.count) .. " cases " .. tostring(self.code) end,
	Description = function(self)
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then name = prod:GetName() end
		return GetText("award_product", tostring(self.count), name)
	end,
	Apply = function(self)
		local prod = GetProductByCode(self.code)
		if prod then
			DebugOut("QUEST", string.format("Applying reward: Adding %d cases of manufactured %s.", self.count, prod:GetName()))
			Player:AddProduct(prod.code, self.count)
		end
		return true
	end,
}

-- Wrapper function: Automatically detects if the requested item is a raw ingredient
-- or a finished product and generates the correct Reward Object.
function AwardItem(name, count)
	if _AllIngredients[name] then 
		return CreateObject(_AwardIngredient, { name = name, count = count })
	else 
		return CreateObject(_AwardProduct, { code = name, count = count })
	end
end

-- ==========================================
-- REWARD: AwardSetInventory
-- Overrides normal addition math and hard-sets the player's stock of an item to a specific number.
-- Useful for confiscation quests (e.g. "Take all my cacao").
-- ==========================================
local _AwardSetInventory = {
	DebugDescription = function(self) return "Set " .. tostring(self.name) .. " to " .. tostring(self.count) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Hard-setting inventory of '%s' to exactly %d.", self.name, self.count))
		
		if _AllIngredients[self.name] then
			Player.ingredients[self.name] = self.count
		else
			local prod = GetProductByCode(self.name)
			if prod then Player.products[prod.code] = self.count end
		end
		
		-- Force a supply recalculation in case we just emptied out active factories
		Player:UpdateSupplies()
		return true
	end,
}
function AwardSetInventory(itemName, count) return CreateObject(_AwardSetInventory, { name = itemName, count = count }) end

-- ==========================================
-- REWARD: AwardRandomIngredient
-- Generates a randomized ingredient reward based on catalogue pools.
-- Supports bounded ranges (e.g. 5 to 10 sacks) and negative bounds to steal items.
-- ==========================================
local _AwardRandomIngredient = {
	DebugDescription = function(self)
		local range = tostring(self.min)
		if self.max then range = range .. " to " .. tostring(self.max) end
		return "Random Ingredient (" .. self.poolType .. "): " .. range
	end,
	
	-- Description omitted because the specific item is generated at the moment of execution.
	Description = function(self) return nil end,
	
	Apply = function(self)
		local pool = {}
		
		-- Filter the global ingredient list based on the requested parameter
		for _, ing in ipairs(_IngredientOrder) do
			local include = false
			if self.poolType == "all" then 
				include = true
			elseif self.poolType == "unlocked" then 
				if Player.catalogue.unlockedIngredients[ing.name] then include = true end
			elseif self.poolType == "locked" then 
				if not Player.catalogue.unlockedIngredients[ing.name] then include = true end
			end
			
			if include then table.insert(pool, ing) end
		end
		
		if table.getn(pool) > 0 then
			-- Execute weighted selection
			local ing = pool[RandRange(1, table.getn(pool))]
			
			local amount = self.min
			if self.max then amount = RandRange(self.min, self.max) end
			
			DebugOut("QUEST", string.format("Applying reward: Random Ingredient Generator (%s pool) yielded %d sacks of '%s'.", self.poolType, amount, ing:GetName()))
			Player:AddIngredient(ing.name, amount)
		else
			DebugOut("ERROR", string.format("AwardRandomIngredient failed: No ingredients exist in the requested pool '%s'.", self.poolType))
		end
		return true
	end,
}
function AwardRandomIngredient(type, count1, count2)
	return CreateObject(_AwardRandomIngredient, { poolType = type, min = count1, max = count2 })
end

-- ==========================================
-- REWARD: AwardRandomProduct
-- Generates a randomized finished product reward based on catalogue pools.
-- Explictly ignores UGRs to prevent logic errors.
-- ==========================================
local _AwardRandomProduct = {
	DebugDescription = function(self)
		local range = tostring(self.min)
		if self.max then range = range .. " to " .. tostring(self.max) end
		return "Random Product (" .. self.poolType .. "): " .. range
	end,
	
	Apply = function(self)
		local pool = {}
		
		for code, prod in pairs(_AllProducts) do
			-- Block user creations; only base-game system recipes are eligible for RNG drops
			if prod.category.name ~= "user" then
				local include = false
				
				if self.poolType == "all" then 
					include = true
				elseif self.poolType == "unlocked" then 
					if prod:IsKnown() then include = true end
				elseif self.poolType == "locked" then 
					if not prod:IsKnown() then include = true end
				end
				
				if include then table.insert(pool, prod) end
			end
		end
		
		if table.getn(pool) > 0 then
			local prod = pool[RandRange(1, table.getn(pool))]
			
			local amount = self.min
			if self.max then amount = RandRange(self.min, self.max) end
			
			DebugOut("QUEST", string.format("Applying reward: Random Product Generator (%s pool) yielded %d cases of '%s'.", self.poolType, amount, prod:GetName()))
			Player:AddProduct(prod.code, amount)
		else
			DebugOut("ERROR", string.format("AwardRandomProduct failed: No products exist in the requested pool '%s'.", self.poolType))
		end
		return true
	end,
}
function AwardRandomProduct(type, count1, count2)
	return CreateObject(_AwardRandomProduct, { poolType = type, min = count1, max = count2 })
end

-- ==========================================
-- REQUIREMENT: RequireIngredient / RequireProduct
-- Constantly evaluates if the player has gathered enough of a specific item to hand in a quest.
-- ==========================================
local _RequireIngredient = {
	DebugDescription = function(self) return tostring(self.count) .. " sacks " .. tostring(self.name) end,
	Description = function(self)
		if self.count > 1 then return GetText("require_ingredient", tostring(self.count), GetText(self.name))
		else return GetText("require_ingredient_single", GetText(self.name))
		end
	end,
	Evaluate = function(self, quest)
		local have = Player.ingredients[self.name] or 0
		return have >= self.count
	end,
	CrossCheck = function(self) if _AllIngredients[self.name] then return nil else return "UNDEFINED INGREDIENT: " .. self.name end end
}

local _RequireProduct = {
	DebugDescription = function(self) return tostring(self.count) .. " cases " .. tostring(self.code) end,
	Description = function(self)
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then name = prod:GetName()
		else name = GetString("ugr_generic")
		end
		
		if self.count > 1 then return GetText("require_product", tostring(self.count), name)
		else return GetText("require_product_single", name)
		end
	end,
	Evaluate = function(self, quest)
		local have = 0
		local prod = GetProductByCode(self.code)
		if prod then have = Player.products[prod.code] or 0 end
		return have >= self.count
	end,
}

-- Smart routing function for item requirements
function RequireItem(name, count)
	if _AllIngredients[name] then return CreateObject(_RequireIngredient, { name = name, count = count })
	else return CreateObject(_RequireProduct, { code = name, count = count })
	end
end

-------------------------------------------------------------------------------
-- Manufacturing & Machinery
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardMachinery
-- Unlocks a new production line tier (e.g. Infusions, Truffles) in a specific factory.
-- ==========================================
local _AwardMachinery = {
	DebugDescription = function(self) return "Machinery: " .. self.category .. " in " .. self.building end,
	Description = function(self) return GetText("award_machinery", GetText(self.category), GetText(self.building)) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Permanently installed %s machinery into factory '%s'.", self.category, self.building))
		Player.factories[self.building][self.category] = true
		return true
	end,
}
function AwardMachinery(category, building)
	return CreateObject(_AwardMachinery, { category = category, building = building })
end

-- ==========================================
-- REWARD: AwardRecipe
-- Adds a specific game recipe to the player's recipe book.
-- ==========================================
local _AwardRecipe = {
	DebugDescription = function(self) return "Recipe: " .. self.code end,
	Description = function(self)
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then name = prod:GetName() end
		return GetText("award_recipe", name)
	end,
	Apply = function(self)
		local prod = GetProductByCode(self.code)
		if prod then
			prod:Unlock()
			gRecipeSelection = prod
		end
		return true
	end,
	CrossCheck = function(self) if _AllProducts[self.code] then return nil else return "UNDEFINED PRODUCT: " .. self.code end end
}
function AwardRecipe(code) return CreateObject(_AwardRecipe, { code = code }) end

-- ==========================================
-- REQUIREMENT: RequireRecipe
-- Checks if the player has unlocked a specific recipe.
-- ==========================================
local _RequireRecipe = {
	DebugDescription = function(self) return "Recipe: " .. self.code end,
	Description = function(self)
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then
			name = prod:GetName()
			return GetText("require_recipe", name)
		else
			return GetString("require_recipe_invented")
		end
	end,
	Evaluate = function(self, quest)
		local prod = GetProductByCode(self.code)
		if prod then return Player.knownRecipes[prod.code]
		else return false
		end
	end,
}
function RequireRecipe(code) return CreateObject(_RequireRecipe, { code = code }) end

-- ==========================================
-- REQUIREMENT: RequireLabIngredient
-- Verifies that the player has physically evaluated an ingredient in the test kitchen 
-- by dropping 1 sack of it into Teddy's pantry.
-- ==========================================
local _RequireLabIngredient = {
	DebugDescription = function(self) return "Lab has: " .. self.name end,
	Evaluate = function(self, quest)
		return Player.labIngredients[self.name] or false
	end,
	CrossCheck = function(self) if _AllIngredients[self.name] then return nil else return "UNDEFINED INGREDIENT: " .. self.name end end
}
function RequireLabIngredient(ingredientName) return CreateObject(_RequireLabIngredient, { name = ingredientName }) end

-- ==========================================
-- REQUIREMENT: RequireRecipeMade
-- Validates if the player has actually run the factory to produce a product, 
-- rather than just buying it or cheating it in.
-- ==========================================
local _RequireRecipeMade = {
	DebugDescription = function(self) return "Make: " .. self.count .. "x " .. self.code end,
	Description = function(self)
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then name = prod:GetName() end
		
		if self.count == 1 then return GetText("require_recipe_made_single", name, tostring(self.count))
		else return GetText("require_recipe_made", name, tostring(self.count))
		end
	end,
	Evaluate = function(self, quest)
		local made = 0
		local prod = GetProductByCode(self.code)
		if prod then made = Player.itemsMade[prod.code] or 0 end
		return (made >= self.count)
	end,
}
function RequireRecipeMade(code, count)
	count = count or 1
	return CreateObject(_RequireRecipeMade, { code = code, count = count })
end

-- Alias for UGR tracking
function RequireUserRecipeMade(index, count)
	index = index or 1
	return RequireRecipeMade("user" .. index, count)
end

-- ==========================================
-- REQUIREMENT: RequireRecipeInvented
-- Validates that a UGR has been successfully created in the test kitchen.
-- ==========================================
local _RequireRecipeInvented = {
	DebugDescription = function(self) return "Invent: " .. self.code end,
	Description = function(self) return GetString("require_recipe_invented") end,
	Evaluate = function(self, quest)
		local prod = GetProductByCode(self.code)
		if prod then return true else return false end
	end,
}
function RequireRecipeInvented(code) return CreateObject(_RequireRecipeInvented, { code = code }) end

-- ==========================================
-- REQUIREMENT: RequireRecipesKnown
-- Tracks the total volume of known recipes within a specific machinery category.
-- ==========================================
local _RequireRecipesKnown = {
	DebugDescription = function(self) return "Known: " .. self.number .. " " .. tostring(self.category) end,
	Description = function(self)
		if self.category then return GetText("require_recipes_known_category", tostring(self.number), GetText(self.category))
		else return GetText("require_recipes_known", tostring(self.number))
		end
	end,
	Evaluate = function(self, quest)
		local count = Player:GetKnownRecipeCount(self.category)
		return (count >= self.number)
	end,
	CrossCheck = function(self) if (not self.category) or (_AllCategories[self.category]) then return nil else return "UNDEFINED CATEGORY: " .. self.category end end,
}
function RequireRecipesKnown(number, category)
	number = number or 0
	return CreateObject(_RequireRecipesKnown, { number = number, category = category })
end

-- ==========================================
-- REQUIREMENT: RequireRecipesMade
-- Tracks the total volume of factory productions within a specific machinery category.
-- ==========================================
local _RequireRecipesMade = {
	DebugDescription = function(self) return "Made: " .. self.number .. " " .. tostring(self.category) end,
	Description = function(self)
		if self.category then return GetText("require_recipes_made_category", tostring(self.number), GetText(self.category))
		else return GetText("require_recipes_made", tostring(self.number))
		end
	end,
	Evaluate = function(self, quest)
		local count = Player:GetMadeRecipeCount(self.category)
		return (count >= self.number)
	end,
	CrossCheck = function(self) if (not self.category) or (_AllCategories[self.category]) then return nil else return "UNDEFINED CATEGORY: " .. self.category end end,
}
function RequireRecipesMade(number, category)
	number = number or 0
	return CreateObject(_RequireRecipesMade, { number = number, category = category })
end

-- ==========================================
-- REQUIREMENT: RequireUserCreationWithIngredient
-- Complex evaluator: Checks if a specific custom User Recipe (or any User Recipe) 
-- utilizes a specific ingredient. Heavily used in the endgame judging quests.
-- ==========================================
local _RequireUserCreationWithIngredient = {
	DebugDescription = function(self)
		if self.index then
			return "Creation #" .. self.index .. " contains: " .. self.name
		else
			return "Any creation contains: " .. self.name
		end
	end,
	Description = function(self)
		if self.index then
			local prod = GetProductByCode("user" .. self.index)
			local prodName = prod and prod:GetName() or GetString("ugr_generic")
			return GetText("require_creation_has_ingredient_specific", prodName, GetText(self.name))
		else
			return GetText("require_creation_has_ingredient_any", GetText(self.name))
		end
	end,
	Evaluate = function(self, quest)
		if self.index then
			-- Mode A: Check a specific explicitly requested UGR
			local codeTable = Player.itemRecipes[self.index]
			if not codeTable then return false end
			
			local ingCode = _AllIngredients[self.name].code
			-- Scan the recipe signature (Skipping index 1 as it holds the category string)
			for i = 2, table.getn(codeTable) do
				if codeTable[i] == ingCode then return true end
			end
			return false
		else
			-- Mode B: Scan ALL existing UGRs on the player's profile
			for _, codeTable in ipairs(Player.itemRecipes) do
				local ingCode = _AllIngredients[self.name].code
				for i = 2, table.getn(codeTable) do
					if codeTable[i] == ingCode then return true end
				end
			end
			return false
		end
	end,
	CrossCheck = function(self)
		if not _AllIngredients[self.name] then return "UNDEFINED INGREDIENT: " .. self.name end
		return nil
	end
}
function RequireUserCreationWithIngredient(ingredientName, userRecipeIndex)
	return CreateObject(_RequireUserCreationWithIngredient, { name = ingredientName, index = userRecipeIndex })
end

-------------------------------------------------------------------------------
-- Port Unlocks & Map Geometry
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardUnlockPort
-- Un-fogs a port on the world map, allowing the player to travel there.
-- ==========================================
local _UnlockPort = {
	Description = function(self) return "Unlock " .. GetString(self.name) end,
	Apply = function(self)
		local port = _AllPorts[self.name]
		port:Unlock()
		return true
	end,
	CrossCheck = function(self) if _AllPorts[self.name] then return nil else return "UNDEFINED PORT: " .. self.name end end
}
function AwardUnlockPort(name)
	if _AllPorts[name] then return CreateObject(_UnlockPort, { name = name })
	else DebugOut("ERROR", string.format("Attempted to unlock undefined port mapping: '%s'", tostring(name)))
	end
end

-- ==========================================
-- REQUIREMENT: RequirePort
-- Validates that the player has discovered a port.
-- ==========================================
local _PortAvailable = {
	Description = function(self) return "Unlocked: " .. self.name end,
	Evaluate = function(self, quest)
		local port = _AllPorts[self.name]
		return port:IsAvailable()
	end,
	CrossCheck = function(self) if _AllPorts[self.name] then return nil else return "UNDEFINED PORT: " .. self.name end end
}
function RequirePort(name)
	if _AllPorts[name] then return CreateObject(_PortAvailable, { name = name }) end
end

-- ==========================================
-- REQUIREMENT: RequirePlayerInPort
-- Triggers goals strictly when the player lands in a specific city.
-- ==========================================
local _RequirePlayerInPort = {
	DebugDescription = function(self) return "Player is in: " .. self.name end,
	Evaluate = function(self, quest)
		return Player.portName == self.name
	end,
	CrossCheck = function(self) if _AllPorts[self.name] then return nil else return "UNDEFINED PORT: " .. self.name end end
}
function RequirePlayerInPort(name) return CreateObject(_RequirePlayerInPort, { name = name }) end

-------------------------------------------------------------------------------
-- Market Supply Flow (Ingredients)
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardUnlockIngredient
-- Forces an ingredient to begin spawning naturally in its assigned markets.
-- ==========================================
local _UnlockIngredient = {
	Description = function(self) return "Unlock " .. tostring(self.name) end,
	Apply = function(self)
		local ing = _AllIngredients[self.name]
		ing:Unlock()
		
		-- Automatically add the unlocked ingredient to the player's encyclopedia catalogue
		Player.catalogue.unlockedIngredients[self.name] = true
		DebugOut("PLAYER", string.format("Applying reward: Unlocking map presence and catalogue entry for '%s'.", self.name))
		return true
	end,
}
function AwardUnlockIngredient(name)
	if _AllIngredients[name] then return CreateObject(_UnlockIngredient, { name = name }) end
end

-- ==========================================
-- REWARD: AwardLockIngredient
-- Confiscates an ingredient from the global map, preventing it from spawning in shops.
-- Useful for famine/shortage questlines.
-- ==========================================
local _LockIngredient = {
	Description = function(self) return "Lock " .. tostring(self.name) end,
	Apply = function(self)
		local ing = _AllIngredients[self.name]
		ing:Lock()
		
		-- Scrub the ingredient from the encyclopedia so the player cannot reference it
		Player.catalogue.unlockedIngredients[self.name] = nil
		DebugOut("PLAYER", string.format("Applying reward: Locking and removing catalogue entry for '%s'.", self.name))
		return true
	end,
}
function AwardLockIngredient(name)
	if _AllIngredients[name] then return CreateObject(_LockIngredient, { name = name }) end
end

-- ==========================================
-- REQUIREMENT: RequireIngredientAvailable / Unavailable
-- Checks the global lock state of an ingredient.
-- ==========================================
local _IngredientAvailable = {
	DebugDescription = function(self) return "Available: " .. self.name end,
	Description = function(self) return "AVAILABLE: " .. GetString(self.name) end,
	Evaluate = function(self, quest)
		local ing = _AllIngredients[self.name]
		return ing:IsAvailable()
	end,
}
function RequireIngredientAvailable(name)
	if _AllIngredients[name] then return CreateObject(_IngredientAvailable, { name = name }) end
end

local _IngredientUnavailable = {
	DebugDescription = function(self) return "Unavailable: " .. self.name end,
	Description = function(self) return "UNAVAILABLE: " .. GetString(self.name) end,
	Evaluate = function(self, quest)
		local ing = _AllIngredients[self.name]
		return (not ing:IsAvailable())
	end,
}
function RequireIngredientUnavailable(name)
	if _AllIngredients[name] then return CreateObject(_IngredientUnavailable, { name = name }) end
end

-------------------------------------------------------------------------------
-- Character Moods & Haggling Manipulators
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardHappiness
-- Adjusts an NPC's emotional state, making them friendlier or angrier.
-- ==========================================
local _AwardHappiness = {
	type = "AwardHappiness",
	Description = function(self) return tostring(self.name) .. ": happiness +" .. tostring(self.amount) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Adjusting happiness modifier for %s by %+d.", self.name, self.amount))
		_AllCharacters[self.name]:BumpHappiness(self.amount)
		return true
	end,
}
function AwardHappiness(name, amount)
	if _AllCharacters[name] then return CreateObject(_AwardHappiness, { name = name, amount = amount }) end
end

-- ==========================================
-- REWARD: AwardHaggleSuccess
-- Guarantees the player will instantly succeed on their very next haggle attempt with an NPC.
-- Used to reward players for completing favors for merchants.
-- ==========================================
local _AwardHaggleSuccess = {
	DebugDescription = function(self) return "Force Haggle Success: " .. self.name end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Forcing absolute success on next haggle sequence with %s.", self.name))
		Player.questVariables.forceHaggle = self.name
		return true
	end,
}
function AwardHaggleSuccess(characterName) return CreateObject(_AwardHaggleSuccess, { name = characterName }) end

-------------------------------------------------------------------------------
-- Character Placement (Dynamic Map Overrides)
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardPlaceCharacter
-- Forces a character to spawn inside a specific building, overriding their natural map geometry.
-- ==========================================
local _AwardPlaceCharacter = {
	Description = function(self) return "Place " .. tostring(self.char) .. " in " .. tostring(self.building) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Overriding geometry map and placing '%s' in '%s'.", self.char, self.building))
		Player.buildingCharacters[self.building] = Player.buildingCharacters[self.building] or {}
		Player.buildingCharacters[self.building][self.char] = true
		return true
	end
}
function AwardPlaceCharacter(characterName, buildingName)
	return CreateObject(_AwardPlaceCharacter, { char = characterName, building = buildingName })
end

-- ==========================================
-- REWARD: AwardRemoveCharacter
-- Releases a character from a forced map override, returning them to their natural schedule.
-- ==========================================
local _AwardRemoveCharacter = {
	Description = function(self) return "Remove " .. tostring(self.char) .. " from " .. tostring(self.building) end,
	Apply = function(self)
		if Player.buildingCharacters[self.building] then
			DebugOut("QUEST", string.format("Applying reward: Un-assigning character '%s' from override building '%s'.", self.char, self.building))
			Player.buildingCharacters[self.building][self.char] = nil
		end
		return true
	end
}
function AwardRemoveCharacter(characterName, buildingName)
	return CreateObject(_AwardRemoveCharacter, { char = characterName, building = buildingName })
end

-- ==========================================
-- REQUIREMENT: RequireCharacterInBuilding
-- Verifies the physical presence of an NPC at a location before triggering a quest.
-- ==========================================
local _RequireCharacterInBuilding = {
	DebugDescription = function(self) return "Char " .. self.char .. " in " .. self.building end,
	Evaluate = function(self, quest)
		local building = _AllBuildings[self.building]
		if not building then return false end
		
		local charList = building:GetCharacterList()
		for _, char in ipairs(charList) do
			if char.name == self.char then return true end
		end
		return false
	end,
	CrossCheck = function(self)
		if not _AllCharacters[self.char] then return "UNDEFINED CHARACTER: " .. self.char end
		if not _AllBuildings[self.building] then return "UNDEFINED BUILDING: " .. self.building end
		return nil
	end
}
function RequireCharacterInBuilding(characterName, buildingName) 
	return CreateObject(_RequireCharacterInBuilding, { char = characterName, building = buildingName }) 
end

-------------------------------------------------------------------------------
-- Industrial Infrastructure Modifications
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardFactoryPowerup
-- Grants a permanent buff/enhancement to a specific factory (e.g. speed boosts).
-- ==========================================
local _AwardFactoryPowerup = {
	Description = function(self) return "Powerup: " .. tostring(self.building) .. "-" .. tostring(self.category) .. "-" .. tostring(self.key) end,
	Apply = function(self)
		local building = self.building
		local category = self.category
		
		if type(building) == "string" then building = _AllBuildings[building] end
		if type(category) == "string" then category = _AllCategories[category] end
		
		building:EnablePowerup(category, self.key)
		return true
	end
}
function AwardFactoryPowerup(building, category, key)
	return CreateObject(_AwardFactoryPowerup, { key = key, category = category, building = building })
end

-- ==========================================
-- REWARD: AwardFactoryStop / AwardFactoryReconfigure
-- Sabotages or alters the player's active production lines via scripted quest events.
-- ==========================================
local _AwardFactoryStop = {
	DebugDescription = function(self) return "Stop Factory: " .. self.name end,
	Apply = function(self)
		if Player.factories[self.name] then
			DebugOut("QUEST", string.format("Applying reward: Terminating active production lines at factory '%s'.", self.name))
			Player.factories[self.name].production = 0
			Player:UpdateNeeds()
		end
		return true
	end,
	CrossCheck = function(self) if _AllBuildings[self.name] and _AllBuildings[self.name].type == "factory" then return nil else return "UNDEFINED FACTORY: " .. self.name end end
}
function AwardFactoryStop(factoryName) return CreateObject(_AwardFactoryStop, { name = factoryName }) end

local _AwardFactoryReconfigure = {
	DebugDescription = function(self) return "Reconfig " .. self.factory .. " to " .. self.product end,
	Apply = function(self)
		local factory = _AllBuildings[self.factory]
		local product = _AllProducts[self.product]
		if factory and product then
			DebugOut("QUEST", string.format("Applying reward: Reconfiguring '%s' pipeline to build '%s'.", self.factory, product:GetName()))
			factory:SetProduction(product, 0)
		end
		return true
	end,
	CrossCheck = function(self)
		if not (_AllBuildings[self.factory] and _AllBuildings[self.factory].type == "factory") then return "UNDEFINED FACTORY: " .. self.factory end
		if not _AllProducts[self.product] then return "UNDEFINED PRODUCT: " .. self.product end
		return nil
	end
}
function AwardFactoryReconfigure(factoryName, productCode) return CreateObject(_AwardFactoryReconfigure, { factory = factoryName, product = productCode }) end

-- ==========================================
-- REWARDS/REQUIREMENTS: Building Ownership states
-- Checks or forces the player's possession of a commercial/industrial building.
-- ==========================================
local _AwardBuildingOwned = {
	Description = function(self) return "Own " .. tostring(self.name) end,
	Apply = function(self)
		local building = self.name
		if type(building) == "string" then building = _AllBuildings[building] end
		if building then building:MarkOwned() end
		return true
	end
}
function AwardBuildingOwned(name)
	return CreateObject(_AwardBuildingOwned, { name = name })
end


local _RequireBuildingOwned = {
	DebugDescription = function(self) return "Owned: " .. self.name end,
	Evaluate = function(self, quest)
		local building = self.name
		if type(building) == "string" then building = _AllBuildings[building] end
		return (building and building:IsOwned()) or false
	end,
}
function RequireBuildingOwned(name)
	return CreateObject(_RequireBuildingOwned, { name = name })
end

local _RequireFactoriesOwned = {
	DebugDescription = function(self) return "Factories owned: " .. self.count end,
	Evaluate = function(self, quest)
		return (Player.factoriesOwned >= self.count)
	end,
}
function RequireFactoriesOwned(count)
	return CreateObject(_RequireFactoriesOwned, { count = count })
end

local _RequireShopsOwned = {
	DebugDescription = function(self) return "Shops owned: " .. self.count end,
	Description = function(self)
		if self.count == 1 then return GetString("require_shop_single")
		else return GetText("require_shops", tostring(self.count))
		end
	end,
	Evaluate = function(self, quest)
		return (Player.shopsOwned >= self.count)
	end,
}
function RequireShopsOwned(count)
	return CreateObject(_RequireShopsOwned, { count = count })
end

-- ==========================================
-- REWARDS: Building UI Blockers
-- Locks the player out of interacting with a building (e.g., closing the market for a holiday).
-- ==========================================
local _BlockBuilding = {
	Description = function(self) return "Block Building: " .. self.name end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Blocking player UI access to '%s'.", self.name))
		Player.buildingsBlocked[self.name] = true
		return true
	end,
}
function AwardBlockBuilding(name) return CreateObject(_BlockBuilding, { name = name }) end

local _UnblockBuilding = {
	Description = function(self) return "Un-block Building: " .. self.name end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Restoring player UI access to '%s'.", self.name))
		Player.buildingsBlocked[self.name] = nil
		return true
	end,
}
function AwardUnblockBuilding(name) return CreateObject(_UnblockBuilding, { name = name }) end

-------------------------------------------------------------------------------
-- Temporal Delays & Timeline Logic
-------------------------------------------------------------------------------

-- ==========================================
-- REQUIREMENT: RequireAbsoluteTime / RelativeTime
-- Prevents a quest from executing until a specific target date is reached.
-- ==========================================
local _AbsoluteTime = {
	DebugDescription = function(self) return "Absolute Time: " .. self.time end,
	Description = function(self)
		if self.show then return GetText("require_date", Date(self.time)) else return nil end
	end,
	Evaluate = function(self, quest)
		-- Map into the global waiting tracker
		Player.questsWaiting[quest.name] = self.time
		return Player.time >= self.time
	end,
}
function RequireAbsoluteTime(time, show)
	local showit = show
	if showit ~= false then showit = true end
	return CreateObject(_AbsoluteTime, { time = time, show = showit })
end

local _RelativeTime = {
	DebugDescription = function(self) return "Time Passed: " .. self.time end,
	Description = function(self, quest)
		local startTime = Player.questsActive[quest.name] or Player.time
		if self.show then return GetText("require_date", Date(startTime + self.time)) else return nil end
	end,
	Evaluate = function(self, quest)
		local startTime = Player.questsActive[quest.name] or Player.time
		Player.questsWaiting[quest.name] = startTime + self.time
		return Player.time >= startTime + self.time
	end,
}
function RequireRelativeTime(time, show)
	local showit = show
	if showit ~= false then showit = true end
	return CreateObject(_RelativeTime, { time = time, show = showit })
end

-- ==========================================
-- REQUIREMENT: Cooldown Trackers (NoOffers, NoAccepts, NoCompletes, NoActives)
-- Prevents the game from spamming the player with too many quests at once.
-- ==========================================
local _NoOffers = {
	DebugDescription = function(self) return "Quest Offer Time: " .. self.time end,
	Evaluate = function(self, quest) return Player.time >= Player.lastOfferTime + self.time end,
}
function RequireNoOffers(ticks) return CreateObject(_NoOffers, { time = ticks }) end

local _NoAccepts = {
	DebugDescription = function(self) return "Quest Accept Time: " .. self.time end,
	Evaluate = function(self, quest) return Player.time >= Player.lastAcceptTime + self.time end,
}
function RequireNoAccepts(ticks) return CreateObject(_NoAccepts, { time = ticks }) end

local _NoCompletes = {
	DebugDescription = function(self) return "Quest Complete Time: " .. self.time end,
	Evaluate = function(self, quest) return Player.time >= Player.lastCompleteTime + self.time end,
}
function RequireNoCompletes(ticks) return CreateObject(_NoCompletes, { time = ticks }) end

local _NoActives = {
	DebugDescription = function(self) return "No Quests Active" end,
	Evaluate = function(self, quest)
		local n = 0
		for name, time in pairs(Player.questsActive) do n = n + 1 end
		return (n == 0)
	end,
}
function RequireNoQuestsActive() return _NoActives end

-------------------------------------------------------------------------------
-- Meta-Quest Controls (Skipping, Disabling)
-------------------------------------------------------------------------------

-- Toggles the entire quest generation engine globally.
function AwardEnableQuests()
	return {
		DebugDescription = function(self) return "Enable Quests" end,
		Apply = function(self) Player.options.noQuests = nil; return true; end,
	}
end

function AwardDisableQuests()
	return {
		DebugDescription = function(self) return "Disable Quests" end,
		Apply = function(self) Player.options.noQuests = true; return true; end,
	}
end

-- ==========================================
-- REWARD: AwardQuestSkip
-- Immediately forces a completely different quest to register as "Completed".
-- ==========================================
local _AwardQuestSkip = {
	DebugDescription = function(self) return "Skip Quest: " .. self.name end,
	Apply = function(self)
		if _AllQuests[self.name] then
			DebugOut("QUEST", string.format("Applying reward: Forcing completion override flag for '%s'.", self.name))
			Player.questsComplete[self.name] = Player.time
			Player.questsActive[self.name] = nil
		end
		return true
	end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST TO SKIP: " .. self.name end end
}
function AwardQuestSkip(questName) return CreateObject(_AwardQuestSkip, { name = questName }) end

-- ==========================================
-- REQUIREMENT: Sequence Locks
-- Requires another quest to be active, complete, or un-started before proceeding.
-- ==========================================
local _QuestComplete = {
	DebugDescription = function(self) return "Complete: " .. self.name end,
	Evaluate = function(self, quest) return Player.questsComplete[self.name] end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: " .. self.name end end
}
function RequireQuestComplete(quest) return CreateObject(_QuestComplete, { name = quest }) end


local _QuestActive = {
	DebugDescription = function(self) return "Active: " .. self.name end,
	Evaluate = function(self, quest) return Player.questsActive[self.name] end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: " .. self.name end end
}
function RequireQuestActive(quest) return CreateObject(_QuestActive, { name = quest }) end


local _QuestNotActive = {
	DebugDescription = function(self) return "NOT Active: " .. self.name end,
	Evaluate = function(self, quest) return (Player.questsActive[self.name] == nil) end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: " .. self.name end end
}
function RequireQuestNotActive(quest) return CreateObject(_QuestNotActive, { name = quest }) end


local _QuestIncomplete = {
	DebugDescription = function(self) return "Incomplete: " .. self.name end,
	Evaluate = function(self, quest)
		local tf = (Player.questsComplete[self.name] == nil)
		return tf
	end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: " .. self.name end end
}
function RequireQuestIncomplete(quest)
	if type(quest) == "table" then
		DebugOut("ERROR", string.format("BAD QUEST NAME in RequireQuestIncomplete -- Table passed instead of string. Could be %s", tostring(quest[1])))
	end
	return CreateObject(_QuestIncomplete, { name = quest })
end

-------------------------------------------------------------------------------
-- Special Delivery / Telegram Routing Constraints
-------------------------------------------------------------------------------

-- Detects if a character is part of the transient map pools (Wanderers / Empties)
-- instead of a permanent shopkeeper or resident.
function IsCharacterNonResident(charName)
	if not charName then return false end
	
	for _, travName in ipairs(_TravelCharacters) do
		if travName == charName then return true end
	end
	
	for _, emptyName in ipairs(_EmptyCharacters) do
		if emptyName == charName then return true end
	end
	
	return false
end

-- ==========================================
-- REWARDS: Order Banning
-- Blacklists or Whitelists specific characters or buildings from receiving randomized
-- telegram special delivery orders, preventing quest conflicts.
-- ==========================================
local _AwardEnableOrderForChar = {
	DebugDescription = function(self) return "Enable Orders for: " .. self.name end,
	Description = function(self) return "Enable Orders for: " .. self.name end, 
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Un-banning '%s' from receiving future special orders.", self.name))
		Player.orderBannedChars[self.name] = nil
		Player.orderEligibleChars[self.name] = true
		return true
	end,
}
function AwardEnableOrderForChar(charName) return CreateObject(_AwardEnableOrderForChar, { name = charName }) end

local _AwardDisableOrderForChar = {
	DebugDescription = function(self) return "Disable Orders for: " .. self.name end,
	Description = function(self) return "Disable Orders for: " .. self.name end, 
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Banning '%s' from receiving future special orders.", self.name))
		Player.orderBannedChars[self.name] = true
		Player.orderEligibleChars[self.name] = nil
		return true
	end,
}
function AwardDisableOrderForChar(charName) return CreateObject(_AwardDisableOrderForChar, { name = charName }) end

local _AwardEnableOrderForBuilding = {
	DebugDescription = function(self) return "Enable Orders at: " .. self.name end,
	Description = function(self) return "Enable Orders at: " .. self.name end, 
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Un-banning '%s' from hosting future special orders.", self.name))
		Player.orderBannedBuildings[self.name] = nil
		return true
	end,
}
function AwardEnableOrderForBuilding(buildingName) return CreateObject(_AwardEnableOrderForBuilding, { name = buildingName }) end

local _AwardDisableOrderForBuilding = {
	DebugDescription = function(self) return "Disable Orders at: " .. self.name end,
	Description = function(self) return "Disable Orders at: " .. self.name end, 
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Banning '%s' from hosting future special orders.", self.name))
		Player.orderBannedBuildings[self.name] = true
		return true
	end,
}
function AwardDisableOrderForBuilding(buildingName) return CreateObject(_AwardDisableOrderForBuilding, { name = buildingName }) end

-- ==========================================
-- REQUIREMENT: Activity Verification
-- Scans both the active quest list AND the pending telegram queue to ensure 
-- an NPC/Building is completely free before assigning them a new mission.
-- ==========================================
local _RequireCharHasNoActiveOrder = {
	DebugDescription = function(self) return "Char " .. self.name .. " has NO active order" end,
	Evaluate = function(self, quest)
		if Player.pendingSpecialOrders then
			for _, order in ipairs(Player.pendingSpecialOrders) do
				if order.ender == self.name then return false end
			end
		end

		for questName, _ in pairs(Player.questsActive) do
			local activeQuest = _AllQuests[questName]
			if activeQuest and activeQuest.delivery and activeQuest:GetEnderName() == self.name then
				return false
			end
		end
		
		return true
	end,
	CrossCheck = function(self) if _AllCharacters[self.name] then return nil else return "UNDEFINED CHARACTER: " .. self.name end end
}
function RequireCharHasNoActiveOrder(charName) return CreateObject(_RequireCharHasNoActiveOrder, { name = charName }) end

local _RequireBuildingHasNoActiveOrder = {
	DebugDescription = function(self) return "Building " .. self.name .. " has NO active order" end,
	Evaluate = function(self, quest)
		if Player.pendingSpecialOrders then
			for _, order in ipairs(Player.pendingSpecialOrders) do
				if order.endbuilding == self.name then return false end
			end
		end

		for questName, _ in pairs(Player.questsActive) do
			local activeQuest = _AllQuests[questName]
			if activeQuest and activeQuest.endbuilding == self.name then
				-- Fail if there's a dynamic procedural delivery actively running here
				if activeQuest.delivery then return false end
				
				-- Fail if a transient wanderer NPC has been locked here by a scripted quest
				local enderName = activeQuest:GetEnderName()
				if enderName and IsCharacterNonResident(enderName) then return false end
			end
		end
		
		return true
	end,
	CrossCheck = function(self) if _AllBuildings[self.name] then return nil else return "UNDEFINED BUILDING: " .. self.name end end
}
function RequireBuildingHasNoActiveOrder(buildingName) return CreateObject(_RequireBuildingHasNoActiveOrder, { name = buildingName }) end

local _RequireCharOrdersDisabled = {
	DebugDescription = function(self) return "Orders disabled for: " .. self.name end,
	Evaluate = function(self, quest) return Player.orderBannedChars[self.name] == true end,
	CrossCheck = function(self) if _AllCharacters[self.name] then return nil else return "UNDEFINED CHARACTER: " .. self.name end end
}
function RequireCharOrdersDisabled(charName) return CreateObject(_RequireCharOrdersDisabled, { name = charName }) end

local _RequireCharOrdersEnabled = {
	DebugDescription = function(self) return "Orders enabled for: " .. self.name end,
	Evaluate = function(self, quest) return Player.orderBannedChars[self.name] ~= true end,
	CrossCheck = function(self) if _AllCharacters[self.name] then return nil else return "UNDEFINED CHARACTER: " .. self.name end end
}
function RequireCharOrdersEnabled(charName) return CreateObject(_RequireCharOrdersEnabled, { name = charName }) end

-------------------------------------------------------------------------------
-- Internal Custom State Variables
-------------------------------------------------------------------------------

-- ==========================================
-- REWARDS: Variable Mutation
-- Directly adjusts custom integer flags in the Player's quest state dictionary.
-- ==========================================
local _SetVariable = {
	Description = function(self) return "Set Var: " .. tostring(self.name) .. " = " .. tostring(self.value) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Modifying system variable '%s' to %s", self.name, tostring(self.value)))
		Player.questVariables[self.name] = self.value
		return true
	end,
}
function SetVariable(name, value)
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_SetVariable, { name = lname, value = value })
end

local _IncVariable = {
	Description = function(self) return "Increment Var: " .. tostring(self.name) end,
	Apply = function(self)
		local n = Player.questVariables[self.name] or 0
		DebugOut("QUEST", string.format("Applying reward: Incrementing system variable '%s' to %d", self.name, (n + 1)))
		Player.questVariables[self.name] = n + 1
		return true
	end,
}
function IncrementVariable(name)
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_IncVariable, { name = lname })
end

-- ==========================================
-- REQUIREMENTS: Variable Evaluation
-- Validates the current integer state of a quest variable.
-- ==========================================
local _VarEqual = {
	DebugDescription = function(self) return "Var: " .. self.name .. " = " .. self.value end,
	Evaluate = function(self, quest) return (Player.questVariables[self.name] == self.value) end,
}
function RequireVariableEqual(name, value)
	local lname = string.lower(name)
	return CreateObject(_VarEqual, { name = lname, value = value })
end

local _VarLessThan = {
	DebugDescription = function(self) return "Var: " .. self.name .. " < " .. self.value end,
	Evaluate = function(self, quest)
		local n = Player.questVariables[self.name] or 0
		return (n < self.value)
	end,
}
function RequireVariableLessThan(name, value)
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_VarLessThan, { name = lname, value = value })
end

local _VarMoreThan = {
	DebugDescription = function(self) return "Var: " .. self.name .. " > " .. self.value end,
	Evaluate = function(self, quest)
		local n = Player.questVariables[self.name] or 0
		return (n > self.value)
	end,
}
function RequireVariableMoreThan(name, value)
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_VarMoreThan, { name = lname, value = value })
end

-------------------------------------------------------------------------------
-- Medals & Trophies
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardMedal
-- Triggers a global trophy unlock popup and plays the achievement fanfare.
-- ==========================================
local _AwardMedal = {
	DebugDescription = function(self) return "Medal: " .. self.key end,
	Description = function(self) return GetText("award_medal", GetText(self.key)) end,
	Apply = function(self)
		DebugOut("QUEST", string.format("Applying reward: Generating trophy medal object '%s'.", self.key))
		Player:AwardMedal(self.key)
		return true
	end,
}
function AwardMedal(key) return CreateObject(_AwardMedal, { key = key }) end

local _RequireMedal = {
	DebugDescription = function(self) return "Medal: " .. self.key end,
	Description = function(self) return GetText("require_medal", GetText(self.key)) end,
	Evaluate = function(self, quest) return (Player.medals[self.key] ~= nil) end,
}
function RequireMedal(key) return CreateObject(_RequireMedal, { key = key }) end

-------------------------------------------------------------------------------
-- Custom Recipe Slot Configuration
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardCustomSlot
-- Expands the player's capacity to create new custom UGRs in the Test Kitchen.
-- ==========================================
local _AwardCustomSlot = {
	Description = function(self) return tostring(self.n) .. " Recipe Slot(s)" end,
	Apply = function(self)
		local n = (Player.customSlots or 0) + self.n
		DebugOut("QUEST", string.format("Applying reward: Upgraded UGR cap by %d. New maximum allowed slots: %d", self.n, n))
		
		Player.customSlots = n
		Player.questVariables.ugr_slots = n - (Player.categoryCount.user or 0)
		
		-- Reset UI pointers so the recipe book recognizes the new empty slot
		gRecipeSelection = nil
		gCategorySelection = _AllCategories.user
		return true
	end,
}
function AwardCustomSlot(n) return CreateObject(_AwardCustomSlot, { n = n or 1 }) end

-------------------------------------------------------------------------------
-- UI Hooks & Text Triggers
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardText
-- Forces an NPC to speak an arbitrary string, bypassing standard dialogue pools.
-- Essential for narrative exposition or handing over quest items visually.
-- ==========================================
local _AwardText = {
	Description = function(self) return "Text: " .. self.key end,
	Apply = function(self, iterator)
		local lastChar = gActiveCharacter
		local quest = self.quest
		local text

		if quest then
			-- Supports context-sensitive {token} replacements mapped to this specific quest
			text = quest:GetDynamicExtraTextString(self.key, self.char)
		else
			DebugOut("ERROR", "AwardText was executed without a valid quest object reference. Cannot perform dynamic replacements.")
			text = GetString(self.key) 
		end

		DisplayDialog { 
			"ui/ui_character_generic.lua", 
			text = "#" .. text, 
			char = self.char,
			ok = self.ok_label,
			ok_length = self.ok_length,
			mood = self.mood
		}

		gActiveCharacter = lastChar
		return true, true
	end,
}

function AwardText(key, char, options)
	options = options or {}
	local quest_context = _AllQuests[gCurrentQuestBeingBuilt]

	return CreateObject(_AwardText, { 
		key = key, 
		char = char,
		quest = quest_context, 
		ok_label = options.label,
		ok_length = options.length,
		mood = options.mood
	})
end

-- ==========================================
-- REWARD: AwardDialog
-- Programmatically launches a UI screen (Inventory, Recipe Book, Quest Log).
-- ==========================================
local _AwardDialog = {
	Description = function(self) return "Show: " .. tostring(self.key) end,
	Apply = function(self, iterator)
		if self.key == "inventory" then DisplayDialog{"ui/inventory.lua"}
		elseif self.key == "recipes" then DisplayDialog{"ui/ui_recipes.lua"}
		elseif self.key == "quests" then DisplayDialog {"ui/ui_questlog.lua"}
		elseif self.key == "medals" then DisplayDialog {"ui/ui_medals.lua"}
		elseif self.key == "catalogue" then DisplayDialog {"ui/ui_catalogue.lua"}
		elseif self.key == "sign" then DisplayDialog {"ui/sign_basic.lua"}
		end
		return true, true
	end,
}
function AwardDialog(key) return CreateObject(_AwardDialog, { key = key }) end

-- ==========================================
-- REWARD: AwardOfferQuest / AwardDelayQuest
-- Programmatically chains quests together without requiring an NPC trigger.
-- ==========================================
local _AwardOfferQuest = {
	Description = function(self) return "Offer Quest: " .. self.name end,
	Apply = function(self)
		local offered = false
		local q = _AllQuests[self.name]
		if q and (not q:IsActive()) and (not q:IsComplete()) then
			q:Offer()
			offered = true
		end
		return true, offered
	end,
}
function AwardOfferQuest(name) return CreateObject(_AwardOfferQuest, { name = name }) end

local _AwardDelayQuest = {
	Description = function(self) return "Delay: " .. self.name .. " by " .. self.time end,
	Apply = function(self)
		local q = _AllQuests[self.name]
		if q and (not q:IsActive()) and (not q:IsComplete()) then
			DebugOut("QUEST", string.format("Applying reward: Setting trigger delay for quest '%s' for %d weeks.", self.name, self.time))
			Player.questsDeferred[self.name] = Player.time + self.time
		end
		return true
	end,
}
function AwardDelayQuest(name, time) return CreateObject(_AwardDelayQuest, { name = name, time = time or 1 }) end

-------------------------------------------------------------------------------
-- Catalogue & Information Discovery (Meta Progression)
-------------------------------------------------------------------------------

-- ==========================================
-- REWARD: AwardUnlockHistory
-- Unlocks a lore/encyclopedia article in the player's Catalogue UI.
-- ==========================================
local _AwardHistory = {
	DebugDescription = function(self) return "Unlock History: " .. self.key end,
	
	Description = function(self)
		local prefix = GetString("award_history_prefix")
		if prefix == "#####" or prefix == "award_history_prefix" then prefix = "New Catalogue Entry:" end
		
		return prefix .. " " .. GetString(self.key .. "_title")
	end,
	
	Apply = function(self)
		Player.catalogue.unlockedHistory = Player.catalogue.unlockedHistory or {}
		Player.catalogue.unlockedHistory[self.key] = true
		
		DebugOut("PLAYER", string.format("Applying reward: Unlocking encyclopedia history article '%s'.", self.key))
		return true
	end
}
function AwardUnlockHistory(key) return CreateObject(_AwardHistory, { key = key }) end

-- ==========================================
-- REWARD: AwardUnlockCharacter
-- Upgrades a character's catalogue entry to Stage 2 (Fully Unlocked).
-- This builds their secret preference matrices so the player can start
-- discovering their likes and dislikes dynamically.
-- ==========================================
local _AwardUnlockCharacter = {
	DebugDescription = function(self) return "Unlock Character Bio: " .. self.name end,
	Description = function(self) return "New Catalogue Entry: " .. GetString(self.name) end,
	Apply = function(self)
		local charName = self.name
		
		if not Player.catalogue.unlockedCharacters[charName] then
			Player.catalogue.unlockedCharacters[charName] = {
				met = false,
				unlocked = false,
				discovered_likes = {},
				discovered_dislikes = {},
				undiscovered_dislikes_pool = {}
			}
		end

		if not Player.catalogue.unlockedCharacters[charName].unlocked then
			-- Execute Full Stage 2 Discovery
			Player.catalogue.unlockedCharacters[charName].unlocked = true
			Player.catalogue.unlockedCharacters[charName].met = true 
			
			DebugOut("PLAYER", string.format("Applying reward: Unlocking full catalogue bio for '%s'.", charName))

			-- Calculate and populate the secret dislikes pool so they can be discovered gradually
			-- (Likes are discovered differently via the gift-giving subsystem)
			local charObject = _AllCharacters[charName]
			if charObject and charObject.dislikes then
				Player.catalogue.unlockedCharacters[charName].undiscovered_dislikes_pool = {}
				
				if charObject.dislikes.ingredients then
					for ingredientName, _ in pairs(charObject.dislikes.ingredients) do
						table.insert(Player.catalogue.unlockedCharacters[charName].undiscovered_dislikes_pool, ingredientName)
					end
				end
				if charObject.dislikes.products then
					for productCode, _ in pairs(charObject.dislikes.products) do
						table.insert(Player.catalogue.unlockedCharacters[charName].undiscovered_dislikes_pool, productCode)
					end
				end
				if charObject.dislikes.categories then
					for categoryName, _ in pairs(charObject.dislikes.categories) do
						table.insert(Player.catalogue.unlockedCharacters[charName].undiscovered_dislikes_pool, categoryName)
					end
				end
				
				DebugOut("PLAYER", string.format("Populated secret dislike discovery pool for %s with %d items.", charName, table.getn(Player.catalogue.unlockedCharacters[charName].undiscovered_dislikes_pool)))
			end
		end
		return true
	end,
}
function AwardUnlockCharacter(name) return CreateObject(_AwardUnlockCharacter, { name = name }) end

-- ==========================================
-- REWARD: AwardDiscoverPreference
-- Highly complex data-mining reward. Secretly peeks into an NPC's character data
-- and moves one of their "Likes" or "Dislikes" from the hidden matrix into
-- the player's visible Catalogue UI, allowing players to learn about them dynamically.
-- ==========================================
local _AwardDiscoverPreference = {
	DebugDescription = function(self)
		local charName = self.char and GetString(self.char) or "Random Character"
		local prefType = self.type and ("'" .. self.type .. "'") or "random preference"
		local prefItem = self.pref and (" '" .. GetString(self.pref) .. "'") or ""
		return "Discover " .. prefType .. prefItem .. " for " .. charName
	end,

	-- This is a "silent" reward. The player discovers the preference by checking their
	-- catalogue notebook, not by being explicitly told in a quest-completion popup.
	Description = function(self) return nil end,

	Apply = function(self)
		local characterToUpdate = nil
		
		-- 1. IDENTIFY TARGET CHARACTER
		if self.char then
			characterToUpdate = _AllCharacters[self.char]
		else
			-- If no character is specified, scan the entire world for a random valid character 
			-- who the player has met, but hasn't fully figured out yet.
			local eligibleChars = {}
			for charName, charData in pairs(Player.catalogue.unlockedCharacters) do
				if charData.met then
					local charObj = _AllCharacters[charName]
					if charObj and charObj.likes then 
						
						-- Tally up the total possible traits they possess
						local masterLikesCount = 0
						if charObj.likes.categories then for _ in pairs(charObj.likes.categories) do masterLikesCount = masterLikesCount + 1 end end
						if charObj.likes.products then for _ in pairs(charObj.likes.products) do masterLikesCount = masterLikesCount + 1 end end
						if charObj.likes.ingredients then for _ in pairs(charObj.likes.ingredients) do masterLikesCount = masterLikesCount + 1 end end
						
						-- Tally up what the player currently knows
						local discoveredLikesCount = 0
						if charData.discovered_likes then for _ in ipairs(charData.discovered_likes) do discoveredLikesCount = discoveredLikesCount + 1 end end
						
						local undiscoveredDislikesCount = 0
						if charData.undiscovered_dislikes_pool then for _ in ipairs(charData.undiscovered_dislikes_pool) do undiscoveredDislikesCount = undiscoveredDislikesCount + 1 end end

						-- If there is a discrepancy (meaning hidden traits exist), they are a valid target
						if discoveredLikesCount < masterLikesCount or undiscoveredDislikesCount > 0 then
							table.insert(eligibleChars, charObj)
						end
					end
				end
			end
			
			if table.getn(eligibleChars) > 0 then
				characterToUpdate = eligibleChars[RandRange(1, table.getn(eligibleChars))]
			end
		end

		if not characterToUpdate then
			DebugOut("ERROR", "AwardDiscoverPreference: Could not locate an eligible character for random trait discovery.")
			return true
		end

		-- 2. DETERMINE PREFERENCE CATEGORY (Like vs. Dislike)
		local charData = Player.catalogue.unlockedCharacters[characterToUpdate.name]
		local prefType = self.type
		
		-- If no preference type is requested, randomize between learning a Like or a Dislike.
		if not prefType then
			local hasUndiscoveredLikes = false
			local masterLikesCount = 0
			
			if characterToUpdate.likes then
				if characterToUpdate.likes.categories then for _ in pairs(characterToUpdate.likes.categories) do masterLikesCount = masterLikesCount + 1 end end
				if characterToUpdate.likes.products then for _ in pairs(characterToUpdate.likes.products) do masterLikesCount = masterLikesCount + 1 end end
				if characterToUpdate.likes.ingredients then for _ in pairs(characterToUpdate.likes.ingredients) do masterLikesCount = masterLikesCount + 1 end end
			end
			
			if charData.discovered_likes and table.getn(charData.discovered_likes) < masterLikesCount then
				hasUndiscoveredLikes = true
			end
			
			local hasUndiscoveredDislikes = charData.undiscovered_dislikes_pool and table.getn(charData.undiscovered_dislikes_pool) > 0
			
			-- Only roll the dice if BOTH types of traits are still hidden. Otherwise, force the one that remains.
			if hasUndiscoveredLikes and hasUndiscoveredDislikes then
				if RandRange(1, 2) == 1 then prefType = "like" else prefType = "dislike" end
			elseif hasUndiscoveredLikes then
				prefType = "like"
			elseif hasUndiscoveredDislikes then
				prefType = "dislike"
			else
				DebugOut("ERROR", string.format("AwardDiscoverPreference: Requested random trait generation, but %s has no remaining hidden traits.", characterToUpdate.name))
				return true 
			end
		end

		-- 3. SELECT SPECIFIC TRAIT TO REVEAL
		local preferenceToReveal = self.pref
		if not preferenceToReveal then
			local undiscovered = {}
			
			if prefType == "like" and characterToUpdate.likes then
				local masterList = {}
				if characterToUpdate.likes.categories then for k, _ in pairs(characterToUpdate.likes.categories) do table.insert(masterList, k) end end
				if characterToUpdate.likes.products then for k, _ in pairs(characterToUpdate.likes.products) do table.insert(masterList, k) end end
				if characterToUpdate.likes.ingredients then for k, _ in pairs(characterToUpdate.likes.ingredients) do table.insert(masterList, k) end end

				-- Build a temporary array of everything the player DOESN'T know yet
				for _, prefName in ipairs(masterList) do
					local found = false
					if charData.discovered_likes then
						for _, discoveredName in ipairs(charData.discovered_likes) do
							if prefName == discoveredName then found = true; break; end
						end
					end
					if not found then table.insert(undiscovered, prefName) end
				end
				
			elseif prefType == "dislike" then
				undiscovered = charData.undiscovered_dislikes_pool or {}
			end
			
			if table.getn(undiscovered) > 0 then
				preferenceToReveal = undiscovered[RandRange(1, table.getn(undiscovered))]
			end
		end

		-- 4. COMMIT THE DISCOVERY TO THE CATALOGUE UI
		if preferenceToReveal then
			local discoveredListKey = "discovered_" .. prefType .. "s"
			
			if not charData[discoveredListKey] then charData[discoveredListKey] = {} end
			
			-- Sanity check: Verify the trait isn't already known to prevent redundant duplication
			local alreadyKnown = false
			for _, knownPref in ipairs(charData[discoveredListKey]) do
				if knownPref == preferenceToReveal then alreadyKnown = true; break; end
			end

			if not alreadyKnown then
				table.insert(charData[discoveredListKey], preferenceToReveal)
				DebugOut("PLAYER", string.format("Applying reward: Discovered new %s trait for %s ('%s').", prefType, GetString(characterToUpdate.name), GetString(preferenceToReveal)))

				-- If it's a dislike, permanently pop it off the undiscovered pool list so it's never picked again.
				if prefType == "dislike" then
					for i, poolItem in ipairs(charData.undiscovered_dislikes_pool) do
						if poolItem == preferenceToReveal then
							table.remove(charData.undiscovered_dislikes_pool, i)
							break
						end
					end
				end
			else
				DebugOut("ERROR", string.format("AwardDiscoverPreference: Aborted. Trait '%s' is already known for %s.", preferenceToReveal, characterToUpdate.name))
			end
		else
			DebugOut("ERROR", string.format("AwardDiscoverPreference: Could not locate a valid undiscovered trait for %s of type %s.", characterToUpdate.name, prefType))
		end
		
		return true
	end,
	
	CrossCheck = function(self)
		if self.char and not _AllCharacters[self.char] then return "UNDEFINED CHARACTER: " .. self.char end
		if self.type and (self.type ~= "like" and self.type ~= "dislike") then return "INVALID PREFERENCE TYPE: " .. self.type end
		
		if self.pref then
			local found = _AllIngredients[self.pref] or _AllProducts[self.pref] or _AllCategories[self.pref]
			if not found then return "UNDEFINED PREFERENCE ITEM: " .. self.pref end
		end
		return nil
	end
}
function AwardDiscoverPreference(charName, preferenceType, preferenceName)
	return CreateObject(_AwardDiscoverPreference, { char = charName, type = preferenceType, pref = preferenceName })
end

-------------------------------------------------------------------------------
-- Dynamic Quest Hints
-------------------------------------------------------------------------------

-- ==========================================
-- REQUIREMENT: HintPerson
-- Dummy requirement that doesn't actually halt a quest, but attaches metadata
-- telling the Hint Engine where to direct the player.
-- ==========================================
local _HintPerson = {
	DebugDescription = function(self) return "Hint: " .. self.name end,
	Description = function(self)
		if self.port and self.building then return GetText("require_person_building_port", GetText(self.name), GetText(self.building), GetText(self.port))
		elseif self.port then return GetText("require_person_port", GetText(self.name), GetText(self.port))
		elseif self.building and self.building == "_travelers" then return GetText("require_person_travel", GetText(self.name))
		elseif self.building then return GetText("require_person_building", GetText(self.name), GetText(self.building))
		else return GetText("require_person", GetText(self.name))
		end
	end,
	Evaluate = function(self, quest) return true end,
	hint = true,
	showEnder = true,
}
function HintPerson(name, building, port)
	if type(building) == "table" then building = building.name end
	if type(port) == "table" then port = port.name end
	return CreateObject(_HintPerson, { name = name, building = building, port = port })
end

-- ==========================================
-- REQUIREMENT: HintExpirationDate / HintExpirationWeeks
-- Dummy requirements that parse the expiration metadata of a quest to inform
-- the player of their impending failure deadline dynamically.
-- ==========================================
local _HintDate = {
	DebugDescription = function(self, quest)
		local weeks = (Player.questsActive[quest.name] or Player.time) + (quest.expires or 0)
		return "Date: " .. Date(weeks)
	end,
	Description = function(self, quest)
		local weeks = (Player.questsActive[quest.name] or Player.time) + (quest.expires or 0)
		if (Player.time <= weeks) then return GetText("expire_date", Date(weeks))
		else return GetString("expire_done")
		end
	end,
	Evaluate = function(self, quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		return (weeksLeft > 0)
	end,
	hint = true,
}
function HintExpirationDate() return CreateObject(_HintDate) end


local _HintWeeks = {
	DebugDescription = function(self, quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		return "Weeks: " .. tostring(weeksLeft)
	end,
	Description = function(self, quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		
		if (weeksLeft > 1) then return GetText("expire_weeks", tostring(weeksLeft))
		elseif (weeksLeft == 1) then return GetString("expire_weeks_one")
		elseif (weeksLeft == 0) then return GetText("expire_weeks_zero", tostring(weeksLeft))
		else return GetString("expire_done")
		end
	end,
	Evaluate = function(self, quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		return (weeksLeft >= 0)
	end,
	hint = true,
}
function HintExpirationWeeks() return CreateObject(_HintWeeks) end