--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Transport)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/json.lua")

-------------------------------------------------------------------------------
-- Bridge State
-------------------------------------------------------------------------------

CommunityTransport = CommunityTransport or {}
CommunityTransport.nextId = CommunityTransport.nextId or 1
CommunityTransport.pending = CommunityTransport.pending or nil
CommunityTransport.pollEveryFrames = 6
CommunityTransport.timeoutFrames = 1800

local MAX_REQUEST_BODY_BYTES = 5 * 1024 * 1024
local MAX_REQUEST_PATH_BYTES = 4095

local REQUEST_FILE = "request.txt"
local RESPONSE_FILE = "response.txt"
local READY_FILE = "ready.txt"
local PROBE_FILE = "community_bridge_probe.txt"

local function ParseHeaderBlock(text)
	local separator = string.find(text, "\n\n", 1, true)
	if not separator then
		return nil, "Bridge response has no header separator."
	end
	local head = string.sub(text, 1, separator - 1)
	local body = string.sub(text, separator + 2)
	local fields = {}
	for line in string.gfind(head, "([^\n]+)") do
		local colon = string.find(line, ":", 1, true)
		if colon then
			local key = string.sub(line, 1, colon - 1)
			local value = string.sub(line, colon + 1)
			value = string.gsub(value, "^%s+", "")
			value = string.gsub(value, "%s+$", "")
			fields[key] = value
		end
	end
	return fields, body
end

local function ParseBridgeResponse(text)
	if not text or text == "" then
		return nil, "No bridge response."
	end
	if string.sub(text, 1, 4) ~= "CCB1" then
		return nil, "Unsupported bridge response format."
	end
	local fields, rawBody = ParseHeaderBlock(text)
	if not fields then
		return nil, rawBody
	end
	local function StrictUInt(value)
		value = tostring(value or "")
		if value == "" or string.find(value, "^[0-9]+$") == nil then
			return nil
		end
		local number = tonumber(value)
		if not number or number < 0 or number ~= Floor(number) then
			return nil
		end
		return number
	end
	local id = StrictUInt(fields.ID)
	local status = StrictUInt(fields.STATUS)
	local bodyLength = StrictUInt(fields["BODY-LENGTH"])
	if not id then
		return nil, "Bridge response has an invalid request ID."
	end
	if not status then
		return nil, "Bridge response has an invalid HTTP status."
	end
	if not bodyLength then
		return nil, "Bridge response has an invalid body length."
	end
	local trailer = "\nCCB-END\n"
	if string.len(rawBody) ~= bodyLength + string.len(trailer)
	   or string.sub(rawBody, bodyLength + 1) ~= trailer then
		return nil, "Bridge response envelope is incomplete or has trailing data."
	end
	local body = string.sub(rawBody, 1, bodyLength)
	return {
		id = id,
		status = status,
		bridgeError = fields["BRIDGE-ERROR"],
		body = body,
	}
end

local function BuildBridgeRequest(id, method, path, body, authToken)
	body = body or ""
	authToken = tostring(authToken or "")
	local parts =
	{
		"CCB1\n",
		"ID: ", tostring(id), "\n",
		"METHOD: ", method, "\n",
		"PATH: ", path, "\n",
	}
	if authToken ~= "" then
		table.insert(parts, "AUTH: ")
		table.insert(parts, authToken)
		table.insert(parts, "\n")
	end
	table.insert(parts, "BODY-LENGTH: ")
	table.insert(parts, tostring(string.len(body)))
	table.insert(parts, "\n\n")
	table.insert(parts, body)
	table.insert(parts, "\nCCB-END\n")
	return table.concat(parts)
end

local function FinishPending(response, err)
	local pending = CommunityTransport.pending
	CommunityTransport.pending = nil
	if not pending then
		return
	end
	if pending.callback then
		pending.callback(response, err)
	end
end

local function PrimeBridgeDiscovery()
	-- ReadFromFile/WriteToFile are not ordinary cwd-relative file calls. The
	-- Playground executable transparently prefixes plain names with its
	-- virtual "user:" mount. Write a probe into that mount so the native
	-- bridge can discover the exact physical directory on this Windows user.
	WriteToFile(PROBE_FILE, "CCB1 PROBE\nGAME: c3_dbd\n")
end

-------------------------------------------------------------------------------
-- Request Processing
-------------------------------------------------------------------------------

