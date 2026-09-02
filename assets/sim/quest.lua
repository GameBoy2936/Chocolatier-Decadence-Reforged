--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Quest Engine)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Quest" is any tracked task, mission, or objective for the player to complete. 
-- This script contains the base class, the delivery subclass, and the procedural 
-- generation engine for special orders and dynamic market requests.

-- Priority 1 is "Force Offer". The default is set extremely high so background 
-- tasks yield to active story missions.
kDefaultPriority = 9999

Quest =
{
	-- ==========================================
	-- Identity & Routing
	-- ==========================================
	name = nil,					-- Internal key name of the quest (Must be unique)
	starter = nil,				-- Array of character objects who can offer the quest
	ender = nil,				-- Array of character objects who can receive the quest completion
	
	priority = kDefaultPriority,-- Quest priority (lower numbers = higher priority)
	isReal = nil,               -- Explicit override for IsReal() auto-detection (True/False)
	visible = true,				-- Toggles visibility in the player's UI quest ledger
	autoComplete = nil,			-- If true, the quest instantly completes upon acceptance
	
	followup = nil,				-- Internal name of the next quest in a chain to offer immediately
	repeatable = nil,			-- Cooldown (in weeks) before this quest can be offered again
	expires = nil,				-- Total weeks allowed before the quest automatically fails/expires
	
	-- ==========================================
	-- UI Label Overrides
	-- ==========================================
	-- Custom string keys for the buttons presented to the player during dialogues.
	accept = "quest_accept",	
	defer = "quest_defer",		-- Set to "none" to completely disable deferring
	reject = "quest_reject",	-- Set to "none" to completely disable rejection
	
	accept_length = "medium",		-- Optional: "medium" or "long" to resize the accept button
	defer_length = "medium",			
	reject_length = "medium",		
	
	oncomplete_label = nil,		
	oncomplete_label_length = nil,
	onincomplete_label = nil,	
	onincomplete_label_length = nil,
	
	-- ==========================================
	-- Logic Hooks & Conditions
	-- ==========================================
	-- These tables hold function references that the engine evaluates to determine
	-- if a quest can be offered, completed, or failed.
	require = {},				-- Array of prerequisites (Must evaluate True to offer)
	goals = {},					-- Array of goal conditions (Must evaluate True to complete)
	
	-- These tables execute code (giving items, money, happiness) when specific events happen.
	onaccept = {},				
	onreject = {},				
	ondefer = {},				
	oncomplete = {},			
	onincomplete = {},			
	onexpire = {},				
}

-- Metamethod for clean debug logging
Quest.__tostring = function(t) return "{Quest:" .. tostring(t.name) .. "}" end

-- Global Registries
_AllQuests = {}
_NoStarterQuests = {}		-- Background telegram quests (quests with no physical NPC starter)
_AllVariableNames = {}		-- Converts to a sorted array of global variables after the load phase

------------------------------------------------------------------------------
-- Creation & Initialization
------------------------------------------------------------------------------

-- Factory method: Parses a quest definition table and initializes it into the game engine
function Quest:Create(t)
	if not t then
		DebugOut("ERROR", "Quest:Create - Attempted to create a nil quest definition.")
	elseif not t.name then
		DebugOut("ERROR", "Quest:Create - Quest defined without a unique name. Ignoring.")
	elseif _AllQuests[t.name] then
		DebugOut("ERROR", string.format("Quest:Create - Duplicate quest name detected: %s", t.name))
	else
		-- Set global tracker for debugging nested loading errors inside data files
		gCurrentQuestBeingBuilt = t.name 
		DebugOut("LOAD", string.format("Quest:Create - Initializing definition: %s", t.name))
		
		setmetatable(t, self) 
		self.__index = self
		_AllQuests[t.name] = t
		
		-- Sanitize start/end character arrays to ensure they are always tables
		if type(t.starter) ~= "table" then 
			t.starter = { t.starter } 
		end
		
		if not t.ender then 
			t.ender = t.starter 
		end
		
		if type(t.ender) ~= "table" then 
			t.ender = { t.ender } 
		end
		
		-- Background quests with no physical triggers or rewards are pushed to low priority automatically
		if (t.priority == kDefaultPriority) and (not t:IsReal()) then
			DebugOut("QUEST", string.format("Marking '%s' as non-real (Background/Flavor). Demoting priority.", t.name))
			t.priority = kDefaultPriority + 1
		end
	end
	
	return t
end

-- Global wrapper
function CreateQuest(t) 
	return Quest:Create(t) 
end

-- Master function to load all quest data files from the system
function LoadQuests()
	DebugOut("LOAD", "Initiating quest data payload execution.")
	local t = {}
	
	-- Fetch array of filepaths from the C++ layer
	LoadQuestFileList(t)
	
	for _, fileName in ipairs(t) do
		gCurrentQuestBeingBuilt = nil 
		dofile(fileName)
		-- Note: XML String file loading is now handled explicitly by Player:ReloadStrings()
	end
	
	gCurrentQuestBeingBuilt = nil 
	
	-- Consolidate and sort all dynamically registered variables for the save system
	local vars = {}
	_AllVariableNames.ugr_slots = true
	_AllVariableNames.ownphone = true
	_AllVariableNames.ownplane = true
	
	for name, _ in pairs(_AllVariableNames) do 
		table.insert(vars, name) 
	end
	
	table.sort(vars, function(a, b) return a < b end)
	_AllVariableNames = vars
	
	-- Verify structural integrity of all loaded quests
	for _, q in pairs(_AllQuests) do 
		q:CrossCheck() 
	end
end

------------------------------------------------------------------------------
-- Post-Load Mapping
------------------------------------------------------------------------------

-- Maps instantiated character objects to their corresponding quests.
-- Called after all characters and quests are fully loaded into memory.
function PrepareCharactersForQuests()
	for _, quest in pairs(_AllQuests) do
		-- If a quest has no starter, flag it as a telegram/background quest
		if table.getn(quest.starter) == 0 then
			table.insert(_NoStarterQuests, quest)
		end
		
		-- Map Starters
		for i, char in ipairs(quest.starter) do
			if type(char) == "string" then
				char = _AllCharacters[char] or CreateCharacter(char)
				quest.starter[i] = char
			end
			char:AddStartQuest(quest)
		end
		
		-- Map Enders
		for i, char in ipairs(quest.ender) do
			if type(char) == "string" then
				char = _AllCharacters[char] or CreateCharacter(char)
				quest.ender[i] = char
			end
			char:AddEndQuest(quest)
		end
	end
end

------------------------------------------------------------------------------
-- Evaluation Helpers
------------------------------------------------------------------------------

-- Returns the active difficulty level the quest was locked into upon acceptance.
-- If the quest isn't active yet, returns the player's current global difficulty.
function GetQuestDifficulty(quest)
	if quest and Player.questsActive[quest.name] and Player.questDifficulty[quest.name] then
		return Player.questDifficulty[quest.name]
	end
	return Player.difficulty or 1
end

-- Validates an array of condition hooks (e.g., "Does player have 10 Sugar?")
local function EvaluateRequirementList(requirements, quest)
	local allgood = true
	local allhints = true
	
	for _, req in ipairs(requirements) do
		if not req.hint then 
			allhints = false 
		end
		
		if req.Evaluate and (not req:Evaluate(quest)) then 
			allgood = false 
		end
	end
	
	return allgood, allhints
end

-- Iterates and triggers an array of reward/penalty hooks (e.g., "Give 500 dollars")
local function ApplyGiftList(gifts, quest)
	-- We use an iterator object pattern here to allow complex hooks to pause
	-- or conditionally advance the execution sequence.
	local iterator = { 
		t = gifts or {}, 
		n = 0,
		quest = quest,
	}
	
	function iterator:go()
		local somethingHappened = false
		local cont = true
		
		-- Run through the gift list until there's an Apply function that tells us to stop
		while (cont and self.n < table.getn(self.t)) do
			self.n = self.n + 1
			local gift = self.t[self.n]
			
			if gift.Apply then
				local somethingJustHappened
				cont, somethingJustHappened = gift:Apply(self)
				somethingHappened = somethingHappened or somethingJustHappened
			end
		end
		
		return somethingHappened
	end
	
	return iterator:go()
end

-- Executes happiness modifiers immediately. This ensures the character displays
-- the correct emotional state portrait BEFORE their dialog UI pops up.
local function PreApplyHappinessChanges(gifts, character)
	if not gifts or not character then return end
	
	for _, gift in ipairs(gifts) do
		-- Look for an AwardHappiness action that targets the specific speaker
		if gift.type == "AwardHappiness" and gift.name == character.name then
			DebugOut("QUEST", string.format("Pre-applying happiness modifier for %s prior to UI rendering.", character.name))
			gift:Apply() 
		end
	end
end

------------------------------------------------------------------------------
-- Debugging / Safety Checks
------------------------------------------------------------------------------

local function CrossCheckQuestFunctions(t, name)
	for _, f in ipairs(t) do
		if f.CrossCheck then
			local result = f:CrossCheck()
			if result then
				DebugOut("ERROR", string.format("Quest CrossCheck failed for '%s': %s", name, result))
			end
		end
	end
end

-- Ensures all assigned hooks inside the quest definition are valid and executable
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
-- Dynamic Text & Dialogue Generation Engine
------------------------------------------------------------------------------

-- Grammatically formats an array of requested products for dialogue.
-- Example: "20 Basic Bars, 10 Truffles, and 5 Exotics"
local function FormatMultiItemString(items)
	local parts = {}
	
	for _, item in ipairs(items) do
		local prod = _AllProducts[item.product]
		if prod then
			table.insert(parts, item.count .. " " .. prod:GetName())
		end
	end

	if table.getn(parts) == 0 then return "" end
	if table.getn(parts) == 1 then return parts[1] end
	
	-- Handle the grammatical "and" for the final item
	local last = table.remove(parts)
	return table.concat(parts, ", ") .. ", and " .. last
end

