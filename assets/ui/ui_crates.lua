--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Cargo Crates Bonus Game)
	Copyright (c) 2007-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local char = gDialogTable.char or _AllCharacters["main_alex"]

if char then
	Player:MeetCharacter(char)
end

local started = false
local betFont = { uiFontName, 32, BlackColor }

-------------------------------------------------------------------------------
-- Dynamic Betting Bounds Engine
-------------------------------------------------------------------------------
-- This complex logic scales the "Crates" bet slider to always be proportional
-- to the player's total net worth, keeping the stakes feeling relevant regardless
-- of whether they are at Rank 1 or Rank 5.

-- 1. Calculate the Minimum Bet (Floor is 1% of total cash)
local minBet = Floor(Player.money * 0.01)

-- Round to the nearest $100 for clean UI presentation
minBet = Floor((minBet + 50) / 100) * 100

if minBet < 100 then 
	minBet = 100
elseif minBet > 1000000 then 
	minBet = 1000000 -- Hard cap minimum at $1,000,000
end

-- 2. Calculate the Maximum Bet (Ceiling is roughly 20% of total cash)
local maxBet = Floor(Player.money * 0.20)

-- If the player is broke, let them risk up to 50% of their cash.
if maxBet < minBet then 
	maxBet = Player.money * 0.5 
end

if maxBet > 1000000 then 
	maxBet = 1000000 
end
if maxBet < minBet then 
	maxBet = minBet 
end

if minBet == maxBet and maxBet > 200 then 
	minBet = Floor(maxBet / 2) 
end

-- 3. Calculate Step Increments (Delta)
-- The UI features 10 sliding ticks between the min and max bet.
local deltaBet = Floor((maxBet - minBet) / 10)

if deltaBet <= 0 then
	minBet = maxBet - 1000
	if minBet < 100 then minBet = 100 end
	deltaBet = Floor((maxBet - minBet) / 10)
end

deltaBet = Floor((deltaBet + 50) / 100) * 100
maxBet = minBet + 10 * deltaBet

-- Extreme Edge Case: Allow gambling up to 50% if the numbers require it to function.
if maxBet > Player.money / 2 then
	maxBet = Player.money / 2
	maxBet = Floor(maxBet / 100) * 100
	deltaBet = Floor((maxBet - minBet) / 10)
	maxBet = minBet + 10 * deltaBet
end

-- Ultimate Failsafe fallback
if maxBet < minBet then
	maxBet = minBet
	deltaBet = 0
end

-- Initialize the active bet to exactly the middle of the slider (5 ticks in)
local bet = minBet + (5 * deltaBet)
local winnings = 0

DebugOut("GAMBLE", string.format("Crates initialized. Min: %s | Max: %s | Step: %s", Dollars(minBet), Dollars(maxBet), Dollars(deltaBet)))

-------------------------------------------------------------------------------
-- Betting UI Mechanics
-------------------------------------------------------------------------------

local function UpdateBet()
	SetLabel("bet", Dollars(bet))
	EnableWindow("bet_less", (bet > minBet))
	EnableWindow("bet_more", (bet < maxBet))
end

local function LowerBet()
	bet = bet - deltaBet
	UpdateBet()
end

local function RaiseBet()
	bet = bet + deltaBet
	UpdateBet()
end

-------------------------------------------------------------------------------
-- Gameplay Lifecycle Methods
-------------------------------------------------------------------------------

-- Called when the game ends. Forces all remaining crates to display their hidden 
-- values so the player can see what they missed.
-- Utilizes SelectPrize(index, true), an underlying C-bound engine function.
local function RevealAll()
	for i = 1, 21 do
		local value = SelectPrize(i, true)
		EnableWindow("select_" .. tostring(i), false)
	end
end

local function Cancel()
	CloseWindow()
end

