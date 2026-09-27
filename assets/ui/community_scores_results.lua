--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Score Results)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

local state = gCommunityScoresUI or {}
local items = state.items or {}
local page = tonumber(state.page) or 1
local perPage = tonumber(state.per_page) or 5
local selectedIndex = tonumber(state.selected) or 0
local contents = {}

local metaFont = { standardFont, 12.5, BlackColor }
local scoreFont = { standardFont, 18, MaroonColor }
local selectedFill = Color(164, 116, 66, 32)
local ruleColor = Color(116, 82, 54, 60)
local transparentButtonGraphics =
{
	"image/reforged_transparent", "image/reforged_transparent", "image/reforged_transparent"
}

local function FormatNumber(value)
	if HighScoreModel and HighScoreModel.FormatNumber then
		return HighScoreModel:FormatNumber(tonumber(value) or 0)
	end
	return tostring(tonumber(value) or 0)
end

local function FormatDate(value)
	value = tostring(value or "")
	-- Timestamps use fixed ISO positions; the shipped Lua has no string.match.
	if string.len(value) < 16 then
		return value
	end
	if string.sub(value, 5, 5) ~= "-" or string.sub(value, 8, 8) ~= "-" or
	   string.sub(value, 11, 11) ~= "T" or string.sub(value, 14, 14) ~= ":" then
		return value
	end
	local y = string.sub(value, 1, 4)
	local m = string.sub(value, 6, 7)
	local d = string.sub(value, 9, 10)
	local h = string.sub(value, 12, 13)
	local mi = string.sub(value, 15, 16)
	if not tonumber(y) or not tonumber(m) or not tonumber(d) or not tonumber(h) or not tonumber(mi) then
		return value
	end
	return d .. "/" .. m .. "/" .. y .. " " .. h .. ":" .. mi .. " UTC"
end

local function RankName(item)
	local snapshot = item and item.snapshot or {}
	local rank = tonumber(snapshot.rank) or 0
	if rank > 0 and RankNames and RankNames[rank] then
		return GetString(RankNames[rank])
	end
	return ""
end

local start = ((page - 1) * perPage) + 1
for slot = 1, perPage do
	local index = start + slot - 1
	local item = items[index]
	local y = (slot - 1) * 45

	if item then
		local title = FormatNumber(item.score)
		local rankName = RankName(item)
		local meta = FormatDate(item.submitted_at_utc)
		if item.campaign_mode == "free" then
			meta = GetString("hiscore_mode_free_play") .. "  -  " .. meta
		elseif rankName ~= "" then
			meta = rankName .. "  -  " .. meta
		end

		if selectedIndex == index then
			table.insert(contents, Rectangle { x = 0, y = y + 1, w = 406, h = 43, color = selectedFill })
		end
		local tempSlot = slot
		table.insert(contents, Button {
			x = 0, y = y, w = 406, h = 44,
			graphics = transparentButtonGraphics, type = kPush,
			command = function()
				if CommunityScoresUISelectVisible then
					CommunityScoresUISelectVisible(tempSlot)
				end
			end
		})
		table.insert(contents, Text {
			x = 4, y = y + 11, w = 20, h = 20,
			label = selectedIndex == index and "#>" or "",
			font = { labelFontName, 14, MaroonColor }, flags = kHAlignCenter + kVAlignCenter
		})
		table.insert(contents, Text {
			x = 30, y = y + 4, w = 142, h = 30,
			label = "#" .. title, font = scoreFont, flags = kHAlignLeft + kVAlignCenter
		})
		table.insert(contents, Text {
			x = 177, y = y + 9, w = 221, h = 24,
			label = "#" .. meta, font = metaFont, flags = kHAlignRight + kVAlignCenter
		})
	end

	table.insert(contents, Rectangle { x = 0, y = y + 44, w = 406, h = 1, color = ruleColor })
end

-- FillWindow children need an explicit drawable root in Playground.
local root = { x = 0, y = 0, w = 406, h = 225 }
for _, control in ipairs(contents) do
	table.insert(root, control)
end
MakeDialog(root)
