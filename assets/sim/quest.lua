--[[--------------------------------------------------------------------------
	Chocolatier Three: Quest engine
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Quest" is a task for the player to complete

kDefaultPriority = 9999

Quest =
{
	name = nil,					-- Name of the quest
	starter = nil,				-- Quest start character
	ender = nil,				-- Quest end character
	priority = kDefaultPriority,	-- Quest priority (1 is "forceOffer")
    isReal = nil,               -- Explicitly override the IsReal() auto-detection. Set to true or false

	accept = "quest_accept",	-- "Accept" label, default:"quest_accept"
	defer = "quest_defer",		-- "Defer" label, default:"quest_defer" -- Use "none" to disallow deferring the quest
	reject = "quest_reject",	-- default:"quest_reject" -- Use "none" to disallow rejecting the quest
	
	accept_length = nil,		-- Optional: "medium" or "long" for the accept button
	defer_length = nil,			-- Optional: "medium" or "long" for the defer button
	reject_length = nil,		-- Optional: "medium" or "long" for the reject button
	
	require = {},				-- set of quest pre-requisites
	goals = {},					-- set of quest goals
	
	onaccept = {},				-- set of "gifts" to apply when player accepts quest
	onreject = {},				-- set of "gifts" to apply when player rejects quest
	ondefer = {},				-- set of "gifts" to apply when player defers quest
	oncomplete = {},			-- set of "gifts" to apply when player completes quest
	onincomplete = {},			-- set of "gifts" to apply when player receives the "incomplete" message for a quest
	
	oncomplete_label = nil,		-- Optional: Custom label for the completion dialog's "Ok" button
	oncomplete_label_length = nil,
	onincomplete_label = nil,	-- Optional: Custom label for the incomplete dialog's "Ok" button
	onincomplete_label_length = nil,
	
	expires = nil,				-- number of weeks before quest expires
	onexpire = {},				-- set of "gifts" to apply when the quest expires
	
	followup = nil,				-- NAME of next quest in the quest chain, offerred immediately after completing this quest
	visible = true,				-- make this quest visible/invisible in the quest log (default: true)
	repeatable = nil,			-- make this quest repeatable after N weeks (default: not repeatable)
	
	autoComplete = nil,		-- auto-complete this quest as soon as it is accepted
}

Quest.__tostring = function(t) return "{Quest:"..tostring(t.name).."}" end

_AllQuests = {}
_NoStarterQuests = {}
_AllVariableNames = {}		-- On load, initially a set of <name=true>; converted to a sorted array after load

------------------------------------------------------------------------------
-- Player-specific accessors

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Quest:Create(t)
	if not t then
		-- TODO: WARN: Generic error
	elseif not t.name then
		-- TODO: WARN: No Name given
	elseif _AllQuests[t.name] then
		-- TODO: WARN: Quest already defined
	else
        gCurrentQuestBeingBuilt = t.name -- NEW: Set the global to the name of the quest being created.
--		DebugOut("QUEST:"..tostring(t.name))
        DebugOut("LOAD", "Created quest definition: " .. t.name)
		
		setmetatable(t, self) self.__index = self
		_AllQuests[t.name] = t
		
		-- Make sure starter and ender are tables
		if type(t.starter) ~= "table" then t.starter = { t.starter } end
		if not t.ender then t.ender = t.starter end
		if type(t.ender) ~= "table" then t.ender = { t.ender } end
		
		-- Check for "is real" condition
		if (t.priority == kDefaultPriority) and (not t:IsReal()) then
			DebugOut("MARKING 'NON-REAL' QUEST: "..tostring(t.name))
			t.priority = kDefaultPriority + 1
		end
	end
	return t
end

function CreateQuest(t) return Quest:Create(t) end

function LoadQuests()
	-- Get a list of quest definition files from the system
	local t = {}
	LoadQuestFileList(t)
	
	-- Load each quest definition file (and associated string file if available) in the list
	for _,fileName in ipairs(t) do
        gCurrentQuestBeingBuilt = nil -- Reset before each file
		dofile(fileName)
        -- The string file loading is now handled by Player:ReloadStrings()
	end
    gCurrentQuestBeingBuilt = nil -- Clear it when done.
	
	-- Convert the _AllVariableNames array from <name>=true to a sorted list of variable names
	-- and add a special "ugr_slots" variable
	local vars = {}
	_AllVariableNames.ugr_slots = true
	_AllVariableNames.ownphone = true
	_AllVariableNames.ownplane = true
	for name,_ in pairs(_AllVariableNames) do table.insert(vars,name) end
	table.sort(vars, function(a,b) return a < b end)
	_AllVariableNames = vars
	
	-- Cross check all quests
	for _,q in pairs(_AllQuests) do q:CrossCheck() end
end

------------------------------------------------------------------------------
-- Load post-processing

function PrepareCharactersForQuests()
	for _,quest in pairs(_AllQuests) do
		if table.getn(quest.starter) == 0 then
			table.insert(_NoStarterQuests, quest)
		end
		
		for i,char in ipairs(quest.starter) do
			if type(char) == "string" then
				char = _AllCharacters[char] or CreateCharacter(char)
				quest.starter[i] = char
			end
			char:AddStartQuest(quest)
		end
		for i,char in ipairs(quest.ender) do
			if type(char) == "string" then
				char = _AllCharacters[char] or CreateCharacter(char)
				quest.ender[i] = char
			end
			char:AddEndQuest(quest)
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function GetQuestDifficulty(quest)
    if quest and Player.questsActive[quest.name] and Player.questDifficulty[quest.name] then
        -- If the quest is active and has a stored difficulty, use that.
        return Player.questDifficulty[quest.name]
    end
    -- Otherwise, use the player's current global difficulty.
    return Player.difficulty or 1
end

local function EvaluateRequirementList(requirements, quest)
	local allgood = true
	local allhints = true
	for _,req in ipairs(requirements) do
		if not req.hint then allhints = false end
		if req.Evaluate and (not req:Evaluate(quest)) then allgood = false end
	end
	return allgood,allhints
end

local function ApplyGiftList(gifts)
	local iterator =
	{
		t = gifts or {},
		n = 0,
	}
	function iterator:go()
		local somethingHappened = false
		
		-- Run through the gift list until there's an Apply function that tells me to stop...
		local cont = true
		while (cont and self.n < table.getn(self.t)) do
			self.n = self.n + 1
			local gift = self.t[self.n]
			if gift.Apply then
				local somethingJustHappened
				cont,somethingJustHappened = gift:Apply(self)
				somethingHappened = somethingHappened or somethingJustHappened
			end
		end
		return somethingHappened
	end
	
	return iterator:go()
end

local function PreApplyHappinessChanges(gifts, character)
    if not gifts or not character then return end
    for _, gift in ipairs(gifts) do
        -- Look for an AwardHappiness action that targets the character who is about to speak.
        if gift.type == "AwardHappiness" and gift.name == character.name then
            DebugOut("QUEST", "Pre-applying happiness change for " .. character.name .. " before showing dialogue.")
            gift:Apply() -- Apply the happiness change immediately.
        end
    end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Quest cross check

local function CrossCheckQuestFunctions(t,name)
	for _,f in ipairs(t) do
		if f.CrossCheck then
			local result = f:CrossCheck()
			if result then
				DebugOut(name .. " - ERROR - "..result)
			end
		end
	end
end

function Quest:CrossCheck()
	if table.getn(self.require) > 0 then CrossCheckQuestFunctions(self.require, self.name) end
	if table.getn(self.goals) > 0 then CrossCheckQuestFunctions(self.goals, self.name) end
	if table.getn(self.onaccept) > 0 then CrossCheckQuestFunctions(self.onaccept, self.name) end
	if table.getn(self.onreject) > 0 then CrossCheckQuestFunctions(self.onreject, self.name) end
	if table.getn(self.ondefer) > 0 then CrossCheckQuestFunctions(self.ondefer, self.name) end
	if table.getn(self.oncomplete) > 0 then CrossCheckQuestFunctions(self.oncomplete, self.name) end
	if table.getn(self.onincomplete) > 0 then CrossCheckQuestFunctions(self.onincomplete, self.name) end
	if table.getn(self.onexpire) > 0 then CrossCheckQuestFunctions(self.onexpire, self.name) end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Quest string retrieval

function Quest:GetTimingContext()
    -- This helper is the single source of truth for determining if a quest
    -- is completed early, late, etc. It returns a string suffix like "_early".

    local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
    
    -- First, determine the deadline for difficulty scaling
    local deadline = self.expires
    if Player.questDifficulty[self.name] == 2 and self.expires_medium then deadline = self.expires_medium end
    if Player.questDifficulty[self.name] == 3 and self.expires_hard then deadline = self.expires_hard end

    if deadline then
        -- CASE 1: The quest has a hard deadline.
        local weeksLeft = deadline - weeksPassed
        if weeksPassed == 0 then return "_very_early"
        elseif weeksLeft >= (deadline * 0.75) then return "_early"
        elseif weeksLeft <= (deadline * 0.25) and deadline > 4 then return "_late"
        elseif weeksLeft <= 2 and deadline > 4 then return "_very_late"
        end
    else
        -- CASE 2: The quest has NO deadline. Use fixed time windows.
        if weeksPassed == 0 then return "_very_early"
        elseif weeksPassed <= 6 then return "_early" -- Within 6 weeks is considered early.
        elseif weeksPassed >= 26 then return "_late" -- Over 6 months is late.
        elseif weeksPassed >= 52 then return "_very_late" -- Over a year is very late.
        end
    end

    return "" -- Default to no specific timing context if none of the above match.
end

function Quest:GetQuestString(key)
    -- This is the original, simple string lookup function.
    -- It is used for non-dialogue text like titles and summaries.
    local difficulty = GetQuestDifficulty(self)
    local difficulty_key = nil
    if difficulty == 2 then
        difficulty_key = self.name .. "_medium" .. (key or "")
    elseif difficulty == 3 then
        difficulty_key = self.name .. "_hard" .. (key or "")
    end

    if difficulty_key then
        local text = GetReplacedString(difficulty_key, self)
        if text ~= "#####" then
            -- Found a difficulty-specific string, so use it.
            return text
        end
    end

	-- If no difficulty-specific string was found, fall back to the default.
	local text = self.name .. (key or "")
	text = GetReplacedString(text, self)
	if text == "#####" then return nil
	else return text
	end
end

function Quest:GetDynamicQuestString(baseKey, character)
    -- This is our new, powerful helper for dynamic, context-aware dialogue.
    local char = character or self:GetEnder() or self:GetStarter()
    if not char then return self:GetQuestString("_" .. baseKey) end -- Fallback for safety

    -- 1. Determine timing context.
    local timing_suffix = ""
    if baseKey == "incomplete" or baseKey == "expired" or baseKey == "complete" then
        timing_suffix = self:GetTimingContext()
    end

    -- Helper function for intelligent key construction
    local function construct_key(prefix, suffix)
        if suffix == prefix or string.sub(suffix, 1, string.len(prefix) + 1) == (prefix .. "_") then
            return suffix
        else
            return prefix .. "_" .. suffix
        end
    end

    -- 2. Build the list of potential keys, from most specific to most generic.
    local keys_to_try = {}
    
    if timing_suffix ~= "" then
        table.insert(keys_to_try, self.name .. "_" .. baseKey .. timing_suffix .. "_" .. char.name)
        table.insert(keys_to_try, self.name .. "_" .. baseKey .. timing_suffix)
    end
    
    table.insert(keys_to_try, construct_key(self.name, baseKey) .. "_" .. char.name)
    table.insert(keys_to_try, construct_key(self.name, baseKey))
    
    -- 3. Find the best available base key.
    local finalBaseKey = nil
    for _, key in ipairs(keys_to_try) do
        if GetString(key .. "_1") ~= "#####" then
            finalBaseKey = key
            break
        end
    end

    if not finalBaseKey then
        DebugOut("DIALOGUE", "No valid string variations found for base '"..baseKey.."' on quest '"..self.name.."'. Returning nil.")
        return nil
    end

    -- 4. Count variations for the found key and select one at random.
    local count = 1
    while GetString(finalBaseKey .. "_" .. (count + 1)) ~= "#####" do
        count = count + 1
    end
    local finalKey = finalBaseKey .. "_" .. RandRange(1, count)

    DebugOut("DIALOGUE", "GetDynamicQuestString called for base '"..baseKey.."' on quest '"..self.name.."'. Final key: '"..finalKey.."'")

    return GetReplacedString(finalKey, self)
end

function Quest:GetDynamicExtraTextString(fullKey, character)
    -- This is a specialized helper for AwardText. It assumes 'fullKey' is the complete base key.
    local char = character or self:GetEnder() or self:GetStarter()
    if not char then return GetReplacedString(fullKey) end -- Fallback for safety

    -- 1. Build a simplified list of keys to try.
    local keys_to_try = {}
    
    -- Most specific: A version for this specific character.
    table.insert(keys_to_try, fullKey .. "_" .. char.name)
    
    -- Generic fallback: The key as-is.
    table.insert(keys_to_try, fullKey)

    -- 2. Find the best available base key.
    local finalBaseKey = nil
    for _, key in ipairs(keys_to_try) do
        if GetString(key .. "_1") ~= "#####" then
            finalBaseKey = key
            break
        end
    end

    if not finalBaseKey then
        DebugOut("DIALOGUE", "No valid string variations found for extra text key '"..fullKey.."'. Returning nil.")
        return nil -- No variations found at all.
    end

    -- 3. Count variations for the found key and select one at random.
    local count = 1
    while GetString(finalBaseKey .. "_" .. (count + 1)) ~= "#####" do
        count = count + 1
    end
    local finalKey = finalBaseKey .. "_" .. RandRange(1, count)

    DebugOut("DIALOGUE", "GetDynamicExtraTextString called for key '"..fullKey.."'. Final key: '"..finalKey.."'")

    return GetReplacedString(finalKey, self)
end

function Quest:GetDynamicHintString(character)
    -- This is our new, optimized helper specifically for hints.
    local char = character or self:GetStarter()
    if not char then return nil end

    -- For Delivery Quests, hints are ONLY given by the quest starter (the shopkeeper).
    if self.delivery then
        if char ~= self:GetStarter() then
            -- If the character speaking is not the one who gave the order, they don't give a hint.
            return nil
        end
    end

    -- 1. Build a simplified, prioritized list of keys to try.
    local keys_to_try = {}
    
    -- Most specific: A hint from this specific character.
    table.insert(keys_to_try, self.name .. "_hint_" .. char.name)
    
    -- Generic fallback: The standard hint for this quest.
    table.insert(keys_to_try, self.name .. "_hint")

    -- 2. Find the best available base key.
    local finalBaseKey = nil
    for _, key in ipairs(keys_to_try) do
        if GetString(key .. "_1") ~= "#####" then
            finalBaseKey = key
            break
        end
    end

    if not finalBaseKey then return nil end -- No hint found.

    -- 3. Count variations for the found key and select one at random.
    local count = 1
    while GetString(finalBaseKey .. "_" .. (count + 1)) ~= "#####" do
        count = count + 1
    end
    local finalKey = finalBaseKey .. "_" .. RandRange(1, count)

    DebugOut("DIALOGUE", "GetDynamicHintString found hint for '"..self.name.."' with key: '"..finalKey.."'")
    return GetReplacedString(finalKey, self)
end

function Quest:GetTitle() return self:GetQuestString("") or tostring(self).." TITLE" end
function Quest:GetSummary() return self:GetQuestString("_summary") end
function Quest:GetIntro() return self:GetDynamicQuestString("offer", self:GetStarter()) end
function Quest:GetCompleteString() return self:GetDynamicQuestString("complete", self:GetEnder()) end
function Quest:GetIncompleteString() return self:GetDynamicQuestString("incomplete", self:GetEnder()) end
function Quest:GetExpiredString()
    local expiredText = self:GetDynamicQuestString("expired", self:GetEnder())
    if expiredText then
        return expiredText
    else
        -- Fallback to the generic expiration message if no specific one is found
        return GetString("generic_quest_expired")
    end
end
function Quest:GetHint()
	return self:GetDynamicHintString(nil)
end

function Quest:DoStringDialog(char, key, building)
	local text = self:GetQuestString(key) -- Uses the simple lookup, which is fine for this generic function.
	if text then
		local result = DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..text, building=building }
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Quest:IsActive()
	return (Player.questsActive[self.name] ~= nil)
end

function Quest:GetStarter()
	local char = Player.questStarters[self.name]
	if char then char = _AllCharacters[char]
	elseif self.starter then char = self.starter[1]
	end
	return char
end

function Quest:GetStarterName()
	local char = self:GetStarter()
	if char then return char.name
	else return nil
	end
end

function Quest:CanEnd(char)
	for _,ender in ipairs(self.ender) do
		if char == ender then return true end
	end
	return false
end

function Quest:GetEnder()
	local char = self.ender[1]
	if not char then char = self:GetStarter() end
	return char
end

function Quest:GetEnderName()
	local char = self:GetEnder()
	if char then return char.name
	else return nil
	end
end

function Quest:IsNotWaiting()
	-- Return true if this quest does NOT have a timer pending
	if Player.questsWaiting[self.name] then
		local waiting = (Player.questsWaiting[self.name] <= Player.time)
		return waiting
	else return true
	end
end

function Quest:Offer(char, building)
    local starterName = char and char.name or "System"
    DebugOut("QUEST", "Processing offer for quest '" .. self.name .. "' from starter '" .. starterName .. "'.")

	if self:IsReal() then Player.lastOfferTime = Player.time end

	-- Put together the appropriate buttons
	local quest = self
	if not char then char = self:GetStarter() end

    -- Get the offer text using our dynamic helper.
    local offerText = self:GetIntro()

    -- Check if any valid offer text was found.
    if not offerText or offerText == "" then
        -- SILENT ACCEPTANCE: No offer text exists for this quest.
        -- This is now a background quest. Accept it automatically without showing any UI.
        DebugOut("QUEST", "No offer text found for '" .. self.name .. "'. Accepting as a background quest.")
        self:Accept(char)
        return
    end

	-- If we have text, proceed with the normal UI display.
	if self.forceTelegram then
		-- If this flag is true, always use the telegram UI.
		DisplayDialog { "ui/ui_quest_telegram.lua", quest=self, building=building }
	elseif char then
		DisplayDialog { "ui/ui_quest_offer.lua", char=char, quest=self, building=building }
	else
		-- TODO: Offer quest with no starter character
		DisplayDialog { "ui/ui_quest_telegram.lua", quest=quest, building=building }
--		DisplayDialog { "ui/ui_quest_offer.lua", char=char, quest=quest, building=building }
	end
end

function Quest:Accept(char)
    DebugOut("QUEST", "Player ACCEPTED quest: " .. self.name)

	if self:IsReal() then Player.lastAcceptTime = Player.time end

	-- TODO: FIRST PEEK DATA
	Player.questsActive[self.name] = Player.time
	if char then Player.questStarters[self.name] = char.name
	else Player.questStarters[self.name] = nil
	end
	Player.questsComplete[self.name] = nil
	
	-- Lock in the quest's difficulty
    Player.questDifficulty[self.name] = Player.difficulty or 1
    DebugOut("DIFFICULTY", "Quest '" .. self.name .. "' locked in at difficulty level: " .. (Player.difficulty or 1))

	if self.visible and not self.autoComplete then gLastQuestAccepted = self end
--	local title = self:GetTitle()
--	if title then Player:QueueMessage("msg_quest_accept", title) end

    -- Select the correct onaccept list based on difficulty
    local difficulty = GetQuestDifficulty(self)
    local accept_list = self.onaccept
    if difficulty == 2 and self.onaccept_medium then
        accept_list = self.onaccept_medium
    elseif difficulty == 3 and self.onaccept_hard then
        accept_list = self.onaccept_hard
    end
    
    -- Pre-apply any happiness changes from the accept list.
    PreApplyHappinessChanges(accept_list, char)
	ApplyGiftList(accept_list, self)
	
	if self.autoComplete then self:Complete() end
	
	if gLastQuestAccepted then
		Player:SetPrimaryQuest(gLastQuestAccepted.name)
		gLastQuestAccepted = nil
	end
end

function Quest:Reject(char)
    DebugOut("QUEST", "Player REJECTED quest: " .. self.name)

	-- TODO: FIRST PEEK DATA
	Player.questsActive[self.name] = nil
	Player.questsComplete[self.name] = Player.time

--	local title = self:GetTitle()
--	if title then Player:QueueMessage("msg_quest_reject", title) end

	-- Select the correct onreject list based on difficulty
    local difficulty = GetQuestDifficulty(self) -- Uses global difficulty since quest isn't active
    local reject_list = self.onreject
    if difficulty == 2 and self.onreject_medium then
        reject_list = self.onreject_medium
    elseif difficulty == 3 and self.onreject_hard then
        reject_list = self.onreject_hard
    end
    
    -- Pre-apply any happiness changes from the reject list.
    PreApplyHappinessChanges(reject_list, char)
	ApplyGiftList(reject_list, self)
end

function Quest:IsComplete()
	return (Player.questsComplete[self.name] ~= nil)
end

function Quest:CanRepeat()
	-- A repeatable quest can repeat if the specified number of ticks have passed
	if self.repeatable == nil then return false end
	if Player.time >= ((Player.questsComplete[self.name] or 0) + self.repeatable) then return true
	else return false
	end
end

function Quest:Complete(char, building)
    DebugOut("QUEST", "Player COMPLETED quest: " .. self.name)

	local somethingHappened = false
	if self:IsReal() then Player.lastCompleteTime = Player.time end
	Player.questsWaiting[self.name] = nil
	
	-- FirstPeekQuestComplete(self)		-- FIRST PEEK

	if not char then char = self:GetEnder() end

    -- Determine timing context for selecting the correct reward list using the new helper.
    local timing_context = self:GetTimingContext()

    -- Select the correct reward list based on difficulty AND timing
    local difficulty = Player.questDifficulty[self.name] or Player.difficulty or 1
    local reward_list = self["oncomplete" .. timing_context] or self.oncomplete -- Try timed list first
    
    if difficulty == 2 and (self["oncomplete" .. timing_context .. "_medium"] or self.oncomplete_medium) then
        reward_list = self["oncomplete" .. timing_context .. "_medium"] or self.oncomplete_medium
    elseif difficulty == 3 and (self["oncomplete" .. timing_context .. "_hard"] or self.oncomplete_hard) then
        reward_list = self["oncomplete" .. timing_context .. "_hard"] or self.oncomplete_hard
    end

    -- Pre-apply any happiness changes from the selected reward list BEFORE showing dialogue.
    PreApplyHappinessChanges(reward_list, char)

	Player.questsActive[self.name] = nil
	Player.questsComplete[self.name] = Player.time
    Player.questDifficulty[self.name] = nil

	local text = self:GetCompleteString()
	local q = self.followup
	if q then q = _AllQuests[q] end
	if text and text ~= "" then
		if self:IsReal() then SoundEvent("quest_complete") end
		somethingHappened = true
		DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..text, building=building, ok=self.oncomplete_label, ok_length=self.oncomplete_label_length, mood=self.oncomplete_mood }
	end

	somethingHappened = ApplyGiftList(reward_list, self) or somethingHappened
	if q then
		somethingHappened = true
		q:Offer(nil, building)
	end
	
	if Player.questPrimary == self.name then Player:SetPrimaryQuest(nil) end
	return somethingHappened
