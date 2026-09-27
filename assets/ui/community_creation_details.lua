--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Creation Details)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/api.lua")
ClearStringCache()
require("community/render.lua")
require("ui/hiscore_countries.lua")

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local context = gDialogTable or {}
local item = context.item
local allowLoad = context.allow_load == true
if not item then
	return
end

local normalized, normalizeError = CommunityApi.NormalizeItem(item)
if not normalized then
	DebugOut("COMMUNITY", "Could not open creation details: " .. tostring(normalizeError))
	return
end
item = normalized

local availability = CommunityCreation.GetAvailability(item.creation)
local isOwned = CommunityApi.IsOwned(item.id, item)

local headerFont = { labelFontName, 16, MaroonColor }
local titleLength = string.len(item.creation.name or "")
local titleSize = 24
if titleLength > 48 then
	titleSize = 22
elseif titleLength > 36 then
	titleSize = 20
end
local nameFont = { standardFont, titleSize, BlackColor }
local authorFont = { standardFont, 14, BlackColor }
local metaFont = { standardFont, 13, BlackColor }
local smallMetaFont = { standardFont, 12, BlackColor }
local metaLabelFont = { labelFontName, 12, MaroonColor }
local descriptionFont = { standardFont, 14, BlackColor }
local ingredientFont = { standardFont, 12, BlackColor }
local lockedFont = { labelFontName, 12, BlackColor }
local statusFont = { standardFont, 14, MaroonColor }
local ruleColor = Color(116, 82, 54, 65)

local countryName = ""
local flag = ""
if item.author.nationality and item.author.nationality ~= "" and HighScoreCountries:IsValid(item.author.nationality) then
	countryName = HighScoreCountries:GetName(item.author.nationality)
	flag = HighScoreCountries:GetFlag(item.author.nationality)
end

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function FormatDate(value)
	value = tostring(value or "")
	if string.len(value) < 10 then
		return value
	end
	local year = tonumber(string.sub(value, 1, 4))
	local month = tonumber(string.sub(value, 6, 7))
	local day = tonumber(string.sub(value, 9, 10))
	local months =
	{
		"Jan",
		"Feb",
		"Mar",
		"Apr",
		"May",
		"Jun",
		"Jul",
		"Aug",
		"Sep",
		"Oct",
		"Nov",
		"Dec",
	}
	if not year or not month or not day or not months[month] then
		return value
	end
	return tostring(day) .. " " .. months[month] .. " " .. tostring(year)
end

-- Rating display scale.
local ratingStarScale = 0.46
local ratingStarPrefix = "community_details_rating_star_"

local function RatingText()
	local count = tonumber(item.rating_count) or 0
	if count < 1 then
		return GetString("community_rating_unrated")
	end
	return GetTextParams("community_rating_summary_compact", { string.format("%.1f", tonumber(item.rating_average) or 0), tostring(count) })
end

local function TagValuesText()
	local tags = item.tags or {}
	if table.getn(tags) == 0 then
		return GetString("catalogue_none")
	end
	local names = {}
	for _, tag in ipairs(tags) do
		local key = tag == "coffee" and "coffee" or ("community_tag_" .. tag)
		table.insert(names, GetString(key))
	end
	return table.concat(names, "  -  ")
end

local function CloseDetails()
	FadeCloseWindow("community_creation_details", "ok")
end

local function LoadIntoKitchen()
	if not allowLoad or not availability.can_load then
		return
	end
	gCommunityKitchenImport =
	{
		creation = item.creation,
		id = item.id,
		metadata =
		{
			rating_average = item.rating_average or 0,
			rating_count = item.rating_count or 0,
			load_count = item.load_count or 0,
			tags = item.tags or {},
			author = item.author or {},
			is_owned = item.is_owned == true,
		},
	}
	FadeCloseWindow("community_creation_details", "load")
end

local function ViewCreatorProfile()
	local profileId = item.author and tostring(item.author.profile_id or "") or ""
	if profileId == "" or CommunityTransport.IsBusy() then
		return
	end
	DisplayDialog { "ui/community_public_profile.lua", profile_id = profileId }
end

local function RateCreation()
	if isOwned or not CommunityAccount.IsSignedIn() or CommunityTransport.IsBusy() then
		return
	end
	gCommunityCreationRatingResult = nil
	DisplayDialog { "ui/community_creation_rating.lua", creation_id = item.id, creation_name = item.creation.name }
	local summary = gCommunityCreationRatingResult
	gCommunityCreationRatingResult = nil
	if summary then
		item.rating_average = summary.rating_average or item.rating_average
		item.rating_count = summary.rating_count or item.rating_count
		CommunityCreationRender.UpdateRatingStars(ratingStarPrefix, item.rating_average, ratingStarScale)
		SetLabel("community_details_rating_meta", RatingText())
	end
