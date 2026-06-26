--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Factory Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Factory" is a Building where the player manufactures chocolate and coffee.
-- Factories consume ingredients and produce product asynchronously every week.

Factory =
{
	defaultConfiguration = "b01",	-- Default product configured when a factory is bought
	type = "factory",
}

setmetatable(Factory, Building)
Factory.__index = Factory
Factory.__tostring = function(t) return "{Factory:" .. tostring(t.name) .. "}" end

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

function Factory:Create(name, port)
	local t = Building:Create(name, port)
	setmetatable(t, self) 
	self.__index = self
	return t
end

------------------------------------------------------------------------------
-- Ownership & Economics
------------------------------------------------------------------------------

-- Configures the factory immediately upon player acquisition
function Factory:MarkOwned()
	Building.MarkOwned(self)
	
	-- Update global tracking states
	Player.portsAvailable[self.port.name] = "factory_stall"
	Player.factoriesOwned = (Player.factoriesOwned or 0) + 1
	Player.factoryAcquiredTime[self.name] = Player.time
	
	-- Initialize default factory tracking table
	local product = _AllProducts[self.defaultConfiguration]
	local t = { 
		current = nil, 
		production = 0, 
		supply = 0, 
		stall = true, 
		needs = {}, 
		output = {} 
	}
	t[product.category.name] = true
	Player.factories[self.name] = t
	
	-- Automatically equip and set to baseline configuration
	self:SetProduction(product, 0)
	
	-- Visually reveal the factory on the port UI
	EnableWindow(self.name .. "_cover", false)
	
	DebugOut("FACTORY", string.format("Player acquired factory '%s'. Default config set to: %s", self.name, product:GetName()))
end

-- Processes the transaction to purchase the factory
function Factory:Purchase(price)
	price = price or self.price or 0
	if price <= Player.money then
		Player:SubtractMoney(price)
		self:MarkOwned()
		-- Optional: Player:QueueMessage("msg_buy_factory", GetString(self.name))
	else
		DebugOut("ERROR", string.format("Insufficient funds to purchase factory '%s'.", self.name))
	end
end

------------------------------------------------------------------------------
-- Manufacturing Management
------------------------------------------------------------------------------

-- Installs a new machinery class into the factory
function Factory:Equip(categoryName)
	Player.factories[self.name][categoryName] = true
	DebugOut("FACTORY", string.format("Factory '%s' successfully equipped with %s machinery.", self.name, GetString(categoryName)))
end

-- Checks if a machinery class is currently installed
function Factory:IsEquipped(categoryName)
	return Player.factories[self.name][categoryName] or false
end

-- Returns the volume and product currently scheduled for production
function Factory:GetProduction(product)
	local count = 0
	local info = Player.factories[self.name]
	
	if not product then product = _AllProducts[info.current] end
	if product then count = info.output[product.code] or 0 end
	
	return count, product
end

-- Sets the target product and the desired yield per week
function Factory:SetProduction(product, count)
	if product then
		local info = Player.factories[self.name]
		
		-- If count isn't specified, revert to whatever this factory's last output for this product was
		count = count or info.output[product.code] or 0
		
		info.current = product.code
		info.output[product.code] = count
		info.production = count
		
		DebugOut("FACTORY", string.format("Factory '%s' configured to produce %s at %d cases/week.", self.name, product:GetName(), count))

		-- Recalculate this factory's raw ingredient consumption needs based on the recipe
		info.needs = product:GetNeeds()
		
		-- Force a global recalculation of all player factory needs and supply times
		Player:UpdateNeeds()

		-- Update the UI
		UpdateLedger("factory")
	end
end

-- Returns how many weeks of ingredients are available for this specific factory
function Factory:GetSupplyTicks()
	local info = Player.factories[self.name]
	return info.supply or 0
end

------------------------------------------------------------------------------
-- Powerups (Factory Enhancements)
------------------------------------------------------------------------------

function Factory:HasPowerup(category, powerup)
	if not category or not category.name then
		-- A factory with no assigned product cannot have an active powerup check
		return false
	end
	
	local key = self.name .. category.name .. powerup
	return Player.powerups[key] or false
end

