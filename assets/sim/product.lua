--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Product" is an item that can be manufactured by the player by
-- combining various Products and Ingredients using a particular Machine

Product =
{
	code = nil,						-- For system products, a unique identifier (unique 3-letter code across the Chocolatier universe)
									-- For player-created products, this is a unique identifier derived from type and components
	category = nil,					-- Product category table (on init, this is just a string)

	-- Pricing
	price_low = nil,				-- Low price
	price_high = nil,				-- High price
	cost_low = nil,					-- Low cost (sum of low costs of ingredients)
	cost_high = nil,				-- High cost (sum of high costs of ingredients)
    unit_type = "unit_case",

	-- Appearance
	appearance = nil,				-- Null if product image has the same name as the product (default for system products)
	
	-- Recipe
	recipe = nil,					-- Set of { ingredient, ingredient, ... }
	counts = nil,					-- Set of { ingredient=count, ... }
}

Product.__tostring = function(t) return "{Product:"..tostring(t.code).."}" end

_AllProducts = {}				-- Match by product codes

------------------------------------------------------------------------------
-- Player-specific accessors

function Product:GetPrice()
	return Player.itemPrices[self.code] or 1
end

function Product:SetPrice(n)
    local oldPrice = Player.itemPrices[self.code] or 0
    if oldPrice ~= n then
        DebugOut("ECONOMY", "Price for " .. self:GetName() .. " changed from " .. Dollars(oldPrice) .. " to " .. Dollars(n))
    end
	Player.itemPrices[self.code] = (n or 0)
end

function Product:GetName()
--DebugOut("Get Name:"..tostring(self.code))
	local name = Player.itemNames[self.code]
	if not name then name = GetString(self.code) end
	return name
end

function Product:GetDescription()
	local desc = Player.itemDescriptions[self.code]
	if not desc then desc = GetString(self.code .. "_desc") end
	return desc
end

function Product:IsKnown()
	return Player.knownRecipes[self.code] or self.category.name == "user"
end

function Product:Unlock()
	if not Player.knownRecipes[self.code] then
		Player.knownRecipes[self.code] = true
		local n = (Player.categoryCount[self.category.name] or 0) + 1
		Player.categoryCount[self.category.name] = n
        DebugOut("RECIPE", "Player learned recipe: " .. self:GetName())
	end
end

function Product:Lock()
	if Player.knownRecipes[self.code] then
		Player.knownRecipes[self.code] = false
		local n = (Player.categoryCount[self.category.name] or 0) - 1
		if n < 1 then n = nil end
		Player.categoryCount[self.category.name] = n
        DebugOut("RECIPE", "Player forgot (locked) recipe: " .. self:GetName())
	end
end

function Product:NumberMade()
	return Player.itemsMade[self.code] or 0
end

function Product:NumberSold()
	return Player.itemsSold[self.code] or 0
end

function Product:RecordMade(n)
	n = n or 0
	local already = Player.itemsMade[self.code] or 0
	if n > 0 then
		Player.itemsMade[self.code] = n + already
		if already == 0 then
			-- First time this is made, count it...
			local count = Player.categoryMadeCount[self.category.name] or 0
			Player.categoryMadeCount[self.category.name] = count + 1
            DebugOut("RECIPE", "First time manufacturing: " .. self:GetName())
		end
	else
		Player.itemsMade[self.code] = nil
	end
end

function Product:RecordSold(n)
	n = (n or 0) + (Player.itemsSold[self.code] or 0)
	if n > 0 then Player.itemsSold[self.code] = n
	else Player.itemsSold[self.code] = nil
	end
end

-- TODO: Some other product ordering function -- ?
function ProductOrderFunction(a,b) return a.code < b.code end

function Product:Sell(count)
	local max = self:GetInventory()
	if count == nil or count > max then count = max end

	if count > 0 then
        local price = self:GetPrice()
        local total = price * count
        DebugOut("PLAYER", "Selling " .. count .. " cases of " .. self:GetName() .. " for " .. Dollars(total))
        
        Player.useTimes[self.code] = Player.time
		self:AdjustInventory(-count)
		self:RecordSold(count)
		Player:AddMoney(total)
--		Player:QueueMessage("msg_sell_product", count, self:GetName(), self:GetPrice())
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Product:Create(t)
	if not t then
		DebugOut("ERROR", "Product:Create called with nil definition table.")
	elseif not t.code then
		DebugOut("ERROR", "Product:Create called without a code.")
	elseif not t.category then
		DebugOut("ERROR", "Product:Create called without a category for '" .. (t.code or "unknown") .. "'.")
	elseif _AllProducts[t.code] then
		DebugOut("ERROR", "Product:Create detected duplicate product code: '" .. t.code .. "'. Ignoring.")
	else
		t.code = string.lower(t.code)
