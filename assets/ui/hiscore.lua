--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (High Score Viewer)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
	Reforged Community score browser.
---------------------------------------------------------------------------]]

require("ui/hiscore_countries.lua")
require("community/account.lua")
ClearStringCache()
Player:LogScore()

-------------------------------------------------------------------------------
-- Typography
-------------------------------------------------------------------------------

local titleFont = { standardFont, 27, BlackColor }
local categoryFont = { labelFontName, 15.5, MaroonColor }
local columnFont = { standardFont, 12, MaroonColor }
local rankFont = { standardFont, 14.5, BlackColor }
local playerFont = { standardFont, 16, BlackColor }
local selectedPlayerFont = { standardFont, 16, MaroonColor }
local runInfoFont = { standardFont, 11.5, BlackColor }
local scoreFont = { standardFont, 17, BlackColor }
local selectedScoreFont = { standardFont, 17, MaroonColor }
local currentMarkerFont = { labelFontName, 14, MaroonColor }
local panelTitleFont = { labelFontName, 19, MaroonColor }
local panelBodyFont = { standardFont, 14, BlackColor }
local panelNameFont = { standardFont, 18, BlackColor }
local panelScoreFont = { standardFont, 25, MaroonColor }
local panelMetaFont = { standardFont, 13.5, BlackColor }
local integrityFont = { labelFontName, 14, MaroonColor }
local statusFont = { standardFont, 17, BlackColor }
local panelStatusFont = { standardFont, 15.5, BlackColor }
local ruleColor = Color(116, 82, 54, 70)

local scrollUpGraphics = {
	"image/button_arrow_up_up",
	"image/button_arrow_up_down",
	"image/button_arrow_up_over"
}

local scrollDownGraphics = {
	"image/button_arrow_down_up",
	"image/button_arrow_down_down",
	"image/button_arrow_down_over"
}

local detailArrowGraphics = {
	"image/button_arrow_right_up",
	"image/button_arrow_right_down",
	"image/button_arrow_right_over"
}

local transparentButtonGraphics = {
	"image/reforged_transparent",
	"image/reforged_transparent",
	"image/reforged_transparent"
}

local kRowFlagScale = 0.20
local kPanelFlagScale = 0.26

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

local kListLeft = 24
local kListRight = 460
local kRankX = 24
local kMarkerX = 55
local kFlagX = 70
local kNameX = 108
local kScoreX = 336
local kDetailX = 444
local kHeaderY = 104
local kFirstRowY = 125
local kScoreRowSpace = 29
local kRightPanelX = 477
local kRightPanelW = 289

-------------------------------------------------------------------------------
-- Native Controller States
-------------------------------------------------------------------------------

local eLocalView = 0
local eRequestingCategories = 1
local eRequestingScores = 2
local eSubmitting = 3
local eGlobalView = 4
local eError = 5

local function IntegrityLabelKey()
	local status = Player:GetIntegrityStatus()
	if status == "ranked" then
		return "hiscore_integrity_ranked"
	elseif status == "unranked_dev" then
		return "hiscore_integrity_dev"
	elseif status == "unranked_freeplay" then
		return "hiscore_integrity_freeplay"
	else
		return "hiscore_integrity_legacy"
	end
end

local function IntegrityDisplayText()
	local text = GetString("hiscore_integrity_label") .. " " .. GetString(IntegrityLabelKey())
	-- Some older/localized strings carried a dangling separator. Never show it.
	text = string.gsub(text, "%s*%-%s*$", "")
	return text
end

-------------------------------------------------------------------------------
-- Community Score Metadata
-------------------------------------------------------------------------------

local remoteRows = {}
local rowDisplayData = {}
local selectedCommunityRow = nil
local selectedStatusOverride = nil
local lastBoardFingerprint = ""
local kRemotePrefixV1 = "|RF1|"
local kRemotePrefixV2 = "|R2"
local kRemoteProfileMarker = "|P"
local kBase36 = "0123456789abcdefghijklmnopqrstuvwxyz"

-- RF1 remains readable; RF2 is the compact format used by current servers.
local remoteFieldNamesV1 = {
	"companyScore", "companyValue", "money", "week", "rank", "difficulty",
	"casesMade", "casesSold", "factories", "shops", "portsVisited",
	"recipesKnown", "recipesMade", "customRecipes", "medals", "earningsPace",
	"highestCash", "lifetimeRevenue", "lifetimeSpend", "ingredientValue",
	"productValue", "machineryValue", "salesRevenue", "specialOrderRevenue",
	"questsCompleted", "specialOrdersCompleted", "specialOrdersFailed",
	"largestSale", "largestSpecialOrder", "salesTransactions", "travelTrips",
	"ingredientSpend", "travelSpend", "machinerySpend", "factorySpend",
	"trackingStartedWeek", "valuePoints", "commercePoints", "expansionPoints",
	"masteryPoints", "progressionPoints", "efficiencyPoints", "baseScore",
	"multiplierPercent", "statsLegacyBaseline"
}

