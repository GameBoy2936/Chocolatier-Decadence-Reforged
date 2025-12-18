--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Money
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 120 -- MODIFIED: Increased width to fit new button labels

-- Function to set a custom amount
local function SetCustomAmount()
    DisplayDialog { 
        "dev/dev_enter_amount.lua", 
        prompt = "Enter new money amount:",
        onOk = function(amount) 
            Player:SetMoney(amount) 
            CloseWindow()
        end 
    }
end

-- NEW: Function to add a custom amount
local function AddCustomAmount()
    DisplayDialog { 
        "dev/dev_enter_amount.lua", 
        prompt = "Enter amount to add:",
        onOk = function(amount) 
            Player:AddMoney(amount) 
            CloseWindow()
        end 
    }
end

-- NEW: Function to remove a custom amount
local function RemoveCustomAmount()
    DisplayDialog { 
        "dev/dev_enter_amount.lua", 
        prompt = "Enter amount to remove:",
        onOk = function(amount) 
            Player:SubtractMoney(amount) 
            CloseWindow()
        end 
    }
end

MakeDialog
{
	name="dev_money",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		Button { x=0,y=h,w=w,h=h },
		Button { x=0,y=2*h,w=w,h=h, label="#<b>+</b> $1,000", command=function() Player:AddMoney(1000); CloseWindow() end },
		Button { x=0,y=3*h,w=w,h=h, label="#<b>+</b> $10,000", command=function() Player:AddMoney(10000); CloseWindow() end },
		Button { x=0,y=4*h,w=w,h=h, label="#<b>+</b> $100,000", command=function() Player:AddMoney(100000); CloseWindow() end },
		Button { x=0,y=5*h,w=w,h=h, label="#<b>+</b> $1,000,000", command=function() Player:AddMoney(1000000); CloseWindow() end },
		Button { x=0,y=6*h,w=w,h=h, label="#<b>+</b> $10,000,000", command=function() Player:AddMoney(10000000); CloseWindow() end },
		Button { x=0,y=7*h,w=w,h=h, label="#<b>+</b> $100,000,000", command=function() Player:AddMoney(10000000); CloseWindow() end },
		Button { x=0,y=8*h,w=w,h=h, label="#<b>-</b> $1,000", command=function() Player:SubtractMoney(1000); CloseWindow() end },
		Button { x=0,y=9*h,w=w,h=h, label="#<b>-</b> $10,000", command=function() Player:SubtractMoney(10000); CloseWindow() end },
		Button { x=0,y=10*h,w=w,h=h, label="#<b>-</b> $100,000", command=function() Player:SubtractMoney(100000); CloseWindow() end },
		Button { x=0,y=11*h,w=w,h=h, label="#<b>-</b> $1,000,000", command=function() Player:SubtractMoney(1000000); CloseWindow() end },
		Button { x=0,y=12*h,w=w,h=h, label="#<b>-</b> $10,000,000", command=function() Player:SubtractMoney(10000000); CloseWindow() end },
		Button { x=0,y=13*h,w=w,h=h, label="#<b>-</b> $100,000,000", command=function() Player:SubtractMoney(10000000); CloseWindow() end },
        -- MODIFIED: Added new buttons and adjusted layout
        Button { x=0,y=15*h,w=w,h=h, label="#Set Money...", command=SetCustomAmount },
        Button { x=0,y=16*h,w=w,h=h, label="#Add Money...", command=AddCustomAmount },
        Button { x=0,y=17*h,w=w,h=h, label="#Remove Money...", command=RemoveCustomAmount },
	},
}