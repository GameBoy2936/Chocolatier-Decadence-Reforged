--[[---------------------------------------------------------------------------
	Chocolatier Three: Recipe Book Dialog
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- Set default recipe if none is set OR player doesn't know the current recipe
if gRecipeSelection then gCategorySelection = gRecipeSelection.category
elseif gCategorySelection then gRecipeSelection = gCategorySelection.products[1]
else
	gRecipeSelection = _AllProducts["b01"]
	gCategorySelection = gRecipeSelection.category
end

------------------------------------------------------------------------------

local function SelectCategory(cat)
	if not (gRecipeSelection and gRecipeSelection.category == cat) then
		gCategorySelection = _AllCategories[cat]
		gRecipeSelection = gCategorySelection.products[1]

		FillWindow("recipe_category", "ui/recipe_category.lua")
		FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
	end
end

------------------------------------------------------------------------------

local categoryPositions =
{
	{ x=35,y=9, },
	{ x=142,y=9, },
	{ x=242,y=9, },
	{ x=342,y=9, },
	{ x=442,y=9, },
	{ x=542,y=9, },
	{ x=642,y=9, },
}

-- Categories
local categoryTabs = { BeginGroup() }
for i,cat in ipairs(_CategoryOrder) do
	local name = cat.name

	-- TODO: Hide coffee tabs until coffee is available
	-- TODO: Hide user tab until user has slots available
	local info = categoryPositions[i]
	local graphics = { "image/recipes_category_" .. i .. "_enabled", "image/recipes_category_" .. i .. "_used", }
	table.insert(categoryTabs, JukeboxCategoryButton { x=info.x, y=info.y, name=name, label=name, graphics=graphics, type=kRadio,
		flags=kVAlignCenter+kHAlignCenter,
		command=function() SelectCategory(name) end })
end

------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=9, name="recipebook", fit=true,
		Bitmap
		{
			x=4,y=16, image="image/popup_back_recipes",
			fit=false,
			
			Window { name="contents", x=0,y=0, fit=true,
				Window { name = "recipe_category", x=17,y=91,w=289,h=362, },
				Window { name = "recipe_recipe", x=311,y=98,w=457,h=354, },
			},
			Group(categoryTabs),
			
			SetStyle(C3ButtonStyle),
			Button { x=338,y=407, name="use_recipe", label="#"..GetString"use_recipe", default=true, command=function() FadeCloseWindow("recipebook", "ok") end },
			Button { x=473,y=407, name="cancel", label="#"..GetString"cancel", cancel=true, command=function() FadeCloseWindow("recipebook", nil) end },

--[[
-- DEBUG
Button { x=338,y=447, name="debug_config", label="#MAKE 25", default=true,
	command=function()
		gCurrentFactory:SetProduction(gRecipeSelection, 25)
		TickSim(1)
		FadeCloseWindow("recipebook", "ok")
	end },
]]--
	
		},
		Bitmap { image="image/popup_nameplate", x=229,y=0,
			Text { x=34,y=10,w=270,h=38, label="#"..GetString"title_recipes", font=nameplateFont, flags=kVAlignCenter+kHAlignCenter },
		},
		
		AppendStyle(C3RoundButtonStyle),
		Button { x=704,y=426, name="ok", label="ok", default=true, command=function() FadeCloseWindow("recipebook", "ok") end },
		Button { x=734,y=381, name="help", label="#?", command=function() HelpDialog("help_recipes") end },
	}
}

if gCurrentFactory then
	EnableWindow("ok", false)
else
-- DEBUG
	EnableWindow("debug_config", false)

	EnableWindow("use_recipe", false)
	EnableWindow("cancel", false)
end

FillWindow("recipe_category", "ui/recipe_category.lua")
FillWindow("recipe_recipe", "ui/recipe_recipe.lua")
if gCategorySelection then SetButtonToggleState(gCategorySelection.name, true) end

OpenBuilding("recipebook", gDialogTable.building)