local remoteFieldNamesV2 = {
	"money", "week", "rank", "casesMade", "casesSold", "factories", "shops",
	"portsVisited", "recipesKnown", "recipesMade", "customRecipes", "medals",
	"ingredientValue", "productValue", "machineryValue",
	"specialOrdersCompleted", "specialOrdersFailed", "specialOrderRevenue", "salesTransactions"
}

local function SplitPacked(value, separator)
	local parts = {}
	local start = 1
	while true do
		local a, b = string.find(value, separator, start, true)
		if not a then
			table.insert(parts, string.sub(value, start))
			break
		end
		table.insert(parts, string.sub(value, start, a - 1))
		start = b + 1
	end
	return parts
end

local function Base36Value(value)
	if not value or value == "" then return nil end
	value = string.lower(value)
	local result = 0
	for i = 1, string.len(value) do
		local char = string.sub(value, i, i)
		local at = string.find(kBase36, char, 1, true)
		if not at then return nil end
		result = (result * 36) + (at - 1)
	end
	return result
end

local function ParseDisplayedScore(rawScore)
	local digits = string.gsub(rawScore or "", "[^0-9%-]", "")
	return tonumber(digits) or 0
end

local function ValidProfileId(value)
	value = tostring(value or "")
	return string.len(value) == 27 and string.find(value, "^cp_[0-9a-f]+$") ~= nil
end

local function IntegrityFromCode(code)
	if code == "R" then return "ranked" end
	if code == "D" then return "unranked_dev" end
	return "legacy_unverified"
end

local function FinishCompactSnapshot(snapshot, scoreValue)
	snapshot.companyScore = scoreValue or 0
	snapshot.campaignMode = snapshot.campaignMode or "story"
	snapshot.companyValue = (snapshot.money or 0) + (snapshot.ingredientValue or 0) + (snapshot.productValue or 0) + (snapshot.machineryValue or 0)
	snapshot.earningsPace = 0
	if (snapshot.week or 0) > 0 then snapshot.earningsPace = Floor((snapshot.money or 0) / snapshot.week) end

	snapshot.valuePoints = Floor((snapshot.companyValue or 0) / 100)
	snapshot.commercePoints = Floor(((snapshot.casesMade or 0) * 0.5) + (snapshot.casesSold or 0))
	snapshot.expansionPoints = Floor(((snapshot.factories or 0) * 12000) + ((snapshot.shops or 0) * 8000) + ((snapshot.portsVisited or 0) * 750))
	snapshot.progressionPoints = 0
	snapshot.operationsPoints = 0
	if snapshot.campaignMode == "free" then
		local creationCount = snapshot.customRecipes or 0
		if creationCount > 20 then creationCount = 20 end
		snapshot.masteryPoints = Floor(((snapshot.recipesMade or 0) * 500) + (creationCount * 750))
		snapshot.operationsPoints = Floor((snapshot.specialOrdersCompleted or 0) * 2500)
	else
		snapshot.masteryPoints = Floor(((snapshot.recipesKnown or 0) * 150) + ((snapshot.recipesMade or 0) * 300) + ((snapshot.customRecipes or 0) * 1500) + ((snapshot.medals or 0) * 2500))
		snapshot.progressionPoints = Floor((snapshot.rank or 1) * 4000)
	end
	snapshot.efficiencyPoints = Floor((snapshot.earningsPace or 0) / 2)
	if snapshot.efficiencyPoints > 75000 then snapshot.efficiencyPoints = 75000 end
	snapshot.baseScore = snapshot.valuePoints + snapshot.commercePoints + snapshot.expansionPoints + snapshot.masteryPoints + snapshot.progressionPoints + snapshot.operationsPoints + snapshot.efficiencyPoints

	local multiplierPercent = 100
	if snapshot.difficulty == 2 then multiplierPercent = 110 end
	if snapshot.difficulty == 3 then multiplierPercent = 125 end
	snapshot.multiplierPercent = multiplierPercent
	snapshot.difficultyMultiplier = multiplierPercent / 100
	snapshot.snapshotVersion = 1
	snapshot.scoreVersion = 1
	snapshot.remoteCompact = true
	return snapshot
end

