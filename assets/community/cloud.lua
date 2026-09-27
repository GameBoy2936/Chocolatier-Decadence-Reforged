--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Cloud Saves)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/version.lua")
require("community/account.lua")
require("community/transport.lua")

-------------------------------------------------------------------------------
-- Cloud State
-------------------------------------------------------------------------------

CommunityCloud = CommunityCloud or {}
CommunityCloud.ClientVersion = CommunityVersion

local MAX_SAVE_BYTES = 2 * 1024 * 1024
local MAX_SAVE_TABLE_DEPTH = 64
local MAX_SAVE_TABLE_NODES = 250000

-------------------------------------------------------------------------------
-- Validation Helpers
-------------------------------------------------------------------------------

local function ValidCloudId(value)
	value = tostring(value or "")
	return value == "" or (string.len(value) == 27 and string.find(value, "^cs_[0-9a-f]+$") ~= nil)
end

local function ValidSyncKey(value)
	value = tostring(value or "")
	return string.len(value) >= 9 and string.len(value) <= 80 and string.find(value, "^ck_[A-Za-z0-9_-]+$") ~= nil
end

local function PositiveInteger(value)
	return type(value) == "number" and value >= 1 and value == Floor(value)
end

local function AuthFailure(response)
	local unauthorized, message = CommunityAccount.HandleUnauthorized(response)
	if unauthorized then
		return message
	end
	return nil
end

local function Metadata()
	local snapshot = nil
	if HighScoreModel and HighScoreModel.BuildSnapshot then
		snapshot = HighScoreModel:BuildSnapshot(Player)
	end
	snapshot = snapshot or {}
	local displayName = tostring(Player.name or GetCurrentUserName() or "Cloud Game")
	-- Story and Free Play are separate campaigns under one local profile.
	-- The current server schema has no explicit mode field, so make the Free Play
	-- cloud row visibly distinct without changing the player's actual save name.
	if Player.IsFreePlay and Player:IsFreePlay() then
		local modeName = HasString and HasString("free_mode") and GetString("free_mode") or "Free Play"
		displayName = displayName .. " - " .. modeName
	end
	return {
		display_name = displayName,
		rank = tonumber(Player.rank) or tonumber(snapshot.rank) or 1,
		difficulty = tonumber(Player.difficulty) or tonumber(snapshot.difficulty) or 1,
		week = tonumber(snapshot.week) or 1,
		company_score = tonumber(snapshot.companyScore) or 0,
		money = tonumber(Player.money) or tonumber(snapshot.money) or 0,
	}
end

-------------------------------------------------------------------------------
-- Local Save Handling
-------------------------------------------------------------------------------

-- Omit Cloud bookkeeping while building the portable campaign save.
local function BuildPortableSave()
	if not Player or not Player.BuildSaveGameString then
		return nil, "No active game is available to sync."
	end
	local savedId = Player.communityCloudSaveId
	local savedRevision = Player.communityCloudRevision
	local savedLastSync = Player.communityCloudLastSync
	local savedAccount = Player.communityCloudAccountId
	local savedPendingKey = Player.communityCloudPendingSyncKey
	local savedPendingAccount = Player.communityCloudPendingSyncAccountId
	local savedPendingByAccount = Player.communityCloudPendingSyncByAccount
	local savedOriginCounter = Player.communityCloudOriginCounter
	local savedFreePlayProfileId = Player.freePlayProfileId
	Player.communityCloudSaveId = nil
	Player.communityCloudRevision = nil
	Player.communityCloudLastSync = nil
	Player.communityCloudAccountId = nil
	Player.communityCloudPendingSyncKey = nil
	Player.communityCloudPendingSyncAccountId = nil
	Player.communityCloudPendingSyncByAccount = nil
	Player.communityCloudOriginCounter = nil
	-- The Free Play sidecar token is local filesystem bookkeeping, not portable
	-- campaign identity. A restored Cloud Save binds to the destination profile.
	Player.freePlayProfileId = nil
	local ok, value = pcall(function() return Player:BuildSaveGameString() end)
	Player.communityCloudSaveId = savedId
	Player.communityCloudRevision = savedRevision
	Player.communityCloudLastSync = savedLastSync
	Player.communityCloudAccountId = savedAccount
	Player.communityCloudPendingSyncKey = savedPendingKey
	Player.communityCloudPendingSyncAccountId = savedPendingAccount
	Player.communityCloudPendingSyncByAccount = savedPendingByAccount
	Player.communityCloudOriginCounter = savedOriginCounter
	Player.freePlayProfileId = savedFreePlayProfileId
	if not ok or type(value) ~= "string" or value == "" then
		return nil, "The current game could not be serialized for Cloud Saves."
	end
	if string.len(value) > MAX_SAVE_BYTES then
		return nil, "This save is too large for Community Cloud Saves (2 MiB maximum)."
	end
	return value, nil
