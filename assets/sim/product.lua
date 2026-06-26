--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Product Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Product" is a manufactured finished good created by combining raw 
-- ingredients using factory machinery. It can then be sold to shops for profit.

Product =
{
	-- ==========================================
	-- Identity & Classification
	-- ==========================================
	-- For system products: A hardcoded unique identifier.
	-- For player recipes: A concatenated signature derived from its ingredients.
	code = nil,						
	
	category = nil,					-- The Product Category object it belongs to
	unit_type = "unit_case",		-- Products are almost universally sold in cases

	-- ==========================================
	-- Economics
	-- ==========================================
	price_low = nil,				-- Base Minimum Retail Price
	price_high = nil,				-- Base Maximum Retail Price
	cost_low = nil,					-- Sum of the lowest possible cost of all required ingredients
	cost_high = nil,				-- Sum of the highest possible cost of all required ingredients

	-- ==========================================
	-- Data Structures
	-- ==========================================
	appearance = nil,				-- Array of tintable layer textures. If nil, defaults to a static image file.
	recipe = nil,					-- Array of required ingredients { "sugar", "sugar", "cacao" }
	counts = nil,					-- Key-Value tally of required ingredients { sugar = 2, cacao = 1 }
}

-- Metamethod for debug logging
Product.__tostring = function(t) return "{Product:" .. tostring(t.code) .. "}" end

-- Global Registry
_AllProducts = {}				-- Key-value lookup by product code

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

-- Factory method: Parses an internal definition and spins up a global Product object.
function Product:Create(t)
	if not t then
		DebugOut("ERROR", "Product:Create called with nil definition table.")
		return nil
	elseif not t.code then
		DebugOut("ERROR", "Product:Create called without a product code.")
		return nil
	elseif not t.category then
		DebugOut("ERROR", string.format("Product:Create called without a category for '%s'.", t.code or "unknown"))
		return nil
	elseif _AllProducts[t.code] then
		DebugOut("ERROR", string.format("Duplicate product code detected: '%s'. Ignoring.", t.code))
		return nil
	else
		-- Ensure code is universally lowercased for safe lookups
		t.code = string.lower(t.code)
		
		if t.category ~= "user" then
			DebugOut("LOAD", string.format("Created product definition: %s", t.code))
		end
		
		-- Bind the metatable
		setmetatable(t, self) 
		self.__index = self
		
		_AllProducts[t.code] = t
		if t.code then _G[t.code] = t end

		t.unit_type = t.unit_type or "unit_case"
		
		-- -----------------------------------------------------
		-- Recipe Restructuring
		-- -----------------------------------------------------
		-- The engine reads XML recipes as { [name] = count }. We need to translate
		-- this into a flat sequential array for the visual generation engines.
		t.counts = t.recipe
		t.recipe = {}
		
		local lowprice = 0
		local highprice = 0
		
		if t.counts then
			for name, scount in pairs(t.counts) do
				local ing = _AllIngredients[name]
				
				-- Check if the ingredient actually exists in the global registry
				if not ing then
					-- Raise an error to the debug log, ignore the ingredient, and remove it from counts
					DebugOut("ERROR", string.format("Product '%s' requires unknown ingredient '%s'. Ignoring ingredient.", t.code, name))
					t.counts[name] = nil
				else
					-- Expand the count into discrete array entries, and sum the raw ingredient cost
					for i = 1, tonumber(scount) do
						lowprice = lowprice + ing.price_low
						highprice = highprice + ing.price_high
						table.insert(t.recipe, name)
					end
					
					t.counts[name] = tonumber(scount)
				end
			end
		end
		
		-- Set the raw manufacturing costs (Prices are calculated later during Categorization)
		t.price_low = lowprice
		t.cost_low = lowprice
		t.price_high = highprice
		t.cost_high = highprice

		-- Seed the initial local market price perfectly in the middle
		Player.itemPrices[t.code] = Floor((t.price_low + t.price_high) / 2 + 0.5)
	end
	
	return t
end

function CreateProduct(t) 
	return Product:Create(t) 