local function DecodeCommunityNameV2(value, scoreValue)
	local markerStart = string.find(value, kRemotePrefixV2, 1, true)
	if not markerStart then return nil end

	local publicName = string.sub(value, 1, markerStart - 1)
	local tail = string.sub(value, markerStart + string.len(kRemotePrefixV2))
	local result = { name = publicName, nationality = "", difficulty = 1, integrityStatus = "legacy_unverified" }

	-- Keep the fixed header readable if the native name buffer truncates the tail.
	if string.len(tail) < 4 then return result end
	local iso = string.sub(tail, 1, 2)
	local country = HighScoreCountries:GetByISO(iso)
	if country then result.nationality = country.code end
	result.difficulty = tonumber(string.sub(tail, 3, 3)) or 1
	result.integrityStatus = IntegrityFromCode(string.sub(tail, 4, 4))
	result.campaignMode = (string.sub(tail, 5, 5) == "F") and "free" or "story"

	local payloadStart = string.find(tail, "|", 5, true)
	if not payloadStart then return result end
	local payload = string.sub(tail, payloadStart + 1)

	-- Newer servers may append a stable Community Profile ID after the compact
	-- score payload:  |Pcp_<24 hex>.  Keep RF2 fully backward compatible.
	local profileMarker = string.find(payload, kRemoteProfileMarker, 1, true)
	if profileMarker then
		local profileId = string.sub(payload, profileMarker + string.len(kRemoteProfileMarker))
		if ValidProfileId(profileId) then result.profileId = profileId end
		payload = string.sub(payload, 1, profileMarker - 1)
	end

	local numbers = SplitPacked(payload, ".")
	-- RF2 originally carried 15 numeric fields. Newer servers append Free Play
	-- operations fields, but old rows must remain fully readable.
	if table.getn(numbers) < 15 then return result end

	local snapshot = {
		difficulty = result.difficulty,
		nationality = result.nationality,
		campaignMode = result.campaignMode or "story",
	}
	for i, fieldName in ipairs(remoteFieldNamesV2) do
		if numbers[i] then
			local decoded = Base36Value(numbers[i])
			if decoded == nil then return result end
			snapshot[fieldName] = decoded
		else
			snapshot[fieldName] = 0
		end
	end
	result.snapshot = FinishCompactSnapshot(snapshot, scoreValue)
	return result
end

local function DecodeCommunityNameV1(value)
	local markerStart = string.find(value, kRemotePrefixV1, 1, true)
	if not markerStart then return nil end

	local publicName = string.sub(value, 1, markerStart - 1)
	local packed = string.sub(value, markerStart + string.len(kRemotePrefixV1))
	local parts = SplitPacked(packed, "|")
	local result = { name = publicName }
	local nationality = parts[1] or ""
	if nationality ~= "" and HighScoreCountries:IsValid(nationality) then result.nationality = nationality else result.nationality = "" end
	result.integrityStatus = parts[2] or "legacy_unverified"
	if parts[5] and string.sub(parts[5], 1, 1) == "P" then
		local profileId = string.sub(parts[5], 2)
		if ValidProfileId(profileId) then result.profileId = profileId end
	end
	local snapshotVersion = tonumber(parts[3]) or 0
	if table.getn(parts) < 4 then return result end
	local numbers = SplitPacked(parts[4] or "", ",")
	if table.getn(numbers) < table.getn(remoteFieldNamesV1) then return result end

	local snapshot = { snapshotVersion = snapshotVersion, scoreVersion = 1, nationality = result.nationality, campaignMode = "story" }
	for i, fieldName in ipairs(remoteFieldNamesV1) do
		local raw = tonumber(numbers[i]) or 0
		if fieldName == "statsLegacyBaseline" then snapshot[fieldName] = raw ~= 0 else snapshot[fieldName] = raw end
	end
	snapshot.difficultyMultiplier = (snapshot.multiplierPercent or 100) / 100
	result.difficulty = snapshot.difficulty
	result.snapshot = snapshot
	return result
end

local function DecodeCommunityName(value, rawScore)
	if not value or value == "" then return nil end
	local scoreValue = ParseDisplayedScore(rawScore)
	local decoded = DecodeCommunityNameV2(value, scoreValue)
	if decoded then return decoded end
	return DecodeCommunityNameV1(value)
end

local function DifficultyMarkup(difficulty)
	difficulty = tonumber(difficulty) or 0
	if difficulty < 1 or difficulty > 3 then return "" end
	local color = "2e8b57"
	if difficulty == 2 then color = "c88700" end
	if difficulty == 3 then color = "c62828" end
	local name = GetString(HighScoreModel:DifficultyNameKey(difficulty))
	return "<font color=\"" .. color .. "\"><b>" .. name .. "</b></font>"
end

local function FormatRunInfo(info, difficulty)
	if not info or info == "" then return "" end
	local difficultyText = DifficultyMarkup(difficulty)
	if difficultyText == "" then return info end
	return info .. "  •  " .. difficultyText
end

local function OpenRemoteDetails(index)
	local remote = remoteRows[index]
	if not remote or not remote.snapshot then
		DisplayDialog { "ui/ui_generic.lua", text = "hiscore_remote_details_unavailable" }
		return
	end
	DisplayDialog {
		"ui/hiscore_details.lua",
		snapshot = remote.snapshot,
		publicName = remote.name,
		nationality = remote.nationality,
		integrityStatus = remote.integrityStatus,
		compactRemote = remote.snapshot.remoteCompact and true or false,
	}