-- Core Regex substitution engine for dynamic variables.
-- Translates placeholders like {deadline_weeksleft} or {speaker_name} into actual data.
local function SubstituteQuestParams(text, quest, contextChar)
	if not text or not quest then return "" end

	-- 1. Gather Object Context
	local ender = quest:GetEnder()
	local endBuilding = _AllBuildings[quest.endbuilding]
	local startBuilding = _AllBuildings[quest.startbuilding]
	
	-- If startBuilding exists, assume its primary resident is the starter
	local starter = startBuilding and startBuilding:GetCharacterList()[1] or nil
	local sender = contextChar or starter 

	-- 2. Temporal Context
	local weeksPassed = Player.time - (Player.questsActive[quest.name] or Player.time)
	local weeksLeft = (quest.expires or 0) - weeksPassed
	if weeksLeft < 0 then weeksLeft = 0 end
	local deadlineDate = Date(Player.time + weeksLeft)

	-- 3. Value Mapping Dictionary
	local map = {}
	
	-- Monetary & Deadline mappings
	map["salary"] = Dollars(quest.price)
	map["deadline_weeksleft"] = tostring(weeksLeft)
	map["deadline_date"] = deadlineDate
	
	-- Inject all character metadata and pronouns from the Character Class helper
	local function MergeTokens(dest, source)
		for k, v in pairs(source) do dest[k] = v end
	end
	MergeTokens(map, GetCharacterTokens(ender, "ender_"))
	MergeTokens(map, GetCharacterTokens(starter, "starter_"))
	MergeTokens(map, GetCharacterTokens(sender, "speaker_"))

	-- Maintain backward compatibility for older hardcoded XML tags
	map["ender_char"] = map["ender_name"] or ""
	map["starter_char"] = map["starter_name"] or ""
	map["speaker_char"] = map["speaker_name"] or ""

	map["ender_building"] = endBuilding and GetString(endBuilding.name) or ""
	map["ender_port"] = endBuilding and GetString(endBuilding.port.name) or ""
	
	map["starter_building"] = startBuilding and GetString(startBuilding.name) or ""
	map["starter_port"] = startBuilding and GetString(startBuilding.port.name) or ""

	-- Special Data Hooks for specific mechanics
	if quest.stolen_ingredient then 
		map["ingredient"] = quest.stolen_ingredient 
	end
	if quest.sabotaged_factory then 
		map["factory"] = quest.sabotaged_factory 
		map["port"] = quest.sabotaged_port
	end

	-- Product Name & Quantity logic
	if quest.items and table.getn(quest.items) > 1 then
		-- Multi-Item Order Support
		for i, item in ipairs(quest.items) do
			local prod = _AllProducts[item.product]
			map["quantity_item"..i] = tostring(item.count)
			map["item_item"..i] = prod and prod:GetName() or "Unknown"
		end
		
		map["item"] = FormatMultiItemString(quest.items)
		map["quantity"] = "a shipment of" 
	else
		-- Single Item Order Support
		local prod = _AllProducts[quest.product]
		map["item"] = prod and prod:GetName() or "Unknown"
		map["quantity"] = tostring(quest.count)
		
		-- Map single item to index 1 as a fallback just in case the UI expects it
		map["quantity_item1"] = map["quantity"]
		map["item_item1"] = map["item"]
	end

	-- Resolver Function for the regex pass
	local function ReplaceFunc(key)
		if map[key] then return map[key] end
		if quest[key] and type(quest[key]) == "string" then return quest[key] end
		return nil
	end

	-- 4. Apply RegEx substitutions (Supports {tag}, [tag], and %tag% formats)
	local result = string.gsub(text, "{([%w_]+)}", function(k) return ReplaceFunc(k) or "{"..k.."}" end)
	result = string.gsub(result, "%[([%w_]+)%]", function(k) return ReplaceFunc(k) or "["..k.."]" end)
	result = string.gsub(result, "%%([%w_]+)%%", function(k) return ReplaceFunc(k) or "%"..k.."%" end)
	
	-- 5. Legacy Player Name Replacement
	if string.find(result, "<player>") then
		result = string.gsub(result, "<player>", Player.name or "")
	end

	return result
end

-- Queues an aftermath dialogue to be played the *next* time the player visits the quest starter.
-- Used to deliver delayed consequences (e.g., apologizing for an expired order, or yelling about theft).
local function QueueDeliveryAftermath(quest, eventType, penaltyKey)
	if not quest.startbuilding then return end
	local startBuilding = _AllBuildings[quest.startbuilding]
	local starter = startBuilding and startBuilding:GetCharacterList()[1] or nil
	if not starter then return end

	local baseKey = ""
	local mood = "neutral"

	-- Determine the emotional reaction to queue
	if eventType == "expired" then
		if quest.isEvilScheme then
			-- The NPC is thrilled you avoided the trap they set for you
			baseKey = "delivery_aftermath_expired_evilscheme"
			mood = "happy"
		else
			-- Standard disappointment for missing a deadline
			baseKey = "delivery_aftermath_expired"
			mood = "neutral"
		end
	elseif eventType == "complete" then
		-- This only triggers upon an Evil Scheme failure (Trap sprung)
		baseKey = "delivery_aftermath_complete_evilscheme_" .. tostring(penaltyKey)
		mood = "angry"
	else
		return
	end

	-- Find the best dialogue key variant
	local keys_to_try = { 
		baseKey .. "_" .. starter.name, 
		baseKey 
	}
	local finalKey = baseKey
	
	for _, key in ipairs(keys_to_try) do
		if GetString(key .. "_1") ~= "#####" then
			local count = 1
			while GetString(key .. "_" .. (count + 1)) ~= "#####" do 
				count = count + 1 
			end
			finalKey = key .. "_" .. RandRange(1, count)
			break
		end
	end

	local rawText = GetString(finalKey)
	if rawText == "#####" then return end

	local text = SubstituteQuestParams(rawText, quest, starter)
	local buttons = GetDeliveryButtonLabels(finalKey)

	-- Inject into the player's global queue state
	Player.pendingAftermaths = Player.pendingAftermaths or {}
	Player.pendingAftermaths[quest.startbuilding] = Player.pendingAftermaths[quest.startbuilding] or {}
	
	table.insert(Player.pendingAftermaths[quest.startbuilding], {
		text = text,
		mood = mood,
		ok_label = buttons.ok,
		ok_length = "long"
	})
	
	DebugOut("QUEST", string.format("Queued contextual aftermath dialogue for building: %s", quest.startbuilding))
end

-- Returns a suffix string determining if a quest was completed early, late, or on time.
-- This feeds into the dialogue engine to trigger specific contextual reactions.
function Quest:GetTimingContext()
	local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
	
	-- 1. Determine the true active deadline based on difficulty
	local deadline = self.expires
	if Player.questDifficulty[self.name] == 2 and self.expires_medium then 
		deadline = self.expires_medium 
	end
	if Player.questDifficulty[self.name] == 3 and self.expires_hard then 
		deadline = self.expires_hard 
	end

	if deadline then
		-- CASE A: The quest has a hard deadline
		local weeksLeft = deadline - weeksPassed
		if weeksPassed == 0 then 
			return "_very_early"
		elseif weeksLeft >= (deadline * 0.75) then 
			return "_early"
		elseif weeksLeft <= (deadline * 0.25) and deadline > 4 then 
			return "_late"
		elseif weeksLeft <= 2 and deadline > 4 then 
			return "_very_late"
		end
	else
		-- CASE B: Free-floating quests (No deadline)
		if weeksPassed == 0 then 
			return "_very_early"
		elseif weeksPassed <= 6 then 
			return "_early" 		-- Within 6 weeks is early
		elseif weeksPassed >= 26 then 
			return "_late" 			-- Over 6 months is late
		elseif weeksPassed >= 52 then 
			return "_very_late" 	-- Over a year is very late
		end
	end

	return "" -- Default if it perfectly hits the median window
end

-- Fundamental fallback string fetcher used for UI titles and summaries.
function Quest:GetQuestString(key)
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
			return text 
		end
	end

	local text = self.name .. (key or "")
	text = GetReplacedString(text, self)
	if text == "#####" then 
		return nil 
	else 
		return text 
	end
end

-- Powerful hierarchical lookup that fetches context-aware dialogue strings.
function Quest:GetDynamicQuestString(baseKey, character)
	local char = character or self:GetEnder() or self:GetStarter()
	if not char then 
		return self:GetQuestString("_" .. baseKey) 
	end 

	local timing_suffix = ""
	if baseKey == "incomplete" or baseKey == "expired" or baseKey == "complete" then
		timing_suffix = self:GetTimingContext()
	end

	local function construct_key(prefix, suffix)
		if suffix == prefix or string.sub(suffix, 1, string.len(prefix) + 1) == (prefix .. "_") then
			return suffix
		else
			return prefix .. "_" .. suffix
		end
	end

	local keys_to_try = {}
	
	-- 1. Highly specific timing + character variants
	if timing_suffix ~= "" then
		table.insert(keys_to_try, self.name .. "_" .. baseKey .. timing_suffix .. "_" .. char.name)
		table.insert(keys_to_try, self.name .. "_" .. baseKey .. timing_suffix)
	end
	
	-- 2. Base character variant
	table.insert(keys_to_try, construct_key(self.name, baseKey) .. "_" .. char.name)
	
	-- 3. Ultimate generic quest string
	table.insert(keys_to_try, construct_key(self.name, baseKey))
	
	-- Search for the best match
	local finalBaseKey = nil
	for _, key in ipairs(keys_to_try) do
		if GetString(key .. "_1") ~= "#####" then
			finalBaseKey = key
			break
		end
	end

	if not finalBaseKey then
		DebugOut("DIALOGUE", string.format("No valid string variations found for base '%s' on quest '%s'.", baseKey, self.name))
		return nil
	end

	-- Count variations and pick one randomly
	local count = 1
	while GetString(finalBaseKey .. "_" .. (count + 1)) ~= "#####" do 
		count = count + 1 
	end
	
	local finalKey = finalBaseKey .. "_" .. RandRange(1, count)

	DebugOut("DIALOGUE", string.format("DynamicQuestString selected '%s' for quest '%s'.", finalKey, self.name))
	
	-- Save the key so we can map the buttons to it later
	if self.delivery then self.lastDynamicKey = finalKey end

	return GetReplacedString(finalKey, self)
