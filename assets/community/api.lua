--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community API)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/version.lua")
require("community/transport.lua")
require("community/creation.lua")
require("community/account.lua")
require("community/identity.lua")

-------------------------------------------------------------------------------
-- API State
-------------------------------------------------------------------------------

CommunityApi = CommunityApi or {}
CommunityApi.ClientVersion = CommunityVersion
CommunityApi.CreationTagOrder =
{
	"sweet", "bitter", "fruity", "nutty",
	"spiced", "floral", "citrus", "tropical",
	"coffee", "tea", "creamy", "boozy",
	"rich", "herbal", "savoury", "experimental",
	"dark_chocolate", "milk_chocolate", "white_chocolate", "caramel",
}
CommunityApi.MaxCreationTags = 4

-------------------------------------------------------------------------------
-- Request Helpers
-------------------------------------------------------------------------------

local function UrlEncode(value)
	value = tostring(value or "")
	return string.gsub(value, "([^A-Za-z0-9%-_%.~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
end

local function PublicCreationId(value)
	return type(value) == "string" and string.len(value) == 27 and string.find(value, "^cr_[0-9a-f]+$") ~= nil
end

local function IntegerAtLeast(value, minimum)
	return type(value) == "number" and value == Floor(value) and value >= minimum
end

local function OptionalString(value)
	return value == nil or type(value) == "string"
end

local function FiniteNumber(value)
	if type(value) ~= "number" or value ~= value then
		return false
	end
	local zero = value - value
	return zero == zero
end

local function NormalizeTags(value)
	-- Empty Lua tables are ambiguous to the Community JSON encoder: an
	-- unmarked {} is encoded as a JSON object, not an array. Tags are always
	-- an ordered JSON array, including when no tags are selected, so preserve
	-- that type explicitly through normalization.
	if value == nil then
		return CommunityJSON.Array({})
	end
	if type(value) ~= "table" or table.getn(value) > CommunityApi.MaxCreationTags then
		return nil, "Community creation has invalid tag metadata."
	end
	local allowed = {}
	for _, tag in ipairs(CommunityApi.CreationTagOrder) do
		allowed[tag] = true
	end
	local seen = {}
	local result = CommunityJSON.Array({})
	for _, tag in ipairs(value) do
		if type(tag) ~= "string" or not allowed[tag] or seen[tag] then
			return nil, "Community creation has invalid tag metadata."
		end
		seen[tag] = true
	end
	for _, tag in ipairs(CommunityApi.CreationTagOrder) do
		if seen[tag] then
			table.insert(result, tag)
		end
	end
	return result, nil
end

local function AuthToken()
	return CommunityAccount and CommunityAccount.IsSignedIn() and CommunityAccount.GetSessionToken() or ""
end

local function AuthFailure(response)
	local unauthorized, message = CommunityAccount.HandleUnauthorized(response)
	if unauthorized then
		return message
	end
	return nil
end

-------------------------------------------------------------------------------
-- Creation Validation
-------------------------------------------------------------------------------

function CommunityApi.NormalizeItem(value)
	if type(value) ~= "table" then
		return nil, "Community creation item must be a table."
	end
	if not PublicCreationId(value.id) then
		return nil, "Community creation has an invalid public ID."
	end
	if type(value.author) ~= "table" or type(value.author.public_name) ~= "string"
	   or value.author.public_name == "" or string.len(value.author.public_name) > 20
	   or not OptionalString(value.author.nationality) or not OptionalString(value.author.profile_id) then
		return nil, "Community creation has invalid author metadata."
	end
	local authorProfileId = value.author.profile_id or ""
	if authorProfileId ~= "" and (string.len(authorProfileId) ~= 27 or string.find(authorProfileId, "^cp_[0-9a-f]+$") == nil) then
		return nil, "Community creation has invalid author profile metadata."
	end
	if type(value.created_at_utc) ~= "string" or not IntegerAtLeast(value.load_count, 0) then
		return nil, "Community creation has invalid server metadata."
	end
	local tags, tagError = NormalizeTags(value.tags)
	if not tags then
		return nil, tagError
	end
	local ratingAverage = value.rating_average or 0
	local ratingCount = value.rating_count or 0
	if not FiniteNumber(ratingAverage) or ratingAverage < 0 or ratingAverage > 5
	   or not IntegerAtLeast(ratingCount, 0) then
		return nil, "Community creation has invalid rating metadata."
	end
	if type(value.payload_sha256) ~= "string" or string.len(value.payload_sha256) ~= 64
	   or string.find(value.payload_sha256, "^[0-9a-f]+$") == nil then
		return nil, "Community creation has invalid payload metadata."
	end
	local creation, err = CommunityCreation.Normalize(value.creation)
	if not creation then
		return nil, err
	end
	local remixOf = nil
	if value.remix_of ~= nil then
		if type(value.remix_of) ~= "table" or not PublicCreationId(value.remix_of.id)
		   or type(value.remix_of.name) ~= "string" or value.remix_of.name == "" or string.len(value.remix_of.name) > 100
		   or type(value.remix_of.author) ~= "table"
		   or type(value.remix_of.author.public_name) ~= "string" or value.remix_of.author.public_name == ""
		   or string.len(value.remix_of.author.public_name) > 20
		   or not OptionalString(value.remix_of.author.profile_id) then
			return nil, "Community creation has invalid remix metadata."
		end
		local remixProfileId = value.remix_of.author.profile_id or ""
		if remixProfileId ~= "" and (string.len(remixProfileId) ~= 27 or string.find(remixProfileId, "^cp_[0-9a-f]+$") == nil) then
			return nil, "Community creation has invalid remix author metadata."
		end
		remixOf =
		{
			id = value.remix_of.id,
			name = value.remix_of.name,
			author =
			{
				public_name = value.remix_of.author.public_name,
				profile_id = remixProfileId,
			},
		}
	end
	local accountProfileId = CommunityAccount and CommunityAccount.GetProfileId and CommunityAccount.GetProfileId() or ""
	return {
		id = value.id,
		author =
		{
			public_name = value.author.public_name,
			nationality = value.author.nationality or "",
			profile_id = authorProfileId,
		},
		created_at_utc = value.created_at_utc,
		load_count = value.load_count,
		tags = tags,
		rating_average = ratingAverage,
		rating_count = ratingCount,
		payload_sha256 = value.payload_sha256,
		creation = creation,
		remix_of = remixOf,
		is_owned = (authorProfileId ~= "" and accountProfileId ~= "" and authorProfileId == accountProfileId),
	}, nil
end

-------------------------------------------------------------------------------
-- Creation Requests
-------------------------------------------------------------------------------

function CommunityApi.Browse(options, callback)
	options = options or {}
	local category = options.category or "all"
	local query = options.q or ""
	local sort = options.sort or "newest"
	local page = tonumber(options.page) or 1
	local pageSize = tonumber(options.page_size) or 8
	local path = "/api/v1/creations?category=" .. UrlEncode(category)
		.. "&q=" .. UrlEncode(query) .. "&sort=" .. UrlEncode(sort)
		.. "&page=" .. tostring(Floor(page)) .. "&page_size=" .. tostring(Floor(pageSize))
	return CommunityTransport.GetJSON(path, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Community browse request failed.")
			return
		end
		if type(body) ~= "table" or type(body.items) ~= "table" then
			callback(nil, response, "Community browse response is malformed.")
			return
		end
		local items = {}
		for i = 1, table.getn(body.items) do
			local item, itemError = CommunityApi.NormalizeItem(body.items[i])
			if not item then
				callback(nil, response, itemError)
				return
			end
			table.insert(items, item)
		end
		if not IntegerAtLeast(body.page, 1) or not IntegerAtLeast(body.page_size, 1)
		   or not IntegerAtLeast(body.total, 0) or not IntegerAtLeast(body.pages, 0)
		   or type(body.category) ~= "string" or type(body.q) ~= "string" or type(body.sort) ~= "string" then
			callback(nil, response, "Community browse response has invalid pagination metadata.")
			return
		end
		callback({
			items = items,
			page = body.page,
			page_size = body.page_size,
			total = body.total,
			pages = body.pages,
			category = body.category,
			q = body.q,
			sort = body.sort,
		}, response, nil)
	end)
end

function CommunityApi.Get(creationId, callback)
	if not PublicCreationId(creationId) then
		callback(nil, nil, "Invalid community creation ID.")
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/creations/" .. creationId, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Community creation request failed.")
			return
		end
		local item, itemError = CommunityApi.NormalizeItem(body)
		if not item then
			callback(nil, response, itemError)
			return
		end
		callback(item, response, nil)
	end)