end

function Quest:Incomplete(char, building)
	local somethingHappened = false

    local timing_context = self:GetTimingContext()
    local incomplete_list = self["onincomplete" .. timing_context] or self.onincomplete

    -- Pre-apply any happiness changes from the correct onincomplete list.
    PreApplyHappinessChanges(incomplete_list, char)

	local text = self:GetIncompleteString()
	if text and text ~= "" then
		somethingHappened = true
		DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..text, building=building, ok=self.onincomplete_label, ok_length=self.onincomplete_label_length, mood=self.onincomplete_mood }
	end
    
	ApplyGiftList(incomplete_list, self)
	return somethingHappened
end

function Quest:IsExpired()
    -- Select the correct expiration time based on difficulty
    local difficulty = GetQuestDifficulty(self)
    local expires_time = self.expires -- Default to Easy
    if difficulty == 2 and self.expires_medium then
        expires_time = self.expires_medium
    elseif difficulty == 3 and self.expires_hard then
        expires_time = self.expires_hard
    end

	if expires_time and (Player.time >= Player.questsActive[self.name] + expires_time) then return true
	else return false
	end
end

function Quest:Expire(char, building)
    DebugOut("QUEST", "Quest EXPIRED: " .. self.name)

	Player.questsWaiting[self.name] = nil
	local c = self:GetEnder()
	char = c or char

	Player.questsActive[self.name] = nil
	Player.questStarters[self.name] = nil
	Player.questsComplete[self.name] = Player.time
    
    local difficulty = Player.questDifficulty[self.name] or Player.difficulty or 1 -- Get locked difficulty before clearing
    Player.questDifficulty[self.name] = nil

	local text = self:GetExpiredString()
	DisplayDialog { "ui/ui_telegram.lua", char=char, text=text, building=building }
	
    -- Select the correct onexpire list based on difficulty
    local expire_list = self.onexpire
    if difficulty == 2 and self.onexpire_medium then
        expire_list = self.onexpire_medium
    elseif difficulty == 3 and self.onexpire_hard then
        expire_list = self.onexpire_hard
    end
	ApplyGiftList(expire_list, self)

	if Player.questPrimary == self.name then Player:SetPrimaryQuest(nil) end
