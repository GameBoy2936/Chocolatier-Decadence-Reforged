--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Character Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Character" represents an NPC in the world. They handle dialogue, quests, 
-- trading haggling logic, and personal data (dietary restrictions, likes/dislikes).

Character =
{
	-- ==========================================
	-- Core Identity
	-- ==========================================
	name = nil,					-- Internal key (e.g., "baker_john")
	actions = nil,				-- List of interaction action blocks available on click
	haggleFactor = 1,			-- 1.0 base. Lower values indicate NPCs who hate to haggle.
	
	-- ==========================================
	-- Demographics & Lore
	-- ==========================================
	gender = nil,				-- "male", "female", "nonbinary"
	nationality = nil,			-- Country code string (e.g., "usa", "pakistan")
	religion = nil,				-- Cultural background ("christian", "muslim", "hindu", etc.)
	dietaryreqs = nil,			-- Dietary flags { alcohol_free=true, halal=true, kosher=true, lactose_free=true, no_beef=true }
	
	-- ==========================================
	-- Preferences (Gift/Order System)
	-- ==========================================
	likes = nil,                -- Table of preferred items { "ingredient_name"=weight, "category_name"=weight, "product_code"=weight }
	dislikes = nil,             -- Table of disliked items { "ingredient_name"=true, "category_name"=true, "product_code"=true }
	
	-- ==========================================
	-- Quest Tracking
	-- ==========================================
	questStarts = nil,			-- Array of quests where this character is the giver
	questEnds = nil,			-- Array of quests where this character is the recipient

	-- ==========================================
	-- Mood Constants
	-- ==========================================
	kHappy = 70,				-- Happiness >= 70 is "Happy"
	kNeutral = 50,				-- Happiness == 50 is "Neutral" (Baseline)
	kAngry = 25,				-- Happiness <= 25 is "Angry"
	
	kHaggleDelta = 4,			-- Amount of mood change when Haggling (Positive on success, negative on fail)
	kPurchaseDelta = 10,		-- Amount of mood change when completing a transaction
}

-- Metamethod for debug logging
Character.__tostring = function(t) return "{Character:" .. tostring(t.name) .. "}" end

-- Global Registries
_AllCharacters = {}
_PrimaryCharacters = {}

------------------------------------------------------------------------------
-- Default Behaviors
------------------------------------------------------------------------------

-- Unless overridden, all characters simply speak their dynamic dialogue when clicked
Character.actions = { SpeakDynamic() }

------------------------------------------------------------------------------
-- Mood & Happiness State Management
------------------------------------------------------------------------------

-- Retrieves current happiness, gradually trending it back towards the 50 baseline over time.
function Character:GetHappiness()
	local happiness = Player.charHappiness[self.name]
	if not happiness then return Character.kNeutral end
	
	-- Calculate the character's emotional decay since the last time the player interacted with them.
	-- Happiness drifts 1 point back towards 50 for every simulator week (tick) that passes.
	local deltaTime = Player.time - (Player.charHappinessTime[self.name] or Player.time)
	
	if deltaTime > 0 then
		if happiness < Character.kNeutral then
			happiness = happiness + deltaTime
			if happiness > Character.kNeutral then happiness = Character.kNeutral end
		elseif happiness > Character.kNeutral then
			happiness = happiness - deltaTime
			if happiness < Character.kNeutral then happiness = Character.kNeutral end
		end
		
		-- If they have fully returned to baseline, clear them from the player save table to save memory
		if happiness == Character.kNeutral then
			Player.charHappiness[self.name] = nil
			Player.charHappinessTime[self.name] = nil
		else
			Player.charHappiness[self.name] = happiness
			Player.charHappinessTime[self.name] = Player.time
		end
	end
	
	return happiness
end

function Character:IsHappy() return (self:GetHappiness() >= Character.kHappy) end
function Character:IsAngry() return (self:GetHappiness() <= Character.kAngry) end

-- Explicitly force the character's happiness to a specific integer
function Character:SetHappiness(h)
	if h == Character.kNeutral then
		Player.charHappiness[self.name] = nil
		Player.charHappinessTime[self.name] = nil
	else
		if h < 0 then h = 0
		elseif h > 100 then h = 100
		end
		
		Player.charHappiness[self.name] = h
		Player.charHappinessTime[self.name] = Player.time
	end
	
	DebugOut("CHAR", string.format("Set happiness for '%s' to %d", self.name, h))
	SetMood(self.name, h)
