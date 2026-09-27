--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Account)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/version.lua")
require("community/json.lua")
require("community/transport.lua")

-------------------------------------------------------------------------------
-- Account State
-------------------------------------------------------------------------------

CommunityAccount = CommunityAccount or {}
CommunityAccount.ClientVersion = CommunityVersion

local STORE_FILE = "community_account.json"
local loaded = false
local state =
{
	account_id = "",
	session_token = "",
	login_name = "",
	profile = nil,
}

-------------------------------------------------------------------------------
-- Local Store Helpers
-------------------------------------------------------------------------------

local function Trim(value)
	return string.gsub(tostring(value or ""), "^%s*(.-)%s*$", "%1")
end

local function CopyProfile(value)
	if type(value) ~= "table" then
		return nil
	end
	if type(value.profile_id) ~= "string" or type(value.public_name) ~= "string" then
		return nil
	end
	local stringFields = { "nationality", "gender", "favorite_category", "bio", "updated_at_utc" }
	for _, key in ipairs(stringFields) do
		if value[key] ~= nil and type(value[key]) ~= "string" then
			return nil
		end
	end
	local favorite = value.favorite_product
	if type(favorite) ~= "table" then
		favorite = {}
	end
	for _, key in ipairs({ "kind", "id", "name" }) do
		if favorite[key] ~= nil and type(favorite[key]) ~= "string" then
			return nil
		end
	end
	local function NamedFavorite(field)
		local item = value[field]
		if type(item) ~= "table" then
			item = {}
		end
		for _, key in ipairs({ "id", "name" }) do
			if item[key] ~= nil and type(item[key]) ~= "string" then
				return nil
			end
		end
		return { id = tostring(item.id or ""), name = tostring(item.name or "") }
	end
	local favoriteIngredient = NamedFavorite("favorite_ingredient")
	local favoriteCharacter = NamedFavorite("favorite_character")
	local favoritePort = NamedFavorite("favorite_port")
	if not favoriteIngredient or not favoriteCharacter or not favoritePort then
		return nil
	end
	return {
		profile_id = tostring(value.profile_id or ""),
		public_name = tostring(value.public_name or ""),
		nationality = tostring(value.nationality or ""),
		gender = tostring(value.gender or ""),
		favorite_product =
		{
			kind = tostring(favorite.kind or ""),
			id = tostring(favorite.id or ""),
			name = tostring(favorite.name or ""),
		},
		favorite_category = tostring(value.favorite_category or ""),
		favorite_ingredient = favoriteIngredient,
		favorite_character = favoriteCharacter,
		favorite_port = favoritePort,
		bio = tostring(value.bio or ""),
		updated_at_utc = tostring(value.updated_at_utc or ""),
	}
end

local function ValidProfileShape(value)
	if type(value) ~= "table" then
		return false
	end
	local profileId = tostring(value.profile_id or "")
	local publicName = tostring(value.public_name or "")
	if string.len(profileId) ~= 27 or string.find(profileId, "^cp_[0-9a-f]+$") == nil then
		return false
	end
	if publicName == "" or string.len(publicName) > 20 or string.find(publicName, "|", 1, true)
	   or string.find(publicName, "%c") then return false end
	if type(value.favorite_product) ~= "table" then
		return false
	end
	if type(value.favorite_ingredient) ~= "table" or type(value.favorite_character) ~= "table" or type(value.favorite_port) ~= "table" then
		return false
	end
	return true
end

local function SaveStore()
	local ok, encoded = pcall(CommunityJSON.Encode, {
		version = 3,
		account_id = state.account_id,
		session_token = state.session_token,
		login_name = state.login_name,
		profile = state.profile,
	})
	if not ok then
		DebugOut("COMMUNITY", "Could not encode Community Account store: " .. tostring(encoded))
		return false
	end
	WriteToFile(STORE_FILE, encoded)
	return true
end

local function ValidSessionShape()
	if state.session_token == "" or state.account_id == "" then
		return false
	end
	if string.len(state.session_token) ~= 64 or string.find(state.session_token, "^[0-9a-f]+$") == nil then
		return false
	end
	if string.len(state.account_id) ~= 27 or string.find(state.account_id, "^ca_[0-9a-f]+$") == nil then
		return false
	end
	if not ValidProfileShape(state.profile) then
		return false
	end
	return true
end

local function LoadStore()
	if loaded then
		return
	end
	loaded = true
	local raw = ReadFromFile(STORE_FILE)
	if not raw or raw == "" then
		return
	end
	local ok, decoded = pcall(CommunityJSON.Decode, raw)
	if not ok or type(decoded) ~= "table" then
		DebugOut("COMMUNITY", "Ignoring malformed Community Account store.")
		return
	end
	local token = tostring(decoded.session_token or "")
	if token ~= "" and (string.len(token) ~= 64 or string.find(token, "^[0-9a-f]+$") == nil) then
		DebugOut("COMMUNITY", "Ignoring malformed Community Account session token.")
		return
	end
	state.account_id = tostring(decoded.account_id or "")
	state.session_token = token
	state.login_name = Trim(decoded.login_name or "")
	state.profile = CopyProfile(decoded.profile)
	if (state.session_token ~= "" or state.account_id ~= "") and not ValidSessionShape() then
		DebugOut("COMMUNITY", "Discarding incomplete Community Account session state.")
		state.account_id = ""
		state.session_token = ""
		state.profile = nil
		SaveStore()
	end
