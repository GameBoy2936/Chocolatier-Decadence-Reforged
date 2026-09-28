--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Community Profile)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/account.lua")
require("community/identity.lua")
require("ui/hiscore_countries.lua")

ClearStringCache()

if not CommunityAccount.IsSignedIn() then
	DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_profile_requires_account") }
	return
end

-------------------------------------------------------------------------------
-- Profile State
-------------------------------------------------------------------------------

local current = CommunityAccount.GetProfile() or {}
local genders =
{
	"",
	"male",
	"female",
	"non_binary",
	"other",
	"prefer_not_say",
}

local categories =
{
	"",
	"bar",
	"beverage",
	"infusion",
	"truffle",
	"blend",
	"exotic",
}

local categoryKeys =
{
	bar = "bar",
	beverage = "beverage",
	infusion = "infusion",
	truffle = "truffle",
	blend = "community_filter_blend",
	exotic = "exotic",
}

local function IndexOf(list, value)
	for i, item in ipairs(list) do
		if item == value then
			return i
		end
	end

	return 1
end

-------------------------------------------------------------------------------
-- Favourite Selection State
-------------------------------------------------------------------------------

local function CopyFavorite(value, includeKind)
	value = value or {}
	local result =
	{
		id = tostring(value.id or ""),
		name = tostring(value.name or ""),
	}

	if includeKind then
		result.kind = tostring(value.kind or "")
	end

	return result
end

local favoriteProduct = CopyFavorite(current.favorite_product, true)
local favoriteIngredient = CopyFavorite(current.favorite_ingredient, false)
local favoriteCharacter = CopyFavorite(current.favorite_character, false)
local favoritePort = CopyFavorite(current.favorite_port, false)

gCommunityProfile =
{
	public_name = tostring(current.public_name or ""),
	nationality = tostring(current.nationality or ""),
	gender = tostring(current.gender or ""),
	favorite_category = tostring(current.favorite_category or ""),
	bio = tostring(current.bio or ""),
}

local genderIndex = IndexOf(genders, gCommunityProfile.gender)
local categoryIndex = IndexOf(categories, gCommunityProfile.favorite_category)

-------------------------------------------------------------------------------
-- UI Styles
-------------------------------------------------------------------------------

local labelFont = { standardFont, 14, BlackColor }
local valueFont = { standardFont, 14, MaroonColor }
local favoriteValueFont = { standardFont, 12.5, MaroonColor }
local bioFont = { standardFont, 13.5, BlackColor }
local statusFont = { standardFont, 12, MaroonColor }
local favoriteActionButtonFont = { uiFontName, 14.5, BlackColor }
local favoriteActionButtonStyle =
{
	parent = C3ButtonStyle,
	font = favoriteActionButtonFont,
}
local ruleColor = Color(116, 82, 54, 55)

local arrowGraphicsLeft =
{
	"image/button_arrow_left_up",
	"image/button_arrow_left_down",
	"image/button_arrow_left_over",
	"image/button_arrow_left_down",
}

local arrowGraphicsRight =
{
	"image/button_arrow_right_up",
	"image/button_arrow_right_down",
	"image/button_arrow_right_over",
	"image/button_arrow_right_down",
}

-------------------------------------------------------------------------------
-- Display Helpers
-------------------------------------------------------------------------------

local function Wrap(index, count, delta)
	index = index + delta

	if index < 1 then
		index = count
	elseif index > count then
		index = 1
	end

	return index
end

local function GenderText()
	local value = genders[genderIndex]

	if value == "" then
		return GetString("community_profile_unspecified")
	end

	if value == "male" then return GetString("gender_male") end
	if value == "female" then return GetString("gender_female") end
	return GetString("community_gender_" .. value)
end

local function CategoryText()
	local value = categories[categoryIndex]

	if value == "" then
		return GetString("community_profile_unspecified")
	end

	return GetString(categoryKeys[value] or "community_profile_unspecified")
end

local function FavoriteText(value)
	value = value or {}
	if tostring(value.id or "") == "" then
		return GetString("catalogue_none")
	end

	local name = tostring(value.name or "")
	if name ~= "" then
		return name
	end

	return tostring(value.id or "")
end