end

function Quest:IsDeferred()
	if not Player.questsDeferred[self.name] then return false
	else return Player.questsDeferred[self.name] > Player.time
	end
end

function Quest:Defer(char, weeks)
	weeks = weeks or 4
	Player.questsDeferred[self.name] = Player.time + weeks
    DebugOut("QUEST", "Player DEFERRED quest '" .. self.name .. "' for " .. weeks .. " weeks.")

--	local title = self:GetTitle()
--	if title then Player:QueueMessage("msg_quest_defer", title) end
	
	-- Select the correct ondefer list based on difficulty
    local difficulty = GetQuestDifficulty(self) -- Uses global difficulty
    local defer_list = self.ondefer
    if difficulty == 2 and self.ondefer_medium then
        defer_list = self.ondefer_medium
    elseif difficulty == 3 and self.ondefer_hard then
        defer_list = self.ondefer_hard
    end

    -- Pre-apply any happiness changes from the defer list.
    PreApplyHappinessChanges(defer_list, char)
	ApplyGiftList(defer_list, self)
end

function Quest:IsHintEligible()
	-- A hint is eligible ONLY if all of these conditions are true:
	-- 1. The quest is currently active.
	if not self:IsActive() then return false end
	
	-- 2. A hint string actually exists for this quest.
	if not self:GetHint() then return false end
	
	-- 3. At least 12 weeks have passed since the quest was accepted.
	local timeElapsed = Player.time - (Player.questsActive[self.name] or Player.time)
	if timeElapsed < 12 then return false end
	
	-- 4. The hint is not on cooldown.
	local cooldownTime = Player.questHintCooldowns[self.name] or 0
	if Player.time < cooldownTime then return false end
	
	-- If all checks pass, the hint is eligible.
	return true
