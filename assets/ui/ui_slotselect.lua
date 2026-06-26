--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Slot Machine / Crates Selector)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initialization & Setup
-------------------------------------------------------------------------------

local char = gDialogTable.char or gActiveCharacter or "main_alex"
local building = gDialogTable.building

-- Ensure character is resolved to a proper object
if type(char) == "string" then 
	char = _AllCharacters[char] 
end
gActiveCharacter = char

-- Log the interaction so the character is officially "Met" in the catalogue
if char then
	Player:MeetCharacter(char)
end

-- Track discovery of the casino for progression purposes
if building and not Player.buildingsVisited[building.name] then
	DebugOut("PLAYER", string.format("First visit to casino recorded: %s", building.name))
	Player.buildingsVisited[building.name] = true
end

local text = gDialogTable.text or "gamble_options"

-------------------------------------------------------------------------------
-- Bet Scaling Logic
-------------------------------------------------------------------------------

-- Default fallback bet tiers if the player is broke
local bet = { 1, 5, 10 }

-- Dynamically scale the available bet tiers based on the player's total wealth.
-- Base calculation: The lowest bet is 0.1% of their total cash on hand.
local n = Floor(Player.money / 1000)

-- Smooth out the numbers so the UI buttons have clean, round digits
if n > 100 then 
	n = 100 * Floor(n / 100)		-- Round to the nearest $100 if wealthy
elseif n > 10 then 
	n = 10 * Floor(n / 10)			-- Round to the nearest $10 if moderately wealthy
end

-- Assign the final scalable brackets: 1x, 10x, and 100x the base tier
if n > 0 then 
	bet = { n, n * 10, n * 100 } 
end

-------------------------------------------------------------------------------
-- Action Handlers
-------------------------------------------------------------------------------

-- Launches the Slot Machine minigame with the selected bet tier
local function SelectMachine(which)
	DebugOut("GAMBLE", string.format("Player selected Slot Machine with bet tier %d (%s).", which, Dollars(bet[which])))
	CloseWindow()
	QueueCommand(function() 
		DisplayDialog { "ui/ui_slotmachine.lua", bet = bet[which] } 
	end)
end

-- Launches the Cargo Crates minigame
local function SelectCrates()
	DebugOut("GAMBLE", "Player selected Cargo Crates minigame.")
	CloseWindow()
	QueueCommand(function() 
		DisplayDialog { "ui/ui_crates.lua", char = char, building = building } 
	end)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x = 1000, y = 35, w = 601, h = 800, name = "slotselect", fit = true,
		
		Bitmap
		{
			x = 0, y = 49, h = 800, image = "image/popup_back_dialog", fit = true,
			
			-- Character Identity
			SetStyle(C3CharacterNameStyle),
			Text { x = 41, y = 201, w = 187, h = 20, label = "#" .. GetString(char.name), font = characterNameFont, flags = kVAlignCenter + kHAlignCenter },
			
			-- Slot Machine Section (Left Side)
			SetStyle(C3ButtonStyle),
			Bitmap { x = 241, y = 105, scale = 0.29, image = "image/slot_machine_base" },
			Button { x = 341, y = 110, scale = 0.75, label = "#" .. Dollars(bet[1]), command = function() SelectMachine(1) end },
			Button { x = 341, y = 143, scale = 0.75, label = "#" .. Dollars(bet[2]), command = function() SelectMachine(2) end },
			Button { x = 341, y = 176, scale = 0.75, label = "#" .. Dollars(bet[3]), command = function() SelectMachine(3) end },

			-- Cargo Crates Section (Right Side)
			Button { 
				x = 445, y = 85, 
				graphics = { "image/box_closed", "image/button_box_down", "image/box_open" }, 
				command = SelectCrates,
				Bitmap { x = 35, y = 46, image = "items/dollars_big" },
			},

			-- Dialogue Box
			SetStyle(C3CharacterDialogStyle),
			Text { x = 241, y = 48, w = 314, h = 172, label = "#" .. GetString(text), flags = kVAlignTop + kHAlignCenter },
			
			-- Dismiss Button
			SetStyle(C3ButtonStyle),
			Button { x = 234, y = 240, name = "ok", label = "ok", cancel = true, close = true },
		},
		
		-- Character Portrait Overlay
		CharWindow { x = 49, y = 0, name = char.name, happiness = char:GetHappiness() },
	}
}

-- Engine hook to map this UI over the active building
OpenBuilding("slotselect", building)