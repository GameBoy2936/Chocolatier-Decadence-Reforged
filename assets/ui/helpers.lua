--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (UI Helpers & String Engine)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 1. General Object Utilities
-------------------------------------------------------------------------------

-- Queues an execution block to be processed cleanly on the next engine frame
function QueueCommand(command)
	table.insert(gCommandQueue, command)
end

-- Simulates basic Object-Oriented inheritance in Lua
function CreateObject(class, t)
	t = t or {}
	setmetatable(t, class)
	class.__index = class
	return t
end

-------------------------------------------------------------------------------
-- 2. Time & Date Formatting
-------------------------------------------------------------------------------

-- [TODO, MICHAEL @ 2026 MODDING] Override the C++ Dollars function. This will need to be able to grab the localized money based strings. The ledger must be able to update the money at any time, decked out with a money rolling animation, even when the ledger is not the active UI in the player's control, which is something that the original C++ had handled. For now, the original Dollars made in C++ in the encrypted/compiled .exe is in charge.

-- Overrides the C++ Date function to support dynamic multi-language localization.
-- Translates the raw simulation "Week" integer into a formatted string (e.g., "June 27, 1946").
function Date(weeks)
	-- Game canonical start date: June 27, 1946
	local start_year = 1946
	
	-- Calculate the day offset for June 27th in a standard non-leap year.
	-- Jan(31) + Feb(28) + Mar(31) + Apr(30) + May(31) = 151 days. (+27 = 178)
	local start_day_offset = 178
	
	-- Calculate total absolute days elapsed (1 week = 7 days)
	local days_elapsed = (weeks - 1) * 7
	local days_remaining = start_day_offset + days_elapsed
	local current_year = start_year
	
	local function IsLeapYear(y)
		return (Mod(y, 4) == 0) and ((Mod(y, 100) ~= 0) or (Mod(y, 400) == 0))
	end
	
	-- 1. Determine the exact Year by subtracting days
	while true do
		local days_in_this_year = 365
		if IsLeapYear(current_year) then
			days_in_this_year = 366
		end
		
		if days_remaining <= days_in_this_year then
			break
		end
		
		days_remaining = days_remaining - days_in_this_year
		current_year = current_year + 1
	end
	
	-- 2. Determine the exact Month and Day
	local months = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
	local month_index = 1
	
	for i, standard_days in ipairs(months) do
		local days_in_month = standard_days
		
		-- Adjust February length for leap years
		if i == 2 and IsLeapYear(current_year) then
			days_in_month = 29
		end
		
		if days_remaining <= days_in_month then
			month_index = i
			break
		else
			days_remaining = days_remaining - days_in_month
		end
	end
	
	local day = days_remaining
	
	-- 3. Localization and Formatting
	local month_key = "month_" .. month_index 
	local month_str = GetString(month_key)
	
	-- Failsafe: if the month string is missing, print the integer to avoid UI crashes
	if month_str == "#####" then month_str = tostring(month_index) end 

	-- Assemble the final localized date string using positional arguments
	-- EN: "%1% %2%, %3%"  -> "January 1, 1946"
	-- JA: "%3%年%1%%2%日" -> "1946年1月1日" 
	return GetText("date_format", month_str, tostring(day), tostring(current_year))
end

-------------------------------------------------------------------------------
-- 3. Ledger UI State Management
-------------------------------------------------------------------------------

function UpdateActiveQuestGoalsComplete()
	if SetLedgerQuestIndicator then
		local mode = "off"
		local q = Player:GetPrimaryQuest()
		
		if q then
			local allgood, allhints = q:AreGoalsMet()
			if allgood then
				-- If all goals are met AND all secret hints are fulfilled, lock solid green
				if allhints then mode = "on"
				-- Otherwise, flash to indicate progress is ready to turn in
				else mode = "flash"
				end
			end
		end
		SetLedgerQuestIndicator(mode)
	end
end

