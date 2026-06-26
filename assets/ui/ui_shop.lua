--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Shop Interface)
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

require("ui/helpers.lua")

-------------------------------------------------------------------------------
-- Initialization & Setup
-------------------------------------------------------------------------------

local shop = gDialogTable.shop
local port = shop.port
local char = gDialogTable.char
local isFirstVisit = not Player.buildingsVisited[shop.name]

-- Record the character meeting in the global catalogue
if char then
	Player:MeetCharacter(char)
end

-- Rest merchant mood and extract identity
char:MakeNeutral()
local name = char.name

local transactionCompleted = false
local haggleSucceededOnce = false
local lastHaggleResult = nil

-------------------------------------------------------------------------------
-- UI: Dynamic Font Auto-Scaler
-------------------------------------------------------------------------------
-- Shrinks the font size to ensure merchant dialogue perfectly fits within the UI bounds.
local function SetDynamicKeeperText(text)
	if not text then text = "" end
	local function Ceil(x) return Floor(x + 0.99999) end
	
	local font_sizes_to_check = { 16, 15, 14 }
	local chars_per_line_map = { [16] = 54, [15] = 56, [14] = 58 }
	local segments = {}
	local current_pos = 1
	
	if text then
		local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
		while start_pos do
			table.insert(segments, string.sub(text, current_pos, start_pos - 1))
			current_pos = end_pos + 1
			start_pos, end_pos = string.find(text, "<br>", current_pos, true)
		end
		table.insert(segments, string.sub(text, current_pos))
	end
	if table.getn(segments) == 0 then segments = { text or "" } end
	
	local final_font_size = 14
	for _, current_font_size in ipairs(font_sizes_to_check) do
		local chars_per_line = chars_per_line_map[current_font_size]
		local total_lines = table.getn(segments) - 1
		for _, segment in ipairs(segments) do
			total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
		end
		if total_lines <= 2 then
			final_font_size = current_font_size
			break 
		end
	end
	
	local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
	SetLabel("keeper_text", formatted_text)
end

-------------------------------------------------------------------------------
-- Transaction Processing
-------------------------------------------------------------------------------

-- Executes when the player finalizes a product sale
local function SellProduct(prod, n, silent) 
	transactionCompleted = true
	if not silent then
		SoundEvent("sell")
	end
	
	-- 1. Milestone Tracking
	local itemKey = prod.code
	local categoryKey = prod.category.name
	local portKey = port.name
	local isFirstEver = not Player.firstEverSell[itemKey]

	Player.firstSell[portKey] = Player.firstSell[portKey] or {}
	local isFirstAtPort = not Player.firstSell[portKey][itemKey]
	
	Player.firstSellCategory[portKey] = Player.firstSellCategory[portKey] or {}
	local isFirstCategoryAtPort = not Player.firstSellCategory[portKey][categoryKey]

	if isFirstEver then
		Player.firstEverSell[itemKey] = true
		DebugOut("PLAYER", string.format("Global First: Player sold product '%s' for the first time.", itemKey))
	end
	if isFirstAtPort then
		Player.firstSell[portKey][itemKey] = true
		DebugOut("PLAYER", string.format("Local First: Player sold product '%s' at port '%s' for the first time.", itemKey, portKey))
	end
	if isFirstCategoryAtPort then
		Player.firstSellCategory[portKey][categoryKey] = true
		DebugOut("PLAYER", string.format("Category First: Player sold a '%s' product at port '%s' for the first time.", categoryKey, portKey))
	end
	
	-- 2. Execute Sale
	prod:Sell(n)
	
	-- Lock the UI element immediately if we've completely exhausted our inventory of this item
	if prod:GetInventory() == 0 then 
		EnableWindow(prod.code, false) 
	end
	
	-- 3. Merchant Mood Adjustment
	if lastHaggleResult == "bad" then
		char:MakeNeutral()
		DebugOut("CHAR", string.format("Merchant '%s' happiness restored to neutral after post-failed-haggle sale.", char.name))
	else
		char:MakeHappy()
	end
end

-------------------------------------------------------------------------------
-- Inventory Aggregation
-------------------------------------------------------------------------------

-- Read the player's current inventory and filter it down to only the products
-- that this specific shop is willing to purchase.
local count = 0
local products = {}

for code, _ in pairs(Player.products) do
	local prod = _AllProducts[code]
	local category = prod:GetMachinery()
	
	if prod and prod:GetInventory() > 0 and shop.buys[category.name] then
		count = count + 1
		table.insert(products, prod)
	end
end

table.sort(products, ProductOrderFunction)

