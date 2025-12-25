--[[---------------------------------------------------------------------------
	Chocolatier Three: Slot Machine
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local bet = gDialogTable.bet or 100

-------------------------------------------------------------------------------
-- Calculate odds of winning...

-- MODIFICATION: Rebalanced odds based on Difficulty.
-- Original game had a Net EV of +0.5 (Gross 1.5), which was a money printer.
-- Payouts are fixed: 1x (Simple), 2.5x (Basic), 8x (Jackpot).

local simpleWin, basicWin, jackpotWin

if Player.difficulty == 3 then -- Hard Mode
	-- House Edge: ~20% (Gross Return 0.80)
	-- The casino is predatory. Gambling is a losing strategy.
	simpleWin = 15		-- 15% * 1.0 = 0.15
	basicWin = 25		-- 10% * 2.5 = 0.25
	jackpotWin = 30		-- 05% * 8.0 = 0.40
						-- Total     = 0.80
						
elseif Player.difficulty == 2 then -- Medium Mode
	-- House Edge: ~2.5% (Gross Return 0.975)
	-- Fair casino odds. You might win in the short term, but lose long term.
	simpleWin = 20		-- 20% * 1.0 = 0.20
	basicWin = 35		-- 15% * 2.5 = 0.375
	jackpotWin = 40		-- 05% * 8.0 = 0.40
						-- Total     = 0.975

else -- Easy Mode
	-- Player Edge: ~7% (Gross Return 1.07)
	-- Generous, but not the broken 150% of the original game.
	simpleWin = 25		-- 25% * 1.0 = 0.25
	basicWin = 45		-- 20% * 2.5 = 0.50
	jackpotWin = 49		-- 04% * 8.0 = 0.32
						-- Total     = 1.07
end

-- However, lower-value slots are looser:
-- (Fixed original bug where 'looseFactor' was calculated but 'looseness' was used)
local looseness = 1.0

if Player.difficulty == 3 then
	-- Hard Mode: High rollers get TIGHTER slots. The house protects its bankroll.
	if bet > 100000 then looseness = 0.95
	elseif bet > 10000 then looseness = 0.98
	end
else
	-- Easy/Medium: Small bets are slightly looser to encourage play.
	if bet < 1000 then looseness = 1.05
	elseif bet < 10000 then looseness = 1.025
	elseif bet < 100000 then looseness = 1.01
	end
end

-- Apply the modifier
simpleWin = simpleWin * looseness
basicWin = basicWin * looseness
jackpotWin = jackpotWin * looseness

-- Debug output to verify odds during testing
DebugOut("GAMBLE", "Slot Odds Configured. Simple: "..simpleWin.."%, Basic: "..(basicWin-simpleWin).."%, Jackpot: "..(jackpotWin-basicWin).."%")

-------------------------------------------------------------------------------

-- Gather ingredient needs into an indexed table
local ings = { "dollars", }
for name,_ in pairs(Player.needs) do
	table.insert(ings, name)
end

-------------------------------------------------------------------------------

local n = { 0,0,0,0 }
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
	
	-- Randomize
	-- Roll to determine whether the player wins... and what...
	local r = RandRange(1,100)
	
	-- Debug the roll
	-- DebugOut("GAMBLE", "Spin Roll: " .. r)
	
	if r <= simpleWin then
		-- Three in a row: even payout
		payout = 1
		n[1] = RandRange(1, table.getn(ings))
		n[2] = n[1]
		n[3] = n[2]
		n[4] = RandRange(1, table.getn(ings))
		if n[4] == n[3] then n[4] = Mod((n[4] + 1), table.getn(ings)) + 1 end
	elseif r <= basicWin then
		-- Four in a row: high 2.5x payout
		payout = 2.5
		n[1] = RandRange(2, table.getn(ings))
		n[2] = n[1]
		n[3] = n[2]
		n[4] = n[3]
	elseif r <= jackpotWin then
		-- Four "$" in a row: JACKPOT 8x payout
		payout = 8
		n[1] = 1
		n[2] = 1
		n[3] = 1
		n[4] = 1
	else
		-- Completely random but avoid triples and quads, no payout
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

	-- Shuffle
	for i=1,4 do
		local s = RandRange(1,4)
		local t = n[i]
		n[i] = n[s]
		n[s] = t
	end
	
	StartSlots(n[1],n[2],n[3],n[4],payout)
end

local function AllStopped()
	local win = Floor(bet * payout + 0.9)
	if win > 0 then
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
		SetLabel("instructions", GetString("slots_lost", Dollars(bet)))
	end
end

local function PaidOut()
	EnableWindow("ok", true)
	ready = true
end

-------------------------------------------------------------------------------

local instructions = GetString("slots_instructions", Dollars(bet))

MakeDialog
{
	Bitmap
	{
		name="slotmachine",
		x=1000,y=kCenter, image="image/popup_back_generic_tall",
		
		SetStyle(C3DialogBodyStyle),
		Text { x=25,y=365,w=433,h=36, flags=kVAlignCenter+kHAlignCenter, name="instructions", label="#"..instructions },
		
		Bitmap
		{
			x=kCenter,y=5, w=366,h=403,image="image/slot_machine_base", fit=true,
				
			SlotMachine
			{
				x=0,y=0,w=kMax,h=550,
				options = ings,
				wheel1 = { x=80+14,y=116+40 },
				wheel2 = { x=141+14,y=116+40 },
				wheel3 = { x=202+14,y=116+40 },
				wheel4 = { x=263+14,y=116+40 },
				onstopped = AllStopped,
				onpayout = PaidOut,
			},
			Bitmap { x=0,y=0, image="image/slot_machine_mask" },
			
			Button { name="pull", x=326,y=49,
				graphics = { "image/slot_machine_handle_up", "image/slot_machine_handle_down", "image/slot_machine_handle_up", },
				mask = "image/slot_machine_handle_mask",
--				sound = "cadi/ui_click.ogg",
				type = kPush,
				command=PullLever,
			},
		},
		
		SetStyle(C3ButtonStyle),
		Button { x=kCenter,y=424, name="ok", label="cancel", default=true,cancel=true,close=true },
	},
}

OpenBuilding("slotmachine", gDialogTable.building)