end

local function DeleteCreation()
	if not isOwned or CommunityTransport.IsBusy() then
		return
	end
	local answer = DisplayDialog {
		"ui/ui_generic_yn.lua",
		text = "#" .. GetTextParams("community_delete_confirm", { item.creation.name }),
	}
	if answer ~= "yes" then
		return
	end

	SetLabel("community_details_status", GetString("community_delete_sending"))
	EnableWindow("community_delete", false)
	if allowLoad then
		EnableWindow("community_load", false)
	end

	CommunityApi.Delete(item.id, function(body, response, err)
		if err then
			if not CommunityAccount.IsSignedIn() then
				DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_session_expired") }
				FadeCloseWindow("community_creation_details", "account_required")
				return
			end
			SetLabel("community_details_status", GetTextParams("community_delete_error", { tostring(err) }))
			EnableWindow("community_delete", true)
			if allowLoad and availability.can_load then
				EnableWindow("community_load", true)
			end
			return
		end
		gCommunityCreationDeleted = item.id
		FadeCloseWindow("community_creation_details", "deleted")
	end)
end

-------------------------------------------------------------------------------
-- Identity block
-------------------------------------------------------------------------------
local identityContents = {}
local authorX = 190
local authorW = 265
if flag ~= "" then
	table.insert(identityContents, Bitmap {
		x = 190, y = 91,
		image = flag,
		scale = 0.16,
	})
	authorX = 220
	authorW = 235
end

table.insert(identityContents, Text {
	x = authorX, y = 87, w = authorW, h = 23,
	label = "#" .. item.author.public_name .. (isOwned and ("  -  " .. GetString("community_your_creation")) or ""),
	font = authorFont,
	flags = kHAlignLeft + kVAlignCenter,
})

table.insert(identityContents, Text {
	x = 190, y = 111, w = 265, h = 18,
	label = "#" .. (countryName ~= "" and (countryName .. "  -  ") or "") .. GetString(item.creation.category) .. "  -  " .. GetString("community_stats_creation_loads") .. ": " .. tostring(item.load_count),
	font = metaFont,
	flags = kHAlignLeft + kVAlignCenter,
})

table.insert(identityContents, Text {
	x = 190, y = 128, w = 265, h = 18,
	label = "#" .. GetTextParams("community_shared_date", { FormatDate(item.created_at_utc) }),
	font = smallMetaFont,
	flags = kHAlignLeft + kVAlignCenter,
})

-------------------------------------------------------------------------------
-- Ingredient row, centered for anywhere from one to six ingredients.
-------------------------------------------------------------------------------
local ingredientContents = {}
local ingredientCount = table.getn(item.creation.ingredients)
local firstIngredientX = 250 - (((ingredientCount - 1) * 68) / 2) - 23
for i = 1, ingredientCount do
	local name = item.creation.ingredients[i]
	local unlocked = Player and Player.labIngredients and Player.labIngredients[name]
	local x = firstIngredientX + ((i - 1) * 68)
	if unlocked and _AllIngredients and _AllIngredients[name] then
		table.insert(ingredientContents, Rollover {
			x = x, y = 306, w = 46, h = 46,
			contents = name .. ":RecipeBookRolloverContents()",
			CommunityCreationRender.Ingredient(name, 0, 0, 0.72, true),
		})
		table.insert(ingredientContents, Text {
			x = x - 17, y = 353, w = 80, h = 29,
			label = "#" .. GetString(name),
			font = ingredientFont,
			flags = kHAlignCenter + kVAlignTop,
		})
	else
		table.insert(ingredientContents, CommunityCreationRender.Ingredient(name, x, 306, 0.72, false))
		table.insert(ingredientContents, Text {
			x = x - 13, y = 356, w = 72, h = 20,
			label = "#???",
			font = lockedFont,
			flags = kHAlignCenter + kVAlignTop,
		})
	end
end

-- Always report the creation's actual Test Kitchen availability. Whether the
-- Load button is present depends on how the player opened the Cookbook, but
-- progression information is useful from every Community entry point.
local statusText
if availability.can_load then
	statusText = GetString("community_details_ready")
elseif not availability.category_unlocked then
	statusText = GetTextParams("community_details_category_locked", { GetString(item.creation.category) })
