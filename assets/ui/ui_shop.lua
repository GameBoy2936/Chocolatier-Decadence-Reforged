--[[---------------------------------------------------------------------------
	Chocolatier Three: Shop Dialog
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("ui/helpers.lua")

local shop = gDialogTable.shop
local port = shop.port
local char = gDialogTable.char

if char then
    Player:MeetCharacter(char)
end

if not Player.buildingsVisited[shop.name] then
	DebugOut("PLAYER", "First visit to shop: " .. shop.name)
	Player.buildingsVisited[shop.name] = true
end

char:MakeNeutral()
local name = char.name

local transactionCompleted = false
local haggleSucceededOnce = false
local lastHaggleResult = nil

local function SetDynamicKeeperText(text)
    if not text then text = "" end
    local function Ceil(x) return Floor(x + 0.99999) end
    local font_sizes_to_check = {16, 15, 14}
    local chars_per_line_map = { [16] = 50, [15] = 55, [14] = 60 }
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

local function SellProduct(prod, n, silent) -- Add 'silent' parameter
	transactionCompleted = true
	if not silent then
		SoundEvent("sell") -- Only play the sound if not silent
	end
	
    -- First Transaction Logic
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
        DebugOut("PLAYER", "First time ever selling product: " .. itemKey)
    end
    if isFirstAtPort then
        Player.firstSell[portKey][itemKey] = true
        DebugOut("PLAYER", "First time selling product '" .. itemKey .. "' at port '" .. portKey .. "'")
    end
    if isFirstCategoryAtPort then
        Player.firstSellCategory[portKey][categoryKey] = true
        DebugOut("PLAYER", "First time selling a '" .. categoryKey .. "' category product at port '" .. portKey .. "'")
    end
	
	prod:Sell(n)
	if prod:GetInventory() == 0 then EnableWindow(prod.code, false) end
	
	if lastHaggleResult == "bad" then
        -- If the last haggle was a failure, the character becomes neutral, not happy.
        char:MakeNeutral()
        DebugOut("CHAR", char.name .. " happiness set to neutral after post-failed-haggle sale.")
    else
        -- Otherwise, they become happy as usual.
        char:MakeHappy()
    end
end

-------------------------------------------------------------------------------

-- Gather available products into a sorted table
local count = 0
local products = {}
for code,_ in pairs(Player.products) do
	local prod = _AllProducts[code]
	local category = prod:GetMachinery()
	if prod and prod:GetInventory() > 0 and shop.buys[category.name] then
		count = count + 1
		table.insert(products, prod)
	end
end
table.sort(products, ProductOrderFunction)

-------------------------------------------------------------------------------
-- Box layouts

local layout =
{
	xLeft = 226,
	dx = 650-226,
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
		if self.perRow == self.count and self.count > 3 then self.perRow = Floor(self.count / 2) end
		self.rows = Floor((self.count + self.perRow - 1) / self.perRow)
		self.perRow = Floor((self.count + self.rows - 1) / self.rows)
		
		self.xLeft = 226 + (self.dx - self.perRow * self.xDelta) / 2
		self.x = self.xLeft
	end,
}

if count <= 3 then
	layout.xDelta = 123
	layout.yDelta = 135

	layout.AddCrate = function(self,product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList,
			Rollover { x=self.x,y=self.y, fit=true, contents="_AllProducts['"..prod.code.."']:ShopRolloverContents()",
				name=prod.code,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", sell=prod, onOk=function(n) SellProduct(prod, n) end }
                    if count and count > 0 then
                        local thanks_key = "shop_thanks"
                        if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_first_ever"
                        elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_first_at_building"
                        elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_first_category" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code))
                        lastHaggleResult = nil
                    end
				end,
				Bitmap { x=0,y=0, image="image/button_box_up", prod:GetAppearanceBig(35, 46), },
				Text { x=3,y=124,w=layout.xDelta,h=20, name=prod.code.."_price", label="#"..priceLabel, font= { uiFontName, 18, BlackColor }, flags=kVAlignTop+kHAlignCenter },
			})
	end
elseif count <= 12 then
	layout.xDelta = 70
	layout.yDelta = 90

	layout.AddCrate = function(self,product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList,
			Rollover { x=self.x,y=self.y, fit=true, contents="_AllProducts['"..prod.code.."']:ShopRolloverContents()",
				name=prod.code,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", sell=prod, onOk=function(n) SellProduct(prod, n) end }
                    if count and count > 0 then
                        local thanks_key = "shop_thanks"
                        if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_first_ever"
                        elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_first_at_building"
                        elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_first_category" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code))
                        lastHaggleResult = nil
                    end
				end,
				Bitmap { x=0,y=0, image="image/button_box_up", scale=.6, prod:GetAppearanceBig(21, 28, .6), },
				Text { x=3,y=75,w=layout.xDelta,h=20, name=prod.code.."_price", label="#"..priceLabel, flags=kVAlignTop+kHAlignCenter },
			})
	end
elseif count <= 16 then
	layout.xDelta = 50
	layout.yDelta = 90

	layout.AddCrate = function(self,product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList,
			Rollover { x=self.x,y=self.y, fit=true, contents="_AllProducts['"..prod.code.."']:ShopRolloverContents()",
				name=prod.code,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", sell=prod, onOk=function(n) SellProduct(prod, n) end }
                    if count and count > 0 then
                        local thanks_key = "shop_thanks"
                        if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_first_ever"
                        elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_first_at_building"
                        elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_first_category" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code))
                        lastHaggleResult = nil
                    end
				end,
				Bitmap { x=0,y=0, image="image/button_box_up", scale=.5, prod:GetAppearanceBig(18, 23, .5), },
				Text { x=7,y=65,w=layout.xDelta,h=20, name=prod.code.."_price", label="#"..priceLabel, flags=kVAlignTop+kHAlignCenter }
			})
	end
elseif count <= 27 then
	layout.xDelta = 47
	layout.yDelta = 55

	layout.AddCrate = function(self,product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList,
			Rollover { x=self.x,y=self.y, fit=true, contents="_AllProducts['"..prod.code.."']:ShopRolloverContents()",
				name=prod.code,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", sell=prod, onOk=function(n) SellProduct(prod, n) end }
                    if count and count > 0 then
                        local thanks_key = "shop_thanks"
                        if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_first_ever"
                        elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_first_at_building"
                        elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_first_category" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code))
                        lastHaggleResult = nil
                    end
				end,
				Bitmap { x=0,y=0, image="image/button_box_up", scale=.35, prod:GetAppearanceBig(12, 15, .35), },
				Text { x=0,y=45,w=layout.xDelta,h=20, name=prod.code.."_price", label="#"..priceLabel, font= { uiFontName, 14, BlackColor }, flags=kVAlignTop+kHAlignCenter },
			})
	end
else
	layout.xDelta = 70
	layout.yDelta = 20
	layout.y = 65

	layout.AddCrate = function(self,product)
		local prod = product
		local currentPrice = prod:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(prod.code, port.name)
		if modifier > 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>" end
		
		table.insert(self.productList,
			Rollover { x=self.x,y=self.y, fit=true, contents="_AllProducts['"..prod.code.."']:ShopRolloverContents()",
				name=prod.code,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", sell=prod, onOk=function(n) SellProduct(prod, n) end }
                    if count and count > 0 then
                        local thanks_key = "shop_thanks"
                        if not Player.firstEverSell[prod.code] then thanks_key = "shop_thanks_first_ever"
                        elseif not Player.firstSell[port.name][prod.code] then thanks_key = "shop_thanks_first_at_building"
                        elseif not Player.firstSellCategory[port.name][prod.category.name] then thanks_key = "shop_thanks_first_category" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, shop, lastHaggleResult, prod.code))
                        lastHaggleResult = nil
                    end
				end,
				prod:GetAppearanceBig(0, 0, .25),
				Text { x=16,y=0,w=layout.xDelta-16,h=layout.yDelta, name=prod.code.."_price", label="#"..priceLabel, flags=kVAlignTop+kHAlignCenter },
			})
	end
