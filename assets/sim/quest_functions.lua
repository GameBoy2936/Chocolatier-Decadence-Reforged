--[[--------------------------------------------------------------------------
	Chocolatier Three: Quest Functions
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- HELPERS

local function GetProductByCode(code)
	local prod = _AllProducts[code]
	if not prod then
		first,last = string.find(code, "user", 1, true)
		if first then
			local i = tonumber(string.sub(code, last+1))
			local products = _AllCategories["user"].products
			if products and i <= table.getn(products) then prod = products[i] end
		end
	end
	return prod
end

------------------------------------------------------------------------------
-- MONEY

local _AwardMoney =
{
	DebugDescription = function(self) return "Cash: "..Dollars(self.money) end,
	Description = function(self) return GetText("award_money", Dollars(self.money)) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Add " .. Dollars(self.money))
        Player:AddMoney(self.money);
        return true;
    end,
}
function AwardMoney(money) return CreateObject(_AwardMoney, { money=tonumber(money) }) end

local _MinMoney =
{
	DebugDescription = function(self) return "Cash >= "..Dollars(self.money) end,
	Description = function(self) return GetText("require_min_money", Dollars(self.money)) end,
	Evaluate = function(self, quest)
        local result = (Player.money >= self.money)
			if quest:IsReal() then
				--DebugOut("QUEST", "Req for '"..quest.name.."': Have >= " .. Dollars(self.money) .. "? " .. tostring(result))
			end
        return result
    end,
}
function RequireMinMoney(money) return CreateObject(_MinMoney, { money=tonumber(money) }) end

local _MaxMoney =
{
	DebugDescription = function(self) return " Cash <= "..Dollars(self.money) end,
	Description = function(self) return GetText("require_max_money", Dollars(self.money)) end,
	Evaluate = function(self, quest)
        local result = (Player.money <= self.money)
			if quest:IsReal() then
				--DebugOut("QUEST", "Req for '"..quest.name.."': Have <= " .. Dollars(self.money) .. "? " .. tostring(result))
			end
        return result
    end,
}
function RequireMaxMoney(money) return CreateObject(_MaxMoney, { money=tonumber(money) }) end

local _RequireMoneyRange =
{
	DebugDescription = function(self) return "Cash: "..Dollars(self.min).."-"..Dollars(self.max) end,
	Description = function(self) return GetText("require_min_money", Dollars(self.min)) .. " and " .. GetText("require_max_money", Dollars(self.max)) end,
	Evaluate = function(self, quest)
        local result = (Player.money >= self.min and Player.money <= self.max)
			if quest:IsReal() then
				--DebugOut("QUEST", "Req for '"..quest.name.."': Money between " .. Dollars(self.min) .. " and " .. Dollars(self.max) .. "? " .. tostring(result))
			end
        return result
    end,
}
function RequireMoneyRange(minMoney, maxMoney) return CreateObject(_RequireMoneyRange, { min=tonumber(minMoney), max=tonumber(maxMoney) }) end

------------------------------------------------------------------------------
-- RANK

local _AwardRank =
{
	DebugDescription = function(self) return "Rank "..self.rank end,
	Description = function(self) return GetString("award_rank") end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Set Rank to " .. self.rank)
		Player:SetRank(self.rank)
		return true
	end
}
function AwardRank(rank) return CreateObject(_AwardRank, { rank=rank}) end

local _MinRank =
{
	Description = function(self) return "Rank >= "..self.rank end,
	Evaluate = function(self, quest)
        local result = (Player.rank >= self.rank)
			if quest:IsReal() then
				--DebugOut("QUEST", "Req for '"..quest.name.."': Rank >= " .. self.rank .. "? " .. tostring(result))
			end
        return result
    end,
}
function RequireMinRank(rank) return CreateObject(_MinRank, { rank=tonumber(rank) }) end

local _MaxRank =
{
	Description = function(self) return "Rank <= "..self.rank end,
	Evaluate = function(self, quest)
        local result = (Player.rank <= self.rank)
			if quest:IsReal() then
				--DebugOut("QUEST", "Req for '"..quest.name.."': Rank <= " .. self.rank .. "? " .. tostring(result))
			end
        return result
    end,
}
function RequireMaxRank(rank) return CreateObject(_MaxRank, { rank=tonumber(rank) }) end

------------------------------------------------------------------------------
-- INVENTORY

local _AwardIngredient =
{
	DebugDescription = function(self) return tostring(self.count).." sacks "..tostring(self.name) end,
	Description = function(self) return GetText("award_ingredient", tostring(self.count), GetText(self.name)) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Add " .. self.count .. " sacks of " .. self.name)
        Player:AddIngredient(self.name, self.count);
        return true;
    end,
	CrossCheck = function(self) if _AllIngredients[self.name] then return nil else return "UNDEFINED INGREDIENT: "..self.name end end
}
local _AwardProduct =
{
	DebugDescription = function(self) return tostring(self.count).." cases "..tostring(self.code) end,
	Description = function(self)
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then name = prod:GetName() end
		return GetText("award_product", tostring(self.count), name)
	end,
	Apply = function(self)
		local prod = GetProductByCode(self.code)
		if prod then
            DebugOut("QUEST", "Applying reward: Add " .. self.count .. " cases of " .. prod:GetName())
            Player:AddProduct(prod.code, self.count)
        end
		return true
	end,
}
function AwardItem(name, count)
	if _AllIngredients[name] then return CreateObject(_AwardIngredient, { name=name, count=count })
	else return CreateObject(_AwardProduct, { code=name, count=count })
	end
end

local _AwardSetInventory =
{
	DebugDescription = function(self) return "Set "..tostring(self.name).." to "..tostring(self.count) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Set inventory of '" .. self.name .. "' to " .. self.count)
		if _AllIngredients[self.name] then
			Player.ingredients[self.name] = self.count
		else
			local prod = GetProductByCode(self.name)
			if prod then Player.products[prod.code] = self.count end
		end
		Player:UpdateSupplies()
		return true;
	end,
}
function AwardSetInventory(itemName, count) return CreateObject(_AwardSetInventory, { name=itemName, count=count }) end

local _AwardRandomItem =
{
	DebugDescription = function(self) return "Award Random: "..self.category end,
	Apply = function(self)
		local cat = _AllCategories[self.category]
		if cat and table.getn(cat.products) > 0 then
			local randomIndex = RandRange(1, table.getn(cat.products))
			local randomProd = cat.products[randomIndex]
            DebugOut("QUEST", "Applying reward: Add " .. self.count .. " cases of random " .. self.category .. " (" .. randomProd:GetName() .. ")")
			Player:AddProduct(randomProd.code, self.count)
		end
		return true;
	end,
}
function AwardRandomItem(category, count) return CreateObject(_AwardRandomItem, { category=category, count=count or 1 }) end

local _RequireIngredient =
{
	DebugDescription = function(self) return tostring(self.count).." sacks "..tostring(self.name) end,
	Description = function(self)
		if self.count > 1 then return GetText("require_ingredient", tostring(self.count), GetText(self.name))
		else return GetText("require_ingredient_single", GetText(self.name))
		end
	end,
	Evaluate = function(self, quest)
		local have = Player.ingredients[self.name] or 0
		return have >= self.count
	end,
	CrossCheck = function(self) if _AllIngredients[self.name] then return nil else return "UNDEFINED INGREDIENT: "..self.name end end
}
local _RequireProduct =
{
	DebugDescription = function(self) return tostring(self.count).." cases "..tostring(self.code) end,
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
function RequireItem(name, count)
	if _AllIngredients[name] then return CreateObject(_RequireIngredient, { name=name, count=count })
	else return CreateObject(_RequireProduct, { code=name, count=count })
	end
end

------------------------------------------------------------------------------
-- RECIPES

local _AwardMachinery =
{
	DebugDescription = function(self) return "Machinery: " .. self.category .. " in " .. self.building end,
	Description = function(self) return GetText("award_machinery", GetText(self.category), GetText(self.building)) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Award " .. self.category .. " machinery to factory " .. self.building)
		Player.factories[self.building][self.category] = true
		return true
	end,
}
function AwardMachinery(category, building)
	return CreateObject(_AwardMachinery, { category=category, building=building })
end

local _AwardRecipe =
{
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
	CrossCheck = function(self) if _AllProducts[self.code] then return nil else return "UNDEFINED PRODUCT: "..self.code end end
}
function AwardRecipe(code)
	return CreateObject(_AwardRecipe, { code=code })
end

local _RequireRecipe =
{
	DebugDescription = function(self)
		return "Recipe: " .. self.code
	end,
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
		local name = self.code
		local prod = GetProductByCode(self.code)
		if prod then return Player.knownRecipes[prod.code]
		else return false
		end
	end,
}
function RequireRecipe(code)
	return CreateObject(_RequireRecipe, { code=code })
end

local _RequireLabIngredient =
{
	DebugDescription = function(self) return "Lab has: "..self.name end,
	Evaluate = function(self, quest)
		return Player.labIngredients[self.name] or false
	end,
	CrossCheck = function(self) if _AllIngredients[self.name] then return nil else return "UNDEFINED INGREDIENT: "..self.name end end
}
function RequireLabIngredient(ingredientName) return CreateObject(_RequireLabIngredient, { name=ingredientName }) end

local _RequireRecipeMade =
{
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
		return ( made >= self.count)
	end,
}
function RequireRecipeMade(code, count)
	count = count or 1
	return CreateObject(_RequireRecipeMade, { code=code, count=count })
end

function RequireUserRecipeMade(index, count)
	index = index or 1
	return RequireRecipeMade("user"..index, count)
end

local _RequireRecipeInvented =
{
	DebugDescription = function(self) return "Invent: " .. self.code end,
	Description = function(self)
		return GetString("require_recipe_invented")
	end,
	Evaluate = function(self, quest)
		local prod = GetProductByCode(self.code)
		if prod then return true
		else return false
		end
	end,
}
function RequireRecipeInvented(code)
	return CreateObject(_RequireRecipeInvented, { code=code })
end

local _RequireRecipesKnown =
{
	DebugDescription = function(self)
		return "Known: "..self.number.." "..tostring(self.category)
	end,
	Description = function(self)
		if self.category then return GetText("require_recipes_known_category", tostring(self.number), GetText(self.category))
		else return GetText("require_recipes_known", tostring(self.number))
		end
	end,
	Evaluate = function(self, quest)
		local count = Player:GetKnownRecipeCount(self.category)
		return (count >= self.number)
	end,
	CrossCheck = function(self) if (not self.category) or (_AllCategories[self.category]) then return nil else return "UNDEFINED CATEGORY: "..self.category end end,
}
function RequireRecipesKnown(number, category)
	number = number or 0
	return CreateObject(_RequireRecipesKnown, { number=number, category=category })
end

local _RequireRecipesMade =
{
	DebugDescription = function(self) return "Made: "..self.number.." "..tostring(self.category) end,
	Description = function(self)
		if self.category then return GetText("require_recipes_made_category", tostring(self.number), GetText(self.category))
		else return GetText("require_recipes_made", tostring(self.number))
		end
	end,
	Evaluate = function(self, quest)
		local count = Player:GetMadeRecipeCount(self.category)
		return (count >= self.number)
	end,
	CrossCheck = function(self) if (not self.category) or (_AllCategories[self.category]) then return nil else return "UNDEFINED CATEGORY: "..self.category end end,
}
function RequireRecipesMade(number, category)
	number = number or 0
	return CreateObject(_RequireRecipesMade, { number=number, category=category })
end

local _RequireUserCreationWithIngredient =
{
	DebugDescription = function(self)
		if self.index then
			return "Creation #"..self.index.." contains: "..self.name
		else
			return "Any creation contains: "..self.name
		end
	end,
	Description = function(self)
		if self.index then
			local prod = GetProductByCode("user"..self.index)
			local prodName = prod and prod:GetName() or GetString("ugr_generic")
			return GetText("require_creation_has_ingredient_specific", prodName, GetText(self.name))
		else
			return GetText("require_creation_has_ingredient_any", GetText(self.name))
		end
	end,
	Evaluate = function(self, quest)
		if self.index then
			-- Check a specific user recipe
			local codeTable = Player.itemRecipes[self.index]
			if not codeTable then return false end -- Player hasn't made this creation yet
			
			local ingCode = _AllIngredients[self.name].code
			for i=2, table.getn(codeTable) do -- Start at 2 to skip the category name
				if codeTable[i] == ingCode then return true end
			end
			return false
		else
			-- Check all user recipes
			for _, codeTable in ipairs(Player.itemRecipes) do
				local ingCode = _AllIngredients[self.name].code
				for i=2, table.getn(codeTable) do
					if codeTable[i] == ingCode then return true end
				end
			end
			return false
		end
	end,
	CrossCheck = function(self)
		if not _AllIngredients[self.name] then return "UNDEFINED INGREDIENT: "..self.name end
		return nil
	end
}
function RequireUserCreationWithIngredient(ingredientName, userRecipeIndex)
	return CreateObject(_RequireUserCreationWithIngredient, { name=ingredientName, index=userRecipeIndex })
end

------------------------------------------------------------------------------
-- PORTS

local _UnlockPort =
{
	Description = function(self) return "Unlock "..GetString(self.name) end,
	Apply = function(self)
		local port = _AllPorts[self.name]
		port:Unlock()
		return true
	end,
	CrossCheck = function(self) if _AllPorts[self.name] then return nil else return "UNDEFINED PORT: "..self.name end end
}
function AwardUnlockPort(name)
	if _AllPorts[name] then return CreateObject(_UnlockPort, { name=name })
	else DebugOut("UNKNOWN UNLOCK PORT: "..tostring(name))
	end
end

local _PortAvailable =
{
	Description = function(self) return "Unlocked: "..self.name end,
	Evaluate = function(self, quest)
		local port = _AllPorts[self.name]
		return port:IsAvailable()
	end,
	CrossCheck = function(self) if _AllPorts[self.name] then return nil else return "UNDEFINED PORT: "..self.name end end
}
function RequirePort(name)
	if _AllPorts[name] then return CreateObject(_PortAvailable, { name=name }) end
end

local _RequirePlayerInPort =
{
	DebugDescription = function(self) return "Player is in: "..self.name end,
	Evaluate = function(self, quest)
		return Player.portName == self.name
	end,
	CrossCheck = function(self) if _AllPorts[self.name] then return nil else return "UNDEFINED PORT: "..self.name end end
}
function RequirePlayerInPort(name) return CreateObject(_RequirePlayerInPort, { name=name }) end

------------------------------------------------------------------------------
-- AVAILABILITY

local _LockIngredient =
{
	Description = function(self) return "Lock "..tostring(self.name) end,
	Apply = function(self)
		local ing = _AllIngredients[self.name]
		ing:Lock()
        -- Remove the ingredient from the catalogue when it's locked.
        Player.catalogue.unlockedIngredients[self.name] = nil
        DebugOut("PLAYER", "Applying reward: Locking and REMOVING ingredient entry for '" .. self.name .. "'.")
		return true
	end,
}
function AwardLockIngredient(name)
	if _AllIngredients[name] then return CreateObject(_LockIngredient, { name=name }) end
end
	
local _UnlockIngredient =
{
	Description = function(self) return "Unlock "..tostring(self.name) end,
	Apply = function(self)
		local ing = _AllIngredients[self.name]
		ing:Unlock()
        -- Add the ingredient to the catalogue when it's unlocked.
        Player.catalogue.unlockedIngredients[self.name] = true
        DebugOut("PLAYER", "Applying reward: Unlocking ingredient entry for '" .. self.name .. "'.")
		return true
	end,
}
function AwardUnlockIngredient(name)
	if _AllIngredients[name] then return CreateObject(_UnlockIngredient, { name=name }) end
end

local _IngredientAvailable =
{
	DebugDescription = function(self) return "Available: "..self.name end,
	Description = function(self) return "AVAILABLE: "..GetString(self.name) end,
	Evaluate = function(self, quest)
		local ing = _AllIngredients[self.name]
		return ing:IsAvailable()
	end,
}
function RequireIngredientAvailable(name)
	if _AllIngredients[name] then return CreateObject(_IngredientAvailable, { name=name }) end
end

local _IngredientUnavailable =
{
	DebugDescription = function(self) return "Unavailable: "..self.name end,
	Description = function(self) return "UNAVAILABLE: "..GetString(self.name) end,
	Evaluate = function(self, quest)
		local ing = _AllIngredients[self.name]
		return (not ing:IsAvailable())
	end,
}
function RequireIngredientUnavailable(name)
	if _AllIngredients[name] then return CreateObject(_IngredientUnavailable, { name=name }) end
end

------------------------------------------------------------------------------
-- MOODS

local _AwardHappiness =
{
	type = "AwardHappiness",
	Description = function(self) return tostring(self.name)..": happiness +"..tostring(self.amount) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Bumping happiness for " .. self.name .. " by " .. self.amount)
        _AllCharacters[self.name]:BumpHappiness(self.amount);
        return true;
    end,
}
function AwardHappiness(name,amount)
	if _AllCharacters[name] then return CreateObject(_AwardHappiness, { name=name, amount=amount }) end
end

local _AwardHaggleSuccess =
{
	DebugDescription = function(self) return "Force Haggle Success: "..self.name end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Forcing next haggle with " .. self.name .. " to succeed.")
		Player.questVariables.forceHaggle = self.name
		return true
	end,
}
function AwardHaggleSuccess(characterName) return CreateObject(_AwardHaggleSuccess, { name=characterName }) end

------------------------------------------------------------------------------
-- CHARACTER PLACEMENT

local _AwardPlaceCharacter =
{
	Description = function(self) return "Place "..tostring(self.char).." in "..tostring(self.building) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Placing character '" .. self.char .. "' in building '" .. self.building .. "'.")
		Player.buildingCharacters[self.building] = Player.buildingCharacters[self.building] or {}
		Player.buildingCharacters[self.building][self.char] = true
		return true
	end
}
function AwardPlaceCharacter(characterName,buildingName)
	return CreateObject(_AwardPlaceCharacter, { char=characterName, building=buildingName })
end

local _AwardRemoveCharacter =
{
	Description = function(self) return "Remove "..tostring(self.char).." from "..tostring(self.building) end,
	Apply = function(self)
		if Player.buildingCharacters[self.building] then
            DebugOut("QUEST", "Applying reward: Removing character '" .. self.char .. "' from building '" .. self.building .. "'.")
			Player.buildingCharacters[self.building][self.char] = nil
		end
		return true
	end
}
function AwardRemoveCharacter(characterName,buildingName)
	return CreateObject(_AwardRemoveCharacter, { char=characterName, building=buildingName })
end

local _RequireCharacterInBuilding =
{
	DebugDescription = function(self) return "Char "..self.char.." in "..self.building end,
	Evaluate = function(self, quest)
		local building = _AllBuildings[self.building]
		if not building then return false end
		local charList = building:GetCharacterList()
		for _, char in ipairs(charList) do
			if char.name == self.char then
				return true
			end
		end
		return false
	end,
	CrossCheck = function(self)
		if not _AllCharacters[self.char] then return "UNDEFINED CHARACTER: "..self.char end
		if not _AllBuildings[self.building] then return "UNDEFINED BUILDING: "..self.building end
		return nil
	end
}
function RequireCharacterInBuilding(characterName, buildingName) return CreateObject(_RequireCharacterInBuilding, { char=characterName, building=buildingName }) end

------------------------------------------------------------------------------
-- MARKETS/SHOPS/FACTORIES

local _AwardMachine =
{
}

local _AwardFactoryPowerup =
{
	Description = function(self) return "Powerup: "..tostring(self.building).."-"..tostring(self.category).."-"..tostring(self.key) end,
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
	return CreateObject(_AwardFactoryPowerup, { key=key, category=category, building=building })
end

local _AwardFactoryStop =
{
	DebugDescription = function(self) return "Stop Factory: "..self.name end,
	Apply = function(self)
		if Player.factories[self.name] then
            DebugOut("QUEST", "Applying reward: Stopping production at factory '" .. self.name .. "'.")
			Player.factories[self.name].production = 0
			Player:UpdateNeeds()
		end
		return true
	end,
	CrossCheck = function(self) if _AllBuildings[self.name] and _AllBuildings[self.name].type == "factory" then return nil else return "UNDEFINED FACTORY: "..self.name end end
}
function AwardFactoryStop(factoryName) return CreateObject(_AwardFactoryStop, { name=factoryName }) end

local _AwardFactoryReconfigure =
{
	DebugDescription = function(self) return "Reconfig "..self.factory.." to "..self.product end,
	Apply = function(self)
		local factory = _AllBuildings[self.factory]
		local product = _AllProducts[self.product]
		if factory and product then
            DebugOut("QUEST", "Applying reward: Reconfiguring factory '" .. self.factory .. "' to " .. product:GetName())
			factory:SetProduction(product, 0)
		end
		return true
	end,
	CrossCheck = function(self)
		if not (_AllBuildings[self.factory] and _AllBuildings[self.factory].type == "factory") then return "UNDEFINED FACTORY: "..self.factory end
		if not _AllProducts[self.product] then return "UNDEFINED PRODUCT: "..self.product end
		return nil
	end
}
function AwardFactoryReconfigure(factoryName, productCode) return CreateObject(_AwardFactoryReconfigure, { factory=factoryName, product=productCode }) end

local _AwardBuildingOwned =
{
	Description = function(self) return "Own "..tostring(self.name) end,
	Apply = function(self)
		local building = self.name
		if type(building) == "string" then building = _AllBuildings[building] end
		if building then building:MarkOwned() end
		return true
	end
}
function AwardBuildingOwned(name)
	return CreateObject(_AwardBuildingOwned, { name=name })
end

local _RequireBuildingOwned =
{
	DebugDescription = function(self) return "Owned: "..self.name end,
	Evaluate = function(self, quest)
		local building = self.name
		if type(building) == "string" then building = _AllBuildings[building] end
		return (building and building:IsOwned()) or false
	end,
}
function RequireBuildingOwned(name)
	return CreateObject(_RequireBuildingOwned, { name=name })
end

local _RequireFactoriesOwned =
{
	DebugDescription = function(self) return "Factories owned: "..self.count end,
	Evaluate = function(self, quest)
		return (Player.factoriesOwned >= self.count)
	end,
}
function RequireFactoriesOwned(count)
	return CreateObject(_RequireFactoriesOwned, { count=count})
end

local _RequireShopsOwned =
{
	DebugDescription = function(self) return "Shops owned: "..self.count end,
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
	return CreateObject(_RequireShopsOwned, { count=count})
end

local _BlockBuilding =
{
	Description = function(self) return "Block Building: "..self.name end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Blocking building '" .. self.name .. "'.")
        Player.buildingsBlocked[self.name] = true;
        return true;
    end,
}
function AwardBlockBuilding(name)
	return CreateObject(_BlockBuilding, {name=name })
end

local _UnblockBuilding =
{
	Description = function(self) return "Un-block Building: "..self.name end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Unblocking building '" .. self.name .. "'.")
        Player.buildingsBlocked[self.name] = nil;
        return true;
    end,
}
function AwardUnblockBuilding(name)
	return CreateObject(_UnblockBuilding, {name=name })
end

------------------------------------------------------------------------------
-- TIME

local _AbsoluteTime =
{
	DebugDescription = function(self) return "Absolute Time: "..self.time end,
	Description = function(self)
		if self.show then return GetText("require_date", Date(self.time))
		else return nil
		end
	end,
	Evaluate = function(self,quest)
		Player.questsWaiting[quest.name] = self.time
		return Player.time >= self.time
	end,
}
function RequireAbsoluteTime(time,show)
	local showit = show
	if showit ~= false then showit = true end
	return CreateObject(_AbsoluteTime, { time=time,show=showit })
end

local _RelativeTime =
{
	DebugDescription = function(self) return "Time Passed: "..self.time end,
	Description = function(self,quest)
		local startTime = Player.questsActive[quest.name] or Player.time
		if self.show then return GetText("require_date", Date(startTime + self.time))
		else return nil
		end
	end,
	Evaluate = function(self,quest)
		local startTime = Player.questsActive[quest.name] or Player.time
		Player.questsWaiting[quest.name] = startTime + self.time
		return Player.time >= startTime + self.time
	end,
}
function RequireRelativeTime(time,show)
	local showit = show
	if showit ~= false then showit = true end
	return CreateObject(_RelativeTime, { time=time,show=showit })
end

local _NoOffers =
{
	DebugDescription = function(self) return "Quest Offer Time: "..self.time end,
	Evaluate = function(self, quest)
		return Player.time >= Player.lastOfferTime + self.time
	end,
}
function RequireNoOffers(ticks)
	return CreateObject(_NoOffers, { time=ticks })
end

local _NoAccepts =
{
	DebugDescription = function(self) return "Quest Accept Time: "..self.time end,
	Evaluate = function(self, quest)
		return Player.time >= Player.lastAcceptTime + self.time
	end,
}
function RequireNoAccepts(ticks)
	return CreateObject(_NoAccepts, { time=ticks })
end

local _NoCompletes =
{
	DebugDescription = function(self) return "Quest Complete Time: "..self.time end,
	Evaluate = function(self, quest)
		return Player.time >= Player.lastCompleteTime + self.time
	end,
}
function RequireNoCompletes(ticks)
	return CreateObject(_NoCompletes, { time=ticks })
end

local _NoActives =
{
	DebugDescription = function(self) return "No Quests Active" end,
	Evaluate = function(self, quest)
		local n = 0
		for name,time in pairs(Player.questsActive) do n = n + 1 end
		return (n == 0)
	end,
}
function RequireNoQuestsActive() return _NoActives end

------------------------------------------------------------------------------
-- QUESTS

function AwardEnableQuests()
	return
	{
		DebugDescription = function(self) return "Enable Quests" end,
		Apply = function(self) Player.options.noQuests = nil; return true; end,
	}
end

function AwardDisableQuests()
	return
	{
		DebugDescription = function(self) return "Disable Quests" end,
		Apply = function(self) Player.options.noQuests = true; return true; end,
	}
end

local _AwardQuestSkip =
{
	DebugDescription = function(self) return "Skip Quest: " .. self.name end,
	Apply = function(self)
		if _AllQuests[self.name] then
            DebugOut("QUEST", "Applying reward: Skipping quest '" .. self.name .. "'.")
			Player.questsComplete[self.name] = Player.time
			Player.questsActive[self.name] = nil
		end
		return true
	end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST TO SKIP: "..self.name end end
}
function AwardQuestSkip(questName) return CreateObject(_AwardQuestSkip, { name=questName }) end

local _QuestComplete =
{
	DebugDescription = function(self) return "Complete: "..self.name end,
	Evaluate = function(self, quest) return Player.questsComplete[self.name] end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: "..self.name end end
}
function RequireQuestComplete(quest)
	return CreateObject(_QuestComplete, { name=quest })
end

local _QuestActive =
{
	DebugDescription = function(self) return "Active: "..self.name end,
	Evaluate = function(self, quest) return Player.questsActive[self.name] end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: "..self.name end end
}
function RequireQuestActive(quest)
	return CreateObject(_QuestActive, { name=quest })
end

local _QuestNotActive =
{
	DebugDescription = function(self) return "NOT Active: "..self.name end,
	Evaluate = function(self, quest) return (Player.questsActive[self.name] == nil) end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: "..self.name end end
}
function RequireQuestNotActive(quest)
	return CreateObject(_QuestNotActive, { name=quest })
end

local _QuestIncomplete =
{
	DebugDescription = function(self) return "Incomplete: "..self.name end,
	Evaluate = function(self, quest)
		local tf = (Player.questsComplete[self.name] == nil)
		return tf
	end,
	CrossCheck = function(self) if _AllQuests[self.name] then return nil else return "UNDEFINED QUEST: "..self.name end end
}
function RequireQuestIncomplete(quest)
	if type(quest) == "table" then
		DebugOut("ERROR: BAD QUEST NAME -- using {} instead of ()? Could be "..tostring(quest[1]))
	end
	return CreateObject(_QuestIncomplete, { name=quest })
end

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

local _AwardEnableOrderForChar =
{
    DebugDescription = function(self) return "Enable Orders for: " .. self.name end,
    Description = function(self) return "Enable Orders for: " .. self.name end, -- ADD THIS LINE
    Apply = function(self)
        DebugOut("QUEST", "Applying reward: Character '" .. self.name .. "' is now ELIGIBLE for special orders.")
        Player.orderBannedChars[self.name] = nil
        Player.orderEligibleChars[self.name] = true
        return true
    end,
}
function AwardEnableOrderForChar(charName) return CreateObject(_AwardEnableOrderForChar, { name=charName }) end

local _AwardDisableOrderForChar =
{
    DebugDescription = function(self) return "Disable Orders for: " .. self.name end,
    Description = function(self) return "Disable Orders for: " .. self.name end, -- ADD THIS LINE
    Apply = function(self)
        DebugOut("QUEST", "Applying reward: Character '" .. self.name .. "' is now BANNED from special orders.")
        Player.orderBannedChars[self.name] = true
        Player.orderEligibleChars[self.name] = nil
        return true
    end,
}
function AwardDisableOrderForChar(charName) return CreateObject(_AwardDisableOrderForChar, { name=charName }) end

local _AwardEnableOrderForBuilding =
{
    DebugDescription = function(self) return "Enable Orders at: " .. self.name end,
    Description = function(self) return "Enable Orders at: " .. self.name end, -- ADD THIS LINE
    Apply = function(self)
        DebugOut("QUEST", "Applying reward: Building '" .. self.name .. "' is now ELIGIBLE for special orders.")
        Player.orderBannedBuildings[self.name] = nil
        return true
    end,
}
function AwardEnableOrderForBuilding(buildingName) return CreateObject(_AwardEnableOrderForBuilding, { name=buildingName }) end

local _AwardDisableOrderForBuilding =
{
    DebugDescription = function(self) return "Disable Orders at: " .. self.name end,
    Description = function(self) return "Disable Orders at: " .. self.name end, -- ADD THIS LINE
    Apply = function(self)
        DebugOut("QUEST", "Applying reward: Building '" .. self.name .. "' is now BANNED from special orders.")
        Player.orderBannedBuildings[self.name] = true
        return true
    end,
}
function AwardDisableOrderForBuilding(buildingName) return CreateObject(_AwardDisableOrderForBuilding, { name=buildingName }) end

local _RequireCharHasNoActiveOrder =
{
    DebugDescription = function(self) return "Char " .. self.name .. " has NO active order" end,
    Evaluate = function(self, quest)
        -- Iterate through all active quests
        for questName, _ in pairs(Player.questsActive) do
            local activeQuest = _AllQuests[questName]
            -- Check if the quest is a delivery and if the ender matches our character
            if activeQuest.delivery and activeQuest:GetEnderName() == self.name then
                -- Found an active order for this character, so the requirement fails.
                -- DebugOut("QUEST", "Req for '"..quest.name.."': Check No Active Order for " .. self.name .. "? FAILED (Active order: " .. questName .. ")")
                return false
            end
        end
        -- No active orders were found for this character, so the requirement passes.
        -- DebugOut("QUEST", "Req for '"..quest.name.."': Check No Active Order for " .. self.name .. "? PASSED")
        return true
    end,
    CrossCheck = function(self) if _AllCharacters[self.name] then return nil else return "UNDEFINED CHARACTER: "..self.name end end
}
function RequireCharHasNoActiveOrder(charName)
    return CreateObject(_RequireCharHasNoActiveOrder, { name=charName })
end

local _RequireBuildingHasNoActiveOrder =
{
    DebugDescription = function(self) return "Building " .. self.name .. " has NO active order" end,
    Evaluate = function(self, quest)
        for questName, _ in pairs(Player.questsActive) do
            local activeQuest = _AllQuests[questName]
            if activeQuest and activeQuest.endbuilding == self.name then
                -- Condition 1: It's a procedural delivery quest.
                if activeQuest.delivery then return false end
                -- Condition 2 (NEW): It's a scripted quest where a non-resident is the ender at this building.
                local enderName = activeQuest:GetEnderName()
                if enderName and IsCharacterNonResident(enderName) then return false end
            end
        end
        return true
    end,
    CrossCheck = function(self) if _AllBuildings[self.name] then return nil else return "UNDEFINED BUILDING: "..self.name end end
}
function RequireBuildingHasNoActiveOrder(buildingName)
    return CreateObject(_RequireBuildingHasNoActiveOrder, { name=buildingName })
end

------------------------------------------------------------------------------
-- QUEST VARIABLES

local _SetVariable =
{
	Description = function(self) return "Set Var: "..tostring(self.name).." = "..tostring(self.value) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Setting variable '" .. self.name .. "' to " .. tostring(self.value))
        Player.questVariables[self.name] = self.value;
        return true;
    end,
}
function SetVariable(name,value)
	local val = value
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_SetVariable, { name=lname,value=val })
end

local _IncVariable =
{
	Description = function(self) return "Increment Var: "..tostring(self.name) end,
	Apply = function(self)
		local n = Player.questVariables[self.name] or 0
        DebugOut("QUEST", "Applying reward: Incrementing variable '" .. self.name .. "' to " .. (n + 1))
		Player.questVariables[self.name] = n + 1
		return true
	end,
}
function IncrementVariable(name)
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_IncVariable, { name=lname })
end

local _VarEqual =
{
	DebugDescription = function(self) return "Var: "..self.name.." = "..self.value end,
	Evaluate = function(self, quest) return (Player.questVariables[self.name] == self.value) end,
}
function RequireVariableEqual(name,value)
	local val = value
	local lname = string.lower(name)
	return CreateObject(_VarEqual, { name=lname,value=val })
end

local _VarLessThan =
{
	DebugDescription = function(self) return "Var: "..self.name.." < "..self.value end,
	Evaluate = function(self, quest)
		local n = Player.questVariables[self.name] or 0
		return (n < self.value)
	end,
}
function RequireVariableLessThan(name,value)
	local val = value
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_VarLessThan, { name=lname,value=val })
end

local _VarMoreThan =
{
	DebugDescription = function(self) return "Var: "..self.name.." > "..self.value end,
	Evaluate = function(self, quest)
		local n = Player.questVariables[self.name] or 0
		return (n > self.value)
	end,
}
function RequireVariableMoreThan(name,value)
	local val = value
	local lname = string.lower(name)
	_AllVariableNames[name] = true
	return CreateObject(_VarMoreThan, { name=lname,value=val })
end

------------------------------------------------------------------------------
-- MEDALS

local _AwardMedal =
{
	DebugDescription = function(self) return "Medal: " .. self.key end,
	Description = function(self) return GetText("award_medal", GetText(self.key)) end,
	Apply = function(self)
        DebugOut("QUEST", "Applying reward: Awarding medal '" .. self.key .. "'.")
        Player:AwardMedal(self.key);
        return true;
    end,
}
function AwardMedal(key) return CreateObject(_AwardMedal, { key=key }) end

local _RequireMedal =
{
	DebugDescription = function(self) return "Medal: " .. self.key end,
	Description = function(self) return GetText("require_medal", GetText(self.key)) end,
	Evaluate = function(self, quest) return (Player.medals[self.key] ~= nil) end,
}
function RequireMedal(key) return CreateObject(_RequireMedal, { key=key }) end

------------------------------------------------------------------------------
-- CUSTOM SLOTS

local _AwardCustomSlot =
{
	Description = function(self) return tostring(self.n).." Recipe Slot(s)" end,
	Apply = function(self)
		local n = (Player.customSlots or 0) + self.n
        DebugOut("QUEST", "Applying reward: Awarding " .. self.n .. " custom recipe slot(s). New total: " .. n)
		Player.customSlots = n
		Player.questVariables.ugr_slots = n - (Player.categoryCount.user or 0)
		
		gRecipeSelection = nil
		gCategorySelection = _AllCategories.user
		return true
	end,
}
function AwardCustomSlot(n) return CreateObject(_AwardCustomSlot, { n=n or 1 }) end

------------------------------------------------------------------------------
-- MISC TEXT

local _AwardText =
{
	Description = function(self) return "Text: "..self.key end,
	Apply = function(self, iterator)
		local lastChar = gActiveCharacter
		local quest = self.quest
        local text

        if quest then
		    text = quest:GetDynamicExtraTextString(self.key, self.char)
        else
            DebugOut("ERROR", "AwardText was executed without a valid quest object reference!")
            text = GetString(self.key) -- Fallback to a direct, non-dynamic lookup.
        end

		DisplayDialog { 
            "ui/ui_character_generic.lua", 
            text="#"..text, 
            char=self.char,
            ok = self.ok_label,
            ok_length = self.ok_length,
            mood = self.mood
        }

		gActiveCharacter = lastChar
		return true,true
	end,
}

function AwardText(key, char, options)
    options = options or {}
    local quest_context = _AllQuests[gCurrentQuestBeingBuilt]

    return CreateObject(_AwardText, { 
        key=key, 
        char=char,
        quest = quest_context, -- Store a direct reference to the quest object.
        ok_label = options.label,
        ok_length = options.length,
        mood = options.mood
    })
end

------------------------------------------------------------------------------
-- UI

local _AwardDialog =
{
	Description = function(self) return "Show: "..tostring(self.key) end,
	Apply = function(self, iterator)
		if self.key == "inventory" then DisplayDialog{"ui/inventory.lua"}
		elseif self.key == "recipes" then DisplayDialog{"ui/ui_recipes.lua"}
		elseif self.key == "quests" then DisplayDialog {"ui/ui_questlog.lua"}
		elseif self.key == "medals" then DisplayDialog {"ui/ui_medals.lua"}
		elseif self.key == "sign" then DisplayDialog {"ui/sign_basic.lua"}
		end
		return true,true
	end,
}
function AwardDialog(key) return CreateObject(_AwardDialog, { key=key }) end

------------------------------------------------------------------------------
-- Quests

local _AwardOfferQuest =
{
	Description = function(self) return "Offer Quest: "..self.name end,
	Apply = function(self)
		local offered = false
		local q = _AllQuests[self.name]
		if q and (not q:IsActive()) and (not q:IsComplete()) then
			q:Offer()
			offered = true
		end
		return true,offered
	end,
}
function AwardOfferQuest(name) return CreateObject(_AwardOfferQuest, {name=name}) end

local _AwardDelayQuest =
{
	Description = function(self) return "Delay: "..self.name.." by "..self.time end,
	Apply = function(self)
		local q = _AllQuests[self.name]
		if q and (not q:IsActive()) and (not q:IsComplete()) then
            DebugOut("QUEST", "Applying reward: Delaying quest '" .. self.name .. "' for " .. self.time .. " weeks.")
			Player.questsDeferred[self.name] = Player.time + self.time
		end
		return true
	end,
}
function AwardDelayQuest(name, time) return CreateObject(_AwardDelayQuest, {name=name, time=time or 1}) end

------------------------------------------------------------------------------
-- Catalogue

local _AwardHistory =
{
	DebugDescription = function(self) return "Unlock History: " .. self.key end,
	Description = function(self) return "New Catalogue Entry: " .. GetString(self.key .. "_title") end,
	Apply = function(self)
        DebugOut("PLAYER", "Applying reward: Unlocking history article '" .. self.key .. "'.")
        Player.catalogue.unlockedHistory[self.key] = true;
        return true;
    end,
}
function AwardUnlockHistory(key) return CreateObject(_AwardHistory, { key=key }) end

local _AwardUnlockCharacter =
{
	DebugDescription = function(self) return "Unlock Character Bio: " .. self.name end,
	Description = function(self) return "New Catalogue Entry: " .. GetString(self.name) end,
	Apply = function(self)
        local charName = self.name
        -- Initialize the character's catalogue entry if it doesn't exist
        if not Player.catalogue.unlockedCharacters[charName] then
            Player.catalogue.unlockedCharacters[charName] = {
                met = false,
                unlocked = false,
                discovered_likes = {},
                discovered_dislikes = {},
                undiscovered_dislikes_pool = {}
            }
        end

        -- Only proceed if the bio isn't already unlocked
        if not Player.catalogue.unlockedCharacters[charName].unlocked then
            -- Set both flags to true for a full unlock (Stage 2)
            Player.catalogue.unlockedCharacters[charName].unlocked = true
            Player.catalogue.unlockedCharacters[charName].met = true -- Ensure they are also marked as 'met'
            DebugOut("PLAYER", "Applying reward: Fully unlocking character bio for '" .. charName .. "'.")

            -- Populate the undiscovered dislikes pool from the master character object
            local charObject = _AllCharacters[charName]
            if charObject and charObject.dislikes then
                -- Clear the pool first to prevent duplicates on re-load
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
                DebugOut("PLAYER", "Populated dislike pool for " .. charName .. " with " .. table.getn(Player.catalogue.unlockedCharacters[charName].undiscovered_dislikes_pool) .. " items.")
            end
        end
        return true;
    end,
}
function AwardUnlockCharacter(name) return CreateObject(_AwardUnlockCharacter, { name=name }) end

local _AwardDiscoverPreference =
{
	DebugDescription = function(self)
		-- Provides a detailed description for the developer console.
		local charName = self.char and GetString(self.char) or "Random Character"
		local prefType = self.type and ("'"..self.type.."'") or "random preference"
		local prefItem = self.pref and (" '"..GetString(self.pref).."'") or ""
		
		return "Discover "..prefType..prefItem.." for "..charName
	end,

	-- This is a "silent" reward. The player discovers the preference by checking the
	-- catalogue, not by being explicitly told in the quest log's reward section.
	-- Therefore, it should not have a player-facing description.
	Description = function(self) return nil end,

	Apply = function(self)
		local characterToUpdate = nil
		
		-- 1. DETERMINE THE TARGET CHARACTER
		if self.char then
			characterToUpdate = _AllCharacters[self.char]
		else
			-- Find a random character who has been met and still has undiscovered preferences.
			local eligibleChars = {}
			for charName, charData in pairs(Player.catalogue.unlockedCharacters) do
				if charData.met then
					local charObj = _AllCharacters[charName]
					if charObj and charObj.likes then -- Ensure character object and likes/dislikes table exist
						-- Count total potential likes
						local masterLikesCount = 0
						if charObj.likes.categories then for _ in pairs(charObj.likes.categories) do masterLikesCount = masterLikesCount + 1 end end
						if charObj.likes.products then for _ in pairs(charObj.likes.products) do masterLikesCount = masterLikesCount + 1 end end
						if charObj.likes.ingredients then for _ in pairs(charObj.likes.ingredients) do masterLikesCount = masterLikesCount + 1 end end
						
						local discoveredLikesCount = 0
						if charData.discovered_likes then for _ in ipairs(charData.discovered_likes) do discoveredLikesCount = discoveredLikesCount + 1 end end
						
						local undiscoveredDislikesCount = 0
						if charData.undiscovered_dislikes_pool then for _ in ipairs(charData.undiscovered_dislikes_pool) do undiscoveredDislikesCount = undiscoveredDislikesCount + 1 end end

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
			DebugOut("DEV", "AwardDiscoverPreference: Could not find an eligible character for random discovery.")
			return true
		end

		-- 2. DETERMINE THE PREFERENCE TYPE (like or dislike)
		local charData = Player.catalogue.unlockedCharacters[characterToUpdate.name]
		local prefType = self.type
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
			
			if hasUndiscoveredLikes and hasUndiscoveredDislikes then
				if RandRange(1, 2) == 1 then prefType = "like" else prefType = "dislike" end
			elseif hasUndiscoveredLikes then
				prefType = "like"
			elseif hasUndiscoveredDislikes then
				prefType = "dislike"
			else
				DebugOut("DEV", "AwardDiscoverPreference: " .. characterToUpdate.name .. " has no more preferences to discover.")
				return true -- No more preferences to reveal for this character
			end
		end

		-- 3. DETERMINE THE SPECIFIC PREFERENCE TO REVEAL
		local preferenceToReveal = self.pref
		if not preferenceToReveal then
			local undiscovered = {}
			if prefType == "like" and characterToUpdate.likes then
				local masterList = {}
				if characterToUpdate.likes.categories then for k,_ in pairs(characterToUpdate.likes.categories) do table.insert(masterList, k) end end
				if characterToUpdate.likes.products then for k,_ in pairs(characterToUpdate.likes.products) do table.insert(masterList, k) end end
				if characterToUpdate.likes.ingredients then for k,_ in pairs(characterToUpdate.likes.ingredients) do table.insert(masterList, k) end end

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

		-- 4. APPLY THE DISCOVERY
		if preferenceToReveal then
			local discoveredListKey = "discovered_" .. prefType .. "s"
			
			-- Ensure the list exists
			if not charData[discoveredListKey] then charData[discoveredListKey] = {} end
			
			-- Check if it's already known to prevent duplicates
			local alreadyKnown = false
			for _, knownPref in ipairs(charData[discoveredListKey]) do
				if knownPref == preferenceToReveal then alreadyKnown = true; break; end
			end

			if not alreadyKnown then
				table.insert(charData[discoveredListKey], preferenceToReveal)
				DebugOut("PLAYER", "Discovered a new preference for " .. GetString(characterToUpdate.name) .. ": " .. prefType .. "s '" .. GetString(preferenceToReveal) .. "'")

				-- If it's a dislike, also remove it from the undiscovered pool
				if prefType == "dislike" then
					for i, poolItem in ipairs(charData.undiscovered_dislikes_pool) do
						if poolItem == preferenceToReveal then
							table.remove(charData.undiscovered_dislikes_pool, i)
							break
						end
					end
				end
			else
				DebugOut("DEV", "AwardDiscoverPreference: Attempted to reveal preference '"..preferenceToReveal.."' for "..characterToUpdate.name..", but it was already known.")
			end
		else
			DebugOut("DEV", "AwardDiscoverPreference: Could not find a valid undiscovered preference for " .. characterToUpdate.name .. " of type " .. prefType)
		end
		
		return true
	end,
	
	CrossCheck = function(self)
		if self.char and not _AllCharacters[self.char] then return "UNDEFINED CHARACTER: "..self.char end
		if self.type and (self.type ~= "like" and self.type ~= "dislike") then return "INVALID PREFERENCE TYPE: "..self.type end
		if self.pref then
			local found = _AllIngredients[self.pref] or _AllProducts[self.pref] or _AllCategories[self.pref]
			if not found then return "UNDEFINED PREFERENCE ITEM: "..self.pref end
		end
		return nil
	end
}
function AwardDiscoverPreference(charName, preferenceType, preferenceName)
	return CreateObject(_AwardDiscoverPreference, { char=charName, type=preferenceType, pref=preferenceName })
end

------------------------------------------------------------------------------
-- Some "Hints"

local _HintPerson =
{
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
	if type(building) == "table" then building=building.name end
	if type(port) == "table" then port=port.name end
	return CreateObject(_HintPerson, { name=name,building=building,port=port })
end

local _HintDate =
{
	DebugDescription = function(self,quest)
		local weeks = (Player.questsActive[quest.name] or Player.time) + (quest.expires or 0)
		return "Date: "..Date(weeks)
	end,
	Description = function(self,quest)
		local weeks = (Player.questsActive[quest.name] or Player.time) + (quest.expires or 0)
		if (Player.time <= weeks) then return GetText("expire_date", Date(weeks))
		else return GetString("expire_done")
		end
	end,
	Evaluate = function(self,quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		return (weeksLeft > 0)
	end,
	hint = true,
}
function HintExpirationDate()
	return CreateObject(_HintDate)
end

local _HintWeeks =
{
	DebugDescription = function(self,quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		return "Weeks: "..tostring(weeksLeft)
	end,
	Description = function(self,quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		if (weeksLeft > 1) then return GetText("expire_weeks", tostring(weeksLeft))
		elseif (weeksLeft == 1) then return GetString("expire_weeks_one")
		elseif (weeksLeft == 0) then return GetText("expire_weeks_zero", tostring(weeksLeft))
		else return GetString("expire_done")
		end
	end,
	Evaluate = function(self,quest)
		local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
		local weeksLeft = (quest.expires or 0) - weeksPassed
		return (weeksLeft >= 0)
	end,
	hint = true,
}
function HintExpirationWeeks()
	return CreateObject(_HintWeeks)
end