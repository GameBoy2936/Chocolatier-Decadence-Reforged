--[[---------------------------------------------------------------------------
	Chocolatier Two Standard Item Buy/Sell
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local buy = gDialogTable.buy
local sell = gDialogTable.sell
local item = buy or sell
local price = item:GetPrice()

local onOk = gDialogTable.onOk

local max
if buy then
	max = Floor(Player.money / price)
elseif sell then
	max = sell:GetInventory()
end

local dxWindow = 460
local dyWindow = 230

-------------------------------------------------------------------------------

local function cancelFunction()
	FadeCloseWindow("ui_register")
end

local function okFunction()
	-- Retrieve number to buy or sell
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	count = tonumber(count)
	
    -- Perform the transaction
	if count > 0 and type(onOk) == "function" then 
        onOk(count) 
        
        -- FIX: Force the Ledger to acknowledge the money change immediately.
        -- This sets the new animation target while the Buy/Sell dialog is closing.
        if LedgerUpdateDisplay then LedgerUpdateDisplay() end
    end
    
	FadeCloseWindow("ui_register", count)
end

local function sellAll()
	SetLabel("count", tostring(max))
    -- okFunction now handles the update call
	okFunction()
end

local function Update()
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	count = tonumber(count)
	if max and count > max then
		count = max
		SetLabel("count", tostring(count))
	end
	
	local s
	local total = count * price
	if count == 0 then s = ""
	else s = " x " .. Dollars(price) .. " = " .. Dollars(total)
	end
	
	SetLabel("subtotal", s)
	SetFocus("count")
end

-------------------------------------------------------------------------------

local function PressDigit(n)
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	count = tonumber(count) * 10 + n
	if max and count > max then count = max end
	SetLabel("count", tostring(count))
	Update()
end

local function Add(n)
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	count = tonumber(count) + n
	if max and count > max then count = max end
	SetLabel("count", tostring(count))
	Update()
end

local function Clear()
	SetLabel("count", "0")
	Update()
end

-------------------------------------------------------------------------------

local buysell
local ask = Dollars(price)
if buy then
	buysell = "buy"
    -- Use dynamic unit names for the buy prompt
    local unit_plural = item.unit_plural or "sacks"
	ask = "#"..GetText("buy_howmany", item:GetName(), ask, unit_plural)
else
	buysell = "sell"
	ask = "#"..GetText("sell_howmany", item:GetName(), ask, tostring(item:GetInventory()))
end

-- TODO: Number buttons
local numberGraphics = { "controls/checkover", "controls/checkup", "controls/checkover" }

local rolloverContents
if buy then rolloverContents = item.name..":BuySellRolloverContents()"
else rolloverContents = "_AllProducts['"..item.code.."']:BuySellRolloverContents()"
end

MakeDialog
{
	name = "buysell",
	Bitmap
	{
		x=287,y=59, name="ui_register", image="image/popup_back_register",
		
		SetStyle(C3CharacterDialogStyle),
		Rollover { x=30,y=24, w=64,h=64, contents=rolloverContents, fit=false, item:GetAppearanceBig() },
		Text { x=110,y=18,w=245,h=78, label=ask, flags=kHAlignLeft+kVAlignCenter },
		
		Bitmap { x=70,y=104, image="image/popup_back_register_entryfield",
			TextEdit { x=4,y=0, w=114,h=kMax, name="count", length=7, label="0", ignore=kNumbersOnly, clearinitial=true, onkey=Update, flags=kVAlignCenter+kHAlignRight, font= {uiFontName,18,WhiteColor} },
		},
		Text { x=192,y=104, w=158,h=36, name="subtotal", flags=kHAlignLeft+kVAlignCenter },
		
		SetStyle(C3SmallRoundButtonStyle),
		Button { x=7,y=86, label="#C", command=function() Clear() end },
		Button { x=23,y=132, label="#1", command=function() PressDigit(1) end },
		Button { x=62,y=132, label="#2", command=function() PressDigit(2) end },
		Button { x=101,y=132, label="#3", command=function() PressDigit(3) end },
		Button { x=140,y=132, label="#4", command=function() PressDigit(4) end },
		Button { x=179,y=132, label="#5", command=function() PressDigit(5) end },
		Button { x=7,y=169, label="#6", command=function() PressDigit(6) end },
		Button { x=46,y=169, label="#7", command=function() PressDigit(7) end },
		Button { x=85,y=169, label="#8", command=function() PressDigit(8) end },
		Button { x=124,y=169, label="#9", command=function() PressDigit(9) end },
		Button { x=163,y=169, label="#0", command=function() PressDigit(0) end },

		SetStyle(C3ButtonStyle),
		AppendStyle { scale=0.6 },
		Button { x=251,y=134, label="#+1", command=function() Add(1) end },
		Button { x=251,y=159, label="#+10", command=function() Add(10) end },
		Button { x=251,y=184, label="#+100", command=function() Add(100) end },
		Button { x=251,y=209, label="#+1000", command=function() Add(1000) end },

		SetStyle(C3LargeRoundButtonStyle),
		Button { x=137,y=228, command=okFunction, default=true, label=buysell, },
		
		SetStyle(C3ButtonStyle),
		Button { x=9,y=258, name="sell_all", command=sellAll, label="sell_all", },
		Button { x=232,y=258, command=cancelFunction, label="cancel", cancel=true, },
	}
}

-- Only enable "SELL ALL" button when selling
if not sell then EnableWindow("sell_all", false) end

-- Only enable "MAX" button when a maximum number is supplied
if max then EnableWindow("number_max", false) end
Update()