end

local function PendingByAccount()
	if not Player then
		return {}
	end
	local pending = Player.communityCloudPendingSyncByAccount
	if type(pending) ~= "table" then
		pending = {}
		local legacyKey = tostring(Player.communityCloudPendingSyncKey or "")
		local legacyAccount = tostring(Player.communityCloudPendingSyncAccountId or "")
		if ValidSyncKey(legacyKey) and legacyAccount ~= "" then
			pending[legacyAccount] = { key = legacyKey, fingerprint = "" }
		end
		Player.communityCloudPendingSyncByAccount = pending
		Player.communityCloudPendingSyncKey = ""
		Player.communityCloudPendingSyncAccountId = ""
	end
	return pending
end

local function GetPendingOperation(accountId)
	local value = PendingByAccount()[tostring(accountId or "")]
	if type(value) ~= "table" then
		return nil
	end
	local key = tostring(value.key or "")
	local fingerprint = tostring(value.fingerprint or "")
	if not ValidSyncKey(key) then
		return nil
	end
	return { key = key, fingerprint = fingerprint }
end

local function ClearPendingSyncKey(accountId)
	if not Player then
		return
	end
	accountId = tostring(accountId or CommunityAccount.GetAccountId() or "")
	local pending = PendingByAccount()
	pending[accountId] = nil
	Player.communityCloudPendingSyncKey = ""
	Player.communityCloudPendingSyncAccountId = ""
end

local function FingerprintText(text)
	local hash = 5381
	for i = 1, string.len(text or "") do
		hash = Mod((hash * 131) + string.byte(text, i), 2147483647)
	end
	return string.format("%08x", hash)
end

local function OperationFingerprint(accountId, link, saveData, metadata)
	local ok, metaJson = pcall(CommunityJSON.Encode, metadata or {})
	if not ok then
		return nil, "Could not encode Cloud Save metadata."
	end
	local source = table.concat({
		tostring(accountId or ""), "\n",
		tostring(link and link.id or ""), "\n",
		tostring(link and link.revision or 0), "\n",
		tostring(saveData or ""), "\n",
		metaJson,
	})
	return FingerprintText(source), nil
end

local function EnsurePendingSyncKey(fingerprint)
	if not Player then
		return nil, "No active game is available to sync."
	end
	local accountId = CommunityAccount.GetAccountId()
	local existing = GetPendingOperation(accountId)
	if existing and existing.fingerprint == tostring(fingerprint or "") then
		return existing.key, nil
	end
	local counter = Floor(tonumber(Player.communityCloudOriginCounter) or 0) + 1
	local stamp = counter
	if CurrentTime then
		local ok, value = pcall(function() return CurrentTime() end)
		if ok then
			stamp = Floor((tonumber(value) or 0) * 1000)
		end
	end
	local accountTail = string.sub(accountId, -8)
	local key = "ck_" .. accountTail .. "_" .. tostring(counter) .. "_" .. tostring(stamp) .. "_" .. tostring(fingerprint or "00000000")
	if not ValidSyncKey(key) then
		return nil, "Could not create a Cloud Save retry key."
	end
	Player.communityCloudOriginCounter = counter
	PendingByAccount()[accountId] = { key = key, fingerprint = tostring(fingerprint or "") }
	Player:SaveGame()
	return key, nil
