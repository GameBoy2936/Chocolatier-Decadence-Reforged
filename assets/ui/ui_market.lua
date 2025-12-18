--[[---------------------------------------------------------------------------
	Chocolatier Three: Market Dialog
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("ui/helpers.lua")

local market = gDialogTable.market
local port = market.port
local char = gDialogTable.char
local isFirstVisit = not Player.buildingsVisited[market.name]

if char then
    Player:MeetCharacter(char)
end

char:MakeNeutral()
local name = char.name

local transactionCompleted = false
local haggleSucceededOnce = false
local lastHaggleResult = nil

local function SetDynamicKeeperText(text)
    -- Dynamically adjusts font size for the market/shop keeper text box.
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

local function BuyIngredient(ing, n)
	transactionCompleted = true
	SoundEvent("buy")
	
    -- First Transaction Logic
    local itemKey = ing.name
    local portKey = port.name
    local isFirstEver = not Player.firstEverBuy[itemKey]
    
    Player.firstBuy[portKey] = Player.firstBuy[portKey] or {}
    local isFirstAtPort = not Player.firstBuy[portKey][itemKey]

    if isFirstEver then
        Player.firstEverBuy[itemKey] = true
        DebugOut("PLAYER", "First time ever buying ingredient: " .. itemKey)
    end
    if isFirstAtPort then
        Player.firstBuy[portKey][itemKey] = true
        DebugOut("PLAYER", "First time buying ingredient '" .. itemKey .. "' at port '" .. portKey .. "'")
    end
	
	ing:Buy(n)
	
	-- A transaction will make this character happy
	if lastHaggleResult == "bad" then
        -- If the last haggle was a failure, the character becomes neutral, not happy.
        char:MakeNeutral()
        DebugOut("CHAR", char.name .. " happiness set to neutral after post-failed-haggle purchase.")
    else
        -- Otherwise, they become happy as usual.
        char:MakeHappy()
    end
end

-------------------------------------------------------------------------------
-- Gather available ingredients into a sorted table
local inventory = gDialogTable.inventory or market.inventory
local ingredients = {}
for _,ing in ipairs(inventory) do
	if (not ing.locked) or Player.ingredientsAvailable[ing.name] then
		table.insert(ingredients, ing)
	end
end
table.sort(ingredients, IngredientOrderFunction)
local count = table.getn(ingredients)

-------------------------------------------------------------------------------
-- Sack layouts

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
	ingredientList = {},
	
	Initialize = function(self)
		self.perRow = Floor(self.dx / self.xDelta)
		if self.perRow == self.count and self.count > 3 then self.perRow = Floor((self.count + 1) / 2) end
		self.rows = Floor((self.count + self.perRow - 1) / self.perRow)
		self.perRow = Floor((self.count + self.rows - 1) / self.rows)
		
		self.xLeft = 226 + (self.dx - self.perRow * self.xDelta) / 2
		self.x = self.xLeft
	end,
}

if count <= 3 then
	layout.xDelta = 123
	layout.yDelta = 135

	layout.AddSack = function(self,ingredient)
		local ing = ingredient
		local currentPrice = ing:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(ing.name, port.name)
		if modifier > 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>" end
		
		if not Player.lastSeenPort[ing.name] then
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up",
											Bitmap { x=6,y=18, image="image/button_recipes_new_underlay", scale=120/100 },
											Bitmap { x=33,y=47, image="items/"..ing.name.."_big" } })
		else
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up",
											Bitmap { x=33,y=47, image="items/"..ing.name.."_big" } })
		end
		
		table.insert(self.ingredientList,
			Rollover { x=self.x+33,y=self.y+47, w=64,h=64, contents=ing.name..":MarketRolloverContents()", fit=false,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", buy=ing, onOk=function(n) BuyIngredient(ing, n) end }
                    if count and count > 0 then
                        local thanks_key = "market_thanks"
                        if not Player.firstEverBuy[ing.name] then thanks_key = "market_thanks_first_ever"
                        elseif not Player.firstBuy[port.name][ing.name] then thanks_key = "market_thanks_first_at_building" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, market, lastHaggleResult, ing.name))
                        lastHaggleResult = nil -- Reset haggle context after the thanks message is shown
                    end
				end,
			})
		table.insert(self.ingredientList, Text { x=self.x,y=self.y+128,w=123,h=20, name=ing.name.."_price", label="#"..priceLabel, font= { uiFontName, 18, BlackColor }, flags=kVAlignTop+kHAlignCenter })
	end
