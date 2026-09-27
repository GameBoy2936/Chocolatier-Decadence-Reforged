--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Identity)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/json.lua")
require("ui/hiscore_countries.lua")
require("community/account.lua")

CommunityIdentity = CommunityIdentity or {}

-------------------------------------------------------------------------------
-- Identity State
-------------------------------------------------------------------------------

local STORE_FILE = "community_identity.json"
local loaded = false
local profile = { public_name = "", nationality = "" }

-------------------------------------------------------------------------------
-- Identity Helpers
-------------------------------------------------------------------------------

local function Trim(value)
	value = tostring(value or "")
	local markerStart = string.find(value, "|RN1|", 1, true)
	if markerStart then
		value = string.sub(value, 1, markerStart - 1)
	end
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
end

local function ValidNationality(value)
	return value == "" or HighScoreCountries:IsValid(value)
end

local function Validate(name, nationality)
	name = Trim(name)
	nationality = tostring(nationality or "")

	if name == "" then
		return nil, nil, "Public name cannot be empty."
	end
	if string.len(name) > 20 then
		return nil, nil, "Public name is limited to 20 bytes."
	end
	if string.find(name, "|", 1, true) then
		return nil, nil, "Public name cannot contain |."
	end
	if string.find(name, "%c") then
		return nil, nil, "Public name contains an unsupported control character."
	end
	if not ValidNationality(nationality) then
		return nil, nil, "The selected Community flag is invalid."
	end

	return name, nationality, nil
end

local function SyncPlayer()
	if not Player or profile.public_name == "" then
		return
	end
	Player.highScoreDisplayName = profile.public_name
	Player.highScoreNationality = profile.nationality or ""
end

local function WriteStore()
	local ok, encoded = pcall(CommunityJSON.Encode, {
		version = 1,
		public_name = profile.public_name,
		nationality = profile.nationality,
	})
	if not ok then
		DebugOut("COMMUNITY", "Could not encode Community profile: " .. tostring(encoded))
		return false
	end
	WriteToFile(STORE_FILE, encoded)
	return true
end

local function CandidateFromPlayer()
	if not Player then
		return nil
	end

	local name = Trim(Player.highScoreDisplayName)
	local nationality = tostring(Player.highScoreNationality or "")
	if not ValidNationality(nationality) then
		nationality = ""
	end
	if name == "" then
		return nil
	end

	-- Older saves may mirror Player.name into the High Score alias.
	-- Do not treat that fallback as a configured Community identity.
	local playerName = Trim(Player.name)
	if nationality == "" and playerName ~= "" and name == playerName then
		return nil
	end

	local validName, validNationality = Validate(name, nationality)
	if not validName then
		return nil
	end
	return { public_name = validName, nationality = validNationality }
end

-------------------------------------------------------------------------------
-- Local Profile Store
-------------------------------------------------------------------------------

local function LoadStore()
	if loaded then
		return
	end
	loaded = true
	profile = { public_name = "", nationality = "" }

	local raw = ReadFromFile(STORE_FILE)
	if raw and raw ~= "" then
		local ok, decoded = pcall(CommunityJSON.Decode, raw)
		if ok and type(decoded) == "table" then
			local name, nationality = Validate(decoded.public_name, decoded.nationality or "")
			if name then
				profile.public_name = name
				profile.nationality = nationality
				SyncPlayer()
				return
			end
		end
		DebugOut("COMMUNITY", "Ignoring malformed Community profile store.")
	end

	-- Import a High Score alias only when the player had actually configured one.
	local candidate = CandidateFromPlayer()
	if candidate then
		profile = candidate
		WriteStore()
		SyncPlayer()
		DebugOut("COMMUNITY", "Migrated existing High Scores identity into the shared Community Profile.")
	end
end

local function AccountProfile()
	if CommunityAccount and CommunityAccount.IsSignedIn and CommunityAccount.IsSignedIn() then
		local accountProfile = CommunityAccount.GetProfile()
		if accountProfile and tostring(accountProfile.public_name or "") ~= "" then
			return accountProfile
		end
	end
	return nil
end

-------------------------------------------------------------------------------
-- Community Identity
-------------------------------------------------------------------------------

function CommunityIdentity.Get()
	local accountProfile = AccountProfile()
	if accountProfile then
		profile.public_name = tostring(accountProfile.public_name or "")
		profile.nationality = tostring(accountProfile.nationality or "")
		SyncPlayer()
		return { public_name = profile.public_name, nationality = profile.nationality }
	end
	LoadStore()
	SyncPlayer()
	return { public_name = profile.public_name, nationality = profile.nationality }
end

function CommunityIdentity.IsConfigured()
	local accountProfile = AccountProfile()
	if accountProfile then
		return tostring(accountProfile.public_name or "") ~= ""
	end
	LoadStore()
	return profile.public_name ~= ""
end

function CommunityIdentity.Set(name, nationality)
	local accountProfile = AccountProfile()
	if accountProfile then
		local cleanName, cleanNationality, err = Validate(name, nationality)
		if not cleanName then
			return false, err
		end
		if cleanName ~= tostring(accountProfile.public_name or "") or cleanNationality ~= tostring(accountProfile.nationality or "") then
			return false, "Change your public name or flag from Options > Community Account."
		end
		profile.public_name = cleanName
		profile.nationality = cleanNationality
		SyncPlayer()
		return true, nil
	end

	LoadStore()
	local cleanName, cleanNationality, err = Validate(name, nationality)
	if not cleanName then
		return false, err
	end
	profile.public_name = cleanName
	profile.nationality = cleanNationality
	SyncPlayer()
	if not WriteStore() then
		return false, "Could not save the Community Profile."
	end
	return true, nil
end

function CommunityIdentity.GetSuggested()
	local accountProfile = AccountProfile()
	if accountProfile then
		return { public_name = accountProfile.public_name, nationality = accountProfile.nationality or "" }
	end
	LoadStore()
	if profile.public_name ~= "" then
		return CommunityIdentity.Get()
	end
	local candidate = CandidateFromPlayer()
	if candidate then
		return candidate
	end
	return { public_name = Trim(Player and Player.name or ""), nationality = "" }
end

function CommunityIdentity.Format(profileValue)
	profileValue = profileValue or CommunityIdentity.Get()
	local text = tostring(profileValue.public_name or "")
	local nationality = tostring(profileValue.nationality or "")
	if nationality ~= "" and HighScoreCountries:IsValid(nationality) then
		text = text .. " - " .. HighScoreCountries:GetName(nationality)
	end
	return text
end

function CommunityIdentity.SyncPlayer()
	local current = CommunityIdentity.Get()
	if Player and current.public_name ~= "" then
		Player.highScoreDisplayName = current.public_name
		Player.highScoreNationality = current.nationality or ""
	end
end
