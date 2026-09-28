--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Community Score Account Gate)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/account.lua")
require("community/identity.lua")
ClearStringCache()

if CommunityAccount.IsSignedIn() then
	QueueCommand(function() FadeCloseWindow("community_score_account_required", "signed_in") end)
end

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local headerFont = { labelFontName, 23, MaroonColor }
local bodyFont = { standardFont, 13, BlackColor }
local smallFont = { standardFont, 10.5, BlackColor }
local ruleColor = Color(116, 82, 54, 60)

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function Authenticate(mode)
	local result = DisplayDialog { "ui/community_account_auth.lua", mode = mode }
	if result == "signed_in" and CommunityAccount.IsSignedIn() then
		CommunityIdentity.SyncPlayer()
		FadeCloseWindow("community_score_account_required", "signed_in")
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "community_score_account_required", x = 1000, y = kCenter, image = "image/popup_back_generic_tall",
		Text { x = 35, y = 36, w = 432, h = 38, label = "#" .. GetString("community_score_account_required_header"), font = headerFont, flags = kHAlignCenter + kVAlignCenter },
		Text { x = 54, y = 104, w = 394, h = 105, label = "#" .. GetString("community_score_account_required_body"), font = bodyFont, flags = kHAlignCenter + kVAlignTop },
		Rectangle { x = 48, y = 215, w = 406, h = 1, color = ruleColor },
		Text { x = 58, y = 241, w = 386, h = 58, label = "#" .. GetString("community_score_account_required_privacy"), font = smallFont, flags = kHAlignCenter + kVAlignTop },
		SetStyle(C3ButtonMediumStyle),
		Button { x = 80, y = 323, label = "#" .. GetString("community_account_sign_in"), command = function() Authenticate("signin") end },
		Button { x = 252, y = 323, label = "#" .. GetString("community_account_create"), command = function() Authenticate("register") end },
		SetStyle(C3ButtonMediumStyle),
		Button { x = 166, y = 385, label = "cancel", cancel = true, default = true, command = function() FadeCloseWindow("community_score_account_required", "cancel") end },
	}
}
CenterFadeIn("community_score_account_required")