end

-- Specialized wrapper used directly by the XML parsing engine
function CreateProductFromXML(t)
	-- XML sends flat tables. Repackage it into the structured object format.
	local t_formatted = { code = t.code, category = t.category, recipe = t }
	t_formatted.recipe.code = nil
	t_formatted.recipe.category = nil
	
	return Product:Create(t_formatted)
end

-- Post-load operation: Calculates the final retail value of all products by
-- multiplying their raw ingredient costs by their assigned Category markup.
function AssignProductCategories()
	for _, product in pairs(_AllProducts) do
		local category = _AllCategories[product.category]
		
		if not category then
			DebugOut("ERROR", string.format("Product '%s' references missing category '%s'.", product.code, product.category))
		else
			product.category = category
			category:AddProduct(product)
			
			-- Hard-mode penalty: On higher difficulties, the final retail price ceiling is lowered.
			local price_penalty = 1.0
			if Player.difficulty == 2 then 
				price_penalty = 0.90 -- Player earns max 90% of the normal profit margin
			elseif Player.difficulty == 3 then 
				price_penalty = 0.75 -- Player earns max 75% of the normal profit margin
			end
			
			-- Finalize actual retail brackets
			product.price_low = Floor(product.cost_low * category.markup * price_penalty + 0.5)
			product.price_high = Floor(product.cost_high * category.markup * price_penalty + 0.5)
		end
	end
end

------------------------------------------------------------------------------
-- Player Economics & Market Transactions
------------------------------------------------------------------------------

function Product:GetPrice()
	return Player.itemPrices[self.code] or 1
end

function Product:SetPrice(n)
	local oldPrice = Player.itemPrices[self.code] or 0
	if oldPrice ~= n then
		DebugOut("ECONOMY", string.format("Market price for %s shifted from %s to %s", self:GetName(), Dollars(oldPrice), Dollars(n)))
	end
	Player.itemPrices[self.code] = (n or 0)
end

-- Fetches the localized name, falling back to the Player's custom text if it's a UGR
function Product:GetName()
	local name = Player.itemNames[self.code]
	if not name then name = GetString(self.code) end
	return name
end

function Product:GetDescription()
	local desc = Player.itemDescriptions[self.code]
	if not desc then desc = GetString(self.code .. "_desc") end
	return desc
end

------------------------------------------------------------------------------
-- Recipe Unlocking & Tracking
------------------------------------------------------------------------------

-- Custom user recipes are considered intrinsically "known"
function Product:IsKnown()
	return Player.knownRecipes[self.code] or self.category.name == "user"
end

function Product:Unlock()
	if not Player.knownRecipes[self.code] then
		Player.knownRecipes[self.code] = true
		local n = (Player.categoryCount[self.category.name] or 0) + 1
		Player.categoryCount[self.category.name] = n
		
		DebugOut("RECIPE", string.format("Player learned new recipe: %s", self:GetName()))
	end
end

function Product:Lock()
	if Player.knownRecipes[self.code] then
		Player.knownRecipes[self.code] = false
		local n = (Player.categoryCount[self.category.name] or 0) - 1
		if n < 1 then n = nil end
		Player.categoryCount[self.category.name] = n
		
		DebugOut("RECIPE", string.format("Player forgot (locked) recipe: %s", self:GetName()))
	end
end

------------------------------------------------------------------------------
-- Inventory & Sales Logic
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

function Product:NumberMade() return Player.itemsMade[self.code] or 0 end
function Product:NumberSold() return Player.itemsSold[self.code] or 0 end

function Product:RecordMade(n)
	n = n or 0
	local already = Player.itemsMade[self.code] or 0
	
	if n > 0 then
		Player.itemsMade[self.code] = n + already
		
		-- If this is the absolute first time the player has made this product, increment the global category tally
		if already == 0 then
			local count = Player.categoryMadeCount[self.category.name] or 0
			Player.categoryMadeCount[self.category.name] = count + 1
			DebugOut("RECIPE", string.format("First time manufacturing product: %s", self:GetName()))
		end
	else
		Player.itemsMade[self.code] = nil
	end
