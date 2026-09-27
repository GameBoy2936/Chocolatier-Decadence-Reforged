--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Master Recipe Book)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
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
-- Free Play Creation Libraries
------------------------------------------------------------------------------

if Player.IsFreePlay and Player:IsFreePlay() and gRecipeSelection and gRecipeSelection.category and gRecipeSelection.category.name == "user" then
	gCreationLibraryTab = gRecipeSelection.creationLibrary or gCreationLibraryTab or "free"
else
	gCreationLibraryTab = gCreationLibraryTab or "free"
end

function GetCreationLibraryProducts(tab)
	local out = {}
	local category = _AllCategories["user"]
	if not category then return out end
	for _, prod in ipairs(category.products or {}) do
		local library = prod.creationLibrary or "story"
		if library == tab then table.insert(out, prod) end
	end
	return out
end

local function UpdateCreationTabs()
	local show = Player.IsFreePlay and Player:IsFreePlay()
		and gCategorySelection and gCategorySelection.name == "user"
	EnableWindow("creation_story_tab", show and true or false)
	EnableWindow("creation_free_tab", show and true or false)
	if show then
		SetButtonToggleState("creation_story_tab", (gCreationLibraryTab == "story"))
		SetButtonToggleState("creation_free_tab", (gCreationLibraryTab ~= "story"))
	end
end

function SelectCreationLibrary(tab)
	if tab ~= "story" then tab = "free" end
	gCreationLibraryTab = tab
	gRecipePage = 1
	local products = GetCreationLibraryProducts(tab)
	gRecipeSelection = products[1]
	FillWindow("recipe_category", "ui/recipe_category.lua")
	FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
	UpdateCreationTabs()
end

------------------------------------------------------------------------------
-- Action Handlers
------------------------------------------------------------------------------

-- Updates the active category tab and resets the internal sub-windows
local function SelectCategory(cat)
	if not (gRecipeSelection and gRecipeSelection.category == cat) then
		DebugOut("UI", string.format("Recipe Book category switched to: %s", cat))
		gCategorySelection = _AllCategories[cat]
		if cat == "user" and Player.IsFreePlay and Player:IsFreePlay() then
			local products = GetCreationLibraryProducts(gCreationLibraryTab or "free")
			gRecipeSelection = products[1]
		else
			gRecipeSelection = gCategorySelection.products[1]
		end

		FillWindow("recipe_category", "ui/recipe_category.lua")
		FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
		UpdateCreationTabs()
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
			DebugOut("DEV", string.format("Forced production rate via Recipe Book for %s (yield: %d).", gRecipeSelection.code, val))

			-- Use QueueCommand to safely close the recipe book AFTER the number entry dialog closes
			QueueCommand(function() FadeCloseWindow("recipebook", "ok") end)
		end
	}
end

------------------------------------------------------------------------------
-- UI Construction
------------------------------------------------------------------------------

-- The Community Profile reuses the ordinary Recipe Book as a picker rather
-- than maintaining a separate copy of this screen. In that path only, the
-- normal "Use This Recipe" action becomes "Set Favourite" and Cancel is active.
local isCommunityProfilePicker = gCommunityProfileRecipePicker == true
local primaryActionLabel = isCommunityProfilePicker and GetString("community_set_favorite") or GetString("use_recipe")

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

	SetStyle(C3ButtonLongStyle),
	Button { x = 338, y = 75, scale = 0.7, name = "creation_story_tab", label = "#" .. GetString("story_creations"), type = kRadio, command = function() SelectCreationLibrary("story") end },
	Button { x = 493, y = 75, scale = 0.7, name = "creation_free_tab", label = "#" .. GetString("freeplay_creations"), type = kRadio, command = function() SelectCreationLibrary("free") end },

	SetStyle(C3ButtonStyle),
	Button { x = 338, y = 407, name = "use_recipe", label = "#" .. primaryActionLabel, default = true, command = function() FadeCloseWindow("recipebook", "ok") end },
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
if isCommunityProfilePicker then
	-- This is a selection dialog: the standard footer pair is the only commit/cancel
	-- path. recipe_recipe.lua will disable the primary action for invalid recipes.
	EnableWindow("use_recipe", true)
	EnableWindow("cancel", true)
	EnableWindow("ok", false)
	EnableWindow("dev_force_rate", false)
elseif gCurrentFactory then
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

UpdateCreationTabs()

OpenBuilding("recipebook", gDialogTable.building)
