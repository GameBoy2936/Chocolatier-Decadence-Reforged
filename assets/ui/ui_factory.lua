--[[---------------------------------------------------------------------------
	Chocolatier Three: Factory Status Dialog
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local factory = gDialogTable.factory
gCurrentFactory = factory
local char = gDialogTable.char

if char then
    Player:MeetCharacter(char)
end

local name = char.name

local info = Player.factories[factory.name]
local current = _AllProducts[info.current]

local function UpdateDisplay()
	if info and info.current then
		local count,current = factory:GetProduction()
		FillWindow("configuration", "ui/ui_factory_content.lua")
		
		local category = current:GetMachinery()
		SetLabel("make", GetString("make_"..category.factory))
	end
end

local function CloseDialog()
	gCurrentFactory = nil
	FadeCloseWindow("ui_factory", "ok")
end

local function MakeChocolates()
	local count,product = factory:GetProduction()
	
	-- Tutorial hack: Give them a hint when they're trying to make Milk Chocolates for the first time
	if product.code == "b01" and _AllQuests["tut_16"]:IsActive() then
		DisplayDialog { "ui/ui_character_generic.lua", char=char, building=factory, text="tut16_configure_hint" }
		return
	end
	
	-- Kill the audio environment during the minigame
	count = product:RunMinigame { factory=factory, char=char }
	count = tonumber(count)
	if count >= 0 then
		factory:SetProduction(product, count)
		UpdateDisplay()
		TickSim(1)
		CloseDialog()
	end
end

local function ChangeConfiguration()
	gRecipeSelection = _AllProducts[info.current]
	local ok = DisplayDialog { "ui/ui_recipes.lua", factory=factory, building=factory }
	local product = gRecipeSelection
	gRecipeSelection = nil
	if product and ok then
		if factory:GetProduction(product) == 0 then
			local count = product:RunMinigame { factory=factory, char=char }
			count = tonumber(count)
			if count >= 0 then
				factory:SetProduction(product, count)
				UpdateDisplay()
				TickSim(1)
			end
		else
			factory:SetProduction(product)
			UpdateDisplay()
		end
	end
end

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=601,h=366, name="ui_factory",
		Bitmap
		{
			x=0,y=49, image="image/popup_back_dialog",
			Window { x=241,y=35,w=kMax,h=185, name="configuration" },
			
			SetStyle(C3CharacterNameStyle),
			Text { x=41,y=201,w=187,h=20, label="#"..GetString(char.name), font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
			
			SetStyle(C3ButtonStyle),
			Button { x=250,y=230, name="configure", label="configure", command=ChangeConfiguration },
			Button { x=390,y=230, name="make", label="make_chocolates", command=MakeChocolates },

			AppendStyle(C3RoundButtonStyle),
			Button { x=529,y=248, name="ok", label="ok", default=true, cancel=true, command=CloseDialog },
		},
		CharWindow { x=49,y=0, name=char.name, happiness=char:GetHappiness() },
	}
}

-- Until they've made basic bars, don't let them re-configure the factory
-- if not _AllQuests["tut_04"]:IsComplete() then EnableWindow("configure", false) end -- RULE TURNED OFF

UpdateDisplay()
OpenBuilding("ui_factory", factory)