-- Standard graceful exit (The player hits the "Collect Winnings" button)
local function Finish()
	DebugOut("GAMBLE", string.format("Player chose to cash out early. Revealing remaining crates."))
	SetLabel("winnings_label", GetString("you_won"))
	SetLabel("instructions", GetString("crates_welldone"))
	RevealAll()
	
	EnableWindow("close", true)
	EnableWindow("done", false)
end

-- Final reconciliation logic when closing the UI window completely
local function Done()
	local won = winnings - bet
	
	if won == 0 then
		SetLabel("winnings_label", GetText("you_won", Dollars(bet)))
		SetLabel("winnings", Dollars(won))
		DebugOut("GAMBLE", "Crates finished: Broke Even.")
	elseif winnings == 0 then
		SetLabel("winnings_label", GetString("you_lost"))
		local wonLabel = Dollars(-won)
		SetLabel("winnings", wonLabel)
		DebugOut("GAMBLE", string.format("Crates finished: Total Loss (-%s).", Dollars(-won)))
	else
		Player:AddMoney(winnings)
		SetLabel("winnings_label", GetString("you_won"))
		SetLabel("winnings", Dollars(won))
		DebugOut("GAMBLE", string.format("Crates finished: Net Profit (+%s).", Dollars(won)))
	end

	CloseWindow()
end

-------------------------------------------------------------------------------
-- Active Gameplay Logic
-------------------------------------------------------------------------------

local function EnableSelections(yn)
	for i = 1, 21 do
		EnableWindow("select_" .. tostring(i), yn)
	end
end

-- Commits the bet and generates the backend layout array
local function AcceptBet()
	DebugOut("GAMBLE", string.format("Player committed bet of %s. Starting Crates game.", Dollars(bet)))
	
	EnableWindow("make_bet", false)
	EnableWindow("start", false)
	EnableWindow("close", false)
	EnableWindow("done", true)
	
	SetCommand("done", Finish)
	SetLabel("done", GetString("done"))

	SetLabel("winnings_label", GetString("losings"))
	SetLabel("winnings", Dollars(0))
	
	EnableWindow("bet_more", false)
	EnableWindow("bet_less", false)
	
	Player:SubtractMoney(bet)
	
	-- PrepareGame is a C-bound engine function that calculates the total grid value 
	-- and secretly places the bomb.
	local total = PrepareGame(bet)
	started = true

	-- Calculate the "Grand Total" hint value
	local n = total
	if n > 100000 then 
		n = Floor(n / 10000) * 10000
	elseif n > 10000 then 
		n = Floor(n / 1000) * 1000
	else 
		n = Floor(n / 100) * 100
	end
	
	SetLabel("instructions", GetText("gamble_crate_first", Dollars(n)))
	EnableWindow("crates", true)
end

-- Executes when the player clicks on a specific crate.
-- Utilizes SelectPrize(index, false), which returns either the numeric value 
-- of the crate, or 0 if the crate contained the game-ending Bomb.
local function DoSelect(i)
	if started then
		EnableWindow("select_" .. tostring(i), false)
		local value = SelectPrize(i, false)
		
		if value > 0 then
			-- Crate contained money
			winnings = winnings + value
			local won = winnings - bet
			local wonLabel = Dollars(winnings)

			if won > 0 then
				SetLabel("instructions", GetText("crates_ahead", Dollars(winnings), Dollars(bet)))
				SetLabel("winnings_label", GetString("winnings"))
			elseif won < 0 then
				SetLabel("instructions", GetText("crates_behind", Dollars(winnings), Dollars(bet)))
				SetLabel("winnings_label", GetString("losings"))
			else
				SetLabel("instructions", GetText("crates_even", Dollars(winnings), Dollars(bet)))
				SetLabel("winnings_label", GetString("winnings"))
			end

			SetLabel("winnings", wonLabel)
			DebugOut("GAMBLE", string.format("Crate %d clicked: Earned %s (Current Gross: %s)", i, Dollars(value), Dollars(winnings)))
		else
			-- Crate contained the Bomb. Game Over.
			DebugOut("GAMBLE", string.format("Crate %d clicked: BOMB TRIGGERED. Player lost everything.", i))
			winnings = 0
			
			SetLabel("instructions", GetText("crates_lost", Dollars(bet)))
			SetLabel("winnings_label", GetString("you_lost"))
			SetLabel("winnings", WorsePriceColor .. Dollars(bet))

			RevealAll()
			EnableWindow("close", true)
			EnableWindow("done", false)
		end
	end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

