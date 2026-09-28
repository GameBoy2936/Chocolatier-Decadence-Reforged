--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Public Community Profile)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/api.lua")
require("ui/hiscore_countries.lua")
ClearStringCache()

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local context = gDialogTable or {}
local profileId = tostring(context.profile_id or "")
if profileId == "" then
	return
end

local headerFont = { labelFontName, 24, MaroonColor }
local nameFont = { standardFont, 22, BlackColor }
local bodyFont = { standardFont, 14, BlackColor }
local metaFont = { standardFont, 13, BlackColor }
local smallFont = { standardFont, 12, BlackColor }
local sectionFont = { labelFontName, 18, MaroonColor }
local labelFont = { standardFont, 13, BlackColor }
local valueFont = { standardFont, 14, BlackColor }
local statValueFont = { standardFont, 15.5, MaroonColor }
local ruleColor = Color(116, 82, 54, 65)

gCommunityPublicProfile = nil
local categoryKeys =
{
	bar = "bar", beverage = "beverage", infusion = "infusion",
	truffle = "truffle", blend = "community_filter_blend", exotic = "exotic",
}

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function DisplayDate(value)
	value = tostring(value or "")
	if string.len(value) < 10 then
		return value
	end
	if string.sub(value, 5, 5) ~= "-" or string.sub(value, 8, 8) ~= "-" then
		return value
	end
	local y = string.sub(value, 1, 4)
	local m = string.sub(value, 6, 7)
	local d = string.sub(value, 9, 10)
	if not tonumber(y) or not tonumber(m) or not tonumber(d) then
		return value
	end
	return d .. "/" .. m .. "/" .. y
end

local function LastPlayedText(presence)
	presence = presence or {}
	if presence.online then
		return ""
	end
	local seconds = tonumber(presence.last_played_seconds_ago)
	if not seconds then
		return GetString("community_public_profile_last_played_unknown")
	end
	if seconds < 60 then
		return GetString("community_public_profile_last_played_just_now")
	end
	local minutes = Floor(seconds / 60)
	if minutes < 60 then
		local singular = GetPluralSuffix(minutes, Player.options.language or "en") == "_1"
		local key = singular and "community_public_profile_last_played_minute" or "community_public_profile_last_played_minutes"
		return GetTextParams(key, { tostring(minutes) })
	end
	local hours = Floor(minutes / 60)
	if hours < 24 then
		local singular = GetPluralSuffix(hours, Player.options.language or "en") == "_1"
		local key = singular and "community_public_profile_last_played_hour" or "community_public_profile_last_played_hours"
		return GetTextParams(key, { tostring(hours) })
	end
	local days = Floor(hours / 24)
	if days < 7 then
		local singular = GetPluralSuffix(days, Player.options.language or "en") == "_1"
		local key = singular and "community_public_profile_last_played_day" or "community_public_profile_last_played_days"
		return GetTextParams(key, { tostring(days) })
	end
	local played = DisplayDate(presence.last_played_utc)
	if played == "" then
		return GetString("community_public_profile_last_played_unknown")
	end
	return GetTextParams("community_public_profile_last_played_date", { played })
end

local function GenderName(value)
	value = tostring(value or "")
	if value == "" then
		return GetString("community_profile_unspecified")
	end
	if value == "male" then return GetString("gender_male") end
	if value == "female" then return GetString("gender_female") end
	return GetString("community_gender_" .. value)
end

local function CategoryName(value)
	value = tostring(value or "")
	if value == "" then
		return GetString("community_profile_unspecified")
	end
	return GetString(categoryKeys[value] or "community_profile_unspecified")
end

local function NamedFavoriteName(value, emptyKey)
	value = value or {}
	local name = tostring(value.name or "")
	if name == "" then
		return GetString(emptyKey)
	end
	return name
end