end

-- Adjust the character's happiness by a relative delta value
function Character:BumpHappiness(delta)
	local n = self:GetHappiness() + delta
	if n < 0 then n = 0
	elseif n > 100 then n = 100
	end
	
	DebugOut("CHAR", string.format("Bumped happiness for '%s' by %d (New: %d)", self.name, delta, n))

	Player.charHappiness[self.name] = n
	Player.charHappinessTime[self.name] = Player.time
	SetMood(self.name, n)
end

-- Pre-set emotional triggers
function Character:MakeAngry() self:SetHappiness(Character.kAngry - 10) end
function Character:MakeNeutral() self:SetHappiness(Character.kNeutral) end
function Character:MakeHappy() self:SetHappiness(Character.kHappy + 10) end

------------------------------------------------------------------------------
-- Identity & Formatting Accessors
------------------------------------------------------------------------------

function Character:GetName()
	return GetString(self.name)
end

function Character:GetFirstName()
	if self.firstname then return GetString(self.firstname) end
	
	-- Fallback: Split GetName() by the first space to extract the first name
	local full = self:GetName()
	local spacePos = string.find(full, " ")
	if spacePos then
		return string.sub(full, 1, spacePos - 1)
	end
	return full
end

function Character:GetLastName()
	if self.lastname then return GetString(self.lastname) end
	
	-- Fallback: Split GetName() by the first space to extract the last name
	local full = self:GetName()
	local spacePos = string.find(full, " ")
	if spacePos then
		return string.sub(full, spacePos + 1)
	end
	return ""
end

-- Used for formal address (Mr., Ms., etc.)
function Character:GetHonorific()
	if self.honorific then return GetString(self.honorific) end
	
	-- Fallback based on assigned gender
	local g = self.gender or "neutral"
	local title = GetString("honorific_default_" .. g)
	
	-- Hardcoded safety fallback if localization string is missing to prevent UI "#####" breaks
	if title == "#####" then
		if g == "male" then return "Mr."
		elseif g == "female" then return "Ms."
		else return "Mx." end
	end
	
	return title
end

-- Builds a table of grammatical substitution tokens mapped to this character.
-- This allows dialogue to dynamically output "He said to give it to him" vs "She said to give it to her".
function GetCharacterTokens(charObj, prefix)
	local t = {}
	if not charObj then return t end
	prefix = prefix or ""
	
	-- 1. Identity Tokens
	t[prefix .. "name"] = charObj:GetName()
	t[prefix .. "firstname"] = charObj:GetFirstName()
	t[prefix .. "lastname"] = charObj:GetLastName()
	t[prefix .. "honorific"] = charObj:GetHonorific()
	
	-- 2. Pronoun Tokens
	local g = charObj.gender or "neutral"
	
	-- Helper to fetch a localized pronoun safely
	local function SafePronoun(key, fallback)
		local s = GetString(key)
		if s == "#####" or s == key then return fallback else return s end
	end

	t[prefix .. "subject"] = SafePronoun("pronoun_subject_" .. g, g=="male" and "He" or (g=="female" and "She" or "They"))
	t[prefix .. "subject_lower"] = SafePronoun("pronoun_subject_lower_" .. g, g=="male" and "he" or (g=="female" and "she" or "they"))
	
	t[prefix .. "object"] = SafePronoun("pronoun_object_" .. g, g=="male" and "Him" or (g=="female" and "Her" or "Them"))
	t[prefix .. "object_lower"] = SafePronoun("pronoun_object_lower_" .. g, g=="male" and "him" or (g=="female" and "her" or "them"))
	
	t[prefix .. "possessive"] = SafePronoun("pronoun_possessive_" .. g, g=="male" and "His" or (g=="female" and "Her" or "Their"))
	t[prefix .. "possessive_lower"] = SafePronoun("pronoun_possessive_lower_" .. g, g=="male" and "his" or (g=="female" and "her" or "their"))
	
	t[prefix .. "possessive_pronoun"] = SafePronoun("pronoun_possessive_pronoun_" .. g, g=="male" and "His" or (g=="female" and "Hers" or "Theirs"))
	t[prefix .. "possessive_pronoun_lower"] = SafePronoun("pronoun_possessive_pronoun_lower_" .. g, g=="male" and "his" or (g=="female" and "hers" or "theirs"))
	
	t[prefix .. "reflexive"] = SafePronoun("pronoun_reflexive_" .. g, g=="male" and "Himself" or (g=="female" and "Herself" or "Themselves"))
	t[prefix .. "reflexive_lower"] = SafePronoun("pronoun_reflexive_lower_" .. g, g=="male" and "himself" or (g=="female" and "herself" or "themselves"))
	
	-- 3. Verb Conjugations (is/are, has/have)
	t[prefix .. "verb_tobe"] = SafePronoun("verb_tobe_" .. g, (g=="neutral") and "are" or "is")
	t[prefix .. "verb_tohave"] = SafePronoun("verb_tohave_" .. g, (g=="neutral") and "have" or "has")

	return t
