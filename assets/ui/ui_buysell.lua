--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Cash Register Interface)
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- The script handles the Numpad popup window that appears when clicking a 
-- product/ingredient sack in a shop or market.

-- Determine the context of the transaction
local buy = gDialogTable.buy
local sell = gDialogTable.sell
local item = buy or sell
local price = item:GetPrice()

local onOk = gDialogTable.onOk

-- Determine the mathematical ceiling for this transaction
local max
if buy then
	-- Cap purchases at the player's available funds
	max = Floor(Player.money / price)
elseif sell then
	-- Cap sales at the player's physical inventory
	max = sell:GetInventory()
end

local dxWindow = 460
local dyWindow = 230

-------------------------------------------------------------------------------
-- Handlers & Execution
-------------------------------------------------------------------------------

local function cancelFunction()
	DebugOut("UI", "Transaction cancelled by player.")
	FadeCloseWindow("ui_register")
end

local function okFunction()
	-- Retrieve and validate the number inputted by the player
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	count = tonumber(count)
	
	-- Execute the functional callback passed from the parent Shop/Market script
	if count > 0 and type(onOk) == "function" then 
		DebugOut("UI", string.format("Executing %s transaction for amount: %d", (buy and "BUY" or "SELL"), count))
		onOk(count) 
		
		-- UI REFRESH FIX: Force the global Ledger UI to acknowledge the money delta immediately.
		-- This prevents the "money increasing" animation from lagging or glitching 
		-- while the register dialog is in the middle of its fade-out sequence.
		if LedgerUpdateDisplay then 
			LedgerUpdateDisplay() 
		end
	end
	
	FadeCloseWindow("ui_register", count)
end

-- Automatic max-out for selling
local function sellAll()
	SetLabel("count", tostring(max))
	okFunction()
end

-- Validation hook run every time a button is pressed to recalculate the subtotal
local function Update()
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	count = tonumber(count)
	
	-- Strict enforcement of the mathematical ceiling
	if max and count > max then
		count = max
		SetLabel("count", tostring(count))
	end
	
	-- Build the descriptive subtotal string
	local s
	local total = count * price
	
	if count == 0 then 
		s = ""
	else 
		s = " x " .. Dollars(price) .. " = " .. Dollars(total)
	end
	
	SetLabel("subtotal", s)
	
	-- Force the OS cursor back onto the input text box
	SetFocus("count")
end

-------------------------------------------------------------------------------
-- Keypad Mathematics
-------------------------------------------------------------------------------

local function PressDigit(n)
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	
	-- Standard numeric string append logic
	count = tonumber(count) * 10 + n
	
	if max and count > max then count = max end
	SetLabel("count", tostring(count))
	Update()
end

local function Add(n)
	local count = GetLabel("count") or "0"
	if count == "" then count = "0" end
	
	-- Mathematical addition logic
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
-- Dynamic String Resolution & Tooltips
-------------------------------------------------------------------------------

local buysell
local ask = Dollars(price)

if buy then
	buysell = "buy"
	-- For purchases, we default the prompt to the Plural unit representation
	-- because we are asking "How many [Sacks] of [Sugar] do you want?"
	local unit_name = item:GetUnitName(2) 
	ask = "#" .. GetText("buy_howmany", item:GetName(), ask, unit_name)
else
	buysell = "sell"
	-- For sales, we know exactly what we are liquidating, so we construct
	-- the accurate pluralized capacity right in the string.
	local invCount = item:GetInventory()
	local unit_name = item:GetUnitName(invCount)
	ask = "#" .. GetText("sell_howmany", item:GetName(), ask, tostring(invCount) .. " " .. unit_name)
end

-- Resolve the hover tooltip object type (Ingredients vs Products)
local rolloverContents
if buy then 
	rolloverContents = item.name .. ":BuySellRolloverContents()"
else 
	rolloverContents = "_AllProducts['" .. item.code .. "']:BuySellRolloverContents()"
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local numberGraphics = { "controls/checkover", "controls/checkup", "controls/checkover" }

MakeDialog
{
	name = "buysell",
	Bitmap
	{
		x = 287, y = 59, name = "ui_register", image = "image/popup_back_register",
		
		SetStyle(C3CharacterDialogStyle),
		
		-- Icon & Informational Text
		Rollover { x = 30, y = 24, w = 64, h = 64, contents = rolloverContents, fit = false, item:GetAppearanceBig() },
		Text { x = 110, y = 18, w = 245, h = 78, label = ask, flags = kHAlignLeft + kVAlignCenter },
		
		-- White Text Entry Field
		Bitmap { x = 70, y = 104, image = "image/popup_back_register_entryfield",
			TextEdit { 
				x = 4, y = 0, w = 114, h = kMax, 
				name = "count", 
				length = 7, 
				label = "0", 
				ignore = kNumbersOnly, clearinitial = true, onkey = Update, 
				flags = kVAlignCenter + kHAlignRight, font = { uiFontName, 18, WhiteColor } 
			},
		},
		
		-- Math Readout
		Text { x = 192, y = 104, w = 158, h = 36, name = "subtotal", flags = kHAlignLeft + kVAlignCenter },
		
		-- Phone-style Numpad
		SetStyle(C3SmallRoundButtonStyle),
		Button { x = 7, y = 86, label = "#C", command = function() Clear() end },
		Button { x = 23, y = 132, label = "#1", command = function() PressDigit(1) end },
		Button { x = 62, y = 132, label = "#2", command = function() PressDigit(2) end },
		Button { x = 101, y = 132, label = "#3", command = function() PressDigit(3) end },
		Button { x = 140, y = 132, label = "#4", command = function() PressDigit(4) end },
		Button { x = 179, y = 132, label = "#5", command = function() PressDigit(5) end },
		Button { x = 7, y = 169, label = "#6", command = function() PressDigit(6) end },
		Button { x = 46, y = 169, label = "#7", command = function() PressDigit(7) end },
		Button { x = 85, y = 169, label = "#8", command = function() PressDigit(8) end },
		Button { x = 124, y = 169, label = "#9", command = function() PressDigit(9) end },
		Button { x = 163, y = 169, label = "#0", command = function() PressDigit(0) end },

		-- Quick Add Buttons
		SetStyle(C3ButtonStyle),
		AppendStyle { scale = 0.6 },
		Button { x = 251, y = 134, label = "#+1", command = function() Add(1) end },
		Button { x = 251, y = 159, label = "#+10", command = function() Add(10) end },
		Button { x = 251, y = 184, label = "#+100", command = function() Add(100) end },
		Button { x = 251, y = 209, label = "#+1000", command = function() Add(1000) end },

		-- Confirm / Cancel Buttons
		SetStyle(C3LargeRoundButtonStyle),
		Button { x = 137, y = 228, command = okFunction, default = true, label = buysell },
		
		SetStyle(C3ButtonStyle),
		Button { x = 9, y = 258, name = "sell_all", command = sellAll, label = "sell_all" },
		Button { x = 232, y = 258, command = cancelFunction, label = "cancel", cancel = true },
	}
}

-- Safety constraints for active buttons
if not sell then EnableWindow("sell_all", false) end
if max then EnableWindow("number_max", false) end

Update()