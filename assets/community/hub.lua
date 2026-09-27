--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Hub)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/version.lua")
require("community/transport.lua")
require("community/account.lua")

-------------------------------------------------------------------------------
-- Hub State
-------------------------------------------------------------------------------

CommunityHub = CommunityHub or {}
CommunityHub.ClientVersion = CommunityVersion
CommunityHub.LastSummary = CommunityHub.LastSummary or nil

-------------------------------------------------------------------------------
-- Response Validation
-------------------------------------------------------------------------------

local function IntegerAtLeast(value, minimum)
	return type(value) == "number" and value == Floor(value) and value >= minimum
end

local function OptionalString(value)
	return value == nil or type(value) == "string"
end

local function NormalizeTopScore(value)
	if value == nil then
		return nil, nil
	end
	if type(value) ~= "table" then
		return nil, "Community summary contains an invalid top score."
	end
	if type(value.public_name) ~= "string" or value.public_name == "" or string.len(value.public_name) > 20 then
		return nil, "Community summary contains invalid leaderboard identity metadata."
	end
	if not OptionalString(value.nationality) or not IntegerAtLeast(value.score, 0)
	   or not IntegerAtLeast(value.difficulty, 1) or value.difficulty > 3
	   or not IntegerAtLeast(value.week, 0) then
		return nil, "Community summary contains invalid leaderboard score metadata."
	end
	return {
		public_name = value.public_name,
		nationality = value.nationality or "",
		score = value.score,
		difficulty = value.difficulty,
		week = value.week,
	}, nil
end

local function NormalizeFeaturedCreation(value)
	if value == nil then
		return nil, nil
	end
	if type(value) ~= "table" then
		return nil, "Community summary contains an invalid featured creation."
	end
	if type(value.id) ~= "string" or string.find(value.id, "^cr_[0-9a-f]+$") == nil
	   or string.len(value.id) ~= 27
	   or type(value.name) ~= "string" or value.name == ""
	   or type(value.author) ~= "string" or value.author == ""
	   or not OptionalString(value.nationality)
	   or type(value.category) ~= "string" or value.category == ""
	   or not IntegerAtLeast(value.load_count, 0) then
		return nil, "Community summary contains invalid featured creation metadata."
	end
	return {
		id = value.id,
		name = value.name,
		author = value.author,
		nationality = value.nationality or "",
		category = value.category,
		load_count = value.load_count,
	}, nil
end

function CommunityHub.NormalizeSummary(value)
	if type(value) ~= "table" or value.status ~= "ok" then
		return nil, "Community summary response is malformed."
	end
	local integerFields =
	{
		"players_online", "presence_window_seconds", "accounts", "community_scores",
		"account_owned_scores", "community_creations", "creation_loads", "cloud_saves",
	}
	for _, key in ipairs(integerFields) do
		if not IntegerAtLeast(value[key], 0) then
			return nil, "Community summary contains invalid " .. key .. " metadata."
		end
	end
	if type(value.service) ~= "string" or type(value.version) ~= "string" or type(value.environment) ~= "string" then
		return nil, "Community summary contains invalid service metadata."
	end
	local topScore, topError = NormalizeTopScore(value.top_score)
	if topError then
		return nil, topError
	end
	local featured, creationError = NormalizeFeaturedCreation(value.featured_creation)
	if creationError then
		return nil, creationError
	end

	return {
		status = "ok",
		service = value.service,
		version = value.version,
		environment = value.environment,
		players_online = value.players_online,
		presence_window_seconds = value.presence_window_seconds,
		accounts = value.accounts,
		community_scores = value.community_scores,
		account_owned_scores = value.account_owned_scores,
		community_creations = value.community_creations,
		creation_loads = value.creation_loads,
		cloud_saves = value.cloud_saves,
		top_score = topScore,
		featured_creation = featured,
	}, nil
end

-------------------------------------------------------------------------------
-- Community Requests
-------------------------------------------------------------------------------

function CommunityHub.GetSummary(callback)
	return CommunityTransport.GetJSON("/api/v1/community/summary", function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Community summary request failed.")
			return
		end
		local summary, normalizeError = CommunityHub.NormalizeSummary(body)
		if not summary then
			callback(nil, response, normalizeError)
			return
		end
		CommunityHub.LastSummary = summary
		callback(summary, response, nil)
	end)
end

function CommunityHub.OpenExternal(target, callback)
	return CommunityTransport.OpenExternal(target, callback)
end
