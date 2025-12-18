--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Building" is a click-able entity in a port

Building =
{
	name = nil,				-- Name of the building itself
	port = nil,				-- Port where the building is located
	enabled = true,			-- Whether or not the building is enabled by default
	x = nil,				-- x-coordinate within the port view
	y = nil,				-- y-coordinate within the port view

	type = "generic",
}

Building.__tostring = function(t) return "{Building:"..tostring(t.name).."}" end

_AllBuildings = {}

-- There are a couple of generic Buildings with different audio types:
Saloon = { cadikey="saloons" }
setmetatable(Saloon, Building)
Saloon.__index = Saloon
Saloon.__tostring = function(t) return "{Saloon:"..tostring(t.name).."}" end
Saloon = Building

TrainStation = { cadikey="train_station" }
setmetatable(TrainStation, Building)
TrainStation.__index = TrainStation
TrainStation.__tostring = function(t) return "{TrainStation:"..tostring(t.name).."}" end
TrainStation = Building

Bank = { cadikey="bank" }
setmetatable(Bank, Building)
Bank.__index = Bank
Bank.__tostring = function(t) return "{Bank:"..tostring(t.name).."}" end

Wilderness = { cadikey = "plantation" }
setmetatable(Wilderness, Building)
Wilderness.__index = Wilderness
Wilderness.__tostring = function(t) return "{Wilderness:"..tostring(t.name).."}" end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

Casino = { cadikey="casino_ambience", type = "casino" }
setmetatable(Casino, Building)
Casino.__index = Casino
Casino.__tostring = function(t) return "{Casino:"..tostring(t.name).."}" end

function Casino:EnterBuilding(char, somethingHappened)
	char = self:RandomCharacter()
    DebugOut("BUILDING", "Player entering casino: " .. self.name)
	DisplayDialog { "ui/ui_slotselect.lua", char=char, building=self }	
	return true
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Building:Create(name, port)
	local t = nil
	if not name then
		-- TODO: WARN: No Name given
--	elseif not port then
--		-- TODO: WARN: No Port given
	else
--		DebugOut("BUILDING:"..tostring(name))
        -- if port then DebugOut("LOAD", "Created building '" .. name .. "' in port '" .. port.name .. "'.") end

		if _AllBuildings[name] then
			DebugOut("REDEFINING "..tostring(name))
		elseif _G[name] then
			-- TODO: WARN: Variable with this name already exists
		end

		t = _AllBuildings[name] or {}
		setmetatable(t, self) self.__index = self
		_AllBuildings[name] = t
		_G[name] = t
		
		-- TODO: Initialize other building values
		t.name = name
		t.port = port
		t.characters = {}
		
		-- TODO: Keep buildings ordered - ?
		if port then table.insert(port.buildings, t) end
	end
	
	return t
end

function CreateBuilding(name, port, type)
	type = type or Building
	local t = type:Create(name, port)
	
	-- Create a default character for the building
	t.characters[1] = { name.."keep" }
	CreateCharacter(name.."keep")
end

function EmptyBuilding(name, port, type)
	local buildingType = type or Building
	local t = buildingType:Create(name, port)
	
	-- Set up the building to be initially empty
	t.characters[1] = {}
    -- If a specific type was passed, ensure it's set on the object
    if type then
        t.type = type.type
    end
end

------------------------------------------------------------------------------

function Building:IsOwned()
	return Player.buildingsOwned[self.name] or false
end

function Building:MarkOwned()
	Player.buildingsOwned[self.name] = true
end

function Building:IsEnabled()
	return self.enabled or Player.buildingsEnabled[self.name]
end

------------------------------------------------------------------------------

function Building:PortRolloverContents()
	local n = GetString(self.name)
	if n == "#####" then n = self.name end
	return MakeDialog
	{
		BSGWindow
		{
			x=0,y=0, fit=true, color=rolloverColor, frame="controls/rollover",
			TightText { x=0,y=0, label="#"..n, font=rolloverInfoFont, flags=kVAlignTop+kHAlignLeft, }
		}
	}
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Character management

