--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Factory Status Dialog)
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local factory = gDialogTable.factory
gCurrentFactory = factory
local char = gDialogTable.char

-- Record the character meeting in the global catalogue
if char then
	Player:MeetCharacter(char)
end

local name = char.name
local info = Player.factories[factory.name]
local current = _AllProducts[info.current]

-------------------------------------------------------------------------------
-- UI Refresh & State Management
-------------------------------------------------------------------------------

-- Refreshes the inner status panel (which displays current production numbers)
local function UpdateDisplay()
	if info and info.current then
		local count, current = factory:GetProduction()
		FillWindow("configuration", "ui/ui_factory_content.lua")
		
		-- Update the dynamic label on the "Make" button based on machinery type
		local category = current:GetMachinery()
		SetLabel("make", GetString("make_" .. category.factory))
	end
end

local function CloseDialog()
	gCurrentFactory = nil
	FadeCloseWindow("ui_factory", "ok")
end

-------------------------------------------------------------------------------
-- Action Handlers
-------------------------------------------------------------------------------

-- Developer Cheat: Forces the factory to produce a specific amount of cases per week
local function devForceRate()
	local count, product = factory:GetProduction()
	DisplayDialog { 
		"dev/dev_enter_amount.lua", 
		prompt = "Force cases per week for " .. product:GetName() .. ":",
		initialValue = tostring(count),
		onOk = function(val)
			factory:SetProduction(product, val)
			UpdateDisplay()
			DebugOut("DEV", string.format("Forced production rate at %s to %d cases/week.", factory.name, val))
		end
	}
end

-- Triggers the factory minigame to set the weekly production yield
local function MakeChocolates()
	local count, product = factory:GetProduction()
	
	-- Tutorial Hook: Display a hint if the player is trying to make Milk Chocolate Bars
	-- for the very first time during the Rank 1 tutorial sequence.
	if product.code == "b01" and _AllQuests["tut_16"]:IsActive() then
		DebugOut("TUTORIAL", "Triggering tutorial 16 hint for configuring Milk Chocolate Bars.")
		DisplayDialog { "ui/ui_character_generic.lua", char = char, building = factory, text = "tut16_configure_hint" }
		return
	end
	
	DebugOut("FACTORY", string.format("Launching manufacturing minigame for product: %s", product:GetName()))
	
	-- RunMinigame halts the normal UI and returns the final score/count.
	count = product:RunMinigame { factory = factory, char = char }
	count = tonumber(count)
	
	if count >= 0 then
		factory:SetProduction(product, count)
		UpdateDisplay()
		
		-- Advance time by 1 week to account for the time spent manufacturing
		TickSim(1)
		CloseDialog()
	else
		DebugOut("FACTORY", "Minigame aborted or failed. Production rate unchanged.")
	end
end

-- Opens the recipe book to change what this factory is currently producing
local function ChangeConfiguration()
	DebugOut("FACTORY", string.format("Opening recipe book to configure factory: %s", factory.name))
	
	gRecipeSelection = _AllProducts[info.current]
	local ok = DisplayDialog { "ui/ui_recipes.lua", factory = factory, building = factory }
	local product = gRecipeSelection
	gRecipeSelection = nil
	
	if product and ok then
		-- If we have never successfully produced this item here before, force the minigame immediately
		if factory:GetProduction(product) == 0 then
			DebugOut("FACTORY", "New product configuration requires initial minigame run.")
			local count = product:RunMinigame { factory = factory, char = char }
			count = tonumber(count)
			
			if count >= 0 then
				factory:SetProduction(product, count)
				UpdateDisplay()
				TickSim(1)
			end
		else
			-- If we have historical production data for this item, just swap to it silently
			DebugOut("FACTORY", string.format("Swapped configuration to previously manufactured product: %s", product:GetName()))
			factory:SetProduction(product)
			UpdateDisplay()
		end
	end
end

-- Opens the specialized Upgrades UI to purchase new machinery
local function ManageUpgrades()
	DebugOut("UI", string.format("Opening upgrades menu for factory: %s", factory.name))
	DisplayDialog { "ui/ui_factory_upgrades.lua", factory = factory, char = char }
	UpdateDisplay()
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

-- Define the bitmap elements table dynamically so we can conditionally inject dev tools
local ui_elements = {
	x = 0, y = 49, image = "image/popup_back_dialog",
	
	-- Sub-panel container for the dynamic content UI
	Window { x = 241, y = 35, w = kMax, h = 185, name = "configuration" },
	
	-- Character Identity Plate
	SetStyle(C3CharacterNameStyle),
	Text { x = 41, y = 201, w = 187, h = 20, label = "#" .. GetString(char.name), font = characterNameFont, flags = kVAlignCenter + kHAlignCenter },
	
	-- Action Buttons
	SetStyle(C3ButtonStyle),
	Button { x = kCenter - 133, y = 240, name = "upgrades", label = "upgrades", command = ManageUpgrades },
	Button { x = kCenter, y = 240, name = "configure", label = "configure", command = ChangeConfiguration },
	Button { x = kCenter + 133, y = 240, name = "make", label = "make_chocolates", command = MakeChocolates },

	AppendStyle(C3RoundButtonStyle),
	Button { x = 529, y = 248, name = "ok", label = "ok", default = true, cancel = true, command = CloseDialog },
}

-- Conditional Injection: Add the Admin [SET RATE] button if developer mode is enabled
if CheckConfig("dev") then
	table.insert(ui_elements, Button { 
		x = kCenter - 233, y = 230, w = 60, h = 18, 
		label = "#SET RATE", 
		font = { devMenuStyle.font[1], 10, Color(255, 0, 0, 255) }, 
		command = devForceRate 
	})
end

MakeDialog
{
	Window
	{
		x = 1000, y = 35, w = 601, h = 366, name = "ui_factory",
		Bitmap(ui_elements),
		CharWindow { x = 49, y = 0, name = char.name, happiness = char:GetHappiness() },
	}
}

UpdateDisplay()
OpenBuilding("ui_factory", factory)