end

function CommunityApi.Upload(creation, metadata, callback)
	if type(metadata) == "function" then
		callback = metadata
		metadata = nil
	end
	callback = callback or function() end
	local canonical, formatError = CommunityCreation.Normalize(creation)
	if not canonical then
		callback(nil, nil, formatError)
		return false
	end
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to your Community Account before sharing creations.")
		return false
	end
	local envelope = { client_version = CommunityApi.ClientVersion, creation = canonical }
	if metadata ~= nil then
		local tags, tagError = NormalizeTags(metadata.tags)
		if not tags then
			callback(nil, nil, tagError)
			return false
		end
		local sourceCreationId = tostring(metadata.source_creation_id or "")
		if sourceCreationId ~= "" and not PublicCreationId(sourceCreationId) then
			callback(nil, nil, "Community remix source is invalid.")
			return false
		end
		envelope.metadata = { tags = tags }
		if sourceCreationId ~= "" then
			envelope.metadata.source_creation_id = sourceCreationId
		end
	end
	return CommunityTransport.PostJSON("/api/v1/creations", envelope, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		if not response or (response.status ~= 201 and response.status ~= 200) then
			callback(nil, response, body and body.error or "Community creation upload failed.")
			return
		end
		if type(body) ~= "table" or type(body.item) ~= "table" or not PublicCreationId(body.item.id) then
			callback(nil, response, "Community upload response is malformed.")
			return
		end
		local item, itemError = CommunityApi.NormalizeItem(body.item)
		if not item then
			callback(nil, response, itemError)
			return
		end
		item.was_duplicate = body.duplicate and true or false
		callback(item, response, nil)
	end, AuthToken())
