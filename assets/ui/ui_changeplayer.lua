--[[---------------------------------------------------------------------------
	Chocolatier Three: Change Player dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

DebugOut("SAVE", "Auto-saving current player before entering Change Player screen.")
Player:SaveGame()

-------------------------------------------------------------------------------

local function okFunction()
    DebugOut("UI", "OK button clicked. Loading selected player: " .. GetCurrentUserName())
	Player:LoadGame()
	FadeCloseWindow("changeplayer", "ok")
end

-------------------------------------------------------------------------------

local function UpdatePlayers()
    DebugOut("UI", "UpdatePlayers called. Refreshing player list.")
	local n = GetNumUsers()
	local i=0
	while i < n do
		i = i + 1
		SetLabel("name"..i, GetUserName(i-1))
		SetBitmap("icon"..i, "image/indicatorlight_off")
	end
	while i < 10 do
		i = i + 1
		SetLabel("name"..i, "")
		SetBitmap("icon"..i, "image/indicatorlight_off")
	end

	EnableWindow("newplayer", n < 10)
	EnableWindow("deleteplayer", n > 1)

	local n = GetCurrentUser() + 1
	SetBitmap("icon"..n, "image/indicatorlight_green")
end

-------------------------------------------------------------------------------

local function SelectPlayer(n)
	n = n - 1
	if n < GetNumUsers() then
        DebugOut("UI", "Player selected slot " .. (n + 1) .. ": " .. GetUserName(n))
		SetCurrentUser(n)
		UpdatePlayers()
	end
end

local function DeletePlayer()
    DebugOut("UI", "Delete Player button clicked for user: " .. GetCurrentUserName())
	local name = GetString("confirm_delete", GetCurrentUserName())
	local yn = DisplayDialog { "ui/ui_generic_yn.lua", text="#"..name }
	if yn == "yes" then
        DebugOut("PLAYER", "Player confirmed deletion of: " .. GetCurrentUserName())
		local n = GetCurrentUser()
		DeleteUser(n)
		UpdatePlayers()
	else
        DebugOut("UI", "Player cancelled deletion.")
    end
end

local function RenamePlayer()
    DebugOut("UI", "Rename Player button clicked for user: " .. GetCurrentUserName())
	local name = GetCurrentUserName()
	local newName = DisplayDialog { "ui/ui_entername.lua", name=name }
	if newName and newName ~= "" and newName ~= name then
        DebugOut("PLAYER", "Player '" .. name .. "' renamed to '" .. newName .. "'.")
		ChangeCurrentUserName(newName)
		Player.name = newName
		Player.stringTable.player = newName
		UpdatePlayers()
	else
        DebugOut("UI", "Player cancelled rename or entered same name.")
    end
end

local function NewPlayer()
	local newName = DisplayDialog { "ui/ui_entername.lua" }
	if newName and newName ~= "" then
        local difficultyChoice = DisplayDialog { "ui/ui_difficulty.lua" }
        
        -- Proceed only if the player made a choice (didn't cancel)
        if difficultyChoice then 
		    CreateNewUser(newName)
		    Player:Reset()
		    Player.name = newName
		    Player.stringTable.player = Player.name
            Player.difficulty = difficultyChoice -- Save the chosen difficulty
		    Player:SaveGame()
		    UpdatePlayers()
        end
	end
end

-------------------------------------------------------------------------------

local function PlayerInfo(n)
	return Group
	{
		Bitmap { x=0,y=4,w=32,h=32, name="icon"..n, image="image/indicatorlight_off" },
		Text { x=36,y=0,w=174,h=40, name="name"..n, font=StandardButtonFont, flags=kHAlignLeft + kVAlignCenter },
	}
end

MakeDialog
{
	Bitmap
	{
		name="changeplayer",
		x=1000,y=kCenter,image="image/popup_back_generic_1",

		AppendStyle { font = StandardButtonFont, type = kRadio, sound = kDefaultcontrolSound, graphics = {} },
		Button { x=40,y=57-4,h=40, fit=true, name="select1", command=function() SelectPlayer(1) end, PlayerInfo(1) },
		Button { x=40,y=89-4,h=40, fit=true, name="select2", command=function() SelectPlayer(2) end, PlayerInfo(2) },
		Button { x=40,y=121-4,h=40, fit=true, name="select3", command=function() SelectPlayer(3) end, PlayerInfo(3) },
		Button { x=40,y=153-4,h=40, fit=true, name="select4", command=function() SelectPlayer(4) end, PlayerInfo(4) },
		Button { x=40,y=185-4,h=40, fit=true, name="select5", command=function() SelectPlayer(5) end, PlayerInfo(5) },
		Button { x=251,y=57-4,h=40, fit=true, name="select6", command=function() SelectPlayer(6) end, PlayerInfo(6) },
		Button { x=251,y=89-4,h=40, fit=true, name="select7", command=function() SelectPlayer(7) end, PlayerInfo(7) },
		Button { x=251,y=121-4,h=40, fit=true, name="select8", command=function() SelectPlayer(8) end, PlayerInfo(8) },
		Button { x=251,y=153-4,h=40, fit=true, name="select9", command=function() SelectPlayer(9) end, PlayerInfo(9) },
		Button { x=251,y=185-4,h=40, fit=true, name="select10", command=function() SelectPlayer(10) end, PlayerInfo(10) },
		
		SetStyle(C3ButtonStyle),
		Button { x=kCenter-133,y=230, name="newplayer", command=NewPlayer, label="newplayer", },
		Button { x=kCenter,y=230, name="renameplayer", command=RenamePlayer, label="renameplayer", },
		Button { x=kCenter+133,y=230, name="deleteplayer", command=DeletePlayer, label="deleteplayer", },

		AppendStyle(C3RoundButtonStyle),
		Button { x=445,y=251, name="ok", command=okFunction, label="ok", default=true, cancel=true },
	}
}

UpdatePlayers()
CenterFadeIn("changeplayer")