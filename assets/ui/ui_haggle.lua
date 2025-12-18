--[[---------------------------------------------------------------------------
	Chocolatier Three: Haggle dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("ui/helpers.lua")

local char = gDialogTable.char
local market = gDialogTable.market
local shop = gDialogTable.shop
local building = market or shop

-------------------------------------------------------------------------------

-- prepare options for all four (good/bad)/(soft/hard) combinations
local options = { {true,true}, {true,false}, {false,true}, {false,false} }

local function GetRandomHaggleString(baseKey)
    local count = 1
    -- Keep checking for the next numbered string (e.g., "baseKey2", "baseKey3")
    -- until we find one that doesn't exist.
    while GetReplacedString(baseKey .. (count + 1)) ~= "#####" do
        count = count + 1
    end
    
    -- Pick a random number between 1 and the total count we found.
    local randomIndex = RandRange(1, count)
    return GetReplacedString(baseKey .. randomIndex)
end

local function FillOptions()
	-- Select random dialog for the shop keeper
	local intro_key = "market_haggle_intro"
	if shop then intro_key = "shop_haggle_intro" end
	SetLabel("character_text", GetMerchantDialogue(intro_key, char, building))
	
	-- Prepare player labels: shuffle and assign
	for i=1,4 do
		local j = RandRange(1,4)
		local t = options[i]
		options[i] = options[j]
		options[j] = t
	end
	for i=1,4 do
	
		DebugOut("HAGGLE", "OPTION "..tostring(options[i][1]).."/"..tostring(options[i][2]))	
	
		local n = "market_haggle_"
		if shop then n = "shop_haggle_" end
		if options[i][1] then n = n .. "good_"
		else n = n .. "bad_"
		end
		
		if options[i][2] then n = n .. "soft_"
		else n = n .. "hard_"
		end
		
		n = GetRandomHaggleString(n)
		--DebugOut(n)	
		SetLabel("player"..i, n)
	end
end

-------------------------------------------------------------------------------

local function EndHaggle(response, result)
	gHaggleSuccess = result
	if result == "good" then SoundEvent("positive_haggle")
	elseif result == "bad" then SoundEvent("negative_haggle")
	end
	FadeCloseWindow("ui_haggle", response)
end

local function Select(nSelect)
	-- Disable buttons
	EnableWindow("select1", false)
	EnableWindow("select2", false)
	EnableWindow("select3", false)
	EnableWindow("select4", false)
	EnableWindow("haggle_cancel", false)
	
	-- Hide alternate responses
	EnableWindow("character_text", false)
	for i=1,4 do
		if nSelect ~= i then EnableWindow("player"..i, false) end
	end

	-- Determine haggle results
	local good = options[nSelect][1]
	local soft = options[nSelect][2]
	local result = building:ComputeHaggle(char, good, soft)

	-- Adjust mood impact based on difficulty
    local haggle_mood_delta = 4 -- Base value from Character.lua
    if Player.difficulty == 2 then -- Medium
        haggle_mood_delta = 8
    elseif Player.difficulty == 3 then -- Hard
        haggle_mood_delta = 15
    end

	-- Characters respond to haggles
	if soft then
		if result == "good" then
			char:BumpHappiness(haggle_mood_delta)
		else
			-- Neutral or bad result with soft language has a smaller penalty
			char:BumpHappiness(-haggle_mood_delta)
		end
	else
		-- Hard language is always very punishing to the relationship
		char:BumpHappiness(-haggle_mood_delta * 2)
	end
	
	-- Select an appropriate response for the keeper
	local response_key
	local base_key = "market_haggle_response_"
	if shop then base_key = "shop_haggle_response_" end
	response_key = base_key .. result
	
	-- Special case for pushed luck, which overrides the normal response
	if result == "bad" and haggleSucceededOnce then
		response_key = base_key .. "pushedluck"
	end

    -- Get the actual dialogue string using the key we just built
    local response = GetMerchantDialogue(response_key, char, building)
    
    -- Now, properly end the haggle sequence with the result and the response text
    EndHaggle(response, result)
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		x=241,y=59, name="ui_haggle", image="image/popup_back_haggle",
		
		SetStyle(C3CharacterDialogStyle),
		Text { x=63,y=7,w=338,h=62, name="character_text", font={dialogBodyFont[1], dialogBodyFont[2], WhiteColor} },
		Text { x=122,y=80,w=276,h=47, name="player1" },
		Text { x=122,y=123,w=276,h=47, name="player2" },
		Text { x=122,y=169,w=276,h=47, name="player3" },
		Text { x=122,y=214,w=276,h=47, name="player4" },
		Text { x=122,y=257,w=276,h=47, name="cancel_text", label="cancel" },
		
		SetStyle(C3SmallRoundButtonStyle),
		Button { x=52,y=71, name="select1", command=function() Select(1) end },
		Button { x=52,y=71+44, name="select2", command=function() Select(2) end },
		Button { x=52,y=71+2*44, name="select3", command=function() Select(3) end },
		Button { x=52,y=71+3*44, name="select4", command=function() Select(4) end },
		Button { x=52,y=71+4*44, name="haggle_cancel", command=EndHaggle, cancel=true },
	}
}
FillOptions()