end

local function RemoteProfileId(remote)
	if remote and ValidProfileId(remote.profileId) then
		return remote.profileId
	end

	-- Legacy Community rows predate profile IDs in the native leaderboard
	-- envelope.  We can still resolve the signed-in player's own row exactly.
	local profile = CommunityAccount and CommunityAccount.GetProfile and CommunityAccount.GetProfile() or nil
	if remote and profile and tostring(remote.name or "") == tostring(profile.public_name or "")
	   and ValidProfileId(profile.profile_id) then
		return profile.profile_id
	end
	return ""
end

local function OpenSelectedProfile()
	if GetState() ~= eGlobalView or not selectedCommunityRow then return end
	local profileId = RemoteProfileId(remoteRows[selectedCommunityRow])
	if profileId == "" then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_public_profile_unavailable") }
		return
	end
	DisplayDialog { "ui/community_public_profile.lua", profile_id = profileId }
end

local function FirstPopulatedRow()
	for i = 1, 10 do
		if rowDisplayData[i] and rowDisplayData[i].displayName ~= "" then return i end
	end
	return nil
end

local function CurrentPlayerRow()
	local activePublicName = Player.highScoreDisplayName or ""
	local activeProfileName = Player.name or ""
	for i = 1, 10 do
		local row = rowDisplayData[i]
		if row and (row.displayName == activePublicName or row.displayName == activeProfileName) then
			return i
		end
	end
	return nil
end

local function RefreshSelectionStyles()
	local globalView = GetState() == eGlobalView
	for i = 1, 10 do
		local suffix = tostring(i)
		local row = rowDisplayData[i]
		local selected = globalView and selectedCommunityRow == i and row and row.displayName ~= ""
		local displayName = row and row.displayName or ""
		local displayScore = row and row.displayScore or ""

		if selected then
			SetLabel("playerdisplay" .. suffix, "")
			SetLabel("playerselected" .. suffix, displayName)
			SetLabel("scoredisplay" .. suffix, "")
			SetLabel("scoreselected" .. suffix, displayScore)
		else
			SetLabel("playerdisplay" .. suffix, displayName)
			SetLabel("playerselected" .. suffix, "")
			SetLabel("scoredisplay" .. suffix, displayScore)
			SetLabel("scoreselected" .. suffix, "")
		end
	end
end

local function UpdateSelectedPanel()
	if GetState() ~= eGlobalView then return end

	local row = selectedCommunityRow and rowDisplayData[selectedCommunityRow] or nil
	local remote = selectedCommunityRow and remoteRows[selectedCommunityRow] or nil

	if not row or row.displayName == "" then
		SetLabel("selectedempty", GetString("hiscore_selected_none"))
		SetLabel("selectedname", "")
		SetLabel("selectedscore", "")
		SetLabel("selectedinfo", "")
		SetLabel("selectedcountry", "")
		SetBitmap("selectedflag", "", kPanelFlagScale)
		EnableWindow("scoredetails", false)
		EnableWindow("viewprofile", false)
		return
	end

	SetLabel("selectedempty", "")
	SetLabel("selectedname", row.displayName)
	SetLabel("selectedscore", row.displayScore)
	SetLabel("selectedinfo", row.info)

	if remote and remote.nationality and remote.nationality ~= "" and HighScoreCountries:IsValid(remote.nationality) then
		SetBitmap("selectedflag", HighScoreCountries:GetFlag(remote.nationality), kPanelFlagScale)
		SetLabel("selectedcountry", HighScoreCountries:GetName(remote.nationality))
	else
		SetBitmap("selectedflag", "", kPanelFlagScale)
		SetLabel("selectedcountry", "")
	end

	EnableWindow("scoredetails", remote ~= nil and remote.snapshot ~= nil)
	EnableWindow("viewprofile", RemoteProfileId(remote) ~= "")
end

local function UpdateSelectedStatus()
	SetLabel("selectedstatus", selectedStatusOverride or GetString("hiscore_browse_hint"))
end

local function SelectCommunityRow(index)
	if GetState() ~= eGlobalView then return end
	local row = rowDisplayData[index]
	if not row or row.displayName == "" then return end
	selectedCommunityRow = index
	selectedStatusOverride = nil
	RefreshSelectionStyles()
	UpdateSelectedPanel()
end

local function OpenMyCommunityScores()
	if CommunityAccount and CommunityAccount.IsSignedIn and CommunityAccount.IsSignedIn() then
		DisplayDialog { "ui/community_scores.lua" }
		return
	end

	local result = DisplayDialog { "ui/community_account_menu.lua" }
	if result == "signed_in" and CommunityAccount.IsSignedIn() then
		DisplayDialog { "ui/community_scores.lua" }
	end
end