end

local function NormalizeCloudLink(cloud)
	if type(cloud) ~= "table" then
		return nil
	end
	if type(cloud.id) ~= "string" or type(cloud.game_id) ~= "string" then
		return nil
	end
	local id = cloud.id
	local revision = cloud.current_revision ~= nil and cloud.current_revision or cloud.revision
	local gameId = cloud.game_id
	if cloud.client_sync_key ~= nil and type(cloud.client_sync_key) ~= "string" then
		return nil
	end
	local syncKey = cloud.client_sync_key or ""
	if not ValidCloudId(id) or id == "" or gameId ~= "c3_dbd" then
		return nil
	end
	if not PositiveInteger(revision) then
		return nil
	end
	if syncKey ~= "" and not ValidSyncKey(syncKey) then
		return nil
	end
	return {
		id = id,
		current_revision = revision,
		updated_at_utc = tostring(cloud.updated_at_utc or ""),
		client_sync_key = syncKey,
	}
end

local function LinkCurrent(cloud)
	local link = NormalizeCloudLink(cloud)
	if not link then
		return false, "Community server returned an invalid Cloud Save link."
	end
	Player.communityCloudSaveId = link.id
	Player.communityCloudRevision = link.current_revision
	Player.communityCloudLastSync = link.updated_at_utc
	Player.communityCloudAccountId = CommunityAccount.GetAccountId()
	ClearPendingSyncKey(CommunityAccount.GetAccountId())
	Player:SaveGame()
	return true, nil
end

local function ExistingLocalLink()
	local saveId = tostring(Player and Player.communityCloudSaveId or "")
	local revision = tonumber(Player and Player.communityCloudRevision) or 0
	local accountId = tostring(Player and Player.communityCloudAccountId or "")
	if not ValidCloudId(saveId) then
		return nil, "invalid"
	end
	if saveId ~= "" and (revision < 1 or revision ~= Floor(revision)) then
		return nil, "invalid"
	end
	return { id = saveId, revision = revision, account_id = accountId }, nil
end

local function IsLocalNameInUse(name)
	local wanted = string.lower(tostring(name or ""))
	for i = 0, GetNumUsers() - 1 do
		if string.lower(tostring(GetUserName(i) or "")) == wanted then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------------
-- Save Data Validation
-------------------------------------------------------------------------------

-- Cloud saves may contain only the data grammar emitted by BuildSaveGameString.
local function SafeSaveSource(source)
	if type(source) ~= "string" or source == "" or string.len(source) > MAX_SAVE_BYTES then
		return false
	end
	if not string.find(source, "^%s*return%s*{") then
		return false
	end
	local dangerous =
	{
		["function"] = true, ["while"] = true, ["repeat"] = true, ["until"] = true, ["do"] = true, ["end"] = true,
		["for"] = true, ["if"] = true, ["then"] = true, ["else"] = true, ["elseif"] = true, ["local"] = true,
		["and"] = true, ["or"] = true, ["not"] = true, ["break"] = true, ["in"] = true,
	}
	local inString = false
	local escaped = false
	local word = ""
	local sawReturn = false
	local function FinishWord()
		if word == "" then
			return true
		end
		if word == "return" then
			if sawReturn then
				return false
			end
			sawReturn = true
		elseif dangerous[word] then
			return false
		end
		word = ""
		return true
	end
	local i = 1
	while i <= string.len(source) do
		local ch = string.sub(source, i, i)
		if inString then
			if escaped then escaped = false
			elseif ch == "\\" then escaped = true
			elseif ch == '"' then inString = false end
		else
			if ch == '"' then
				if not FinishWord() then
					return false
				end
				inString = true
			elseif string.find(ch, "[A-Za-z_]") then
				word = word .. ch
			elseif string.find(ch, "[0-9]") and word ~= "" then
				word = word .. ch
			else
				if not FinishWord() then
					return false
				end
				if not string.find(ch, "[%s%d{}=,%+%-%.]") then
					return false
				end
			end
		end
		i = i + 1
	end
	if inString or not FinishWord() or not sawReturn then
		return false
	end
	return true
