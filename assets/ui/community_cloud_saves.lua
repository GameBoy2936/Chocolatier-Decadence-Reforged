--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Community Cloud Saves UI)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/cloud.lua")
ClearStringCache()

-- Authentication is intentionally gated by the caller before this dialog is
-- constructed.  Do not open a modal dialog from this file's top-level code:
-- Playground's Lua 5.0 host cannot yield across that C-call boundary.

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local headerFont = { labelFontName, 26, MaroonColor }
local rowFont = { standardFont, 15.5, BlackColor }
local rowMetaFont = { standardFont, 12.5, BlackColor }
local introFont = { standardFont, 13, BlackColor }
local pageFont = { standardFont, 12.5, BlackColor }
local statusFont = { standardFont, 13, MaroonColor }
local ruleColor = Color(116, 82, 54, 60)
local transparentButtonGraphics =
{
	"image/reforged_transparent", "image/reforged_transparent", "image/reforged_transparent"
}

local items = {}
local selected = 0
local page = 1
local perPage = 5
local loading = false

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function PageCount()
	if table.getn(items) == 0 then
		return 1
	end
	return Floor((table.getn(items) - 1) / perPage) + 1
end

local function FormatDate(value)
	value = tostring(value or "")
	-- string.match is not present in Chocolatier's Lua 5.0 sandbox.  Community
	-- timestamps are ISO-8601, so fixed-position parsing is both sufficient and
	-- compatible with the game's original string library.
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

local function DifficultyName(value)
	value = tonumber(value) or 1
	if HighScoreModel and HighScoreModel.DifficultyNameKey then
		return GetString(HighScoreModel:DifficultyNameKey(value))
	end
	return tostring(value)
end

local function SetStatus(text)
	SetLabel("community_cloud_status", tostring(text or ""))
end

local function SessionExpired(err)
	if not err or CommunityAccount.IsSignedIn() then
		return false
	end
	DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_session_expired") }
	FadeCloseWindow("community_cloud_panel", "account_required")
	return true
end

local function UpdateActionButtons()
	local item = selected > 0 and items[selected] or nil
	EnableWindow("community_cloud_restore_new", item ~= nil and GetNumUsers() < 10 and not loading)
	EnableWindow("community_cloud_restore_current", item ~= nil and GetNumUsers() > 0 and not loading)
	EnableWindow("community_cloud_delete", item ~= nil and not loading)
end

local function RefreshRows()
	local pages = PageCount()
	if page > pages then
		page = pages
	end
	if page < 1 then
		page = 1
	end
	local start = ((page - 1) * perPage) + 1
	for slot = 1, perPage do
		local index = start + slot - 1
		local item = items[index]
		local suffix = tostring(slot)
		if item then
			local metadata = item.metadata or {}
			local name = tostring(item.display_name or metadata.display_name or GetString("community_cloud_unnamed"))
			local details = GetTextParams("community_cloud_row_meta", { tostring(item.current_revision or 0), DifficultyName(metadata.difficulty), tostring(metadata.week or 1) })
			SetLabel("community_cloud_row" .. suffix, name)
			SetLabel("community_cloud_meta" .. suffix, details)
			SetLabel("community_cloud_selected" .. suffix, selected == index and ">" or "")
			EnableWindow("community_cloud_select" .. suffix, true)
		else
			SetLabel("community_cloud_row" .. suffix, "")
			SetLabel("community_cloud_meta" .. suffix, "")
			SetLabel("community_cloud_selected" .. suffix, "")
			EnableWindow("community_cloud_select" .. suffix, false)
		end
	end
	SetLabel("community_cookbook_page", GetTextParams("community_cookbook_page", { tostring(page), tostring(pages) }))
	EnableWindow("community_cloud_prev", page > 1 and not loading)
	EnableWindow("community_cloud_next", page < pages and not loading)

	UpdateActionButtons()
end

local function Select(index)
	if not items[index] then
		return
	end
	selected = index
	RefreshRows()
end

local function SelectVisible(slot)
	Select(((page - 1) * perPage) + slot)
end

local function LoadList(statusText)
	if CommunityTransport.IsBusy() then
		SetStatus(GetString("community_cookbook_busy"))
		return
	end
	loading = true
	if statusText then
		SetStatus(statusText)
	end
	EnableWindow("community_cloud_sync", false)
	EnableWindow("community_hub_refresh", false)
	UpdateActionButtons()
	CommunityCloud.List(function(result, response, err)
		loading = false
		EnableWindow("community_cloud_sync", true)
		EnableWindow("community_hub_refresh", true)
		if err then
			if SessionExpired(err) then
				return
			end
			SetStatus(GetTextParams("community_cloud_error", { tostring(err) }))
			RefreshRows()
			return
		end
		items = result or {}
		selected = 0
		page = 1
		if table.getn(items) == 0 then
			SetStatus(GetString("community_cloud_none"))
		else
			SetStatus(GetString("community_cloud_header") .. ": " .. tostring(table.getn(items)))
		end
		RefreshRows()
	end)
end