end

-- Lay out items
layout:Initialize()
for _,prod in ipairs(products) do
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

local function Haggle()
	local response = DisplayDialog { "ui/ui_haggle.lua", char=char, shop=shop}

    -- Store the result of the haggle.
    lastHaggleResult = gHaggleSuccess

	if gHaggleSuccess == "good" then
        local response_key
        if haggleSucceededOnce then
            -- Player succeeded a second time! Use the new positive pushed luck key.
            response_key = "shop_haggle_response_good_pushedluck"
        else
            -- This was the first success.
            response_key = "shop_haggle_response_good"
        end
        local response_text = GetMerchantDialogue(response_key, char, shop)
        if response_text then SetDynamicKeeperText(response_text) end

        haggleSucceededOnce = true -- Mark that a haggle has succeeded this visit.
		shop:HaggleSuccess()
		char:MakeHappy()
		EnableWindow("haggle", (Player.rank > 1) and (not Player.haggleDisable[char.name]))
        
	elseif gHaggleSuccess == "bad" then
        local response_key
        if haggleSucceededOnce then
            -- Player succeeded, then failed. Use the bad pushed luck key.
            response_key = "shop_haggle_response_bad_pushedluck"
        else
            -- This was the first haggle, and it failed.
            response_key = "shop_haggle_response_bad"
        end
        local response_text = GetMerchantDialogue(response_key, char, shop)
        SetDynamicKeeperText(response_text)

		shop:HaggleFailure()
		Player.haggleDisable[char.name] = true
		EnableWindow("haggle", false)
    elseif response then
        SetDynamicKeeperText(response)
    end
