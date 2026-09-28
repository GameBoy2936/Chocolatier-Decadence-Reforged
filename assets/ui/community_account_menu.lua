--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Community Account Menu)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/account.lua")
require("community/identity.lua")

ClearStringCache()

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local signedIn = CommunityAccount.IsSignedIn()
local headerFont = { labelFontName, 24, MaroonColor }
local bodyFont = { standardFont, 16, BlackColor }
local smallFont = { standardFont, 11, BlackColor }
local statusFont = { standardFont, 11.5, MaroonColor }
local ruleColor = Color(116, 82, 54, 60)
local contents = {}

-------------------------------------------------------------------------------
-- Account Actions
-------------------------------------------------------------------------------

local function SetBusy(busy)
	EnableWindow("community_account_menu_primary", not busy)
	EnableWindow("community_account_menu_secondary", not busy)
	EnableWindow("community_account_menu_cancel", not busy)
end

local function Authenticate(mode)
	local result = DisplayDialog { "ui/community_account_auth.lua", mode = mode }
	
	if result == "signed_in" and CommunityAccount.IsSignedIn() then
		CommunityIdentity.SyncPlayer()
		FadeCloseWindow("community_account_menu", "signed_in")
	end
end

local function EditProfile()
	local result = DisplayDialog { "ui/community_profile.lua" }
	
	if result == "saved" then
		CommunityIdentity.SyncPlayer()
		FadeCloseWindow("community_account_menu", "profile_saved")
	elseif result == "account_required" then
		FadeCloseWindow("community_account_menu", "signed_out")
	end
end

local function SignOut()
	local answer = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. GetString("community_account_signout_confirm") }
	if answer ~= "yes" then
		return
	end
	
	SetBusy(true)
	SetLabel("community_account_menu_status", GetString("community_account_signing_out"))
	
	CommunityAccount.Logout(function(ok, response, err)
		if not ok then
			SetBusy(false)
			SetLabel("community_account_menu_status", GetTextParams("community_account_error", { tostring(err or "Could not revoke the server session.") }))
			return
		end
		
		CommunityIdentity.SyncPlayer()
		FadeCloseWindow("community_account_menu", "signed_out")
	end)
end

-------------------------------------------------------------------------------
-- Menu Contents
-------------------------------------------------------------------------------

if signedIn then
	table.insert(contents, Text { x = 35, y = 40, w = 432, h = 36, label = "#" .. GetString("community_account_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter })
	table.insert(contents, Text { x = 54, y = 88, w = 394, h = 62, label = "#" .. GetTextParams("community_account_signed_in", { CommunityAccount.GetLoginName() }), font = bodyFont, flags = kHAlignCenter + kVAlignTop })
	table.insert(contents, Rectangle { x = 48, y = 143, w = 406, h = 1, color = ruleColor })
	
	table.insert(contents, SetStyle(C3ButtonMediumStyle))
	table.insert(contents, Button { x = kCenter - 83, y = 158, name = "community_account_menu_primary", label = "#" .. GetString("community_account_edit_profile"), command = EditProfile })
	table.insert(contents, Button { x = kCenter + 83, y = 158, name = "community_account_menu_secondary", label = "#" .. GetString("community_account_sign_out"), command = SignOut })
else
	table.insert(contents, Text { x = 35, y = 40, w = 432, h = 36, label = "#" .. GetString("community_account_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter })
	table.insert(contents, Text { x = 54, y = 88, w = 394, h = 76, label = "#" .. GetString("community_account_intro"), font = bodyFont, flags = kHAlignCenter + kVAlignTop })
	table.insert(contents, Rectangle { x = 48, y = 148, w = 406, h = 1, color = ruleColor })
	
	table.insert(contents, SetStyle(C3ButtonMediumStyle))
	table.insert(contents, Button { x = kCenter - 83, y = 158, name = "community_account_menu_primary", label = "#" .. GetString("community_account_sign_in"), command = function() Authenticate("signin") end })
	table.insert(contents, Button { x = kCenter + 83, y = 158, name = "community_account_menu_secondary", label = "#" .. GetString("community_account_create"), command = function() Authenticate("register") end })
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_account_menu",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_1",
		
		Group(contents),
		Text { x = 54, y = 252, w = 394, h = 18, name = "community_account_menu_status", label = "", font = statusFont, flags = kHAlignCenter + kVAlignCenter },
		
		SetStyle(C3ButtonMediumStyle),
		Button { x = kCenter, y = 234, name = "community_account_menu_cancel", label = "cancel", cancel = true, default = true, command = function() FadeCloseWindow("community_account_menu", "cancel") end },
	}
}

CenterFadeIn("community_account_menu")