end

function Product:RecordSold(n)
	n = (n or 0) + (Player.itemsSold[self.code] or 0)
	if n > 0 then 
		Player.itemsSold[self.code] = n
	else 
		Player.itemsSold[self.code] = nil
	end
end

-- Executes a sale to a shopkeeper
function Product:Sell(count)
	local max = self:GetInventory()
	if count == nil or count > max then count = max end

	if count > 0 then
		local price = self:GetPrice()
		local total = price * count
		
		DebugOut("ECONOMY", string.format("Sold %d cases of %s for %s.", count, self:GetName(), Dollars(total)))
		
		Player.useTimes[self.code] = Player.time
		self:AdjustInventory(-count)
		self:RecordSold(count)
		Player:AddMoney(total)
	end
end

-- Sorting hook
function ProductOrderFunction(a, b) return a.code < b.code end

------------------------------------------------------------------------------
-- UI Rendering: Dynamic Recipe Assembly
------------------------------------------------------------------------------

function Product:GetAppearanceHuge(x, y)
	x = x or 0
	y = y or 0
	local appearance = {}
	
	if self.appearance then
		local machinery = self:GetMachinery()
		local isBeverage = machinery and (machinery.name == "beverage" or machinery.name == "blend")
		local mugInjected = not isBeverage

		for _, layerNameRaw in ipairs(self.appearance) do
			local tint = { 1, 1, 1, 1 }
			local layerName = layerNameRaw
			
			if type(layerName) == "table" then
				tint[1] = layerName[2]
				tint[2] = layerName[3]
				tint[3] = layerName[4]
				layerName = layerName[1]
			end
			
			table.insert(appearance, BitmapTint { x = x, y = y, image = "custom/" .. layerName, tint = tint })
			table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. layerName .. "_highlight" })
			
			-- -----------------------------------------------------
			-- LAYER INJECTION FIX (3D Glass Mug Sandwich):
			-- -----------------------------------------------------
			-- Inject the glass mug body and the BACK RIM (outer rim) immediately 
			-- AFTER layer 2 (the liquid body) is rendered.
			if isBeverage and not mugInjected and string.find(layerName, "layer2") then
				table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/mug" })
				table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_outer" })
				mugInjected = true
			end
		end
		
		-- Inject the FRONT RIM (inner rim) at the absolute top of the stack to enclose everything
		if isBeverage then
			table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_inner" })
		end
		
		-- Failsafe
		if isBeverage and not mugInjected then
			table.insert(appearance, 1, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_outer" })
			table.insert(appearance, 1, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/mug" })
		end
		
		appearance = Group(appearance)
	else
		appearance = Bitmap { x = x, y = y, image = "items/" .. self.code .. "_big" }
	end
	return appearance
end

function Product:GetAppearanceBig(x, y, scale)
	scale = (scale or 1) * 0.5
	x = x or 0
	y = y or 0
	local appearance = {}
	
	if self.appearance then
		local machinery = self:GetMachinery()
		local isBeverage = machinery and (machinery.name == "beverage" or machinery.name == "blend")
		local mugInjected = not isBeverage

		for _, layerNameRaw in ipairs(self.appearance) do
			local tint = { 1, 1, 1, 1 }
			local layerName = layerNameRaw
			
			if type(layerName) == "table" then
				tint[1] = layerName[2]
				tint[2] = layerName[3]
				tint[3] = layerName[4]
				layerName = layerName[1]
			end
			
			table.insert(appearance, BitmapTint { x = x, y = y, image = "custom/" .. layerName, tint = tint, scale = scale })
			table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. layerName .. "_highlight", scale = scale })
			
			-- -----------------------------------------------------
			-- LAYER INJECTION FIX (3D Glass Mug Sandwich):
			-- -----------------------------------------------------
			if isBeverage and not mugInjected and string.find(layerName, "layer2") then
				table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/mug", scale = scale })
				table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_outer", scale = scale })
				mugInjected = true
			end
		end
		
		-- Inject the FRONT RIM (inner rim)
		if isBeverage then
			table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_inner", scale = scale })
		end
		
		-- Failsafe
		if isBeverage and not mugInjected then
			table.insert(appearance, 1, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_outer", scale = scale })
			table.insert(appearance, 1, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/mug", scale = scale })
		end
		
		appearance = Group(appearance)
	else
		appearance = Bitmap { x = x, y = y, image = "items/" .. self.code .. "_big", scale = scale }
	end
	return appearance
end

function Product:GetAppearance(x, y, scale)
	scale = scale or 1
	x = x or 0
	y = y or 0
	local appearance = {}
	
	if self.appearance then
		local machinery = self:GetMachinery()
		local isBeverage = machinery and (machinery.name == "beverage" or machinery.name == "blend")
		local mugInjected = not isBeverage

		for _, layerNameRaw in ipairs(self.appearance) do
			local tint = { 1, 1, 1, 1 }
			local layerName = layerNameRaw
			
			if type(layerName) == "table" then
				tint[1] = layerName[2]
				tint[2] = layerName[3]
				tint[3] = layerName[4]
				layerName = layerName[1]
			end
			
			table.insert(appearance, BitmapTint { x = x, y = y, image = "custom/" .. layerName, tint = tint, scale = 0.25 * scale })
			table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. layerName .. "_highlight", scale = 0.25 * scale })
			
			-- -----------------------------------------------------
			-- LAYER INJECTION FIX (3D Glass Mug Sandwich):
			-- -----------------------------------------------------
			if isBeverage and not mugInjected and string.find(layerName, "layer2") then
				table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/mug", scale = 0.25 * scale })
				table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_outer", scale = 0.25 * scale })
				mugInjected = true
			end
		end
		
		-- Inject the FRONT RIM (inner rim)
		if isBeverage then
			table.insert(appearance, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_inner", scale = 0.25 * scale })
		end
		
		-- Failsafe
		if isBeverage and not mugInjected then
			table.insert(appearance, 1, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/rim_outer", scale = 0.25 * scale })
			table.insert(appearance, 1, Bitmap { x = x, y = y, image = "custom/" .. machinery.name .. "/mug", scale = 0.25 * scale })
		end
		
		appearance = Group(appearance)
	else
		appearance = Bitmap { x = x, y = y, image = "items/" .. self.code, scale = scale }
	end
	return appearance
end

------------------------------------------------------------------------------
-- UI Tooltips
------------------------------------------------------------------------------

function Product:GetUnitName(count)
	local type = self.unit_type or "unit_case"
	return GetLocalizedUnit(type, count)
end

function Product:RolloverContents(strings)
	local inventory = GetText("prod_inventory", tostring(self:GetInventory()))

	local priceRange = nil
	if Player.lowPrice[self.code] and Player.highPrice[self.code] then
		priceRange = GetText("price_range", Dollars(Player.lowPrice[self.code]), Dollars(Player.highPrice[self.code]))
	end
	
	local lastSeen = GetString("product_never_seen")
	if Player.lastSeenPort[self.code] then
		lastSeen = GetText("product_lastseen", GetText(Player.lastSeenPort[self.code]), Dollars(Player.lastSeenPrice[self.code]))
	end
	
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
			self:GetAppearanceBig(),
			AppendStyle { font = rolloverInfoFont, flags = kVAlignTop + kHAlignLeft },
			Group(text),
		}
	}