--		DebugOut("PRODUCT:"..tostring(t.code))
        if t.category ~= "user" then
            DebugOut("LOAD", "Created product definition: " .. t.code)
        end
		
		setmetatable(t, self) self.__index = self
		_AllProducts[t.code] = t
		if t.code then _G[t.code] = t end

		-- Defaults to "unit_case" if not specified in XML.
		t.unit_type = t.unit_type or "unit_case"
		
		-- Recipe is parsed from XML as <ingredient name> = <number>, should be just a list of ingredients. Convert it.
		t.counts = t.recipe
		t.recipe = {}
		
		-- Also, gather the total prices of its ingredients
		local lowprice = 0
		local highprice = 0
		if t.counts then
			for name,scount in pairs(t.counts) do
				local ing = _AllIngredients[name]
				for i=1,tonumber(scount) do
					lowprice = lowprice + ing.price_low
					highprice = highprice + ing.price_high
					table.insert(t.recipe, name)
				end
				t.counts[name]=tonumber(scount)
			end
		end
		
		t.price_low = lowprice
		t.cost_low = lowprice
		t.price_high = highprice
		t.cost_high = highprice

		-- Initial price for this product is smack in the middle
		Player.itemPrices[t.code] = Floor((t.price_low + t.price_high) / 2 + .5)
	end
	return t
end

function CreateProduct(t) return Product:Create(t) end

function CreateProductFromXML(t)
	-- XML contains "flat" data
	local t = { code=t.code, category=t.category, recipe=t }
	t.recipe.code = nil
	t.recipe.category = nil
	return Product:Create(t)
end

function AssignProductCategories()
	-- TODO: Do this in order?
	for _,product in pairs(_AllProducts) do
		local category = _AllCategories[product.category]
		if not category then
			-- TODO: WARN missing category
		else
			product.category = category
			category:AddProduct(product)
			
			-- Apply difficulty-based sale price penalty
			local price_penalty = 1.0
			if Player.difficulty == 2 then -- Medium
				price_penalty = 0.90 -- Player earns only 90% of the normal sale price
			elseif Player.difficulty == 3 then -- Hard
				price_penalty = 0.75 -- Player earns only 75% of the normal sale price
			end
			
			product.price_low = Floor(product.cost_low * category.markup * price_penalty + .5)
			product.price_high = Floor(product.cost_high * category.markup * price_penalty + .5)
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Product:GetInventory()
	return Player.products[self.code] or 0
end

function Product:AdjustInventory(n)
	local count = Player.products[self.code] or 0
	if n < 0 then
		n = -n
		if n > count then count = nil
		else count = count - n
		end
	else
		count = count + n
	end
	if count == 0 then count = nil end
	Player.products[self.code] = count
	return count or 0
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Product:GetAppearanceHuge(x,y)
	x=x or 0
	y=y or 0
	local appearance = {}
	if self.appearance then
		for _,layerName in ipairs(self.appearance) do
			local tint = {1,1,1,1}
			if type(layerName) == "table" then
				tint[1] = layerName[2]
				tint[2] = layerName[3]
				tint[3] = layerName[4]
				layerName = layerName[1]
			end
			
			table.insert(appearance, BitmapTint { x=x,y=y, image="custom/"..layerName, tint=tint } )
			table.insert(appearance, Bitmap { x=x,y=y, image="custom/"..layerName.."_highlight" } )
		end
		appearance = Group(appearance)
	else
		appearance = Bitmap { x=x,y=y, image="items/"..self.code.."_big" }
	end
	return appearance
end

function Product:GetAppearanceBig(x,y,scale)
	scale = (scale or 1) * .5
	x=x or 0
	y=y or 0
	local appearance = {}
	if self.appearance then
		for _,layerName in ipairs(self.appearance) do
			local tint = {1,1,1,1}
			if type(layerName) == "table" then
				tint[1] = layerName[2]
				tint[2] = layerName[3]
				tint[3] = layerName[4]
				layerName = layerName[1]
			end
			
			table.insert(appearance, BitmapTint { x=x,y=y, image="custom/"..layerName, tint=tint, scale=scale } )
			table.insert(appearance, Bitmap { x=x,y=y, image="custom/"..layerName.."_highlight", scale=scale } )
		end
		appearance = Group(appearance)
	else
		appearance = Bitmap { x=x,y=y, image="items/"..self.code.."_big", scale=scale }
	end
	return appearance
end

function Product:GetAppearance(x,y,scale)
	scale = scale or 1
	x=x or 0
	y=y or 0
	local appearance = {}
	if self.appearance then
		for _,layerName in ipairs(self.appearance) do
			local tint = {1,1,1,1}
			if type(layerName) == "table" then
				tint[1] = layerName[2]
				tint[2] = layerName[3]
				tint[3] = layerName[4]
				layerName = layerName[1]
			end
			
			-- TODO: "Small" size of customizable pieces
			table.insert(appearance, BitmapTint { x=x,y=y, image="custom/"..layerName, tint=tint, scale=.25 * scale } )
			table.insert(appearance, Bitmap { x=x,y=y, image="custom/"..layerName.."_highlight", scale=.25 * scale} )
		end
		appearance = Group(appearance)
	else
		appearance = Bitmap { x=x,y=y, image="items/"..self.code, scale=scale }
	end
	return appearance