end

function CommunityApi.IsOwned(creationId, item)
	return item and item.is_owned or false
end

function CommunityApi.Delete(creationId, callback)
	if not PublicCreationId(creationId) then
		callback(nil, nil, "Invalid community creation ID.")
		return false
	end
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in as the owner of this creation to delete it.")
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/creations/" .. creationId .. "/delete", {}, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		local authError = AuthFailure(response)
		if authError then
			callback(nil, response, authError)
			return
		end
		-- Deletion is idempotent from the player's point of view. If another
		-- signed-in computer already removed this owned creation, the desired
		-- state has already been reached; treat 404 as success and refresh.
		if response and response.status == 404 then
			callback({ status = "ok", deleted = true, already_deleted = true, creation_id = creationId }, response, nil)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not delete community creation.")
			return
		end
		callback(body, response, nil)
	end, AuthToken())
end

-------------------------------------------------------------------------------
-- Profile Requests
-------------------------------------------------------------------------------

local function NormalizeProfilePresence(value)
	if value == nil then
		return { online = false, last_played_utc = "", last_played_seconds_ago = nil, presence_window_seconds = 0 }, nil
	end
	if type(value) ~= "table" or type(value.online) ~= "boolean"
	   or not OptionalString(value.last_played_utc)
	   or (value.last_played_seconds_ago ~= nil and not IntegerAtLeast(value.last_played_seconds_ago, 0))
	   or (value.presence_window_seconds ~= nil and not IntegerAtLeast(value.presence_window_seconds, 0)) then
		return nil, "Community Profile contains invalid presence metadata."
	end
	return {
		online = value.online and true or false,
		last_played_utc = tostring(value.last_played_utc or ""),
		last_played_seconds_ago = value.last_played_seconds_ago,
		presence_window_seconds = tonumber(value.presence_window_seconds or 0) or 0,
	}, nil