-- Default SetCharacters(table) means SetCharacters(1, table)
function Building:SetCharacters(rank, table)
	if (not table) and type(rank) == "table" then
		table = rank
		rank = 1
	end
	if type(rank) == "number" and type(table) == "table" then
		self.characters[rank] = table
	else
		-- TODO: Report error with character table
	end
end

function Building:AddCharacter(rank, char)
	if type(char) == "table" then char = char.name end
	if type(rank) == "number" and type(char) == "string" then
		local temp = self.characters[rank] or {}
		table.insert(temp, char)
		self.characters[rank] = temp
	else
		-- TODO: Report error with character add
	end
end

-- Select the character list for this building based on player's current rank
function Building:GetCharacterList()
	-- TODO: Start with player's rank and work downwards as necessary
	-- 1. Start with the rank-specific base list
	local chars = self.characters[1]
	for i=1,Player.rank do
		chars = self.characters[i] or chars
	end

    -- 2. Create a working copy so we don't modify the original definition
    local combinedList = {}
    if chars then
        for _, c in ipairs(chars) do table.insert(combinedList, c) end
    end

	-- 3. Add dynamic characters (Quest-driven placements via Player.buildingCharacters)
	-- If special characters are enabled in this building, add them also... to a copy of the character list
	local bt = Player.buildingCharacters[self.name]
	if bt then
		for name,_ in pairs(bt) do
			local c = _AllCharacters[name]
			if c then table.insert(combinedList, c) end
		end
	end
	
	-- Handle the _empty pool
    -- If the list is empty, OR if this building is flagged as a Social Hub
	if (table.getn(combinedList) == 0) or (self.includeEmpty and _empty) then 
        local emptyChars = _empty:GetCharacterList()
        for _, c in ipairs(emptyChars) do
            -- Optional: Check for duplicates to prevent cloning if a char is already there
            local isDuplicate = false
            for _, existing in ipairs(combinedList) do
                if existing == c then isDuplicate = true; break end
            end
            
            if not isDuplicate then
                table.insert(combinedList, c)
            end
        end
	end

    return combinedList
end

function Building:GetResidentCharacterList()
	-- This is a specific version of GetCharacterList that ONLY returns
	-- true residents and temporary placements, without the fallback to _empty.
	-- It is used to prevent misclassifying non-residents during quest generation.
	local chars = self.characters[1]
	for i=1,Player.rank do
		chars = self.characters[i] or chars
	end

	local bt = Player.buildingCharacters[self.name]
	if bt then
		local t = chars
		chars = {}
		for i,char in ipairs(t) do table.insert(chars,char) end
		for name,_ in pairs(bt) do
			local c = _AllCharacters[name]
			if c then table.insert(chars, c) end
		end
	end
	
	return chars
end

-- Look for a character with an action at random from this building
function Building:RandomActionCharacter()
	local charList = self:GetCharacterList()
	local possible = {}
	for _,c in ipairs(charList) do
		if c.actions and (table.getn(c.actions) > 0) then table.insert(possible, c) end
	end
	local n = table.getn(possible)
	if n > 1 then n = RandRange(1,n) end
	if n > 0 then return possible[n]
	else return nil
	end
end

-- Look for ANY character from this building
function Building:RandomCharacter()
	local charList = self:GetCharacterList()
	local n = table.getn(charList)
	if n > 1 then n = RandRange(1,n) end
	if n > 0 then return charList[n]
	else return nil
	end
end

------------------------------------------------------------------------------
-- Quest Management

