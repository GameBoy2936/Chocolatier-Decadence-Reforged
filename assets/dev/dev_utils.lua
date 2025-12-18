--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Utilities
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

function devRestartGame()
	local n=Player.name
	Player:Reset()
	Player.name=n
	SwapToModal("ui/portview.lua")
	local q = _AllQuests["tut_01"]
	q:Offer()
end

function devReloadPort()
	local file = "ports/"..Player.portName.."/"..Player.portName..".lua"
	dofile(file)
	PrepareCharactersForBuildings()
	SwapToModal("ui/portview.lua")
end

function devDesignProduct()
	CloseWindow()
	QueueCommand(function() DisplayDialog { "ui/ui_kitchen.lua" } end)
end

function devDesignSign()
	CloseWindow()
	QueueCommand(function() DisplayDialog {"ui/sign_basic.lua"} end)
end

function devSlotMachine()
	CloseWindow()
	QueueCommand(function() DisplayDialog {"ui/ui_slotselect.lua"} end)
end

function devReloadStyles()
	CloseWindow()
end

function devReloadStrings()
	CloseWindow()
end

function devCrates()
	CloseWindow()
	QueueCommand(function() DisplayDialog {"ui/ui_crates.lua"} end)
end

function devCurves()
	CloseWindow()
	QueueCommand(function() DoModal("dev/dev_animation.lua") end)
end

function devAddSlot(n)
	CloseWindow()
	Player.customSlots = (Player.customSlots or 0) + (n or 1)
	Player.questVariables.ugr_slots = Player.customSlots - (Player.categoryCount.user or 0)
end

-- NEW: Function to open the debug console
function devConsole(x,y)
    DisplayDialog { "dev/dev_console.lua", x=x, y=y }
end

local function ForceNewTip(tipType)
    local newTip
    if tipType == "ingredient" then
        newTip = Tips.GenerateIngredientTip()
    elseif tipType == "product" then
        newTip = Tips.GenerateProductTip()
    elseif tipType == "category" then
        newTip = Tips.GenerateCategoryTip()
    elseif tipType == "port" then
        newTip = Tips.GeneratePortTip()
    elseif tipType == "seasonal" then
        newTip = Tips.GenerateSeasonalTip()
    end

    if newTip then
        table.insert(Player.activeTips, newTip)
        if not newTip.seasonal_key then
            table.insert(Player.pendingAnnouncements, newTip)
        end
        DebugOut("DEV: Force-spawned new tip of type '" .. tipType .. "'")
        CloseWindow()
    else
        DebugOut("DEV: Failed to generate tip of type '" .. tipType .. "'. (Not enough data? e.g., no products made)")
    end
end

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 130
local x = 0
local y = 2*h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	if y > 550 then
		x = x + w
		y = 2*h
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_utils",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		Button { x=0,y=h,w=w,h=h, label="#Reload Current Port", command=devReloadPort },
		Button { x=0,y=2*h,w=w,h=h, label="#Restart Game", command=devRestartGame },
		Button { x=0,y=3*h,w=w,h=h, label="#Product Creator", command=devDesignProduct },
		Button { x=0,y=4*h,w=w,h=h, label="#Crates", command=devCrates },
		Button { x=0,y=5*h,w=w,h=h, label="#Curve Editor", command=devCurves },
		Button { x=0,y=6*h,w=w,h=h, label="#Add 1 Custom Slot", command=function() devAddSlot(1) end },
		Button { x=0,y=7*h,w=w,h=h, label="#Add 10 Custom Slots", command=function() devAddSlot(10) end },
		Button { x=0,y=8*h,w=w,h=h, label="#Slot Machine", command=devSlotMachine },
        Button { x=0,y=9*h,w=w,h=h, label="#New Ingredient Tip", command=function() ForceNewTip("ingredient") end },
        Button { x=0,y=10*h,w=w,h=h, label="#New Product Tip", command=function() ForceNewTip("product") end },
        Button { x=0,y=11*h,w=w,h=h, label="#New Category Tip", command=function() ForceNewTip("category") end },
        Button { x=0,y=12*h,w=w,h=h, label="#New Port-Wide Ing. Tip", command=function() ForceNewTip("port") end },
        Button { x=0,y=13*h,w=w,h=h, label="#New Seasonal Tip", command=function() ForceNewTip("seasonal") end },
        -- NEW: Button to open the debug console
        Button { x=0,y=14*h,w=w,h=h, label="#Debug Console", command=function() devConsole(0, gDialogTable.y+h) end },
	},
}