local function EnsureCommunityAccountForScore()
	if CommunityAccount and CommunityAccount.IsSignedIn and CommunityAccount.IsSignedIn() then return true end
	local result = DisplayDialog { "ui/community_score_account_required.lua" }
	return result == "signed_in" and CommunityAccount.IsSignedIn()
end

local function SubmitCommunityScore()
	-- Keep the pending score while the player signs in or renews an expired session.
	while true do
		if not EnsureCommunityAccountForScore() then return end
		local vars = loadstring(GetLuaServerSubmitSetupVars(false))
		if type(vars) ~= "function" then
			DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_score_setup_failed") }
			return
		end
		vars()
		local val = DoModal("ui/hiscore_submit.lua")
		if HighScoreSubmitController and HighScoreSubmitController.Cleanup then
			HighScoreSubmitController:Cleanup()
		end
		if val == "qualified" then
			SubmissionDone(true)
			selectedStatusOverride = GetString("congratshighscore")
			UpdateSelectedStatus()
			return
		elseif val == "success" then
			SubmissionDone(false)
			selectedStatusOverride = GetString("scorednq")
			UpdateSelectedStatus()
			return
		elseif val ~= "account_required" then
			return
		end
		-- Reopen the account gate when the score ticket session expires.
	end
end

local function OpenSelectedDetails()
	if GetState() == eGlobalView then
		if selectedCommunityRow then
			OpenRemoteDetails(selectedCommunityRow)
		else
			DisplayDialog { "ui/ui_generic.lua", text = "hiscore_remote_details_unavailable" }
		end
	else
		DoModal("ui/hiscore_details.lua")
	end
end

-------------------------------------------------------------------------------
-- Company Score Display
-------------------------------------------------------------------------------

local function UpdateCompanyScoreLabels()
	local categoryName = GetLabel("category") or ""
	local legacyNames = {
		["Legacy Scores"] = true,
		["Scores historiques"] = true,
	}
	local legacyBoard = legacyNames[categoryName] or false
	local globalView = GetState() == eGlobalView
	local activePublicName = Player.highScoreDisplayName or ""
	local activeProfileName = Player.name or ""
	local fingerprintParts = { categoryName }

	if legacyBoard then
		SetLabel("scoreheader", GetString("hiscore_legacy_score_column"))
	else
		SetLabel("scoreheader", GetString("hiscore_company_score_column"))
	end

	for i = 1, 10 do
		local suffix = tostring(i)
		local nativeName = GetLabel("name" .. suffix) or ""
		local rawScore = GetLabel("score" .. suffix) or ""
		local info = GetLabel("info" .. suffix) or ""
		local displayName = nativeName
		local remote = nil

		if nativeName ~= "" and globalView then
			remote = DecodeCommunityName(nativeName, rawScore)
			if remote then displayName = remote.name end
		end
		remoteRows[i] = remote

		local displayScore = ""
		if nativeName ~= "" then
			if legacyBoard then
				displayScore = rawScore
			else
				local digits = string.gsub(rawScore, "[^0-9%-]", "")
				local value = tonumber(digits)
				if value then displayScore = HighScoreModel:FormatNumber(value) end
			end
		end

		local displayInfo = FormatRunInfo(info, remote and remote.difficulty or nil)
		rowDisplayData[i] = {
			displayName = displayName,
			displayScore = displayScore,
			info = displayInfo,
			difficulty = remote and remote.difficulty or nil,
		}

		SetLabel("infodisplay" .. suffix, displayInfo)

		if remote and remote.nationality and remote.nationality ~= "" and HighScoreCountries:IsValid(remote.nationality) then
			SetBitmap("rowflag" .. suffix, HighScoreCountries:GetFlag(remote.nationality), kRowFlagScale)
		else
			SetBitmap("rowflag" .. suffix, "", kRowFlagScale)
		end

		if remote and remote.snapshot then
			SetBitmap("rowdetailicon" .. suffix, "image/button_arrow_right_up", 0.23)
			EnableWindow("rowdetails" .. suffix, true)
		else
			SetBitmap("rowdetailicon" .. suffix, "", 0.23)
			EnableWindow("rowdetails" .. suffix, false)
		end

		EnableWindow("rowselect" .. suffix, globalView and displayName ~= "")

		if displayName ~= "" and (displayName == activePublicName or displayName == activeProfileName) then
			SetLabel("currentmarker" .. suffix, ">")
		else
			SetLabel("currentmarker" .. suffix, "")
		end

		table.insert(fingerprintParts, nativeName)
		table.insert(fingerprintParts, rawScore)
	end

	local fingerprint = table.concat(fingerprintParts, "\001")
	if not globalView then
		selectedCommunityRow = nil
		lastBoardFingerprint = ""
	elseif fingerprint ~= lastBoardFingerprint then
		selectedCommunityRow = CurrentPlayerRow() or FirstPopulatedRow()
		selectedStatusOverride = nil
		lastBoardFingerprint = fingerprint
	elseif selectedCommunityRow and (not rowDisplayData[selectedCommunityRow] or rowDisplayData[selectedCommunityRow].displayName == "") then
		selectedCommunityRow = CurrentPlayerRow() or FirstPopulatedRow()
	end

	RefreshSelectionStyles()
	if globalView then UpdateSelectedPanel() end