-- Programmatically generate the 21 clickable crate button overlays
local selections = {}
for i = 1, 21 do
	local n = i
	local x = Mod(i - 1, 7) * 60 + 226
	local y = Floor((i - 1) / 7) * 55 + 95
	
	table.insert(selections,
		Button { 
			x = x, y = y, w = 50, h = 47, 
			graphics = {},
			sound = "",
			name = "select_" .. tostring(n), 
			command = function() DoSelect(n) end 
		}
	)
end

MakeDialog
{
	Window
	{
		x = 1000, y = 35, w = 701, h = 366, name = "ui_crates",
		
		Bitmap
		{
			x = 0, y = 9, image = "image/popup_back_market",
			
			-- Dialogue Banner
			SetStyle(C3CharacterDialogStyle),
			Text { x = 230, y = 48, w = 405, h = 172, name = "instructions", label = "#" .. GetString("gamble_crate_instructions"), flags = kVAlignTop + kHAlignCenter },
			
			-- Initial Bet Configuration Panel
			Window
			{
				x = 0, y = 0, w = kMax, h = kMax, name = "make_bet",
				
				SetStyle(C3CharacterDialogStyle),
				Text { x = 265, y = 136, w = 235, h = 32, label = "#" .. GetString("your_bet"), font = betFont, flags = kVAlignCenter + kHAlignLeft },
				Text { x = 265, y = 168, w = 235, h = 32, name = "bet", label = "#" .. Dollars(bet), font = betFont, flags = kVAlignCenter + kHAlignLeft },
				
				SetStyle(C3SmallRoundButtonStyle),
				Button { x = 245, y = 188, command = LowerBet, name = "bet_less", label = "#-" },
				Button { x = 285, y = 188, command = RaiseBet, name = "bet_more", label = "#+" },
				
				Bitmap { x = 505, y = 110, image = "image/box_closed", Bitmap { x = 35, y = 46, image = "items/dollars_big" } },
			},
			
			-- Identity Tag
			SetStyle(C3CharacterNameStyle),
			Text { x = 37, y = 241, w = 187, h = 20, label = "#" .. GetString(char.name), font = characterNameFont, flags = kVAlignCenter + kHAlignCenter },

			-- Active Status Panel
			SetStyle(C3CharacterDialogStyle),
			Text { x = 60, y = 280, w = 165, h = 32, name = "winnings_label", label = "", flags = kVAlignCenter + kHAlignRight },
			Text { x = 230, y = 280, w = 200, h = 32, name = "winnings", label = "", font = betFont, flags = kVAlignCenter + kHAlignLeft },
			
			-- UI Controls
			SetStyle(C3ButtonStyle),
			Button { x = 334, y = 280, name = "start", label = "start", command = AcceptBet },
			Button { x = 466, y = 280, name = "done", label = "cancel", cancel = true, command = Cancel },
			Button { x = 466, y = 280, name = "close", label = "close", command = Done },

			-- C-Bound Graphical Animation Layer
			CratesGame
			{
				name = "crates",
				x = 0, y = 0, w = kMax, h = kMax,
				Group(selections),
			},
			
			AppendStyle(C3RoundButtonStyle),
		},
		
		CharWindow { x = 45, y = 0, name = char.name, happiness = char:GetHappiness() },
	}
}

UpdateBet()
EnableWindow("close", false)
EnableWindow("crates", false)
EnableWindow("make_bet", true)

OpenBuilding("ui_crates", gDialogTable.building)