end

------------------------------------------------------------------------------
	
function Quest:IsEligible()
	-- Instantly ineligible if:
	--   Quests are globaly disabled
	--   Currently Active
	--   Already Completed, and not repeatable
	--   Deferred past the current time
	if Player.options.noQuests and (not self.alwaysAvailable) then return false end
	if self:IsActive() then return false end
	if self:IsDeferred() then return false end
	if self:IsComplete() then
		if not self:CanRepeat() then return false end
	end

    -- If any of these negative requirements are met, the quest is NOT eligible.
    if self.norequire and table.getn(self.norequire) > 0 then
        for _, noreq in ipairs(self.norequire) do
            if noreq.Evaluate and noreq:Evaluate(self) then
                -- This negative condition is true, so the quest is ineligible.
                return false
            end
        end
    end

    -- Select the correct requirement list based on difficulty
    local difficulty = GetQuestDifficulty(self)
    local require_list = self.require -- Default to Easy
    if difficulty == 2 and self.require_medium then
        require_list = self.require_medium
    elseif difficulty == 3 and self.require_hard then
        require_list = self.require_hard
    end

	return EvaluateRequirementList(require_list, self)
end

function Quest:IsReal()
    -- If a quest has an 'isReal' property defined, use its value directly.
    if self.isReal ~= nil then
        return self.isReal
    end

	-- A quest is considered "real" IF:
	--  It has a specifically set priority
	--  It is not autoComplete
	--  It is not repeatable
	--  It has either non-hint goals, onaccept, or oncomplete items
	local isReal = false
--	if (not self.autoComplete) and (self.repeatable == nil) then
	if self.repeatable == nil then
		if table.getn(self.onaccept) > 0 or table.getn(self.oncomplete) > 0 then isReal = true
		elseif (self.priority < kDefaultPriority) then isReal = true
		elseif table.getn(self.goals) > 0 then
			for _,req in ipairs(self.goals) do
				if not req.hint then isReal = true; break; end
			end
		end
	end
	if isReal and (string.find(self.name, "hint") or string.find(self.name, "tease")) then isReal = false end
	return isReal
end

function Quest:AreGoalsMet()
    -- Select the correct goal list based on difficulty
    local difficulty = GetQuestDifficulty(self)
    local goal_list = self.goals -- Default to Easy
    if difficulty == 2 and self.goals_medium then
        goal_list = self.goals_medium
    elseif difficulty == 3 and self.goals_hard then
        goal_list = self.goals_hard
    end

	local allgood,allhints = EvaluateRequirementList(goal_list, self)
	return allgood,allhints
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

DeliveryQuest =
{
	product = nil,			-- Product to deliver
	count = nil,			-- Number to deliver
	price = nil,			-- Money that will be paid
							-- Normal Quest ender indicates WHO to deliver to
	
	defer = "quest_defer",
	delivery = true,
}
setmetatable(DeliveryQuest, Quest)
DeliveryQuest.__index = DeliveryQuest
DeliveryQuest.__tostring = function(t) return "{DeliveryQuest:"..tostring(t.name).."}" end

function DeliveryQuest:IsEligible()
	-- Delivery Quests are not "eligible" under the normal rules
	return false
end