function Building:FindQuestsEnding()
	local quests = nil
	
	-- Gather all active quests that end with characters in the Primary Characters list
	for _,char in ipairs(_PrimaryCharacters) do
		if char.questEnds then
			for _,quest in ipairs(char.questEnds) do
				if quest:IsActive() and quest:IsNotWaiting() then
					quests = quests or {}
					table.insert(quests, { quest=quest, char=char })
				end
			end
		end
	end
	
	-- If no Primary character quests ending,
	-- gather all active quests that end with characters in this building
	if not quests then
		local charList = self:GetCharacterList()
		for _,char in ipairs(charList) do
--[[
			if char.questEnds then
				for _,quest in ipairs(char.questEnds) do
					if quest:IsActive() and quest:IsNotWaiting() then
						quests = quests or {}
						table.insert(quests, { quest=quest, char=char })
					end
				end
			end
]]--
			for name,_ in pairs(Player.questsActive) do
				local quest = _AllQuests[name]
				if quest:IsActive() and quest:IsNotWaiting() and quest:CanEnd(char) then
					quests = quests or {}
					table.insert(quests, { quest=quest, char=char })
				end
			end
		end
	end
	
	-- TODO: Sort quests by start time?

	return quests
end

function Building:FindQuestsStarting(maxPriority)
	local quests = nil
	
	-- Gather all eligible quests that start with characters in the Primary Characters list
	for _,char in ipairs(_PrimaryCharacters) do
		if char.questStarts then
			for _,quest in ipairs(char.questStarts) do
				if quest:IsEligible() then
					quests = quests or {}
					table.insert(quests, { quest=quest, char=char })
				end
			end
		end
	end

	-- If no Primary character quests eligible,
	-- gather all eligible quests that start with characters in this building
	if not quests then
		local charList = self:GetCharacterList()
		for _,char in ipairs(charList) do
			if char.questStarts then
				for _,quest in ipairs(char.questStarts) do
					if quest:IsEligible() then
						quests = quests or {}
						table.insert(quests, { quest=quest, char=char })
					end
				end
			end
		end
	end
	
	-- Sort quests by priority and keep only the highest-priority category
	if quests and (table.getn(quests) > 0) then
		table.sort(quests, function(a,b) return a.quest.priority < b.quest.priority end)
		
		-- Do a strict prioritization of the available quests and choose at random from among the most
		-- important ones available
		maxPriority = maxPriority or kDefaultPriority
		if maxPriority > quests[1].quest.priority then maxPriority = quests[1].quest.priority end
		for i,qt in ipairs(quests) do
			local q = qt.quest
			if q.priority > maxPriority then
				-- Cut the quest list here
				table.setn(quests, i - 1)
				break
			end
		end
	end
	
	if quests and (table.getn(quests) > 0) then return quests
	else return nil
	end
end

------------------------------------------------------------------------------
-- Out of Money check on building entry

function CheckOutOfMoney()
--DebugOut("CheckOutOfMoney")

--	local targetMoney = 500		-- how much money triggers the bail out?
	local targetMoney = BaseTravelPrice() * 2
	local nomoney = false

	-- It becomes possible for player to lose money once the Zurich market is un-blocked during the tutorial
	if Player.money < targetMoney and not gTravelActive and not Player.buildingsBlocked["zur_market"] then
		nomoney = true
		
--DebugOut("--> POSSIBLE LOW MONEY")
		
		-- Is there a shop in town? If the player has inventory, they have a chance to sell something
		local shop = _AllPorts[Player.portName].hasShop
		if shop then
			local value = 0
			for code,count in pairs(Player.products) do
				local prod = _AllProducts[code]
				local category = prod:GetMachinery()
				if shop.buys[category.name] then value = value + count * Player.itemPrices[code] end
			end
--DebugOut("--> POSSIBLE TO SELL PRODUCT FOR "..Dollars(value))
			if value >= targetMoney then
				-- Player has plenty of inventory to sell at the shop
				nomoney = false
			else
				-- See if a factory could produce something the player can sell