-- Toggles visibility of the brass covers over unowned factory Dookie Droppers
function UpdateLedgerFactoryCovers()
	EnableWindow("zur_factory_cover", not zur_factory:IsOwned())
	EnableWindow("cap_factory_cover", not cap_factory:IsOwned())
	EnableWindow("san_factory_cover", not san_factory:IsOwned())
	EnableWindow("tok_factory_cover", not tok_factory:IsOwned())
	EnableWindow("wel_factory_cover", not wel_factory:IsOwned())
	EnableWindow("tor_factory_cover", not tor_factory:IsOwned())
end

-- Master Ledger Refresh Hook
function UpdateLedger(type)
	local data = ""
	
	if type == "factory" or type == "newplayer" then 
		UpdateLedgerFactoryCovers() 
	end
	
	if type == "quest" or type == "newplayer" then
		local label = Player.questPrimary
		if label then
			local q = _AllQuests[label]
			data = q:GetSummary()
			
			if (data == "#####") or (not data) then 
				data = ""
			else
				-- Dynamically shrink the text if the quest summary is excessively long
				local strLen = string.len(data)
				if strLen > 160 then data = "<font size='11'>" .. data
				elseif strLen > 130 then data = "<font size='12'>" .. data
				elseif strLen > 110 then data = "<font size='13'>" .. data
				end
			end
		end
	end
	
	if RealUpdateLedger then RealUpdateLedger(type, data) end
	UpdateActiveQuestGoalsComplete()
end

-------------------------------------------------------------------------------
-- 4. Help Manual Hook
-------------------------------------------------------------------------------

function HelpDialog(key, mainmenu)
	DebugOut("UI", string.format("Opening Help Manual context: %s", key or "Root"))
	DisplayDialog { "ui/ui_help.lua", helpScreen = key, mainmenu = mainmenu }
end

-------------------------------------------------------------------------------
-- 5. Robust String System & Localization Engine
-------------------------------------------------------------------------------

local bsgLoadStringFile = bsgLoadStringFile
local bsgGetString = bsgGetString
local _originalGetString = GetString

local _textCache = {}
local _baseStringCache = {}

-- Flushes the memory caches. Essential when swapping languages mid-game.
function ClearStringCache()
	_textCache = {}
	_baseStringCache = {}
	DebugOut("LOAD", "Internal Lua string caches have been successfully flushed.")
end

-- Retrieves the raw XML string from the C++ layer securely.
local function GetBaseString(key)
	if _baseStringCache[key] then return _baseStringCache[key] end
	
	local text = bsgGetString(key)
	
	if text == "" or text == nil then
		local success, result = pcall(function() return _originalGetString(key) end)
		
		-- Filter out the C++ missing string error flag ("#####") 
		-- We NEVER cache "#####". This prevents missing strings from permanently poisoning the cache.
		if success and result and result ~= "" and result ~= key and result ~= "#####" then
			text = result
		else
			text = nil
		end
	end
	
	if text then _baseStringCache[key] = text end
	
	return text
end

-- Evaluates difficulty syntax tags inside strings: [D|easy|medium|hard]
local function ProcessDifficulty(text)
	return string.gsub(text, "%[D%|(.-)|(.-)|(.-)%]", function(easy, medium, hard)
		local difficulty = Player.difficulty or 1
		
		if gCurrentQuestBeingBuilt then
			difficulty = Player.difficulty or 1
		elseif gDetailQuest and Player.questDifficulty[gDetailQuest.name] then
			difficulty = Player.questDifficulty[gDetailQuest.name]
		end
		
		if difficulty == 3 then return hard
		elseif difficulty == 2 then return medium
		else return easy
		end
	end)
end

-- Evaluates positional argument tags inside strings: %1%, -->1<--
local function ProcessParameters(text, params)
	if not params or params.n == 0 then return text end
	
	local function replacePlaceholder(n)
		local index = tonumber(n)
		if params[index] ~= nil then
			if type(params[index]) == "table" and params[index].GetName then
				return params[index]:GetName()
			else
				return tostring(params[index])
			end
		else
			return ""
		end
	end
	
	text = string.gsub(text, "%%([%d]+)%%%-?", replacePlaceholder)
	text = string.gsub(text, "-->([%d]+)<--%-?", replacePlaceholder)
	return text
