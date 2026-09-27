--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Creation Upload)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/api.lua")
require("community/account.lua")
require("community/render.lua")
require("ui/hiscore_countries.lua")
ClearStringCache()

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local context = gDialogTable or {}
local creation, creationError = CommunityCreation.Normalize(context.creation or {})
if not creation then
	DebugOut("COMMUNITY", "Could not open creation upload UI: " .. tostring(creationError))
	return
end

local profile = CommunityAccount.GetProfile() or {}
local provenance, shareDisposition = CommunityCreation.GetShareDisposition(creation)
local foreignCopyLocked = shareDisposition == "foreign_copy"
local shareActionLabel = shareDisposition == "remix" and GetString("community_share_remix") or GetString("community_share_creation")

local headerFont = { labelFontName, 21, MaroonColor }
local nameFont = { standardFont, 20, BlackColor }
local bodyFont = { standardFont, 14, BlackColor }
local smallFont = { standardFont, 12, BlackColor }
local sectionFont = { labelFontName, 15, MaroonColor }
local statusFont = { standardFont, 11, MaroonColor }
local ruleColor = Color(116, 82, 54, 65)
local tagButtonStyle =
{
	parent = C3ButtonMediumStyle,
	font = { uiFontName, 14, BlackColor },
	sound = "cadi/ui_click.ogg",
}

local selected = {}
local selectedCount = 0
local sending = false
local tagButtons = {}
local tagXs = { 29, 140, 251, 362 }
local tagYs = { 227, 258, 289, 320, 351 }

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function TagKey(tag)
	if tag == "coffee" then return "coffee" end
	return "community_tag_" .. tag
end

local function TagText(tag)
	return tostring(GetString(TagKey(tag)) or tag or "")
end

local function SetStatus(text)
	SetLabel("community_upload_status", tostring(text or ""))
end

local function UpdateTagSummary()
	-- Selection is communicated visually through each tag button's down state.
	-- This function is kept as a no-op so existing calls remain harmless.
end

local function SyncTagButton(tag)
	-- kToggle applies its own state change as the click finishes. Queue our
	-- authoritative state until after that native change, otherwise the engine
	-- can overwrite SetButtonToggleState() during the same click.
	QueueCommand(function()
		SetButtonToggleState("community_upload_tag_" .. tag, selected[tag] == true)
	end)
end

local function ToggleTag(tag)
	if sending then
		SyncTagButton(tag)
		return
	end
	if selected[tag] then
		selected[tag] = nil
		selectedCount = selectedCount - 1
		SetStatus("")
	elseif selectedCount >= CommunityApi.MaxCreationTags then
		SetStatus(GetTextParams("community_upload_tag_limit", { tostring(CommunityApi.MaxCreationTags) }))
	else
		selected[tag] = true
		selectedCount = selectedCount + 1
		SetStatus("")
	end
	SyncTagButton(tag)
	UpdateTagSummary()
end

local function SelectedTags()
	-- Mark the table as an array even when it is empty. Without this, the JSON
	-- encoder serializes a zero-tag selection as {} instead of [], which the
	-- Community service correctly rejects as non-array tag metadata.
	local tags = CommunityJSON.Array({})
	for _, tag in ipairs(CommunityApi.CreationTagOrder) do
		if selected[tag] then
			table.insert(tags, tag)
		end
	end
	return tags
end

local function CloseUpload()
	if sending then
		return
	end
	gCommunityCreationUploadResult = nil
	FadeCloseWindow("community_creation_upload", "cancel")
end

local function ShareCreation()
	if foreignCopyLocked then
		local sourceName = provenance and tostring(provenance.source_public_name or "") or ""
		if sourceName == "" then sourceName = GetString("community_upload_foreign_creator") end
		SetStatus(GetTextParams("community_upload_foreign_copy", { sourceName }))
		return
	end
	if sending or CommunityTransport.IsBusy() then
		SetStatus(GetString("community_cookbook_busy"))
		return
	end
	sending = true
	EnableWindow("community_share_creation", false)
	EnableWindow("community_upload_cancel", false)
	SetStatus(GetString("community_share_sending"))
	local tags = SelectedTags()
	local metadata = { tags = tags }
	CommunityApi.Upload(creation, metadata, function(item, response, err)
		sending = false
		if err then
			SetStatus(GetTextParams("community_share_error", { tostring(err) }))
			EnableWindow("community_share_creation", true)
			EnableWindow("community_upload_cancel", true)
			return
		end
		gCommunityCreationUploadResult = { item = item }
		FadeCloseWindow("community_creation_upload", item.was_duplicate and "updated" or "shared")
	end)
end

local flag = ""
if profile.nationality and profile.nationality ~= "" and HighScoreCountries:IsValid(profile.nationality) then
	flag = HighScoreCountries:GetFlag(profile.nationality)
