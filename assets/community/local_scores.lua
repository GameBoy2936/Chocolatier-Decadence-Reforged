--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Local High Score lifecycle/repair helpers.

	Playground stores its local High Score table in user:hiscore.dat, separately
	from Chocolatier's save-slot roster.  The SDK's production skeleton requires
	TSettings::DeleteUser() to call TPfHiscores::ClearPlayerData(), but that
	operation is not exported to this game's Lua environment directly.

	Reforged therefore uses a short-lived "shadow" profile when it needs to
	invoke that native cleanup for a detached player name.  Creating a profile
	under the stale name and immediately deleting it routes through the game's
	real DeleteUser() path, allowing Playground itself to update/checksum its
	private hiscore.dat instead of Reforged editing that binary file.
---------------------------------------------------------------------------]]

CommunityLocalScores = CommunityLocalScores or {}

local kMaxProfiles = 10
local kScratchBase = "RFRepair"

local function CleanName(value)
	if value == nil then return "" end
	return tostring(value)
end

local function NameKey(value)
	return string.lower(CleanName(value))
end

local function LogHiscore(message)
	if type(DebugOut) == "function" then
		DebugOut("HISCORE", tostring(message))
	end
end

local function PlayerCanSave()
	return Player and type(Player.SaveGame) == "function"
end

local function PlayerCanLoad()
	return Player and type(Player.LoadGame) == "function"
end

local function SafeSave()
	if not PlayerCanSave() then return true end
	local ok, err = pcall(function() Player:SaveGame() end)
	if not ok then return false, tostring(err) end
	return true
end

local function SafeLoad()
	if not PlayerCanLoad() then return true end
	local ok, err = pcall(function() Player:LoadGame() end)
	if not ok then return false, tostring(err) end
	return true
end

function CommunityLocalScores.FindProfileIndex(name)
	name = CleanName(name)
	if name == "" then return nil end
	if type(GetNumUsers) ~= "function" or type(GetUserName) ~= "function" then return nil end

	local wanted = NameKey(name)
	local count = tonumber(GetNumUsers()) or 0
	local i = 0
	while i < count do
		if NameKey(GetUserName(i)) == wanted then return i end
		i = i + 1
	end
	return nil
end

function CommunityLocalScores.ProfileNameSet()
	local result = {}
	if type(GetNumUsers) ~= "function" or type(GetUserName) ~= "function" then return result end

	local count = tonumber(GetNumUsers()) or 0
	local i = 0
	while i < count do
		local name = CleanName(GetUserName(i))
		if name ~= "" then result[NameKey(name)] = true end
		i = i + 1
	end
	return result
end

function CommunityLocalScores.IsLiveProfileName(name)
	return CommunityLocalScores.FindProfileIndex(name) ~= nil
end

local function CurrentProfileName()
	if type(GetCurrentUserName) ~= "function" then return "" end
	return CleanName(GetCurrentUserName())
end

local function RestoreProfile(name, loadPlayer)
	local index = CommunityLocalScores.FindProfileIndex(name)
	if index == nil then
		return false, "Could not restore local profile '" .. CleanName(name) .. "'."
	end

	local ok, err = pcall(SetCurrentUser, index)
	if not ok then return false, tostring(err) end

	if loadPlayer then
		local loaded, loadErr = SafeLoad()
		if not loaded then return false, loadErr end
	end
	return true
end

local function FindScratchName()
	local n = 0
	while n < 100 do
		local candidate = kScratchBase
		if n > 0 then candidate = candidate .. tostring(n) end
		if not CommunityLocalScores.IsLiveProfileName(candidate) then return candidate end
		n = n + 1
	end
	return nil
end

local function HasShadowSlot()
	if type(GetNumUsers) ~= "function" then return false end
	return (tonumber(GetNumUsers()) or kMaxProfiles) < kMaxProfiles
end

-- Invoke Playground's native per-player cleanup without attempting to parse or
-- rewrite user:hiscore.dat ourselves. "name" MUST NOT currently belong to a
-- live save slot. The profile active before the operation is restored by name.

