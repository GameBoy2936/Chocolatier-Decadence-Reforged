--[[---------------------------------------------------------------------------
	Chocolatier Three: Slot Machine
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local bet = gDialogTable.bet or 100

-------------------------------------------------------------------------------
-- Calculate odds of winning...

-- Odds of winning a "simple" 1x payout: 20%
local simpleWin = 20
-- Odds of winning the "basic" 2.5x payout: 20%
local basicWin = simpleWin + 20
-- Odds of winning the "jackpot" 8x payout: 10%
local jackpotWin = basicWin + 10
-- So overall, the game is even
-- 0.2 x 1 + 0.2 x 2.5 + 0.1 x 8 + .5 x -1 = 1

-- However, lower-value slots are looser:
local looseness = 1
if bet < 1000 then looseFactor = 1.05
elseif bet < 10000 then looseFactor = 1.025
elseif bet < 100000 then looseFactor = 1.01
end

simpleWin = simpleWin * looseness
basicWin = basicWin * looseness
jackpotWin = jackpotWin * looseness

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
