--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Slot Machine)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local bet = gDialogTable.bet or 100

-------------------------------------------------------------------------------
-- Probability & Odds Logic
-------------------------------------------------------------------------------
-- The original game had a severely broken Net Expected Value (EV) of +0.5,
-- making the casino an infinite money printer. This has been rebalanced
-- to scale logically with the player's selected difficulty.
-- Payout multipliers are fixed: 1x (Simple), 2.5x (Basic), 8x (Jackpot).

local simpleWin, basicWin, jackpotWin

if Player.difficulty == 3 then 
	-- ------------------------------------------------------------------------
	-- HARD MODE: The Casino is predatory. Gambling is a losing strategy.
	-- House Edge: ~20% (Player Gross Return: 0.80)
	-- ------------------------------------------------------------------------
	simpleWin = 15		-- 15% chance to hit * 1.0x payout = 0.15 EV
	basicWin = 25		-- 10% chance to hit * 2.5x payout = 0.25 EV
	jackpotWin = 30		-- 05% chance to hit * 8.0x payout = 0.40 EV
						-- Total Net EV = 0.80
						
elseif Player.difficulty == 2 then 
	-- ------------------------------------------------------------------------
	-- MEDIUM MODE: Fair casino odds. Viable for short-term bursts, losing long-term.
	-- House Edge: ~2.5% (Player Gross Return: 0.975)
	-- ------------------------------------------------------------------------
	simpleWin = 20		-- 20% chance to hit * 1.0x payout = 0.20 EV
	basicWin = 35		-- 15% chance to hit * 2.5x payout = 0.375 EV
	jackpotWin = 40		-- 05% chance to hit * 8.0x payout = 0.40 EV
						-- Total Net EV = 0.975

else 
	-- ------------------------------------------------------------------------
	-- EASY MODE: Generous, but not the broken 1.50x EV of the original vanilla game.
	-- Player Edge: ~7% (Player Gross Return: 1.07)
	-- ------------------------------------------------------------------------
	simpleWin = 25		-- 25% chance to hit * 1.0x payout = 0.25 EV
	basicWin = 45		-- 20% chance to hit * 2.5x payout = 0.50 EV
	jackpotWin = 49		-- 04% chance to hit * 8.0x payout = 0.32 EV
						-- Total Net EV = 1.07
end

-- "Looseness" Modifier (Slot volatility scaled by bet size)
-- (Fixes an original game bug where 'looseFactor' was calculated but never actually used)
local looseness = 1.0

if Player.difficulty == 3 then
	-- Hard Mode: High rollers get TIGHTER slots. The house protects its bankroll from whales.
	if bet > 100000 then looseness = 0.95
	elseif bet > 10000 then looseness = 0.98
	end
else
	-- Easy/Medium: Small bets are slightly looser to encourage casual play.
	if bet < 1000 then looseness = 1.05
	elseif bet < 10000 then looseness = 1.025
	elseif bet < 100000 then looseness = 1.01
	end
end

-- Apply final modifiers
simpleWin = simpleWin * looseness
basicWin = basicWin * looseness
jackpotWin = jackpotWin * looseness

DebugOut("GAMBLE", string.format("Slot Odds Configured (Bet: %s) -> Simple: %.2f%% | Basic: %.2f%% | Jackpot: %.2f%%", Dollars(bet), simpleWin, (basicWin - simpleWin), (jackpotWin - basicWin)))

-------------------------------------------------------------------------------
-- Visual Wheel Setup
-------------------------------------------------------------------------------

-- Populate the slot machine visual reels with the game's actual ingredients.
-- The "dollars" sprite is always hardcoded into Index 1 (used for Jackpots).
local ings = { "dollars" }
for name, _ in pairs(Player.needs) do
	table.insert(ings, name)
end

-------------------------------------------------------------------------------
-- Spin Mechanics
-------------------------------------------------------------------------------

local n = { 0, 0, 0, 0 } -- The final assigned indices for the four wheels
local payout = 0
local ready = true