elseif count <= 10 then
	layout.xDelta = 74
	layout.yDelta = 90

	layout.AddSack = function(self,ingredient)
		local ing = ingredient
		local currentPrice = ing:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(ing.name, port.name)
		if modifier > 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>" end
		
		if not Player.lastSeenPort[ing.name] then
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up", scale=.6,
											Bitmap { x=4,y=10, image="image/button_recipes_new_underlay", scale=72/100 },
											Bitmap { x=20,y=28, image="items/"..ing.name.."_big", scale=.6, } })
		else
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up", scale=.6,
											Bitmap { x=20,y=28, image="items/"..ing.name.."_big", scale=.6, } })
		end
		
		table.insert(self.ingredientList,
			Rollover { x=self.x+20,y=self.y+28, w=38,h=38, contents=ing.name..":MarketRolloverContents()", fit=false,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", buy=ing, onOk=function(n) BuyIngredient(ing, n) end }
                    if count and count > 0 then
                        local thanks_key = "market_thanks"
                        if not Player.firstEverBuy[ing.name] then thanks_key = "market_thanks_first_ever"
                        elseif not Player.firstBuy[port.name][ing.name] then thanks_key = "market_thanks_first_at_building" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, market, lastHaggleResult, ing.name))
                        lastHaggleResult = nil
                    end
				end,
			})
		table.insert(self.ingredientList, Text { x=self.x,y=self.y+75,w=74,h=20, name=ing.name.."_price", label="#"..priceLabel, flags=kVAlignTop+kHAlignCenter })
	end
elseif count <= 16 then
	layout.xDelta = 53
	layout.yDelta = 90

	layout.AddSack = function(self,ingredient)
		local ing = ingredient
		local currentPrice = ing:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(ing.name, port.name)
		if modifier > 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>" end
		
		if not Player.lastSeenPort[ing.name] then
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up", scale=.5,
											Bitmap { x=3,y=9, image="image/button_recipes_new_underlay", scale=60/100 },
											Bitmap { x=17,y=24, image="items/"..ing.name.."_big", scale=.5, } })
		else
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up", scale=.5,
											Bitmap { x=17,y=24, image="items/"..ing.name.."_big", scale=.5, } })
		end

		table.insert(self.ingredientList,
			Rollover { x=self.x+16,y=self.y+24, w=32,h=32, contents=ing.name..":MarketRolloverContents()", fit=false,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", buy=ing, onOk=function(n) BuyIngredient(ing, n) end }
                    if count and count > 0 then
                        local thanks_key = "market_thanks"
                        if not Player.firstEverBuy[ing.name] then thanks_key = "market_thanks_first_ever"
                        elseif not Player.firstBuy[port.name][ing.name] then thanks_key = "market_thanks_first_at_building" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, market, lastHaggleResult, ing.name))
                        lastHaggleResult = nil
                    end
				end,
			})
		table.insert(self.ingredientList, Text { x=self.x,y=self.y+62,w=64,h=20, name=ing.name.."_price", label="#"..priceLabel, flags=kVAlignTop+kHAlignCenter })
	end
else
	layout.xDelta = 45
	layout.yDelta = 90

	layout.AddSack = function(self,ingredient)
		local ing = ingredient
		local currentPrice = ing:GetPrice()
		local priceLabel = Dollars(currentPrice)
		local modifier = Tips.GetPriceModifier(ing.name, port.name)
		if modifier > 1.0 then priceLabel = WorsePriceColor .. priceLabel .. "</font>"
		elseif modifier < 1.0 then priceLabel = BetterPriceColor .. priceLabel .. "</font>" end
		
		if not Player.lastSeenPort[ing.name] then
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up", scale=.45,
											Bitmap { x=4,y=8, image="image/button_recipes_new_underlay", scale=54/100 },
											Bitmap { x=16,y=21, image="items/"..ing.name.."_big", scale=.45, } })
		else
			table.insert(self.ingredientList, Bitmap { x=self.x,y=self.y, image="image/button_sack_up", scale=.45,
											Bitmap { x=16,y=21, image="items/"..ing.name.."_big", scale=.45, } })
		end

		table.insert(self.ingredientList,
			Rollover { x=self.x+15,y=self.y+21, w=30,h=30, contents=ing.name..":MarketRolloverContents()", fit=false,
				command = function()
					local count = DisplayDialog { "ui/ui_buysell.lua", buy=ing, onOk=function(n) BuyIngredient(ing, n) end }
                    if count and count > 0 then
                        local thanks_key = "market_thanks"
                        if not Player.firstEverBuy[ing.name] then thanks_key = "market_thanks_first_ever"
                        elseif not Player.firstBuy[port.name][ing.name] then thanks_key = "market_thanks_first_at_building" end
                        SetDynamicKeeperText(GetMerchantDialogue(thanks_key, char, market, lastHaggleResult, ing.name))
                        lastHaggleResult = nil
                    end
				end,
			})
		table.insert(self.ingredientList, Text { x=self.x-3.5,y=self.y+55,w=64,h=20, name=ing.name.."_price", label="#"..priceLabel, flags=kVAlignTop+kHAlignCenter })
	end
