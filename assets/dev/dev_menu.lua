--[[---------------------------------------------------------------------------
	Chocolatier Three: Main Development Menu
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

function devUpdateQuest()
	SetLabel("dev_quest", "Q:"..tostring(Player.questPrimary))
end

-------------------------------------------------------------------------------

local function devUtils(x,y) DisplayDialog { "dev/dev_utils.lua", x=x,y=y } end
local function devQuests(x,y) DisplayDialog { "dev/dev_quests.lua", x=x,y=y } end
local function devQuestVars(x,y) DisplayDialog { "dev/dev_vars.lua", x=x,y=y } end
local function devPorts(x,y) DisplayDialog { "dev/dev_ports.lua", x=x,y=y } end
local function devIngredients(x,y) DisplayDialog { "dev/dev_ingredients.lua", x=x,y=y } end
local function devProducts(x,y) DisplayDialog { "dev/dev_products.lua", x=x,y=y } end
local function devRecipes(x,y) DisplayDialog { "dev/dev_recipes.lua", x=x,y=y } end
local function devMoney(x,y) DisplayDialog { "dev/dev_money.lua", x=x,y=y } end
local function devBuildings(x,y) DisplayDialog { "dev/dev_buildings.lua", x=x,y=y } end
local function devSaves(x,y) DisplayDialog { "dev/dev_saves.lua", x=x,y=y } end
local function devInventory(x,y) DisplayDialog { "dev/dev_inventory.lua", x=x,y=y } end

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]

function devMenu()
	if (CheckConfig("dev")) then
		return BSGWindow { x=kCenter,y=0, w=800,h=h, fit=true, color={1,1,1,.8}, name="dev_menu", SetStyle(devMenuStyle),
			Button { x=0,y=0,w=150,h=h, name="dev_quest", label="#Q:"..tostring(Player.questPrimary), command=function() devQuests(0,h) end },

			Button { x=150,y=0,w=70,h=h, label="#Inventory", command=function() devInventory(0,h) end },
			Button { x=220,y=0,w=80,h=h, label="#Ingredients", command=function() devIngredients(220,h) end },
			Button { x=300,y=0,w=60,h=h, label="#Recipes", command=function() devRecipes(0,h) end },
			Button { x=360,y=0,w=40,h=h, label="#Ports", command=function() devPorts(360,h) end },
			Button { x=400,y=0,w=60,h=h, label="#Buildings", command=function() devBuildings(400,h) end },
			Button { x=460,y=0,w=40,h=h, label="#Vars", command=function() devQuestVars(460,h) end },
			Button { x=500,y=0,w=60,h=h, label="#Saves", command=function() devSaves(500,h) end },
			
			Button { x=670,y=0,w=40,h=h, label="#Utils", command=function() devUtils(670,h) end },
			Button { x=710,y=0,w=90,h=h, label="#Money", command=function() devMoney(710,h) end },
		}
	else
		return Group{}
	end
end