--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Scores)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/version.lua")
require("community/transport.lua")
require("community/account.lua")

-------------------------------------------------------------------------------
-- Score State
-------------------------------------------------------------------------------

CommunityScores = CommunityScores or {}
CommunityScores.ClientVersion = CommunityVersion

-------------------------------------------------------------------------------
-- Request Helpers
-------------------------------------------------------------------------------

local function SignedIn(callback)
	if CommunityAccount.IsSignedIn() then
		return true
	end
	if callback then
		callback(nil, nil, "Sign in to your Community Account first.")
	end
	return false
end

local function AuthFailure(response)
	local unauthorized, message = CommunityAccount.HandleUnauthorized(response)
	if unauthorized then
		return message
	end
	return nil
end

local function IntegerAtLeast(value, minimum)
	return type(value) == "number" and value == Floor(value) and value >= minimum
end

local function ValidProfileId(value)
	value = tostring(value or "")
	return string.len(value) == 27 and string.find(value, "^cp_[0-9a-f]+$") ~= nil
end

local function NormalizeItem(value)
	if type(value) ~= "table" then
		return nil
	end
	if not IntegerAtLeast(value.submission_id, 1) then
		return nil
	end
	if value.game_id ~= "c3_dbd" then
		return nil
	end
	if type(value.name) ~= "string" or value.name == "" or string.len(value.name) > 20 then
		return nil
	end
	if type(value.nationality) ~= "string" then
		return nil
	end
	if not IntegerAtLeast(value.score, 0) then
		return nil
	end
	if type(value.game_data) ~= "string" then
		return nil
	end
	if type(value.integrity_status) ~= "string" then
		return nil
	end
	local campaignMode = tostring(value.campaign_mode or "story")
	if campaignMode ~= "story" and campaignMode ~= "free" then
		return nil
	end
	if not IntegerAtLeast(value.integrity_version, 0) then
		return nil
	end
	if not IntegerAtLeast(value.score_version, 0) then
		return nil
	end
	if not IntegerAtLeast(value.snapshot_version, 0) then
		return nil
	end
	if type(value.snapshot) ~= "table" then
		return nil
	end
	if type(value.submitted_at_utc) ~= "string" then
		return nil
	end

	-- Account-owned score responses may now include the stable public profile
	-- ID.  Older servers omitted it, so safely fall back to the signed-in
	-- account's authoritative profile ID for these owned rows.
	local profileId = tostring(value.profile_id or "")
	if profileId == "" and CommunityAccount and CommunityAccount.GetProfileId then
		profileId = tostring(CommunityAccount.GetProfileId() or "")
	end
	if profileId ~= "" and not ValidProfileId(profileId) then
		return nil
	end

	return {
		submission_id = value.submission_id,
		profile_id = profileId,
		game_id = value.game_id,
		name = value.name,
		nationality = value.nationality,
		score = value.score,
		campaign_mode = campaignMode,
		game_data = value.game_data,
		integrity_status = value.integrity_status,
		integrity_version = value.integrity_version,
		score_version = value.score_version,
		snapshot_version = value.snapshot_version,
		snapshot = value.snapshot,
		submitted_at_utc = value.submitted_at_utc,
	}
end

function CommunityScores.RequestTicket(callback)
	if not SignedIn(callback) then
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/account/score-ticket", {
		client_version = CommunityScores.ClientVersion,
	}, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		if not response or response.status ~= 201 then
			callback(nil, response, body and body.error or "Could not obtain a score ownership ticket.")
			return
		end
		local ticket = type(body) == "table" and tostring(body.ticket or "") or ""
		if string.len(ticket) ~= 24 or string.find(ticket, "^[0-9a-f]+$") == nil then
			callback(nil, response, "Community server returned an invalid score ownership ticket.")
			return
		end
		local okProfile, profileError = CommunityAccount.AcceptAuthoritativeProfile(
			type(body) == "table" and body.account_id or "",
			type(body) == "table" and body.profile or nil
		)
		if not okProfile then
			callback(nil, response, profileError or "Community server returned invalid account identity data.")
			return
		end
		callback(ticket, response, nil)
	end, CommunityAccount.GetSessionToken())
end

-------------------------------------------------------------------------------
-- Score Requests
-------------------------------------------------------------------------------

function CommunityScores.List(callback)
	if not SignedIn(callback) then
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/account/scores", function(body, response, err)
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
			callback(nil, response, body and body.error or "Could not retrieve your Community scores.")
			return
		end
		local result = {}
		local source = type(body) == "table" and body.items or nil
		if type(source) ~= "table" then
			callback(nil, response, "Community score list response is malformed.")
			return
		end
		for _, raw in ipairs(source) do
			local item = NormalizeItem(raw)
			if not item then
				callback(nil, response, "Community score list contained malformed data.")
				return
			end
			table.insert(result, item)
		end
		callback(result, response, nil)
	end, CommunityAccount.GetSessionToken())
end

function CommunityScores.Delete(submissionId, callback)
	if not SignedIn(callback) then
		return false
	end
	if not IntegerAtLeast(submissionId, 1) then
		callback(nil, nil, "Community score has an invalid submission ID.")
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/scores/" .. tostring(submissionId) .. "/delete", {}, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		-- A second device may have deleted the row after this list was loaded.
		-- 404 already represents the requested end state, so deletion remains
		-- safe to retry after a lost response or stale My Scores page.
		if response and response.status == 404 then
			callback({ status = "ok", deleted = true, already_deleted = true, submission_id = submissionId }, response, nil)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not delete Community score.")
			return
		end
		callback(body, response, nil)
	end, CommunityAccount.GetSessionToken())
end