function Factory:EnablePowerup(category, powerup)
	local key = self.name .. category.name .. powerup
	Player.powerups[key] = true
	DebugOut("FACTORY", string.format("Power-up '%s' enabled for %s machinery at factory '%s'.", powerup, category.name, self.name))
end

------------------------------------------------------------------------------
-- Building Interaction & UI
------------------------------------------------------------------------------

function Factory:EnterBuilding(char, somethingHappened)
	if self:IsOwned() then
		char = self:RandomCharacter()
		DisplayDialog { "ui/ui_factory.lua", char = char, factory = self, ok = "ok" }
		return true
	else
		-- TODO: Trigger building purchase prompt if not owned
		return false
	end
end

------------------------------------------------------------------------------
-- Ledger Rollover (Status Tooltips)
------------------------------------------------------------------------------

-- The minimum number of supply weeks required to keep the UI bar out of the "Red" danger zone, mapped by player rank
local lowIngredientCutoff = { 2, 3, 4, 4, 4, 5, 5 }

function Factory:LedgerRolloverPopup()
	if not self:IsOwned() then return nil end
	
	local x = 0
	local y = 0
	local h = 15
	local font = { uiFontName, h, Color(0, 0, 0, 255) }
	local contents = {}
	
	local count, product = self:GetProduction()
	
	-- 1. Base configuration text (Port Name + Product Name)
	local line = "#" .. GetString(self.port.name) .. " - " .. product:GetName()
	table.insert(contents, TightText { x = x, y = y, w = 400, h = h, label = line, flags = kHAlignLeft + kVAlignTop, font = font })
	y = y + h
	
	-- 2. Production Volume text
	line = "#" .. GetText("dookie_pertick", tostring(count))
	table.insert(contents, TightText { x = x, y = y, w = 400, h = h, label = line, flags = kHAlignLeft + kVAlignTop, font = font })
	y = y + h
	
	-- 3. Ingredient Supply Status Logic
	local lowCount = lowIngredientCutoff[Player.rank] 
	local supply = self:GetSupplyTicks()
	
	if supply > lowCount then
		-- Factory is healthy; show total remaining weeks
		line = "#" .. GetText("dookie_ticks", tostring(supply))
		table.insert(contents, TightText { x = x, y = y, w = 400, h = h, label = line, flags = kHAlignLeft + kVAlignTop, font = font })
		y = y + h
	else
		-- Factory is in danger; break down which specific ingredients are causing the bottleneck
		local info = Player.factories[self.name]
		for name, required_count in pairs(info.needs) do
			line = nil
			local ticks = Floor(Player.supply[name])
			
			if Player.ingredients[name] == 0 then 
				line = "#" .. WorsePriceColor .. GetText("ing_out", GetString(name))
			elseif ticks < lowCount then 
				line = "#" .. GetText("ing_low", GetString(name))
			end
			
			if line then
				-- Append the port where the player last saw this ingredient for sale
				if Player.lastSeenPort[name] then
					line = line .. " - " .. GetText("lastseen", GetString(Player.lastSeenPort[name]))
				end
			
				local scale = h / 32
				table.insert(contents, Bitmap { x = x, y = y, scale = scale, image = "items/" .. name })
				table.insert(contents, TightText { x = x + h, y = y, w = 400, h = h, label = line, flags = kHAlignLeft + kVAlignTop, font = font })
				y = y + h
			end
		end
		
		-- Print remaining weeks if there are at least 2 weeks left before absolute stall
		if supply >= 2 then
			line = "#" .. GetText("dookie_ticks", tostring(supply))
			table.insert(contents, TightText { x = x, y = y, w = 400, h = h, label = line, flags = kHAlignLeft + kVAlignTop, font = font })
			y = y + h
		end
	end

	-- 4. VIP Overrides
	-- "Phone home" option (Changes factory config remotely via Private Phone)
	if Player.questVariables.ownphone == 1 then
		table.insert(contents, TightText { x = x, y = y, w = 400, h = h, label = "click_phone", flags = kHAlignLeft + kVAlignTop, font = font })
		y = y + h
	end
	
	-- Render Dialog Layout
	return MakeDialog { 
		BSGWindow { x = 0, y = 0, frame = "controls/rollover", fit = true, Group(contents) }
	}
end