--DebugOut("--> ATTEMPT TO RUN FACTORIES")
				TickSim()
				value = 0
				for code,count in pairs(Player.products) do
					local prod = _AllProducts[code]
					local category = prod:GetMachinery()
					if shop.buys[category.name] then value = value + count * Player.itemPrices[code] end
				end
				if value >= targetMoney then nomoney = false end
--DebugOut("--> NOW POSSIBLE TO SELL PRODUCT FOR "..Dollars(value))
			end

			if value < targetMoney then
				-- TODO: Offer to liquidate ingredients ?
			end
		end
		
		if nomoney then
--DebugOut("--> OUT OF OPTIONS")

			-- Offer the nomoney quests if available
			local q = _AllQuests["nomoney"]
			if q:IsComplete() or q:IsActive() then
				q = _AllQuests["nomoney2"]
				if q:IsComplete() or q:IsActive() then
					q = _AllQuests["nomoney3"]
					if q:IsComplete() or q:IsActive() then
						q = _AllQuests["nomoney4"]
						if q:IsComplete() or q:IsActive() then
							q = nil
						end
					end
				end
			end
			if q then
--DebugOut("--> OFFER NOMONEY:"..tostring(q))
				nomoney = false
				q:Offer(las_casinokeep,self)
			else
				-- Offer the "final" nomoney quest - get free cash
				q = _AllQuests["nomoney5"]
				if q then
--DebugOut("--> OFFER FINAL NOMONEY:"..tostring(q))
					q:Offer(las_casinokeep,self)
				end
			end
		end
	end
	
	return nomoney
end

------------------------------------------------------------------------------
-- Click Management

function Building:Show()
	return function()
		EnableWindow("background", true)
		EnableWindow("contents", true)
	end
end

function Building:TransitionIn(x,y)
	local x = x or 150
	local y = y or 50
	local centery = ((self.y or 0) + y) / 2
	return function()
		EnableWindow("background", true)
		EnableWindow("contents", false)
		Transition { "path", window="background", time = 150, path = { {self.x,self.y},{self.x,self.y},{x,y},{x,y} } }
		Transition { "zoomin", window="background", time = 100,
			onend=function()
				EnableWindow("contents", true)
				Transition { "fadein", window="contents", time=50 }
			end }
	end
end

function Building:HandleQuestExpiration()
	local somethingHappened = false
	-- Just pick the first expired quest...
	local expired = nil
	for name,_ in pairs(Player.questsActive) do
		local quest = _AllQuests[name]
		if quest:IsExpired() then
			expired = quest
			break
		end
	end

	if expired then
		-- TODO: Use the quest ender to deliver the expiration message? Only if the ender is in this building?
--		local char = expired.ender[1]
		local char = self:RandomCharacter()
		
		if char then
			expired:Expire(char, self)
			somethingHappened = true
		end
	end
	
	return somethingHappened
end

function Building:HandleQuestCompletion(allowIncompletes)
	if allowIncompletes == nil then allowIncompletes = true end
	local char = nil
	local quest = nil
	local completed = false
	local incompleted = false
	
	-- Gather complete and incomplete quests ending in this building
	local complete = {}
	local incomplete = {}
	local quests = self:FindQuestsEnding()
	if quests and table.getn(quests) > 0 then
		for _,data in ipairs(quests) do
			quest = data.quest
			if quest:AreGoalsMet() and not quest:IsComplete() then table.insert(complete, data)
			elseif allowIncompletes and (not quest:IsComplete()) then table.insert(incomplete, data)
			end
		end
	end
	
	-- Show either completed quests or incomplete quests but not both, most recently accepted first
	-- so that meta-quests will be completed AFTER sub-quests that were accepted within the time of the meta-quest
	if table.getn(complete) > 0 then
		table.sort(complete, function(q1,q2) return Player.questsActive[q1.quest.name] < Player.questsActive[q2.quest.name] end)
		for _,data in ipairs(complete) do
			char = data.char
			quest = data.quest
			completed = quest:Complete(char, self)
		end
	elseif table.getn(incomplete) > 0 then
		table.sort(incomplete, function(q1,q2) return Player.questsActive[q1.quest.name] < Player.questsActive[q2.quest.name] end)
		for _,data in ipairs(incomplete) do
			char = data.char
			quest = data.quest
			incompleted = quest:Incomplete(char, self)
		end
	end
	
	return char,completed,incompleted