function GetDynamicDeliveryString(baseKey, quest, contextChar)
	-- 1. Safely gather all possible context.
	if not quest or not quest.product then return nil end
	
	local product = _AllProducts[quest.product]
	local ender = quest:GetEnder()
	local endBuilding = _AllBuildings[quest.endbuilding]
	local startBuilding = _AllBuildings[quest.startbuilding]
	local sender = startBuilding and startBuilding:GetCharacterList()[1] or nil

	if not product or not ender or not sender or not endBuilding then return nil end

	-- Determine the primary and secondary characters for the key lookup.
	local primaryChar, secondaryChar
	if contextChar and (baseKey == "delivery_incomplete" or string.find(baseKey, "delivery_incomplete_") or baseKey == "delivery_complete" or string.find(baseKey, "delivery_complete_") or baseKey == "delivery_expired" or string.find(baseKey, "delivery_expired_")) then
		primaryChar = contextChar
		secondaryChar = (primaryChar.name == sender.name) and ender or sender
	else
		primaryChar = (string.find(baseKey, "recipient")) and ender or sender
		secondaryChar = (primaryChar.name == sender.name) and ender or sender
	end
	
	local itemName = product:GetName()
	
	-- Calculate dynamic deadline (weeks remaining)
	local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
	local weeksLeft = (quest.expires or 0) - weeksPassed

	-- 2. Build the list of potential keys.
	local keys_to_try = {}
	
	local genericBaseKey = baseKey
	genericBaseKey = string.gsub(genericBaseKey, "_very_early", "")
	genericBaseKey = string.gsub(genericBaseKey, "_very_late", "")
	genericBaseKey = string.gsub(genericBaseKey, "_early", "")
	genericBaseKey = string.gsub(genericBaseKey, "_late", "")

	table.insert(keys_to_try, baseKey .. "_" .. primaryChar.name .. "_" .. product.code .. "_" .. secondaryChar.name)
	table.insert(keys_to_try, baseKey .. "_" .. primaryChar.name .. "_" .. product.code)
	table.insert(keys_to_try, baseKey .. "_" .. primaryChar.name)
	table.insert(keys_to_try, baseKey)

	if genericBaseKey ~= baseKey then
		table.insert(keys_to_try, genericBaseKey .. "_" .. primaryChar.name .. "_" .. product.code .. "_" .. secondaryChar.name)
		table.insert(keys_to_try, genericBaseKey .. "_" .. primaryChar.name .. "_" .. product.code)
		table.insert(keys_to_try, genericBaseKey .. "_" .. primaryChar.name)
		table.insert(keys_to_try, genericBaseKey)
	end

	-- 3. Find the best available key.
	local finalKey = baseKey
	for _, key in ipairs(keys_to_try) do
		if GetString(key .. "_1") ~= "#####" then
			local count = 1
			while GetString(key .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
			finalKey = key .. "_" .. RandRange(1, count)
			break
		end
	end

    DebugOut("DIALOGUE", "GetDynamicDeliveryString called for base '" .. baseKey .. "'. Final key chosen: '" .. finalKey .. "'.")

	-- 4. Format and return the string with standardized parameters.
	-- Standard parameters: count, product, recipient, salary, deadline, endBuilding, endPort, startBuilding, startPort, starter
	local finalString = GetText(finalKey,
		quest.count,                                         -- %1%
		itemName,                                            -- %2%
		GetString(ender.name),                               -- %3%
		Dollars(quest.price),                                -- %4%
		weeksLeft,                                           -- %5% DYNAMIC: weeks remaining, not total expires
		GetString(endBuilding.name),                         -- %6%
		GetString(endBuilding.port.name),                    -- %7%
		startBuilding and GetString(startBuilding.name) or "",  -- %8%
		startBuilding and GetString(startBuilding.port.name) or "", -- %9%
		sender and GetString(sender.name) or ""              -- %10%
	)

    if finalString == "#####" or finalString == nil then
        DebugOut("ERROR", "GetDynamicDeliveryString failed to find ANY valid string for base key: " .. baseKey)
        return nil
    end

    return finalString
end

function DeliveryQuest:GetTitle()
	local prod = _AllProducts[self.product]
	local ender = self:GetEnder()
	local endBuilding = _AllBuildings[self.endbuilding]
	local startBuilding = _AllBuildings[self.startbuilding]
	local starter = startBuilding and startBuilding:GetCharacterList()[1] or nil
	
	-- Standard parameters: count, product, recipient, salary, deadline, endBuilding, endPort, startBuilding, startPort, starter
	return GetText("delivery_title", 
		self.count,                                          -- %1%
		prod and prod:GetName() or "Unknown",                -- %2%
		GetString(ender.name),                               -- %3%
		Dollars(self.price),                                 -- %4%
		self.expires,                                        -- %5%
		GetString(endBuilding.name),                         -- %6%
		GetString(endBuilding.port.name),                    -- %7%
		startBuilding and GetString(startBuilding.name) or "",  -- %8%
		startBuilding and GetString(startBuilding.port.name) or "", -- %9%
		starter and GetString(starter.name) or ""            -- %10%
	)
end

function DeliveryQuest:GetIntro()
	-- Check if this is an in-person offer (not a telegram)
	if self.forceTelegram == false then
		-- Determine if this is sender or recipient offering
		local currentBuilding = gDialogTable and gDialogTable.building
		local offerKey
		
		if currentBuilding and currentBuilding.name == self.startbuilding then
			offerKey = "delivery_sender_offer"
		else
			offerKey = "delivery_recipient_offer"
		end
		
		-- Return the in-person dialogue string
		return GetDynamicDeliveryString(offerKey, self)
	end
	
	-- Otherwise, return the telegram format
	local prod = _AllProducts[self.product]
	local ender = self:GetEnder()
	local endBuilding = _AllBuildings[self.endbuilding]
	local startBuilding = _AllBuildings[self.startbuilding]
	local starter = startBuilding and startBuilding:GetCharacterList()[1] or nil
	
	-- Step 1: Gather telegram header components
	local to_str = GetText("telegram_to", Player.name)
	local where_str = ""
	local from_str = ""
	
	if startBuilding then
		where_str = GetString(startBuilding.name) .. " - " .. GetString(startBuilding.port.name)
		where_str = GetText("telegram_where", where_str)
		from_str = GetText("telegram_from", GetText(starter.name))
	end

	-- Step 2: Get body text with standardized parameters
	local body_text = GetText("delivery_intro",
		self.count,                                          -- %1%
		prod:GetName(),                                      -- %2%
		GetString(ender.name),                               -- %3%
		Dollars(self.price),                                 -- %4%
		self.expires,                                        -- %5%
		GetString(endBuilding.name),                         -- %6%
		GetString(endBuilding.port.name),                    -- %7%
		startBuilding and GetString(startBuilding.name) or "",  -- %8%
		startBuilding and GetString(startBuilding.port.name) or "", -- %9%
		starter and GetString(starter.name) or ""            -- %10%
	)
	
	-- Step 3: Assemble the final telegram
	local text = to_str.."<br>"..from_str.."<br>"..where_str.."<br><br>"..body_text
	return string.upper(text)
end

function DeliveryQuest:GetCompleteString()
	local ender = self:GetEnder()
	local baseKey = "delivery_complete"

	if ender then
		local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
		local weeksLeft = (self.expires or 0) - weeksPassed

        if weeksPassed == 0 then
            baseKey = "delivery_complete_very_early" -- Completed in the same week it was accepted
        elseif weeksLeft >= (self.expires * 0.99) then
            baseKey = "delivery_complete_early"
		elseif weeksLeft <= 2 and self.expires > 4 then
            baseKey = "delivery_complete_very_late"
		elseif weeksLeft <= (self.expires * 0.25) and self.expires > 4 then
            baseKey = "delivery_complete_late"
		end
	end
	
    -- Catalogue likes/dislikes discovery
    if ender then
        local charKey = ender.name
        local charCatalogueData = Player.catalogue.unlockedCharacters[charKey]
        
        -- Proceed only if the character has a catalogue entry and it's unlocked.
        if charCatalogueData and charCatalogueData.unlocked then
            local product = _AllProducts[self.product]
            local charObject = _AllCharacters[charKey]
            
            if product and charObject then
                DebugOut("CATALOGUE", "Processing special order completion for " .. charKey .. " to discover preferences.")
                
                -- 1. Discover LIKES based on the delivered product.
                if charObject.likes then
                    -- Check product category
                    if charObject.likes.categories and charObject.likes.categories[product.category.name] then
                        table.insert(charCatalogueData.discovered_likes, product.category.name)
                    end
                    -- Check specific product
                    if charObject.likes.products and charObject.likes.products[product.code] then
                        table.insert(charCatalogueData.discovered_likes, product.code)
                    end
                    -- Check ingredients
                    if charObject.likes.ingredients then
                        for ingredientName, _ in pairs(product.counts) do
                            if charObject.likes.ingredients[ingredientName] then
                                table.insert(charCatalogueData.discovered_likes, ingredientName)
                            end
                        end
                    end
                end

                -- 2. Discover one new DISLIKE from the undiscovered pool.
                if charCatalogueData.undiscovered_dislikes_pool and table.getn(charCatalogueData.undiscovered_dislikes_pool) > 0 then
                    -- Pick a random dislike from the pool
                    local randomIndex = RandRange(1, table.getn(charCatalogueData.undiscovered_dislikes_pool))
                    local discoveredDislike = table.remove(charCatalogueData.undiscovered_dislikes_pool, randomIndex)
                    
                    -- Add it to the discovered list
                    table.insert(charCatalogueData.discovered_dislikes, discoveredDislike)
                    DebugOut("CATALOGUE", "Discovered new dislike for " .. charKey .. ": " .. discoveredDislike)
                end

                -- 3. Clean up duplicates from the discovered lists to keep them tidy.
                local function removeDuplicates(t)
                    local seen = {}
                    local new_t = {}
                    for _, v in ipairs(t) do
                        if not seen[v] then
                            table.insert(new_t, v)
                            seen[v] = true
                        end
                    end
                    return new_t
                end

                charCatalogueData.discovered_likes = removeDuplicates(charCatalogueData.discovered_likes)
                DebugOut("CATALOGUE", charKey .. " now has " .. table.getn(charCatalogueData.discovered_likes) .. " discovered likes and " .. table.getn(charCatalogueData.discovered_dislikes) .. " discovered dislikes.")
            end
        end
    end
	
	local message = GetDynamicDeliveryString(baseKey, self, ender)
	return GetReplacedString("#"..message) 
end

function DeliveryQuest:GetIncompleteString()
    -- New timing-based key selection for incomplete dialogue
	local ender = self:GetEnder()
	local baseKey = "delivery_incomplete"
    local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
    local weeksLeft = (self.expires or 0) - weeksPassed

    if weeksPassed == 0 then
        baseKey = "delivery_incomplete_very_early"
    elseif weeksLeft <= 2 and self.expires > 4 then -- Only trigger "late" for quests with a reasonable deadline
        baseKey = "delivery_incomplete_very_late" 
    elseif weeksLeft <= (self.expires * 0.25) and self.expires > 4 then
        baseKey = "delivery_incomplete_late"
    end

	return GetDynamicDeliveryString(baseKey, self, self:GetEnder())
end

function DeliveryQuest:GetExpiredString()
	return GetDynamicDeliveryString("delivery_expired", self, self:GetEnder())
end

function DeliveryQuest:GetSummary()
	local prod = _AllProducts[self.product]
	local ender = self:GetEnder()
	local endBuilding = _AllBuildings[self.endbuilding]
	local startBuilding = _AllBuildings[self.startbuilding]
	local starter = startBuilding and startBuilding:GetCharacterList()[1] or nil
	
	-- Standard parameters: count, product, recipient, salary, deadline, endBuilding, endPort, startBuilding, startPort, starter
	return GetText("delivery_summary",
		self.count,                                          -- %1%
		prod:GetName(),                                      -- %2%
		GetString(ender.name),                               -- %3%
		Dollars(self.price),                                 -- %4%
		self.expires,                                        -- %5%
		GetString(endBuilding.name),                         -- %6%
		GetString(endBuilding.port.name),                    -- %7%
		startBuilding and GetString(startBuilding.name) or "",  -- %8%
		startBuilding and GetString(startBuilding.port.name) or "", -- %9%
		starter and GetString(starter.name) or ""            -- %10%
	)
end

function DeliveryQuest:GetSaveTable()
	local t = {}
	t.product = self.product
	t.count = self.count
	t.price = self.price
    t.starter = self:GetStarterName()
	t.ender = self:GetEnder().name
	t.endbuilding = self.endbuilding
	t.startbuilding = self.startbuilding
	t.expires = self.expires
	t.name = self.name
    t.isResident = self.isResident
    t.sourcePool = self.sourcePool
	t.forceTelegram = self.forceTelegram
	return t
end

function CreateDeliveryQuest(t, isResident, sourcePool)
	-- Clone the DeliveryQuest template to inherit default properties
	local q = {}
	for k, v in pairs(DeliveryQuest) do
		q[k] = v
	end
	setmetatable(q, DeliveryQuest)
	
	q.product = t.product
	q.count = t.count
	q.price = t.price
	q.startbuilding = t.startbuilding
	q.starter = { _AllCharacters[t.starter] }
	q.ender = { _AllCharacters[t.ender] }
	q.endbuilding = t.endbuilding
	q.endport = _AllBuildings[q.endbuilding].port.name
	q.expires = t.expires
	q.isResident = t.isResident or isResident
	q.sourcePool = t.sourcePool or sourcePool
	
	-- This flag will be true if the quest is generated by the weekly UpdateSpecialOrders
	-- and false if it's generated by an in-person offer.
	q.forceTelegram = t.forceTelegram or false
	
	q.goals = { RequireItem(q.product, q.count), HintPerson(q:GetEnder().name, q.endbuilding, q.endport), HintExpirationWeeks() }
	
	q.onaccept = {}
	q.onreject = {}
	q.oncomplete = { AwardItem(q.product, -q.count), AwardMoney(q.price) }
	q.onexpire = {}
	
    -- We will create separate reward tables for each timing context
    q.oncomplete_very_early = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, 75) }
    q.oncomplete_early = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, 50) }
    q.oncomplete_late = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, -10) }
    q.oncomplete_very_late = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, -20) }
    -- The default oncomplete table will have the standard "on time" happiness bump
    table.insert(q.oncomplete, AwardHappiness(t.ender, 30))

    -- Cleanup action to oncomplete and onexpire
    local cleanupAction = { Apply = function(self) Player.questOfferText[t.name] = nil; return true; end }
    table.insert(q.onreject, cleanupAction)
    table.insert(q.oncomplete, cleanupAction)
    table.insert(q.onexpire, cleanupAction)

	local is_non_resident = false
	local enderName = t.ender

	-- Check if the ender is in the master list of travelers
	for _, travName in ipairs(_TravelCharacters) do
		if travName == enderName then
			is_non_resident = true
			break
		end
	end

	-- If not a traveler, check if the ender is in the master list of empty characters
	if not is_non_resident then
		for _, emptyName in ipairs(_EmptyCharacters) do
			if emptyName == enderName then
				is_non_resident = true
				break
			end
		end
	end

	-- Now, use this reliable flag to add the cleanup actions.
	if is_non_resident then
		local source = q.sourcePool or "_empty"
        
        -- On Accept: Move the character from their source pool to the destination and ban them.
        table.insert(q.onaccept, AwardRemoveCharacter(t.ender, source))
        table.insert(q.onaccept, AwardPlaceCharacter(t.ender, t.endbuilding))
        table.insert(q.onaccept, AwardDisableOrderForChar(t.ender))
        table.insert(q.onaccept, AwardDisableOrderForBuilding(t.endbuilding))
		
		-- On Reject: Move the character back to their source pool and un-ban them.
		table.insert(q.onreject, AwardRemoveCharacter(t.ender, t.endbuilding))
		table.insert(q.onreject, AwardPlaceCharacter(t.ender, source))
        table.insert(q.onreject, AwardEnableOrderForChar(t.ender))
        table.insert(q.onreject, AwardEnableOrderForBuilding(t.endbuilding))

		-- On Complete: Also move the character back to their pool and un-ban them.
		table.insert(q.oncomplete, AwardRemoveCharacter(t.ender, t.endbuilding))
		table.insert(q.oncomplete, AwardPlaceCharacter(t.ender, source))
        table.insert(q.oncomplete, AwardEnableOrderForChar(t.ender))
        table.insert(q.oncomplete, AwardEnableOrderForBuilding(t.endbuilding))
		
		-- On Expire: Also move the character back and un-ban them.
		table.insert(q.onexpire, AwardRemoveCharacter(t.ender, t.endbuilding))
		table.insert(q.onexpire, AwardPlaceCharacter(t.ender, source))
        table.insert(q.onexpire, AwardEnableOrderForChar(t.ender))
        table.insert(q.onexpire, AwardEnableOrderForBuilding(t.endbuilding))
	end
	
	q.name = t.name
	_AllQuests[q.name] = q
	
	return q