local function UpdateProfile(profile)
	gCommunityPublicProfile = profile

	local flag = ""
	local country = ""
	if profile.nationality and profile.nationality ~= "" and HighScoreCountries:IsValid(profile.nationality) then
		flag = HighScoreCountries:GetFlag(profile.nationality)
		country = HighScoreCountries:GetName(profile.nationality)
	end

	SetBitmap("community_public_flag", flag, 0.22)
	SetLabel("community_public_name", tostring(profile.public_name or ""))
	SetLabel(
		"community_public_meta",
		GetTextParams("community_public_profile_meta", { GenderName(profile.gender), country ~= "" and country or GetString("community_profile_no_flag") })
	)
	SetLabel(
		"community_public_member_since",
		GetTextParams("community_public_profile_member_since_value", { DisplayDate(profile.member_since_utc) })
	)
	local presence = profile.presence or {}
	if presence.online then
		SetBitmap("community_public_presence_light", "image/indicatorlight_green", 0.5)
		SetLabel("community_public_presence", GetString("community_public_profile_online"))
		SetLabel("community_public_last_played", "")
	else
		SetBitmap("community_public_presence_light", "image/indicatorlight_off", 0.5)
		SetLabel("community_public_presence", GetString("community_public_profile_offline"))
		SetLabel("community_public_last_played", LastPlayedText(presence))
	end
	SetLabel(
		"community_public_bio",
		tostring(profile.bio or "") ~= "" and tostring(profile.bio) or GetString("community_public_profile_no_bio")
	)

	local favorite = profile.favorite_product or {}
	SetLabel(
		"community_public_favorite_name",
		tostring(favorite.name or "") ~= "" and tostring(favorite.name) or GetString("community_profile_no_favorite_product")
	)
	SetLabel("community_public_favorite_category", CategoryName(profile.favorite_category))
	SetLabel("community_public_favorite_ingredient", NamedFavoriteName(profile.favorite_ingredient, "catalogue_none"))
	SetLabel("community_public_favorite_character", NamedFavoriteName(profile.favorite_character, "catalogue_none"))
	SetLabel("community_public_favorite_port", NamedFavoriteName(profile.favorite_port, "catalogue_none"))
	FillWindow("community_public_favorite_art", "ui/community_public_profile_favorite.lua")

	local stats = profile.stats or {}
	SetLabel("community_public_creations", tostring(stats.creations_shared or 0))
	SetLabel("community_public_loads", tostring(stats.total_creation_loads or 0))

	local most = stats.most_loaded_creation
	if type(most) == "table" then
		local loadCount = tonumber(most.load_count or 0) or 0
		local valueKey = "community_public_profile_most_loaded_value"
		if loadCount == 1 then
			valueKey = "community_public_profile_most_loaded_value_one"
		end
		SetLabel(
			"community_public_most_loaded",
			GetTextParams(valueKey, { tostring(most.name or ""), tostring(loadCount) })
		)
	else
		SetLabel("community_public_most_loaded", GetString("community_public_profile_none"))
	end

	SetLabel("community_public_status", "")
end

