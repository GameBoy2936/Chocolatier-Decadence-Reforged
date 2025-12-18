--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Ingredients
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- Alphabetize the menu
local ShowIngredients = {}
for _,ing in pairs(_AllIngredients) do table.insert(ShowIngredients,ing) end
table.sort(ShowIngredients, IngredientAlphabetizeFunction)

-------------------------------------------------------------------------------

local function ToggleIngredient(ing)
	if ing:IsAvailable() then
		ing:Lock()
		SetLabel("dev_"..ing.name, "+ ".. GetString(ing.name))
	else
		ing:Unlock()
		SetLabel("dev_"..ing.name, "- ".. GetString(ing.name))
	end
end

local function UnlockAll()
	for name,ing in pairs(ShowIngredients) do
		ing:Unlock()
		SetLabel("dev_"..ing.name, "- ".. GetString(ing.name))
	end
end

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 140
local x = 0
local y = 3*h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	if y > 400 then
		x = x + w
		y = 3*h
	end
end

-------------------------------------------------------------------------------

for _,ing in pairs(ShowIngredients) do
	local name = "dev_" .. ing.name
	local label
	if ing:IsAvailable() then label = "#- "
	else label = "#+ "
	end
	label = label .. GetString(ing.name)
	local temp = ing
	AddItem (Button { x=x,y=y,w=w,h=h, name=name, label=label, command=function() ToggleIngredient(temp) end })
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_ingredients",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		TightText { x=0,y=h,w=3*w,h=h, label="#<b>Click an item with a + to unlock it. Click an item with a - to lock it.</b>" },
		Button { x=0,y=2*h,w=w,h=h, label="#<b>Unlock All</b>", command=UnlockAll },
		Group(items),
	},
}