local function RefreshValues()
	SetLabel("catalogue_gender_value", GenderText())
	SetLabel("community_profile_category_value", CategoryText())
	SetLabel("community_profile_product_value", FavoriteText(favoriteProduct))
	SetLabel("community_profile_ingredient_value", FavoriteText(favoriteIngredient))
	SetLabel("community_profile_character_value", FavoriteText(favoriteCharacter))
	SetLabel("community_profile_port_value", FavoriteText(favoritePort))
end

local function RefreshFlag()
	gCommunityProfilePreviewNationality = gCommunityProfile.nationality or ""
	FillWindow("community_profile_preview", "ui/community_profile_preview.lua")
end

-------------------------------------------------------------------------------
-- Profile Actions
-------------------------------------------------------------------------------

local function ChooseFlag()
	local result = DisplayDialog { "ui/hiscore_nationality.lua", selected = gCommunityProfile.nationality }

	if result ~= nil and result ~= "cancel" then
		gCommunityProfile.nationality = result
		RefreshFlag()
	end
end

local function SafeDisplayName(entry)
	if not entry then return "" end

	if entry.GetName then
		local ok, value = pcall(function() return entry:GetName() end)
		if ok and value and value ~= "" then
			return tostring(value)
		end
	end

	local key = tostring(entry.name or "")
	if key ~= "" then
		local value = GetString(key)
		if value and value ~= "#####" then
			return tostring(value)
		end
	end

	return key
end

local pickerQueued = false

local function SetPickerButtonsEnabled(enabled)
	EnableWindow("community_profile_pick_product", enabled)
	EnableWindow("community_profile_pick_character", enabled)
	EnableWindow("community_profile_pick_ingredient", enabled)
	EnableWindow("community_profile_pick_port", enabled)
	EnableWindow("community_profile_remove_product", enabled)
	EnableWindow("community_profile_remove_character", enabled)
	EnableWindow("community_profile_remove_ingredient", enabled)
	EnableWindow("community_profile_remove_port", enabled)
end

local function RefreshFavoriteActionButtons()
	EnableWindow("community_profile_pick_product", true)
	EnableWindow("community_profile_pick_character", true)
	EnableWindow("community_profile_pick_ingredient", true)
	EnableWindow("community_profile_pick_port", true)
	EnableWindow("community_profile_remove_product", tostring(favoriteProduct.id or "") ~= "")
	EnableWindow("community_profile_remove_character", tostring(favoriteCharacter.id or "") ~= "")
	EnableWindow("community_profile_remove_ingredient", tostring(favoriteIngredient.id or "") ~= "")
	EnableWindow("community_profile_remove_port", tostring(favoritePort.id or "") ~= "")
end

local function QueueProfilePicker(label, command)
	if pickerQueued then return end
	if CommunityTransport.IsBusy() then
		SetLabel("community_profile_status", GetString("community_cookbook_busy"))
		return
	end

	pickerQueued = true
	SetPickerButtonsEnabled(false)
	DebugOut("UI", "Community Profile: queued " .. label .. " picker.")

	-- Full-screen game dialogs are deferred until the button callback has returned.
	-- This matches the engine's own safe transition pattern used by the developer UIs.
	QueueCommand(function()
		DebugOut("UI", "Community Profile: opening " .. label .. " picker.")
		command()
		DebugOut("UI", "Community Profile: closed " .. label .. " picker.")
		pickerQueued = false
		RefreshValues()
		RefreshFavoriteActionButtons()
	end)
end

