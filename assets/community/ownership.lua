--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Community Creation ownership token store

	Public creator names are presentation only and are not authentication.
	Each successful upload receives a server-generated 256-bit owner token.
	Only its SHA-256 hash is stored server-side; this local file keeps the
	plaintext token in Playground's private user: directory so the uploader can
	later delete that creation from the Community Cookbook.
-----------------------------------------------------------------------------]]

require("community/json.lua")

CommunityOwnership = CommunityOwnership or {}

local STORE_FILE = "community_creation_ownership.json"
local loaded = false
local tokens = {}

local function ValidCreationId(value)
	return type(value) == "string"
		and string.len(value) == 27
		and string.find(value, "^cr_[0-9a-f]+$") ~= nil
end

local function ValidOwnerToken(value)
	return type(value) == "string"
		and string.len(value) == 64
		and string.find(value, "^[0-9a-f]+$") ~= nil
end

local function LoadStore()
	if loaded then return end
	loaded = true
	tokens = {}

	local raw = ReadFromFile(STORE_FILE)
	if not raw or raw == "" then return end

	local ok, decoded = pcall(CommunityJSON.Decode, raw)
	if not ok or type(decoded) ~= "table" or type(decoded.items) ~= "table" then
		DebugOut("COMMUNITY", "Ignoring malformed Community ownership token store.")
		return
	end

	for creationId, token in pairs(decoded.items) do
		if ValidCreationId(creationId) and ValidOwnerToken(token) then
			tokens[creationId] = token
		end
	end
end

local function SaveStore()
	LoadStore()
	local payload = {
		version = 1,
		items = tokens,
	}
	local ok, encoded = pcall(CommunityJSON.Encode, payload)
	if not ok then
		DebugOut("COMMUNITY", "Could not encode Community ownership token store: " .. tostring(encoded))
		return false
	end
	WriteToFile(STORE_FILE, encoded)
	return true
end

function CommunityOwnership.Get(creationId)
	LoadStore()
	if not ValidCreationId(creationId) then return nil end
	return tokens[creationId]
end

function CommunityOwnership.Has(creationId)
	return CommunityOwnership.Get(creationId) ~= nil
end

function CommunityOwnership.Remember(creationId, token)
	LoadStore()
	if not ValidCreationId(creationId) or not ValidOwnerToken(token) then return false end
	tokens[creationId] = token
	return SaveStore()
end

function CommunityOwnership.Forget(creationId)
	LoadStore()
	if not ValidCreationId(creationId) then return false end
	tokens[creationId] = nil
	return SaveStore()
end