-------------------------------------------------------------------------------
-- Dynamic Layout Engine
-------------------------------------------------------------------------------
-- Evaluates the number of products the player intends to sell and automatically scales 
-- and arranges the wooden crate icons to fit inside the UI dialogue box perfectly.

local layout =
{
	xLeft = 226,
	dx = 650 - 226,
	x = 226,
	y = 80,
	xDelta = 70,
	yDelta = 95,
	rows = 1,
	perRow = 1,
	rowCount = 0,
	count = count,
	productList = {},
	
	Initialize = function(self)
		self.perRow = Floor(self.dx / self.xDelta)
		if self.perRow == self.count and self.count > 3 then 
			self.perRow = Floor(self.count / 2) 
		end
		self.rows = Floor((self.count + self.perRow - 1) / self.perRow)
		self.perRow = Floor((self.count + self.rows - 1) / self.rows)
		
		self.xLeft = 226 + (self.dx - self.perRow * self.xDelta) / 2
		self.x = self.xLeft
	end,
}

-- -----------------------------------------------------
-- Layout Variant: 1-3 Items (Massive Icons)
-- -----------------------------------------------------
if count <= 3 then
	layout.xDelta = 123
	layout.yDelta = 135

	layout.AddCrate = function(self, product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList, Rollover { 
			x = self.x, y = self.y, fit = true, contents = "_AllProducts['" .. prod.code .. "']:ShopRolloverContents()",
			name = prod.code,
			command = function()
				local count = DisplayDialog { "ui/ui_buysell.lua", sell = prod, onOk = function(n) SellProduct(prod, n) end }
				if count and count > 0 then
					local thanks_key = "shop_thanks"
					if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_firstever"
					elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_firstatbuilding"
					elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_firstcategory" end
					
					SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code, nil, count))
					lastHaggleResult = nil
				end
			end,
			Bitmap { x = 0, y = 0, image = "image/button_box_up", prod:GetAppearanceBig(35, 46) },
			Text { x = 3, y = 124, w = layout.xDelta, h = 20, name = prod.code .. "_price", label = "#" .. priceLabel, font = { uiFontName, 18, BlackColor }, flags = kVAlignTop + kHAlignCenter },
		})
	end

-- -----------------------------------------------------
-- Layout Variant: 4-12 Items (Large Icons)
-- -----------------------------------------------------
elseif count <= 12 then
	layout.xDelta = 70
	layout.yDelta = 90

	layout.AddCrate = function(self, product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList, Rollover { 
			x = self.x, y = self.y, fit = true, contents = "_AllProducts['" .. prod.code .. "']:ShopRolloverContents()",
			name = prod.code,
			command = function()
				local count = DisplayDialog { "ui/ui_buysell.lua", sell = prod, onOk = function(n) SellProduct(prod, n) end }
				if count and count > 0 then
					local thanks_key = "shop_thanks"
					if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_firstever"
					elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_firstatbuilding"
					elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_firstcategory" end
					
					SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code, nil, count))
					lastHaggleResult = nil
				end
			end,
			Bitmap { x = 0, y = 0, image = "image/button_box_up", scale = 0.6, prod:GetAppearanceBig(21, 28, 0.6) },
			Text { x = 3, y = 75, w = layout.xDelta, h = 20, name = prod.code .. "_price", label = "#" .. priceLabel, flags = kVAlignTop + kHAlignCenter },
		})
	end

-- -----------------------------------------------------
-- Layout Variant: 13-16 Items (Medium Icons)
-- -----------------------------------------------------
elseif count <= 16 then
	layout.xDelta = 50
	layout.yDelta = 90

	layout.AddCrate = function(self, product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList, Rollover { 
			x = self.x, y = self.y, fit = true, contents = "_AllProducts['" .. prod.code .. "']:ShopRolloverContents()",
			name = prod.code,
			command = function()
				local count = DisplayDialog { "ui/ui_buysell.lua", sell = prod, onOk = function(n) SellProduct(prod, n) end }
				if count and count > 0 then
					local thanks_key = "shop_thanks"
					if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_firstever"
					elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_firstatbuilding"
					elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_firstcategory" end
					
					SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code, nil, count))
					lastHaggleResult = nil
				end
			end,
			Bitmap { x = 0, y = 0, image = "image/button_box_up", scale = 0.5, prod:GetAppearanceBig(18, 23, 0.5) },
			Text { x = 7, y = 65, w = layout.xDelta, h = 20, name = prod.code .. "_price", label = "#" .. priceLabel, flags = kVAlignTop + kHAlignCenter }
		})
	end

