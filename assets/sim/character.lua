--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Character" is a non-player character

Character =
{
	name = nil,					-- Name of this character
	actions = nil,				-- List of character actions
	haggleFactor = 1,			-- Default: no haggle preference
	
	-- Character preferences
    likes = nil,                -- Table of preferred items { "ingredient_name"=weight, "category_name"=weight, "product_code"=weight }
    dislikes = nil,             -- Table of disliked items { "ingredient_name"=true, "category_name"=true, "product_code"=true }
	
	-- Cross-references
	questStarts = nil,			-- List of quests started by this character
	questEnds = nil,			-- List of quests ended by this character

	-- Mood constants
	kHappy = 70,				-- "Happy" threshold
	kNeutral = 50,				-- "Neutral" value
	kAngry = 25,				-- "Angry" threshold
	kHaggleDelta = 4,			-- Amount of mood change when Haggling
	kPurchaseDelta = 10,		-- Amount of mood change when making a purchase
}

Character.__tostring = function(t) return "{Character:"..tostring(t.name).."}" end

_AllCharacters = {}
_PrimaryCharacters = {}

------------------------------------------------------------------------------
-- Default character actions

Character.actions = { SpeakDynamic() }

------------------------------------------------------------------------------
-- Player-specific accessors

function Character:GetHappiness()
	-- Quick bail out: default happiness is 50
	local happiness = Player.charHappiness[self.name]
	if not happiness then return 50 end
	
	-- Calculate the character's happiness change since last meeting...
	-- Happiness trends toward 50 over time, one point per simulator tick
	local deltaTime = Player.time - (Player.charHappinessTime[self.name] or Player.time)
	if deltaTime > 0 then
		if happiness < 50 then
			happiness = happiness + deltaTime
			if happiness > 50 then happiness = 50 end
		elseif happiness > 50 then
			happiness = happiness - deltaTime
			if happiness < 50 then happiness = 50 end
		end
		
		-- Only track happiness if it is not the default
		if happiness == 50 then
			Player.charHappiness[self.name] = nil
			Player.charHappinessTime[self.name] = nil
		else
			Player.charHappiness[self.name] = happiness
			Player.charHappinessTime[self.name] = Player.time
		end
	end
	return happiness
end

function Character:IsHappy()
	return (self:GetHappiness() >= Character.kHappy)
end

function Character:IsAngry()
	return (self:GetHappiness() <= Character.kAngry)
end

function Character:SetHappiness(h)
	-- Only track non-default (50) happiness
	if h == 50 then
		Player.charHappiness[self.name] = nil
		Player.charHappinessTime[self.name] = nil
	else
		if h < 0 then h = 0
		elseif h > 100 then h = 100
		end
		
		Player.charHappiness[self.name] = h
		Player.charHappinessTime[self.name] = Player.time
	end
	
    DebugOut("CHAR", "Set happiness for " .. self.name .. " to " .. h)
	SetMood(self.name, h)
end

function Character:BumpHappiness(delta)
	local n = self:GetHappiness() + delta
	if n < 0 then n = 0
	elseif n > 100 then n = 100
	end
	
    DebugOut("CHAR", "Bumping happiness for " .. self.name .. " by " .. delta .. ". New value: " .. n)

	Player.charHappiness[self.name] = n
	Player.charHappinessTime[self.name] = Player.time
	SetMood(self.name, n)
end

function Character:MakeAngry()
	self:SetHappiness(Character.kAngry - 10)
end

function Character:MakeNeutral()
	self:SetHappiness(Character.kNeutral)
end

function Character:MakeHappy()
	self:SetHappiness(Character.kHappy + 10)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Character:Create(name)
	local t = nil
	if not name then
		-- TODO: WARN: No Name given
	elseif _AllCharacters[name] then
		DebugOut("ERROR", "ALREADY DEFINED: "..tostring(name))
		t = _AllCharacters[name]
	elseif _G[name] then
		-- TODO: WARN: Variable with this name already exists
	else
--		DebugOut("CHARACTER:"..tostring(name))
        DebugOut("CHAR", "Created character: " .. name)
	
		t = {} setmetatable(t, self) self.__index = self
		_AllCharacters[name] = t
		_G[name] = t
		
		-- Initialize other character values
		t.name = name
	end
	
	return t
end

function CreateCharacter(name) return Character:Create(name) end

function CreatePrimaryCharacter(name)
	local c = Character:Create(name)
	table.insert(_PrimaryCharacters, c)
	c.primary = true
	return c
end

------------------------------------------------------------------------------
-- Load post-processing

function PrepareCharactersForBuildings()
	-- For every building, for every set of rank-based character lists, for every character
	for _,building in pairs(_AllBuildings) do
		for _,charList in ipairs(building.characters) do
			for i,charName in ipairs(charList) do
				if type(charName) == "string" then
					charList[i] = _AllCharacters[charName] or CreateCharacter(charName)
				end
			end
		end
	end
end

function Character:AddStartQuest(quest)
	self.questStarts = self.questStarts or {}
	table.insert(self.questStarts, quest)
end

function Character:AddEndQuest(quest)
	self.questEnds = self.questEnds or {}
	table.insert(self.questEnds, quest)
end

------------------------------------------------------------------------------
-- Actions

function Character:RandomAction(building)
	if self.actions and table.getn(self.actions) > 0 then
		local n = table.getn(self.actions)
		if n > 1 then n = RandRange(1, n) end
		local a = self.actions[n]
		if a.DoAction then a:DoAction(self, building) end
	end
end