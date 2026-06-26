--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Detail Dispatcher)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script serves as a lightweight routing module. It evaluates the current
-- global selection state and injects the corresponding detail view script 
-- into the right-hand panel of the Catalogue UI.

require("ui/catalogue_detail_common.lua")

local selection = gCatalogueSelection

if selection then
	DebugOut("UI", string.format("Catalogue Detail Dispatcher routing selection to: %s category", gCatalogueCategory))
	
	if gCatalogueCategory == "characters" then
		dofile("ui/catalogue_character_detail.lua")
	elseif gCatalogueCategory == "ingredients" then
		dofile("ui/catalogue_ingredient_detail.lua")
	elseif gCatalogueCategory == "ports" then
		dofile("ui/catalogue_port_detail.lua")
	elseif gCatalogueCategory == "history" then
		dofile("ui/catalogue_history_detail.lua")
	end
else
	-- Default fallback state if nothing is selected (Render an empty prompt)
	MakeDialog {
		Text { x = 0, y = 0, w = kMax, h = kMax, label = "#" .. GetString("catalogue_no_selection"), flags = kVAlignCenter + kHAlignCenter }
	}
end