end

function Product:ShopRolloverContents() return self:RolloverContents(GetString("click_sell")) end
Product.InventoryRolloverContents = Product.RolloverContents
Product.BuySellRolloverContents = Product.RolloverContents

function Product:RecipeBookRolloverContents()
	if self:IsKnown() then
		return self:RolloverContents()
	else
		-- Render obfuscated unknown recipe tooltip
		return MakeDialog
		{
			BSGWindow
			{
				x = 0, y = 0, fit = true, color = rolloverColor, frame = "controls/rollover",
				self:GetAppearanceBig(),
				AppendStyle { font = rolloverInfoFont, flags = kVAlignTop + kHAlignLeft },
				Text { x = 64, y = 0, w = 238, h = 64, label = "#" .. GetString("recipe_unknown"), flags = kVAlignCenter + kHAlignLeft },
			}
		}
	end
end

-- Renders the blank empty silhouette for available UGR slots in the recipe book
function RecipeBookEmptySlotContents()
	return MakeDialog
	{
		BSGWindow
		{
			x = 0, y = 0, fit = true, color = rolloverColor, frame = "controls/rollover",
			Bitmap { x = 0, y = 0, w = 64, h = 64, image = "items/unknown", scale = 2 },
			AppendStyle { font = rolloverInfoFont, flags = kVAlignTop + kHAlignLeft },
			Text { x = 64, y = 0, w = 238, h = 64, label = "#" .. GetString("user_blankslot"), flags = kVAlignCenter + kHAlignLeft },
		}
	}
