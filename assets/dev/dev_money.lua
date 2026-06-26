--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Money
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 120 

-------------------------------------------------------------------------------
-- Custom Value Parsers
-------------------------------------------------------------------------------

local function SetCustomAmount()
	DisplayDialog { 
		"dev/dev_enter_amount.lua", 
		prompt = "Enter exact new money amount:",
		onOk = function(amount) 
			DebugOut("DEV", string.format("Money Override: Setting exact player funds to %s", Dollars(amount)))
			Player:SetMoney(amount) 
			CloseWindow()
		end 
	}
end

local function AddCustomAmount()
	DisplayDialog { 
		"dev/dev_enter_amount.lua", 
		prompt = "Enter exact amount to inject:",
		onOk = function(amount) 
			DebugOut("DEV", string.format("Money Override: Injecting %s to player wallet.", Dollars(amount)))
			Player:AddMoney(amount) 
			CloseWindow()
		end 
	}
end

local function RemoveCustomAmount()
	DisplayDialog { 
		"dev/dev_enter_amount.lua", 
		prompt = "Enter exact amount to deduct:",
		onOk = function(amount) 
			DebugOut("DEV", string.format("Money Override: Deducting %s from player wallet.", Dollars(amount)))
			Player:SubtractMoney(amount) 
			CloseWindow()
		end 
	}
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	name = "dev_money",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = w, h = h, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Button { x = 0, y = h, w = w, h = h },
		
		-- Quick Adds
		Button { x = 0, y = 2*h, w = w, h = h, label = "#<b>+</b> $1,000", command = function() DebugOut("DEV", "Added +$1k"); Player:AddMoney(1000); CloseWindow() end },
		Button { x = 0, y = 3*h, w = w, h = h, label = "#<b>+</b> $10,000", command = function() DebugOut("DEV", "Added +$10k"); Player:AddMoney(10000); CloseWindow() end },
		Button { x = 0, y = 4*h, w = w, h = h, label = "#<b>+</b> $100,000", command = function() DebugOut("DEV", "Added +$100k"); Player:AddMoney(100000); CloseWindow() end },
		Button { x = 0, y = 5*h, w = w, h = h, label = "#<b>+</b> $1,000,000", command = function() DebugOut("DEV", "Added +$1m"); Player:AddMoney(1000000); CloseWindow() end },
		Button { x = 0, y = 6*h, w = w, h = h, label = "#<b>+</b> $10,000,000", command = function() DebugOut("DEV", "Added +$10m"); Player:AddMoney(10000000); CloseWindow() end },
		Button { x = 0, y = 7*h, w = w, h = h, label = "#<b>+</b> $100,000,000", command = function() DebugOut("DEV", "Added +$100m"); Player:AddMoney(100000000); CloseWindow() end },
		
		-- Quick Subtracts
		Button { x = 0, y = 8*h, w = w, h = h, label = "#<b>-</b> $1,000", command = function() DebugOut("DEV", "Removed -$1k"); Player:SubtractMoney(1000); CloseWindow() end },
		Button { x = 0, y = 9*h, w = w, h = h, label = "#<b>-</b> $10,000", command = function() DebugOut("DEV", "Removed -$10k"); Player:SubtractMoney(10000); CloseWindow() end },
		Button { x = 0, y = 10*h, w = w, h = h, label = "#<b>-</b> $100,000", command = function() DebugOut("DEV", "Removed -$100k"); Player:SubtractMoney(100000); CloseWindow() end },
		Button { x = 0, y = 11*h, w = w, h = h, label = "#<b>-</b> $1,000,000", command = function() DebugOut("DEV", "Removed -$1m"); Player:SubtractMoney(1000000); CloseWindow() end },
		Button { x = 0, y = 12*h, w = w, h = h, label = "#<b>-</b> $10,000,000", command = function() DebugOut("DEV", "Removed -$10m"); Player:SubtractMoney(10000000); CloseWindow() end },
		Button { x = 0, y = 13*h, w = w, h = h, label = "#<b>-</b> $100,000,000", command = function() DebugOut("DEV", "Removed -$100m"); Player:SubtractMoney(100000000); CloseWindow() end },
		
		-- Custom Inputs
		Button { x = 0, y = 15*h, w = w, h = h, label = "#Set Money...", command = SetCustomAmount },
		Button { x = 0, y = 16*h, w = w, h = h, label = "#Add Money...", command = AddCustomAmount },
		Button { x = 0, y = 17*h, w = w, h = h, label = "#Remove Money...", command = RemoveCustomAmount },
	},
}