end

function RandomDeliveryQuest(startShop)
	local t = {}
	
	-- Select starting character from the given shop, with fallback.
	if not startShop then
		local ownedShops = {}
		for name, _ in pairs(Player.buildingsOwned) do
			local b = _AllBuildings[name]
			if b and b.type == "shop" then
				table.insert(ownedShops, b)
			end
		end

		if table.getn(ownedShops) > 0 then
			startShop = ownedShops[RandRange(1, table.getn(ownedShops))]
		else
			-- Fallback for testing if no shops are owned.
			startShop = zur_shop 
		end
	end
	t.startbuilding = startShop.name
	
	local starterChar = startShop:GetCharacterList()[1]
    if starterChar then
        t.starter = starterChar.name
    end

	-- Logic for selecting an eligible end building and character
	local isResident = false
	local sourcePool = "_empty" -- Default source pool for non-residents

	-- 1. Gather all possible buildings from available ports, respecting the new ban list.
	local allBuildings = {}
	for name,port in pairs(_AllPorts) do
		if port:IsAvailable() then
			for _,b in ipairs(port.buildings) do
				-- Exclude special buildings, the starting shop, AND any banned buildings.
				if b.type ~= "special" and b.name ~= startShop.name and not Player.orderBannedBuildings[b.name] then
					table.insert(allBuildings, b)
				end
			end
		end
	end

	if table.getn(allBuildings) == 0 then return nil end
	local buildingIndex = RandRange(1, table.getn(allBuildings))
	local building = allBuildings[buildingIndex]
	t.endbuilding = building.name

	-- This block handles the 50/50 chance for special buildings.
	local forceNonResident = false
	local special_buildings = {
		zur_station = true,
		zur_school = true,
		hav_hotel = true,
		tan_hotel = true,
		san_bar = true,
	}

	if special_buildings[building.name] then
		if RandRange(1, 2) == 1 then
			forceNonResident = true
		end
	end

	-- 2. Determine the ender character based on the building type
	local enderCharObject = nil
	local charList = building:GetResidentCharacterList()
	if charList and table.getn(charList) > 0 and not forceNonResident then
		local eligibleResidents = {}
		for _, char in ipairs(charList) do
			if not Player.orderBannedChars[char.name] then
				table.insert(eligibleResidents, char)
			end
		end

		if table.getn(eligibleResidents) > 0 then
			local randomIndex = RandRange(1, table.getn(eligibleResidents))
			enderCharObject = eligibleResidents[randomIndex]
			t.ender = enderCharObject.name
			isResident = true
		end
	end
	
    if isResident and enderCharObject then
        local isTrueTraveler = false
        for _, travName in ipairs(_TravelCharacters) do
            if travName == enderCharObject.name then isTrueTraveler = true; break; end
        end
        if not isTrueTraveler then
            for _, emptyName in ipairs(_EmptyCharacters) do
                if emptyName == enderCharObject.name then isTrueTraveler = true; break; end
            end
        end

        if isTrueTraveler then
            isResident = false
            sourcePool = GetCharacterSourcePool(enderCharObject.name)
        end
    end
	
	if not isResident then
        if not enderCharObject or not isResident then
		    local filteredTravelers = {}
		    local travelerChars = _travelers:GetCharacterList()
		    for _, char in ipairs(travelerChars) do
			    if not Player.orderBannedChars[char.name] then
				    table.insert(filteredTravelers, char)
			    end
		    end

		    local filteredEmpty = {}
		    local emptyChars = _empty:GetCharacterList()
		    for _, char in ipairs(emptyChars) do
			    if not Player.orderBannedChars[char.name] then
				    table.insert(filteredEmpty, char)
			    end
		    end

		    local chosenPool = nil
		    if table.getn(filteredTravelers) > 0 and table.getn(filteredEmpty) > 0 then
			    if RandRange(1, 2) == 1 then
				    chosenPool = filteredTravelers
				    sourcePool = "_travelers"
			    else
				    chosenPool = filteredEmpty
				    sourcePool = "_empty"
			    end
		    elseif table.getn(filteredTravelers) > 0 then
			    chosenPool = filteredTravelers
			    sourcePool = "_travelers"
		    elseif table.getn(filteredEmpty) > 0 then
			    chosenPool = filteredEmpty
			    sourcePool = "_empty"
		    else
			    return nil -- No eligible non-residents available
		    end
		
		    local randomIndex = RandRange(1, table.getn(chosenPool))
		    enderCharObject = chosenPool[randomIndex]
		    t.ender = enderCharObject.name
		    isResident = false
        end
	end

	if not t.ender or not enderCharObject then
		return nil
	end

	-- Select a product for the order, now using preferences
	local products = {}
	
	local potentialProducts = {}
	for code,prod in pairs(_AllProducts) do
		if prod:IsKnown() then
			table.insert(potentialProducts, prod)
		end
	end

	local finalProductPool = {}
	if enderCharObject.likes and enderCharObject.likes.categories then
		local preferredProducts = {}
		local otherProducts = {}
		for _, prod in ipairs(potentialProducts) do
			if enderCharObject.likes.categories[prod.category.name] then
				table.insert(preferredProducts, prod.code)
			else
				table.insert(otherProducts, prod.code)
			end
		end

		if table.getn(preferredProducts) > 0 and RandRange(1, 100) <= 75 then
			finalProductPool = preferredProducts
		else
			finalProductPool = {}
            for _, prod in ipairs(potentialProducts) do table.insert(finalProductPool, prod.code) end
		end
	else
        for _, prod in ipairs(potentialProducts) do table.insert(finalProductPool, prod.code) end
	end
    
    products = finalProductPool
    
    local weightedProductList = {}
    local dislikes = enderCharObject.dislikes or {}
    local likes = enderCharObject.likes or {}

    for _, productCode in ipairs(products) do
        local product = _AllProducts[productCode]
        local isDisliked = false

        if dislikes.products and dislikes.products[product.code] then isDisliked = true end
        if not isDisliked and dislikes.categories and dislikes.categories[product.category.name] then isDisliked = true end
        if not isDisliked and dislikes.ingredients then
            for ingredientName, _ in pairs(product.counts) do
                if dislikes.ingredients[ingredientName] then isDisliked = true; break; end
            end
        end

        if not isDisliked then
            local weight = 1
            if likes.products and likes.products[product.code] then weight = weight + 4 end
            if likes.categories and likes.categories[product.category.name] then weight = weight + 2 end
            if likes.ingredients then
                for ingredientName, _ in pairs(product.counts) do
                    if likes.ingredients[ingredientName] then weight = weight + 1 end
                end
            end
            
            for i = 1, weight do
                table.insert(weightedProductList, product.code)
            end
        end
    end
    
    if table.getn(weightedProductList) == 0 then
        weightedProductList = products
    end

	if table.getn(weightedProductList) == 0 then return nil end
	
	t.product = weightedProductList[RandRange(1, table.getn(weightedProductList))]
	local product = _AllProducts[t.product]
	
	-- Choose a count based on player rank... 10-40 times player rank, meaning 20-200 basically
	t.count = Player.rank * RandRange(10,40)
	
	-- Special order will pay 3x the maximum product price
	t.price = Floor(product.price_high * 3) * t.count
	
	-- Randomize delivery time based on rank
	if Player.rank == 2 then t.expires = RandRange(16,20)
	elseif Player.rank == 3 then t.expires = RandRange(12,16)
	elseif Player.rank == 4 then t.expires = RandRange(10,14)
	elseif Player.rank == 5 then t.expires = RandRange(8,12)
	else t.expires = 8
	end
	t.expires = t.expires * 2
	
    if Player.difficulty == 2 then -- Medium
        t.count = Floor(t.count * 1.5)
        t.price = Floor(t.price * 0.9)
        t.expires = Floor(t.expires * 0.75)
    elseif Player.difficulty == 3 then -- Hard
        t.count = Floor(t.count * 2.0)
        t.price = Floor(t.price * 0.6)
        t.expires = Floor(t.expires * 0.5)
    end
	
	t.name = "delivery_"..tostring(t.count).."_"..t.product.."_"..tostring(Player.time)
	return CreateDeliveryQuest(t, isResident, sourcePool)