else
	statusText = GetTextParams("community_details_missing", { tostring(table.getn(availability.missing_ingredients)), tostring(availability.total_ingredients) })
end

-------------------------------------------------------------------------------
-- Context-sensitive action row
-------------------------------------------------------------------------------
local actionContents = { BeginGroup() }
local hasProfile = item.author and tostring(item.author.profile_id or "") ~= ""
local actions = {}
if hasProfile then
	table.insert(actions, { name = "community_view_profile", label = GetString("community_view_profile"), command = ViewCreatorProfile, enabled = true })
end
if isOwned then
	table.insert(actions, { name = "community_delete", label = GetString("community_delete_creation"), command = DeleteCreation, enabled = true })
elseif CommunityAccount.IsSignedIn() then
	table.insert(actions, { name = "community_rating_header", label = GetString("community_rating_header"), command = RateCreation, enabled = true })
end
if allowLoad then
	table.insert(actions, { name = "community_load", label = GetString("community_load_into_kitchen"), command = LoadIntoKitchen, enabled = availability.can_load })
end

local count = table.getn(actions)
local xs = {}

-- Centre the native-size action buttons around kCenter.
if count == 1 then
	xs = { kCenter }
elseif count == 2 then
	xs = { kCenter - 81, kCenter + 81 }
else
	xs = { kCenter - 161, kCenter, kCenter + 161 }
end
for i, action in ipairs(actions) do
	table.insert(actionContents, SetStyle(C3ButtonMediumStyle))
	table.insert(actionContents, Button {
		x = xs[i], y = 421, scale = 1,
		name = action.name,
		label = "#" .. action.label,
		command = action.command,
	})
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_creation_details",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_tall",

		-- Title
		Text {
			x = 35, y = 49, w = 432, h = 31,
			label = "#" .. item.creation.name,
			font = nameFont,
			flags = kHAlignCenter + kVAlignCenter,
		},
		Rectangle { x = 37, y = 83, w = 428, h = 1, color = ruleColor },

		-- Creation artwork.
		CommunityCreationRender.Appearance(item.creation, 38, 114, 1),

		Rectangle { x = 176, y = 94, w = 1, h = 166, color = ruleColor },

		-- Identity and description.
		Group(identityContents),
		Text {
			x = 190, y = 150, w = 265, h = 55,
			label = "#" .. item.creation.description,
			font = descriptionFont,
			flags = kHAlignLeft + kVAlignTop,
		},

		-- Rating and tags.
		Text {
			x = 190, y = 196, w = 200, h = 20,
			label = "#" .. GetString("community_details_rating_label"),
			font = metaLabelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 219, y = 196, w = 100, h = 20,
			name = "community_details_rating_meta",
			label = "#" .. RatingText(),
			font = smallMetaFont,
			flags = kHAlignRight + kVAlignCenter,
		},
		CommunityCreationRender.RatingStars(item.rating_average, 190, 216, ratingStarScale, ratingStarPrefix),
		Text {
			x = 190, y = 243, w = 39, h = 20,
			label = "#" .. GetString("community_upload_tags_header"),
			font = metaLabelFont,
			flags = kHAlignLeft + kVAlignTop,
		},
		Text {
			x = 233, y = 244, w = 222, h = 29,
			label = "#" .. TagValuesText(),
			font = smallMetaFont,
			flags = kHAlignLeft + kVAlignTop,
		},

		-- Ingredients.
		Rectangle { x = 37, y = 271, w = 428, h = 1, color = ruleColor },
		Text {
			x = 37, y = 276, w = 428, h = 25,
			label = "#" .. GetString("catalogue_ingredients"),
			font = { labelFontName, 16, MaroonColor },
			flags = kHAlignCenter + kVAlignCenter,
		},
		Group(ingredientContents),

		-- Availability.
		Rectangle { x = 37, y = 372, w = 428, h = 1, color = ruleColor },
		Text {
			x = 48, y = 377, w = 406, h = 27,
			name = "community_details_status",
			label = "#" .. statusText,
			font = statusFont,
			flags = kHAlignCenter + kVAlignCenter,
		},

		Group(actionContents),

		SetStyle(C3RoundButtonStyle),
		Button {
			x = 448, y = 425,
			name = "ok",
			label = "ok",
			default = true,
			cancel = true,
			command = CloseDetails,
		},
	}
}

if allowLoad and not availability.can_load then
	EnableWindow("community_load", false)
end
CenterFadeIn("community_creation_details")
