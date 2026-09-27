--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Creation Rendering)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/creation.lua")

-------------------------------------------------------------------------------
-- Creation Rendering
-------------------------------------------------------------------------------

CommunityCreationRender = CommunityCreationRender or {}

local function Tint(layer)
	return Color(layer.red or 255, layer.green or 255, layer.blue or 255, 255)
end

function CommunityCreationRender.Appearance(value, x, y, scale)
	local creation = value
	if type(value) == "table" and value.creation then
		creation = value.creation
	end
	local normalized, err = CommunityCreation.Normalize(creation)
	if not normalized then
		DebugOut("COMMUNITY", "Could not render creation appearance: " .. tostring(err))
		return Bitmap { x = x or 0, y = y or 0, image = "items/unknown", scale = scale or 1 }
	end

	x = x or 0
	y = y or 0
	scale = scale or 1

	local contents = {}
	local isServedDrink = (normalized.category == "beverage")
	local mugInjected = not isServedDrink

	for _, layer in ipairs(normalized.appearance) do
		table.insert(contents, BitmapTint {
			x = x, y = y,
			image = "custom/" .. layer.image,
			tint = Tint(layer),
			scale = scale,
		})
		table.insert(contents, Bitmap {
			x = x, y = y,
			image = "custom/" .. layer.image .. "_highlight",
			scale = scale,
		})

		if isServedDrink and not mugInjected and string.find(layer.image, "layer2", 1, true) then
			table.insert(contents, Bitmap { x = x, y = y, image = "custom/" .. normalized.category .. "/mug", scale = scale })
			table.insert(contents, Bitmap { x = x, y = y, image = "custom/" .. normalized.category .. "/rim_outer", scale = scale })
			mugInjected = true
		end
	end

	if isServedDrink then
		table.insert(contents, Bitmap { x = x, y = y, image = "custom/" .. normalized.category .. "/rim_inner", scale = scale })
	end

	if isServedDrink and not mugInjected then
		table.insert(contents, 1, Bitmap { x = x, y = y, image = "custom/" .. normalized.category .. "/rim_outer", scale = scale })
		table.insert(contents, 1, Bitmap { x = x, y = y, image = "custom/" .. normalized.category .. "/mug", scale = scale })
	end

	if table.getn(contents) == 0 then
		return Bitmap { x = x or 0, y = y or 0, image = "items/unknown", scale = scale }
	end
	return Group(contents)
end

function CommunityCreationRender.Ingredient(name, x, y, scale, unlocked)
	x = x or 0
	y = y or 0
	scale = scale or 1
	if unlocked then
		return Bitmap { x = x, y = y, image = "items/" .. name .. "_big", scale = scale }
	end
	-- The Secret Test Kitchen already uses black/empty discovery language.
	-- Locked ingredients keep their silhouette but hide the name.
	return BitmapTint {
		x = x, y = y,
		image = "items/" .. name .. "_big",
		tint = Color(0, 0, 0, 255),
		scale = scale,
	}
end

-------------------------------------------------------------------------------
-- Rating Stars
-------------------------------------------------------------------------------

-- Rating artwork is stored at 128 px while the UI uses a 48 px working size.

local communityRatingStarAssets =
{
	empty =
	{
		up = "image/star_empty_up",
		over = "image/star_empty_over",
		down = "image/star_empty_down",
	},
	full =
	{
		up = "image/star_full_up",
		over = "image/star_full_over",
		down = "image/star_full_down",
	},
	half =
	{
		up = "image/star_half_up",
		over = "image/star_half_over",
		down = "image/star_half_down",
	},
}

local communityRatingStarBasePixels = 48
local communityRatingStarSourcePixels = 128
local communityRatingStarScaleFactor = communityRatingStarBasePixels / communityRatingStarSourcePixels

local function RatingHalfUnits(value)
	local rating = tonumber(value) or 0
	if rating < 0 then
		rating = 0
	end
	if rating > 5 then
		rating = 5
	end
	-- The shipped Lua sandbox has no math table.
	local units = tonumber(string.format("%.0f", rating * 2)) or 0
	if units < 0 then
		units = 0
	end
	if units > 10 then
		units = 10
	end
	return units
end

function CommunityCreationRender.RatingStarAsset(kind, state)
	local bucket = communityRatingStarAssets[kind] or communityRatingStarAssets.empty
	state = state or "up"
	return bucket[state] or bucket.up or communityRatingStarAssets.empty.up
end

function CommunityCreationRender.RatingStarScale(uiScale)
	return (uiScale or 1) * communityRatingStarScaleFactor
end

function CommunityCreationRender.RatingStarKind(value, slot)
	local units = RatingHalfUnits(value)
	local whole = (tonumber(slot) or 1) * 2
	if units >= whole then
		return "full"
	end
	if units == whole - 1 then
		return "half"
	end
	return "empty"
end

function CommunityCreationRender.RatingStars(value, x, y, uiScale, namePrefix)
	x = x or 0
	y = y or 0
	uiScale = uiScale or 1
	local assetScale = CommunityCreationRender.RatingStarScale(uiScale)
	local step = 52 * uiScale
	local contents = {}
	for i = 1, 5 do
		local spec =
		{
			x = x + ((i - 1) * step),
			y = y,
			image = CommunityCreationRender.RatingStarAsset(CommunityCreationRender.RatingStarKind(value, i), "up"),
			scale = assetScale,
		}
		if namePrefix and namePrefix ~= "" then
			spec.name = namePrefix .. tostring(i)
		end
		table.insert(contents, Bitmap(spec))
	end
	return Group(contents)
end

function CommunityCreationRender.UpdateRatingStars(namePrefix, value, uiScale)
	if not namePrefix or namePrefix == "" then
		return
	end
	local assetScale = CommunityCreationRender.RatingStarScale(uiScale or 1)
	for i = 1, 5 do
		SetBitmap(
			namePrefix .. tostring(i),
			CommunityCreationRender.RatingStarAsset(CommunityCreationRender.RatingStarKind(value, i), "up"),
			assetScale
		)
	end
end
