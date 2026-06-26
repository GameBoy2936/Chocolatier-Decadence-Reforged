--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Haggle Dialog)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

require("ui/helpers.lua")

-------------------------------------------------------------------------------
-- Initialization & Context
-------------------------------------------------------------------------------

local char = gDialogTable.char
local market = gDialogTable.market
local shop = gDialogTable.shop
local building = market or shop
local pushedLuck = gDialogTable.pushedLuck

-- A matrix defining the four valid player interaction combinations.
-- { isGood/Polite, isSoft/Yielding }
local options = { {true, true}, {true, false}, {false, true}, {false, false} }

-------------------------------------------------------------------------------
-- String Resolution & Parsing
-------------------------------------------------------------------------------

-- Retrieves a random variation of a string key, parsing metadata tags automatically.
local function GetRandomHaggleString(baseKey)
	local count = 1
	
	-- We iterate through the raw XML data (using GetString, not GetReplacedString)
	-- to see how many randomized variations of this specific line exist.
	while GetString(baseKey .. (count + 1)) ~= "#####" do
		count = count + 1
	end
	
	-- Select a variation dynamically
	local randomIndex = RandRange(1, count)
	local rawText = GetString(baseKey .. randomIndex)
	
	-- Execute Named Placeholder Substitution (e.g., swapping {character_honorific})
	if rawText and rawText ~= "#####" then
		local map = {}
		
		local charTokens = GetCharacterTokens(char, "character_")
		if charTokens then
			for k, v in pairs(charTokens) do map[k] = v end
		end
		
		map["building"] = GetString(building.name)
		map["port"] = GetString(building.port.name)
		
		local result = string.gsub(rawText, "{(.-)}", function(key)
			return map[key] or "{" .. key .. "}"
		end)
		
		-- Legacy Player Name hook Support
		if string.find(result, "<player>") then
			result = string.gsub(result, "<player>", Player.name or "")
		end
		
		return result
	end

	return rawText
end

-------------------------------------------------------------------------------
-- Option Generation & Layout
-------------------------------------------------------------------------------

local function FillOptions()
	-- 1. Select initial merchant dialogue challenge
	local intro_key = "market_haggle_intro"
	if shop then intro_key = "shop_haggle_intro" end
	
	-- 50% chance to use the aggressive "Pushed Luck" intro if the player is doubling down
	if pushedLuck and RandRange(1, 2) == 1 then
		intro_key = intro_key .. "_pushluck"
	end
	
	SetLabel("character_text", GetMerchantDialogue(intro_key, char, building))
	
	-- 2. Shuffle the positions of the four interaction choices
	for i = 1, 4 do
		local j = RandRange(1, 4)
		local t = options[i]
		options[i] = options[j]
		options[j] = t
	end
	
	-- 3. Resolve localized strings for the shuffled buttons
	for i = 1, 4 do
		DebugOut("HAGGLE", string.format("Generated Player Haggle Option %d: Polite=%s | Soft=%s", i, tostring(options[i][1]), tostring(options[i][2])))
	
		local n = "market_haggle_"
		if shop then n = "shop_haggle_" end
		
		if options[i][1] then n = n .. "good_"
		else n = n .. "bad_"
		end
		
		if options[i][2] then n = n .. "soft_"
		else n = n .. "hard_"
		end
		
		-- If doubling down, source the aggressive variations 50% of the time
		if pushedLuck and RandRange(1, 2) == 1 then
			n = n .. "pushluck_"
		end
		
		n = GetRandomHaggleString(n)
		SetLabel("player" .. i, n)
	end
end

-------------------------------------------------------------------------------
-- Execution & Callbacks
-------------------------------------------------------------------------------

-- Safely shuts down the UI overlay and broadcasts the event outcome.
local function EndHaggle(response, result)
	gHaggleSuccess = result
	if result == "good" then 
		SoundEvent("positive_haggle")
	elseif result == "bad" then 
		SoundEvent("negative_haggle")
	end
	FadeCloseWindow("ui_haggle", response)
end

-- Fired when the player makes their selection
local function Select(nSelect)
	-- Disable buttons to prevent spam clicks
	EnableWindow("select1", false)
	EnableWindow("select2", false)
	EnableWindow("select3", false)
	EnableWindow("select4", false)
	EnableWindow("haggle_cancel", false)
	
	-- Hide all unselected responses for visual clarity
	EnableWindow("character_text", false)
	for i = 1, 4 do
		if nSelect ~= i then EnableWindow("player" .. i, false) end
	end

	-- Run the mathematical resolution against the merchant's personality matrix
	local good = options[nSelect][1]
	local soft = options[nSelect][2]
	local result = building:ComputeHaggle(char, good, soft)

	-- Mood Delta Scales: Higher difficulties punish mistakes more severely.
	local haggle_mood_delta = 4 
	if Player.difficulty == 2 then 
		haggle_mood_delta = 8
	elseif Player.difficulty == 3 then 
		haggle_mood_delta = 15
	end

	-- Apply psychological results to the merchant's relationship tracker
	if soft then
		if result == "good" then
			char:BumpHappiness(haggle_mood_delta)
		else
			-- Gentle communication mitigates some of the anger of a failed haggle
			char:BumpHappiness(-haggle_mood_delta)
		end
	else
		-- Hardball communication is inherently riskier and more alienating
		char:BumpHappiness(-haggle_mood_delta * 2)
	end
	
	-- Formulate the merchant's final retort
	local response_key
	local base_key = "market_haggle_response_"
	if shop then base_key = "shop_haggle_response_" end
	
	response_key = base_key .. result
	
	if result == "bad" and pushedLuck then
		response_key = base_key .. "pushedluck"
	end

	local response = GetMerchantDialogue(response_key, char, building)
	EndHaggle(response, result)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		x = 241, y = 59, name = "ui_haggle", image = "image/popup_back_haggle",
		
		SetStyle(C3CharacterDialogStyle),
		Text { x = 63, y = 7, w = 338, h = 62, name = "character_text", font = { dialogBodyFont[1], dialogBodyFont[2], WhiteColor } },
		
		Text { x = 122, y = 80, w = 276, h = 47, name = "player1", font = { uiFontName, 15, BlackColor } },
		Text { x = 122, y = 123, w = 276, h = 47, name = "player2", font = { uiFontName, 15, BlackColor } },
		Text { x = 122, y = 169, w = 276, h = 47, name = "player3", font = { uiFontName, 15, BlackColor } },
		Text { x = 122, y = 214, w = 276, h = 47, name = "player4", font = { uiFontName, 15, BlackColor } },
		
		Text { x = 122, y = 257, w = 276, h = 47, name = "cancel_text", label = "cancel", font = { labelFontName, 22, BlackColor } },
		
		SetStyle(C3SmallRoundButtonStyle),
		Button { x = 52, y = 71, name = "select1", command = function() Select(1) end },
		Button { x = 52, y = 71 + 44, name = "select2", command = function() Select(2) end },
		Button { x = 52, y = 71 + 2 * 44, name = "select3", command = function() Select(3) end },
		Button { x = 52, y = 71 + 3 * 44, name = "select4", command = function() Select(4) end },
		Button { x = 52, y = 71 + 4 * 44, name = "haggle_cancel", command = EndHaggle, cancel = true },
	}
}

FillOptions()