end

function Building:HandleQuestCompletionAndRealOffers()
	-- This function handles HIGH-PRIORITY quest interactions only:
	-- 1. Completing a finished quest.
	-- 2. Offering a new "real" quest.

	-- Priority 1: Check for completed quests.
	local char, questCompleted, _ = self:HandleQuestCompletion(false)
	if questCompleted then
		return true, char -- A quest was completed. Stop here.
	end

	-- Priority 2: Gather all available starting quests.
	local allQuests = self:FindQuestsStarting(kDefaultPriority + 1)
	if allQuests and table.getn(allQuests) > 0 then
		-- Separate them into "real" quests and "tease" quests.
		local realQuests = {}
		for _, data in ipairs(allQuests) do
			if data.quest:IsReal() then
				table.insert(realQuests, data)
			end
		end
		
		-- Offer a REAL quest if one exists.
		if table.getn(realQuests) > 0 then
			local n = 1
			while realQuests[n+1] and realQuests[n+1].quest.priority == realQuests[1].quest.priority do
				n = n + 1
			end
			if n > 1 then n = RandRange(1,n) end
			
			local quest = realQuests[n].quest
			char = realQuests[n].char
			
			quest:Offer(char, self)
			return true, char -- A real quest was offered. Stop here.
		end
	end

	return false, nil -- No high-priority quest action was taken.
end

function Building:HandleIncompleteAndTeaseOffers()
	-- This function handles LOW-PRIORITY quest interactions only:
	-- 1. Showing "incomplete" dialogue for an active quest.
	-- 2. Offering a "tease" (flavor dialogue) quest.
	-- It returns the character who spoke, but does NOT return true for somethingHappened,
	-- allowing the OnClick logic to proceed to EnterBuilding.

	local char = nil

	-- Priority 1: Check for INCOMPLETE quest dialogue.
	local _, _, questIncompleted = self:HandleQuestCompletion(true)
	if questIncompleted then
		-- An incomplete message was shown. We get the character who spoke.
		char = self:RandomCharacter() 
		return char -- Return the character but not 'true'
	end

	-- Priority 2: If still nothing has happened, offer a TEASE quest.
	local allQuests = self:FindQuestsStarting(kDefaultPriority + 1)
	if allQuests and table.getn(allQuests) > 0 then
		local teaseQuests = {}
		for _, data in ipairs(allQuests) do
			if not data.quest:IsReal() then
				table.insert(teaseQuests, data)
			end
		end

		if table.getn(teaseQuests) > 0 then
			local n = table.getn(teaseQuests)
			if n > 1 then n = RandRange(1, n) end
			
			local quest = teaseQuests[n].quest
			char = teaseQuests[n].char
			
			quest:Offer(char, self)
			return char -- A tease quest was offered. Return the character but not 'true'.
		end
	end
	
	return nil -- No low-priority quest action was taken.
end

