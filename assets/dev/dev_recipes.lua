--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Recipes
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local ShowCategories = _CategoryOrder

local function ToggleRecipe(prod)
	if prod:IsKnown() then
		prod:Lock()
		SetLabel("dev_"..prod.code, "+ ".. prod:GetName())
	else
		prod:Unlock()
		SetLabel("dev_"..prod.code, "- ".. prod:GetName())
	end
end

local function UnlockAll()
	for name,prod in pairs(_AllProducts) do
		prod:Unlock()
		SetLabel("dev_"..prod.code, "- ".. prod:GetName())
	end
end

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 150
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

for _,cat in ipairs(ShowCategories) do
	local label = GetString(cat.name)
	label = string.upper(label)
	AddItem (Text { x=x,y=y,w=w,h=h, label="#--"..label..":" })
	for _,prod in ipairs(cat.products) do
		local name = "dev_" .. prod.code
		local label
		if prod:IsKnown() then label = "#- "
		else label = "#+ "
		end
		label = label .. prod:GetName()
		local temp = prod
		AddItem (Button { x=x,y=y,w=w,h=h, name=name, label=label, command=function() ToggleRecipe(temp) end })
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_recipes",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		Text { x=0,y=h,w=3*w,h=h, label="#<b>Click a recipe with a + to unlock it. Click a recipe with a - to lock it.</b>" },
		Button { x=0,y=2*h,w=w,h=h, label="#Unlock All", command=UnlockAll },
		Group(items),
	},
}