local function CloseProfile()
	FadeCloseWindow("community_public_profile", "ok")
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_public_profile",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_tall",

		-- Identity
		Text {
			x = 30, y = 24, w = 442, h = 32,
			label = "#" .. GetString("community_profile_header"),
			font = headerFont,
			flags = kHAlignCenter + kVAlignCenter,
		},
		Bitmap
		{
			x = 44, y = 66,
			name = "community_public_flag",
			image = "",
			scale = 0.22,
		},
		Text {
			x = 88, y = 59, w = 230, h = 30,
			name = "community_public_name",
			label = "",
			font = nameFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 320, y = 61, w = 110, h = 22,
			name = "community_public_presence",
			label = "",
			font = metaFont,
			flags = kHAlignRight + kVAlignCenter,
		},
		Bitmap {
			x = 438, y = 64,
			name = "community_public_presence_light",
			image = "image/indicatorlight_off",
			scale = 0.5,
		},
		Text {
			x = 88, y = 88, w = 195, h = 20,
			name = "community_public_meta",
			label = "",
			font = metaFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 285, y = 88, w = 168, h = 20,
			name = "community_public_last_played",
			label = "",
			font = smallFont,
			flags = kHAlignRight + kVAlignCenter,
		},
		Text {
			x = 88, y = 108, w = 365, h = 18,
			name = "community_public_member_since",
			label = "",
			font = smallFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 44, y = 133, w = 414, h = 43,
			name = "community_public_bio",
			label = "#" .. GetString("community_public_profile_loading"),
			font = bodyFont,
			flags = kHAlignLeft + kVAlignTop,
		},

		Rectangle { x = 40, y = 181, w = 422, h = 1, color = ruleColor },

		-- Favourites
		Text {
			x = 40, y = 187, w = 422, h = 25,
			label = "#" .. GetString("community_public_profile_favorites"),
			font = sectionFont,
			flags = kHAlignCenter + kVAlignCenter,
		},

		Window
		{
			name = "community_public_favorite_art",
			x = 46, y = 215, w = 88, h = 90,
		},
		Text {
			x = 140, y = 216, w = 108, h = 18,
			label = "#" .. GetString("community_profile_favorite_product_short"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 140, y = 235, w = 108, h = 36,
			name = "community_public_favorite_name",
			label = "",
			font = valueFont,
			flags = kHAlignLeft + kVAlignTop,
		},
		Text {
			x = 140, y = 277, w = 108, h = 17,
			label = "#" .. GetString("community_profile_favorite_category_short"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 140, y = 295, w = 108, h = 18,
			name = "community_public_favorite_category",
			label = "",
			font = valueFont,
			flags = kHAlignLeft + kVAlignCenter,
		},

		Rectangle { x = 260, y = 216, w = 1, h = 96, color = ruleColor },

		Text {
			x = 278, y = 218, w = 78, h = 18,
			label = "#" .. GetString("community_profile_favorite_ingredient_short"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 357, y = 218, w = 101, h = 18,
			name = "community_public_favorite_ingredient",
			label = "",
			font = valueFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 278, y = 252, w = 78, h = 18,
			label = "#" .. GetString("community_profile_favorite_character_short"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 357, y = 252, w = 101, h = 34,
			name = "community_public_favorite_character",
			label = "",
			font = valueFont,
			flags = kHAlignLeft + kVAlignTop,
		},
		Text {
			x = 278, y = 288, w = 78, h = 18,
			label = "#" .. GetString("ledger_port"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 357, y = 288, w = 101, h = 18,
			name = "community_public_favorite_port",
			label = "",
			font = valueFont,
			flags = kHAlignLeft + kVAlignCenter,
		},

		Rectangle { x = 40, y = 310, w = 422, h = 1, color = ruleColor },

		-- Community Stats
		Text {
			x = 40, y = 316, w = 422, h = 25,
			label = "#" .. GetString("community_public_profile_stats"),
			font = sectionFont,
			flags = kHAlignCenter + kVAlignCenter,
		},

		Text {
			x = 55, y = 344, w = 128, h = 19,
			label = "#" .. GetString("community_public_profile_creations"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 185, y = 343, w = 38, h = 20,
			name = "community_public_creations",
			label = "",
			font = statValueFont,
			flags = kHAlignRight + kVAlignCenter,
		},
		Text {
			x = 279, y = 344, w = 124, h = 19,
			label = "#" .. GetString("community_public_profile_loads"),
			font = labelFont,
			flags = kHAlignLeft + kVAlignCenter,
		},
		Text {
			x = 405, y = 343, w = 40, h = 20,
			name = "community_public_loads",
			label = "",
			font = statValueFont,
			flags = kHAlignRight + kVAlignCenter,
		},

		-- Give the long creation name its own full-width line rather than forcing
		-- it into the narrow statistic row beside its label.
		Text {
			x = 55, y = 370, w = 392, h = 18,
			label = "#" .. GetString("community_public_profile_most_loaded"),
			font = labelFont,
			flags = kHAlignCenter + kVAlignCenter,
		},
		Text {
			x = 55, y = 387, w = 392, h = 20,
			name = "community_public_most_loaded",
			label = "",
			font = metaFont,
			flags = kHAlignCenter + kVAlignCenter,
		},

		Text {
			x = 48, y = 390, w = 406, h = 15,
			name = "community_public_status",
			label = "",
			font = smallFont,
			flags = kHAlignCenter + kVAlignCenter,
		},

		SetStyle(C3ButtonStyle),
		Button {
			x = kCenter, y = 410,
			name = "ok",
			label = "ok",
			default = true,
			cancel = true,
			command = CloseProfile,
		},
	}
}

SetBitmap("community_public_flag", "", 0.22)
CenterFadeIn("community_public_profile")
QueueCommand(function()
	CommunityApi.GetProfile(profileId, function(profile, response, err)
		if err then
			SetLabel("community_public_status", GetTextParams("community_public_profile_error", { tostring(err) }))
			return
		end
		UpdateProfile(profile)
	end)
end)
