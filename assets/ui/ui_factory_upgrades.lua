--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Factory Upgrades Dialog)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local factory = gDialogTable.factory
local char = gDialogTable.char

-------------------------------------------------------------------------------
-- Balances & Economics
-------------------------------------------------------------------------------

-- Recycler cost scales aggressively based on difficulty
local kRecyclerCost = 250000 
if Player.difficulty == 2 then kRecyclerCost = 350000 end
if Player.difficulty == 3 then kRecyclerCost = 500000 end

-- Font styling definitions
local categoryFont = { labelFontName, 18, BlackColor }
local costFont = { uiFontName, 17, Color(79, 9, 9, 255) } 
local statusFont = { uiFontName, 12, Color(0, 100, 0, 255) }

-------------------------------------------------------------------------------
-- Transaction Logic
-------------------------------------------------------------------------------

-- Handles the transaction to unlock a new product category line for this factory
local function BuyMachinery(catName, cost)
	if Player.money >= cost then
		local confirmText = GetText("factory_buymachinery", GetText(catName), Dollars(cost), Dollars(Player.money))
		local yn = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. confirmText }
		
		if yn == "yes" then
			Player:SubtractMoney(cost)
			factory:Equip(catName)
			SoundEvent("buy")
			DebugOut("FACTORY", string.format("Machinery upgrade purchased: %s installed in %s.", catName, factory.name))
			
			CloseWindow()
			QueueCommand(function() DisplayDialog { "ui/ui_factory_upgrades.lua", factory = factory, char = char } end)
		end
	else
		DebugOut("ECONOMY", string.format("Machinery purchase failed: Insufficient funds for %s.", catName))
		DisplayDialog { "ui/ui_generic.lua", text = "factory_insufficient" }
	end
end

-- Handles the transaction to install a factory powerup (Recyclers slow the minigame grid down)
local function BuyRecycler(catName, cost)
	if Player.money >= cost then
		local confirmText = GetText("factory_buyrecycler", GetText(catName), Dollars(cost))
		local yn = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. confirmText }
		
		if yn == "yes" then
			Player:SubtractMoney(cost)
			local category = _AllCategories[catName]
			factory:EnablePowerup(category, "recycler")
			SoundEvent("buy")
			DebugOut("FACTORY", string.format("Recycler powerup purchased for %s line in %s.", catName, factory.name))
			
			CloseWindow()
			QueueCommand(function() DisplayDialog { "ui/ui_factory_upgrades.lua", factory = factory, char = char } end)
		end
	else
		DebugOut("ECONOMY", string.format("Recycler purchase failed: Insufficient funds for %s.", catName))
		DisplayDialog { "ui/ui_generic.lua", text = "factory_insufficient" }
	end
end

-------------------------------------------------------------------------------
-- Grid Construction
-------------------------------------------------------------------------------

-- Maps localized category names to their respective visual hardware assets
local machineImages = {
	bar = "image/machine_1",
	beverage = "image/machine_2",
	infusion = "image/machine_3",
	blend = "image/machine_5",
	truffle = "image/machine_4",
	exotic = "image/machine_6"
}

-- Defines the exact 3x2 grid layout matrix
local upgradeSlots = {
	{ name = "bar",      col = 1, row = 1 },
	{ name = "beverage", col = 2, row = 1 },
	{ name = "infusion", col = 3, row = 1 },
	{ name = "truffle",  col = 1, row = 2 },
	{ name = "blend",    col = 2, row = 2 },
	{ name = "exotic",   col = 3, row = 2 }
}

