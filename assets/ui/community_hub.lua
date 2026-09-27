--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Hub UI)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/hub.lua")
require("community/identity.lua")
require("ui/hiscore_countries.lua")
ClearStringCache()

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local headerFont = { labelFontName, 28, MaroonColor }
local subHeaderFont = { standardFont, 14, BlackColor }
local statusFont = { standardFont, 14, BlackColor }
local statusStrongFont = { standardFont, 16, MaroonColor }
local spotlightHeaderFont = { labelFontName, 18, MaroonColor }
local spotlightFont = { standardFont, 14, BlackColor }
local smallFont = { standardFont, 12, BlackColor }
local ruleColor = Color(116, 82, 54, 65)

local loading = false

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function SetStatus(text)
	SetLabel("community_hub_status", tostring(text or ""))
end

local function DifficultyName(value)
	value = tonumber(value) or 1
	if HighScoreModel and HighScoreModel.DifficultyNameKey then
		return GetString(HighScoreModel:DifficultyNameKey(value))
	end
	if value == 3 then
		return GetString("difficulty_hard")
	end
	if value == 2 then
		return GetString("difficulty_medium")
	end
	return GetString("difficulty_easy")
end

local function AccountStatus()
	local signedIn = CommunityAccount.IsSignedIn()
	local profile = CommunityAccount.GetProfile() or {}
	if signedIn and profile.public_name and profile.public_name ~= "" then
		SetLabel("community_account_header", GetTextParams("community_hub_signed_in", { tostring(profile.public_name) }))
		local country = ""
		if profile.nationality and profile.nationality ~= "" and HighScoreCountries:IsValid(profile.nationality) then
			country = HighScoreCountries:GetName(profile.nationality)
		end
		SetLabel("community_account_header_meta", country)
	else
		SetLabel("community_account_header", GetString("community_hub_signed_out"))
		SetLabel("community_account_header_meta", GetString("community_hub_signin_hint"))
	end
end

local function RenderSummary(summary)
	if not summary then
		return
	end
	SetLabel("community_hub_server", GetString("community_hub_online"))
	SetLabel("community_hub_players", GetString("community_stats_players_online") .. ": " .. tostring(summary.players_online))
	SetLabel("community_hub_totals",
		GetString("community_stats_accounts") .. ": " .. tostring(summary.accounts) .. "  -  " ..
		GetString("community_stats_scores") .. ": " .. tostring(summary.community_scores) .. "  -  " ..
		GetString("community_stats_creations") .. ": " .. tostring(summary.community_creations))

	local top = summary.top_score
	if top then
		SetLabel("community_hub_top_score", GetTextParams("community_hub_top_score", { tostring(top.public_name), Dollars(top.score), DifficultyName(top.difficulty) }))
	else
		SetLabel("community_hub_top_score", GetString("community_hub_top_score_none"))
	end

	local featured = summary.featured_creation
	if featured then
		SetLabel("community_hub_featured", GetTextParams("community_hub_featured_creation", { tostring(featured.name), tostring(featured.author), tostring(featured.load_count) }))
	else
		SetLabel("community_hub_featured", GetString("community_hub_featured_none"))
	end
	SetStatus(GetString("community_hub_refreshed"))
end

local function RefreshSummary()
	if loading or CommunityTransport.IsBusy() then
		SetStatus(GetString("community_hub_busy"))
		return
	end
	loading = true
	SetStatus(GetString("community_hub_loading"))
	CommunityHub.GetSummary(function(summary, response, err)
		loading = false
		if err then
			SetLabel("community_hub_server", GetString("community_hub_offline"))
			SetLabel("community_hub_players", GetString("community_hub_players_unknown"))
			SetLabel("community_hub_totals", GetString("community_hub_totals_unknown"))
			SetLabel("community_hub_top_score", GetString("community_hub_spotlight_unavailable"))
			SetLabel("community_hub_featured", "")
			SetStatus(GetTextParams("community_hub_error", { tostring(err) }))
			return
		end
		RenderSummary(summary)
	end)
end

local function OpenHighScores()
	DisplayDialog { "ui/hiscore.lua" }
end

local function OpenCookbook()
	DisplayDialog { "ui/community_cookbook.lua", allow_load = false, source = "community_hub" }
end

local function OpenCloudSaves()
	-- Never open the Cloud Saves dialog while signed out.  DisplayDialog yields,
	-- and calling another DisplayDialog from the top level of a dialog script
	-- crosses Playground's Lua/C coroutine boundary and kills the coroutine.
	if not CommunityAccount.IsSignedIn() then
		local accountResult = DisplayDialog { "ui/community_account_menu.lua" }
		CommunityIdentity.SyncPlayer()
		AccountStatus()

		if accountResult ~= "signed_in" or not CommunityAccount.IsSignedIn() then
			return
		end
	end

	local result = DisplayDialog { "ui/community_cloud_saves.lua" }
	if result == "account_required" then
		CommunityIdentity.SyncPlayer()
		AccountStatus()
	end