end

function CommunityApi.GetProfile(profileId, callback)
	profileId = tostring(profileId or "")
	if string.len(profileId) ~= 27 or string.find(profileId, "^cp_[0-9a-f]+$") == nil then
		callback(nil, nil, "This creation is not linked to a Community Profile.")
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/profiles/" .. profileId, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not load Community Profile.")
			return
		end
		if type(body) ~= "table" then
			callback(nil, response, "Community Profile response is malformed.")
			return
		end
		local presence, presenceError = NormalizeProfilePresence(body.presence)
		if not presence then
			callback(nil, response, presenceError)
			return
		end
		body.presence = presence
		callback(body, response, nil)
	end)
end

-------------------------------------------------------------------------------
-- Rating Requests
-------------------------------------------------------------------------------

function CommunityApi.GetRating(creationId, callback)
	if not PublicCreationId(creationId) then
		callback(nil, nil, "Invalid community creation ID.")
		return false
	end
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to rate Community creations.")
		return false
	end
	return CommunityTransport.GetJSON("/api/v1/creations/" .. creationId .. "/rating", function(body, response, err)
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
			callback(nil, response, body and body.error or "Could not load your creation rating.")
			return
		end
		if type(body) ~= "table" or not FiniteNumber(body.rating_average or 0)
		   or not IntegerAtLeast(body.rating_count or 0, 0) or not IntegerAtLeast(body.your_rating or 0, 0)
		   or (body.your_rating or 0) > 5 then
			callback(nil, response, "Creation rating response is malformed.")
			return
		end
		callback({
			rating_average = body.rating_average or 0,
			rating_count = body.rating_count or 0,
			your_rating = body.your_rating or 0,
			can_rate = body.can_rate ~= false,
		}, response, nil)
	end, AuthToken())
end

function CommunityApi.SetRating(creationId, rating, callback)
	if not PublicCreationId(creationId) then
		callback(nil, nil, "Invalid community creation ID.")
		return false
	end
	if not CommunityAccount.IsSignedIn() then
		callback(nil, nil, "Sign in to rate Community creations.")
		return false
	end
	if not IntegerAtLeast(rating, 0) or rating > 5 then
		callback(nil, nil, "Rating must be from 0 to 5.")
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/creations/" .. creationId .. "/rating", { rating = rating }, function(body, response, err)
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
			callback(nil, response, body and body.error or "Could not save creation rating.")
			return
		end
		if type(body) ~= "table" or not FiniteNumber(body.rating_average or 0)
		   or not IntegerAtLeast(body.rating_count or 0, 0) or not IntegerAtLeast(body.your_rating or 0, 0)
		   or (body.your_rating or 0) > 5 then
			callback(nil, response, "Creation rating response is malformed.")
			return
		end
		callback({ rating_average = body.rating_average or 0, rating_count = body.rating_count or 0, your_rating = body.your_rating or 0 }, response, nil)
	end, AuthToken())
end

function CommunityApi.RecordLoad(creationId, callback)
	if not PublicCreationId(creationId) then
		callback(nil, nil, "Invalid community creation ID.")
		return false
	end
	return CommunityTransport.PostJSON("/api/v1/creations/" .. creationId .. "/load", {}, function(body, response, err)
		if err then
			callback(nil, response, err)
			return
		end
		if not response or response.status ~= 200 then
			callback(nil, response, body and body.error or "Could not record creation load.")
			return
		end
		callback(body, response, nil)
	end)
end