local function SelectFavoriteProduct()
	-- Deliberately mirror dev_order_detail.EditOrderProduct: seed the ordinary
	-- Recipe Book globals, open ui_recipes.lua unchanged, then read the selection.
	local previousRecipe = gRecipeSelection
	local previousCategory = gCategorySelection
	local previousPage = gRecipePage
	local previousLastCategory = gLastViewedCategory
	local previousFactory = gCurrentFactory
	local previousProfileRecipePicker = gCommunityProfileRecipePicker

	local initial = nil
	if favoriteProduct.kind == "game" and favoriteProduct.id ~= "" then
		initial = _AllProducts[favoriteProduct.id]
	end
	if not initial then initial = _AllProducts["b01"] end

	if initial then
		gRecipeSelection = initial
		gCategorySelection = initial.category
	end
	gCurrentFactory = nil
	gCommunityProfileRecipePicker = true

	local ok = DisplayDialog { "ui/ui_recipes.lua" }
	local chosen = gRecipeSelection

	gCommunityProfileRecipePicker = previousProfileRecipePicker
	gRecipeSelection = previousRecipe
	gCategorySelection = previousCategory
	gRecipePage = previousPage
	gLastViewedCategory = previousLastCategory
	gCurrentFactory = previousFactory

	if not ok or not chosen then return end

	local known = false
	if chosen.IsKnown then
		local callOk, value = pcall(function() return chosen:IsKnown() end)
		known = callOk and value
	end

	local categoryName = ""
	if chosen.category then
		categoryName = tostring(chosen.category.name or chosen.category or "")
	end

	local code = tostring(chosen.code or "")
	if not known or code == "" or categoryName == "user" then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_profile_favorite_recipe_invalid") }
		return
	end

	favoriteProduct =
	{
		kind = "game",
		id = code,
		name = SafeDisplayName(chosen),
	}
	SetLabel("community_profile_status", "")
end

local function ResolveCatalogueFavorite(category, favorite)
	local id = tostring((favorite or {}).id or "")
	if id == "" then return nil end

	if category == "characters" then
		return _AllCharacters and _AllCharacters[id] or nil
	elseif category == "ingredients" then
		return _AllIngredients and _AllIngredients[id] or nil
	elseif category == "ports" then
		return _AllPorts and _AllPorts[id] or nil
	end

	return nil
end

local function IsCatalogueFavoriteKnown(category, entry)
	if not entry or not Player or not Player.catalogue then return false end
	local id = tostring(entry.name or "")
	if id == "" then return false end

	if category == "characters" then
		local unlocked = Player.catalogue.unlockedCharacters and Player.catalogue.unlockedCharacters[id]
		return unlocked and unlocked.met
	elseif category == "ingredients" then
		return Player.catalogue.unlockedIngredients and Player.catalogue.unlockedIngredients[id]
	elseif category == "ports" then
		return Player.catalogue.unlockedPorts and Player.catalogue.unlockedPorts[id]
	end

	return false
end

local function SelectCatalogueFavorite(category, favorite, setFavorite)
	-- The ordinary Catalogue already stores the highlighted object in
	-- gCatalogueSelection and closes with its round OK button. We only choose
	-- the starting tab and harvest that existing selection afterwards.
	local previousCategory = gCatalogueCategory
	local previousSelection = gCatalogueSelection
	local previousTopIndex = gCatalogueTopIndex
	local previousCategoryPage = gCatalogueCategoryPage

	gCatalogueCategory = category
	gCatalogueSelection = ResolveCatalogueFavorite(category, favorite)
	gCatalogueTopIndex = 1
	gCatalogueCategoryPage = 1

	local ok = DisplayDialog { "ui/ui_catalogue.lua" }
	local chosenCategory = gCatalogueCategory
	local chosen = gCatalogueSelection

	gCatalogueCategory = previousCategory
	gCatalogueSelection = previousSelection
	gCatalogueTopIndex = previousTopIndex
	gCatalogueCategoryPage = previousCategoryPage

	if not ok or chosenCategory ~= category or not chosen then return end
	if not IsCatalogueFavoriteKnown(category, chosen) then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("help_catalogue_locked") }
		return
	end

	setFavorite({ id = tostring(chosen.name or ""), name = SafeDisplayName(chosen) })
	SetLabel("community_profile_status", "")
end

local function OpenFavoriteProduct()
	QueueProfilePicker("favourite product", SelectFavoriteProduct)
end

local function OpenFavoriteCharacter()
	QueueProfilePicker("favourite character", function()
		SelectCatalogueFavorite("characters", favoriteCharacter, function(value) favoriteCharacter = value end)
	end)
end

local function OpenFavoriteIngredient()
	QueueProfilePicker("favourite ingredient", function()
		SelectCatalogueFavorite("ingredients", favoriteIngredient, function(value) favoriteIngredient = value end)
	end)
end

local function OpenFavoritePort()
	QueueProfilePicker("favourite port", function()
		SelectCatalogueFavorite("ports", favoritePort, function(value) favoritePort = value end)
	end)
end