end

-- This function is called once per week by TickSim() to handle the per-shop
-- special order generation system.
function UpdateSpecialOrders()
    local function Max(a, b) if a > b then return a else return b end end
    local function Count(t) local c=0; for _ in pairs(t or {}) do c=c+1 end; return c end

    -- Do nothing if the player doesn't own any shops yet.
    if not Player.shopsOwned or Player.shopsOwned == 0 then return end

    -- NEW: Backlog throttle
    -- Skip generating if too many pending orders are already queued.
    -- Cap = floor(shopsOwned / 2), min 1.
    local pending = Player.pendingSpecialOrders or {}
    local pendingCount = Count(pending)  -- (was table.getn/pending #)
    local pendingCap = Max(1, Floor((Player.shopsOwned or 0) / 2))  -- (was math.max/math.floor)
    if pendingCount >= pendingCap then
        DebugOut("QUEST", string.format("Pending orders cap reached (%d/%d). Skipping generation this week.", pendingCount, pendingCap))
        return
    end

    -- 1. Calculate the balancing modifier. The more shops the player owns,
    -- the slower the chance increases for each individual shop to maintain game balance.
    local balance_modifier = 1.0 - ((Player.shopsOwned - 1) * 0.04)
    if balance_modifier < 0.20 then balance_modifier = 0.20 end -- Cap the penalty at 80%
    
    DebugOut("QUEST", string.format("Special Order Check: Player owns %d shops. Balance modifier is %.2f.", Player.shopsOwned, balance_modifier))

    -- 2a. Define the base chance increase per week. (WAS 5)
    local base_chance_increase = 3
    -- 2b. Define the cooldown period in weeks (WAS 8)
    local order_cooldown_duration = 12

    -- NEW: Rank dampener (higher rank => slightly slower ramp; min clamp 0.60)
    -- Rank 1 -> 1.00 ; Rank 5 -> 0.60
    local rank = Player.rank or 1
    local rank_damp = 1.0 - 0.10 * (rank - 1)
    if rank_damp < 0.60 then rank_damp = 0.60 end

    -- 3. Iterate through all buildings the player owns.
    for shopName, _ in pairs(Player.buildingsOwned) do
        local shop = _AllBuildings[shopName]
        -- Ensure the building is a shop and has its data initialized.
        if shop and shop.type == "shop" then
            -- Initialize data for a newly acquired shop if it doesn't exist
            if not Player.shopOrderData[shopName] then
                Player.shopOrderData[shopName] = { chance = 0, cooldown = 0 }
            end

            local data = Player.shopOrderData[shopName]
            
            -- Check if the shop is currently on cooldown.
            if data.cooldown and data.cooldown > Player.time then
                -- If the shop is on cooldown, do nothing this week.
                DebugOut("QUEST", string.format("%s is on cooldown. No order chance increase. (Ends week %d)", shop.name, data.cooldown))
            else
                -- If not on cooldown, proceed with chance increase and roll.
                if data.cooldown ~= 0 then
                    data.cooldown = 0 -- Ensure cooldown is cleared if it just expired
                    DebugOut("QUEST", string.format("%s cooldown has expired. Resuming order generation chance.", shop.name))
                end

                -- 4. Increase the shop's chance to generate an order.
                -- (WAS: base_chance_increase * balance_modifier)
                local chance_increase = base_chance_increase * balance_modifier * rank_damp
                local old_chance = data.chance or 0
                data.chance = old_chance + chance_increase
                
                DebugOut("QUEST", string.format(
                    "%s: Chance increased by %.2f%% (from %.2f%% to %.2f%%). [rank damp=%.2f]",
                    shop.name, chance_increase, old_chance, data.chance, rank_damp))

                -- 5. Roll the dice to see if an order should be generated this week.
                local roll = RandRange(1, 100)
                if roll <= data.chance or data.chance >= 100 then
                    if data.chance >= 100 then
                        DebugOut("QUEST", string.format("Roll for %s: FORCED (chance >= 100%%). Attempting to generate order.", shop.name))
                    else
                        DebugOut("QUEST", string.format("Roll for %s: %d <= %.2f. SUCCESS! Attempting to generate order.", shop.name, roll, data.chance))
                    end
                    
                    local orderQuest = RandomDeliveryQuest(shop)
                    
                    if orderQuest then
                        -- 6. If an order was successfully generated, store its DATA and place the character.
                        local questData = orderQuest:GetSaveTable()
                        questData.earlyOfferCutoff = Player.time + 6 -- Player has 6 weeks for an in-person offer.
                        
                        local isResident = false
                        local enderBuilding = _AllBuildings[questData.endbuilding]
                        if enderBuilding and enderBuilding.GetCharacterList then
                            for _, resident in ipairs(enderBuilding:GetCharacterList()) do
                                if resident.name == questData.ender then
                                    isResident = true
                                    break
                                end
                            end
                        end
            
                        if not isResident then
                            local sourcePool = "_empty" -- Default
                            for _, travName in ipairs(_TravelCharacters) do
                                if travName == questData.ender then
                                    sourcePool = "_travelers"
                                    break
                                end
                            end
                            questData.sourcePool = sourcePool
                            
                            DebugOut("QUEST", "Placing non-resident ender '" .. questData.ender .. "' at '" .. questData.endbuilding .. "' for pending order. Source: " .. sourcePool)
                            -- Directly manipulate Player state to move the character from their source pool.
                            if Player.buildingCharacters[sourcePool] then
                                Player.buildingCharacters[sourcePool][questData.ender] = nil
                            end
                            -- Place them in the destination building.
                            Player.buildingCharacters[questData.endbuilding] = Player.buildingCharacters[questData.endbuilding] or {}
                            Player.buildingCharacters[questData.endbuilding][questData.ender] = true
                            
                            -- Ban the character and building from receiving other orders while this one is pending.
                            Player.orderBannedChars[questData.ender] = true
                            Player.orderBannedBuildings[questData.endbuilding] = true
                        end
                        questData.isResident = isResident
                        
                        table.insert(Player.pendingSpecialOrders, questData)
                        DebugOut("QUEST", "Successfully generated and QUEUED special order data for: " .. orderQuest.name)
                        
                        -- Reset chance AND set the cooldown timer
                        data.chance = 0
                        data.cooldown = Player.time + order_cooldown_duration
                        DebugOut("QUEST", string.format("%s has generated an order. Cooldown set until week %d.", shop.name, data.cooldown))
                    else
                        DebugOut("QUEST", "Failed to generate order for " .. shop.name .. " (no suitable products?). Chance not reset.")
                    end
                else
                    DebugOut("QUEST", string.format("Roll for %s: %d > %.2f. No order generated this week.", shop.name, roll, data.chance))
                end
            end
        end
    end
end