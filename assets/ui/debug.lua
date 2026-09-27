--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Debug Logging)
	Copyright (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Configuration
-------------------------------------------------------------------------------

-- Preserve the native engine logger once, before Reforged installs its wrapper.
if not gOriginalDebugOut then
	gOriginalDebugOut = DebugOut
end

local function SafeCheckConfig(key)
	if not CheckConfig then return false end

	local ok, result = pcall(function()
		return CheckConfig(key)
	end)

	return ok and result or false
end

-- Canonical logging categories used throughout Reforged. Keeping this list in
-- one place prevents runtime logs and the developer console from drifting.
gDebugCategories = {
	"BUILDING",
	"CATALOGUE",
	"CHAR",
	"COMMUNITY",
	"DEV",
	"DIALOGUE",
	"DIFFICULTY",
	"ECONOMY",
	"ERROR",
	"EVENT",
	"FACTORY",
	"FONT",
	"FREEPLAY",
	"GAMBLE",
	"GENERAL",
	"HAGGLE",
	"HINT",
	"HISCORE",
	"KITCHEN",
	"LOAD",
	"MIGRATION",
	"PLAYER",
	"PORT",
	"QUEST",
	"RECIPE",
	"SAVE",
	"SIM",
	"TIP",
	"TRAVEL",
	"TUTORIAL",
	"UI",
	"WARNING",
}

local gKnownDebugCategories = {}
for _, category in ipairs(gDebugCategories) do
	gKnownDebugCategories[category] = true
end

function IsDevModeEnabled()
	return SafeCheckConfig("dev")
		or SafeCheckConfig("debug")
		or SafeCheckConfig("cheat")
		or SafeCheckConfig("cheats")
		or SafeCheckConfig("console")
end

local function BuildDefaultDebugFilters()
	local filters = {}
	for _, category in ipairs(gDebugCategories) do
		filters[category] = true
	end
	return filters
end

gDebugEnabled = IsDevModeEnabled()
gDebugPayloadEnabled = SafeCheckConfig("debug_objects")
gDebugLogMaxEntries = 500

if gDebugEnabled then
	gDebugLog = gDebugLog or {}
	gDebugFilters = gDebugFilters or {
		searchTerm = "",
		categories = BuildDefaultDebugFilters(),
	}

	-- Add categories introduced by newer builds without discarding the player's
	-- current search/filter state from an already-open developer session.
	gDebugFilters.categories = gDebugFilters.categories or {}
	for _, category in ipairs(gDebugCategories) do
		if gDebugFilters.categories[category] == nil then
			gDebugFilters.categories[category] = true
		end
	end
else
	gDebugLog = nil
	gDebugFilters = nil
end

-------------------------------------------------------------------------------
-- Logging
-------------------------------------------------------------------------------

local function NormalizeDebugCategory(category)
	category = string.upper(tostring(category or "GENERAL"))
	if gKnownDebugCategories[category] then return category end
	return "GENERAL"
end

-- Reforged's single logging entry point. Routine diagnostics are emitted only
-- in developer sessions; WARNING and ERROR messages remain visible through the
-- native engine logger in release sessions so genuine faults are diagnosable.
function DebugOut(category, message, object)
	if message == nil then
		message = category
		category = "GENERAL"
	end

	category = NormalizeDebugCategory(category)
	message = tostring(message or "nil")

	local shouldEmitNative = gDebugEnabled or category == "WARNING" or category == "ERROR"
	if shouldEmitNative and gOriginalDebugOut then
		gOriginalDebugOut(string.format("[%s] %s", category, message))
	end

	if not gDebugEnabled then return end

	gDebugLog = gDebugLog or {}
	table.insert(gDebugLog, {
		timestamp = (Player and Player.time) or 0,
		category = category,
		message = message,
		object = gDebugPayloadEnabled and object or nil,
	})

	while table.getn(gDebugLog) > gDebugLogMaxEntries do
		table.remove(gDebugLog, 1)
	end
end