local function PollPending()
	local pending = CommunityTransport.pending
	if not pending then
		return
	end

	pending.frames = pending.frames + 1
	if pending.frames > CommunityTransport.timeoutFrames then
		if pending.stage == "waiting_ready" then
			FinishPending(nil, "Community bridge could not discover Chocolatier's user-file directory. Check community_bridge/bridge_status.txt.")
		else
			FinishPending(nil, "No response from the Community bridge. Check community_bridge/bridge_status.txt.")
		end
		return
	end

	if Mod(pending.frames, CommunityTransport.pollEveryFrames) ~= 0 then
		QueueCommand(PollPending)
		return
	end

	if pending.stage == "waiting_ready" then
		local ready = ReadFromFile(READY_FILE)
		if ready and string.find(ready, "CCB1 READY", 1, true) then
			WriteToFile(REQUEST_FILE, pending.requestText)
			pending.stage = "waiting_response"
			DebugOut("COMMUNITY", string.format("Bridge request %d queued after user-root discovery: %s %s", pending.id, pending.method, pending.path))
		elseif Mod(pending.frames, CommunityTransport.pollEveryFrames * 10) == 0 then
			-- Re-write the probe occasionally in case the bridge started a
			-- fraction later than the Lua module.
			PrimeBridgeDiscovery()
		end
		QueueCommand(PollPending)
		return
	end

	local raw = ReadFromFile(RESPONSE_FILE)
	if raw and raw ~= "" then
		local response, parseError = ParseBridgeResponse(raw)
		if response and response.id == pending.id then
			if response.bridgeError and response.bridgeError ~= "" then
				FinishPending(response, response.bridgeError)
				return
			end
			FinishPending(response, nil)
			return
		elseif parseError then
			DebugOut("COMMUNITY", "Ignoring malformed/stale bridge response: " .. tostring(parseError))
		end
	end
	QueueCommand(PollPending)
end

function CommunityTransport.IsBusy()
	return CommunityTransport.pending ~= nil
end

-------------------------------------------------------------------------------
-- Community Transport
-------------------------------------------------------------------------------

function CommunityTransport.Request(method, path, body, callback, authToken)
	if CommunityTransport.pending then
		if callback then
			callback(nil, "A community request is already in progress.")
		end
		return false
	end
	method = string.upper(tostring(method or "GET"))
	path = tostring(path or "")
	body = body or ""
	if string.sub(path, 1, 1) ~= "/" then
		if callback then
			callback(nil, "Community request path must begin with '/'.")
		end
		return false
	end
	if string.len(path) > MAX_REQUEST_PATH_BYTES or string.find(path, "%c") then
		if callback then
			callback(nil, "Community request path is malformed or too long.")
		end
		return false
	end
	if type(body) ~= "string" or string.len(body) > MAX_REQUEST_BODY_BYTES then
		if callback then
			callback(nil, "Community request is too large for the native bridge.")
		end
		return false
	end
	if method ~= "GET" and method ~= "POST" and method ~= "OPEN" then
		if callback then
			callback(nil, "Community bridge supports GET, POST and allowlisted OPEN requests only.")
		end
		return false
	end
	if method == "OPEN" and string.sub(path, 1, 10) ~= "/external/" then
		if callback then
			callback(nil, "External-link bridge request is malformed.")
		end
		return false
	end

	local id = CommunityTransport.nextId
	CommunityTransport.nextId = id + 1
	authToken = tostring(authToken or "")
	if authToken ~= "" and (string.len(authToken) ~= 64 or string.find(authToken, "^[0-9a-f]+$") == nil) then
		if callback then
			callback(nil, "Community session token is malformed.")
		end
		return false
	end
	local requestText = BuildBridgeRequest(id, method, path, body, authToken)
	CommunityTransport.pending =
	{
		id = id,
		callback = callback,
		frames = 0,
		stage = "waiting_ready",
		method = method,
		path = path,
		requestText = requestText,
	}

	PrimeBridgeDiscovery()
	DebugOut("COMMUNITY", "Waiting for native bridge to discover Playground's user: file mount.")
	QueueCommand(PollPending)
	return true
end

-- Prime bridge discovery in Playground's transient user: mount.
PrimeBridgeDiscovery()

function CommunityTransport.OpenExternal(target, callback)
	target = tostring(target or "")
	local allowed = { discord = true, wiki = true }
	if not allowed[target] then
		if callback then
			callback(false, "External link is not allowlisted.")
		end
		return false
	end
	return CommunityTransport.Request("OPEN", "/external/" .. target, "", function(response, err)
		if err then
			if callback then
				callback(false, err)
			end
			return
		end
		if not response or response.status ~= 200 then
			if callback then
				callback(false, "The native bridge could not open the external link.")
			end
			return
		end
		if callback then
			callback(true, nil)
		end
	end)
end

function CommunityTransport.GetJSON(path, callback, authToken)
	return CommunityTransport.Request("GET", path, "", function(response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local ok, value = pcall(CommunityJSON.Decode, response.body)
		if not ok then
			callback(nil, response, "Invalid JSON response: " .. tostring(value))
			return
		end
		callback(value, response, nil)
	end, authToken)
end

function CommunityTransport.PostJSON(path, value, callback, authToken)
	local ok, body = pcall(CommunityJSON.Encode, value)
	if not ok then
		callback(nil, nil, "Could not encode JSON request: " .. tostring(body))
		return false
	end
	return CommunityTransport.Request("POST", path, body, function(response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local decodedOk, decoded = pcall(CommunityJSON.Decode, response.body)
		if not decodedOk then
			callback(nil, response, "Invalid JSON response: " .. tostring(decoded))
			return
		end
		callback(decoded, response, nil)
	end, authToken)
end