-- -----------------------------------------------------
-- Layout Variant: 17-27 Items (Small Icons)
-- -----------------------------------------------------
elseif count <= 27 then
	layout.xDelta = 47
	layout.yDelta = 55

	layout.AddCrate = function(self, product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList, Rollover { 
			x = self.x, y = self.y, fit = true, contents = "_AllProducts['" .. prod.code .. "']:ShopRolloverContents()",
			name = prod.code,
			command = function()
				local count = DisplayDialog { "ui/ui_buysell.lua", sell = prod, onOk = function(n) SellProduct(prod, n) end }
				if count and count > 0 then
					local thanks_key = "shop_thanks"
					if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_firstever"
					elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_firstatbuilding"
					elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_firstcategory" end
					
					SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code, nil, count))
					lastHaggleResult = nil
				end
			end,
			Bitmap { x = 0, y = 0, image = "image/button_box_up", scale = 0.35, prod:GetAppearanceBig(12, 15, 0.35) },
			Text { x = 0, y = 45, w = layout.xDelta, h = 20, name = prod.code .. "_price", label = "#" .. priceLabel, font = { uiFontName, 14, BlackColor }, flags = kVAlignTop + kHAlignCenter },
		})
	end

-- -----------------------------------------------------
-- Layout Variant: 28+ Items (Micro Icons / Lists)
-- -----------------------------------------------------
else
	layout.xDelta = 70
	layout.yDelta = 20
	layout.y = 65

	layout.AddCrate = function(self, product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList, Rollover { 
			x = self.x, y = self.y, fit = true, contents = "_AllProducts['" .. prod.code .. "']:ShopRolloverContents()",
			name = prod.code,
			command = function()
				local count = DisplayDialog { "ui/ui_buysell.lua", sell = prod, onOk = function(n) SellProduct(prod, n) end }
				if count and count > 0 then
					local thanks_key = "shop_thanks"
					if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_firstever"
					elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_firstatbuilding"
					elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_firstcategory" end
					
					SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code, nil, count))
					lastHaggleResult = nil
				end
			end,
			prod:GetAppearanceBig(0, 0, 0.25),
			Text { x = 16, y = 0, w = layout.xDelta - 16, h = layout.yDelta, name = prod.code .. "_price", label = "#" .. priceLabel, flags = kVAlignTop + kHAlignCenter },
		})
	end
end

-- Execute Grid Population
layout:Initialize()
for _, prod in ipairs(products) do
	layout:AddCrate(prod)
	layout.x = layout.x + layout.xDelta
	layout.rowCount = layout.rowCount + 1
	if layout.rowCount == layout.perRow then
		layout.y = layout.y + layout.yDelta
		layout.x = layout.xLeft
		layout.rowCount = 0
	end
end

-------------------------------------------------------------------------------
-- Haggle, Quick-Sell, & Shutdown Handlers
-------------------------------------------------------------------------------

local function Haggle()
	local response = DisplayDialog { "ui/ui_haggle.lua", char = char, shop = shop, pushedLuck = haggleSucceededOnce }
	lastHaggleResult = gHaggleSuccess

	if gHaggleSuccess == "good" then
		local response_key
		if haggleSucceededOnce then
			response_key = "shop_haggle_response_good_pushedluck"
		else
			response_key = "shop_haggle_response_good"
		end
		
		local response_text = GetMerchantDialogue(response_key, char, shop)
		if response_text then SetDynamicKeeperText(response_text) end

		haggleSucceededOnce = true
		shop:HaggleSuccess()
		char:MakeHappy()
		EnableWindow("haggle", (Player.rank > 1) and (not Player.haggleDisable[char.name]))
		
	elseif gHaggleSuccess == "bad" then
		local response_key
		if haggleSucceededOnce then
			response_key = "shop_haggle_response_bad_pushedluck"
		else
			response_key = "shop_haggle_response_bad"
		end
		
		local response_text = GetMerchantDialogue(response_key, char, shop)
		SetDynamicKeeperText(response_text)

		shop:HaggleFailure()
		char:MakeAngry()
		Player.haggleDisable[char.name] = true
		EnableWindow("haggle", false)
		
	elseif response then
		SetDynamicKeeperText(response)
	end
end

-- Completely liquidates all qualifying inventory the player is carrying in a single click
local function SellAll()
	if table.getn(products) > 0 then
		DebugOut("ECONOMY", string.format("Sell All button clicked by player in %s.", shop.name))
		SoundEvent("sell")
		
		local totalSold = 0
		local contextProduct = products[1]

		for _, prod in ipairs(products) do 
			local amount = prod:GetInventory()
			totalSold = totalSold + amount
			
			-- Pass 'true' to silence the repetitive cash register noise
			SellProduct(prod, amount, true) 
		end
		
		SetDynamicKeeperText(GetMerchantDialogue("shop_thanks", char, shop, lastHaggleResult, contextProduct.code, nil, totalSold))
		lastHaggleResult = nil
		
		char:MakeHappy()
		
		-- Immediately boot the player out to process the transaction
		CloseShopWindow()
	end