end

local function AcceptSession(body, loginName)
	if type(body) ~= "table" or type(body.session_token) ~= "string" or string.len(body.session_token) ~= 64
	   or string.find(body.session_token, "^[0-9a-f]+$") == nil then
		return false, "Community Account response did not contain a valid session."
	end
	local acceptedProfile = CopyProfile(body.profile)
	local accountId = tostring(body.account_id or "")
	if string.len(accountId) ~= 27 or string.find(accountId, "^ca_[0-9a-f]+$") == nil
	   or not acceptedProfile or not ValidProfileShape(acceptedProfile) then
		return false, "Community Account response did not contain a valid public profile."
	end
	state.session_token = body.session_token
	state.account_id = accountId
	state.login_name = Trim(loginName or state.login_name or "")
	state.profile = acceptedProfile
	SaveStore()
	return true, nil
end

-------------------------------------------------------------------------------
-- Validation
-------------------------------------------------------------------------------

function CommunityAccount.ValidateLoginName(value)
	value = Trim(value)
	if string.len(value) < 3 or string.len(value) > 32 or string.find(value, "^[A-Za-z0-9_.%-]+$") == nil then
		return nil, "Sign-in name must be 3-32 letters, numbers, dots, dashes or underscores."
	end
	return value, nil
end

function CommunityAccount.ValidatePassword(value)
	value = tostring(value or "")
	if string.len(value) < 10 or string.len(value) > 128 then
		return nil, "Password must be between 10 and 128 characters."
	end
	return value, nil
end

function CommunityAccount.ValidatePublicName(value)
	value = Trim(value)
	if value == "" or string.len(value) > 20 or string.find(value, "|", 1, true) or string.find(value, "%c") then
		return nil, "Public name must be 1-20 UTF-8 bytes and contain no control characters or |."
	end
	return value, nil
end

-------------------------------------------------------------------------------
-- Session Access
-------------------------------------------------------------------------------

function CommunityAccount.IsSignedIn()
	LoadStore()
	return ValidSessionShape()
end

function CommunityAccount.GetSessionToken()
	LoadStore()
	return state.session_token
end

function CommunityAccount.GetAccountId()
	LoadStore()
	return state.account_id
end

function CommunityAccount.GetProfile()
	LoadStore()
	return CopyProfile(state.profile)
end

function CommunityAccount.GetProfileId()
	LoadStore()
	return state.profile and tostring(state.profile.profile_id or "") or ""
end

function CommunityAccount.GetLoginName()
	LoadStore()
	return state.login_name
end

-------------------------------------------------------------------------------
-- Profile State
-------------------------------------------------------------------------------

-- Refresh the cached profile when an authenticated request returns newer public data.
function CommunityAccount.AcceptAuthoritativeProfile(accountId, profile)
	LoadStore()
	accountId = tostring(accountId or "")
	local accepted = CopyProfile(profile)
	if not ValidSessionShape() then
		return false, "You are not signed in."
	end
	if accountId ~= state.account_id then
		return false, "Community server returned a different account identity."
	end
	if not accepted or not ValidProfileShape(accepted) then
		return false, "Community server returned an invalid public profile."
	end
	if tostring(state.profile.profile_id or "") ~= tostring(accepted.profile_id or "") then
		return false, "Community server returned a different profile identity."
	end
	state.profile = accepted
	SaveStore()
	return true, nil
end

-- Keep the sign-in name when a session expires; never retain the password.
function CommunityAccount.InvalidateSession(keepLogin)
	LoadStore()
	local login = keepLogin == false and "" or state.login_name
	state = { account_id = "", session_token = "", login_name = login, profile = nil }
	SaveStore()
end

function CommunityAccount.ClearLocal()
	loaded = true
	state = { account_id = "", session_token = "", login_name = "", profile = nil }
	WriteToFile(STORE_FILE, "")
end

function CommunityAccount.HandleUnauthorized(response)
	if response and tonumber(response.status) == 401 then
		CommunityAccount.InvalidateSession(true)
		return true, "Your Community Account session expired or was revoked. Please sign in again."
	end
	return false, nil
end

-------------------------------------------------------------------------------
-- Account Requests
-------------------------------------------------------------------------------