end

-- Specialized helper for extra flavor text blocks.
function Quest:GetDynamicExtraTextString(fullKey, character)
	local char = character or self:GetEnder() or self:GetStarter()
	if not char then return GetReplacedString(fullKey) end 

	local keys_to_try = { 
		fullKey .. "_" .. char.name, 
		fullKey 
	}
	
	local finalBaseKey = nil
	for _, key in ipairs(keys_to_try) do
		if GetString(key .. "_1") ~= "#####" then
			finalBaseKey = key
			break
		end
	end

	if not finalBaseKey then return nil end 

	local count = 1
	while GetString(finalBaseKey .. "_" .. (count + 1)) ~= "#####" do 
		count = count + 1 
	end
	
	return GetReplacedString(finalBaseKey .. "_" .. RandRange(1, count), self)
end

-- Generates randomized tooltip advice for players who are stuck on an objective
function Quest:GetDynamicHintString(character)
	local char = character or self:GetStarter()
	if not char then return nil end

	-- For Delivery Quests, hints are ONLY given by the quest starter (the shopkeeper)
	if self.delivery and char ~= self:GetStarter() then 
		return nil 
	end

	local keys_to_try = { 
		self.name .. "_hint_" .. char.name, 
		self.name .. "_hint" 
	}
	
	local finalBaseKey = nil
	for _, key in ipairs(keys_to_try) do
		if GetString(key .. "_1") ~= "#####" then
			finalBaseKey = key
			break
		end
	end

	if not finalBaseKey then return nil end 

	local count = 1
	while GetString(finalBaseKey .. "_" .. (count + 1)) ~= "#####" do 
		count = count + 1 
	end
	
	local finalKey = finalBaseKey .. "_" .. RandRange(1, count)
	DebugOut("DIALOGUE", string.format("Extracted quest hint string: %s", finalKey))
	
	return GetReplacedString(finalKey, self)
end

-- Getter overrides for standard UI mapping
function Quest:GetTitle() return self:GetQuestString("") or tostring(self).." TITLE" end
function Quest:GetSummary() return self:GetQuestString("_summary") end
function Quest:GetIntro(char) return self:GetDynamicQuestString("offer", char or self:GetStarter()) end
function Quest:GetCompleteString(char) return self:GetDynamicQuestString("complete", char or self:GetEnder()) end
function Quest:GetIncompleteString(char) return self:GetDynamicQuestString("incomplete", char or self:GetEnder()) end
function Quest:GetHint() return self:GetDynamicHintString(nil) end

-- Calculates customized expiration text depending on character
function Quest:GetExpiredString(char)
	local expiredText = self:GetDynamicQuestString("expired", char or self:GetEnder())
	if expiredText then 
		return expiredText 
	end
	
	-- Fallback to the generic engine default if no specific text exists
	return GetString("generic_quest_expired")
end

-- Directly renders a dialog window with static text
function Quest:DoStringDialog(char, key, building)
	local text = self:GetQuestString(key) 
	if text then
		DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. text, building = building }
	end
end

------------------------------------------------------------------------------
-- Quest Logic Controls (Accept, Complete, Expire)
------------------------------------------------------------------------------

function Quest:IsActive() 
	return (Player.questsActive[self.name] ~= nil) 
end

function Quest:CanEnd(char)
	for _, ender in ipairs(self.ender) do
		if char == ender then return true end
	end
	return false
end

function Quest:GetStarter()
	local char = Player.questStarters[self.name]
	if char then 
		return _AllCharacters[char] 
	end
	
	if self.starter then 
		return self.starter[1] 
	end
	
	return nil
end

function Quest:GetStarterName()
	local char = self:GetStarter()
	return char and char.name or nil
end

function Quest:GetEnder()
	local char = self.ender[1]
	if not char then char = self:GetStarter() end
	return char
end

function Quest:GetEnderName()
	local char = self:GetEnder()
	return char and char.name or nil
end

function Quest:IsNotWaiting()
	if Player.questsWaiting[self.name] then
		return (Player.questsWaiting[self.name] <= Player.time)
	end
	return true
end

-- Triggers the dialogue to present the quest to the player
function Quest:Offer(char, building)
	local starterName = char and char.name or "System"
	DebugOut("QUEST", string.format("Processing offer for quest '%s' from starter '%s'.", self.name, starterName))

	if self:IsReal() then Player.lastOfferTime = Player.time end

	local quest = self
	if not char then char = self:GetStarter() end

	local offerText = self:GetIntro()

	-- Background auto-acceptance:
	-- If no offer text exists, accept it automatically without showing any UI to the player.
	if not offerText or offerText == "" then
		DebugOut("QUEST", string.format("No offer text found for '%s'. Automatically accepting background task.", self.name))
		self:Accept(char)
		return
	end

	-- Display appropriate UI layer
	if self.forceTelegram then
		DisplayDialog { "ui/ui_quest_telegram.lua", quest = self, building = building }
	elseif char then
		DisplayDialog { "ui/ui_quest_offer.lua", char = char, quest = self, building = building }
	else
		-- Fallback if character data is missing
		DisplayDialog { "ui/ui_quest_telegram.lua", quest = quest, building = building }
	end
end

-- Processes the player deciding to accept the mission
function Quest:Accept(char)
	DebugOut("QUEST", string.format("Player ACCEPTED quest: %s", self.name))

	if self:IsReal() then Player.lastAcceptTime = Player.time end

	-- Update internal trackers
	Player.questsActive[self.name] = Player.time
	Player.questStarters[self.name] = char and char.name or nil
	Player.questsComplete[self.name] = nil
	
	-- Lock in the current difficulty so the quest scales appropriately, even if the player
	-- changes their difficulty setting in the options menu mid-quest.
	Player.questDifficulty[self.name] = Player.difficulty or 1
	DebugOut("DIFFICULTY", string.format("Quest '%s' scaling locked at Difficulty Level %d.", self.name, Player.questDifficulty[self.name]))

	if self.visible and not self.autoComplete then 
		gLastQuestAccepted = self 
	end

	-- Apply Acceptance Rewards
	local difficulty = GetQuestDifficulty(self)
	local accept_list = self.onaccept
	if difficulty == 2 and self.onaccept_medium then 
		accept_list = self.onaccept_medium
	elseif difficulty == 3 and self.onaccept_hard then 
		accept_list = self.onaccept_hard 
	end
	
	PreApplyHappinessChanges(accept_list, char)
	ApplyGiftList(accept_list, self)
	
	-- Auto-completion mechanic for purely narrative/tracker quests
	if self.autoComplete then self:Complete() end
	
	-- Ledger synchronization
	if gLastQuestAccepted then
		Player:SetPrimaryQuest(gLastQuestAccepted.name)
		gLastQuestAccepted = nil
	end
end

-- Processes the player declining to accept the mission
function Quest:Reject(char)
	DebugOut("QUEST", string.format("Player REJECTED quest: %s", self.name))

	-- Remove from active queue and flag as completed to prevent it from looping
	Player.questsActive[self.name] = nil
	Player.questsComplete[self.name] = Player.time

	local difficulty = GetQuestDifficulty(self) 
	local reject_list = self.onreject
	
	if difficulty == 2 and self.onreject_medium then 
		reject_list = self.onreject_medium
	elseif difficulty == 3 and self.onreject_hard then 
		reject_list = self.onreject_hard 
	end
	
	PreApplyHappinessChanges(reject_list, char)
	ApplyGiftList(reject_list, self)
end

function Quest:IsComplete() 
	return (Player.questsComplete[self.name] ~= nil) 
end

function Quest:CanRepeat()
	if self.repeatable == nil then return false end
	
	-- True if the cooldown period has elapsed since completion
	return Player.time >= ((Player.questsComplete[self.name] or 0) + self.repeatable)
end

-- Executes the final reward sequence and dialogue when a quest's goals are fully met
function Quest:Complete(char, building)
	DebugOut("QUEST", string.format("Player COMPLETED quest: %s", self.name))

	local somethingHappened = false
	if self:IsReal() then Player.lastCompleteTime = Player.time end
	
	Player.questsWaiting[self.name] = nil
	
	if not char then char = self:GetEnder() end

	-- 1. Determine timing and difficulty contexts
	local timing_context = self:GetTimingContext()
	local difficulty = Player.questDifficulty[self.name] or Player.difficulty or 1
	
	local reward_list = self["oncomplete" .. timing_context] or self.oncomplete
	
	if difficulty == 2 and (self["oncomplete" .. timing_context .. "_medium"] or self.oncomplete_medium) then
		reward_list = self["oncomplete" .. timing_context .. "_medium"] or self.oncomplete_medium
	elseif difficulty == 3 and (self["oncomplete" .. timing_context .. "_hard"] or self.oncomplete_hard) then
		reward_list = self["oncomplete" .. timing_context .. "_hard"] or self.oncomplete_hard
	end

	PreApplyHappinessChanges(reward_list, char)

	-- 2. Clear Trackers
	Player.questsActive[self.name] = nil
	Player.questsComplete[self.name] = Player.time
	Player.questDifficulty[self.name] = nil

	-- 3. Execute Dialogue UI
	local text = self:GetCompleteString(char)
	local q = self.followup
	if q then q = _AllQuests[q] end
	
	if text and text ~= "" then
		if self:IsReal() then SoundEvent("quest_complete") end
		somethingHappened = true
		
		DisplayDialog { 
			"ui/ui_character_generic.lua", 
			char = char, 
			text = "#" .. text, 
			building = building, 
			ok = self.oncomplete_label, 
			ok_length = self.oncomplete_label_length, 
			mood = self.oncomplete_mood 
		}
	end

	-- 4. Finalize rewards
	somethingHappened = ApplyGiftList(reward_list, self) or somethingHappened
	
	-- If a chained quest is attached, force it to offer immediately
	if q then
		somethingHappened = true
		q:Offer(nil, building)
	end
	
	if Player.questPrimary == self.name then 
		Player:SetPrimaryQuest(nil) 
	end
	
	return somethingHappened
end