local function SyncCurrent()
	if CommunityTransport.IsBusy() then
		SetStatus(GetString("community_cookbook_busy"))
		return
	end
	if GetNumUsers() <= 0 then
		SetStatus(GetString("community_cloud_no_local_game"))
		return
	end
	loading = true
	EnableWindow("community_cloud_sync", false)
	EnableWindow("community_hub_refresh", false)
	SetStatus(GetString("community_cloud_syncing"))
	UpdateActionButtons()
	CommunityCloud.SyncCurrent(function(result, response, err)
		loading = false
		EnableWindow("community_cloud_sync", true)
		EnableWindow("community_hub_refresh", true)
		if err then
			if SessionExpired(err) then
				return
			end
			SetStatus(GetTextParams("community_cloud_error", { tostring(err) }))
			UpdateActionButtons()
			return
		end
		if result and (result.account_mismatch or result.invalid_link or result.missing) then
			local key = "community_cloud_relink_account_prompt"
			if result.invalid_link then
				key = "community_cloud_relink_invalid_prompt"
			end
			if result.missing then
				key = "community_cloud_relink_missing_prompt"
			end
			local relink = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetString(key) }
			if relink == "yes" then
				loading = true
				SetStatus(GetString("community_cloud_syncing"))
				UpdateActionButtons()
				CommunityCloud.SyncCurrentAsNew(function(forked, response2, err2)
					loading = false
					if err2 then
						if SessionExpired(err2) then
							return
						end
						SetStatus(GetTextParams("community_cloud_error", { tostring(err2) }))
						UpdateActionButtons()
						return
					end
					SetStatus(GetString("community_cloud_relinked"))
					LoadList(nil)
				end)
			else
				UpdateActionButtons()
			end
			return
		end
		if result and result.conflict then
			local cloud = result.cloud or {}
			SetStatus(GetString("community_cloud_conflict"))
			local restore = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetString("community_cloud_conflict_restore_prompt") }
			if restore == "yes" and cloud.id and cloud.id ~= "" then
				loading = true
				SetStatus(GetString("community_cloud_restoring"))
				UpdateActionButtons()
				CommunityCloud.RestoreIntoCurrent(cloud.id, function(ok2, response2, err2)
					loading = false
					if not ok2 then
						if SessionExpired(err2) then
							return
						end
						SetStatus(GetTextParams("community_cloud_error", { tostring(err2) }))
						UpdateActionButtons()
						return
					end
					DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_cloud_restored") }
					FadeCloseWindow("community_cloud_panel", "restored")
					QueueCommand(function() SwapToModal("ui/mapview.lua") end)
				end)
				return
			end
			local keepBoth = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetString("community_cloud_conflict_fork_prompt") }
			if keepBoth == "yes" then
				loading = true
				SetStatus(GetString("community_cloud_syncing"))
				UpdateActionButtons()
				CommunityCloud.SyncCurrentAsNew(function(forked, response2, err2)
					loading = false
					if err2 then
						if SessionExpired(err2) then
							return
						end
						SetStatus(GetTextParams("community_cloud_error", { tostring(err2) }))
						UpdateActionButtons()
						return
					end
					SetStatus(GetString("community_cloud_conflict_forked"))
					LoadList(nil)
				end)
			else
				LoadList(nil)
			end
			return
		end
		if result and result.unchanged then
			SetStatus(GetString("community_cloud_up_to_date"))
			RefreshRows()
		else
			SetStatus(GetTextParams("community_cloud_synced", { tostring(result.cloud.current_revision or 0) }))
			LoadList(nil)
		end
	end)
end

local function RestoreNew()
	local item = selected > 0 and items[selected] or nil
	if not item or loading then
		return
	end
	if GetNumUsers() >= 10 then
		SetStatus(GetString("community_cloud_local_full"))
		return
	end
	local suggested = tostring(item.display_name or (item.metadata and item.metadata.display_name) or "Cloud Game")
	local newName = DisplayDialog { "ui/ui_entername.lua", name = suggested }
	if not newName or newName == "" then
		return
	end
	local answer = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetTextParams("community_cloud_import_confirm", { newName }) }
	if answer ~= "yes" then
		return
	end
	loading = true
	SetStatus(GetString("community_cloud_restoring"))
	UpdateActionButtons()
	CommunityCloud.ImportAsNewLocal(item.id, newName, function(ok, response, err)
		loading = false
		if not ok then
			if SessionExpired(err) then
				return
			end
			SetStatus(GetTextParams("community_cloud_error", { tostring(err) }))
			UpdateActionButtons()
			return
		end
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetTextParams("community_cloud_imported", { newName }) }
		FadeCloseWindow("community_cloud_panel", "restored")
		QueueCommand(function() SwapToModal("ui/mapview.lua") end)
	end)
end