end

local function CloseShopWindow()
	if products then
		for _,prod in ipairs(products) do
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

local function SellAll()
    if table.getn(products) > 0 then
        DebugOut("UI", "Sell All button clicked.")
        SoundEvent("sell") -- Play the sound ONCE here.
        
        for _, prod in ipairs(products) do 
            -- Call SellProduct for each item, passing 'true' for the silent parameter.
            -- prod:GetInventory() gets the full amount of that product.
            SellProduct(prod, prod:GetInventory(), true) 
        end
        
        -- After all sales, give a generic "thanks" message and make the character happy.
        SetDynamicKeeperText(GetMerchantDialogue("shop_thanks", char, shop, lastHaggleResult))
        lastHaggleResult = nil
		
		-- A transaction will make this character happy
        char:MakeHappy()
        
        CloseShopWindow()
    end
end

-------------------------------------------------------------------------------

local welcome = nil

if layout.count > 0 then
    local welcome_key = "shop_welcome"
    if shop:IsOwned() then 
        welcome_key = "shop_welcome_owned" 
    end
    welcome = GetMerchantDialogue(welcome_key, char, shop, nil, nil, isFirstVisit)

	MakeDialog
	{
		Window
		{
			x=1000,y=35,w=701,h=366, name="ui_shop",
			Bitmap
			{
				x=0,y=9, image="image/popup_back_shop",
				
				SetStyle(C3CharacterDialogStyle),
				Text { x=240,y=36,w=348,h=40, name="keeper_text", label="#"..welcome },
				Group(layout.productList),
				
				SetStyle(C3CharacterNameStyle),
				Text { x=37,y=241,w=187,h=20, label="#"..GetString(char.name), font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
				
				SetStyle(C3ButtonStyle),
				Button { x=202,y=280, name="haggle", label="haggle", command=Haggle },
				Button { x=334,y=280, name="sellall", label="sell_all", command=SellAll },
				Button { x=466,y=280, name="ok", label="exit", default=true,cancel=true, command=CloseShopWindow },

				AppendStyle(C3RoundButtonStyle),
				Button { x=598,y=275, name="help", label="#?", command=function() HelpDialog("help_shop") end },
			},
			CharWindow { x=45,y=0, name=char.name, happiness=char:GetHappiness() },
		}
	}

	EnableWindow("haggle", (Player.rank > 1) and (not Player.haggleDisable[char.name]) and (not shop:IsOwned()))
else
	-- Player has nothing to sell
	MakeDialog
	{
		Window
		{
			x=1000,y=35,w=701,h=366, name="ui_shop",
			Bitmap
			{
				x=0,y=9, image="image/popup_back_shop",
				
				SetStyle(C3CharacterDialogStyle),
				Text { x=241,y=48,w=414,h=172, name="keeper_text", label="#"..GetMerchantDialogue("shop_comeback", char, shop, nil, nil, isFirstVisit) },
				
				SetStyle(C3CharacterNameStyle),
				Text { x=37,y=241,w=187,h=20, label="#"..GetString(char.name), font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
				
				SetStyle(C3ButtonStyle),
				Button { x=466,y=280, name="ok", label="exit", default=true,cancel=true, command=CloseShopWindow},

				AppendStyle(C3RoundButtonStyle),
				Button { x=598,y=275, name="help", label="#?", command=function() HelpDialog("help_shop") end },
			},
			CharWindow { x=45,y=0, name=char.name, happiness=char:GetHappiness() },
		}
	}
end

-- This block now ONLY handles setting the flag, which is correct.
if isFirstVisit then
    Player.buildingsVisited[shop.name] = true
    DebugOut("PLAYER", "First visit to building: " .. shop.name)
end

OpenBuilding("ui_shop", shop)
-- This final call is no longer needed as the text is set directly in the MakeDialog block.
-- if layout.count > 0 then SetDynamicKeeperText(welcome) end