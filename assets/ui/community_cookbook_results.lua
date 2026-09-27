--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Cookbook Results)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/render.lua")
require("ui/hiscore_countries.lua")

local state = gCommunityCookbook or {}
local items = state.items or {}
local contents = {}

local nameFont = { standardFont, 16, BlackColor }
local selectedNameFont = { standardFont, 16, MaroonColor }
local metaFont = { standardFont, 12, BlackColor }
local selectedMetaFont = { standardFont, 12, MaroonColor }
local ruleColor = Color(116, 82, 54, 55)
local transparentButtonGraphics =
{
	"image/reforged_transparent",
	"image/reforged_transparent",
	"image/reforged_transparent",
}

for slot = 1, 7 do
	local item = items[slot]
	local y = (slot - 1) * 38
	if item then
		local selected = (state.selected_index == slot)
		local availability = CommunityCreation.GetAvailability(item.creation)
		local ready = availability and availability.can_load
		local categoryName = GetString(item.creation.category)
		local statusText = ready and GetString("community_creation_ready_short") or GetString("community_creation_locked_short")

		table.insert(contents, CommunityCreationRender.Appearance(item.creation, 5, y + 2, 0.25))
		table.insert(contents, Text {
			x = 42, y = y + 2, w = 300, h = 18,
			label = "#" .. item.creation.name,
			font = selected and selectedNameFont or nameFont,
			flags = kHAlignLeft + kVAlignTop,
		})
		local metaX = 43
		local metaW = 250
		local nationality = item.author and item.author.nationality or ""
		if nationality ~= "" and HighScoreCountries:IsValid(nationality) then
			table.insert(contents, Bitmap {
				x = 43, y = y + 20,
				image = HighScoreCountries:GetFlag(nationality),
				scale = 0.15,
			})
			metaX = 69
			metaW = 234
		end
		table.insert(contents, Text {
			x = metaX, y = y + 20, w = metaW, h = 16,
			label = "#" .. item.author.public_name .. "  -  " .. categoryName,
			font = selected and selectedMetaFont or metaFont,
			flags = kHAlignLeft + kVAlignTop,
		})
		table.insert(contents, Text {
			x = 336, y = y + 10, w = 88, h = 18,
			label = "#" .. statusText,
			font = selected and selectedMetaFont or metaFont,
			flags = kHAlignRight + kVAlignCenter,
		})
		local tempSlot = slot
		table.insert(contents, Button {
			x = 0, y = y, w = 432, h = 37,
			graphics = transparentButtonGraphics,
			sound = "cadi/ui_click.ogg",
			type = kPush,
			command = function() CommunityCookbookSelect(tempSlot) end,
		})
		table.insert(contents, Rectangle { x = 0, y = y + 37, w = 432, h = 1, color = ruleColor })
	end
end

MakeDialog(contents)