local function RestoreCurrent()
	local item = selected > 0 and items[selected] or nil
	if not item or loading or GetNumUsers() <= 0 then
		return
	end
	local answer = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetTextParams("community_cloud_restore_confirm", { tostring(item.display_name or "") }) }
	if answer ~= "yes" then
		return
	end
	Player:SaveGame()
	loading = true
	SetStatus(GetString("community_cloud_restoring"))
	UpdateActionButtons()
	CommunityCloud.RestoreIntoCurrent(item.id, function(ok, response, err)
		loading = false
		if not ok then
			if SessionExpired(err) then
				return
			end
			SetStatus(GetTextParams("community_cloud_error", { tostring(err) }))
			UpdateActionButtons()
			return
		end
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_cloud_restored") }
		FadeCloseWindow("community_cloud_panel", "restored")
		QueueCommand(function() SwapToModal("ui/mapview.lua") end)
	end)
end

local function DeleteSelected()
	local item = selected > 0 and items[selected] or nil
	if not item or loading then
		return
	end
	local answer = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetTextParams("community_cloud_delete_confirm", { tostring(item.display_name or "") }) }
	if answer ~= "yes" then
		return
	end
	loading = true
	SetStatus(GetString("community_cloud_deleting"))
	UpdateActionButtons()
	CommunityCloud.Delete(item.id, function(body, response, err)
		loading = false
		if err then
			if SessionExpired(err) then
				return
			end
			SetStatus(GetTextParams("community_cloud_error", { tostring(err) }))
			UpdateActionButtons()
			return
		end
		LoadList(GetString("community_cloud_deleted"))
	end)
end

local function Row(slot, y)
	return Group {
		Text { x = 50, y = y + 5, w = 18, h = 20, name = "community_cloud_selected" .. slot, label = "", font = { labelFontName, 14, MaroonColor }, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 72, y = y + 1, w = 330, h = 23, name = "community_cloud_row" .. slot, label = "", font = rowFont, flags = kHAlignLeft + kVAlignCenter },
		Text { x = 72, y = y + 23, w = 330, h = 18, name = "community_cloud_meta" .. slot, label = "", font = rowMetaFont, flags = kHAlignLeft + kVAlignCenter },
		Button { x = 48, y = y, w = 406, h = 43, name = "community_cloud_select" .. slot,
			graphics = transparentButtonGraphics, type = kPush, command = function() SelectVisible(slot) end },
		Rectangle { x = 48, y = y + 43, w = 406, h = 1, color = ruleColor },
	}
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_cloud_panel", x = 1000, y = kCenter, image = "image/popup_back_generic_tall",
		Text { x = 35, y = 15, w = 432, h = 38, label = "#" .. GetString("community_cloud_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 48, y = 53, w = 406, h = 30, label = "#" .. GetString("community_cloud_intro"), font = introFont, flags = kHAlignCenter + kVAlignTop },

		SetStyle(C3ButtonMediumStyle),
		Button { x = 78, y = 84, name = "community_cloud_sync", label = "#" .. GetString("community_cloud_sync_current"), command = SyncCurrent },
		Button { x = 259, y = 84, name = "community_hub_refresh", label = "#" .. GetString("community_hub_refresh"), command = function() LoadList(GetString("community_cloud_loading")) end },
		Rectangle { x = 48, y = 134, w = 406, h = 1, color = ruleColor },

		Row(1, 140), Row(2, 184), Row(3, 228), Row(4, 272), Row(5, 316),

		SetStyle(C3ButtonStyle),
		Button { x = 48, y = 363, name = "community_cloud_prev", label = "previous", command = function()
			page = page - 1
			RefreshRows()
		end },
		Text { x = 181, y = 373, w = 140, h = 22, name = "community_cookbook_page", label = "", font = pageFont, flags = kHAlignCenter + kVAlignCenter },
		Button { x = 321, y = 363, name = "community_cloud_next", label = "next", command = function()
			page = page + 1
			RefreshRows()
		end },
		Rectangle { x = 48, y = 411, w = 406, h = 1, color = ruleColor },

		Text { x = 48, y = 414, w = 406, h = 20, name = "community_cloud_status", label = "#" .. GetString("community_cloud_loading"), font = statusFont, flags = kHAlignCenter + kVAlignCenter },

		-- Full-scale stock controls across the footer.  The custom style changes only
		-- the label font so the longer restore strings fit; the button art stays 1.0.
		SetStyle(C3ButtonStyle),
		Button { x = kCenter - 133, y = 410, name = "community_cloud_restore_new", label = "#" .. GetString("community_cloud_import_new"), command = RestoreNew },
		Button { x = kCenter, y = 410, name = "community_cloud_restore_current", label = "#" .. GetString("community_cloud_restore_current"), command = RestoreCurrent },
		Button { x = kCenter + 133, y = 410, name = "community_cloud_delete", label = "#" .. GetString("community_cloud_delete"), command = DeleteSelected },
		SetStyle(C3RoundButtonStyle),
		Button { x = 448, y = 425, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("community_cloud_panel", "ok") end },
	}
}

for i = 1, perPage do
	EnableWindow("community_cloud_select" .. tostring(i), false)
end
RefreshRows()
CenterFadeIn("community_cloud_panel")
QueueCommand(function() LoadList(GetString("community_cloud_loading")) end)