end

-- Triggered when the player clicks "Exit" to leave the shop
function CloseShopWindow()
	-- Update global tracking for historical highs/lows
	if products then
		for _, prod in ipairs(products) do
			local displayedPrice = prod:GetPrice()
			if port then Player.lastSeenPort[prod.code] = port.name end
			Player.lastSeenPrice[prod.code] = displayedPrice
			
			local modifier = Tips.GetPriceModifier(prod.code, port.name)
			local basePrice = Floor(displayedPrice / modifier)
			
			if not Player.lowPrice[prod.code] then Player.lowPrice[prod.code] = basePrice
			elseif basePrice < Player.lowPrice[prod.code] then Player.lowPrice[prod.code] = basePrice
			end
			
			if not Player.highPrice[prod.code] then Player.highPrice[prod.code] = basePrice
			elseif basePrice > Player.highPrice[prod.code] then Player.highPrice[prod.code] = basePrice
			end
		end
	end
	
	if transactionCompleted then SubTickSim() end
	
	FadeCloseWindow("ui_shop", "ok")
end

-------------------------------------------------------------------------------
-- Main UI Construction
-------------------------------------------------------------------------------

local welcome = nil

if layout.count > 0 then
	-- Player has items to sell
	local welcome_key = "shop_welcome"
	if shop:IsOwned() then 
		welcome_key = "shop_welcome_owned" 
	end
	welcome = GetMerchantDialogue(welcome_key, char, shop, nil, nil, isFirstVisit)

	MakeDialog
	{
		Window
		{
			x = 1000, y = 35, w = 701, h = 366, name = "ui_shop",
			Bitmap
			{
				x = 0, y = 9, image = "image/popup_back_shop",
				
				-- Main Interface Text
				SetStyle(C3CharacterDialogStyle),
				Text { x = 230, y = 36, w = 398, h = 40, name = "keeper_text" },
				
				-- Render the dynamically generated product layout
				Group(layout.productList),
				
				-- Character Identity Plate
				SetStyle(C3CharacterNameStyle),
				Text { x = 37, y = 241, w = 187, h = 20, label = "#" .. GetString(char.name), font = characterNameFont, flags = kVAlignCenter + kHAlignCenter },
				
				-- UI Controls
				SetStyle(C3ButtonStyle),
				Button { x = 202, y = 280, name = "haggle", label = "haggle", command = Haggle },
				Button { x = 334, y = 280, name = "sellall", label = "sell_all", command = SellAll },
				Button { x = 466, y = 280, name = "ok", label = "exit", default = true, cancel = true, command = CloseShopWindow },

				-- Help Button
				AppendStyle(C3RoundButtonStyle),
				Button { x = 598, y = 275, name = "help", label = "#?", command = function() HelpDialog("help_shop") end },
			},
			CharWindow { x = 45, y = 0, name = char.name, happiness = char:GetHappiness() },
		}
	}

	-- You cannot haggle in your own corporate stores
	EnableWindow("haggle", (Player.rank > 1) and (not Player.haggleDisable[char.name]) and (not shop:IsOwned()))

else
	-- Player's inventory is empty (or they only have items this shop refuses to buy)
	welcome = GetMerchantDialogue("shop_comeback", char, shop, nil, nil, isFirstVisit)
	MakeDialog
	{
		Window
		{
			x = 1000, y = 35, w = 701, h = 366, name = "ui_shop",
			Bitmap
			{
				x = 0, y = 9, image = "image/popup_back_shop",
				
				SetStyle(C3CharacterDialogStyle),
				Text { x = 241, y = 48, w = 414, h = 172, name = "keeper_text" },
				
				SetStyle(C3CharacterNameStyle),
				Text { x = 37, y = 241, w = 187, h = 20, label = "#" .. GetString(char.name), font = characterNameFont, flags = kVAlignCenter + kHAlignCenter },
				
				SetStyle(C3ButtonStyle),
				Button { x = 466, y = 280, name = "ok", label = "exit", default = true, cancel = true, command = CloseShopWindow },

				AppendStyle(C3RoundButtonStyle),
				Button { x = 598, y = 275, name = "help", label = "#?", command = function() HelpDialog("help_shop") end },
			},
			CharWindow { x = 45, y = 0, name = char.name, happiness = char:GetHappiness() },
		}
	}
end

if isFirstVisit then
	Player.buildingsVisited[shop.name] = true
	DebugOut("PLAYER", string.format("First visit to building recorded: %s", shop.name))
end

OpenBuilding("ui_shop", shop)
SetDynamicKeeperText(welcome)