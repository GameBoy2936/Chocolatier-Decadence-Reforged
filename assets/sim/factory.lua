--[[--------------------------------------------------------------------------
	Chocolatier Three - Factories
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Factory" is a Building where the player manufactures things

Factory =
{
	defaultConfiguration = "b01",
	cadikey = "factory",
	type = "factory",
}

setmetatable(Factory, Building)
Factory.__index = Factory
Factory.__tostring = function(t) return "{Factory:"..tostring(t.name).."}" end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Factory:Create(name, port)
	local t = Building:Create(name, port)
	setmetatable(t, self) self.__index = self
	return t
end

------------------------------------------------------------------------------

function Factory:MarkOwned()
	Building.MarkOwned(self)
	Player.portsAvailable[self.port.name] = "factory_stall"
	Player.factoriesOwned = (Player.factoriesOwned or 0) + 1
	Player.factoryAcquiredTime[self.name] = Player.time
	
	local product = _AllProducts[self.defaultConfiguration]
	local t = { current=nil, production=0, supply=0, stall=true, needs={}, output={} }
	t[product.category.name] = true
	Player.factories[self.name] = t
	self:SetProduction(product, 0)
	EnableWindow(self.name.."_cover", false)
    DebugOut("FACTORY", "Player acquired factory '" .. self.name .. "'. Default config: " .. product:GetName())
end

function Factory:Purchase(price)
	price = price or self.price or 0
	if price <= Player.money then
		Player:SubtractMoney(price)
		self:MarkOwned()
--		if price > 0 then Player:QueueMessage("msg_buy_factory", GetString(self.name)) end
	end
end

------------------------------------------------------------------------------

function Factory:Equip(categoryName)
	Player.factories[self.name][categoryName] = true
    DebugOut("FACTORY", "Factory '" .. self.name .. "' equipped with " .. GetString(categoryName) .. " machinery.")
end

function Factory:IsEquipped(categoryName)
	return Player.factories[self.name][categoryName] or false
end

function Factory:GetProduction(product)
	local count = 0
	local info = Player.factories[self.name]
	if not product then product = _AllProducts[info.current] end
	if product then count = info.output[product.code] or 0 end
	return count,product
end

function Factory:SetProduction(product, count)
	if product then
		-- If already produced and no count is given, switch to previous count
		local info = Player.factories[self.name]
		count = count or info.output[product.code] or 0
		info.current = product.code
		info.output[product.code] = count
		info.production = count
		
        DebugOut("FACTORY", "Factory '" .. self.name .. "' configured to produce " .. product:GetName() .. " at " .. count .. " cases/week.")

		-- Update this factory's needs based on recipe information
		info.needs = product:GetNeeds()
		
		-- Update Player's total factory needs and supplies
		Player:UpdateNeeds()

		-- Update ledger
		UpdateLedger("factory")
	end
end


function Factory:GetSupplyTicks()
	local info = Player.factories[self.name]
	return info.supply or 0
end

------------------------------------------------------------------------------
-- Powerups

function Factory:HasPowerup(category, powerup)
	if not category or not category.name then
		-- This can happen if a factory has no product configured yet.
		-- In this state, it can't have a powerup for a specific category.
		return false
	end
	local key = self.name..category.name..powerup
	return Player.powerups[key] or false
end

function Factory:EnablePowerup(category, powerup)
	local key = self.name..category.name..powerup
	Player.powerups[key] = true
    DebugOut("FACTORY", "Power-up '" .. powerup .. "' enabled for " .. category.name .. " at factory '" .. self.name .. "'.")
end

------------------------------------------------------------------------------
-- Click Management

function Factory:EnterBuilding(char, somethingHappened)
	if self:IsOwned() then
--		char = char or self:RandomCharacter()
		char = self:RandomCharacter()
		DisplayDialog { "ui/ui_factory.lua", char=char, factory=self, ok="ok" }
		return true
	else
	
		-- TODO: Buy the factory?
	
		return false
	end
end

------------------------------------------------------------------------------
-- Rollovers

-- Weeks below which supply bars would be red
local lowIngredientCutoff = { 2,3,4,4,4,5,5 }

function Factory:LedgerRolloverPopup()
	if not self:IsOwned() then return nil end
	
	local x=0
	local y=0
	local h = 15
	local font = {uiFontName,h,Color(0,0,0,255)}
	local contents = {}
	local count,product = self:GetProduction()
	
	-- Base configuration
	local line = "#"..GetString(self.port.name) .. " - " .. product:GetName()
	table.insert(contents, TightText { x=x,y=y,w=400,h=h, label=line, flags=kHAlignLeft+kVAlignTop, font=font })
	y = y + h
	line = "#"..GetText("dookie_pertick", tostring(count))
	table.insert(contents, TightText { x=x,y=y,w=400,h=h, label=line, flags=kHAlignLeft+kVAlignTop, font=font })
	y = y + h
	
	-- Supply
	local lowCount = lowIngredientCutoff[Player.rank] 
	local supply = self:GetSupplyTicks()
	if supply > lowCount then
		line = "#"..GetText("dookie_ticks", tostring(supply))
		table.insert(contents, TightText { x=x,y=y,w=400,h=h, label=line, flags=kHAlignLeft+kVAlignTop, font=font })
		y = y + h
	else
		local info = Player.factories[self.name]
		for name,count in pairs(info.needs) do
			line = nil
			local ticks = Floor(Player.supply[name])
			if Player.ingredients[name] == 0 then line = "#"..WorsePriceColor..GetText("ing_out", GetString(name))
			elseif ticks < lowCount then line = "#"..GetText("ing_low", GetString(name))
			end
			
			if line then
				if Player.lastSeenPort[name] then
					line = line .. " - " .. GetText("lastseen", GetString(Player.lastSeenPort[name]))
				end
			
				local scale = h/32
				table.insert(contents, Bitmap { x=x,y=y, scale=scale, image="items/"..name })
				table.insert(contents, TightText { x=x+h,y=y,w=400,h=h, label=line, flags=kHAlignLeft+kVAlignTop, font=font })
				y = y + h
			end
		end
		
		if supply >= 2 then
			line = "#"..GetText("dookie_ticks", tostring(supply))
			table.insert(contents, TightText { x=x,y=y,w=400,h=h, label=line, flags=kHAlignLeft+kVAlignTop, font=font })
			y = y + h
		end
	end

	-- "Phone home" option
	if Player.questVariables.ownphone == 1 then
		table.insert(contents, TightText { x=x,y=y,w=400,h=h, label="click_phone", flags=kHAlignLeft+kVAlignTop, font=font })
		y = y + h
	end
	
	return MakeDialog{ BSGWindow { x=0,y=0,frame="controls/rollover",fit=true, Group(contents) }}
end