function OfferDeliveryQuestInPerson(questData, character, building)
	questData.forceTelegram = false
    local quest = CreateDeliveryQuest(questData, questData.isResident, questData.sourcePool)
    
    local offerKey
    if building.name == questData.startbuilding then
        offerKey = "delivery_sender_offer"
    else
        offerKey = "delivery_recipient_offer"
    end
    
    Player.questOfferText[quest.name] = GetDynamicDeliveryString(offerKey, quest)
    
    quest:Offer(character, building)

    -- Add response dialogue based on the player's choice.
    local responseKey = nil
    if quest:IsActive() then
        -- Player accepted the quest.
        if building.name == questData.startbuilding then
            responseKey = "delivery_sender_accept" -- This key doesn't exist yet, but we can add it.
        else
            responseKey = "delivery_recipient_accept"
        end
    elseif quest:IsDeferred() then
        -- Player deferred the quest.
        if building.name == questData.startbuilding then
            responseKey = "delivery_sender_defer" -- This key doesn't exist yet, but we can add it.
        else
            responseKey = "delivery_recipient_defer"
        end
    elseif quest:IsComplete() then -- IsComplete is true on reject
        -- Player rejected the quest.
        if building.name == questData.startbuilding then
            responseKey = "delivery_sender_reject" -- This key doesn't exist yet, but we can add it.
        else
            responseKey = "delivery_recipient_reject"
        end
    end

    if responseKey then
        local responseText = GetDynamicDeliveryString(responseKey, quest)
        DisplayDialog { "ui/ui_character_generic.lua", char=character, text="#"..responseText }
    end

    -- Only remove the quest from the queue if a final decision (Accept/Reject) is made.
    if quest:IsActive() or quest:IsComplete() then
        for i, order in ipairs(Player.pendingSpecialOrders) do
            if order.name == questData.name then
                table.remove(Player.pendingSpecialOrders, i)
                break
            end
        end

        if not quest:IsActive() and not questData.isResident then
            DebugOut("QUEST", "Player rejected in-person order. Returning '" .. questData.ender .. "' to source pool.")
            if Player.buildingCharacters[questData.endbuilding] then
                Player.buildingCharacters[questData.endbuilding][questData.ender] = nil
            end
            Player.buildingCharacters[questData.sourcePool] = Player.buildingCharacters[questData.sourcePool] or {}
            Player.buildingCharacters[questData.sourcePool][questData.ender] = true
            
            Player.orderBannedChars[questData.ender] = nil
            Player.orderBannedBuildings[questData.endbuilding] = nil
        end
    else
        DebugOut("QUEST", "Player deferred in-person order. It remains in the pending queue.")
    end
end

function Building:HandleInPersonSpecialOrders()
    if not Player.pendingSpecialOrders or table.getn(Player.pendingSpecialOrders) == 0 then
        return false
    end

    for i, orderData in ipairs(Player.pendingSpecialOrders) do
        if Player.time < orderData.earlyOfferCutoff then
            if self.name == orderData.startbuilding then
                local shopkeeper = self:GetCharacterList()[1]
                
                -- Create a temporary quest-like object to pass to the string function.
                local tempQuest = {
                    product = orderData.product,
                    ender = _AllCharacters[orderData.ender],
                    GetEnder = function(self) return self.ender end,
                    startbuilding = orderData.startbuilding,
                    endbuilding = orderData.endbuilding
                }
                local promptText = GetDynamicDeliveryString("delivery_sender_prompt", tempQuest)
                
                local choice = DisplayDialog { "ui/ui_character_yesno.lua", char=shopkeeper, text="#"..promptText }
                if choice == "yes" then
                    OfferDeliveryQuestInPerson(orderData, shopkeeper, self)
                end
                return true

            elseif self.name == orderData.endbuilding then
                local ender = _AllCharacters[orderData.ender]
                OfferDeliveryQuestInPerson(orderData, ender, self)
                return true
            end
        end
    end

    return false
end