local function RemoveFavoriteProduct()
	favoriteProduct = { kind = "", id = "", name = "" }
	RefreshValues()
	RefreshFavoriteActionButtons()
	SetLabel("community_profile_status", "")
end

local function RemoveFavoriteCharacter()
	favoriteCharacter = { id = "", name = "" }
	RefreshValues()
	RefreshFavoriteActionButtons()
	SetLabel("community_profile_status", "")
end

local function RemoveFavoriteIngredient()
	favoriteIngredient = { id = "", name = "" }
	RefreshValues()
	RefreshFavoriteActionButtons()
	SetLabel("community_profile_status", "")
end

local function RemoveFavoritePort()
	favoritePort = { id = "", name = "" }
	RefreshValues()
	RefreshFavoriteActionButtons()
	SetLabel("community_profile_status", "")
end

local function SaveProfile()
	if CommunityTransport.IsBusy() then
		SetLabel("community_profile_status", GetString("community_cookbook_busy"))
		return
	end

	local payload =
	{
		public_name = GetLabel("community_profile_nameedit") or "",
		nationality = gCommunityProfile.nationality or "",
		gender = genders[genderIndex],
		favorite_product =
		{
			kind = tostring(favoriteProduct.kind or ""),
			id = tostring(favoriteProduct.id or ""),
			name = tostring(favoriteProduct.name or ""),
		},
		favorite_category = categories[categoryIndex],
		favorite_ingredient = { id = tostring(favoriteIngredient.id or ""), name = tostring(favoriteIngredient.name or "") },
		favorite_character = { id = tostring(favoriteCharacter.id or ""), name = tostring(favoriteCharacter.name or "") },
		favorite_port = { id = tostring(favoritePort.id or ""), name = tostring(favoritePort.name or "") },
		bio = GetLabel("community_profile_bioedit") or "",
	}

	EnableWindow("community_profile_save", false)
	SetLabel("community_profile_status", GetString("community_profile_saving"))

	CommunityAccount.UpdateProfile(payload, function(profile, response, err)
		if err then
			if not CommunityAccount.IsSignedIn() then
				DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_session_expired") }
				FadeCloseWindow("community_profile_panel", "account_required")
				return
			end

			EnableWindow("community_profile_save", true)
			SetLabel("community_profile_status", GetTextParams("community_profile_error", { tostring(err) }))
			return
		end

		CommunityIdentity.SyncPlayer()
		if Player and Player.SaveGame then
			Player:SaveGame()
		end

		FadeCloseWindow("community_profile_panel", "saved")
	end)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_profile_panel",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_tall",

		-- Identity
		Text { x = 48, y = 42, w = 406, h = 20, label = "#" .. GetString("community_profile_public_name"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Bitmap
		{
			image = "image/entername",
			x = kCenter, y = 60,
			TextEdit
			{
				typename = "TextEdit",
				utf8 = true,
				x = 10, y = 3, w = 395, h = 29,
				name = "community_profile_nameedit",
				label = gCommunityProfile.public_name,
				font = labelFont,
				flags = kHAlignCenter + kVAlignCenter,
				clearinitial = false,
				length = 20,
				ignore = kIllegalNameChars,
			},
		},

		Text { x = 48, y = 100, w = 112, h = 22, label = "#" .. GetString("community_profile_flag"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Window { name = "community_profile_preview", x = 164, y = 96, w = 202, h = 30 },

		SetStyle(C3ButtonMediumStyle),
		Button { x = 349, y = 102, label = "#" .. GetString("hiscore_choose_flag"), command = ChooseFlag, scale = 0.68 },

		Rectangle { x = 48, y = 142, w = 406, h = 1, color = ruleColor },

		-- Gender
		Text { x = 48, y = 150, w = 105, h = 22, label = "#" .. GetString("catalogue_gender"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Button { x = 300, y = 146, scale = 0.30, graphics = arrowGraphicsLeft, command = function()
			genderIndex = Wrap(genderIndex, table.getn(genders), -1)
			RefreshValues()
		end },
		Text { x = 290, y = 153, w = 182, h = 24, name = "catalogue_gender_value", font = valueFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 450, y = 146, scale = 0.30, graphics = arrowGraphicsRight, command = function()
			genderIndex = Wrap(genderIndex, table.getn(genders), 1)
			RefreshValues()
		end },

		-- Favourite confection
		Text { x = 48, y = 178, w = 122, h = 22, label = "#" .. GetString("community_profile_favorite_category"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Button { x = 300, y = 174, scale = 0.30, graphics = arrowGraphicsLeft, command = function()
			categoryIndex = Wrap(categoryIndex, table.getn(categories), -1)
			RefreshValues()
		end },
		Text { x = 290, y = 181, w = 182, h = 24, name = "community_profile_category_value", font = valueFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 450, y = 174, scale = 0.30, graphics = arrowGraphicsRight, command = function()
			categoryIndex = Wrap(categoryIndex, table.getn(categories), 1)
			RefreshValues()
		end },

		-- Favourite pickers. Keep the familiar control-button family and expose
		-- selection/removal as explicit actions on every row.
		SetStyle(favoriteActionButtonStyle),
		Text { x = 48, y = 206, w = 122, h = 22, label = "#" .. GetString("community_profile_favorite_product"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 170, y = 205, w = 140, h = 24, name = "community_profile_product_value", font = favoriteValueFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 320, y = 204, scale = 0.50, name = "community_profile_pick_product", label = "choose", command = OpenFavoriteProduct },
		Button { x = 387, y = 204, scale = 0.50, name = "community_profile_remove_product", label = "remove", command = RemoveFavoriteProduct },

		Text { x = 48, y = 232, w = 122, h = 22, label = "#" .. GetString("community_profile_favorite_character"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 170, y = 231, w = 140, h = 24, name = "community_profile_character_value", font = favoriteValueFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 320, y = 230, scale = 0.50, name = "community_profile_pick_character", label = "choose", command = OpenFavoriteCharacter },
		Button { x = 387, y = 230, scale = 0.50, name = "community_profile_remove_character", label = "remove", command = RemoveFavoriteCharacter },

		Text { x = 48, y = 258, w = 122, h = 22, label = "#" .. GetString("community_profile_favorite_ingredient"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 170, y = 257, w = 140, h = 24, name = "community_profile_ingredient_value", font = favoriteValueFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 320, y = 256, scale = 0.50, name = "community_profile_pick_ingredient", label = "choose", command = OpenFavoriteIngredient },
		Button { x = 387, y = 256, scale = 0.50, name = "community_profile_remove_ingredient", label = "remove", command = RemoveFavoriteIngredient },

		Text { x = 48, y = 284, w = 122, h = 22, label = "#" .. GetString("community_profile_favorite_port"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 170, y = 283, w = 140, h = 24, name = "community_profile_port_value", font = favoriteValueFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 320, y = 282, scale = 0.50, name = "community_profile_pick_port", label = "choose", command = OpenFavoritePort },
		Button { x = 387, y = 282, scale = 0.50, name = "community_profile_remove_port", label = "remove", command = RemoveFavoritePort },

		-- Profile bio
		Rectangle { x = 48, y = 311, w = 406, h = 1, color = ruleColor },
		Text { x = 48, y = 317, w = 406, h = 22, label = "#" .. GetString("community_profile_bio"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Bitmap
		{
			image = "image/entername_big",
			x = kCenter, y = 337,
			TextEdit
			{
				typename = "TextEdit",
				utf8 = true,
				x = 12, y = 2, w = 391, h = 59,
				name = "community_profile_bioedit",
				label = gCommunityProfile.bio,
				font = bioFont,
				flags = kHAlignLeft + kVAlignCenter,
				clearinitial = false,
				length = 240,
			},
		},

		Text { x = 48, y = 409, w = 406, h = 17, name = "community_profile_status", label = "", font = statusFont, flags = kHAlignCenter + kVAlignCenter },

		-- Footer
		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter - 88, y = 414, name = "community_profile_save", label = "#" .. GetString("community_profile_save"), default = true, command = SaveProfile },
		Button { x = kCenter + 88, y = 414, label = "cancel", cancel = true, command = function() FadeCloseWindow("community_profile_panel", "cancel") end },
	}
}

-------------------------------------------------------------------------------
-- Initial State
-------------------------------------------------------------------------------

RefreshFlag()
RefreshValues()
RefreshFavoriteActionButtons()
CenterFadeIn("community_profile_panel")
QueueCommand(function() SetFocus("community_profile_nameedit") end)