end

------------------------------------------------------------------------------
-- Machinery & Minigame Hooks
------------------------------------------------------------------------------

-- Helper returning the aggregated ingredient breakdown for a single yield
function Product:GetNeeds()
	local needs = {}
	for _, name in pairs(self.recipe) do
		local n = needs[name] or 0
		needs[name] = n + 1
	end
	return needs
end

-- Resolves the true equipment class required to build this item
function Product:GetMachinery()
	local category = self.category
	
	-- UGRs have the "user" category fundamentally, so we look up the specific
	-- machinery mapping defined during the recipe's creation.
	if Player.itemMachinery[self.code] then
		local machinery = Player.itemMachinery[self.code]
		category = _AllCategories[machinery]
	end
	
	return category
end

-- Triggers the pre-flight checks and launches the Factory Minigame UI
function Product:RunMinigame(t)
	local production = nil
	local factory = t.factory
	local category = self:GetMachinery()
	
	-- 1. Equipment Verification
	-- If the factory doesn't possess the machinery to build this class of item, prompt to install it.
	local equipped = factory:IsEquipped(category.name)
	
	if not equipped then
		local cost = category.machinecost or 10000
		
		if Player.money < cost then
			local text = GetText("factory_expensivemachinery", GetText(category.name), Dollars(cost), Dollars(Player.money))
			DisplayDialog { "ui/ui_character_generic.lua", text = "#" .. text, char = t.char }
		else
			local text = GetText("factory_buymachinery", GetText(category.name), Dollars(cost), Dollars(Player.money))
			local buy = DisplayDialog { "ui/ui_character_yesno.lua", text = "#" .. text, char = t.char }
			
			if buy == "yes" then
				Player:SubtractMoney(cost)
				factory:Equip(category.name)
				equipped = true
			end
		end
	end
		
	-- 2. Material Verification
	if equipped then
		local missing = {}
		local needs = self:GetNeeds()
		
		-- Check if the player possesses at least 1 case worth of ingredients
		for name, need in pairs(needs) do
			local have = Player.ingredients[name] or 0
			if need > have then table.insert(missing, name) end
		end
		
		if table.getn(missing) > 0 then
			DisplayDialog { "ui/ui_missing.lua", text = "factory_insufficient", missing = missing }
		else
			-- 3. Minigame Launch Execution
			local factoryType = self.factory or category.factory
			if factoryType == "coffee" then 
				factoryType = "ui/coffee_factory.lua"
			else 
				factoryType = "ui/chocolate_factory.lua"
			end
			
			-- Temporarily suspend port processing and environments while the minigame layer is active
			SoundEvent("Stop_Environments")
			PausePortAnimations(true)
			
			production = DisplayDialog { factoryType, product = self, factory = t.factory }
			
			-- Restore normal state upon exiting the minigame
			PausePortAnimations(false)
			SoundEvent("Stop_Music")
			
			if factory.cadikey then 
				SoundEvent(factory.cadikey)
			else 
				SoundEvent(factory.port.cadikey)
			end
		end
	end
	
	if production then production = tonumber(production) end
	return (production or -1)
end