function DeliverRandomEligibleHint(character, building)
	-- This function checks if a hint should be delivered instead of a normal interaction.
	
	-- Define building types that CANNOT give hints.
	local disallowed_types = {
		market = true, farm = true, shop = true, factory = true, kitchen = true, casino = true
	}
	if disallowed_types[building.type] then return false end

	-- Get the character the player is interacting with.
	local char = character or building:RandomCharacter()
	if not char then return false end

    -- Prevent evil characters from giving hints.
    if Tips.evilCharacters[char.name] then
        DebugOut("HINT", "Blocked evil character " .. char.name .. " from giving a quest hint.")
        return false
    end

	-- Build a list of all eligible hints
	local eligible_hints = {}
	for questName, _ in pairs(Player.questsActive) do
		local quest = _AllQuests[questName]
        -- NEW: Add a check to completely ignore delivery quests for hint purposes.
		if quest and (not quest.delivery) and quest:IsHintEligible() then
			table.insert(eligible_hints, quest)
		end
	end

	-- Filter the list to find hints that are valid for the CURRENT speaker.
	local filtered_hints = {}
	for _, quest in ipairs(eligible_hints) do
        -- Use our streamlined hint function, passing the CURRENT character.
		local hintText = quest:GetDynamicHintString(char)
		if hintText then
			-- If the function returned text, it means this character is allowed to give this hint.
			table.insert(filtered_hints, { quest = quest, text = hintText })
		end
	end

	-- If there are eligible hints in the FILTERED list, pick one at random and deliver it.
	if table.getn(filtered_hints) > 0 then
		local hint_data = filtered_hints[RandRange(1, table.getn(filtered_hints))]
		
        DebugOut("QUEST", "Delivering hint for quest '" .. hint_data.quest.name .. "' via character '" .. char.name .. "'.")

		-- Display the hint using the generic character dialog.
		DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..hint_data.text, building=building }
		
		-- Set the cooldown for this specific hint
		Player.questHintCooldowns[hint_data.quest.name] = Player.time + 8
		
		return true -- Signify that an action has occurred.
	end
	
	return false -- No eligible hints were found.
end

function Building:Open(char, action)
end

function Building:OnClick()
    DebugOut("BUILDING", "Player clicked on building: " .. self.name)

	-- Check for and auto-save game
	if Player then Player:AutoSave() end

	-- Set up environmental audio
	if self.cadikey then SoundEvent(self.cadikey) end
	
	local somethingHappened, char = false, nil
	
	-- Priority 1: High-priority quests (completion, real offers).
	somethingHappened, char = self:HandleQuestCompletionAndRealOffers()
	
	-- Priority 2: In-person special order offers.
    if not somethingHappened then
        somethingHappened = self:HandleInPersonSpecialOrders()
    end
	
	-- Priority 3: Low money check (loan shark).
	if not somethingHappened then
		if CheckOutOfMoney() then
			somethingHappened = true
		end
	end
	
	-- Priority 4: Quest Hints.
	if not somethingHappened then
		somethingHappened = DeliverRandomEligibleHint(char, self)
	end
		
	-- Priority 5: Pending Market Tip Announcements.
	if not somethingHappened and Player.pendingAnnouncements and table.getn(Player.pendingAnnouncements) > 0 then
		char = char or self:RandomCharacter()
		if char then
			for i, tip_to_announce in ipairs(Player.pendingAnnouncements) do
				if Tips.CanCharacterAnnounceTip(char, self, tip_to_announce) then
					gPendingTip = nil -- Clear any old global just in case
					
					local text = Tips.GetDynamicTipString(tip_to_announce, char)
					DebugOut("TIP", "Announcing tip '" .. tip_to_announce.key .. "' via character " .. char.name)
					DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..text }
					somethingHappened = true
					
					table.remove(Player.pendingAnnouncements, i)
					break
				end
			end
		end
	end

	-- Priority 6: Low-priority quests (incomplete dialogue, tease offers).
	if not somethingHappened then
		char = self:HandleIncompleteAndTeaseOffers()
		-- If a character was returned, it means dialogue was shown. We update the 'char' variable
	end

	-- Priority 7: Building-specific action (e.g., open shop/market UI).
	if (not Player.buildingsBlocked[self.name]) and (self.EnterBuilding) then
		-- This will now run even if a tease/incomplete dialogue was just shown.
		somethingHappened = self:EnterBuilding(char, somethingHappened) or somethingHappened
	end

	-- Priority 8: Final fallback to generic character action.
	if not somethingHappened then
		-- If a character has already been determined by a low-priority event (like a tease),
		-- we should NOT proceed to give them another generic line.
		-- We only want to find a character and make them speak if 'char' is currently nil.
		if not char then
			char = self:RandomActionCharacter()
			if not char then char = self:RandomCharacter() end
			if char and char.actions then
				char:RandomAction(self)
				somethingHappened = true
			elseif char then
				DisplayDialog { "ui/ui_character_generic.lua", char=char, building=self }
			end
		end
	end
	
	-- On exit, check quest completion again (for quests that might auto-complete after an action).
	self:HandleQuestCompletion(false)

	-- Revert environmental audio
	if self.cadikey then SoundEvent(self.port.cadikey) end
