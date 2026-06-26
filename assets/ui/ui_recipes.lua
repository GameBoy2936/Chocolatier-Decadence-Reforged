--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Master Recipe Book)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

------------------------------------------------------------------------------
-- State Initialization
------------------------------------------------------------------------------

-- Ensure the UI always opens to a valid, predictable state.
-- If the player has a specific recipe selected globally, default to that.
-- Otherwise, fall back to the very first Basic Chocolate Bar.
if gRecipeSelection then 
	gCategorySelection = gRecipeSelection.category
elseif gCategorySelection then 
	gRecipeSelection = gCategorySelection.products[1]
else
	gRecipeSelection = _AllProducts["b01"]
	gCategorySelection = gRecipeSelection.category
end

------------------------------------------------------------------------------
-- Action Handlers
------------------------------------------------------------------------------

-- Updates the active category tab and resets the internal sub-windows
local function SelectCategory(cat)
	if not (gRecipeSelection and gRecipeSelection.category == cat) then
		DebugOut("UI", string.format("Recipe Book category switched to: %s", cat))
		gCategorySelection = _AllCategories[cat]
		gRecipeSelection = gCategorySelection.products[1]

		FillWindow("recipe_category", "ui/recipe_category.lua")
		FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
	end
end

-- Developer Cheat: Allows an admin to force the weekly production yield of a 
-- recipe without needing to play the factory minigame.
local function devForceRate()
	if not gCurrentFactory or not gRecipeSelection then return end
	
	local count = gCurrentFactory:GetProduction(gRecipeSelection)
	DisplayDialog { 
		"dev/dev_enter_amount.lua", 
		prompt = "ADMIN: Force production rate for " .. gRecipeSelection:GetName() .. ":",
		initialValue = tostring(count),
		onOk = function(val)
			gCurrentFactory:SetProduction(gRecipeSelection, val)
			DebugOut("DEV", string.format("ADMIN: Forced production rate via Recipe Book for %s (Yield: %d).", gRecipeSelection.code, val))
			
			-- Use QueueCommand to safely close the recipe book AFTER the number entry dialog closes
			QueueCommand(function() FadeCloseWindow("recipebook", "ok") end)
		end
	}
end

------------------------------------------------------------------------------
-- UI Construction
------------------------------------------------------------------------------

-- Hardcoded X/Y coordinates for the 7 category tabs across the top of the book
local categoryPositions = {
	{ x = 35, y = 9 },
	{ x = 142, y = 9 },
	{ x = 242, y = 9 },
	{ x = 342, y = 9 },
	{ x = 442, y = 9 },
	{ x = 542, y = 9 },
	{ x = 642, y = 9 },
}

-- Generate the interactive category tabs
local categoryTabs = { BeginGroup() }
for i, cat in ipairs(_CategoryOrder) do
	local name = cat.name
	local info = categoryPositions[i]
	
	-- Map the enabled and selected states of the tab images
	local graphics = { "image/recipes_category_" .. i .. "_enabled", "image/recipes_category_" .. i .. "_used" }
	
	table.insert(categoryTabs, JukeboxCategoryButton { 
		x = info.x, y = info.y, name = name, label = name, 
		graphics = graphics, type = kRadio, flags = kVAlignCenter + kHAlignCenter,
		command = function() SelectCategory(name) end 
	})
end

-- Assemble the core UI elements
local ui_elements = {
	x = 0, y = 16, image = "image/popup_back_recipes", fit = false,
	
	Window { 
		name = "contents", x = 0, y = 0, fit = true,
		Window { name = "recipe_category", x = 17, y = 91, w = 289, h = 362 },
		Window { name = "recipe_recipe", x = 311, y = 98, w = 457, h = 354 },
	},
	Group(categoryTabs),
	
	SetStyle(C3ButtonStyle),
	Button { x = 338, y = 407, name = "use_recipe", label = "#" .. GetString("use_recipe"), default = true, command = function() FadeCloseWindow("recipebook", "ok") end },
	Button { x = 473, y = 407, name = "cancel", label = "#" .. GetString("cancel"), cancel = true, command = function() FadeCloseWindow("recipebook", nil) end },
}

-- Inject the Admin "Set Rate" button if developer mode is active and the book was 
-- opened from a factory (meaning we have an active target to apply the rate to).
if CheckConfig("dev") and gCurrentFactory then
	table.insert(ui_elements, Button { 
		x = 608, y = 407, 
		name = "dev_force_rate",
		label = "#SET RATE", 
		font = { uiFontName, 16, BlackColor }, 
		command = devForceRate 
	})
end

MakeDialog
{
	Window
	{
		x = 1000, y = 9, name = "recipebook", fit = true,
		Bitmap(ui_elements),
		
		Bitmap { image = "image/popup_nameplate", x = 224, y = 0,
			Text { x = 34, y = 10, w = 270, h = 38, label = "#" .. GetString("title_recipes"), font = nameplateFont, flags = kVAlignCenter + kHAlignCenter },
		},
		
		AppendStyle(C3RoundButtonStyle),
		Button { x = 704, y = 426, name = "ok", label = "ok", default = true, command = function() FadeCloseWindow("recipebook", "ok") end },
		Button { x = 734, y = 381, name = "help", label = "#?", command = function() HelpDialog("help_recipes") end },
	}
}

-- If we opened the recipe book strictly for reference (i.e. from the main Ledger),
-- we disable the functional assignment buttons to prevent errors.
if gCurrentFactory then
	EnableWindow("ok", false)
else
	EnableWindow("use_recipe", false)
	EnableWindow("cancel", false)
	EnableWindow("dev_force_rate", false)
end

-- Render the internal windows
FillWindow("recipe_category", "ui/recipe_category.lua")
FillWindow("recipe_recipe", "ui/recipe_recipe.lua")

-- Force the UI to reflect the active tab
if gCategorySelection then 
	SetButtonToggleState(gCategorySelection.name, true) 
end

OpenBuilding("recipebook", gDialogTable.building)