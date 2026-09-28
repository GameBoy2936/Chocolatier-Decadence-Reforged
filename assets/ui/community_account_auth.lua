--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Community Account Sign In)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/account.lua")
require("community/identity.lua")
require("ui/hiscore_countries.lua")
ClearStringCache()

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local context = gDialogTable or {}
local mode = context.mode == "register" and "register" or "signin"
local suggested = CommunityIdentity.GetSuggested()
gCommunityAuth = { nationality = suggested.nationality or "" }

local headerFont = { labelFontName, 24, MaroonColor }
local labelFont = { standardFont, 14.5, BlackColor }
local helpFont = { standardFont, 11.5, BlackColor }
local statusFont = { standardFont, 12.5, MaroonColor }
local ruleColor = Color(116, 82, 54, 60)

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function RefreshFlag()
	gCommunityProfilePreviewNationality = gCommunityAuth.nationality or ""
	FillWindow("community_auth_flag_preview", "ui/community_profile_preview.lua")
end
local function ChooseFlag()
	local result = DisplayDialog { "ui/hiscore_nationality.lua", selected = gCommunityAuth.nationality }
	if result ~= nil and result ~= "cancel" then
		gCommunityAuth.nationality = result
		RefreshFlag()
	end
end

local function SetBusy(busy)
	EnableWindow("community_auth_submit", not busy)
	EnableWindow("community_auth_cancel", not busy)
end

local function Submit()
	if CommunityTransport.IsBusy() then
		SetLabel("community_auth_status", GetString("community_cookbook_busy"))
		return
	end
	local login = GetLabel("community_auth_login") or ""
	local password = GetLabel("community_auth_password") or ""
	SetBusy(true)
	SetLabel("community_auth_status", GetString(mode == "register" and "community_account_creating" or "community_account_signing_in"))
	if mode == "register" then
		local publicName = GetLabel("community_auth_public_name") or ""
		local initialProfile =
		{
			public_name = publicName, nationality = gCommunityAuth.nationality or "", gender = "",
			favorite_product = { kind = "", id = "", name = "" }, favorite_category = "",
			favorite_ingredient = { id = "", name = "" }, favorite_character = { id = "", name = "" }, favorite_port = { id = "", name = "" },
			bio = ""
		}
		CommunityAccount.Register(login, password, initialProfile, function(profile, response, err)
			if err then
				SetBusy(false)
				SetLabel("community_auth_status", GetTextParams("community_account_error", { tostring(err) }))
				return
			end
			CommunityIdentity.SyncPlayer()
			FadeCloseWindow("community_account_auth", "signed_in")
		end)
	else
		CommunityAccount.Login(login, password, function(profile, response, err)
			if err then
				SetBusy(false)
				SetLabel("community_auth_status", GetTextParams("community_account_error", { tostring(err) }))
				return
			end
			CommunityIdentity.SyncPlayer()
			FadeCloseWindow("community_account_auth", "signed_in")
		end)
	end
end

local function Entry(y, name, initial, length)
	return Bitmap { image = "image/entername", x = 46, y = y,
		TextEdit { typename = "TextEdit", utf8 = true, x = 0, y = 0, w = kMax, h = kMax,
			name = name, label = initial or "", font = labelFont, flags = kHAlignCenter + kVAlignCenter,
			clearinitial = false, length = length or 32 }
	}
end

local fields

if mode == "register" then
	fields = { BeginGroup(),
		Text { x = 48, y = 76, w = 405, h = 20, label = "#" .. GetString("community_account_login_name"), font = labelFont },
		Entry(98, "community_auth_login", "", 32),
		Text { x = 48, y = 139, w = 405, h = 20, label = "#" .. GetString("community_account_password"), font = labelFont },
		Entry(161, "community_auth_password", "", 128),
		Text { x = 50, y = 201, w = 401, h = 25, label = "#" .. GetString("community_account_password_visible_help"), font = helpFont, flags = kHAlignCenter + kVAlignTop },
		Rectangle { x = 48, y = 228, w = 406, h = 1, color = ruleColor },
		Text { x = 48, y = 239, w = 405, h = 20, label = "#" .. GetString("community_profile_public_name"), font = labelFont },
		Entry(261, "community_auth_public_name", suggested.public_name or "", 20),
		Text { x = 48, y = 303, w = 93, h = 22, label = "#" .. GetString("community_profile_flag"), font = labelFont, flags = kVAlignCenter },
		Window { name = "community_auth_flag_preview", x = 142, y = 299, w = 170, h = 30 },
		SetStyle(C3ButtonStyle),
		Button { x = 321, y = 300, label = "#" .. GetString("hiscore_choose_flag"), command = ChooseFlag },
	}
else
	fields = { BeginGroup(),
		Text { x = 48, y = 58, w = 405, h = 20, label = "#" .. GetString("community_account_login_name"), font = labelFont },
		Entry(78, "community_auth_login", CommunityAccount.GetLoginName(), 32),
		Text { x = 48, y = 117, w = 405, h = 20, label = "#" .. GetString("community_account_password"), font = labelFont },
		Entry(137, "community_auth_password", "", 128),
		Text { x = 50, y = 176, w = 401, h = 18, label = "#" .. GetString("community_account_password_visible_help"), font = helpFont, flags = kHAlignCenter + kVAlignCenter },
	}
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_account_auth", x = 1000, y = kCenter,
		image = mode == "register" and "image/popup_back_generic_tall" or "image/popup_back_generic_1",
		Text { x = 35, y = mode == "register" and 26 or 36, w = 432, h = 44,
			label = "#" .. GetString(mode == "register" and "community_account_create_header" or "community_account_signin_header"),
			font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Group(fields),
		Text { x = 45, y = mode == "register" and 349 or 189, w = 412, h = mode == "register" and 53 or 25, name = "community_auth_status",
			label = "#" .. GetString(mode == "register" and "community_account_register_help" or "community_account_login_help"),
			font = statusFont, flags = kHAlignCenter + kVAlignTop },
		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter - 88, y = mode == "register" and 417 or 237, name = "community_auth_submit",
			label = "#" .. GetString(mode == "register" and "community_account_create" or "community_account_sign_in"),
			default = true, command = Submit },
		Button { x = kCenter + 88, y = mode == "register" and 417 or 237, name = "community_auth_cancel", label = "cancel", cancel = true, command = function() FadeCloseWindow("community_account_auth", "cancel") end },
	}
}
if mode == "register" then
	RefreshFlag()
end
CenterFadeIn("community_account_auth")
QueueCommand(function() SetFocus("community_auth_login") end)
