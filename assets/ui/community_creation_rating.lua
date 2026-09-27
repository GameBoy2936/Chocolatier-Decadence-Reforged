--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Creation Rating)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------
require("community/api.lua")
ClearStringCache()
require("community/render.lua")

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local context = gDialogTable or {}
local creationId = tostring(context.creation_id or "")
local creationName = tostring(context.creation_name or "")
local headerFont = { labelFontName, 22, MaroonColor }
local nameFont = { standardFont, 16, BlackColor }
local bodyFont = { standardFont, 14, BlackColor }
local statusFont = { standardFont, 13, MaroonColor }
local current = 0
local busy = false

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function UpdateButtons()
	-- A selected rating visually fills every star up to the chosen value.
	for i = 1, 5 do
		SetButtonToggleState("community_rating_" .. tostring(i), i <= current)
	end
	EnableWindow("community_rating_clear", (not busy) and current > 0)
end

local function CloseRating()
	if busy then
		return
	end
	FadeCloseWindow("community_creation_rating", "cancel")
end

local function SaveRating(value)
	if busy then
		UpdateButtons() return
	end
	local previous = current
	current = tonumber(value) or 0
	UpdateButtons()
	busy = true
	SetLabel("community_rating_status", GetString("community_rating_saving"))
	EnableWindow("community_rating_clear", false)
	CommunityApi.SetRating(creationId, value, function(summary, response, err)
		busy = false
		if err then
			current = previous
			SetLabel("community_rating_status", GetTextParams("community_rating_error", { tostring(err) }))
			UpdateButtons()
			return
		end
		gCommunityCreationRatingResult = summary
		FadeCloseWindow("community_creation_rating", "rated")
	end)
end

local ratingButtons = { BeginGroup() }
local emptyStar = CommunityCreationRender.RatingStarAsset("empty", "up")
local fullStar = CommunityCreationRender.RatingStarAsset("full", "down")
local hoverStar = CommunityCreationRender.RatingStarAsset("full", "over")
local disabledStar = CommunityCreationRender.RatingStarAsset("empty", "down")
local ratingButtonScale = CommunityCreationRender.RatingStarScale(1)
local ratingStarStep = 58
local ratingStarStartX = kCenter - 140
for i = 1, 5 do
	local value = i
	table.insert(ratingButtons, Button {
		x = ratingStarStartX + ((i - 1) * ratingStarStep), y = 145, scale = ratingButtonScale,
		name = "community_rating_" .. tostring(i),
		graphics = { emptyStar, fullStar, hoverStar, disabledStar },
		type = kToggle,
		sound = "cadi/ui_click.ogg",
		command = function() SaveRating(value) end,
	})
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_creation_rating", x = 1000, y = kCenter, image = "image/popup_back_generic_1",
		Text { x = 28, y = 30, w = 444, h = 34, label = "#" .. GetString("community_rating_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 42, y = 70, w = 416, h = 42, label = "#" .. creationName, font = nameFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 48, y = 116, w = 404, h = 25, label = "#" .. GetString("community_rating_help"), font = bodyFont, flags = kHAlignCenter + kVAlignCenter },
		Group(ratingButtons),
		Text { x = 46, y = 198, w = 408, h = 18, name = "community_rating_status",
			label = "#" .. GetString("community_rating_loading"), font = statusFont, flags = kHAlignCenter + kVAlignCenter },
		-- Centre the native-size action buttons around kCenter.
		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter - 81, y = 226, scale = 1, name = "community_rating_clear", label = "#" .. GetString("community_rating_clear"), command = function() SaveRating(0) end },
		Button { x = kCenter + 81, y = 226, scale = 1, name = "community_rating_cancel", label = "cancel", command = CloseRating, cancel = true },
	}
}

for i = 1, 5 do
	EnableWindow("community_rating_" .. tostring(i), false)
end
EnableWindow("community_rating_clear", false)
QueueCommand(function()
	CommunityApi.GetRating(creationId, function(summary, response, err)
		if err then
			SetLabel("community_rating_status", GetTextParams("community_rating_error", { tostring(err) }))
			return
		end
		current = tonumber(summary.your_rating) or 0
		SetLabel("community_rating_status", current > 0 and GetTextParams("community_rating_current", { tostring(current) }) or GetString("community_rating_none"))
		for i = 1, 5 do
			EnableWindow("community_rating_" .. tostring(i), summary.can_rate ~= false)
		end
		UpdateButtons()
	end)
end)
CenterFadeIn("community_creation_rating")