-- saveBefore=true is used for ordinary/orphan cleanup. It is false while the
-- active profile is temporarily renamed during a current-profile rebuild,
-- because that campaign has already been saved before the temporary rename.
local function ShadowClearDetachedName(name, restoreName, saveBefore)
	name = CleanName(name)
	restoreName = CleanName(restoreName)
	if name == "" then return false, "Player name is empty." end
	if restoreName == "" then return false, "No local profile can be restored after repair." end
	if CommunityLocalScores.IsLiveProfileName(name) then
		return false, "The local profile '" .. name .. "' still exists."
	end
	if not HasShadowSlot() then
		return false, "Local score repair needs one free player slot. The ten-profile limit is currently full."
	end
	if type(CreateNewUser) ~= "function" or type(DeleteUser) ~= "function" or type(SetCurrentUser) ~= "function" then
		return false, "This game build does not expose the profile lifecycle needed for local score repair."
	end

	if saveBefore then
		local saved, saveErr = SafeSave()
		if not saved then return false, "Could not save the active profile before repair: " .. tostring(saveErr) end
	end

	local created = false
	local function Recover()
		-- If the shadow survived a partial failure, delete it before restoring
		-- the real campaign. DeleteUser is intentionally used here as well so
		-- Playground owns the hiscore.dat mutation/checksum.
		local shadowIndex = CommunityLocalScores.FindProfileIndex(name)
		if shadowIndex ~= nil then
			pcall(SetCurrentUser, shadowIndex)
			pcall(DeleteUser, shadowIndex)
		end
		local restoreIndex = CommunityLocalScores.FindProfileIndex(restoreName)
		if restoreIndex ~= nil then
			pcall(SetCurrentUser, restoreIndex)
			if PlayerCanLoad() then pcall(function() Player:LoadGame() end) end
		end
	end

	local ok, err = pcall(function()
		CreateNewUser(name)
		created = true

		local shadowIndex = CommunityLocalScores.FindProfileIndex(name)
		if shadowIndex == nil then error("Temporary repair profile was not created.") end
		SetCurrentUser(shadowIndex)

		-- Playground SDK 5.0.7.1 requires TSettings::DeleteUser() to call
		-- TPfHiscores::ClearPlayerData() for the deleted player name.
		DeleteUser(shadowIndex)

		local restored, restoreErr = RestoreProfile(restoreName, true)
		if not restored then error(restoreErr) end
	end)

	if not ok then
		if created then Recover() else RestoreProfile(restoreName, false) end
		return false, tostring(err)
	end

	LogHiscore("Cleared native local High Score/medal state for detached name '" .. name .. "'.")
	return true
end

-- Clear stale native state for a name before creating a new campaign with that
-- name. This prevents a deleted/renamed predecessor from donating its old PB.
function CommunityLocalScores.PrepareNewProfileName(name)
	name = CleanName(name)
	if name == "" then return false, "Player name is empty." end
	if CommunityLocalScores.IsLiveProfileName(name) then
		return false, "A local profile named '" .. name .. "' already exists."
	end

	local restoreName = CurrentProfileName()
	if restoreName == "" then return false, "No active local profile is available." end
	return ShadowClearDetachedName(name, restoreName, true)
end

function CommunityLocalScores.FindVisibleOrphans(visibleNames)
	local live = CommunityLocalScores.ProfileNameSet()
	local seen = {}
	local result = {}

	if type(visibleNames) ~= "table" then return result end
	for _, rawName in ipairs(visibleNames) do
		local name = CleanName(rawName)
		local key = NameKey(name)
		if name ~= "" and not live[key] and not seen[key] then
			seen[key] = true
			table.insert(result, name)
		end
	end
	return result
end

function CommunityLocalScores.ClearVisibleOrphans(visibleNames)
	local orphans = CommunityLocalScores.FindVisibleOrphans(visibleNames)
	local removed = 0
	local currentName = CurrentProfileName()
	if currentName == "" then return 0, orphans, "No active local profile is available." end

	for _, name in ipairs(orphans) do
		local ok, err = ShadowClearDetachedName(name, currentName, true)
		if not ok then return removed, orphans, err end
		removed = removed + 1
	end

	return removed, orphans
end