-- Triggers the "I'm still working on it" flavor dialogue when you click an NPC
function Quest:Incomplete(char, building)
	local somethingHappened = false
	
	local timing_context = self:GetTimingContext()
	local incomplete_list = self["onincomplete" .. timing_context] or self.onincomplete

	PreApplyHappinessChanges(incomplete_list, char)

	local text = self:GetIncompleteString(char)
	
	if text and text ~= "" then
		somethingHappened = true
		DisplayDialog { 
			"ui/ui_character_generic.lua", 
			char = char, 
			text = "#" .. text, 
			building = building, 
			ok = self.onincomplete_label, 
			ok_length = self.onincomplete_label_length, 
			mood = self.onincomplete_mood 
		}
	end
	
	ApplyGiftList(incomplete_list, self)
	return somethingHappened
end

-- Validates whether the active deadline has passed
function Quest:IsExpired()
	local difficulty = GetQuestDifficulty(self)
	local expires_time = self.expires 
	
	if difficulty == 2 and self.expires_medium then 
		expires_time = self.expires_medium
	elseif difficulty == 3 and self.expires_hard then 
		expires_time = self.expires_hard 
	end

	if expires_time and (Player.time >= Player.questsActive[self.name] + expires_time) then 
		return true 
	end
	
	return false
end

-- Handles the logic and consequence triggers when a quest deadline passes
function Quest:Expire(char, building)
	DebugOut("QUEST", string.format("Quest EXPIRED/FAILED: %s", self.name))
	
	if self.delivery then
		QueueDeliveryAftermath(self, "expired")
	end

	Player.questsWaiting[self.name] = nil
	local c = self:GetEnder()
	char = c or char

	-- Clean up trackers
	Player.questsActive[self.name] = nil
	Player.questStarters[self.name] = nil
	Player.questsComplete[self.name] = Player.time
	
	local difficulty = Player.questDifficulty[self.name] or Player.difficulty or 1 
	Player.questDifficulty[self.name] = nil

	-- Display failure telegram UI
	local text = self:GetExpiredString()
	DisplayDialog { "ui/ui_telegram.lua", char = char, text = text, building = building }
	
	-- Issue Penalties
	local expire_list = self.onexpire
	if difficulty == 2 and self.onexpire_medium then 
		expire_list = self.onexpire_medium
	elseif difficulty == 3 and self.onexpire_hard then 
		expire_list = self.onexpire_hard 
	end
	
	ApplyGiftList(expire_list, self)

	if Player.questPrimary == self.name then 
		Player:SetPrimaryQuest(nil) 
	end
end

function Quest:IsDeferred()
	if not Player.questsDeferred[self.name] then return false end
	
	-- True if the deferral time hasn't passed yet
	return Player.questsDeferred[self.name] > Player.time
end

function Quest:Defer(char, weeks)
	weeks = weeks or 4
	Player.questsDeferred[self.name] = Player.time + weeks
	
	DebugOut("QUEST", string.format("Player DEFERRED quest '%s' for %d weeks.", self.name, weeks))

	local difficulty = GetQuestDifficulty(self) 
	local defer_list = self.ondefer
	
	if difficulty == 2 and self.ondefer_medium then 
		defer_list = self.ondefer_medium
	elseif difficulty == 3 and self.ondefer_hard then 
		defer_list = self.ondefer_hard 
	end

	PreApplyHappinessChanges(defer_list, char)
	ApplyGiftList(defer_list, self)
end

function Quest:IsHintEligible()
	-- Constraints for the tutorial hint system
	if not self:IsActive() then return false end
	if not self:GetHint() then return false end
	
	-- Player must be struggling for at least 12 weeks
	local timeElapsed = Player.time - (Player.questsActive[self.name] or Player.time)
	if timeElapsed < 12 then return false end
	
	-- Must not be on active cooldown
	local cooldownTime = Player.questHintCooldowns[self.name] or 0
	if Player.time < cooldownTime then return false end
	
	return true
end

-- The master validation loop checking if an NPC can safely offer this to the player
function Quest:IsEligible()
	if Player.options.noQuests and (not self.alwaysAvailable) then return false end
	if self:IsActive() then return false end
	if self:IsDeferred() then return false end
	if self:IsComplete() and not self:CanRepeat() then return false end

	-- Negative requirements
	if self.norequire and table.getn(self.norequire) > 0 then
		for _, noreq in ipairs(self.norequire) do
			if noreq.Evaluate and noreq:Evaluate(self) then 
				return false 
			end
		end
	end

	local difficulty = GetQuestDifficulty(self)
	local require_list = self.require 
	
	if difficulty == 2 and self.require_medium then 
		require_list = self.require_medium
	elseif difficulty == 3 and self.require_hard then 
		require_list = self.require_hard 
	end

	return EvaluateRequirementList(require_list, self)
end

function Quest:IsReal()
	if self.isReal ~= nil then return self.isReal end

	local isReal = false
	if self.repeatable == nil then
		if table.getn(self.onaccept) > 0 or table.getn(self.oncomplete) > 0 then 
			isReal = true
		elseif (self.priority < kDefaultPriority) then 
			isReal = true
		elseif table.getn(self.goals) > 0 then
			for _, req in ipairs(self.goals) do
				if not req.hint then isReal = true; break; end
			end
		end
	end
	
	-- Hardcoded string overrides for flavor dialogue hooks
	if isReal and (string.find(self.name, "hint") or string.find(self.name, "tease")) then 
		isReal = false 
	end
	
	return isReal
end

function Quest:AreGoalsMet()
	local difficulty = GetQuestDifficulty(self)
	local goal_list = self.goals 
	
	if difficulty == 2 and self.goals_medium then 
		goal_list = self.goals_medium
	elseif difficulty == 3 and self.goals_hard then 
		goal_list = self.goals_hard 
	end

	local allgood, allhints = EvaluateRequirementList(goal_list, self)
	return allgood, allhints
end

------------------------------------------------------------------------------
-- UI: Dynamic Button Generators
------------------------------------------------------------------------------

-- Procedurally generates the localized text for dialogue buttons based on the nature of the quest text
function GetDeliveryButtonLabels(dialogueKey)
	local buttons = {}
	
	-- Response Pools
	local pool_yes_prompt = { "letshearit", "tellmemore", "imlistening", "goon", "pleaseelaborate", "ineeddetails", "iminterested", "youhavemyattention" }
	local pool_no_prompt = { "notnow", "notrightnow", "noimtoobusy", "noimgood", "anothertime", "nothanks", "nothankyou" }
	local pool_accept_sender = { "absolutely", "certainly", "consideritdone", "countmein", "imonit", "rightaway", "youcancountonme", "leaveittome", "illgetrightonit", "illdoit" }
	local pool_accept_receiver = { "illtakeit", "youbet", "itsadeal", "yeslets", "soundsgood", "deal", "weareinbusiness", "indeed", "sure", "iwill", "illdoit", "agreed" }
	local pool_reject = { "forgetit", "icantdothat", "illpass", "notachance", "notinterested", "regrettablyno", "notworthmytime", "nodeal", "noway", "nonever", "imout", "sorryicant", "nothanks", "nothankyou", "nonotforme", "imafraidnot", "absolutelynot" }
	local pool_defer = { "askmelater", "anothertime", "laterperhaps", "maybelater", "letmethinkaboutit", "illgetbacktoyou", "notrightnow", "notnow", "later", "inawhile" }
	local pool_complete = { "yourewelcome", "mypleasure", "happytohelp", "gladtobeofservice", "enjoy", "pleasuredoingbusiness", "anytime"  }
	local pool_incomplete = { "ok" }
	local pool_understand = { "understood", "ihearyou", "loudandclear", "gotit", "makessensetome", "isee", "noted", "copythat", "iunderstand", "allright", "acknowledged" }
	local pool_evilscheme = { "wow", "unbelievable", "howdareyou", "what", "yougottobekiddingme", "really", "nostop", "youwouldntdare", "whatareyoudoing", "thief", "imcallingthepolice", "youllpayforthis" }
	local pool_evilscheme_aftermath = { "whatashame", "sorry", "unbelievable", "thosecowards", "lessonlearned", "howdarethey", "iknow", "pleaseforgiveme", "wonthappenagain", "imfurious", "theyplayedus", "myapologies", "imsosorry", "goodgrief", "illmakeituptoyou" }
	local pool_evilscheme_evaded = { "phew", "thatwasclose", "thankgoodness", "couldvebeenworse", "luckybreak", "illtakeit", "goodtoknow", "goodiwasworried" }

	local function PickRandom(pool)
		if not pool or table.getn(pool) == 0 then return "ok" end
		return pool[RandRange(1, table.getn(pool))]
	end

	dialogueKey = dialogueKey or ""
	
	-- 1. Check for manual specific overrides
	local overrides = {}
	if overrides[dialogueKey] then
		local o = overrides[dialogueKey]
		if o.yes then buttons.yes = o.yes end
		if o.no then buttons.no = o.no end
		if o.accept then buttons.accept = o.accept end
		if o.defer then buttons.defer = o.defer end
		if o.reject then buttons.reject = o.reject end
		if o.ok then buttons.ok = o.ok end
	end

	-- 2. Fallbacks based on pattern matching inside the string key
	if string.find(dialogueKey, "prompt") then
		buttons.yes = buttons.yes or PickRandom(pool_yes_prompt)
		buttons.no = buttons.no or PickRandom(pool_no_prompt)
	end
	
	if string.find(dialogueKey, "sender_offer") then 
		buttons.accept = buttons.accept or PickRandom(pool_accept_sender)
	elseif string.find(dialogueKey, "recipient_offer") then 
		buttons.accept = buttons.accept or PickRandom(pool_accept_receiver)
	else 
		buttons.accept = buttons.accept or PickRandom(pool_accept_receiver) 
	end

	if string.find(dialogueKey, "evilscheme") then
		if string.find(dialogueKey, "expired") then 
			buttons.ok = buttons.ok or PickRandom(pool_evilscheme_evaded)
		else 
			buttons.ok = buttons.ok or PickRandom(pool_evilscheme_aftermath) 
		end
	elseif string.find(dialogueKey, "fail") then 
		buttons.ok = buttons.ok or PickRandom(pool_evilscheme)
	elseif string.find(dialogueKey, "success") then 
		buttons.ok = buttons.ok or PickRandom(pool_evilscheme_evaded)
	elseif string.find(dialogueKey, "incomplete") then 
		buttons.ok = buttons.ok or PickRandom(pool_incomplete)
	elseif string.find(dialogueKey, "complete") then 
		buttons.ok = buttons.ok or PickRandom(pool_complete)
	else 
		buttons.ok = buttons.ok or PickRandom(pool_understand) 
	end

	buttons.defer = buttons.defer or PickRandom(pool_defer)
	buttons.reject = buttons.reject or PickRandom(pool_reject)

	-- Hardcoded ultimate safety fallback
	buttons.yes = buttons.yes or "yes"
	buttons.no = buttons.no or "no"
	buttons.ok = buttons.ok or "ok"

	return buttons
