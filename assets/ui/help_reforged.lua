--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Help)
	Copyright (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

require("community/hub.lua")

-------------------------------------------------------------------------------

local introFont = { uiFontName, 14, BlackColor }
local bodyFont = { uiFontName, 13, BlackColor }
local communityFont = { uiFontName, 13, BlackColor }
local sectionFont = { labelFontName, 18, MaroonColor }

local function OpenExternal(target)
	-- External links are allowlisted by CommunityTransport. If another community
	-- request is already active, leave it alone rather than replacing it.
	if CommunityTransport.IsBusy() then
		return
	end
	CommunityHub.OpenExternal(target, function(ok, err)
		if not ok then
			DebugOut("COMMUNITY", "Help external link failed: " .. tostring(err or target))
		end
	end)
end

local function OpenWiki()
	OpenExternal("wiki")
end

local function OpenDiscord()
	OpenExternal("discord")
end

MakeDialog
{
	SetStyle(C3DialogBodyStyle),

	-- Reforged overview and logo.
	Text { x=15, y=7, w=480, h=84, flags=kVAlignTop+kHAlignLeft, font=introFont, label="#"..GetString("help_reforged_text") },
	Bitmap { x=505, y=6, image="image/title_logo", scale=0.29 },

	-- Keep the open, illustration-and-text feel of the original help screens:
	-- section labels and whitespace provide structure without panel rules.
	Text { x=15, y=95, w=350, h=22, flags=kVAlignCenter+kHAlignCenter, font=sectionFont, label="#"..GetString("help_reforged_whats_new") },
	Text { x=384, y=95, w=350, h=22, flags=kVAlignCenter+kHAlignCenter, font=sectionFont, label="#"..GetString("help_reforged_make_it_yours") },
	Text { x=15, y=118, w=350, h=112, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_reforged_mechanics") },
	Text { x=384, y=118, w=350, h=112, flags=kVAlignTop+kHAlignLeft, font=bodyFont, label="#"..GetString("help_reforged_modding_text") },

	Text { x=15, y=222, w=719, h=20, flags=kVAlignCenter+kHAlignCenter, font=sectionFont, label="#"..GetString("help_reforged_community") },
	Text { x=45, y=240, w=659, h=34, flags=kVAlignCenter+kHAlignCenter, font=communityFont, label="#"..GetString("help_reforged_upsell") },

	-- The native bridge opens these destinations directly, replacing the old raw
	-- URLs and Discord QR code while keeping the page usable from inside the game.
	SetStyle(C3ButtonMediumStyle),
	Button { x=192, y=272, label="#"..GetString("help_reforged_wiki"), command=OpenWiki },
	Button { x=392, y=272, label="#"..GetString("help_reforged_discord"), command=OpenDiscord },
}
