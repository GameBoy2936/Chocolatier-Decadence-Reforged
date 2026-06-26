--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Rapid Save/Load
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 120
local x = 0
local y = 2 * h
local saveGames = {}

-------------------------------------------------------------------------------
-- Parsing Disk Architecture
-------------------------------------------------------------------------------

-- Uses the C-Hook to iterate through the local save directory looking for matching .choco3 extensions
local s = NextSaveFileName()

while s ~= "" do
	local g = s .. ".choco3"
	local visualLabel = "#" .. s
	
	table.insert(saveGames, Button { 
		x = x, y = y, w = w, h = h, 
		label = visualLabel, 
		command = function() 
			DebugOut("SAVE", string.format("Dev Trigger: Quick-Loading specific file -> %s", g))
			Player:LoadGameFromFile(g) 
		end 
	})
	
	y = y + h
	s = NextSaveFileName()
	
	if y > 550 then
		x = x + w
		y = 2 * h
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	name = "dev_saves",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = w, h = h, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		Button { 
			x = 0, y = h, w = w, h = h, label = "#<b>SAVE GAME</b>", 
			command = function() 
				DebugOut("SAVE", "Dev Trigger: Opened specific file-save dialogue box.")
				Player:SaveGameToFile() 
			end 
		},
		
		Button { x = 0, y = 2*h, w = w, h = h },
		Group(saveGames),
	},
}