end

------------------------------------------------------------------------------
-- Subclass: Dynamic Special Orders
------------------------------------------------------------------------------

-- The DeliveryQuest object handles procedurally generated marketplace requests,
-- allowing shopkeepers to order bulk products for cash payouts.

DeliveryQuest =
{
	product = nil,			
	count = nil,			
	price = nil,			
	defer = "quest_defer",
	delivery = true,
}
setmetatable(DeliveryQuest, Quest)
DeliveryQuest.__index = DeliveryQuest
DeliveryQuest.__tostring = function(t) return "{DeliveryQuest:" .. tostring(t.name) .. "}" end

-- Procedurally generated quests bypass normal eligibility requirements
function DeliveryQuest:IsEligible() return false end

-- Custom substitution engine supporting the dynamically built Delivery tables
function GetDynamicDeliveryString(baseKey, quest, contextChar)
	if not quest or (not quest.product and not quest.items) then return nil end
	
	-- For multi-orders, we use the FIRST product to determine base lore context
	local primaryProductCode = quest.product
	if quest.items and quest.items[1] then 
		primaryProductCode = quest.items[1].product 
	end

	local product = _AllProducts[primaryProductCode]
	local ender = quest:GetEnder()
	local endBuilding = _AllBuildings[quest.endbuilding]
	local startBuilding = _AllBuildings[quest.startbuilding]
	local sender = startBuilding and startBuilding:GetCharacterList()[1] or nil

	if not product or not ender or not sender or not endBuilding then return nil end

	-- 1. Establish speaker identities
	local primaryChar, secondaryChar
	if contextChar and (baseKey == "delivery_incomplete" or string.find(baseKey, "delivery_incomplete_") or baseKey == "delivery_complete" or string.find(baseKey, "delivery_complete_") or baseKey == "delivery_expired" or string.find(baseKey, "delivery_expired_")) then
		primaryChar = contextChar
		secondaryChar = (primaryChar.name == sender.name) and ender or sender
	else
		primaryChar = (string.find(baseKey, "recipient")) and ender or sender
		secondaryChar = (primaryChar.name == sender.name) and ender or sender
	end
	
	-- 2. First-time prompt logic
	local isFirstDelivery = false
	if not Player.questVariables.first_delivery_prompt_done and string.find(baseKey, "prompt") then
		isFirstDelivery = true
		Player.questVariables.first_delivery_prompt_done = 1
	end

	-- 3. Probability Weighting Map
	-- We create a massive pool of possible matching dialogue keys, weighted by how
	-- specific they are to the current context. Highly specific lore strings receive huge weights.
	local W_FIRST    = 1000 
	local W_REDEEMED = 500  
	local W_SPECIFIC = 60
	local W_PAIR     = 45
	local W_PROD     = 30
	local W_CHAR1    = 20
	local W_BASE     = 5

	local pool = {}
	local totalWeight = 0
	
	local function AddCandidate(k, w)
		if GetString(k .. "_1") ~= "#####" then
			table.insert(pool, { key=k, weight=w })
			totalWeight = totalWeight + w
		end
	end
	
	local genericBaseKey = baseKey
	genericBaseKey = string.gsub(genericBaseKey, "_very_early", "")
	genericBaseKey = string.gsub(genericBaseKey, "_very_late", "")
	genericBaseKey = string.gsub(genericBaseKey, "_early", "")
	genericBaseKey = string.gsub(genericBaseKey, "_late", "")

	-- Adapt suffix for multi-product orders
	local multiSuffix = ""
	if quest.items then
		local count = table.getn(quest.items)
		if count == 2 then multiSuffix = "_multi2"
		elseif count == 3 then multiSuffix = "_multi3" end
	end

	local function AddCandidatesForPattern(pattern, weight)
		if multiSuffix ~= "" then AddCandidate(pattern .. multiSuffix, weight) end
		AddCandidate(pattern, weight)
	end

	-- Populate Pools
	if isFirstDelivery then
		AddCandidatesForPattern(baseKey .. "_" .. primaryChar.name .. "_first", W_FIRST)
		AddCandidatesForPattern(baseKey .. "_first", W_FIRST)
	end

	-- Narrative Exception: Katherine Carpo's redemption arc
	if primaryChar.name == "evil_kath" and Player.questsComplete["rank4_kath_bribe"] then
		AddCandidatesForPattern(baseKey .. "_" .. primaryChar.name .. "_good", W_REDEEMED)
	end

	local keys_to_process = { baseKey }
	if genericBaseKey ~= baseKey then table.insert(keys_to_process, genericBaseKey) end

	-- Generate permutations
	for _, bKey in ipairs(keys_to_process) do
		AddCandidatesForPattern(bKey .. "_" .. primaryChar.name .. "_" .. product.code .. "_" .. secondaryChar.name, W_SPECIFIC)
		AddCandidatesForPattern(bKey .. "_" .. primaryChar.name .. "_" .. secondaryChar.name, W_PAIR)
		AddCandidatesForPattern(bKey .. "_" .. primaryChar.name .. "_" .. product.code, W_PROD)
		AddCandidatesForPattern(bKey .. "_" .. primaryChar.name, W_CHAR1)
		AddCandidatesForPattern(bKey, W_BASE)
	end

	-- 4. Execute Selection Roulette
	local finalKey = nil
	if totalWeight > 0 then
		local roll = RandRange(1, totalWeight)
		local current = 0
		for _, cand in ipairs(pool) do
			current = current + cand.weight
			if roll <= current then
				local count = 1
				while GetString(cand.key .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
				finalKey = cand.key .. "_" .. RandRange(1, count)
				break
			end
		end
	else
		-- Absolute fallback if probability pool failed
		finalKey = baseKey .. "_1"
		if GetString(finalKey) == "#####" then finalKey = baseKey end
		DebugOut("DIALOGUE", string.format("WARNING: Hit strict fallback for delivery string: %s", baseKey))
	end

	-- Save reference to assign dynamic UI buttons
	if quest then quest.lastDynamicKey = finalKey end

	local rawText = GetString(finalKey)
	if rawText == "#####" then return nil end
	
	-- Pipe the final text through the regex engine
	return SubstituteQuestParams(rawText, quest, contextChar)
end

-- Display generation overrides
function DeliveryQuest:GetTitle()
	if self.items and table.getn(self.items) > 1 then 
		return GetString("delivery_title_multi") 
	end
	return SubstituteQuestParams(GetString("delivery_title"), self)
end

function DeliveryQuest:GetIntro()
	-- If it's an in-person interaction
	if self.forceTelegram == false then
		local currentBuilding = gDialogTable and gDialogTable.building
		local offerKey = (currentBuilding and currentBuilding.name == self.startbuilding) and "delivery_sender_offer" or "delivery_recipient_offer"
		
		local text = GetDynamicDeliveryString(offerKey, self)
		local buttons = GetDeliveryButtonLabels(self.lastDynamicKey)
		
		self.accept = buttons.accept
		self.defer = buttons.defer
		self.reject = buttons.reject
		self.accept_length = "medium"
		self.defer_length = "medium"
		self.reject_length = "medium"
		
		return text
	end
	
	-- Telegram parsing
	local startBuilding = _AllBuildings[self.startbuilding]
	local starter = startBuilding and startBuilding:GetCharacterList()[1] or nil
	
	local to_str = GetText("telegram_to", Player.name)
	local where_str = ""
	local from_str = ""
	
	if startBuilding then
		where_str = GetText("telegram_where", GetString(startBuilding.name) .. " - " .. GetString(startBuilding.port.name))
		from_str = GetText("telegram_from", GetText(starter.name))
	end

	local baseKey = "delivery_intro"
	if self.items then
		local count = table.getn(self.items)
		if count == 2 then baseKey = "delivery_intro_multi2"
		elseif count == 3 then baseKey = "delivery_intro_multi3" end
	end

	local body_text = SubstituteQuestParams(GetString(baseKey), self)
	
	return string.upper(to_str .. "<br>" .. from_str .. "<br>" .. where_str .. "<br><br>" .. body_text)
end

function DeliveryQuest:GetCompleteString(char)
	if self.isEvilScheme then return "" end

	local ender = self:GetEnder()
	local baseKey = "delivery_complete"

	if ender then
		local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
		local weeksLeft = (self.expires or 0) - weeksPassed

		if weeksPassed == 0 then 
			baseKey = "delivery_complete_very_early"
		elseif weeksLeft >= (self.expires * 0.99) then 
			baseKey = "delivery_complete_early"
		elseif weeksLeft <= 2 and self.expires > 4 then 
			baseKey = "delivery_complete_very_late"
		elseif weeksLeft <= (self.expires * 0.25) and self.expires > 4 then 
			baseKey = "delivery_complete_late"
		end
	end
	
	-- -----------------------------------------------------
	-- Catalogue Data Discovery (Gift Preferences)
	-- -----------------------------------------------------
	-- Successfully fulfilling an order teaches the player about the NPC's likes and dislikes
	if ender then
		local charCatalogueData = Player.catalogue.unlockedCharacters[ender.name]
		if charCatalogueData and charCatalogueData.unlocked then
			
			local productsToCheck = {}
			if self.items and table.getn(self.items) > 0 then
				for _, item in ipairs(self.items) do 
					table.insert(productsToCheck, _AllProducts[item.product]) 
				end
			elseif self.product then
				table.insert(productsToCheck, _AllProducts[self.product])
			end

			local charObject = _AllCharacters[ender.name]
			if charObject and table.getn(productsToCheck) > 0 then
				DebugOut("CATALOGUE", string.format("Processing special order completion to discover preferences for %s.", ender.name))
				
				-- Parse Likes
				if charObject.likes then
					for _, product in ipairs(productsToCheck) do
						if charObject.likes.categories and charObject.likes.categories[product.category.name] then
							table.insert(charCatalogueData.discovered_likes, product.category.name)
						end
						
						if charObject.likes.products and charObject.likes.products[product.code] then
							table.insert(charCatalogueData.discovered_likes, product.code)
						end
						
						if charObject.likes.ingredients then
							for ingredientName, _ in pairs(product.counts) do
								if charObject.likes.ingredients[ingredientName] then
									table.insert(charCatalogueData.discovered_likes, ingredientName)
								end
							end
						end
					end
				end

				-- Discover exactly one random dislike per completed quest
				if charCatalogueData.undiscovered_dislikes_pool and table.getn(charCatalogueData.undiscovered_dislikes_pool) > 0 then
					local randomIndex = RandRange(1, table.getn(charCatalogueData.undiscovered_dislikes_pool))
					local discoveredDislike = table.remove(charCatalogueData.undiscovered_dislikes_pool, randomIndex)
					table.insert(charCatalogueData.discovered_dislikes, discoveredDislike)
				end

				-- Clean up array logic
				local function removeDuplicates(t)
					local seen, new_t = {}, {}
					for _, v in ipairs(t) do
						if not seen[v] then 
							table.insert(new_t, v)
							seen[v] = true 
						end
					end
					return new_t
				end
				
				charCatalogueData.discovered_likes = removeDuplicates(charCatalogueData.discovered_likes)
			end
		end
	end
	
	local contextChar = char or ender
	local message = GetDynamicDeliveryString(baseKey, self, contextChar)
	local buttons = GetDeliveryButtonLabels(self.lastDynamicKey)
	
	self.oncomplete_label = buttons.ok
	self.oncomplete_label_length = "long"
	
	return GetReplacedString("#" .. message) 
end

function DeliveryQuest:Complete(char, building)
	-- Override the base Complete() hook specifically to handle Evil Schemes,
	-- where completing the quest triggers a dice-roll rather than a guaranteed payout.
	if self.isEvilScheme then
		DebugOut("QUEST", string.format("Processing Evil Scheme gambling completion logic for: %s", self.name))
		
		if self:IsReal() then Player.lastCompleteTime = Player.time end
		
		Player.questsWaiting[self.name] = nil
		Player.questsActive[self.name] = nil
		Player.questsComplete[self.name] = Player.time
		Player.questDifficulty[self.name] = nil
		
		if Player.questPrimary == self.name then Player:SetPrimaryQuest(nil) end

		local reward_list = self.oncomplete
		local difficulty = Player.questDifficulty[self.name] or Player.difficulty or 1
		
		if difficulty == 2 and self.oncomplete_medium then 
			reward_list = self.oncomplete_medium
		elseif difficulty == 3 and self.oncomplete_hard then 
			reward_list = self.oncomplete_hard 
		end

		ApplyGiftList(reward_list, self)
		
		-- Returning True silences the generic building dialogue engine
		return true
	else
		-- Standard Delivery
		return Quest.Complete(self, char, building)
	end
end

function DeliveryQuest:GetIncompleteString(char)
	local ender = self:GetEnder()
	local baseKey = "delivery_incomplete"
	local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
	local weeksLeft = (self.expires or 0) - weeksPassed

	if weeksPassed == 0 then 
		baseKey = "delivery_incomplete_very_early"
	elseif weeksLeft <= 2 and self.expires > 4 then 
		baseKey = "delivery_incomplete_very_late" 
	elseif weeksLeft <= (self.expires * 0.25) and self.expires > 4 then 
		baseKey = "delivery_incomplete_late" 
	end

	local contextChar = char or ender
	local text = GetDynamicDeliveryString(baseKey, self, contextChar)
	local buttons = GetDeliveryButtonLabels(self.lastDynamicKey)
	
	self.onincomplete_label = buttons.ok
	self.onincomplete_label_length = "medium" 
	
	return text
end

function DeliveryQuest:GetExpiredString() 
	return GetDynamicDeliveryString("delivery_expired", self, self:GetEnder()) 
end

function DeliveryQuest:GetSummary()
	local baseKey = "delivery_summary"
	if self.items then
		local count = table.getn(self.items)
		if count == 2 then baseKey = "delivery_summary_multi2"
		elseif count == 3 then baseKey = "delivery_summary_multi3" end
	end
	return SubstituteQuestParams(GetString(baseKey), self)
end

function DeliveryQuest:Expire(char, building)
	Quest.Expire(self, char, building)
	
	Player.pendingAftermaths = Player.pendingAftermaths or {}
	local aftermathBaseKey = self.isEvilScheme and "delivery_aftermath_expired_evilscheme" or "delivery_aftermath_expired"
	
	local weeksPassed = Player.time - (Player.questsActive[self.name] or Player.time)
	local weeksLeft = (self.expires or 0) - weeksPassed
	local prodName = _AllProducts[self.product] and _AllProducts[self.product]:GetName() or "Unknown"
	local itemName = self.items and FormatMultiItemString(self.items) or prodName
	local countStr = (self.items and table.getn(self.items) > 1) and "a shipment of" or tostring(self.count)
	
	local aftermath = {
		starter = self:GetStarterName(),
		baseKey = aftermathBaseKey,
		item = itemName,
		quantity = countStr,
		product = prodName,
		ender_char = GetString(self:GetEnderName()),
		salary = self.price,
		deadline_weeksleft = tostring(weeksLeft),
		deadline = tostring(self.expires),
		port = GetString(self.endport)
	}
	
	table.insert(Player.pendingAftermaths, aftermath)
	DebugOut("QUEST", string.format("Queued expiration aftermath dialogue for %s.", aftermath.starter))
end

function DeliveryQuest:GetSaveTable()
	return {
		product = self.product, count = self.count, items = self.items, price = self.price,
		starter = self:GetStarterName(), ender = self:GetEnder().name, endbuilding = self.endbuilding,
		startbuilding = self.startbuilding, expires = self.expires, name = self.name,
		isResident = self.isResident, sourcePool = self.sourcePool, forceTelegram = self.forceTelegram, isEvilScheme = self.isEvilScheme
	}
end

-- Constructs the fully fleshed-out delivery quest object from raw data
function CreateDeliveryQuest(t, isResident, sourcePool)
	local q = {}
	for k, v in pairs(DeliveryQuest) do q[k] = v end
	setmetatable(q, DeliveryQuest)
	
	q.product = t.product 
	q.count = t.count
	q.items = t.items 
	q.price = t.price
	q.startbuilding = t.startbuilding
	q.starter = { _AllCharacters[t.starter] }
	q.ender = { _AllCharacters[t.ender] }
	q.endbuilding = t.endbuilding
	q.endport = _AllBuildings[q.endbuilding].port.name
	q.expires = t.expires
	
	q.isResident = t.isResident or isResident
	q.sourcePool = t.sourcePool or sourcePool
	q.forceTelegram = t.forceTelegram or false
	q.isEvilScheme = t.isEvilScheme or false 
	
	q.goals = {}
	q.oncomplete = {}

	-- Populate goals
	if q.items and table.getn(q.items) > 1 then
		for _, item in ipairs(q.items) do
			table.insert(q.goals, RequireItem(item.product, item.count))
			if not q.isEvilScheme then
				table.insert(q.oncomplete, AwardItem(item.product, -item.count))
			end
		end
	else
		table.insert(q.goals, RequireItem(q.product, q.count))
		if not q.isEvilScheme then
			table.insert(q.oncomplete, AwardItem(q.product, -q.count))
		end
	end

	table.insert(q.goals, HintPerson(q:GetEnder().name, q.endbuilding, q.endport))
	table.insert(q.goals, HintExpirationWeeks())
	
	if not q.isEvilScheme then 
		table.insert(q.oncomplete, AwardMoney(q.price)) 
	end
	
	q.onaccept = {}
	q.onreject = {}
	q.onexpire = {}
	
	-- -----------------------------------------------------
	-- The Evil Scheme System
	-- -----------------------------------------------------
	-- When delivering to evil characters, they will ALWAYS take your inventory,
	-- but they have a 75% chance of rolling a massive consequence instead of paying you.
	if q.isEvilScheme then
		
		-- Confiscate the inventory
		if q.items and table.getn(q.items) > 1 then
			for _, item in ipairs(q.items) do 
				table.insert(q.oncomplete, AwardItem(item.product, -item.count)) 
			end
		else
			table.insert(q.oncomplete, AwardItem(q.product, -q.count))
		end
		
		-- Bind the Casino Gamble logic
		local evilGambleAction = {
			Apply = function(self)
				local enderChar = q:GetEnder()
				local roll = RandRange(1, 4)
				
				if roll == 1 then
					-- 25% Chance: Success (Pays out massive boosted price)
					DebugOut("QUEST", string.format("Evil Scheme Resolution: SUCCESS. Paying out %s", Dollars(q.price)))
					Player:AddMoney(q.price)
					
					local key = "delivery_complete_" .. enderChar.name .. "_success"
					local count = 1
					while GetString(key .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
					local finalKey = key .. "_" .. RandRange(1, count)
					
					local text = SubstituteQuestParams(GetString(finalKey), q, enderChar)
					local buttons = GetDeliveryButtonLabels(finalKey)
					
					DisplayDialog { "ui/ui_character_generic.lua", char=enderChar, text="#"..text, building=_AllBuildings[q.endbuilding], ok=buttons.ok, ok_length="long" }
				else
					-- 75% Chance: Critical Failure
					SoundEvent("negative_haggle")
					local penaltyType = RandRange(1, 3)
					local penaltyKey = ""
					
					if penaltyType == 1 then
						-- They just keep the chocolate and refuse to pay
						DebugOut("QUEST", "Evil Scheme Resolution: FAILURE (No Pay / Total Loss)")
						penaltyKey = "nopay"
						
					elseif penaltyType == 2 then
						-- They rob your ingredient stock
						penaltyKey = "theft"
						local stealCandidates = {}
						
						for name, count in pairs(Player.ingredients) do 
							if count > 0 then table.insert(stealCandidates, name) end 
						end
						
						if table.getn(stealCandidates) > 0 then
							local stolenName = stealCandidates[RandRange(1, table.getn(stealCandidates))]
							local stolenAmount = Player.ingredients[stolenName]
							
							DebugOut("QUEST", string.format("Evil Scheme Resolution: FAILURE (Theft). Lost %d sacks of %s.", stolenAmount, stolenName))
							
							Player:AddIngredient(stolenName, -stolenAmount)
							q.stolen_ingredient = GetString(stolenName)
						else
							q.stolen_ingredient = GetString("ingredient_generic_fallback")
						end
						
					elseif penaltyType == 3 then
						-- They sabotage your supply chain, shutting down a random factory completely
						penaltyKey = "stall"
						local ownedFactories = {}
						
						for name, info in pairs(Player.factories) do
							local b = _AllBuildings[name]
							if b and b:IsOwned() then table.insert(ownedFactories, name) end
						end
						
						if table.getn(ownedFactories) > 0 then
							local targetFactory = ownedFactories[RandRange(1, table.getn(ownedFactories))]
							DebugOut("QUEST", string.format("Evil Scheme Resolution: FAILURE (Sabotage). Shutting down production at %s.", targetFactory))
							
							if Player.factories[targetFactory] then
								Player.factories[targetFactory].production = 0
								Player:UpdateNeeds()
							end
							
							q.sabotaged_factory = GetString(targetFactory)
							local facBldg = _AllBuildings[targetFactory]
							if facBldg then 
								q.sabotaged_port = GetString(facBldg.port.name) 
							end
						else
							penaltyKey = "nopay"
						end
					end
					
					QueueDeliveryAftermath(q, "complete", penaltyKey)

					local key = "delivery_complete_" .. enderChar.name .. "_fail_" .. penaltyKey
					local count = 1
					while GetString(key .. "_" .. (count + 1)) ~= "#####" do count = count + 1 end
					local finalKey = key .. "_" .. RandRange(1, count)
					
					local text = SubstituteQuestParams(GetString(finalKey), q, enderChar)
					
					-- Clean up temp values
					q.stolen_ingredient = nil
					q.sabotaged_factory = nil
					q.sabotaged_port = nil
					
					local buttons = GetDeliveryButtonLabels(finalKey)
					DisplayDialog { "ui/ui_character_generic.lua", char=enderChar, text="#"..text, building=_AllBuildings[q.endbuilding], mood="angry", ok=buttons.ok, ok_length="long" }
				end
				
				return true, true
			end
		}
		
		table.insert(q.oncomplete, evilGambleAction)
	end
	
	-- Populate scaling rewards
	if not q.items then 
		q.oncomplete_very_early = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, 75) }
		q.oncomplete_early = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, 50) }
		q.oncomplete_late = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, -10) }
		q.oncomplete_very_late = { AwardItem(q.product, -q.count), AwardMoney(q.price), AwardHappiness(t.ender, -20) }
	else
		table.insert(q.oncomplete, AwardHappiness(t.ender, 30))
	end
	
	if q.isEvilScheme then
		q.oncomplete_very_early = nil
		q.oncomplete_early = nil
		q.oncomplete_late = nil
		q.oncomplete_very_late = nil
	end

	-- Garbage collection hooks
	local cleanupAction = { Apply = function(self) Player.questOfferText[t.name] = nil; return true; end }
	table.insert(q.onreject, cleanupAction)
	table.insert(q.oncomplete, cleanupAction)
	table.insert(q.onexpire, cleanupAction)
	
	local removePendingOrderAction = { Apply = function(self)
		for i, order in ipairs(Player.pendingSpecialOrders) do
			if order.name == t.name then
				table.remove(Player.pendingSpecialOrders, i)
				break
			end
		end
		return true
	end }
	
	table.insert(q.onaccept, removePendingOrderAction)
	table.insert(q.onreject, removePendingOrderAction)
	table.insert(q.oncomplete, removePendingOrderAction)
	table.insert(q.onexpire, removePendingOrderAction)

	-- Location logic for traveling NPCs
	if not q.isResident then
		local source = q.sourcePool or "_empty"
		
		-- On Accept: Move character to the target building and flag them so they aren't generated again.
		table.insert(q.onaccept, AwardRemoveCharacter(t.ender, source))
		table.insert(q.onaccept, AwardPlaceCharacter(t.ender, t.endbuilding))
		table.insert(q.onaccept, AwardDisableOrderForChar(t.ender))
		table.insert(q.onaccept, AwardDisableOrderForBuilding(t.endbuilding))
		
		-- Reversal actions
		table.insert(q.onreject, AwardRemoveCharacter(t.ender, t.endbuilding))
		table.insert(q.onreject, AwardPlaceCharacter(t.ender, source))
		table.insert(q.onreject, AwardEnableOrderForChar(t.ender))
		table.insert(q.onreject, AwardEnableOrderForBuilding(t.endbuilding))

		table.insert(q.oncomplete, AwardRemoveCharacter(t.ender, t.endbuilding))
		table.insert(q.oncomplete, AwardPlaceCharacter(t.ender, source))
		table.insert(q.oncomplete, AwardEnableOrderForChar(t.ender))
		table.insert(q.oncomplete, AwardEnableOrderForBuilding(t.endbuilding))
		
		table.insert(q.onexpire, AwardRemoveCharacter(t.ender, t.endbuilding))
		table.insert(q.onexpire, AwardPlaceCharacter(t.ender, source))
		table.insert(q.onexpire, AwardEnableOrderForChar(t.ender))
		table.insert(q.onexpire, AwardEnableOrderForBuilding(t.endbuilding))
	end
	
	q.name = t.name
	_AllQuests[q.name] = q
	
	return q