end

local function OpenAccount()
	DisplayDialog { "ui/community_account_menu.lua" }
	CommunityIdentity.SyncPlayer()
	AccountStatus()
end

local function OpenStats()
	DisplayDialog { "ui/community_stats.lua" }
end

local function OpenDiscord()
	if CommunityTransport.IsBusy() then
		SetStatus(GetString("community_hub_busy"))
		return
	end
	SetStatus(GetString("community_hub_opening_discord"))
	CommunityHub.OpenExternal("discord", function(ok, err)
		if not ok then
			SetStatus(GetTextParams("community_hub_external_error", { tostring(err or "Could not open the Discord server.") }))
			return
		end
		SetStatus(GetString("community_hub_discord_opened"))
	end)
end

local function OpenWiki()
	if CommunityTransport.IsBusy() then
		SetStatus(GetString("community_hub_busy"))
		return
	end
	SetStatus(GetString("community_hub_opening_wiki"))
	CommunityHub.OpenExternal("wiki", function(ok, err)
		if not ok then
			SetStatus(GetTextParams("community_hub_external_error", { tostring(err or "Could not open the Chocolatier Series Wiki.") }))
			return
		end
		SetStatus(GetString("community_hub_wiki_opened"))
	end)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_hub_panel", x = 1000, y = kCenter, image = "image/popup_back_generic_tall",

		Bitmap
		{
			image = "image/popup_nameplate",
			x = kCenter, y = 0,
			Text { x = 34, y = 10, w = 270, h = 38, label = "#" .. GetString("community_menu"), font = nameplateFont, flags = kHAlignCenter + kVAlignCenter },
		},

		Text { x = 48, y = 61, w = 406, h = 34, label = "#" .. GetString("community_hub_intro"), font = subHeaderFont, flags = kHAlignCenter + kVAlignTop },

		Rectangle { x = 48, y = 99, w = 406, h = 1, color = ruleColor },
		Text { x = 58, y = 110, w = 170, h = 20, name = "community_hub_server",
			label = "#" .. GetString("community_hub_connecting"), font = statusStrongFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 260, y = 110, w = 185, h = 20, name = "community_hub_players",
			label = "#" .. GetString("community_hub_players_unknown"), font = statusFont, flags = kHAlignRight + kVAlignCenter },
		Text { x = 58, y = 132, w = 240, h = 20, name = "community_account_header", label = "", font = statusStrongFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 146, y = 132, w = 300, h = 20, name = "community_account_header_meta", label = "", font = smallFont, flags = kHAlignRight + kVAlignCenter },

		SetStyle(C3ButtonMediumStyle),
		Button { x = 72, y = 166, label = "#" .. GetString("high_scores"), command = OpenHighScores },
		Button { x = 260, y = 166, label = "#" .. GetString("community_hub_cookbook"), command = OpenCookbook },
		Button { x = 72, y = 217, label = "#" .. GetString("community_cloud_header"), command = OpenCloudSaves },
		Button { x = 260, y = 217, label = "#" .. GetString("community_account_header"), command = OpenAccount },

		Rectangle { x = 48, y = 271, w = 406, h = 1, color = ruleColor },
		Text { x = 55, y = 281, w = 392, h = 24, label = "#" .. GetString("community_hub_spotlight"), font = spotlightHeaderFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 58, y = 307, w = 386, h = 22, name = "community_hub_top_score",
			label = "#" .. GetString("community_hub_spotlight_loading"), font = spotlightFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 58, y = 331, w = 386, h = 22, name = "community_hub_featured", label = "", font = spotlightFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 58, y = 355, w = 386, h = 20, name = "community_hub_totals",
			label = "#" .. GetString("community_hub_totals_unknown"), font = smallFont, flags = kHAlignCenter + kVAlignCenter },

		SetStyle(C3ButtonStyle),
		Button { x = kCenter - 133, y = 410, label = "#" .. GetString("community_hub_discord"), command = OpenDiscord },
		Button { x = kCenter, y = 410, label = "#" .. GetString("community_hub_stats"), command = OpenStats },
		Button { x = kCenter + 133, y = 410, label = "#" .. GetString("community_hub_wiki"), command = OpenWiki },

		SetStyle(C3RoundButtonStyle),
		Button { x = 448, y = 425, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("community_hub_panel", "ok") end },
	}
}

CenterFadeIn("community_hub_panel")
AccountStatus()
QueueCommand(RefreshSummary)
