--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Community Statistics)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/hub.lua")
ClearStringCache()

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local headerFont = { labelFontName, 25, MaroonColor }
local sectionFont = { labelFontName, 15, MaroonColor }
local labelFont = { standardFont, 14, BlackColor }
local valueFont = { standardFont, 18, MaroonColor }
local smallFont = { standardFont, 12, BlackColor }
local ruleColor = Color(116, 82, 54, 65)
local loading = false

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function Render(summary)
	SetLabel("community_stats_online", tostring(summary.players_online))
	SetLabel("community_stats_accounts", tostring(summary.accounts))
	SetLabel("community_stats_scores", tostring(summary.community_scores))
	SetLabel("community_stats_owned_scores", tostring(summary.account_owned_scores))
	SetLabel("community_stats_creations", tostring(summary.community_creations))
	SetLabel("community_stats_loads", tostring(summary.creation_loads))
	SetLabel("community_stats_cloud", tostring(summary.cloud_saves))
	SetLabel("community_stats_server", tostring(summary.version))
	SetLabel("community_stats_status", GetTextParams("community_stats_live_help", { tostring(summary.presence_window_seconds) }))
end

local function Refresh()
	if loading or CommunityTransport.IsBusy() then
		return
	end
	loading = true
	SetLabel("community_stats_status", GetString("community_hub_loading"))
	CommunityHub.GetSummary(function(summary, response, err)
		loading = false
		if err then
			SetLabel("community_stats_status", GetTextParams("community_hub_error", { tostring(err) }))
			return
		end
		Render(summary)
	end)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_stats_panel", x = 1000, y = kCenter, image = "image/popup_back_generic_tall",

		Text { x = 35, y = 28, w = 432, h = 38, label = "#" .. GetString("community_stats_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 50, y = 72, w = 402, h = 28, label = "#" .. GetString("community_stats_intro"), font = smallFont, flags = kHAlignCenter + kVAlignTop },
		Rectangle { x = 48, y = 108, w = 406, h = 1, color = ruleColor },

		-- The live totals read more cleanly as two related groups instead of one
		-- long settings-style list.
		Text { x = 54, y = 118, w = 178, h = 25, label = "#" .. GetString("community_stats_group_players_scores"), font = sectionFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 270, y = 118, w = 182, h = 25, label = "#" .. GetString("community_stats_group_creations_cloud"), font = sectionFont, flags = kHAlignCenter + kVAlignCenter },
		Rectangle { x = 251, y = 119, w = 1, h = 169, color = ruleColor },

		-- Players & Scores
		Text { x = 58, y = 153, w = 132, h = 22, label = "#" .. GetString("community_stats_players_online"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 192, y = 153, w = 38, h = 22, name = "community_stats_online", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },
		Text { x = 58, y = 188, w = 132, h = 22, label = "#" .. GetString("community_stats_accounts"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 192, y = 188, w = 38, h = 22, name = "community_stats_accounts", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },
		Text { x = 58, y = 223, w = 132, h = 22, label = "#" .. GetString("community_stats_scores"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 192, y = 223, w = 38, h = 22, name = "community_stats_scores", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },
		Text { x = 58, y = 258, w = 132, h = 22, label = "#" .. GetString("community_stats_owned_scores"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 192, y = 258, w = 38, h = 22, name = "community_stats_owned_scores", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },

		-- Creations & Cloud
		Text { x = 274, y = 153, w = 126, h = 22, label = "#" .. GetString("community_stats_creations"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 408, y = 153, w = 36, h = 22, name = "community_stats_creations", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },
		Text { x = 274, y = 188, w = 126, h = 22, label = "#" .. GetString("community_stats_creation_loads"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 408, y = 188, w = 36, h = 22, name = "community_stats_loads", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },
		Text { x = 274, y = 223, w = 126, h = 22, label = "#" .. GetString("community_cloud_header"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 408, y = 223, w = 36, h = 22, name = "community_stats_cloud", label = "#-", font = valueFont, flags = kHAlignRight + kVAlignCenter },

		-- Technical information sits apart from the actual community totals.
		Rectangle { x = 48, y = 300, w = 406, h = 1, color = ruleColor },
		Text { x = 70, y = 311, w = 110, h = 20, label = "#" .. GetString("community_stats_server_version"), font = labelFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 181, y = 311, w = 251, h = 20, name = "community_stats_server", label = "#-", font = smallFont, flags = kHAlignRight + kVAlignCenter },

		Text { x = 54, y = 350, w = 394, h = 48, name = "community_stats_status",
			label = "#" .. GetString("community_hub_loading"), font = smallFont, flags = kHAlignCenter + kVAlignTop },

		SetStyle(C3ButtonStyle),
		Button { x = kCenter, y = 410, label = "#" .. GetString("community_hub_refresh"), command = Refresh },
		SetStyle(C3RoundButtonStyle),
		Button { x = 448, y = 425, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("community_stats_panel", "ok") end },
	}
}
CenterFadeIn("community_stats_panel")
QueueCommand(Refresh)