local function PullLever()
	if not ready then return end
	
	ready = false
	EnableWindow("ok", false)
	SetLabel("ok", GetString("ok"))
	
	Player:SubtractMoney(bet)
	SoundEvent("pull_lever")
	SoundEvent("machine_spin")
	
	-- Roll RNG (1-100) to determine what tier of payout the player receives
	local r = RandRange(1, 100)
	DebugOut("GAMBLE", string.format("RNG Spin Roll: %d", r))
	
	if r <= simpleWin then
		-- TIER 1: Simple Win (3 matching icons). Payout = 1x
		payout = 1
		n[1] = RandRange(1, table.getn(ings))
		n[2] = n[1]
		n[3] = n[2]
		
		-- Force the 4th wheel to be different so it isn't a 4-in-a-row match
		n[4] = RandRange(1, table.getn(ings))
		if n[4] == n[3] then 
			n[4] = Mod((n[4] + 1), table.getn(ings)) + 1 
		end
		
	elseif r <= basicWin then
		-- TIER 2: Basic Win (4 matching icons). Payout = 2.5x
		payout = 2.5
		-- Starts at index 2 to prevent the player from randomly rolling the Jackpot symbol
		n[1] = RandRange(2, table.getn(ings))
		n[2] = n[1]
		n[3] = n[2]
		n[4] = n[3]
		
	elseif r <= jackpotWin then
		-- TIER 3: Jackpot (4 matching Dollar signs). Payout = 8x
		payout = 8
		n[1] = 1
		n[2] = 1
		n[3] = 1
		n[4] = 1
		
	else
		-- TIER 4: Loss (No payout). 
		-- Randomize all wheels, explicitly guaranteeing we don't accidentally create a winning set.
		payout = 0
		n[1] = RandRange(1, table.getn(ings))
		n[2] = RandRange(1, table.getn(ings))
		n[3] = RandRange(1, table.getn(ings))
		n[4] = RandRange(1, table.getn(ings))
		
		if n[1] == n[2] then
			if n[3] == n[2] then n[3] = Mod((n[3] + 1), table.getn(ings)) + 1 end
			if n[4] == n[2] then n[4] = Mod((n[4] + 1), table.getn(ings)) + 1 end
		elseif n[2] == n[3] then
			if n[4] == n[2] then n[4] = Mod((n[4] + 1), table.getn(ings)) + 1 end
		end
	end

	-- Shuffle the resulting sequence so the "failed" wheel isn't always the 4th one
	for i = 1, 4 do
		local s = RandRange(1, 4)
		local t = n[i]
		n[i] = n[s]
		n[s] = t
	end
	
	-- Pass the finalized target indices to the UI animation component
	StartSlots(n[1], n[2], n[3], n[4], payout)
end

-- Callback triggered automatically by the UI when the spinning animation finishes
local function AllStopped()
	local win = Floor(bet * payout + 0.9)
	
	if win > 0 then
		DebugOut("GAMBLE", string.format("Spin Complete: Player won %s.", Dollars(win)))
		SoundEvent("win_money")
		Player:AddMoney(win)
		UpdateLedger("money")
		
		if payout == 1 then
			SoundEvent("slots_win_3_in_row")
			SetLabel("instructions", GetString("slots_won_even", Dollars(win), Dollars(bet)))
		elseif payout > 4 then
			SoundEvent("slots_win_4_in_row")
			SetLabel("instructions", GetString("slots_won_jackpot", Dollars(win), Dollars(bet)))
		else
			SoundEvent("slots_win_3_in_row")
			SetLabel("instructions", GetString("slots_won", Dollars(win), Dollars(bet)))
		end
	else
		DebugOut("GAMBLE", "Spin Complete: Player lost.")
		SetLabel("instructions", GetString("slots_lost", Dollars(bet)))
	end
end

-- Reset state so the player can spin again or exit
local function PaidOut()
	EnableWindow("ok", true)
	ready = true
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local instructions = GetString("slots_instructions", Dollars(bet))

MakeDialog
{
	Bitmap
	{
		name = "slotmachine",
		x = 1000, y = kCenter, image = "image/popup_back_generic_tall",
		
		SetStyle(C3DialogBodyStyle),
		Text { x = 25, y = 365, w = 433, h = 36, flags = kVAlignCenter + kHAlignCenter, name = "instructions", label = "#" .. instructions },
		
		Bitmap
		{
			x = kCenter, y = 5, w = 366, h = 403, image = "image/slot_machine_base", fit = true,
				
			-- Engine-bound visual animation component
			SlotMachine
			{
				x = 0, y = 0, w = kMax, h = 550,
				options = ings,
				wheel1 = { x = 80 + 14, y = 116 + 40 },
				wheel2 = { x = 141 + 14, y = 116 + 40 },
				wheel3 = { x = 202 + 14, y = 116 + 40 },
				wheel4 = { x = 263 + 14, y = 116 + 40 },
				onstopped = AllStopped,
				onpayout = PaidOut,
			},
			Bitmap { x = 0, y = 0, image = "image/slot_machine_mask" },
			
			-- Interactive Handle
			Button { 
				name = "pull", 
				x = 326, y = 49,
				graphics = { "image/slot_machine_handle_up", "image/slot_machine_handle_down", "image/slot_machine_handle_up" },
				mask = "image/slot_machine_handle_mask",
				type = kPush,
				command = PullLever,
			},
		},
		
		SetStyle(C3ButtonStyle),
		Button { x = kCenter, y = 424, name = "ok", label = "cancel", default = true, cancel = true, close = true },
	},
}

OpenBuilding("slotmachine", gDialogTable.building)