end

------------------------------------------------------------------------------
-- Procedural Generation Core
------------------------------------------------------------------------------

-- Builds a procedurally generated task based on economy weights, difficulty, and network size
function RandomDeliveryQuest(startShop)
	local t = {}
	
	-- 1. Identify the origin location
	if not startShop then
		local ownedShops = {}
		for name, _ in pairs(Player.buildingsOwned) do
			local b = _AllBuildings[name]
			if b and b.type == "shop" then table.insert(ownedShops, b) end
		end
		
		if table.getn(ownedShops) > 0 then
			startShop = ownedShops[RandRange(1, table.getn(ownedShops))]
		else
			startShop = zur_shop 
		end
	end
	
	t.startbuilding = startShop.name
	
	local starterChar = startShop:GetCharacterList()[1]
	if starterChar then t.starter = starterChar.name end

	local isResident = false
	local sourcePool = "_empty" 

	-- 2. Find Valid Destinations
	local allBuildings = {}
	for name, port in pairs(_AllPorts) do
		if port:IsAvailable() then
			for _, b in ipairs(port.buildings) do
				-- Exclude special buildings, the origin building, and currently banned buildings
				if b.type ~= "special" and b.name ~= startShop.name and not Player.orderBannedBuildings[b.name] then
					table.insert(allBuildings, b)
				end
			end
		end
	end

	if table.getn(allBuildings) == 0 then return nil end
	local building = allBuildings[RandRange(1, table.getn(allBuildings))]
	t.endbuilding = building.name

	-- Certain buildings have high probability of receiving travelers
	local forceNonResident = false
	local special_buildings = { zur_station = true, zur_school = true, hav_hotel = true, tan_hotel = true, san_bar = true }
	if special_buildings[building.name] and RandRange(1, 2) == 1 then 
		forceNonResident = true 
	end

	-- 3. Find Valid Receiver Characters
	local enderCharObject = nil
	local charList = building:GetResidentCharacterList()
	
	-- Check for permanent residents first
	if charList and table.getn(charList) > 0 and not forceNonResident then
		local eligibleResidents = {}
		for _, char in ipairs(charList) do
			if not Player.orderBannedChars[char.name] then 
				table.insert(eligibleResidents, char) 
			end
		end
		
		if table.getn(eligibleResidents) > 0 then
			enderCharObject = eligibleResidents[RandRange(1, table.getn(eligibleResidents))]
			t.ender = enderCharObject.name
			isResident = true
		end
	end
	
	-- Verify residency logic
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
	
	-- Process travelers if no resident was selected
	if not isResident then
		if not enderCharObject or not isResident then
			local filteredTravelers, filteredEmpty = {}, {}
			
			for _, char in ipairs(_travelers:GetCharacterList()) do 
				if not Player.orderBannedChars[char.name] then table.insert(filteredTravelers, char) end 
			end
			
			for _, char in ipairs(_empty:GetCharacterList()) do 
				if not Player.orderBannedChars[char.name] then table.insert(filteredEmpty, char) end 
			end

			local chosenPool = nil
			if table.getn(filteredTravelers) > 0 and table.getn(filteredEmpty) > 0 then
				chosenPool = (RandRange(1, 2) == 1) and filteredTravelers or filteredEmpty
				sourcePool = (chosenPool == filteredTravelers) and "_travelers" or "_empty"
			elseif table.getn(filteredTravelers) > 0 then
				chosenPool, sourcePool = filteredTravelers, "_travelers"
			elseif table.getn(filteredEmpty) > 0 then
				chosenPool, sourcePool = filteredEmpty, "_empty"
			else
				return nil
			end
			
			enderCharObject = chosenPool[RandRange(1, table.getn(chosenPool))]
			t.ender = enderCharObject.name
			isResident = false
		end
	end

	if not t.ender or not enderCharObject then return nil end

	-- 4. Determine Moral Alignment for Gambling Traps
	local isEvil = false
	if Tips.evilCharacters[t.ender] then
		isEvil = true
		if t.ender == "evil_kath" and Player.questsComplete["rank4_kath_bribe"] then
			isEvil = false
		end
	end

	-- 5. Calculate Inventory Payloads
	local maxItems = 1
	if Player.rank >= 3 and RandRange(1, 100) <= 30 then
		maxItems = RandRange(2, 3)
		DebugOut("QUEST", string.format("Generating MULTI-ITEM order (Size: %d) for %s.", maxItems, t.ender))
	end

	local potentialProducts = {}
	for code, prod in pairs(_AllProducts) do
		if prod:IsKnown() then
			local canConsume, reason = enderCharObject:CanConsume(prod)
			if canConsume then table.insert(potentialProducts, prod) end
		end
	end
	
	if table.getn(potentialProducts) == 0 then return nil end

	-- Selection Algorithm: Biasing towards items the character canonically likes
	local function PickWeightedProduct(pool)
		local weightedList = {}
		local dislikes = enderCharObject.dislikes or {}
		local likes = enderCharObject.likes or {}
		
		for _, prod in ipairs(pool) do
			local isDisliked = false
			
			if dislikes.products and dislikes.products[prod.code] then isDisliked = true end
			if not isDisliked and dislikes.categories and dislikes.categories[prod.category.name] then isDisliked = true end
			if not isDisliked and dislikes.ingredients then
				for ingredientName, _ in pairs(prod.counts) do
					if dislikes.ingredients[ingredientName] then isDisliked = true; break; end
				end
			end
			
			if not isDisliked then
				local weight = 1
				
				if likes.products and likes.products[prod.code] then weight = weight + 4 end
				if likes.categories and likes.categories[prod.category.name] then weight = weight + 2 end
				if likes.ingredients then
					for ingredientName, _ in pairs(prod.counts) do
						if likes.ingredients[ingredientName] then weight = weight + 1 end
					end
				end
				
				for i = 1, weight do table.insert(weightedList, prod) end
			end
		end
		
		if table.getn(weightedList) == 0 then weightedList = pool end
		if table.getn(weightedList) == 0 then return nil end
		
		return weightedList[RandRange(1, table.getn(weightedList))]
	end

	local finalItems = {}
	local totalPrice = 0
	local usedCodes = {}
	local usedFactories = {}

	for i = 1, maxItems do
		local prod = PickWeightedProduct(potentialProducts)
		if prod and not usedCodes[prod.code] then
			local count = Player.rank * RandRange(10, 40)
			local price = Floor(prod.price_high * 3) * count
			
			-- Scale payload sizes by difficulty
			if Player.difficulty == 2 then
				count = Floor(count * 1.5)
				price = Floor(price * 0.9)
			elseif Player.difficulty == 3 then
				count = Floor(count * 2.0)
				price = Floor(price * 0.6)
			end

			table.insert(finalItems, { product = prod.code, count = count, price = price })
			totalPrice = totalPrice + price
			usedCodes[prod.code] = true
			
			if prod.category and prod.category.factory then 
				usedFactories[prod.category.factory] = true 
			end
		end
	end

	if table.getn(finalItems) == 0 then return nil end

	-- 6. Payout Logic
	-- If they want multiple types of products, we increase the payout multiplier
	if table.getn(finalItems) > 1 then
		local numItems = table.getn(finalItems)
		local complexityBonus = 1.0 + ((numItems - 1) * 0.15)
		
		-- Give a logistics hazard pay bonus if the products require completely separate factories
		local numFactories = 0
		for _ in pairs(usedFactories) do numFactories = numFactories + 1 end
		
		if numFactories > 1 then
			complexityBonus = complexityBonus + 0.10 
		end

		totalPrice = Floor(totalPrice * complexityBonus)
		DebugOut("QUEST", string.format("Applied multi-item complexity bonus x%.2f. New total payout: %s", complexityBonus, Dollars(totalPrice)))
	end

	t.items = finalItems
	t.product = finalItems[1].product 
	t.count = finalItems[1].count 
	t.price = totalPrice 

	if isEvil then
		t.isEvilScheme = true
		t.price = Floor(t.price * 2.5) 
		DebugOut("QUEST", string.format("Evil Scheme flagged for %s. Bribe/Trap payout boosted to %s", t.ender, Dollars(t.price)))
	end
	
	-- 7. Deadline Math
	if Player.rank == 2 then t.expires = RandRange(16, 20)
	elseif Player.rank == 3 then t.expires = RandRange(12, 16)
	elseif Player.rank == 4 then t.expires = RandRange(10, 14)
	elseif Player.rank == 5 then t.expires = RandRange(8, 12)
	else t.expires = 8 end
	
	t.expires = t.expires * 2
	
	if table.getn(finalItems) > 1 then
		local extraWeeks = (table.getn(finalItems) - 1) * 4
		t.expires = t.expires + extraWeeks
	end
	
	if Player.difficulty == 2 then 
		t.expires = Floor(t.expires * 0.75)
	elseif Player.difficulty == 3 then 
		t.expires = Floor(t.expires * 0.5) 
	end
	
	t.name = "delivery_" .. tostring(Player.time) .. "_" .. t.ender .. "_" .. RandRange(1, 1000)
	
	return CreateDeliveryQuest(t, isResident, sourcePool)