end

------------------------------------------------------------------------------
-- Haggling
-- Although these really only apply to shops and markets, I'm putting them
-- in Building because I'm lazy.

function Building:ComputeHaggle(char, good, soft)
	-- Get the base Reasonableness based on prices
	local R = self:ComputeReasonableness()
	
	-- Calculate the multiplier for R based on a variety of factors that affect haggling
	-- The "haggle factor" for this character is a 1.0-based value indicating a character's
	-- willingness, in general, to haggle. A lower haggleFactor means lower F, which means
	-- lower R, which means player is less likely to haggle successfully with this person
	local F = char.haggleFactor
	
	-- If prices are fairly good (R > 50) player needs to be reasonable too...
	-- Take a 10% bump in either direction -- better if player is reasonable when prices are reasonable
	if (R >= 50 and good) or (R <= 50 and not good) then F = F + 0.1
	else F = F - 0.1
	end
	
	-- The player also benefits by tailoring their response to a particular character's personality.
	-- A player's responses may be either "soft" or "hard" and gives a 10% bump if they match
	if (soft and char.prefersSoft) or (not soft and not char.prefersSoft) then F = F + 0.1
	else F = F - 0.1
	end
	
	-- Finally, the character's willingness to haggle is affected by their mood. When they're
	-- angry, they're less willing to haggle
--	if char:IsAngry() then F = F - 0.1
--	end
	
	-- Adjust R according to all of these factors... at this point, "Low R" means "Less Likely to Haggle"
--DebugOut("F:"..F)
	R = R * F
	
	-- Adjust haggle chance and risk
    local success_threshold = 20 -- Base value for a "good" result
    local failure_threshold = 30 -- Base value for a "bad" result

    if Player.difficulty == 2 then -- Medium
        -- Success is slightly harder, failure is slightly more likely.
        success_threshold = 25
        failure_threshold = 25
    elseif Player.difficulty == 3 then -- Hard
        -- Success is much harder, failure is much more likely.
        success_threshold = 30
        failure_threshold = 20
    end
	
	-- Now, decide whether this is going to be a "good" (successful) haggle, "bad", or "neutral" haggle
	-- On a scale of 1..100, the lower value of R, the better the prices...
	-- If we roll lower than R, we can get better prices -- so as prices get
	-- better, our chances of rolling even lower are slim
	local H = RandRange(1,100)
--DebugOut("H:"..H)
    DebugOut("HAGGLE", "Haggle roll: " .. H .. " vs. target " .. string.format("%.2f", R))

	-- Roll is 20 pts under, player wins
	-- 30 pts or more over, player loses
	-- SO... if actual price is half way between low and high, R=50
	--  R=100: 80% drop, 20% stay the same
	--  R=50: 30% drop, 50% stay the same, 20% go up
	--  R=30: 10% dop, 50% stay the same, 40% go up
	--  R=0: 0% drop, 30% stay the same, 70% go up
	
	local result = "neutral"
	if H < R - success_threshold then result = "good"
	elseif H > R + failure_threshold then result = "bad"
	end
	return result
end