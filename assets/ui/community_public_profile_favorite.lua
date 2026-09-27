--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Public Profile Favourite Product)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

local profile = gCommunityPublicProfile or {}
local favorite = profile.favorite_product or {}
local contents = {}
if favorite.kind == "game" and favorite.id and favorite.id ~= "" and _AllProducts and _AllProducts[favorite.id] then
	local product = _AllProducts[favorite.id]
	if product and product.GetAppearanceBig then
		-- Give the favourite product a little more visual weight in the profile.
		table.insert(contents, product:GetAppearanceBig(2, 2, 0.55))
	end
elseif favorite.kind == "creation" then
	-- Community Creation favourites currently display their saved name only.
end
MakeDialog(contents)
