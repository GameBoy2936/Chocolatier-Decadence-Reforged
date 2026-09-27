--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Community High-Score Submission Controller

	Controller-only module. The visible form is opened
	directly as ui/hiscore_submit.lua so nested nationality dialogs no longer
	sit behind an extra modal coroutine boundary.
---------------------------------------------------------------------------]]

require("ui/hiscore_countries.lua")
require("community/identity.lua")
require("community/scores.lua")

HighScoreSubmitController = HighScoreSubmitController or {}

-- RN1 carries nationality through the native score-submission name field.
local kNationalityEnvelopeMarker = "|RN1|"
local kAccountEnvelopeMarker = "|RA1|"

local function CleanPublicDisplayName(value)
	value = tostring(value or "")
	local markerStart = string.find(value, kNationalityEnvelopeMarker, 1, true)
	local accountStart = string.find(value, kAccountEnvelopeMarker, 1, true)
	if accountStart and (not markerStart or accountStart < markerStart) then markerStart = accountStart end
	if markerStart then value = string.sub(value, 1, markerStart - 1) end
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
end

function HighScoreSubmitController:Initialize()
	-- High Scores and Creations share the same Community Profile.
	local communityProfile = CommunityIdentity.Get()
	local defaultDisplayName = ""
	local selectedNationality = ""

	if CommunityIdentity.IsConfigured() then
		defaultDisplayName = CleanPublicDisplayName(communityProfile.public_name)
		selectedNationality = communityProfile.nationality or ""
	else
		-- Use the native name fields until a Community Profile is configured.
		defaultDisplayName = CleanPublicDisplayName(Player.highScoreDisplayName)
		if defaultDisplayName == "" then
			defaultDisplayName = CleanPublicDisplayName(gNameEdit)
		end
		if defaultDisplayName == "" then
			defaultDisplayName = CleanPublicDisplayName(Player.name)
		end
		selectedNationality = Player.highScoreNationality or ""
	end

	if not HighScoreCountries:IsValid(selectedNationality) then
		selectedNationality = ""
	end

	local integrityStatus = Player:GetIntegrityStatus()
	local integrityKey = "hiscore_integrity_legacy"
	if integrityStatus == "ranked" then
		integrityKey = "hiscore_integrity_ranked"
	elseif integrityStatus == "unranked_dev" then
		integrityKey = "hiscore_integrity_dev"
	end

	gHighScoreSubmit = {
		displayName = defaultDisplayName,
		nationality = selectedNationality,
		integrityKey = integrityKey,
		ranked = Player:IsRankedEligible(),
	}

	-- Bind the active submit-dialog callbacks.
	gHighScoreSubmit.RefreshNationality = function()
		HighScoreSubmitController:RefreshNationality()
	end
	gHighScoreSubmit.ChooseNationality = function()
		HighScoreSubmitController:ChooseNationality()
	end
	gHighScoreSubmit.Submit = function()
		HighScoreSubmitController:SubmitCurrentScore()
	end
end

function HighScoreSubmitController:RefreshNationality()
	if not gHighScoreSubmit then return end
	FillWindow("nationalitypreview", "ui/hiscore_submit_preview.lua")
end

function HighScoreSubmitController:ChooseNationality()
	if not gHighScoreSubmit then return end

	local result = DisplayDialog {
		"ui/hiscore_nationality.lua",
		selected = gHighScoreSubmit.nationality,
	}

	if result ~= nil and result ~= "cancel" then
		gHighScoreSubmit.nationality = result
		self:RefreshNationality()
	end

	SetFocus("nameedit")
end

function HighScoreSubmitController:SubmitCurrentScore()
	if not gHighScoreSubmit then return end

	-- New Community scores require a signed-in account.
	if not (CommunityAccount and CommunityAccount.IsSignedIn and CommunityAccount.IsSignedIn()) then
		FadeCloseWindow("hiscoresubmitpanel", "account_required")
		return
	end

	if CommunityTransport.IsBusy() then
		DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_score_request_busy") }
		return
	end

	-- Request ownership before committing the pending score locally.
	SwitchModes(true)
	CommunityScores.RequestTicket(function(ticket, response, err)
		if err or not ticket then
			SwitchModes(false)
			if response and response.status == 401 then
				FadeCloseWindow("hiscoresubmitpanel", "account_required")
				return
			end
			DisplayDialog { "ui/ui_generic.lua", text = "#" .. tostring(err or GetString("community_score_ticket_failed")) }
			return
		end

		if not CommunityAccount.IsSignedIn() then
			SwitchModes(false)
			FadeCloseWindow("hiscoresubmitpanel", "account_required")
			return
		end

		-- Use the profile returned with the fresh ownership ticket.
		local profile = CommunityAccount.GetProfile() or {}
		local name = CleanPublicDisplayName(profile.public_name or "")
		local nationality = tostring(profile.nationality or "")
		if name == "" then
			SwitchModes(false)
			DisplayDialog { "ui/ui_generic.lua", text = "#" .. GetString("community_score_account_profile_invalid") }
			FadeCloseWindow("hiscoresubmitpanel", "account_required")
			return
		end

		Player.highScoreDisplayName = name
		Player.highScoreNationality = nationality
		Player:LogScore()
		Player:SaveGame()

		local submitName = name .. kAccountEnvelopeMarker .. ticket
		DebugOut("HISCORE", string.format(
			"Submitting account-owned Reforged score for Community profile: %s", name
		))
		SubmitToServer(submitName, "", "", false, gMedalsMode)
	end)
end

function HighScoreSubmitController:Cleanup()
	gHighScoreSubmit = nil
end

-- SubmitWindow calls this global while changing native controller states.
function SwitchModes(submit)
	local editing = not submit
	local accountIdentityLocked = CommunityAccount and CommunityAccount.IsSignedIn and CommunityAccount.IsSignedIn()

	EnableWindow("submitcontent", editing)
	EnableWindow("nameeditbox", editing and gMedalsMode == false and not accountIdentityLocked)
	EnableWindow("nationalitypreview", editing and gMedalsMode == false)
	EnableWindow("nationalitychoose", editing and gMedalsMode == false and not accountIdentityLocked)
	EnableWindow("submittoserver", editing)
	EnableWindow("submitcancel", editing)
	EnableWindow("submitconnect", submit)

	if editing and gMedalsMode == false then
		QueueCommand(function() SetFocus("nameedit") end)
	end
end
