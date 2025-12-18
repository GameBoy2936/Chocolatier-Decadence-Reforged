--[[---------------------------------------------------------------------------
	Chocolatier Three: Inventory Dialog
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local ingredientList = {}
local xLeft = 26
local yTop = 60	--69
local xRight = 387
local yBottom = 411

local x = xLeft
local y = yTop

-- Count available ingredients
local count = 0
for _,ing in pairs(_IngredientOrder) do
	if ing:GetInventory() > 0 then count = count + 1 end
end

local xSpacing = 60	-- kItemSize + 5
local ySpacing = kItemSize + 25

if count <= 20 then
	xSpacing = 70
	ySpacing = 90
elseif count <= 36 then
	xSpacing = 60
	ySpacing = 57
elseif count <= 42 then
	xSpacing = 60
	ySpacing = 50
elseif count <= 52 then
	xSpacing = 90
	ySpacing = 26
else
	xSpacing = 90
	ySpacing = 23
end

-- Display ingredients in order (TODO: What order??)
-- Choose ingredient size based on count
for _,ing in pairs(_IngredientOrder) do
	if ing:GetInventory() > 0 then
		if count <= 20 then
			table.insert(ingredientList,
				Rollover { x=x,y=y, contents=ing.name..":InventoryRolloverContents()",
					Bitmap { x=0,y=0, image="items/"..ing.name.."_big", name=ing.name },
					Text { x=0,y=64,w=64,h=20, label=ing:GetInventory(), flags=kVAlignTop+kHAlignCenter },
				})
		elseif count <= 42 then
			table.insert(ingredientList,
				Rollover { x=x,y=y, contents=ing.name..":InventoryRolloverContents()",
					Bitmap { x=8,y=0, image="items/"..ing.name, name=ing.name },
					Text { x=0,y=32,w=48,h=20, label=ing:GetInventory(), flags=kVAlignTop+kHAlignCenter },
				})
		elseif count <= 52 then
			table.insert(ingredientList,
				Rollover { x=x,y=y, contents=ing.name..":InventoryRolloverContents()",
					Bitmap { x=0,y=0, image="items/"..ing.name, name=ing.name, scale=0.75 },
					Text { x=26,y=0,w=xSpacing-26,h=24, label=ing:GetInventory(), flags=kVAlignCenter+kHAlignLeft },
				})
		else
			table.insert(ingredientList,
				Rollover { x=x,y=y, contents=ing.name..":InventoryRolloverContents()",
					Bitmap { x=0,y=0, image="items/"..ing.name, name=ing.name, scale=0.75 },
					Text { x=26,y=0,w=xSpacing-26,h=24, label=ing:GetInventory(), flags=kVAlignCenter+kHAlignLeft },
				})
		end

		x=x+xSpacing
		if x > xRight - xSpacing then
			y = y + ySpacing
			x = xLeft
		end
	end
end

-- Display products in order (TODO: What order??)
xLeft = 400
xRight = 760
x = xLeft
y = yTop
local productList = {}

-- Count available products
count = 0
for _,prod in pairs(_AllProducts) do
	if prod:GetInventory() > 0 then count = count + 1 end
end

xSpacing = 60	-- kItemSize + 5
ySpacing = kItemSize + 25

if count <= 20 then
	xSpacing = 70
	ySpacing = 90
elseif count <= 34 then
	xSpacing = 60
	ySpacing = 57
elseif count <= 52 then
	xSpacing = 90
	ySpacing = 26
elseif count <= 64 then
	xSpacing = 90
	ySpacing = 23
else
	xSpacing = 90
	ySpacing = 18
end

for _,prod in pairs(_AllProducts) do
	if prod:GetInventory() > 0 then
		if count <= 20 then
			table.insert(productList, 
				Rollover { x=x,y=y, contents="_AllProducts['"..prod.code.."']:InventoryRolloverContents()",
					prod:GetAppearanceBig(),
					Text { x=0,y=64,w=64,h=20, label=prod:GetInventory(), flags=kVAlignTop+kHAlignCenter }
				})
		elseif count <= 34 then
			table.insert(productList,
				Rollover { x=x,y=y, contents="_AllProducts['"..prod.code.."']:InventoryRolloverContents()",
					prod:GetAppearance(8,0),
					Text { x=0,y=32,w=48,h=20, label=prod:GetInventory(), flags=kVAlignTop+kHAlignCenter }
				})
		elseif count <= 52 then
			table.insert(productList,
				Rollover { x=x,y=y, contents="_AllProducts['"..prod.code.."']:InventoryRolloverContents()",
					prod:GetAppearance(0,0,.75),
					Text { x=26,y=0,w=xSpacing-26,h=24, label=prod:GetInventory(), flags=kVAlignCenter+kHAlignLeft }
				})
		elseif count <= 64 then
			table.insert(productList,
				Rollover { x=x,y=y, contents="_AllProducts['"..prod.code.."']:InventoryRolloverContents()",
					prod:GetAppearance(0,0,.75),
					Text { x=26,y=0,w=xSpacing-26,h=24, label=prod:GetInventory(), flags=kVAlignCenter+kHAlignLeft }
				})
		else
			table.insert(productList,
				Rollover { x=x,y=y, contents="_AllProducts['"..prod.code.."']:InventoryRolloverContents()",
					prod:GetAppearance(0,0,.5),
					Text { x=18,y=0,w=xSpacing-18,h=18, label=prod:GetInventory(), flags=kVAlignCenter+kHAlignLeft }
				})
		end

		x=x+xSpacing
		if x > xRight - xSpacing then
			y = y + ySpacing
			x = xLeft
		end
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=0,name="inventory",fit=true,
		Bitmap
		{
			x=0,y=13, image="image/popup_back_inventory",
			SetStyle(controlStyle),
			
			Group(ingredientList),
			Group(productList),
		},
		Bitmap { image="image/popup_nameplate", x=223,y=0,
			Text { x=34,y=10,w=270,h=38, label="#"..GetString"title_inventory", font=nameplateFont, flags=kVAlignCenter+kHAlignCenter },
		},
		SetStyle(C3RoundButtonStyle),
		Button { x=704,y=426, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("inventory", "ok") end },
	},
}

CenterFadeIn("inventory")