end

-- Evaluates the probabilities of the player's shopping network generating new requests.
-- Called exactly once per week tick.
function UpdateSpecialOrders()
	local function Max(a, b) if a > b then return a else return b end end
	local function Count(t) local c = 0; for _ in pairs(t or {}) do c = c + 1 end; return c end

	-- Abort early if the player has no shops
	if not Player.shopsOwned or Player.shopsOwned == 0 then return end

	-- Maximum allowed concurrent orders = (Owned Shops / 2), minimum of 1
	local pending = Player.pendingSpecialOrders or {}
	local pendingCount = Count(pending)  
	local pendingCap = Max(1, Floor((Player.shopsOwned or 0) / 2))  
	
	if pendingCount >= pendingCap then
		DebugOut("QUEST", string.format("Pending order queue full (%d/%d). Skipping procedural generation.", pendingCount, pendingCap))
		return
	end

	-- Balance Modifier: As the player monopolizes the map with more shops,
	-- the generation rate for each individual shop is slowed to maintain overall game pacing.
	local balance_modifier = 1.0 - ((Player.shopsOwned - 1) * 0.04)
	if balance_modifier < 0.20 then balance_modifier = 0.20 end 
	
	DebugOut("QUEST", string.format("Network Status: %d Shops Owned. Equilibrium Rate Modifier: %.2f.", Player.shopsOwned, balance_modifier))

	local base_chance_increase = 3
	local order_cooldown_duration = 12
	local rank_damp = 1.0 - 0.10 * ((Player.rank or 1) - 1)
	
	if rank_damp < 0.60 then rank_damp = 0.60 end

	for shopName, _ in pairs(Player.buildingsOwned) do
		local shop = _AllBuildings[shopName]
		
		if shop and shop.type == "shop" then
			if not Player.shopOrderData[shopName] then
				Player.shopOrderData[shopName] = { chance = 0, cooldown = 0 }
			end

			local data = Player.shopOrderData[shopName]
			
			if data.cooldown and data.cooldown > Player.time then
				DebugOut("QUEST", string.format("%s is on operational cooldown. (Ends Week %d)", shop.name, data.cooldown))
			else
				if data.cooldown ~= 0 then
					data.cooldown = 0 
					DebugOut("QUEST", string.format("%s cooldown has expired. Resuming background order generation.", shop.name))
				end

				-- Escalate the probability chance factor for this week
				local chance_increase = base_chance_increase * balance_modifier * rank_damp
				local old_chance = data.chance or 0
				data.chance = old_chance + chance_increase
				
				DebugOut("QUEST", string.format("%s: Internal order chance escalated by %.2f%% (Current: %.2f%%) [Rank Dampener: %.2f]", shop.name, chance_increase, data.chance, rank_damp))

				-- Roll for success
				local roll = RandRange(1, 100)
				if roll <= data.chance or data.chance >= 100 then
					
					if data.chance >= 100 then
						DebugOut("QUEST", string.format("Network Roll for %s: FORCED (100%% threshold reached). Generating request.", shop.name))
					else
						DebugOut("QUEST", string.format("Network Roll for %s: %d <= %.2f. SUCCESS! Generating request.", shop.name, roll, data.chance))
					end
					
					local orderQuest = RandomDeliveryQuest(shop)
					
					if orderQuest then
						local questData = orderQuest:GetSaveTable()
						questData.earlyOfferCutoff = Player.time + 6 
						
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
			
						-- If the generated client is a traveler, pull them out of the background arrays
						-- and lock them into a physical location so the player can actually find them.
						if not isResident then
							local sourcePool = "_empty" 
							
							for _, travName in ipairs(_TravelCharacters) do
								if travName == questData.ender then
									sourcePool = "_travelers"
									break
								end
							end
							questData.sourcePool = sourcePool
							
							DebugOut("QUEST", string.format("Placing traveling client '%s' into '%s' to await pending order. (Sourced from %s)", questData.ender, questData.endbuilding, sourcePool))
							
							if Player.buildingCharacters[sourcePool] then
								Player.buildingCharacters[sourcePool][questData.ender] = nil
							end
							
							Player.buildingCharacters[questData.endbuilding] = Player.buildingCharacters[questData.endbuilding] or {}
							Player.buildingCharacters[questData.endbuilding][questData.ender] = true
							
							Player.orderBannedChars[questData.ender] = true
							Player.orderBannedBuildings[questData.endbuilding] = true
						end
						
						questData.isResident = isResident
						
						table.insert(Player.pendingSpecialOrders, questData)
						DebugOut("QUEST", string.format("Successfully locked and QUEUED special order: %s", orderQuest.name))
						
						data.chance = 0
						data.cooldown = Player.time + order_cooldown_duration
					else
						DebugOut("QUEST", string.format("Procedural engine failed to assemble order for %s (Missing eligible inventory?). Generation aborted.", shop.name))
					end
				else
					DebugOut("QUEST", string.format("Network Roll for %s: %d > %.2f. No requests surfaced this week.", shop.name, roll, data.chance))
				end
			end
		end
	end
end