-- Generates the UI container block for a single category slot in the upgrades grid
local function CreateUpgradeSlot(data)
	local cat = _AllCategories[data.name]
	if not cat then return Group{} end

	-- Calculate absolute pixel offsets
	local xBase = (data.col - 1) * 245 + 45
	local yBase = (data.row - 1) * 165 + 135
	
	local isEquipped = factory:IsEquipped(cat.name)
	local hasRecycler = factory:HasPowerup(cat, "recycler")
	local machineImg = machineImages[cat.name] or "image/machine_1"
	
	-- Dark tint used for unowned machine silhouettes (preserves transparency)
	local shadowTint = Color(50, 50, 50, 255)

	local slotGroup = {
		-- Header Label
		Text { x = xBase - 25, y = yBase, w = 250, h = 25, label = "#" .. GetString(cat.name), font = categoryFont, flags = kHAlignCenter + kVAlignTop },
	}

	-- 1. BASE MACHINERY SECTION
	local machX = xBase
	local machY = yBase + 10
	if isEquipped then
		table.insert(slotGroup, Bitmap { x = machX, y = machY, image = machineImg, scale = 0.40 })
		table.insert(slotGroup, Text { x = machX + 9, y = machY + 120, w = 100, h = 15, label = "#" .. GetString("upgrade_owned"), font = statusFont, flags = kHAlignCenter })
	else
		-- Unowned: Show tinted silhouette and purchase button
		table.insert(slotGroup, BitmapTint { x = machX, y = machY, image = machineImg, scale = 0.35, tint = shadowTint })
		local cost = cat.machinecost or 10000
		table.insert(slotGroup, Button { 
			x = machX - 15, y = machY + 70, w = 90, h = 25, scale = 0.9, label = "#" .. Dollars(cost), font = costFont, 
			command = function() BuyMachinery(cat.name, cost) end 
		})
	end

	-- 2. RECYCLER SECTION (Only applies to Chocolate-type categories)
	if cat.factory == "chocolate" then
		local recX = machX + 110
		local recY = machY + 20
		
		if isEquipped then
			if hasRecycler then
				-- Recycler Owned
				table.insert(slotGroup, Bitmap { x = recX, y = recY, image = "image/recycler_icon", scale = 0.55 })
				table.insert(slotGroup, Text { x = recX - 2, y = recY + 80, w = 80, h = 15, label = "#" .. GetString("upgrade_owned"), font = statusFont, flags = kHAlignCenter })
			else
				-- Machinery Owned, but Recycler Unowned
				table.insert(slotGroup, BitmapTint { x = recX, y = recY, image = "image/recycler_icon", scale = 0.55, tint = shadowTint })
				table.insert(slotGroup, Button { 
					x = recX - 25, y = recY + 65, w = 100, h = 25, scale = 0.9, label = "#" .. Dollars(kRecyclerCost), font = costFont, 
					command = function() BuyRecycler(cat.name, kRecyclerCost) end 
				})
			end
		else
			-- If the base machinery isn't owned, the recycler is totally greyed out and unavailable
			table.insert(slotGroup, BitmapTint { x = recX, y = recY, image = "image/recycler_icon", scale = 0.55, tint = Color(0, 0, 0, 80) })
		end
	end

	return Group(slotGroup)
end

-- Generate all 6 slots and stash them into an array
local gridItems = {}
for _, data in ipairs(upgradeSlots) do
	table.insert(gridItems, CreateUpgradeSlot(data))
end

-------------------------------------------------------------------------------
-- Main UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x = 1000, y = kCenter - 20, name = "ui_upgrades", fit = true,
		Bitmap
		{
			x = 0, y = 0, image = "image/popup_back_awards",
			
			-- Title Header (Text with white stroke outline effect)
			Text { x = 55, y = 20, w = 670, h = 100, name = "title_highlight", label = "#" .. GetString("title_upgrades"), font = { labelFontName, 50, WhiteColor }, flags = kVAlignCenter + kHAlignCenter },
			Text { x = 55, y = 20, w = 670, h = 100, name = "title", label = "#" .. GetString("title_upgrades"), font = { labelFontName, 50, BlackColor }, flags = kVAlignCenter + kHAlignCenter },

			SetStyle(C3ButtonStyle),
			Group(gridItems),
		},
		
		SetStyle(C3RoundButtonStyle),
		Button { x = 704, y = 406, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("ui_upgrades", "ok") end },
		Button { x = 734, y = 361, name = "help", label = "#?", command = function() HelpDialog("help_factory") end },
	}
}

-- Apply the explicit HTML stroke markup to the highlight label for visual pop
SetLabel("title_highlight", "<outline color='FFFFFF' size=2>" .. GetString("title_upgrades"))

CenterFadeIn("ui_upgrades")