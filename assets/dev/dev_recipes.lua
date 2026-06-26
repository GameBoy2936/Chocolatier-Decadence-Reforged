--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Dev Recipe Locks)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local ShowCategories = _CategoryOrder

-------------------------------------------------------------------------------
-- Action Handlers
-------------------------------------------------------------------------------

-- Toggles whether a specific system recipe is known by the player
local function ToggleRecipe(prod)
	if prod:IsKnown() then
		prod:Lock()
		SetLabel("dev_" .. prod.code, "+ " .. prod:GetName())
		DebugOut("DEV", string.format("Admin Action: Locked recipe '%s'.", prod:GetName()))
	else
		prod:Unlock()
		SetLabel("dev_" .. prod.code, "- " .. prod:GetName())
		DebugOut("DEV", string.format("Admin Action: Unlocked recipe '%s'.", prod:GetName()))
	end
end

-- Force unlocks all basic recipes in the game
local function UnlockAll()
	DebugOut("DEV", "Admin Action: Bulk-unlocked ALL standard recipes.")
	for name, prod in pairs(_AllProducts) do
		-- Failsafe: Custom UGR slots shouldn't be unlocked globally via generic logic
		if prod.category and prod.category.name ~= "user" then
			prod:Unlock()
			SetLabel("dev_" .. prod.code, "- " .. prod:GetName())
		end
	end
end

-------------------------------------------------------------------------------
-- UI Construction & Layout Engine
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 150
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

-- Grid Population Loop (Categories -> Products)
for _, cat in ipairs(ShowCategories) do
	local label = GetString(cat.name)
	label = string.upper(label)
	
	-- Inject bold Category Sub-Headers
	AddItem(Text { x = x, y = y, w = w, h = h, label = "#--" .. label .. ":" })
	
	for _, prod in ipairs(cat.products) do
		local name = "dev_" .. prod.code
		local labelStr
		
		-- Apply state indicator prefix (+ is Locked, - is Unlocked)
		if prod:IsKnown() then 
			labelStr = "#- "
		else 
			labelStr = "#+ "
		end
		labelStr = labelStr .. prod:GetName()
		
		local temp = prod
		AddItem(Button { 
			x = x, y = y, w = w, h = h, 
			name = name, label = labelStr, 
			command = function() ToggleRecipe(temp) end 
		})
	end
end

MakeDialog
{
	name = "dev_recipes",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = w, h = h, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Text { x = 0, y = h, w = 3*w, h = h, label = "#<b>Click a recipe with a [+] to unlock it. Click a recipe with a [-] to lock it.</b>" },
		Button { x = 0, y = 2*h, w = w, h = h, label = "#Unlock All", command = UnlockAll },
		
		Group(items),
	},
}