end

local function IsFiniteNumber(value)
	if type(value) ~= "number" or value ~= value then
		return false
	end
	local zero = value - value
	return zero == zero
end

local function ValidateSaveTable(root)
	local seen = {}
	local count = 0
	local function Walk(value, depth)
		local kind = type(value)
		if kind == "string" or kind == "boolean" then
			return true
		end
		if kind == "number" then
			if not IsFiniteNumber(value) then
				return false
			end
			return true
		end
		if kind ~= "table" or depth > MAX_SAVE_TABLE_DEPTH or seen[value] then
			return false
		end
		seen[value] = true
		for key, child in pairs(value) do
			count = count + 1
			if count > MAX_SAVE_TABLE_NODES then
				return false
			end
			local keyType = type(key)
			if keyType ~= "string" and keyType ~= "number" then
				return false
			end
			if not Walk(child, depth + 1) then
				return false
			end
		end
		seen[value] = nil
		return true
	end
	return Walk(root, 1)
end

local function DecodeSave(source)
	if not SafeSaveSource(source) then
		return nil, "Downloaded Cloud Save contains unsupported or unsafe data."
	end
	local loader = loadstring(source)
	if type(loader) ~= "function" then
		return nil, "Downloaded Cloud Save is not a valid Reforged save."
	end
	if setfenv then
		setfenv(loader, {})
	end
	local ok, saveTable = pcall(loader)
	if not ok or type(saveTable) ~= "table" then
		return nil, "Downloaded Cloud Save could not be decoded."
	end
	if not ValidateSaveTable(saveTable) then
		return nil, "Downloaded Cloud Save contains invalid data types or structure."
	end
	return saveTable, nil
end

local function NormalizeCloudSummary(value)
	if type(value) ~= "table" then
		return nil
	end
	local link = NormalizeCloudLink(value)
	if not link then
		return nil
	end
	if type(value.metadata) ~= "table" then
		return nil
	end
	return {
		id = link.id,
		game_id = "c3_dbd",
		current_revision = link.current_revision,
		display_name = tostring(value.display_name or ""),
		metadata = value.metadata,
		client_sync_key = link.client_sync_key,
		created_at_utc = tostring(value.created_at_utc or ""),
		updated_at_utc = tostring(value.updated_at_utc or ""),
	}
end

-------------------------------------------------------------------------------
-- Cloud Save Requests
-------------------------------------------------------------------------------

function CommunityCloud.List(callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to use Cloud Saves.")
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/cloud-saves", function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		if not response or response.status ~= 200 or type(body) ~= "table" or type(body.items) ~= "table" then
			callback(nil, response, body and body.error or "Could not list Cloud Saves.")
			return
		end
		local items = {}
		for _, raw in ipairs(body.items) do
			local item = NormalizeCloudSummary(raw)
			if not item then
				callback(nil, response, "Cloud Save list contained malformed data.")
				return
			end
			table.insert(items, item)
		end
		callback(items, response, nil)
	end, CommunityAccount.GetSessionToken())
end

local function FindBySyncKey(items, key)
	for _, item in ipairs(items or {}) do
		if tostring(item.client_sync_key or "") == tostring(key or "") then
			return item
		end
	end
	return nil
end