end

-------------------------------------------------------------------------------
-- Native Row Refresh
-------------------------------------------------------------------------------

local function ClearScoreRows()
	for i = 1, 10 do
		local suffix = tostring(i)
		SetLabel("name" .. suffix, "")
		SetLabel("score" .. suffix, "")
		SetLabel("info" .. suffix, "")
		SetLabel("playerdisplay" .. suffix, "")
		SetLabel("playerselected" .. suffix, "")
		SetLabel("scoredisplay" .. suffix, "")
		SetLabel("scoreselected" .. suffix, "")
		SetLabel("infodisplay" .. suffix, "")
		SetLabel("currentmarker" .. suffix, "")
		SetBitmap("rowflag" .. suffix, "", kRowFlagScale)
		SetBitmap("rowdetailicon" .. suffix, "", 0.20)
		EnableWindow("rowdetails" .. suffix, false)
		EnableWindow("rowselect" .. suffix, false)
		remoteRows[i] = nil
		rowDisplayData[i] = nil
	end
	selectedCommunityRow = nil
	selectedStatusOverride = nil
	lastBoardFingerprint = ""
end

local lastControllerState = nil

function UpdateButtons()
	local state = GetState()
	local localOnly = IsEnabled(kHiscoreLocalOnly)

	if state ~= lastControllerState then
		if state == eRequestingCategories or state == eRequestingScores then
			ClearScoreRows()
		end
		lastControllerState = state
	end

	EnableWindow("view", false)
	EnableWindow("viewlocal", false)
	EnableWindow("submit", false)
	EnableWindow("moreinfo", false)
	EnableWindow("communitymyscores", false)
	EnableWindow("viewprofile", false)
	EnableWindow("categoryleft", false)
	EnableWindow("categoryright", false)
	EnableWindow("scoredetails", state ~= eGlobalView)

	UpdateCompanyScoreLabels()

	if state == eLocalView then
		EnableWindow("scoredetails", true)
		EnableWindow("moreinfo", true)
		EnableWindow("communitymyscores", true)
		if not localOnly then
			EnableWindow("view", true)
			if ScoreAvailable() then EnableWindow("submit", true) end
		end
	elseif state == eGlobalView then
		EnableWindow("viewlocal", true)
		EnableWindow("moreinfo", true)
		EnableWindow("communitymyscores", true)
		EnableWindow("categoryleft", true)
		EnableWindow("categoryright", true)
		UpdateSelectedPanel()
		UpdateSelectedStatus()
	elseif state == eError then
		EnableWindow("viewlocal", true)
		EnableWindow("moreinfo", true)
		EnableWindow("communitymyscores", true)
	end
end

-------------------------------------------------------------------------------
-- Score Rows
-------------------------------------------------------------------------------

local function GenerateScoreSlot(index)
	local y = kFirstRowY + ((index - 1) * kScoreRowSpace)
	return Group {
		Text {
			x = kRankX, y = y, w = 27, h = 17,
			name = tostring(index), label = "#" .. tostring(index) .. ".",
			font = rankFont, flags = kHAlignRight + kVAlignTop
		},
		Text {
			x = kMarkerX, y = y - 1, w = 13, h = 18,
			name = "currentmarker" .. index, label = "",
			font = currentMarkerFont, flags = kHAlignCenter + kVAlignCenter
		},

		-- Keep native name bindings offscreen; draw the public alias separately.
		Bitmap { x = -2000, y = y, name = "p1_" .. index, image = "hiscore/p1icon" },
		Text { x = -2000, y = y, w = 1, h = 1, name = "name" .. index, label = "" },
		Text { x = -2000, y = y, w = 1, h = 1, name = "score" .. index, label = "" },
		Text { x = -2000, y = y, w = 1, h = 1, name = "info" .. index, label = "" },

		Bitmap { x = kFlagX, y = y, name = "rowflag" .. index, image = "", scale = kRowFlagScale },

		Text {
			x = kNameX, y = y, w = 176, h = 18,
			name = "playerdisplay" .. index, label = "",
			font = playerFont, flags = kHAlignLeft + kVAlignTop
		},
		Text {
			x = kNameX, y = y, w = 176, h = 18,
			name = "playerselected" .. index, label = "",
			font = selectedPlayerFont, flags = kHAlignLeft + kVAlignTop
		},
		Text {
			x = kScoreX, y = y, w = 105, h = 18,
			name = "scoredisplay" .. index, label = "",
			font = scoreFont, flags = kHAlignRight + kVAlignTop
		},
		Text {
			x = kScoreX, y = y, w = 105, h = 18,
			name = "scoreselected" .. index, label = "",
			font = selectedScoreFont, flags = kHAlignRight + kVAlignTop
		},
		Text {
			x = kNameX, y = y + 16, w = kDetailX - kNameX - 7, h = 14,
			name = "infodisplay" .. index, label = "",
			font = runInfoFont, flags = kHAlignLeft + kVAlignTop
		},

		-- Full-row selection target.
		Button {
			x = kMarkerX + 12, y = y - 3, w = kDetailX - kMarkerX - 12, h = 28,
			name = "rowselect" .. index, graphics = transparentButtonGraphics, sound = "cadi/ui_click.ogg", type = kPush,
			command = function() SelectCommunityRow(index) end
		},

		-- Detail arrow.
		Bitmap { x = kDetailX, y = y - 3, name = "rowdetailicon" .. index, image = "", scale = 0.20 },
		Button {
			x = kDetailX - 2, y = y - 3, w = 15, h = 28, name = "rowdetails" .. index,
			graphics = transparentButtonGraphics, sound = "cadi/ui_click.ogg", type = kPush,
			command = function() OpenRemoteDetails(index) end
		},

		Rectangle { x = kRankX, y = y + 27, w = kListRight - kRankX, h = 1, color = ruleColor },
	}
