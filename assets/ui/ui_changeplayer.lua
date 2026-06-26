--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Change Player Dialog)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Safety hook: Save the current player's state before they switch profiles
DebugOut("SAVE", "Auto-saving current profile state before opening roster.")
Player:SaveGame()

-------------------------------------------------------------------------------
-- Execution & Exit
-------------------------------------------------------------------------------

local function okFunction()
	DebugOut("UI", string.format("Profile Selected: Loading user '%s'.", GetCurrentUserName()))
	Player:LoadGame()
	FadeCloseWindow("changeplayer", "ok")
end

-------------------------------------------------------------------------------
-- Roster UI Management
-------------------------------------------------------------------------------

-- Refreshes the 10 visual slots, hiding empty ones and highlighting the active one
local function UpdatePlayers()
	local n = GetNumUsers()
	local i = 0
	
	-- Fill slots with existing player names
	while i < n do
		i = i + 1
		SetLabel("name" .. i, GetUserName(i - 1))
		SetBitmap("icon" .. i, "image/indicatorlight_off")
	end
	
	-- Clear out the remaining empty slots
	while i < 10 do
		i = i + 1
		SetLabel("name" .. i, "")
		SetBitmap("icon" .. i, "image/indicatorlight_off")
	end

	-- The game has a hardcap of 10 profiles. Disable the "New" button if full.
	EnableWindow("newplayer", n < 10)
	-- Disable the "Delete" button if only one profile remains.
	EnableWindow("deleteplayer", n > 1)

	-- Highlight the currently active player
	local activeIdx = GetCurrentUser() + 1
	SetBitmap("icon" .. activeIdx, "image/indicatorlight_green")
end

-------------------------------------------------------------------------------
-- Action Handlers
-------------------------------------------------------------------------------

local function SelectPlayer(n)
	n = n - 1
	if n < GetNumUsers() then
		DebugOut("UI", string.format("Profile slot %d selected: %s", (n + 1), GetUserName(n)))
		SetCurrentUser(n)
		UpdatePlayers()
	end
end

local function DeletePlayer()
	local currentName = GetCurrentUserName()
	DebugOut("UI", string.format("Player initiated deletion sequence for profile: %s", currentName))
	
	local promptStr = GetString("confirm_delete", currentName)
	local yn = DisplayDialog { "ui/ui_generic_yn.lua", text = "#" .. promptStr }
	
	if yn == "yes" then
		DebugOut("SAVE", string.format("Profile deletion confirmed: %s", currentName))
		local n = GetCurrentUser()
		DeleteUser(n)
		UpdatePlayers()
	else
		DebugOut("UI", "Profile deletion aborted by user.")
	end
end

local function RenamePlayer()
	local name = GetCurrentUserName()
	DebugOut("UI", string.format("Player initiated rename sequence for profile: %s", name))
	
	local newName = DisplayDialog { "ui/ui_entername.lua", name = name }
	if newName and newName ~= "" and newName ~= name then
		DebugOut("SAVE", string.format("Profile renamed: '%s' -> '%s'.", name, newName))
		ChangeCurrentUserName(newName)
		Player.name = newName
		Player.stringTable.player = newName
		UpdatePlayers()
	else
		DebugOut("UI", "Profile rename aborted (Cancelled or name unchanged).")
	end
end

local function NewPlayer()
	DebugOut("UI", "Player initiated New Profile creation sequence.")
	local newName = DisplayDialog { "ui/ui_entername.lua" }
	
	if newName and newName ~= "" then
		local difficultyChoice = DisplayDialog { "ui/ui_difficulty.lua" }
		
		-- Proceed only if the player actually selected a difficulty and didn't cancel
		if difficultyChoice then 
			DebugOut("SAVE", string.format("Creating new profile: '%s' (Difficulty: %d)", newName, difficultyChoice))
			CreateNewUser(newName)
			
			Player:Reset()
			Player.name = newName
			Player.stringTable.player = Player.name
			Player.difficulty = difficultyChoice 
			
			Player:SaveGame()
			UpdatePlayers()
		end
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local function PlayerInfo(n)
	return Group
	{
		Bitmap { x = 0, y = 4, w = 32, h = 32, name = "icon" .. n, image = "image/indicatorlight_off" },
		Text { x = 36, y = 0, w = 174, h = 40, name = "name" .. n, font = StandardButtonFont, flags = kHAlignLeft + kVAlignCenter },
	}
end

MakeDialog
{
	Bitmap
	{
		name = "changeplayer",
		x = 1000, y = kCenter, image = "image/popup_back_generic_1",

		AppendStyle { font = StandardButtonFont, type = kRadio, sound = kDefaultcontrolSound, graphics = {} },
		
		-- Column 1
		Button { x = 40, y = 57 - 4,  h = 40, fit = true, name = "select1", command = function() SelectPlayer(1) end, PlayerInfo(1) },
		Button { x = 40, y = 89 - 4,  h = 40, fit = true, name = "select2", command = function() SelectPlayer(2) end, PlayerInfo(2) },
		Button { x = 40, y = 121 - 4, h = 40, fit = true, name = "select3", command = function() SelectPlayer(3) end, PlayerInfo(3) },
		Button { x = 40, y = 153 - 4, h = 40, fit = true, name = "select4", command = function() SelectPlayer(4) end, PlayerInfo(4) },
		Button { x = 40, y = 185 - 4, h = 40, fit = true, name = "select5", command = function() SelectPlayer(5) end, PlayerInfo(5) },
		
		-- Column 2
		Button { x = 251, y = 57 - 4,  h = 40, fit = true, name = "select6", command = function() SelectPlayer(6) end, PlayerInfo(6) },
		Button { x = 251, y = 89 - 4,  h = 40, fit = true, name = "select7", command = function() SelectPlayer(7) end, PlayerInfo(7) },
		Button { x = 251, y = 121 - 4, h = 40, fit = true, name = "select8", command = function() SelectPlayer(8) end, PlayerInfo(8) },
		Button { x = 251, y = 153 - 4, h = 40, fit = true, name = "select9", command = function() SelectPlayer(9) end, PlayerInfo(9) },
		Button { x = 251, y = 185 - 4, h = 40, fit = true, name = "select10", command = function() SelectPlayer(10) end, PlayerInfo(10) },
		
		SetStyle(C3ButtonStyle),
		Button { x = kCenter - 133, y = 230, name = "newplayer", command = NewPlayer, label = "newplayer" },
		Button { x = kCenter, y = 230, name = "renameplayer", command = RenamePlayer, label = "renameplayer" },
		Button { x = kCenter + 133, y = 230, name = "deleteplayer", command = DeletePlayer, label = "deleteplayer" },

		AppendStyle(C3RoundButtonStyle),
		Button { x = 445, y = 251, name = "ok", command = okFunction, label = "ok", default = true, cancel = true },
	}
}

UpdatePlayers()
CenterFadeIn("changeplayer")