-- Resolve an unfinished create before starting another one for this account.
local function ReconcilePendingCreate(accountId, currentFingerprint, callback)
	local pending = GetPendingOperation(accountId)
	if not pending then
		return false
	end
	if pending.fingerprint ~= "" and pending.fingerprint == tostring(currentFingerprint or "") then
		return false  -- exact retry: reuse the key without an extra list request
	end
	CommunityCloud.List(function(items, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local remote = FindBySyncKey(items, pending.key)
		if remote then
			local linked, linkError = LinkCurrent(remote)
			if not linked then
				callback(nil, response, linkError)
				return
			end
			callback({ reconciled = true, cloud = remote }, response, nil)
			return
		end
		ClearPendingSyncKey(accountId)
		Player:SaveGame()
		callback({ reconciled = false }, response, nil)
	end)
	return true
end

local function SendCreate(saveData, metadata, fingerprint, callback)
	local syncKey, keyError = EnsurePendingSyncKey(fingerprint)
	if not syncKey then
		callback(nil, nil, keyError)
		return false
	end
	local payload =
	{
		cloud_save_id = "",
		base_revision = 0,
		save_data = saveData,
		metadata = metadata,
		client_version = CommunityCloud.ClientVersion,
		client_sync_key = syncKey,
	}
	return CommunityTransport.PostJSON("/api/v1/cloud-saves/sync", payload, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		if response and response.status == 400 and type(body) == "table"
		   and string.find(string.lower(tostring(body.error or "")), "idempotency key", 1, true) then
			ClearPendingSyncKey(CommunityAccount.GetAccountId())
			Player:SaveGame()
		end
		if not response or response.status ~= 200 or type(body) ~= "table" or type(body.cloud) ~= "table" then
			callback(nil, response, body and body.error or "Could not create Community Cloud Save.")
			return
		end
		local linked, linkError = LinkCurrent(body.cloud)
		if not linked then
			callback(nil, response, linkError)
			return
		end
		callback({ cloud = body.cloud, unchanged = body.unchanged and true or false, replayed = body.replayed and true or false }, response, nil)
	end, CommunityAccount.GetSessionToken())
end

function CommunityCloud.SyncCurrent(callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to use Cloud Saves.")
		return false
	end
	if not Player or not Player.BuildSaveGameString then
		callback(nil, nil, "No active game is available to sync.")
		return false
	end
	local link, linkError = ExistingLocalLink()
	if linkError then
		callback({ invalid_link = true }, nil, nil)
		return false
	end
	local saveData, saveError = BuildPortableSave()
	if not saveData then
		callback(nil, nil, saveError)
		return false
	end
	local metadata = Metadata()
	local currentAccount = CommunityAccount.GetAccountId()
	local fingerprint, fingerprintError = OperationFingerprint(currentAccount, link, saveData, metadata)
	if not fingerprint then
		callback(nil, nil, fingerprintError)
		return false
	end

	local pending = GetPendingOperation(currentAccount)
	if pending and (link.id == "" or (link.account_id ~= "" and link.account_id ~= currentAccount)) then
		local started = ReconcilePendingCreate(currentAccount, fingerprint, function(result, response, err)
			if err then
				callback(nil, response, err)
				return
			end
			if result and result.reconciled then
				CommunityCloud.SyncCurrent(callback)
				return
			end
			if link.id ~= "" and link.account_id ~= "" and link.account_id ~= currentAccount then
				callback({ account_mismatch = true, linked_account_id = link.account_id }, response, nil)
				return
			end
			SendCreate(saveData, metadata, fingerprint, callback)
		end)
		if started then
			return true
		end
	end

	if link.id ~= "" and link.account_id ~= "" and link.account_id ~= currentAccount then
		callback({ account_mismatch = true, linked_account_id = link.account_id }, nil, nil)
		return false
	end
	if link.id == "" then
		return SendCreate(saveData, metadata, fingerprint, callback)
	end
	local payload =
	{
		cloud_save_id = link.id,
		base_revision = link.revision,
		save_data = saveData,
		metadata = metadata,
		client_version = CommunityCloud.ClientVersion,
		client_sync_key = "",
	}
	return CommunityTransport.PostJSON("/api/v1/cloud-saves/sync", payload, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		if response and response.status == 409 and type(body) == "table" and body.conflict then
			local conflictCloud = NormalizeCloudSummary(body.cloud)
			if not conflictCloud then
				callback(nil, response, "Cloud conflict response contained malformed remote state.")
				return
			end
			callback({ conflict = true, cloud = conflictCloud }, response, nil)
			return
		end
		if response and response.status == 403 then
			callback({ account_mismatch = true }, response, nil)
			return
		end
		if response and response.status == 404 then
			callback({ missing = true }, response, nil)
			return
		end
		if not response or response.status ~= 200 or type(body) ~= "table" or type(body.cloud) ~= "table" then
			callback(nil, response, body and body.error or "Cloud sync failed.")
			return
		end
		local linked, linkError = LinkCurrent(body.cloud)
		if not linked then
			callback(nil, response, linkError)
			return
		end
		callback({ conflict = false, cloud = body.cloud, unchanged = body.unchanged and true or false, replayed = body.replayed and true or false }, response, nil)
	end, CommunityAccount.GetSessionToken())
end

function CommunityCloud.SyncCurrentAsNew(callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to use Cloud Saves.")
		return false
	end
	local saveData, saveError = BuildPortableSave()
	if not saveData then
		callback(nil, nil, saveError)
		return false
	end
	local metadata = Metadata()
	local accountId = CommunityAccount.GetAccountId()
	local createLink = { id = "", revision = 0, account_id = accountId }
	local fingerprint, fingerprintError = OperationFingerprint(accountId, createLink, saveData, metadata)
	if not fingerprint then
		callback(nil, nil, fingerprintError)
		return false
	end
	if GetPendingOperation(accountId) then
		local started = ReconcilePendingCreate(accountId, fingerprint, function(result, response, err)
			if err then
				callback(nil, response, err)
				return
			end
			if result and result.reconciled then
				CommunityCloud.SyncCurrent(callback)
				return
			end
			SendCreate(saveData, metadata, fingerprint, callback)
		end)
		if started then
			return true
		end
	end
	return SendCreate(saveData, metadata, fingerprint, callback)
end

local function ValidateDownloadEnvelope(body, requestedId)
	if type(body) ~= "table" or type(body.save_data) ~= "string" then
		return nil, "Cloud Save download response is malformed."
	end
	if type(body.id) ~= "string" or type(body.game_id) ~= "string" then
		return nil, "Cloud Save download response is malformed."
	end
	local responseId = body.id
	local revision = body.revision ~= nil and body.revision or body.current_revision
	if responseId ~= tostring(requestedId or "") or not ValidCloudId(responseId) or responseId == "" then
		return nil, "Cloud Save download returned a mismatched save ID."
	end
	if body.game_id ~= "c3_dbd" then
		return nil, "Cloud Save belongs to an unsupported game."
	end
	if not PositiveInteger(revision) then
		return nil, "Cloud Save download returned an invalid revision."
	end
	if body.save_data == "" or string.len(body.save_data) > MAX_SAVE_BYTES then
		return nil, "Downloaded Cloud Save is empty or exceeds the 2 MiB limit."
	end
	body.revision = revision
	return body, nil
end

local function CaptureCurrentForRollback()
	if not Player or not Player.BuildSaveGameString then
		return nil, "No active local game is available for rollback."
	end
	if Player.SaveGame then
		local ok, err = pcall(function() Player:SaveGame() end)
		if not ok then
			return nil, "The current local game could not be saved before Cloud restore. " .. tostring(err or "")
		end
	end
	local ok, source = pcall(function() return Player:BuildSaveGameString() end)
	if not ok or type(source) ~= "string" or source == "" then
		return nil, "The current local game could not be captured for rollback."
	end
	return {
		save_data = source,
		mode = (Player.IsFreePlay and Player:IsFreePlay()) and "free" or "story",
		free_play_profile_id = tostring(Player.freePlayProfileId or ""),
	}, nil
end

local function RestoreLocalSave(capture)
	if type(capture) ~= "table" or type(capture.save_data) ~= "string" or capture.save_data == "" then
		return false
	end
	local saveTable = DecodeSave(capture.save_data)
	if not saveTable then return false end
	local ok = pcall(function()
		saveTable.freePlayProfileId = tostring(capture.free_play_profile_id or "")
		Player:Reset(saveTable)
		Player:SetGameMode(capture.mode == "free" and "free" or "story")
		local name = GetCurrentUserName and GetCurrentUserName() or nil
		if name then
			Player.name = name
			Player.stringTable.player = name
		end
		Player:SaveGame()
		UpdateLedger("newplayer")
	end)
	return ok
end

-------------------------------------------------------------------------------
-- Restore and Import
-------------------------------------------------------------------------------

function CommunityCloud.Download(saveId, callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to use Cloud Saves.")
		return false
	end
	saveId = tostring(saveId or "")
	if not ValidCloudId(saveId) or saveId == "" then
		callback(nil, nil, "Cloud Save ID is invalid.")
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/cloud-saves/" .. saveId, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not download Cloud Save.")
			return
		end
		local validated, envelopeError = ValidateDownloadEnvelope(body, saveId)
		if not validated then
			callback(nil, response, envelopeError)
			return
		end
		callback(validated, response, nil)
	end, CommunityAccount.GetSessionToken())
end

function CommunityCloud.RestoreIntoCurrent(saveId, callback)
	return CommunityCloud.Download(saveId, function(body, response, err)
		if err then
			callback(false, response, err)
			return
		end
		local saveTable, decodeError = DecodeSave(body.save_data)
		if not saveTable then
			callback(false, response, decodeError)
			return
		end
		local oldSave, captureError = CaptureCurrentForRollback()
		if not oldSave then
			callback(false, response, captureError)
			return
		end
		local localName = Player and Player.name or GetCurrentUserName()
		local localFreePlayProfileId = tostring((Player and Player.freePlayProfileId) or "")
		if localFreePlayProfileId == "" and Player and Player.EnsureFreePlayProfileId then
			localFreePlayProfileId = Player:EnsureFreePlayProfileId()
		end
		local incomingMode = (saveTable.mode == "free") and "free" or "story"
		local okApply, applyError = pcall(function()
			saveTable.name = localName or saveTable.name
			saveTable.freePlayProfileId = localFreePlayProfileId
			Player:Reset(saveTable)
			Player:SetGameMode(incomingMode)
			Player.communityCloudSaveId = tostring(body.id or saveId or "")
			Player.communityCloudRevision = tonumber(body.revision) or 0
			Player.communityCloudLastSync = tostring(body.updated_at_utc or "")
			Player.communityCloudAccountId = CommunityAccount.GetAccountId()
			ClearPendingSyncKey(CommunityAccount.GetAccountId())
			Player:SaveGame()
			-- Free Play cloud payloads are synchronized against the destination
			-- profile's current Story unlocks after being bound to its sidecar.
			if incomingMode == "free" then
				Player:LoadGame("free")
			end
			UpdateLedger("newplayer")
		end)
		if not okApply then
			RestoreLocalSave(oldSave)
			callback(false, response, "Could not restore the Cloud Save; the previous local game was restored. " .. tostring(applyError or ""))
			return
		end
		callback(true, response, nil)
	end)
end

function CommunityCloud.ImportAsNewLocal(saveId, newName, callback)
	if not CommunityAccount.IsSignedIn() then
		callback(false, nil, "Sign in to use Cloud Saves.")
		return false
	end
	if GetNumUsers() >= 10 then
		callback(false, nil, "All 10 local player slots are already in use.")
		return false
	end
	newName = string.gsub(tostring(newName or ""), "^%s*(.-)%s*$", "%1")
	if newName == "" or string.len(newName) > 20 then
		callback(false, nil, "Choose a local player name between 1 and 20 characters.")
		return false
	end
	if IsLocalNameInUse(newName) then
		callback(false, nil, "A local player with that name already exists. Choose another name.")
		return false
	end

	return CommunityCloud.Download(saveId, function(body, response, err)
		if err then
			callback(false, response, err)
			return
		end
		local saveTable, decodeError = DecodeSave(body.save_data)
		if not saveTable then
			callback(false, response, decodeError)
			return
		end
		-- Free Play is deliberately the second save belonging to a Story profile.
		-- Importing it as an entirely new local player would create an orphaned
		-- Free Play campaign with no Story progression authority. Restore it into an existing
		-- profile instead; Story cloud saves can still create new local profiles.
		if saveTable.mode == "free" then
			callback(false, response, "Free Play Cloud Saves belong to an existing Story profile. Select that local player and restore this save into the current profile instead.")
			return
		end
		local oldUser = GetNumUsers() > 0 and GetCurrentUser() or nil
		local oldSave, captureError = CaptureCurrentForRollback()
		if not oldSave then
			callback(false, response, captureError)
			return
		end
		local created = false
		local okApply, applyError = pcall(function()
			CreateNewUser(newName)
			created = tostring(GetCurrentUserName() or "") == newName
			if not created then
				error("the engine did not activate the new player slot")
			end
			saveTable.name = newName
			-- A newly-created local profile receives its own sidecar token.
			saveTable.freePlayProfileId = ""
			Player:Reset(saveTable)
			Player.name = newName
			if Player.stringTable then
				Player.stringTable.player = newName
			end
			Player.communityCloudSaveId = tostring(body.id or saveId or "")
			Player.communityCloudRevision = tonumber(body.revision) or 0
			Player.communityCloudLastSync = tostring(body.updated_at_utc or "")
			Player.communityCloudAccountId = CommunityAccount.GetAccountId()
			ClearPendingSyncKey(CommunityAccount.GetAccountId())
			Player:SaveGame()
			UpdateLedger("newplayer")
		end)
		if not okApply then
			pcall(function()
				if created and GetNumUsers() > 0 and tostring(GetCurrentUserName() or "") == newName then
					DeleteUser(GetCurrentUser())
				end
				if oldUser ~= nil and oldUser < GetNumUsers() then
					SetCurrentUser(oldUser)
				end
				RestoreLocalSave(oldSave)
			end)
			callback(false, response, "Could not import the Cloud Save as a new local player. The previous player was restored. " .. tostring(applyError or ""))
			return
		end
		callback(true, response, nil)
	end)
end

-------------------------------------------------------------------------------
-- Delete Requests
-------------------------------------------------------------------------------

function CommunityCloud.Delete(saveId, callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to use Cloud Saves.")
		return false
	end
	saveId = tostring(saveId or "")
	if not ValidCloudId(saveId) or saveId == "" then
		callback(nil, nil, "Cloud Save ID is invalid.")
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/cloud-saves/" .. saveId .. "/delete", {}, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		-- A stale row may already be gone on another computer.
		-- HTTP 404 therefore has the same result as a successful delete.
		local alreadyDeleted = response and response.status == 404
		if not alreadyDeleted and (not response or response.status ~= 200) then
			callback(nil, response, body and body.error or "Could not delete Cloud Save.")
			return
		end
		if Player and tostring(Player.communityCloudSaveId or "") == saveId then
			Player.communityCloudSaveId = ""
			Player.communityCloudRevision = 0
			Player.communityCloudLastSync = ""
			Player.communityCloudAccountId = ""
			ClearPendingSyncKey(CommunityAccount.GetAccountId())
			Player:SaveGame()
		end
		if alreadyDeleted then
			callback({ status = "ok", deleted = true, already_deleted = true, cloud_save_id = saveId }, response, nil)
		else
			callback(body, response, nil)
		end
	end, CommunityAccount.GetSessionToken())
end
