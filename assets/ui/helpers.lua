--[[---------------------------------------------------------------------------
	Chocolatier Three: UI Helpers
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

function QueueCommand(command)
	table.insert(gCommandQueue, command)
end

function CreateObject(class, t)
	t = t or {}
	setmetatable(t, class)
	class.__index = class
	return t
end

--------------------------------------------------------------------------------------------------
-- LOCALIZATION FORMATTING OVERRIDES
--------------------------------------------------------------------------------------------------

-- [TODO, MICHAEL @ 2025 MODDING] Override the C++ Dollars function. This will need to be able to grab the localized money based strings. The ledger must be able to update the money at any time, decked out with a money rolling animation, even when the ledger is not the active UI in the player's control, which is something that the original C++ had handled. For now, the original Dollars made in C++ in the encrypted/compiled .exe is in charge.

-- Override the C++ Date function
function Date(weeks)
    -- Game starts June 27, 1946.
    local start_year = 1946
    
    -- Calculate the day offset for June 27th in a non-leap year (1946).
    -- Jan(31) + Feb(28) + Mar(31) + Apr(30) + May(31) = 151 days.
    -- 151 + 27 = 178.
    local start_day_offset = 178
    
    -- Calculate total days elapsed since the start of the game.
    local days_elapsed = (weeks - 1) * 7
    
    -- Current absolute day relative to Jan 1st of the start year
    local days_remaining = start_day_offset + days_elapsed
    local current_year = start_year
    
    -- Helper function for Leap Year logic
    -- Returns true if year is a leap year
    local function IsLeapYear(y)
        -- Leap if divisible by 4, UNLESS divisible by 100 but NOT 400
        return (Mod(y, 4) == 0) and ((Mod(y, 100) ~= 0) or (Mod(y, 400) == 0))
    end
    
    -- 1. Determine the Year
    -- Subtract days year by year, accounting for leap years
    while true do
        local days_in_this_year = 365
        if IsLeapYear(current_year) then
            days_in_this_year = 366
        end
        
        if days_remaining <= days_in_this_year then
            break -- We have found the current year
        end
        
        days_remaining = days_remaining - days_in_this_year
        current_year = current_year + 1
    end
    
    -- 2. Determine the Month and Day
    local months = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local month_index = 1
    
    for i, standard_days in ipairs(months) do
        local days_in_month = standard_days
        
        -- Adjust February for leap years
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
    
    -- 3. Localization and Formatting (Data-Driven)
    
    -- Get localized month string from XML
    -- EN: "January", JA: "1月"
    local month_key = "month_" .. month_index 
    local month_str = GetString(month_key)
    if month_str == "#####" then month_str = tostring(month_index) end 

    -- Format using the XML pattern
    -- Pass: %1% = Month Name, %2% = Day, %3% = Year
    -- EN XML: "%1% %2%, %3%"      -> "January 1, 1946"
    -- JA XML: "%3%年%1%%2%日"     -> "1946年1月1日" (Because month_str includes '月')
    return GetText("date_format", month_str, tostring(day), tostring(current_year))
end

--------------------------------------------------------------------------------------------------
-- Ledger

function UpdateActiveQuestGoalsComplete()
	if SetLedgerQuestIndicator then
		local mode = "off"
		local q = Player:GetPrimaryQuest()
		if q then
			local allgood,allhints = q:AreGoalsMet()
			if allgood then
				if allhints then mode = "on"
				else mode = "flash"
				end
			end
		end
		SetLedgerQuestIndicator(mode)
	end
end

function UpdateLedgerFactoryCovers()
	EnableWindow("zur_factory_cover", not zur_factory:IsOwned())
	EnableWindow("cap_factory_cover", not cap_factory:IsOwned())
	EnableWindow("san_factory_cover", not san_factory:IsOwned())
	EnableWindow("tok_factory_cover", not tok_factory:IsOwned())
	EnableWindow("wel_factory_cover", not wel_factory:IsOwned())
	EnableWindow("tor_factory_cover", not tor_factory:IsOwned())
end

function UpdateLedger(type)
    DebugOut("UI", "UpdateLedger called. Type: " .. (type or "nil"))

	local data=""
	if type == "factory" or type == "newplayer" then UpdateLedgerFactoryCovers() end
	if type == "quest" or type == "newplayer" then
		local label = Player.questPrimary
		if label then
			local q = _AllQuests[label]
			data = q:GetSummary()
			if (data == "#####") or (not data) then data = ""
			else
				DebugOut("UI", "SUMMARY LENGTH:"..tostring(string.len(data)))
				if (string.len(data) > 120) then data = "<font size='11'>"..data
				elseif (string.len(data) > 110) then data = "<font size='13'>"..data
				end
			end
		end
	end
	
	if RealUpdateLedger then RealUpdateLedger(type,data) end
	UpdateActiveQuestGoalsComplete()
end

--------------------------------------------------------------------------------------------------
-- Help

function HelpDialog(key,mainmenu)
	DisplayDialog { "ui/ui_help.lua", helpScreen=key, mainmenu=mainmenu }
end

--------------------------------------------------------------------------------------------------
-- NEW ROBUST STRING SYSTEM
-- (Rest of the file remains unchanged from your previous versions)
-- GetText() for parameters, GetString() for simple lookups only

local bsgLoadStringFile = bsgLoadStringFile
local bsgGetString = bsgGetString
local _originalGetString = GetString

-- String caches
local _textCache = {}
local _baseStringCache = {}

-- Get base string without parameters (internal use)
local function GetBaseString(key)
	if _baseStringCache[key] then
		return _baseStringCache[key]
	end
	
	local text = bsgGetString(key)
	
	if text == "" or text == nil then
		local success, result = pcall(function()
			return _originalGetString(key)
		end)
		
		if success and result and result ~= "" and result ~= key then
			text = result
		else
			text = nil
		end
	end
	
	_baseStringCache[key] = text
	return text
end

-- Process difficulty variations
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

-- Process numbered parameters
local function ProcessParameters(text, params)
	if not params or params.n == 0 then
		return text
	end
	
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

-- Process named placeholders
local function ProcessNamedPlaceholders(text)
	return string.gsub(text, "%%([^%%%d%.%$,;:!%?%s].-)%%", function(a)
		if string.match(a, "^[%a_][%w_]*$") then
			local subtext = GetBaseString(a)
			if subtext then
				return subtext
			end
		end
		return "%"..a.."%"
	end)
end

--------------------------------------------------------------------------------------------------
-- PUBLIC API

-- NEW: GetText - Use this for any string with parameters
function GetText(key, ...)
    if type(key) == "number" then 
        return tostring(key) 
    end
	
	-- Build cache key
	local cacheKey = key
	if arg and arg.n > 0 then
		cacheKey = key .. ":"
		for i = 1, arg.n do
			cacheKey = cacheKey .. tostring(arg[i]) .. "|"
		end
	end
	
	if _textCache[cacheKey] then
		return _textCache[cacheKey]
	end
	
	local text = GetBaseString(key)
	
	if not text then
		text = string.gsub(key, "_", " ")
		if arg and arg.n > 0 then
			-- Don't include parameters in fallback to avoid confusion
		end
		return text
	end
	
	text = ProcessDifficulty(text)
	text = ProcessParameters(text, arg)
	text = ProcessNamedPlaceholders(text)
	text = string.gsub(text, "%%%%", "%%")
	
	_textCache[cacheKey] = text
	return text
end

-- Override GetString to be safe
function GetString(key, ...)
	-- Redirect to GetText if parameters are provided
	if arg and arg.n > 0 then
		return GetText(key, unpack(arg))
	end
	
	-- Simple lookup only
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

-- Replacement for GetReplacedString
function GetTextReplaced(key, ...)
	local s = GetText(key, unpack(arg or {}))
	local temp = string.gsub(s, "<(.-)>", function(a) 
		return Player.stringTable[a] or "<"..a..">" 
	end)
	return temp
end

-- Keep for compatibility, but redirect
function GetReplacedString(key, ...)
	return GetTextReplaced(key, unpack(arg or {}))
end

--------------------------------------------------------------------------------------------------
-- Additional Helper Functions

-- Helper to determine if a quest is relevant to a specific building/character.
-- This filters out "Welcome" messages if the player already has enough stock.

local function IsQuestRelevantToBuilding(quest, building, character, baseKey)
	-- 1. Direct Character Link (Starter/Ender)
	-- If this person gave the quest or ends it, it's ALWAYS relevant.
	if quest:CanEnd(character) then return true end
	for _, s in ipairs(quest.starter) do if s == character then return true end end

	-- 2. Location Link (Is the quest happening in this port?)
	-- If the quest explicitly points to this building, it's relevant.
	local startB = _AllBuildings[quest.startbuilding]
	local endB = _AllBuildings[quest.endbuilding]
	if (startB and startB.port.name == building.port.name) then return true end
	if (endB and endB.port.name == building.port.name) then return true end

	-- 3. Inventory Link (Does this market sell stuff needed for the quest?)
	if building.inventory then 
		local function MarketSells(ingName)
			for _, stockIng in ipairs(building.inventory) do
				if stockIng.name == ingName then return true end
			end
			return false
		end

		-- Filter out common items so they don't trigger generic quest greetings constantly
		local commonIngredients = { sugar = true, milk = true, cacao = true, powder = true }
		
		-- Logic: If "Welcome", only flag relevant if player NEEDS items.
		-- If "Thanks", flag relevant if player BOUGHT items (need check skipped).
		local checkInventory = (baseKey == "market_welcome" or baseKey == "market_welcome_first")

		local function PlayerNeeds(ingName, requiredCount)
			if not checkInventory then return true end
			local have = Player.ingredients[ingName] or 0
			return have < requiredCount
		end

		-- Check Delivery Quests
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
		
		-- Check Standard Quest Goals
		local difficulty = GetQuestDifficulty(quest)
		local goals = quest.goals
		if difficulty == 2 and quest.goals_medium then goals = quest.goals_medium end
		if difficulty == 3 and quest.goals_hard then goals = quest.goals_hard end

		if goals then
			for _, req in ipairs(goals) do
				-- Check Ingredient Requirement
				if req.name and _AllIngredients[req.name] and MarketSells(req.name) then 
					if not commonIngredients[req.name] and PlayerNeeds(req.name, req.count or 1) then return true end
				end
				
				-- Check Product Requirement
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

function GetMerchantDialogue(baseKey, character, building, haggleResult, itemKey, isFirstVisit)
	if not baseKey or not character then return "..." end
	
    -- Repeat Visit Logic
    local isRepeatVisit = false
    -- Check timestamp before updating it
    if Player.buildingLastVisitTime and Player.buildingLastVisitTime[building.name] == Player.time then
        isRepeatVisit = true
    end
    Player.buildingLastVisitTime = Player.buildingLastVisitTime or {}
    Player.buildingLastVisitTime[building.name] = Player.time
	
    if isFirstVisit then
        -- Try specific character intro: market_welcome_bal_marketkeep_first
        local introKey = baseKey .. "_" .. character.name .. "_first"
        
        -- Check if variations exist (e.g. _1)
        if GetString(introKey .. "_1") ~= "#####" then
            local count = 1
            while GetString(introKey .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
            local finalKey = introKey .. "_" .. RandRange(1, count)
            
            DebugOut("DIALOGUE", "Forcing First Visit Intro: " .. finalKey)
            return GetReplacedString(finalKey)
        end
        
        -- If no character-specific intro exists, we fall through to the normal logic
        -- (which might pick a generic "first visit" line from Tier 4).
    end

    -- 1. Gather Contexts
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

    -- 2. Gather Environmental Context (Tips, Season, Holiday)
    local tipContext = nil
    local seasonContext = nil
    
    if itemKey then
        local item = _AllIngredients[itemKey]
        
        -- Tips
        if item and Player.activeTips then
            for _, tip in ipairs(Player.activeTips) do
                if tip.port == building.port.name and tip.item == itemKey then
                    tipContext = "tip_" .. tip.type
                    break
                end
            end
        end
        
        -- Seasonality
        if item then
            if item:IsInSeason() then seasonContext = "inseason"
            else seasonContext = "outofseason" end
        end
    end
    
    -- Holidays
    local holidayContext = nil
    if Player.currentHoliday and Player:IsHolidayActiveInPort(building.port.name) then
        holidayContext = Player.currentHoliday
    end
	
	local contextString = nil
    -- Note: isFirstVisit is handled in Priority Override, but we keep "first" here 
    -- as a fallback tag for generic lines if no character-specific intro exists.
    if isFirstVisit then contextString = "first"
    elseif isRepeatVisit and baseKey == "market_welcome" then contextString = "repeat"
    elseif (baseKey == "market_thanks" or baseKey == "shop_thanks") and haggleResult and (haggleResult == "bad" or haggleResult == "good") then
        contextString = "haggle_" .. haggleResult
    end
	
	-- 3. Build Candidate Pool
    local pool = {}
	local totalWeight = 0
	
	local function AddCandidate(k, w, o)
		if GetString(k .. "_1") ~= "#####" then
			table.insert(pool, { key=k, weight=w, obj=o })
			totalWeight = totalWeight + w
		end
	end

    -- WEIGHTING CONFIGURATION
    local W_QUEST = 50
    local W_ITEM  = 30
    local W_CHAR  = 25
    local W_TIP   = 15
    local W_VISIT = 10
    local W_BASE  = 1

    -- A. Quest Lines (Weight: 50)
	for _, quest in ipairs(relevantQuests) do
		local qName = quest.name
		if itemKey then
			AddCandidate(baseKey .. "_" .. qName .. "_" .. character.name .. "_" .. itemKey, W_QUEST, quest)
			AddCandidate(baseKey .. "_" .. qName .. "_" .. itemKey, W_QUEST, quest)
		end
		AddCandidate(baseKey .. "_" .. qName .. "_" .. character.name, W_QUEST, quest)
		AddCandidate(baseKey .. "_" .. qName, W_QUEST, quest)
	end
	
    -- B. Item Specifics + Seasonality (Weight: 40/30)
	if itemKey then
        if seasonContext then
            AddCandidate(baseKey .. "_" .. character.name .. "_" .. itemKey .. "_" .. seasonContext, 40)
            AddCandidate(baseKey .. "_" .. itemKey .. "_" .. seasonContext, 40)
        end
		AddCandidate(baseKey .. "_" .. character.name .. "_" .. itemKey, W_ITEM)
		AddCandidate(baseKey .. "_" .. itemKey, W_ITEM)
	end

    -- C. Character Personality & Holidays (Weight: 25)
    if holidayContext then
        AddCandidate(baseKey .. "_" .. holidayContext .. "_" .. character.name, 25)
        AddCandidate(baseKey .. "_" .. holidayContext, 25)
    end
    AddCandidate(baseKey .. "_" .. character.name, W_CHAR)

    -- D. Tips (Weight: 15)
	if tipContext and itemKey then
		AddCandidate(baseKey .. "_" .. tipContext .. "_" .. itemKey .. "_" .. character.name, W_TIP)
	end

    -- E. Visit Context (Weight: 10)
	if contextString then
		AddCandidate(baseKey .. "_" .. character.name .. "_" .. contextString, W_VISIT)
		AddCandidate(baseKey .. "_" .. contextString .. "_" .. character.name, W_VISIT)
		AddCandidate(baseKey .. "_" .. contextString, W_VISIT)
	end
	
    -- F. Base Fallback (Weight: 1)
	AddCandidate(baseKey, W_BASE)

	-- 4. Select Final String
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
        -- Total weight is 0. Strict Fallback.
        finalKey = baseKey .. "_1"
        if GetString(finalKey) == "#####" then finalKey = baseKey end
        
        if character and character.name then
             DebugOut("DIALOGUE", "WARNING: Hit generic fallback for " .. character.name .. " (Key: " .. baseKey .. ")")
        end
	end

	-- 5. Format String
	local finalString = GetReplacedString(finalKey, finalObj)
    
    if itemKey then
        local item = _AllIngredients[itemKey] or _AllProducts[itemKey]
        if item then
            finalString = string.gsub(finalString, "<item>", item:GetName())
            finalString = string.gsub(finalString, "%%" .. itemKey .. "%%", item:GetName())
        end
    end
    
    if Player.currentHoliday then
         finalString = string.gsub(finalString, "%%holiday%%", GetString("holiday_"..Player.currentHoliday))
    end

    if finalString == "#####" or finalString == nil then return "..." end
    return finalString
end

-- Helper for debug
function ClearStringCache()
	_textCache = {}
	_baseStringCache = {}
end

function GetStringCacheStats()
	local textCount = 0
	local baseCount = 0
	
	for k,v in pairs(_textCache) do
		textCount = textCount + 1
	end
	
	for k,v in pairs(_baseStringCache) do
		baseCount = baseCount + 1
	end
	
	return string.format("Text: %d, Base: %d", textCount, baseCount)
end

--------------------------------------------------------------------------------------------------
-- Building set-ups

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

-- Base wrapper for the C++ Transition engine
function DoTransition(style, t)
	if type(t) == "table" then
		t.window = t[1]
	else
		t = { window=tostring(t) }
	end
	t[1] = tostring(style)
    
    -- Apply default timing if not specified
    if not t.time then t.time = kUIAnimTime end
    
	Transition(t)
end

-- Standard Alpha Fade In
function FadeIn(t) 
    DoTransition("fadein", t) 
end

-- Standard Alpha Fade Out
function FadeOut(t) 
    DoTransition("fadeout", t) 
end

-- "Pop In" Effect: Centers the window and scales it up (Zoom)
-- This feels much more modern than a simple fade.
function CenterFadeIn(t)
    if type(t) ~= "table" then t = { window=tostring(t) } end
    
    -- 1. Force the window to the center instantly (time=0)
    DoTransition("center", { window=t.window, time=0 })
    
    -- 2. Trigger the Zoom In effect
    -- "zoomin" is defined in Transitions.h/cpp and handles scaling + fading
    DoTransition("zoomin", t) 
end

-- Legacy support for just centering without animation
function Center(t) 
    DoTransition("center", t) 
end

-- Specific transition for the "Zoom" effect (can be used manually)
function ZoomIn(t) 
    DoTransition("zoomin", t) 
end

-- Slide transition (Good for side panels like Ledger)
function SwipeFromLeft(t)
	if type(t) ~= "table" then t = { window=tostring(t) } end
	t.startx = t.startx or -500
	DoTransition("swipe", t)
end

-- Legacy "Swirl" effect (kept for compatibility with original cutscenes)
function SwirlIn(t)
	if type(t) ~= "table" then t = { window=tostring(t) } end
	t.path = t.path or { {-500,300},{-200,0},{150,0},{300,25},{500,100},{200,100},{150,50} }
	t.time = t.time or 400
	t[1] = "path"
	Transition(t)
end

-- The Standard "Close Dialog" function
-- Updated to lock input and close faster than it opened.
function FadeCloseWindow(name, value)
	local v = value
    
    -- Lock input immediately so user can't double-click close
	gButtonsDisabled = true
    
	Transition { 
        "fadeout", 
        window=name, 
        time=kUIExitTime, -- Faster exit
        alpha=0,          -- Target alpha (invisible)
        onend=function() 
            gButtonsDisabled=nil 
            CloseWindow(v) 
        end 
    }
end

-- Helper to force-close everything in case of UI stack errors
function CloseAllModals()
    DebugOut("UI", "Closing all modal windows to force UI reload.")
    local topWindow = GetTopModalWindow()
    while topWindow and topWindow:GetName() ~= "screen" do
        PopModal(topWindow:GetID())
        topWindow = GetTopModalWindow()
    end
end

function OpenBuilding(window, building)
	if gCurrentBuilding then
        -- If we are already inside a building context (e.g. swapping tabs),
        -- just center the new window instantly without a long animation.
		Center(window)
	else
		gCurrentBuilding = building
        -- Use our new "Pop In" effect for entering buildings
		CenterFadeIn(window)
	end
end