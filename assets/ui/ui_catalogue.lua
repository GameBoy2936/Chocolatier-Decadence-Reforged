--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Master Catalogue UI)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Sub-Module Hook Injections
-- ----------------------------------------------------------------------------

if CheckConfig("dev") then
	dofile("characters/asset_manifest.lua")
end

-- Load shared catalogue helpers (Dev Reveal state, Date formatting, etc.)
require("ui/catalogue_detail_common.lua")

-- ----------------------------------------------------------------------------
-- Global State Initialization
-- ----------------------------------------------------------------------------

gCatalogueCategory = gCatalogueCategory or "characters"
gCatalogueSelection = gCatalogueSelection or nil
gCatalogueTopIndex = gCatalogueTopIndex or 1
gCatalogueCategoryPage = gCatalogueCategoryPage or 1 -- Used for top-level tab pagination

-- Define the available master categories and map them to their respective list-view scripts
local categories = { "history", "characters", "ingredients", "ports" }

local list_scripts = {
	history = "ui/catalogue_history_list.lua",
	characters = "ui/catalogue_character_list.lua",
	ingredients = "ui/catalogue_ingredient_list.lua",
	ports = "ui/catalogue_port_list.lua",
}

local totalCategories = table.getn(categories)
local categoriesPerPage = 7 -- The maximum number of top-level tabs that visually fit on screen

-------------------------------------------------------------------------------
-- UI Navigation & Handlers
-------------------------------------------------------------------------------

-- Re-renders the inner windows (left list, right details)
local function UpdatePanels()
	local list_script = list_scripts[gCatalogueCategory] or "ui/quest_none.lua"
	FillWindow("catalogue_list", list_script)
	
	-- The detail window relies on a dispatcher script to route to the correct layout
	FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
end

-- Triggers when the player clicks a top-level category tab
local function SelectCategory(cat_key)
	if gCatalogueCategory ~= cat_key then
		DebugOut("UI", string.format("Catalogue Master Category switched to: %s", cat_key))
		gCatalogueCategory = cat_key
		gCatalogueSelection = nil
		gCatalogueTopIndex = 1
		UpdatePanels()
		
		-- Visually lock down the pressed tab
		for i = 1, totalCategories do
			local cat = categories[i]
			if cat then SetButtonToggleState(cat, cat == cat_key) end
		end
	end
end

-- Hook called by the child list scripts to tell the parent UI to enable/disable arrows
function UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)
	EnableWindow("catalogue_scrollUp", canScrollUp)
	EnableWindow("catalogue_scrollDown", canScrollDown)
end

-- Standard vertical pagination logic for the internal lists
local function ScrollUp()
	if gCatalogueTopIndex > 1 and gCatalogueLayout then
		gCatalogueTopIndex = gCatalogueTopIndex - gCatalogueLayout.items_per_row 
		if gCatalogueTopIndex < 1 then gCatalogueTopIndex = 1 end
		FillWindow("catalogue_list", list_scripts[gCatalogueCategory])
	end
end

local function ScrollDown()
	if gCatalogueLayout then
		gCatalogueTopIndex = gCatalogueTopIndex + gCatalogueLayout.items_per_row
		FillWindow("catalogue_list", list_scripts[gCatalogueCategory])
	end
end

-- Horizontal pagination logic for the top-level Category tabs
local function PrevCategoryPage()
	if gCatalogueCategoryPage > 1 then
		gCatalogueCategoryPage = gCatalogueCategoryPage - 1
		CloseWindow()
		QueueCommand(function() DisplayDialog("ui/ui_catalogue.lua") end)
	end
end

local function NextCategoryPage()
	if (gCatalogueCategoryPage * categoriesPerPage) < totalCategories then
		gCatalogueCategoryPage = gCatalogueCategoryPage + 1
		CloseWindow()
		QueueCommand(function() DisplayDialog("ui/ui_catalogue.lua") end)
	end
end

-------------------------------------------------------------------------------
-- Dynamic Tab Grid Generation
-------------------------------------------------------------------------------

local categoryPositions = {
	{ x = 35, y = 9 }, { x = 142, y = 9 }, { x = 242, y = 9 }, { x = 342, y = 9 },
	{ x = 442, y = 9 }, { x = 542, y = 9 }, { x = 642, y = 9 },
}

-- Dynamically generate and layout the active category tabs for the current page
local categoryTabs = { BeginGroup() }
local startIndex = (gCatalogueCategoryPage - 1) * categoriesPerPage + 1

for i = 1, categoriesPerPage do
	local cat_index = startIndex + i - 1
	local cat_key = categories[cat_index]
	
	if cat_key then
		local tempKey = cat_key
		local info = categoryPositions[i] -- Absolute position based on visual slot 1-7
		
		table.insert(categoryTabs, JukeboxCategoryButton { 
			x = info.x, y = info.y, name = tempKey, label = "catalogue_" .. tempKey, 
			graphics = { "image/recipes_category_" .. i .. "_enabled", "image/recipes_category_" .. i .. "_used" },
			type = kRadio, command = function() SelectCategory(tempKey) end 
		})
	end
end

-------------------------------------------------------------------------------
-- Main UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x = 1000, y = 9, name = "catalogue", fit = true,
		Bitmap
		{
			x = 4, y = 16, image = "image/popup_back_catalogue",
			
			-- Sub-window anchors for the dynamic child panels
			Window { name = "catalogue_list", x = 16, y = 91, w = 289, h = 484 },
			Window { name = "catalogue_detail", x = 311, y = 98, w = 457, h = 484 },
			
			-- Category Pagination
			Button { x = 5, y = 12, name = "prev_cat_page", command = PrevCategoryPage, graphics = { "image/button_arrow_left_up", "image/button_arrow_left_down", "image/button_arrow_left_over" }, scale = 0.75 },
			Group(categoryTabs),
			Button { x = 748, y = 12, name = "next_cat_page", command = NextCategoryPage, graphics = { "image/button_arrow_right_up", "image/button_arrow_right_down", "image/button_arrow_right_over" }, scale = 0.75 },

			-- List Item Pagination
			SetStyle(C3ButtonStyle),
			Button { x = 150, y = 510, name = "catalogue_scrollUp", command = ScrollUp, graphics = { "image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over" }, scale = 0.75 },
			Button { x = 210, y = 510, name = "catalogue_scrollDown", command = ScrollDown, graphics = { "image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over" }, scale = 0.75 },
		},
		
		Bitmap { image = "image/popup_nameplate", x = 228, y = 0,
			Text { x = 34, y = 10, w = 270, h = 38, label = "#" .. GetString("ledger_catalogue"), font = nameplateFont, flags = kVAlignCenter + kHAlignCenter },
		},
		
		SetStyle(C3RoundButtonStyle),
		Button { x = 734, y = 502, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("catalogue", "ok") end },
	},
}

-- Initial State Locking
UpdatePanels()
SetButtonToggleState(gCatalogueCategory, true)
EnableWindow("prev_cat_page", gCatalogueCategoryPage > 1)
EnableWindow("next_cat_page", (gCatalogueCategoryPage * categoriesPerPage) < totalCategories)

CenterFadeIn("catalogue")