--[[---------------------------------------------------------------------------
	Chocolatier Three: Slot Machine
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local char = gDialogTable.char or gActiveCharacter or "main_alex"
local building = gDialogTable.building
if type(char) == "string" then char = _AllCharacters[char] end
gActiveCharacter = char

if char then
    Player:MeetCharacter(char)
end

local text = gDialogTable.text or "gamble_options"

-------------------------------------------------------------------------------

-- Set slot values according to player money
local bet = { 1, 5, 10 }

local n = Floor(Player.money / 1000)			-- Minimum bet: .1% of cash on hand
if n > 100 then n = 100 * Floor(n / 100)		-- Rounded to nearest $100
elseif n > 10 then n = 10 * Floor(n / 10)		-- Or nearest $10
end
if n > 0 then bet = { n, n*10, n*100 } end

-- TODO: Don't let player into casino without at least $10000?

local function SelectMachine(which)
	CloseWindow()
	QueueCommand(function() DisplayDialog { "ui/ui_slotmachine.lua", bet=bet[which] } end )
end

local function SelectCrates()
	CloseWindow()
	QueueCommand(function() DisplayDialog { "ui/ui_crates.lua", char=char, building=building } end )
end

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=601,h=800, name="slotselect", fit=true,
		Bitmap
		{
			x=0,y=49, h=800, image="image/popup_back_dialog", fit=true,
			
			SetStyle(C3CharacterNameStyle),
			Text { x=41,y=201,w=187,h=20, label="#"..GetString(char.name), font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
			
			SetStyle(C3ButtonStyle),
			Bitmap { x=241,y=105, scale=.29, image="image/slot_machine_base", },
			Button { x=341,y=110, scale=.75, label="#"..Dollars(bet[1]), command=function() SelectMachine(1) end },
			Button { x=341,y=143, scale=.75, label="#"..Dollars(bet[2]), command=function() SelectMachine(2) end },
			Button { x=341,y=176, scale=.75, label="#"..Dollars(bet[3]), command=function() SelectMachine(3) end },

			Button { x=445,y=85, graphics={"image/box_closed","image/button_box_down","image/box_open" }, command=SelectCrates,
				Bitmap { x=35,y=46, image="items/dollars_big" },
			},

			SetStyle(C3CharacterDialogStyle),
			Text { x=241,y=48,w=314,h=172, label=text, flags=kVAlignTop+kHAlignCenter },
			
			SetStyle(C3ButtonStyle),
			Button { x=234,y=240, name="ok", label="ok", cancel=true,close=true },
		},
		CharWindow { x=49,y=0, name=char.name, happiness=char:GetHappiness() },
	}
}

OpenBuilding("slotselect", building)
