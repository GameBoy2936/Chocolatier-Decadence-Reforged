--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Dev Ingredient Locks)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Gathers all global ingredients and explicitly alphabetizes them for easier searching
local ShowIngredients = {}
for _, ing in pairs(_AllIngredients) do table.insert(ShowIngredients, ing) end
table.sort(ShowIngredients, IngredientAlphabetizeFunction)

-------------------------------------------------------------------------------
-- Action Handlers
-------------------------------------------------------------------------------

-- Toggles whether an ingredient is naturally available or locked away from generation
local function ToggleIngredient(ing)
	if ing:IsAvailable() then
		ing:Lock()
		SetLabel("dev_" .. ing.name, "+ " .. GetString(ing.name))
		DebugOut("DEV", string.format("Admin Action: Locked ingredient '%s' (Will not spawn).", GetString(ing.name)))
	else
		ing:Unlock()
		SetLabel("dev_" .. ing.name, "- " .. GetString(ing.name))
		DebugOut("DEV", string.format("Admin Action: Unlocked ingredient '%s' (Eligible to spawn).", GetString(ing.name)))
	end
end

-- Forces every single ingredient in the game state to become active
local function UnlockAll()
	DebugOut("DEV", "Admin Action: Bulk-unlocked ALL ingredients.")
	for name, ing in pairs(ShowIngredients) do
		ing:Unlock()
		SetLabel("dev_" .. ing.name, "- " .. GetString(ing.name))
	end
end

-------------------------------------------------------------------------------
-- UI Construction & Layout Engine
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 140
local x = 0
local y = 3 * h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	-- Push to new column if approaching bounds
	if y > 400 then
		x = x + w
		y = 3 * h
	end
end

-- Grid Population Loop
for _, ing in pairs(ShowIngredients) do
	local name = "dev_" .. ing.name
	local label
	
	-- Apply state indicator prefix (+ is Locked, - is Unlocked)
	if ing:IsAvailable() then 
		label = "#- "
	else 
		label = "#+ "
	end
	
	label = label .. GetString(ing.name)
	local temp = ing
	
	AddItem(Button { 
		x = x, y = y, w = w, h = h, 
		name = name, label = label, 
		command = function() ToggleIngredient(temp) end 
	})
end

MakeDialog
{
	name = "dev_ingredients",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = w, h = h, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		TightText { x = 0, y = h, w = 3*w, h = h, label = "#<b>Click an item with a [+] to unlock it. Click an item with a [-] to lock it.</b>" },
		Button { x = 0, y = 2*h, w = w, h = h, label = "#<b>Unlock All</b>", command = UnlockAll },
		
		Group(items),
	},
}