end

function Product:GetUnitName(count)
	-- Default to "unit_case" if not specified (Products are almost always cases)
	local type = self.unit_type or "unit_case"
	return GetLocalizedUnit(type, count)
end

function Product:RolloverContents(strings)
	-- Inventory information
	local inventory = GetText("prod_inventory", tostring(self:GetInventory()))

	-- "High/Low" price information
	local priceRange = nil
	if Player.lowPrice[self.code] and Player.highPrice[self.code] then
		priceRange = GetText("price_range", Dollars(Player.lowPrice[self.code]), Dollars(Player.highPrice[self.code]))
	end
	
	-- "Last seen" information
	local lastSeen = GetString("product_never_seen")
	if Player.lastSeenPort[self.code] then
		lastSeen = GetText("product_lastseen", GetText(Player.lastSeenPort[self.code]), Dollars(Player.lastSeenPrice[self.code]))
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
			self:GetAppearanceBig(),
			AppendStyle { font=rolloverInfoFont, flags=kVAlignTop+kHAlignLeft, },
			Group(text),
		}
	}
end

function Product:ShopRolloverContents()
	return self:RolloverContents(GetString("click_sell"))
end

function Product:RecipeBookRolloverContents()
	if self:IsKnown() then
		return self:RolloverContents()
	else
		return MakeDialog
		{
			BSGWindow
			{
				x=0,y=0, fit=true, color=rolloverColor, frame="controls/rollover",
				self:GetAppearanceBig(),
				AppendStyle { font=rolloverInfoFont, flags=kVAlignTop+kHAlignLeft, },
				Text { x=64,y=0,w=238,h=64,label="#"..GetString"recipe_unknown", flags=kVAlignCenter+kHAlignLeft },
			}
		}
	end
end

function RecipeBookEmptySlotContents()
	return MakeDialog
	{
		BSGWindow
		{
			x=0,y=0, fit=true, color=rolloverColor, frame="controls/rollover",
			Bitmap { x=0,y=0,w=64,h=64, image="items/unknown", scale=2 },
			AppendStyle { font=rolloverInfoFont, flags=kVAlignTop+kHAlignLeft, },
			Text { x=64,y=0,w=238,h=64, label="#"..GetString"user_blankslot", flags=kVAlignCenter+kHAlignLeft },
		}
	}
end

Product.InventoryRolloverContents = Product.RolloverContents
Product.BuySellRolloverContents = Product.RolloverContents

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Product:GetNeeds()
	local needs = {}
	for _,name in pairs(self.recipe) do
		local n = needs[name] or 0
		needs[name] = n + 1
	end
	return needs
end

function Product:GetMachinery()
	local category = self.category
	if Player.itemMachinery[self.code] then
		local machinery = Player.itemMachinery[self.code]
		category = _AllCategories[machinery]
	end
	return category
end

function Product:RunMinigame(t)
	local production = nil
	-- Check available machinery and give player a chance to purchase it
	local factory = t.factory
	local category = self:GetMachinery()
	local equipped = factory:IsEquipped(category.name)
	if not equipped then
		local cost = category.machinecost or 10000
		if Player.money < cost then
			local text = GetText("factory_expensivemachinery", GetText(category.name), Dollars(cost), Dollars(Player.money))
			DisplayDialog { "ui/ui_character_generic.lua", text="#"..text, char=t.char }
		else
			local text = GetText("factory_buymachinery", GetText(category.name), Dollars(cost), Dollars(Player.money))
			local buy = DisplayDialog { "ui/ui_character_yesno.lua", text="#"..text, char=t.char }
			if buy == "yes" then
				Player:SubtractMoney(cost)
				factory:Equip(category.name)
				equipped = true
			end
		end
	end
		
	if equipped then
		-- Check available ingredients
		local missing = {}
		local needs = self:GetNeeds()
		for name,need in pairs(needs) do
			local have = Player.ingredients[name] or 0
			if need > have then table.insert(missing, name) end
		end
		
		if table.getn(missing) > 0 then
			DisplayDialog { "ui/ui_missing.lua", text="factory_insufficient", missing=missing }
		else
			local factoryType = self.factory or category.factory
			if factoryType == "coffee" then factoryType = "ui/coffee_factory.lua"
			else factoryType = "ui/chocolate_factory.lua"
			end
			
			SoundEvent("Stop_Environments")
			PausePortAnimations(true)
			production = DisplayDialog { factoryType, product=self, factory=t.factory }
			PausePortAnimations(false)
			SoundEvent("Stop_Music")
--			SoundEvent("port_music")
			if factory.cadikey then SoundEvent(factory.cadikey)
			else SoundEvent(factory.port.cadikey)
			end
		end
	end
	
	if production then production = tonumber(production) end
	return (production or -1)
end