end


-- Lay out items
layout:Initialize()
for _,ing in pairs(ingredients) do
	layout:AddSack(ing)
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
    local block_haggle = false
    local refusal_key = nil

    if Player.activeTips then
        for _, tip in ipairs(Player.activeTips) do
            if tip.port == port.name and tip.type == "up" and tip.port_wide then
                block_haggle = true
                refusal_key = "market_haggle_refusal_tip" 
                break
            end
        end
    end

    if block_haggle then
        DebugOut("HAGGLE", "Haggle blocked by active PORT-WIDE price-up tip in " .. port.name)
        local refusal_text = GetMerchantDialogue(refusal_key, char, market)
        SetDynamicKeeperText(refusal_text)
        SoundEvent("negative_haggle")
        return -- Exit the function
    end

	local response = DisplayDialog { "ui/ui_haggle.lua", char=char, market=market }
	
    -- Store the result of the haggle.
    lastHaggleResult = gHaggleSuccess
	
	if gHaggleSuccess == "good" then
        local response_key
        if haggleSucceededOnce then
            -- Player succeeded a second time! Use the new positive pushed luck key.
            response_key = "market_haggle_response_good_pushedluck"
        else
            -- This was the first success.
            response_key = "market_haggle_response_good"
        end
        local response_text = GetMerchantDialogue(response_key, char, market)
        if response_text then SetDynamicKeeperText(response_text) end

        haggleSucceededOnce = true -- Mark that a haggle has succeeded this visit.
		market:HaggleSuccess()
		char:MakeHappy()
		EnableWindow("haggle", (Player.rank > 1) and (not Player.haggleDisable[char.name]))
        
	elseif gHaggleSuccess == "bad" then
        local response_key
        if haggleSucceededOnce then
            -- Player succeeded, then failed. Use the bad pushed luck key.
            response_key = "market_haggle_response_bad_pushedluck"
        else
            -- This was the first haggle, and it failed.
            response_key = "market_haggle_response_bad"
        end
        local response_text = GetMerchantDialogue(response_key, char, market)
        SetDynamicKeeperText(response_text)

		market:HaggleFailure()
		char:MakeAngry()
		Player.haggleDisable[char.name] = true
		EnableWindow("haggle", false)
    elseif response then 
        SetDynamicKeeperText(response)
    end
end

local function CloseMarketWindow()
	if ingredients then
		for _,ing in ipairs(ingredients) do
			local displayedPrice = ing:GetPrice()
			if port then Player.lastSeenPort[ing.name] = port.name end
			Player.lastSeenPrice[ing.name] = displayedPrice
			
			local modifier = Tips.GetPriceModifier(ing.name, port.name)
			local basePrice = Floor(displayedPrice / modifier)
			
			if not Player.lowPrice[ing.name] then Player.lowPrice[ing.name] = basePrice
			elseif basePrice < Player.lowPrice[ing.name] then Player.lowPrice[ing.name] = basePrice
			end
			
			if not Player.highPrice[ing.name] then Player.highPrice[ing.name] = basePrice
			elseif basePrice > Player.highPrice[ing.name] then Player.highPrice[ing.name] = basePrice
			end
		end
	end
	
	if transactionCompleted then SubTickSim() end
	
	FadeCloseWindow("ui_market", "ok")
end

-------------------------------------------------------------------------------

if isFirstVisit then
    Player.buildingsVisited[market.name] = true
    DebugOut("PLAYER", "First visit to building: " .. market.name)
end
local welcome = GetMerchantDialogue("market_welcome", char, market, nil, nil, isFirstVisit)

MakeDialog
{
	Window
	{
		x=1000,y=35,w=701,h=366, name="ui_market",
		Bitmap
		{
			x=0,y=9, image="image/popup_back_market",
			
			SetStyle(C3CharacterDialogStyle),
			Text { x=240,y=32,w=348,h=50, name="keeper_text" }, 
			Group(layout.ingredientList),
			
			SetStyle(C3CharacterNameStyle),
			Text { x=37,y=241,w=187,h=20, label="#"..GetString(char.name), font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
			
			SetStyle(C3ButtonStyle),
			Button { x=334,y=280, name="haggle", label="haggle", command=Haggle },
			Button { x=466,y=280, name="ok", label="exit", default=true,cancel=true, command=CloseMarketWindow },

			AppendStyle(C3RoundButtonStyle),
			Button { x=598,y=275, name="help", label="#?", command=function() HelpDialog("help_market") end },
		},
		CharWindow { x=45,y=0, name=char.name, happiness=char:GetHappiness() },
	}
}

EnableWindow("haggle", (Player.rank > 1) and (not Player.haggleDisable[char.name]))
OpenBuilding("ui_market", market)
SetDynamicKeeperText(welcome)