end

-------------------------------------------------------------------------------
-- UI
-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x = 1000, y = 9, name = "hiscorescreen", fit = true,
		Bitmap
		{
			x = 0, y = 13, image = "image/popup_back_highscores",
			HiscoreWindow
			{
				x = 0, y = 0, h = kMax, w = kMax,

				Text { x = kListLeft + 10, y = 35, w = kListRight - kListLeft, h = 34, name = "local", label = "localhighscores", font = titleFont, flags = kVAlignCenter + kHAlignCenter },
				Text { x = kListLeft + 10, y = 35, w = kListRight - kListLeft, h = 34, name = "global", label = "globalhighscores", font = titleFont, flags = kVAlignCenter + kHAlignCenter },

				SetStyle(C3ButtonStyle),
				Button { name = "categoryleft", x = 24, y = 70, scale = 0.58, label = "previous" },
				Text { name = "category", x = 121, y = 71, w = 236, h = 28, font = categoryFont, flags = kHAlignCenter + kVAlignCenter },
				Button { name = "categoryright", x = 365, y = 70, scale = 0.58, label = "next" },

				Text { x = kRankX + 10, y = kHeaderY, w = 52, h = 16, label = "hiscore_rank_column", font = columnFont, flags = kHAlignLeft + kVAlignCenter },
				Text { x = kNameX, y = kHeaderY, w = 210, h = 16, label = "hiscore_player_column", font = columnFont, flags = kHAlignLeft + kVAlignCenter },
				Text { x = kScoreX - 20, y = kHeaderY, w = kListRight - kScoreX, h = 16, name = "scoreheader", label = "hiscore_company_score_column", font = columnFont, flags = kHAlignRight + kVAlignCenter },
				Rectangle { x = kRankX, y = 121, w = kListRight - kRankX, h = 1, color = ruleColor },

				GenerateScoreSlot(1), GenerateScoreSlot(2), GenerateScoreSlot(3), GenerateScoreSlot(4), GenerateScoreSlot(5),
				GenerateScoreSlot(6), GenerateScoreSlot(7), GenerateScoreSlot(8), GenerateScoreSlot(9), GenerateScoreSlot(10),

				-- Community score details.
				Window
				{
					x = kRightPanelX, y = 0, w = kRightPanelW, h = 291, name = "rightpanelsmall",
					Text { x = 22, y = 31, w = 245, h = 34, label = "hiscore_selected_score_header", font = panelTitleFont, flags = kVAlignCenter + kHAlignCenter },
					Rectangle { x = 33, y = 69, w = 223, h = 1, color = ruleColor },
					-- Empty-state copy mirrors the local-view globalhighscoreinfo treatment.
					Text { x = 27, y = 75, w = 235, h = 45, name = "selectedempty", label = "hiscore_selected_none", font = panelBodyFont, flags = kVAlignCenter + kHAlignCenter },
					Bitmap { x = 29, y = 81, name = "selectedflag", image = "", scale = kPanelFlagScale },
					Text { x = 79, y = 77, w = 174, h = 24, name = "selectedname", label = "", font = panelNameFont, flags = kVAlignCenter + kHAlignLeft },
					Text { x = 79, y = 101, w = 174, h = 30, name = "selectedscore", label = "", font = panelScoreFont, flags = kVAlignCenter + kHAlignLeft },
					Text { x = 31, y = 132, w = 227, h = 19, name = "selectedcountry", label = "", font = panelMetaFont, flags = kVAlignCenter + kHAlignCenter },
					Text { x = 31, y = 151, w = 227, h = 27, name = "selectedinfo", label = "", font = panelMetaFont, flags = kVAlignTop + kHAlignCenter },
					Rectangle { x = 33, y = 183, w = 223, h = 1, color = ruleColor },

					Text { x = 31, y = 191, w = 227, h = 38, name = "selectedstatus", label = "hiscore_browse_hint", font = panelStatusFont, flags = kVAlignCenter + kHAlignCenter },
					Text { x = 0, y = 0, w = 1, h = 1, name = "yourrank", label = "", font = panelMetaFont, flags = kVAlignTop + kHAlignLeft },
					Text { x = 0, y = 0, w = 1, h = 1, name = "congratulations", label = "", font = panelMetaFont, flags = kVAlignTop + kHAlignLeft },
					Text { x = 0, y = 0, w = 1, h = 1, name = "dnq", label = "", font = panelMetaFont, flags = kVAlignTop + kHAlignLeft },
				},

				-- Community service status.
				Window
				{
					x = kRightPanelX, y = 0, w = kRightPanelW, h = 291, name = "rightpanel",
					Text { x = 20, y = 34, w = 249, h = 34, name = "globalinfoheader", label = "hiscore_online_header", font = panelTitleFont, flags = kVAlignCenter + kHAlignCenter },
					Text { x = 27, y = 75, w = 235, h = 45, name = "info", label = "globalhighscoreinfo", font = panelBodyFont, flags = kVAlignTop + kHAlignCenter },
					Rectangle { x = 46, y = 124, w = 197, h = 1, color = ruleColor },
					Text { x = 27, y = 135, w = 235, h = 22, label = "#" .. IntegrityDisplayText(), font = integrityFont, flags = kVAlignTop + kHAlignCenter },
					Text { x = 27, y = 155, w = 235, h = 34, name = "eligible", label = "eligible", font = panelMetaFont, flags = kVAlignTop + kHAlignCenter },

					SetStyle(C3ButtonLongStyle),
					Button {
						x = 44, y = 191, name = "submit", label = "hiscore_submit_current",
						command = SubmitCommunityScore
					},

					Text { font = statusFont, name = "server", x = 24, y = 194, w = 241, h = 70, flags = kHAlignCenter + kVAlignCenter, label = "connectingtoserver" },
					Text { font = statusFont, name = "error", x = 24, y = 194, w = 241, h = 70, flags = kHAlignCenter + kVAlignCenter },
				},

				SetStyle(C3ButtonStyle),
				Button { x = 322, y = 416, name = "scrollup", sound = "cadi/ui_click.ogg", graphics = scrollUpGraphics, scale = 0.7 },
				Button { x = 382, y = 416, name = "scrolldown", sound = "cadi/ui_click.ogg", graphics = scrollDownGraphics, scale = 0.7 },

				-- Right-panel controls.
				SetStyle(C3ButtonMediumStyle),
				Button { x = 494, y = 236, scale = 0.72, name = "communitymyscores", label = "#" .. GetString("community_account_my_scores"), command = OpenMyCommunityScores },
				Button { x = 626, y = 236, scale = 0.72, name = "viewprofile", label = "#" .. GetString("community_view_profile"), command = OpenSelectedProfile },

				SetStyle(C3ButtonLongStyle),
				Button { x = 521, y = 301, name = "scoredetails", label = "hiscore_details_button", command = OpenSelectedDetails },
				Button { x = 521, y = 346, name = "moreinfo", label = "hiscore_info_button", command = function() DoModal("ui/hiscoreinfo.lua") end },

				SetStyle(C3ButtonLongStyle),
				Button { x = 521, y = 391, name = "viewlocal", label = "viewlocal" },
				Button { x = 521, y = 391, name = "view", label = "viewglobal" },
			}
		},

		Bitmap
		{
			image = "image/popup_nameplate", x = 223, y = 0,
			Text { x = 34, y = 10, w = 270, h = 38, label = "#" .. GetString("highscoreheader"), font = nameplateFont, flags = kVAlignCenter + kHAlignCenter },
		},

		SetStyle(C3RoundButtonStyle),
		Button { x = 704, y = 426, name = "ok", label = "ok", default = true, cancel = true, command = function() FadeCloseWindow("hiscorescreen", "ok") end },
	}
}

for i = 1, 10 do
	SetBitmap("rowflag" .. tostring(i), "", kRowFlagScale)
	SetBitmap("rowdetailicon" .. tostring(i), "", 0.20)
	EnableWindow("rowdetails" .. tostring(i), false)
	EnableWindow("rowselect" .. tostring(i), false)
end
SetBitmap("selectedflag", "", kPanelFlagScale)
SetLabel("selectedstatus", GetString("hiscore_browse_hint"))
QueueCommand(function() UpdateButtons() end)

CenterFadeIn("hiscorescreen")