end

------------------------------------------------------------------------------
-- Dietary Logic
------------------------------------------------------------------------------

-- Verifies if an NPC will accept a gifted/delivered item based on their cultural profile.
function Character:CanConsume(item)
	if not self.dietaryreqs then return true end
	
	-- 1. Alcohol Restriction (Halal, etc.)
	if self.dietaryreqs.alcohol_free then
		if item.alcohol then return false, "alcohol" end
		
		-- If it's a finished product, scan its ingredient list
		if item.counts then
			for name, _ in pairs(item.counts) do
				local ing = _AllIngredients[name]
				if ing and ing.alcohol then return false, "alcohol" end
			end
		end
	end
	
	-- 2. Lactose Restriction
	if self.dietaryreqs.lactose_free then
		if item.category == "dairy" then return false, "dairy" end
		
		if item.counts then
			for name, _ in pairs(item.counts) do
				local ing = _AllIngredients[name]
				if ing and ing.category == "dairy" then return false, "dairy" end
			end
		end
	end
	
	-- 3. Beef Restriction (Hindu diets)
	if self.dietaryreqs.no_beef then
		-- Explicitly flagged animal products (gelatin historically contains beef/pork)
		if item.name == "gelatin" then return false, "beef" end
	end
	
	return true
end

------------------------------------------------------------------------------
-- Lifecycle Methods
------------------------------------------------------------------------------

function Character:Create(name)
	local t = nil
	
	if not name then
		DebugOut("ERROR", "Attempted to create a character with no name.")
	elseif _AllCharacters[name] then
		DebugOut("ERROR", string.format("Character '%s' already defined. Returning existing object.", name))
		t = _AllCharacters[name]
	elseif _G[name] then
		DebugOut("ERROR", string.format("Global variable collision when creating character: %s", name))
	else
		DebugOut("CHAR", string.format("Created character entity: %s", name))
	
		t = {} 
		setmetatable(t, self) 
		self.__index = self
		
		_AllCharacters[name] = t
		_G[name] = t
		
		t.name = name
		t.dietaryreqs = {} 
	end
	
	return t
end

function CreateCharacter(name) 
	return Character:Create(name) 
end

function CreatePrimaryCharacter(name)
	local c = Character:Create(name)
	table.insert(_PrimaryCharacters, c)
	c.primary = true
	return c
end

------------------------------------------------------------------------------
-- Boot-up Mapping
------------------------------------------------------------------------------

-- Iterates all defined buildings and converts their static string-name character lists 
-- into arrays containing the actual instantiated Character objects.
function PrepareCharactersForBuildings()
	for _, building in pairs(_AllBuildings) do
		for _, charList in ipairs(building.characters) do
			for i, charName in ipairs(charList) do
				if type(charName) == "string" then
					charList[i] = _AllCharacters[charName] or CreateCharacter(charName)
				end
			end
		end
	end
end

-- Cross-reference tracking for the quest engine
function Character:AddStartQuest(quest)
	self.questStarts = self.questStarts or {}
	table.insert(self.questStarts, quest)
end

function Character:AddEndQuest(quest)
	self.questEnds = self.questEnds or {}
	table.insert(self.questEnds, quest)
end

------------------------------------------------------------------------------
-- User Interactions
------------------------------------------------------------------------------

-- Executes a random valid interaction action when clicked by the player
function Character:RandomAction(building)
	if self.actions and table.getn(self.actions) > 0 then
		local n = table.getn(self.actions)
		if n > 1 then n = RandRange(1, n) end
		
		local a = self.actions[n]
		if a.DoAction then 
			a:DoAction(self, building) 
		end
	end
end