end

-- Recursively evaluates nested string references: %other_string_key%
local function ProcessNamedPlaceholders(text)
	return string.gsub(text, "%%([^%%%d%.%$,;:!%?%s].-)%%", function(a)
		if string.find(a, "^[%a_][%w_]*$") then
			local subtext = GetBaseString(a)
			if subtext then return subtext end
		end
		return "%" .. a .. "%"
	end)
end

-- Resolves {named_metadata} tags passed from contextual scripts (like tooltips)
function SubstituteTextParams(text, map)
	if not text or type(text) ~= "string" then return "" end

	local result = string.gsub(text, "{(.-)}", function(key)
		return map[key] or "{" .. key .. "}"
	end)
	
	-- Legacy player-name support
	if string.find(result, "<player>") then
		result = string.gsub(result, "<player>", Player.name or "")
	end

	return result
end

-------------------------------------------------------------------------------
-- 6. String Accessor Public API
-------------------------------------------------------------------------------

-- Advanced fetcher: Resolves complex nested arguments and caches the final compilation
function GetText(key, ...)
	-- Safety blocks to prevent execution failures on invalid calls
	if type(key) == "number" then return tostring(key) end
	if type(key) == "string" and string.find(key, "^%d+$") then return key end
	
	-- Hash a unique cache key based on the positional arguments
	local cacheKey = key
	if arg and arg.n > 0 then
		cacheKey = key .. ":"
		for i = 1, arg.n do
			cacheKey = cacheKey .. tostring(arg[i]) .. "|"
		end
	end
	
	if _textCache[cacheKey] then return _textCache[cacheKey] end
	
	local text = GetBaseString(key)
	
	if not text then
		text = string.gsub(key, "_", " ")
		return text
	end
	
	-- Process all formatting layers sequentially
	text = ProcessDifficulty(text)
	text = ProcessParameters(text, arg)
	text = ProcessNamedPlaceholders(text)
	text = string.gsub(text, "%%%%", "%%")
	
	_textCache[cacheKey] = text
	return text
end

-- Universal generic fetcher: Overrides the old C++ GetString function
function GetString(key, ...)
	if type(key) == "number" then return tostring(key) end
	if type(key) == "string" and string.find(key, "^%d+$") then return key end
	if key == nil then return "" end

	-- Redirect to the advanced parser if format arguments are detected
	if arg and arg.n > 0 then
		return GetText(key, unpack(arg))
	end
	
	local text = GetBaseString(key)
	if text then
		text = ProcessDifficulty(text)
		text = ProcessNamedPlaceholders(text)
		text = string.gsub(text, "%%%%", "%%")
		return text
	else
		return key
	end
end

-- Replaces bracketed variables with entries from the Player's string table
function GetTextReplaced(key, ...)
	local s = GetText(key, unpack(arg or {}))
	local temp = string.gsub(s, "<(.-)>", function(a) 
		return Player.stringTable[a] or "<" .. a .. ">" 
	end)
	return temp
end

function GetReplacedString(key, ...)
	return GetTextReplaced(key, unpack(arg or {}))
end

-- Randomly selects a variation of a base string key (e.g. key_1, key_2, key_3)
function GetRandomString(baseKey, ...)
	local count = 1
	while GetString(baseKey .. "_" .. (count + 1)) ~= "#####" do
		count = count + 1
	end
	
	local finalKey = baseKey
	if count > 1 or GetString(baseKey .. "_1") ~= "#####" then
		local index = RandRange(1, count)
		finalKey = baseKey .. "_" .. index
	end
	
	local text = GetString(finalKey, unpack(arg or {}))
	
	if text and string.find(text, "<player>") then
		text = string.gsub(text, "<player>", Player.name or "Chocolatier")
	end
	
	return text
