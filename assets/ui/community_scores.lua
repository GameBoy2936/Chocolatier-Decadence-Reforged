--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Account Scores)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/scores.lua")
require("ui/hiscore_countries.lua")
ClearStringCache()

if not CommunityAccount.IsSignedIn() then
	DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_scores_requires_account") }
	return
end

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local headerFont = { labelFontName, 26, MaroonColor }
local introFont = { standardFont, 13, BlackColor }
local pageFont = { standardFont, 12.5, BlackColor }
local statusFont = { standardFont, 13, MaroonColor }
local ruleColor = Color(116, 82, 54, 60)

gCommunityScoresUI =
{
	items = {},
	selected = 0,
	page = 1,
	per_page = 5,
	loading = false,
}

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function State()
	return gCommunityScoresUI
end

local function PageCount()
	local state = State()
	if not state or table.getn(state.items or {}) == 0 then
		return 1
	end
	return Floor((table.getn(state.items) - 1) / state.per_page) + 1
end

local function CurrentItem()
	local state = State()
	if not state or state.selected < 1 then
		return nil
	end
	return state.items[state.selected]
end

local function FormatNumber(value)
	if HighScoreModel and HighScoreModel.FormatNumber then
		return HighScoreModel:FormatNumber(tonumber(value) or 0)
	end
	return tostring(tonumber(value) or 0)
end

local function SetStatus(text)
	SetLabel("community_scores_status", tostring(text or ""))
end

local function RefreshChildren()
	if not State() then
		return
	end
	FillWindow("community_scores_results", "ui/community_scores_results.lua")
end

local function UpdateControls()
	local state = State()
	if not state then
		return
	end

	local pages = PageCount()
	if state.page > pages then
		state.page = pages
	end
	if state.page < 1 then
		state.page = 1
	end

	SetLabel(
		"community_cookbook_page",
		GetTextParams("community_cookbook_page", { tostring(state.page), tostring(pages) })
	)
	EnableWindow("community_scores_prev", state.page > 1 and not state.loading)
	EnableWindow("community_scores_next", state.page < pages and not state.loading)

	local item = CurrentItem()
	EnableWindow("hiscore_details_button", item ~= nil and not state.loading)
	EnableWindow("community_scores_delete", item ~= nil and not state.loading)
end

local function RefreshUI()
	local state = State()
	if not state then
		return
	end

	local count = table.getn(state.items or {})
	if count == 0 then
		state.selected = 0
		state.page = 1
	else
		if state.selected < 1 or state.selected > count then
			state.selected = 1
		end
		local pages = PageCount()
		if state.page > pages then
			state.page = pages
		end
		if state.page < 1 then
			state.page = 1
		end
	end

	RefreshChildren()
	UpdateControls()
end

function CommunityScoresUISelectVisible(slot)
	local state = State()
	if not state or state.loading then
		return
	end
	local index = ((state.page - 1) * state.per_page) + slot
	if not state.items[index] then
		return
	end
	state.selected = index
	RefreshUI()
end

local function LoadList(message)
	local state = State()
	if not state or state.loading then
		return
	end

	state.loading = true
	SetStatus(message or GetString("community_scores_loading"))
	UpdateControls()

	CommunityScores.List(function(result, response, err)
		state = State()
		if not state then
			return
		end
		state.loading = false

		if err then
			if not CommunityAccount.IsSignedIn() then
				DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_session_expired") }
				gCommunityScoresUI = nil
				FadeCloseWindow("community_scores_panel", "account_required")
				return
			end
			SetStatus(GetTextParams("community_scores_error", { tostring(err) }))
			RefreshUI()
			return
		end

		state.items = result or {}
		state.selected = 0
		state.page = 1

		if table.getn(state.items) == 0 then
			SetStatus(GetString("community_scores_empty"))
		else
			state.selected = 1
			SetStatus(GetString("community_stats_owned_scores") .. ": " .. tostring(table.getn(state.items)))
		end
		RefreshUI()
	end)
end

