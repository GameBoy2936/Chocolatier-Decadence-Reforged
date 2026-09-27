--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Cookbook Selection)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/render.lua")
require("ui/hiscore_countries.lua")

local state = gCommunityCookbook or {}
local item = state.items and state.items[state.selected_index or 0] or nil
local contents = {}

local metaFont = { standardFont, 14, BlackColor }
local smallMetaFont = { standardFont, 12, BlackColor }
local emphasisFont = { standardFont, 12, MaroonColor }
local ruleColor = Color(116, 82, 54, 60)

local function CompactRatingText(item)
	local count = tonumber(item.rating_count) or 0
	if count < 1 then
		return GetString("community_rating_unrated")
	end
	return string.format("%.1f / 5", tonumber(item.rating_average) or 0)
end

if not item then
	table.insert(contents, Text {
		x = 14, y = 25, w = 241, h = 120,
		label = "#" .. GetString("community_cookbook_select_hint"),
		font = metaFont,
		flags = kHAlignCenter + kVAlignCenter,
	})
	MakeDialog(contents)
	return
end

local availability = CommunityCreation.GetAvailability(item.creation)
local flag = ""
if item.author.nationality and item.author.nationality ~= "" and HighScoreCountries:IsValid(item.author.nationality) then
	flag = HighScoreCountries:GetFlag(item.author.nationality)
end

local availableText = GetTextParams("community_cookbook_available_count", { tostring(availability.available_ingredients), tostring(availability.total_ingredients) })

-- Availability is useful information even when the Cookbook was opened from
-- the Community Hub rather than from inside the Secret Test Kitchen.
local loadText
if availability.can_load then
	loadText = GetString("community_cookbook_can_load")
elseif not availability.category_unlocked then
	loadText = GetString("community_cookbook_category_locked")
else
	loadText = GetString("community_cookbook_missing_ingredients")
end

-- Mini ingredient icons sit flush-right on the availability row. Discovered
-- ingredients use the familiar Recipe Book rollover; undiscovered ingredients
-- remain silhouettes so browsing Community creations never reveals their names.
local ingredientIcons = {}
local ingredientCount = table.getn(item.creation.ingredients)
local ingredientIconStep = 17
local ingredientIconScale = 0.25
local ingredientIconRight = 252
local ingredientIconY = 116
local firstIngredientIconX = ingredientIconRight - (ingredientCount * ingredientIconStep)

for i = 1, ingredientCount do
	local name = item.creation.ingredients[i]
	local x = firstIngredientIconX + ((i - 1) * ingredientIconStep)
	local unlocked = Player and Player.labIngredients and Player.labIngredients[name]
	if unlocked and _AllIngredients and _AllIngredients[name] then
		table.insert(ingredientIcons, Rollover {
			x = x, y = ingredientIconY, w = 16, h = 16,
			contents = name .. ":RecipeBookRolloverContents()",
			CommunityCreationRender.Ingredient(name, 0, 0, ingredientIconScale, true),
		})
	else
		table.insert(ingredientIcons, CommunityCreationRender.Ingredient(name, x, ingredientIconY, ingredientIconScale, false))
	end
end

-- Reduce the handwritten title font only when a Community name needs the room.
local nameLength = string.len(item.creation.name or "")
local nameSize = 15
if nameLength > 38 then
	nameSize = 12.5
elseif nameLength > 27 then
	nameSize = 13.5
end
local nameFont = { labelFontName, nameSize, BlackColor }

-------------------------------------------------------------------------------
-- Upper preview card
-------------------------------------------------------------------------------
table.insert(contents, CommunityCreationRender.Appearance(item.creation, 3, 4, 0.6))

-- Identity / metadata column.
table.insert(contents, Text {
	x = 84, y = 2, w = 171, h = 51,
	label = "#" .. item.creation.name,
	font = nameFont,
	flags = kHAlignLeft + kVAlignCenter,
})

local authorX = 84
local authorW = 171
if flag ~= "" then
	table.insert(contents, Bitmap {
		x = 84, y = 50,
		image = flag,
		scale = 0.2,
	})
	authorX = 120
	authorW = 148
end

table.insert(contents, Text {
	x = authorX, y = 50, w = authorW, h = 19,
	label = "#" .. item.author.public_name,
	font = metaFont,
	flags = kHAlignLeft + kVAlignCenter,
})

local metadataText = GetString(item.creation.category) .. "  -  " .. GetString("community_stats_creation_loads") .. ": " .. tostring(item.load_count)
if item.is_owned then
	metadataText = GetString("community_your_creation") .. "  -  " .. metadataText
end
table.insert(contents, Text {
	x = 84, y = 70, w = 171, h = 20,
	label = "#" .. metadataText,
	font = smallMetaFont,
	flags = kHAlignLeft + kVAlignCenter,
})

-- Compact rating summary.
table.insert(contents, CommunityCreationRender.RatingStars(item.rating_average, 84, 90, 0.33))
table.insert(contents, Text {
	x = 176, y = 89, w = 79, h = 17,
	label = "#" .. CompactRatingText(item),
	font = smallMetaFont,
	flags = kHAlignLeft + kVAlignCenter,
})

-------------------------------------------------------------------------------
-- Availability / state block
-------------------------------------------------------------------------------
table.insert(contents, Rectangle {
	x = 12, y = 110, w = 245, h = 1,
	color = ruleColor,
})

table.insert(contents, Text {
	x = 16, y = 116, w = 237, h = 19,
	label = "#" .. availableText,
	font = emphasisFont,
	flags = kHAlignLeft + kVAlignCenter,
})

table.insert(contents, Group(ingredientIcons))

table.insert(contents, Text {
	x = 14, y = 138, w = 237, h = state.allow_load and 43,
	label = "#" .. loadText,
	font = metaFont,
	flags = kHAlignLeft + kVAlignTop,
})

-- The kitchen-only action sits with the availability message.
if state.allow_load then
	table.insert(contents, SetStyle(C3ButtonLongStyle))
	table.insert(contents, Button {
		x = 34, y = 160, scale = 1,
		name = "community_load",
		label = "#" .. GetString("community_load_into_kitchen"),
		command = CommunityCookbookLoadSelected,
	})
end

MakeDialog(contents)

if state.allow_load then
	EnableWindow("community_load", (not state.loading) and availability.can_load)
end
