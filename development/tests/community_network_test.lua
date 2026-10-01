--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Network Test)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/transport.lua")
require("community/creation.lua")
require("community/api.lua")

-------------------------------------------------------------------------------
-- Test State
-------------------------------------------------------------------------------

local lastCreationId = nil

-------------------------------------------------------------------------------
-- Test Actions
-------------------------------------------------------------------------------

local function SetStatus(text)
	SetLabel("community_test_status", "#" .. tostring(text))
end

local function Busy()
	if CommunityTransport.IsBusy() then
		SetStatus("A request is already running.")
		return true
	end
	return false
end

local function TestPing()
	if Busy() then
		return
	end
	SetStatus("Contacting staging community API...")
	CommunityTransport.GetJSON("/api/v1/community/ping", function(body, response, err)
		if err then
			SetStatus("FAILED: " .. tostring(err))
			DebugOut("COMMUNITY", "Ping failed: " .. tostring(err))
			return
		end
		if not response or response.status ~= 200 then
			SetStatus("HTTP " .. tostring(response and response.status or 0))
			return
		end
		SetStatus(string.format("OK — API v%s, schema v%s", tostring(body.api_version), tostring(body.creation_schema_version)))
		DebugOut("COMMUNITY", "Community API ping succeeded.", body)
	end)
end

local function TestDemoCreation()
	if Busy() then
		return
	end
	SetStatus("Downloading demo creation...")
	CommunityTransport.GetJSON("/api/v1/creations/demo", function(body, response, err)
		if err then
			SetStatus("FAILED: " .. tostring(err))
			DebugOut("COMMUNITY", "Demo GET failed: " .. tostring(err))
			return
		end
		if not response or response.status ~= 200 then
			SetStatus("HTTP " .. tostring(response and response.status or 0))
			return
		end
		local creation, formatError = CommunityCreation.Normalize(body.creation or {})
		if not creation then
			SetStatus("FORMAT FAILED: " .. tostring(formatError))
			return
		end
		SetStatus(string.format("%s — %s — %d ingredients — %d layers",
			tostring(creation.name), tostring(creation.category),
			table.getn(creation.ingredients), table.getn(creation.appearance)))
		DebugOut("COMMUNITY", "Demo creation decoded and validated successfully.", creation)
	end)
end

local function TestEchoPost()
	if Busy() then
		return
	end
	SetStatus("Posting CreationData v1 test payload...")
	local payload, formatError = CommunityCreation.Normalize {
		schema_version = 1,
		game_id = "c3_dbd",
		name = "Bridge Test Bar",
		description = "Round-trip transport test from the Reforged Lua runtime " .. string.char(0x96) .. " legacy punctuation.",
		category = "bar",
		ingredients = { "cacao", "sugar" },
		appearance =
		{
			{ image = "bar/layer1_01", red = 40, green = 22, blue = 8 },
		},
	}
	if not payload then
		SetStatus("FORMAT FAILED: " .. tostring(formatError))
		return
	end
	CommunityTransport.PostJSON("/api/v1/creations/test", payload, function(body, response, err)
		if err then
			SetStatus("FAILED: " .. tostring(err))
			DebugOut("COMMUNITY", "Demo POST failed: " .. tostring(err))
			return
		end
		if not response or response.status ~= 200 then
			SetStatus("HTTP " .. tostring(response and response.status or 0) .. " — " .. tostring(body and body.error or "request rejected"))
			return
		end
		SetStatus("POST accepted — canonical payload SHA-256: " .. tostring(body.payload_sha256 or "?"))
		DebugOut("COMMUNITY", "Creation test POST accepted.", body)
	end)
end

local function TestBrowse()
	if Busy() then
		return
	end
	SetStatus("Browsing persisted creations...")
	CommunityApi.Browse({ page = 1, page_size = 8, sort = "newest" }, function(result, response, err)
		if err then
			SetStatus("FAILED: " .. tostring(err))
			DebugOut("COMMUNITY", "Browse failed: " .. tostring(err))
			return
		end
		local first = result.items[1]
		if first then
			lastCreationId = first.id
			SetStatus(string.format("Browse OK — %d total. First: %s by %s", result.total, first.creation.name, first.author.public_name))
		else
			SetStatus("Browse OK — no persisted creations yet.")
		end
		DebugOut("COMMUNITY", "Persisted creation browse succeeded.", result)
	end)
end

local function TestUploadUGR()
	if Busy() then
		return
	end
	local creation, formatError, meta = CommunityCreation.FirstSavedCreation()
	if not creation then
		SetStatus("NO UGR: " .. tostring(formatError))
		return
	end
	SetStatus("Uploading saved UGR: " .. tostring(creation.name) .. "...")
	CommunityApi.Upload(creation, function(item, response, err)
		if err then
			SetStatus("FAILED: " .. tostring(err))
			DebugOut("COMMUNITY", "UGR upload failed: " .. tostring(err))
			return
		end
		lastCreationId = item.id
		SetStatus("UPLOADED — " .. tostring(item.creation.name) .. " — " .. tostring(item.id))
		DebugOut("COMMUNITY", "Actual saved UGR persisted successfully.", item)
	end)
end

local function TestCountLoad()
	if Busy() then
		return
	end
	if not lastCreationId then
		SetStatus("Browse or upload a persisted creation first.")
		return
	end
	SetStatus("Recording load for " .. tostring(lastCreationId) .. "...")
	CommunityApi.RecordLoad(lastCreationId, function(body, response, err)
		if err then
			SetStatus("FAILED: " .. tostring(err))
			DebugOut("COMMUNITY", "Count Load failed: " .. tostring(err))
			return
		end
		SetStatus("Load recorded — count is now " .. tostring(body.load_count or "?"))
		DebugOut("COMMUNITY", "Creation load count incremented.", body)
	end)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	name = "community_network_test",
	BSGWindow
	{
		x = kCenter, y = kCenter, w = 560, h = 352, fit = true, color = { 1, 1, 1, 0.95 },
		SetStyle(C3DialogBodyStyle),
		Text { x = 30, y = 22, w = 500, h = 32, label = "#Community Creations API Test", font = { labelFontName, 22, MaroonColor }, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 38, y = 60, w = 484, h = 52,
			label = "#Transport + persisted API harness. Transport + persisted API harness. Community launcher active.",
			font = { standardFont, 13, BlackColor }, flags = kHAlignCenter + kVAlignTop },
		Text { x = 40, y = 115, w = 480, h = 70, name = "community_test_status", label = "#Ready.", font = { standardFont, 14, BlackColor }, flags = kHAlignCenter + kVAlignCenter },

		SetStyle(C3ButtonMediumStyle),
		Button { x = 100, y = 198, label = "#Ping", command = TestPing },
		Button { x = 280, y = 198, label = "#Demo GET", command = TestDemoCreation },
		Button { x = 460, y = 198, label = "#Echo POST", command = TestEchoPost },
		Button { x = 100, y = 246, label = "#Browse", command = TestBrowse },
		Button { x = 280, y = 246, label = "#Upload UGR", command = TestUploadUGR },
		Button { x = 460, y = 246, label = "#Count Load", command = TestCountLoad },

		SetStyle(C3RoundButtonStyle),
		Button { x = 280, y = 304, label = "ok", default = true, cancel = true, close = true },
	}
}