local function ViewDetails()
	local item = CurrentItem()
	if not item then
		return
	end
	local snapshot = item.snapshot or {}
	if tonumber(item.score_version) ~= 1 or type(snapshot) ~= "table" or not snapshot.companyScore then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("hiscore_details_button_unavailable") }
		return
	end
	DisplayDialog {
		"ui/hiscore_details.lua",
		snapshot = snapshot,
		publicName = item.name,
		nationality = item.nationality,
		integrityStatus = item.integrity_status,
		campaignMode = item.campaign_mode or snapshot.campaignMode or "story",
		compactRemote = false,
	}
end

local function DeleteSelected()
	local state = State()
	local item = CurrentItem()
	if not state or not item or state.loading then
		return
	end

	local answer = DisplayDialog {
		"ui/ui_generic_yn.lua",
		text = "#" .. GetTextParams("community_scores_delete_confirm", { FormatNumber(item.score) })
	}
	if answer ~= "yes" then
		return
	end

	state.loading = true
	SetStatus(GetString("community_scores_deleting"))
	UpdateControls()

	CommunityScores.Delete(item.submission_id, function(body, response, err)
		state = State()
		if not state then
			return
		end
		state.loading = false

		if err then
			if not CommunityAccount.IsSignedIn() then
				DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_session_expired") }
				gCommunityScoresUI = nil
				FadeCloseWindow("community_scores_panel", "account_required")
				return
			end
			SetStatus(GetTextParams("community_scores_error", { tostring(err) }))
			RefreshUI()
			return
		end

		table.remove(state.items, state.selected)
		if state.selected > table.getn(state.items) then
			state.selected = table.getn(state.items)
		end
		if state.selected < 1 and table.getn(state.items) > 0 then
			state.selected = 1
		end
		SetStatus(GetString("community_scores_deleted"))
		RefreshUI()
	end)
end

local function PreviousPage()
	local state = State()
	if not state or state.loading or state.page <= 1 then
		return
	end
	state.page = state.page - 1
	state.selected = ((state.page - 1) * state.per_page) + 1
	RefreshUI()
end

local function NextPage()
	local state = State()
	if not state or state.loading or state.page >= PageCount() then
		return
	end
	state.page = state.page + 1
	state.selected = ((state.page - 1) * state.per_page) + 1
	RefreshUI()
end

local function CloseScores()
	gCommunityScoresUI = nil
	CommunityScoresUISelectVisible = nil
	FadeCloseWindow("community_scores_panel", "ok")
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_scores_panel", x = 1000, y = kCenter, image = "image/popup_back_generic_tall",
		Text { x = 35, y = 35, w = 432, h = 38, label = "#" .. GetString("community_scores_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 48, y = 73, w = 406, h = 32, label = "#" .. GetString("community_scores_intro"), font = introFont, flags = kHAlignCenter + kVAlignTop },
		Rectangle { x = 48, y = 92, w = 406, h = 1, color = ruleColor },

		-- The list now uses the full 406-pixel content column, just like the rest of
		-- the popup, instead of an arbitrary 342-pixel strip.
		Window { name = "community_scores_results", x = 48, y = 100, w = 406, h = 225 },

		SetStyle(C3ButtonStyle),
		Button { x = 48, y = 330, name = "community_scores_prev", label = "previous", command = PreviousPage },
		Text { x = 181, y = 340, w = 140, h = 22, name = "community_cookbook_page", label = "", font = pageFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 321, y = 330, name = "community_scores_next", label = "next", command = NextPage },
		Rectangle { x = 48, y = 378, w = 406, h = 1, color = ruleColor },

		Text { x = 48, y = 380, w = 406, h = 24, name = "community_scores_status", label = "", font = statusFont, flags = kHAlignCenter + kVAlignCenter },

		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter - 88, y = 414, name = "hiscore_details_button", label = "#" .. GetString("hiscore_details_button"), command = ViewDetails },
		Button { x = kCenter + 88, y = 414, name = "community_scores_delete", label = "#" .. GetString("community_scores_delete"), command = DeleteSelected },
		SetStyle(C3RoundButtonStyle),
		Button { x = 448, y = 425, name = "ok", label = "ok", default = true, cancel = true, command = CloseScores },
	}
}

RefreshUI()
QueueCommand(function() LoadList(GetString("community_scores_loading")) end)
CenterFadeIn("community_scores_panel")