end

-------------------------------------------------------------------------------
-- 7. Pluralization & Grammar Engine
-------------------------------------------------------------------------------

-- Computes the correct linguistic pluralization suffix based on numerical rules
function GetPluralSuffix(count, lang)
	-- Ensure count is absolute (math.abs isn't loaded globally here)
	if count < 0 then count = -count end
	lang = lang or "en"

	-- 1. NO PLURALIZATION AFTER NUMBERS (e.g., "1 Case", "5 Case")
	if lang == "ja" or lang == "zhs" or lang == "zht" or lang == "ko" or lang == "hu" or lang == "tr" or lang == "th" or lang == "vi" or lang == "id" or lang == "ms" then
		return "_other"
	end

	-- 2. POLISH (Complex fraction logic)
	if lang == "pl" then
		if count == 1 then return "_1" end
		local rem10 = Mod(count, 10)
		local rem100 = Mod(count, 100)
		if (rem10 >= 2 and rem10 <= 4) and (rem100 < 12 or rem100 > 14) then
			return "_2"
		else
			return "_5"
		end
	end

	-- 3. SLAVIC LANGUAGES (Russian, Ukrainian, Serbian, Croatian)
	if lang == "ru" or lang == "uk" or lang == "sr" or lang == "hr" then
		local rem10 = Mod(count, 10)
		local rem100 = Mod(count, 100)
		if rem10 == 1 and rem100 ~= 11 then
			return "_1"
		elseif (rem10 >= 2 and rem10 <= 4) and (rem100 < 12 or rem100 > 14) then
			return "_2"
		else
			return "_5"
		end
	end

	-- 4. ROMANIAN (20+ injection rule)
	if lang == "ro" then
		if count == 1 then return "_1" end
		local rem100 = Mod(count, 100)
		if count == 0 or (rem100 >= 1 and rem100 <= 19) then return "_2" end
		return "_20" 
	end

	-- 5. FRENCH (0 is singular)
	if lang == "fr" then
		if count <= 1 then return "_1" end
		return "_2"
	end

	-- 6. CZECH
	if lang == "cz" then
		if count == 1 then return "_1" end
		if count >= 2 and count <= 4 then return "_2" end
		return "_5"
	end

	-- DEFAULT (English, German, Spanish, Italian, Dutch, Nordic)
	-- 1 is singular. Everything else (0, 2, 3+) is plural.
	if count == 1 then return "_1" else return "_2" end
end

-- Fetches a unit string and dynamically modifies it for accurate grammar 
function GetLocalizedUnit(baseKey, count)
	local lang = Player.options.language or "en"
	local suffix = GetPluralSuffix(count, lang)
	
	local key = baseKey .. suffix
	local str = GetString(key)
	
	-- Hierarchy Fallback: If a language demands "_5" but the XML only defined "_2", cascade down safely.
	if str == "#####" then
		if GetString(baseKey .. "_2") ~= "#####" then return GetString(baseKey .. "_2") end
		if GetString(baseKey .. "_other") ~= "#####" then return GetString(baseKey .. "_other") end
		return GetString(baseKey .. "_1") 
	end
	
	return str
end

-------------------------------------------------------------------------------
-- 8. Dialogue Matrix Engine
-------------------------------------------------------------------------------

-- Determines if a specific quest currently holds relevance to the active building/NPC.
-- Prevents generic "Welcome to my market!" chatter if the player is here on an active quest.
local function IsQuestRelevantToBuilding(quest, building, character, baseKey)
	
	-- Relevance A: Identity Hooks
	if quest:CanEnd(character) then return true end
	for _, s in ipairs(quest.starter) do if s == character then return true end end

	-- Relevance B: Geographic Hooks
	local startB = _AllBuildings[quest.startbuilding]
	local endB = _AllBuildings[quest.endbuilding]
	if (startB and startB.port.name == building.port.name) then return true end
	if (endB and endB.port.name == building.port.name) then return true end

	-- Relevance C: Inventory Demand Hooks
	-- Scans the market's physical stock to see if they sell what the player needs.
	if building.inventory then 
		local function MarketSells(ingName)
			for _, stockIng in ipairs(building.inventory) do
				if stockIng.name == ingName then return true end
			end
			return false
		end

		-- We intentionally filter out extremely common items (Sugar, Milk) so they 
		-- don't artificially flag the market as "Quest Relevant" on every single visit.
		local commonIngredients = { sugar = true, milk = true, cacao = true, powder = true }
		local checkInventory = (baseKey == "market_welcome" or baseKey == "market_welcome_first")

		local function PlayerNeeds(ingName, requiredCount)
			if not checkInventory then return true end
			local have = Player.ingredients[ingName] or 0
			return have < requiredCount
		end

		-- Delivery Quest Checks
		if quest.product then
			local prod = _AllProducts[quest.product]
			if prod then
				for ingName, _ in pairs(prod.counts) do
					if MarketSells(ingName) and not commonIngredients[ingName] then 
						if PlayerNeeds(ingName, 1) then return true end
					end
				end
			end
		end
		
		-- Story Quest Goal Checks
		local difficulty = GetQuestDifficulty(quest)
		local goals = quest.goals
		if difficulty == 2 and quest.goals_medium then goals = quest.goals_medium end
		if difficulty == 3 and quest.goals_hard then goals = quest.goals_hard end

		if goals then
			for _, req in ipairs(goals) do
				if req.name and _AllIngredients[req.name] and MarketSells(req.name) then 
					if not commonIngredients[req.name] and PlayerNeeds(req.name, req.count or 1) then return true end
				end
				
				if req.code and _AllProducts[req.code] then
					local prod = _AllProducts[req.code]
					for ingName, _ in pairs(prod.counts) do
						if MarketSells(ingName) and not commonIngredients[ingName] then
							 if PlayerNeeds(ingName, 1) then return true end
						end
					end
				end
			end
		end
	end
	
	return false
end

-- The master probability matrix for contextual NPC dialogue generation.
function GetMerchantDialogue(baseKey, character, building, haggleResult, itemKey, isFirstVisit, itemCount)
	if not baseKey or not character then return "..." end
	
	-- 1. Visitation Tracking Context
	local isRepeatVisit = false
	if Player.buildingLastVisitTime and Player.buildingLastVisitTime[building.name] == Player.time then
		isRepeatVisit = true
	end
	Player.buildingLastVisitTime = Player.buildingLastVisitTime or {}
	Player.buildingLastVisitTime[building.name] = Player.time
	
	-- First-Visit Override Bypass
	if isFirstVisit then
		local introKey = baseKey .. "_" .. character.name .. "_first"
		if GetString(introKey .. "_1") ~= "#####" then
			local count = 1
			while GetString(introKey .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
			local finalKey = introKey .. "_" .. RandRange(1, count)
			
			DebugOut("DIALOGUE", string.format("Priority Override: Firing First-Visit Intro -> %s", finalKey))
			
			local map = { merchant = GetString(character.name), building = GetString(building.name), port = GetString(building.port.name) }
			return SubstituteTextParams(GetString(finalKey), map)
		end
	end

	-- 2. Scrape the world state for contextual hooks
	local relevantQuests = {}
	for questName, _ in pairs(Player.questsActive) do
		local quest = _AllQuests[questName]
		if quest then
			local isDelivery = (string.sub(quest.name, 1, 9) == "delivery_")
			if IsQuestRelevantToBuilding(quest, building, character, baseKey) then
				if not isDelivery or (isDelivery and (quest:GetStarter() == character or quest:GetEnder() == character)) then
					table.insert(relevantQuests, quest)
				end
			end
		end
	end

	local tipContext = nil
	local seasonContext = nil
	
	if itemKey then
		local item = _AllIngredients[itemKey]
		if item and Player.activeTips then
			for _, tip in ipairs(Player.activeTips) do
				if tip.port == building.port.name and tip.item == itemKey then
					tipContext = "tip_" .. tip.type
					break
				end
			end
		end
		if item then
			if item:IsInSeason() then seasonContext = "inseason" else seasonContext = "outofseason" end
		end
	end
	
	local holidayContext = nil
	if Player.currentHoliday and Player:IsHolidayActiveInPort(building.port.name) then
		holidayContext = Player.currentHoliday
	end
	
	local contextString = nil
	if isFirstVisit then contextString = "first"
	elseif isRepeatVisit and baseKey == "market_welcome" then contextString = "repeat"
	elseif (baseKey == "market_thanks" or baseKey == "shop_thanks") and haggleResult and (haggleResult == "bad" or haggleResult == "good") then
		contextString = "haggle_" .. haggleResult
	end
	
	-- 3. Construct probability pool and apply weights
	local pool = {}
	local totalWeight = 0
	
	local function AddCandidate(k, w, o)
		if GetString(k .. "_1") ~= "#####" then
			table.insert(pool, { key = k, weight = w, obj = o })
			totalWeight = totalWeight + w
		end
	end

	-- The Matrix Constants
	local W_QUEST = 50 -- Highest: The player is actively working on something
	local W_CHAR  = 25 -- High: Lore and Character flavor
	local W_ITEM  = 20 -- Moderate: Relevant to the specific item being transacted
	local W_TIP   = 15 -- Low/Moderate: Economic Gossip
	local W_VISIT = 10 -- Low: General greeting variations
	local W_BASE  = 5  -- Lowest: Generic fallback string

	for _, quest in ipairs(relevantQuests) do
		local qName = quest.name
		if itemKey then
			AddCandidate(baseKey .. "_" .. qName .. "_" .. character.name .. "_" .. itemKey, W_QUEST, quest)
			AddCandidate(baseKey .. "_" .. qName .. "_" .. itemKey, W_QUEST, quest)
		end
		AddCandidate(baseKey .. "_" .. qName .. "_" .. character.name, W_QUEST, quest)
		AddCandidate(baseKey .. "_" .. qName, W_QUEST, quest)
	end
	
	if itemKey then
		if seasonContext then
			AddCandidate(baseKey .. "_" .. character.name .. "_" .. itemKey .. "_" .. seasonContext, 40)
			AddCandidate(baseKey .. "_" .. itemKey .. "_" .. seasonContext, 40)
		end
		AddCandidate(baseKey .. "_" .. character.name .. "_" .. itemKey, W_ITEM)
		AddCandidate(baseKey .. "_" .. itemKey, W_ITEM)
	end

	if holidayContext then
		AddCandidate(baseKey .. "_" .. holidayContext .. "_" .. character.name, 25)
		AddCandidate(baseKey .. "_" .. holidayContext, 25)
	end
	
	AddCandidate(baseKey .. "_" .. character.name, W_CHAR)

	if tipContext and itemKey then
		AddCandidate(baseKey .. "_" .. tipContext .. "_" .. itemKey .. "_" .. character.name, W_TIP)
	end

	if contextString then
		AddCandidate(baseKey .. "_" .. character.name .. "_" .. contextString, W_VISIT)
		AddCandidate(baseKey .. "_" .. contextString .. "_" .. character.name, W_VISIT)
		AddCandidate(baseKey .. "_" .. contextString, W_VISIT)
	end
	
	AddCandidate(baseKey, W_BASE)

	-- 4. Roll the weighted dice
	local finalKey = nil
	local finalObj = nil
	
	if totalWeight > 0 then
		local roll = RandRange(1, totalWeight)
		local current = 0
		
		for _, cand in ipairs(pool) do
			current = current + cand.weight
			if roll <= current then
				local count = 1
				while GetString(cand.key .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
				finalKey = cand.key .. "_" .. RandRange(1, count)
				finalObj = cand.obj
				break
			end
		end
	else
		-- Critical Failsafe
		finalKey = baseKey .. "_1"
		if GetString(finalKey) == "#####" then finalKey = baseKey end
		DebugOut("DIALOGUE", string.format("WARNING: Matrix weight zero. Falling back to generic key: %s", baseKey))
	end

	-- 5. Format and Inject Tokens
	local rawText = GetString(finalKey)
	if rawText == "#####" or rawText == nil then return "..." end

	local map = {}
	
	-- Inject deep character metadata into the text format map
	local charTokens = GetCharacterTokens(character, "character_")
	for k, v in pairs(charTokens) do map[k] = v end
	
	local merchTokens = GetCharacterTokens(character, "merchant_")
	for k, v in pairs(merchTokens) do map[k] = v end

	map["merchant"] = map["character_name"]
	map["building"] = GetString(building.name)
	map["port"] = GetString(building.port.name)
	
	if itemKey then
		local item = _AllIngredients[itemKey] or _AllProducts[itemKey]
		if item then
			local unitPrice = item:GetPrice()
			local quantity = itemCount or 0
			map["item"] = item:GetName()
			map["quantity"] = tostring(quantity)
			map["price"] = Dollars(unitPrice)
			map["total_price"] = Dollars(unitPrice * quantity)

			local baseUnit = item.unit_singular or "sack"
			if _AllProducts[itemKey] then baseUnit = "case" end
			
			local baseUnitKey = "unit_" .. baseUnit
			map["unit"] = GetLocalizedUnit(baseUnitKey, quantity)
		end
	end

	-- Complete the substitution
	local finalString
	if finalObj and type(finalObj) == "table" and finalObj.name then
		if SubstituteQuestParams then
			finalString = SubstituteQuestParams(rawText, finalObj, character)
			finalString = SubstituteTextParams(finalString, map)
		else
			finalString = SubstituteTextParams(rawText, map)
		end
	else
		finalString = SubstituteTextParams(rawText, map)
	end

	return finalString
end

-------------------------------------------------------------------------------
-- 9. Display & Window Management API
-------------------------------------------------------------------------------

function OpenBuilding(window, building)
	if gCurrentBuilding then
		Center(window)
	else
		gCurrentBuilding = building
		CenterFadeIn(window)
	end
end

function DialogTransition()
	if type(gDialogTable.transition) == "function" then
		EnableWindow("background", false)
		EnableWindow("contents", false)
		gDialogTable.transition()
	else
		EnableWindow("background", true)
		EnableWindow("contents", true)
	end
end

function DoTransition(style, t)
	if type(t) == "table" then
		t.window = t[1]
	else
		t = { window = tostring(t) }
	end
	t[1] = tostring(style)
	Transition(t)
end

function FadeIn(t) DoTransition("fadein", t) end
function CenterFadeIn(t) DoTransition("center_fadein", t) end
function Center(t) DoTransition("center", t) end
function FadeOut(t) DoTransition("fadeout", t) end
function ZoomIn(t) DoTransition("zoomin", t) end

function SwipeFromLeft(t)
	if type(t) ~= "table" then t = { window = tostring(t) } end
	t.startx = t.startx or -500
	DoTransition("swipe", t)
end

function SwirlIn(t)
	if type(t) ~= "table" then t = { window = tostring(t) } end
	t.path = t.path or { {-500, 300}, {-200, 0}, {150, 0}, {300, 25}, {500, 100}, {200, 100}, {150, 50} }
	t.time = t.time or 400
	t[1] = "path"
	Transition(t)
end

function FadeCloseWindow(name, value)
	local v = value
	gButtonsDisabled = true
	Transition { 
		"fadeout", 
		window = name, 
		alpha = 1, 
		onend = function() 
			gButtonsDisabled = nil 
			CloseWindow(v) 
		end 
	}
end

function CloseAllModals()
	DebugOut("UI", "Closing all modal windows to force UI reload.")
	
	local topWindow = GetTopModalWindow()
	while topWindow and topWindow:GetName() ~= "screen" do
		PopModal(topWindow:GetID())
		topWindow = GetTopModalWindow()
	end
end