end

-- Compact ingredient icons sit directly after the ingredient count. Known
-- ingredients retain the same Recipe Book rollover used elsewhere in Reforged.
local ingredientIcons = {}
local ingredientIconX = 331
local ingredientIconY = 159
local ingredientIconStep = 20
local ingredientIconScale = 0.25
for i = 1, table.getn(creation.ingredients) do
	local name = creation.ingredients[i]
	local x = ingredientIconX + ((i - 1) * ingredientIconStep)
	local unlocked = Player and Player.labIngredients and Player.labIngredients[name] and _AllIngredients and _AllIngredients[name]
	if unlocked then
		table.insert(ingredientIcons, Rollover {
			x = x, y = ingredientIconY, w = 18, h = 18,
			contents = name .. ":RecipeBookRolloverContents()",
			fit = false,
			CommunityCreationRender.Ingredient(name, 0, 0, ingredientIconScale, true),
		})
	else
		table.insert(ingredientIcons, CommunityCreationRender.Ingredient(name, x, ingredientIconY, ingredientIconScale, false))
	end
end

local tagCol = 1
local tagRow = 1
for _, tag in ipairs(CommunityApi.CreationTagOrder) do
	local temp = tag
	table.insert(tagButtons, SetStyle(tagButtonStyle))
	table.insert(tagButtons, Button {
		x = tagXs[tagCol], y = tagYs[tagRow], scale = 0.66,
		name = "community_upload_tag_" .. tag,
		label = "#" .. TagText(tag),
		type = kToggle,
		command = function() ToggleTag(temp) end,
	})
	tagCol = tagCol + 1
	if tagCol > 4 then
		tagCol = 1
		tagRow = tagRow + 1
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_creation_upload",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_tall",

		Text { x = 30, y = 32, w = 442, h = 30, label = "#" .. GetString("community_upload_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 174, y = 60, w = 430, h = 30, label = "#" .. creation.name, font = nameFont, flags = kHAlignLeft + kVAlignCenter },

		CommunityCreationRender.Appearance(creation, 48, 72, 0.8),
		Text { x = 174, y = 90, w = 274, h = 52, label = "#" .. creation.description, font = bodyFont, flags = kHAlignLeft + kVAlignTop },

		Bitmap { x = 176, y = 140, image = flag, scale = 0.18 },
		Text { x = 210, y = 137, w = 248, h = 18, label = "#" .. tostring(profile.public_name or ""), font = bodyFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 176, y = 158, w = 152, h = 18,
			label = "#" .. GetString(creation.category) .. "  -  " .. GetTextParams("community_upload_ingredient_count", { tostring(table.getn(creation.ingredients)) }),
			font = smallFont, flags = kHAlignLeft + kVAlignCenter },
		Group(ingredientIcons),

		Rectangle { x = 37, y = 184, w = 428, h = 1, color = ruleColor },
		Text { x = 38, y = 190, w = 426, h = 22, label = "#" .. GetString("community_upload_tags_header"), font = sectionFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 45, y = 211, w = 412, h = 16,
			label = "#" .. GetTextParams("community_upload_tags_help", { tostring(CommunityApi.MaxCreationTags) }),
			font = smallFont, flags = kHAlignCenter + kVAlignTop },
		Group(tagButtons),
		Text { x = 37, y = 380, w = 428, h = 18, name = "community_upload_status", label = "", font = statusFont, flags = kHAlignCenter + kVAlignCenter },

		SetStyle(C3ButtonLongStyle),
		Button { x = 47, y = 413, name = "community_share_creation", label = "#" .. shareActionLabel, command = ShareCreation, default = true },
		Button { x = 255, y = 413, name = "community_upload_cancel", label = "cancel", command = CloseUpload, cancel = true },
	}
}

for _, tag in ipairs(CommunityApi.CreationTagOrder) do
	SetButtonToggleState("community_upload_tag_" .. tag, false)
end
UpdateTagSummary()

if foreignCopyLocked then
	-- An unchanged recipe downloaded from another Chocolatier may be saved
	-- locally, tasted and redesigned, but it cannot be republished as if it
	-- were a new recipe. Ingredient/category changes make it a remix instead.
	EnableWindow("community_share_creation", false)
	for _, tag in ipairs(CommunityApi.CreationTagOrder) do
		EnableWindow("community_upload_tag_" .. tag, false)
	end
	local sourceName = provenance and tostring(provenance.source_public_name or "") or ""
	if sourceName == "" then sourceName = GetString("community_upload_foreign_creator") end
	SetStatus(GetTextParams("community_upload_foreign_copy", { sourceName }))
else
	SetStatus("")
end
CenterFadeIn("community_creation_upload")