-- Explicitly rebuild the active profile's native Playground score identity.
-- This handles the same-name reincarnation case: e.g. an old Clara left 53,049
-- in hiscore.dat, a new Clara currently has 27,100, and KeepScore refuses to
-- replace the stale higher PB. We temporarily rename the real save slot, clear
-- "Clara" through a throwaway profile deletion, restore the real slot name,
-- then log the score from the actual current campaign.
function CommunityLocalScores.RebuildCurrentProfile(visibleNames)
	local originalName = CurrentProfileName()
	if originalName == "" then return false, nil, 0, "No active local profile is available." end
	if not Player or type(Player.LogScore) ~= "function" then
		return false, originalName, 0, "The current campaign cannot be logged."
	end
	if not HasShadowSlot() then
		return false, originalName, 0, "Local score repair needs one free player slot. The ten-profile limit is currently full."
	end

	-- First remove unambiguous orphan rows such as James when James no longer
	-- exists in the save-slot roster.
	local removed, _, orphanErr = CommunityLocalScores.ClearVisibleOrphans(visibleNames)
	if orphanErr then return false, originalName, removed, orphanErr end

	local saved, saveErr = SafeSave()
	if not saved then return false, originalName, removed, "Could not save the current campaign: " .. tostring(saveErr) end

	local scratchName = FindScratchName()
	if not scratchName then return false, originalName, removed, "Could not allocate a temporary repair profile name." end

	local renamed = false
	local function RollBackName()
		local scratchIndex = CommunityLocalScores.FindProfileIndex(scratchName)
		if scratchIndex ~= nil then
			pcall(SetCurrentUser, scratchIndex)
			pcall(function() Player:LoadGame() end)
			pcall(ChangeCurrentUserName, originalName)
			if Player then
				Player.name = originalName
				if Player.stringTable then Player.stringTable.player = originalName end
				pcall(function() Player:SaveGame() end)
			end
		end
	end

	local ok, err = pcall(function()
		ChangeCurrentUserName(scratchName)
		renamed = true

		-- originalName is detached now, so a shadow slot can safely make
		-- DeleteUser() perform Playground's native ClearPlayerData(originalName).
		local cleared, clearErr = ShadowClearDetachedName(originalName, scratchName, false)
		if not cleared then error(clearErr) end

		local restored, restoreErr = RestoreProfile(scratchName, true)
		if not restored then error(restoreErr) end

		ChangeCurrentUserName(originalName)
		renamed = false
		Player.name = originalName
		if Player.stringTable then Player.stringTable.player = originalName end

		Player:LogScore()
		if type(Player.SaveGame) == "function" then Player:SaveGame() end
	end)

	if not ok then
		if renamed then RollBackName() end
		return false, originalName, removed, tostring(err)
	end

	LogHiscore("Rebuilt native local High Score state for current profile '" .. originalName .. "'.")
	return true, originalName, removed
end

-- Rename a live profile without leaving its former name behind in the native
-- local leaderboard. The destination is cleaned first in case it belonged to a
-- previously deleted profile, then the old name is retired through DeleteUser.
function CommunityLocalScores.RenameCurrentProfile(newName)
	newName = CleanName(newName)
	local oldName = CurrentProfileName()
	if oldName == "" then return false, "No active local profile is available." end
	if newName == "" then return false, "The new player name is empty." end
	if NameKey(newName) == NameKey(oldName) then return true end
	if CommunityLocalScores.IsLiveProfileName(newName) then
		return false, "A local profile named '" .. newName .. "' already exists."
	end
	if not HasShadowSlot() then
		return false, "Safe profile rename needs one free player slot so the old local High Score identity can be retired."
	end

	-- Clean any stale predecessor at the destination while the real profile is
	-- still safely under oldName.
	local prepared, prepareErr = CommunityLocalScores.PrepareNewProfileName(newName)
	if not prepared then return false, prepareErr end

	local saved, saveErr = SafeSave()
	if not saved then return false, "Could not save the current campaign before rename: " .. tostring(saveErr) end

	local renamed = false
	local function RollBack()
		local index = CommunityLocalScores.FindProfileIndex(newName)
		if index ~= nil then
			pcall(SetCurrentUser, index)
			pcall(function() Player:LoadGame() end)
			pcall(ChangeCurrentUserName, oldName)
			if Player then
				Player.name = oldName
				if Player.stringTable then Player.stringTable.player = oldName end
				pcall(function() Player:SaveGame() end)
			end
		end
	end

	local ok, err = pcall(function()
		ChangeCurrentUserName(newName)
		renamed = true

		local cleared, clearErr = ShadowClearDetachedName(oldName, newName, false)
		if not cleared then error(clearErr) end

		local restored, restoreErr = RestoreProfile(newName, true)
		if not restored then error(restoreErr) end

		Player.name = newName
		if Player.stringTable then Player.stringTable.player = newName end
		Player:LogScore()
		if type(Player.SaveGame) == "function" then Player:SaveGame() end
		renamed = false
	end)

	if not ok then
		if renamed then RollBack() end
		return false, tostring(err)
	end

	LogHiscore("Renamed local profile '" .. oldName .. "' to '" .. newName .. "' and retired the old High Score identity.")
	return true
end