function CommunityAccount.Register(loginName, password, profile, callback)
	local login, loginError = CommunityAccount.ValidateLoginName(loginName)
	if not login then
		callback(nil, nil, loginError)
		return false
	end
	local secret, passwordError = CommunityAccount.ValidatePassword(password)
	if not secret then
		callback(nil, nil, passwordError)
		return false
	end
	profile = profile or {}
	local publicName, publicError = CommunityAccount.ValidatePublicName(profile.public_name)
	if not publicName then
		callback(nil, nil, publicError)
		return false
	end
	profile.public_name = publicName
	local payload =
	{
		login_name = login,
		password = secret,
		client_version = CommunityAccount.ClientVersion,
		profile = profile,
	}
	return CommunityTransport.PostJSON("/api/v1/accounts/register", payload, function(body, response, err)
		if err then
			-- A lost registration response may still have created the account.
			-- Try one sign-in before reporting the connection failure.
			if not response or tonumber(response.status or 0) == 0 then
				CommunityTransport.PostJSON("/api/v1/accounts/login", {
					login_name = login,
					password = secret,
					client_version = CommunityAccount.ClientVersion,
				}, function(loginBody, loginResponse, loginErr)
					if not loginErr and loginResponse and loginResponse.status == 200 then
						local ok, acceptError = AcceptSession(loginBody, login)
						if ok then
							callback(CommunityAccount.GetProfile(), loginResponse, nil)
							return
						end
						callback(nil, loginResponse, acceptError)
						return
					end
					callback(nil, response, err)
				end)
				return
			end
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 201 then
			callback(nil, response, body and body.error or "Could not create Community Account.")
			return
		end
		local ok, acceptError = AcceptSession(body, login)
		if not ok then
			callback(nil, response, acceptError)
			return
		end
		callback(CommunityAccount.GetProfile(), response, nil)
	end)
end

function CommunityAccount.Login(loginName, password, callback)
	local login, loginError = CommunityAccount.ValidateLoginName(loginName)
	if not login then
		callback(nil, nil, loginError)
		return false
	end
	local secret, passwordError = CommunityAccount.ValidatePassword(password)
	if not secret then
		callback(nil, nil, passwordError)
		return false
	end
	-- Remember only the non-secret sign-in name. Passwords are never persisted.
	state.login_name = login
	SaveStore()
	return CommunityTransport.PostJSON("/api/v1/accounts/login", {
		login_name = login,
		password = secret,
		client_version = CommunityAccount.ClientVersion,
	}, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not sign in to Community Account.")
			return
		end
		local ok, acceptError = AcceptSession(body, login)
		if not ok then
			callback(nil, response, acceptError)
			return
		end
		callback(CommunityAccount.GetProfile(), response, nil)
	end)
end

function CommunityAccount.Refresh(callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "You are not signed in.")
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/account/me", function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local unauthorized, authError = CommunityAccount.HandleUnauthorized(response)
		if unauthorized then
			callback(nil, response, authError)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not refresh Community Account.")
			return
		end
		local refreshed = CopyProfile(body.profile)
		if not refreshed or not ValidProfileShape(refreshed) then
			callback(nil, response, "Community Account refresh returned an invalid profile.")
			return
		end
		local returnedAccountId = tostring(body.account_id or "")
		if returnedAccountId ~= state.account_id then
			callback(nil, response, "Community Account refresh returned a different account identity.")
			return
		end
		if tostring(refreshed.profile_id or "") ~= tostring(state.profile and state.profile.profile_id or "") then
			callback(nil, response, "Community Account refresh returned a different profile identity.")
			return
		end
		state.login_name = Trim(body.login_name or state.login_name)
		state.profile = refreshed
		SaveStore()
		callback({ profile = CommunityAccount.GetProfile(), cloud_save_count = tonumber(body.cloud_save_count) or 0 }, response, nil)
	end, state.session_token)
end

function CommunityAccount.UpdateProfile(profile, callback)
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "You are not signed in.")
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/account/profile", { profile = profile }, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local unauthorized, authError = CommunityAccount.HandleUnauthorized(response)
		if unauthorized then
			callback(nil, response, authError)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not update Community Profile.")
			return
		end
		local updated = CopyProfile(body.profile)
		if not updated or not ValidProfileShape(updated) then
			callback(nil, response, "Community Profile update returned invalid data.")
			return
		end
		if tostring(updated.profile_id or "") ~= tostring(state.profile and state.profile.profile_id or "") then
			callback(nil, response, "Community Profile update returned a different profile identity.")
			return
		end
		state.profile = updated
		SaveStore()
		callback(CommunityAccount.GetProfile(), response, nil)
	end, state.session_token)
end

function CommunityAccount.Logout(callback)
	if not CommunityAccount.IsSignedIn() then
		CommunityAccount.InvalidateSession(true)
		if callback then
			callback(true, nil, nil)
		end
		return true
	end
	local token = state.session_token
	return CommunityTransport.PostJSON("/api/v1/account/logout", {}, function(body, response, err)
		if err then
			-- Keep the local session when logout cannot reach the server.
			if callback then
				callback(false, response, err)
			end
			return
		end
		if response and (response.status == 200 or response.status == 401) then
			CommunityAccount.InvalidateSession(true)
			if callback then
				callback(true, response, nil)
			end
			return
		end
		if callback then
			callback(false, response, body and body.error or "Could not sign out of Community Account.")
		end
	end, token)
end
