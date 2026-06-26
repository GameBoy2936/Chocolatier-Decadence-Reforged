--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Building Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Building" represents any interactable, clickable entity within a Port.
-- This class handles character population, quest interactions, economy checks 
-- (like bankruptcy), and the master priority loop for player clicks.

Building =
{
	-- ==========================================
	-- Core Identity & State
	-- ==========================================
	name = nil,				-- Internal key name of the building (e.g., "zur_market")
	port = nil,				-- The Port object where this building resides
	enabled = true,			-- TRUE if the building is interactable by default
	
	-- ==========================================
	-- Visuals & Geography
	-- ==========================================
	x = nil,				-- X-coordinate mapping within the port UI view
	y = nil,				-- Y-coordinate mapping within the port UI view
	type = "generic",		-- Building classification ("generic", "market", "shop", "factory", etc.)
}

-- Metamethod for clean debug printing of Building objects
Building.__tostring = function(t) return "{Building:" .. tostring(t.name) .. "}" end

-- Global registry of all initialized buildings
_AllBuildings = {}

-- ==========================================
-- Subclasses & Specific Building Types
-- ==========================================
-- These inherit from the base Building class but apply specific audio 
-- keys or UI overrides depending on their flavor.

Saloon = { cadikey = "saloons" }
setmetatable(Saloon, Building)
Saloon.__index = Saloon
Saloon.__tostring = function(t) return "{Saloon:" .. tostring(t.name) .. "}" end

TrainStation = { cadikey = "train_station" }
setmetatable(TrainStation, Building)
TrainStation.__index = TrainStation
TrainStation.__tostring = function(t) return "{TrainStation:" .. tostring(t.name) .. "}" end

Bank = { cadikey = "bank" }
setmetatable(Bank, Building)
Bank.__index = Bank
Bank.__tostring = function(t) return "{Bank:" .. tostring(t.name) .. "}" end

Wilderness = { cadikey = "plantation" }
setmetatable(Wilderness, Building)
Wilderness.__index = Wilderness
Wilderness.__tostring = function(t) return "{Wilderness:" .. tostring(t.name) .. "}" end

Casino = { cadikey = "casino_ambience", type = "casino" }
setmetatable(Casino, Building)
Casino.__index = Casino
Casino.__tostring = function(t) return "{Casino:" .. tostring(t.name) .. "}" end

-- Casinos have a specific override to launch the slot machine minigame UI
function Casino:EnterBuilding(char, somethingHappened)
	char = self:RandomCharacter()
	DebugOut("BUILDING", string.format("Player entering Casino: %s", self.name))
	DisplayDialog { "ui/ui_slotselect.lua", char = char, building = self }	
	return true
end

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

-- Factory method: Creates or redefines a building object
function Building:Create(name, port)
	local t = nil
	if not name then
		DebugOut("ERROR", "Attempted to create a Building with no name.")
	else
		if _AllBuildings[name] then
			DebugOut("LOAD", string.format("Redefining existing building during hot-reload: %s", name))
		elseif _G[name] then
			DebugOut("WARNING", string.format("Global variable conflict: '%s' already exists.", name))
		else
			-- Log the successful initial creation, and tie it to its geography
			local portName = port and port.name or "Unassigned"
			DebugOut("LOAD", string.format("Created building definition: %s (Port: %s)", name, portName))
		end

		t = _AllBuildings[name] or {}
		
		-- Bind the Building class metatable
		setmetatable(t, self) 
		self.__index = self
		
		-- Register globally
		_AllBuildings[name] = t
		_G[name] = t
		
		-- Initialize core tables
		t.name = name
		t.port = port
		t.characters = {}
		
		-- Link building to its parent port's building list
		if port then table.insert(port.buildings, t) end
	end
	
	return t
end

-- Global wrapper to instantiate a standard building with a default resident
function CreateBuilding(name, port, type)
	type = type or Building
	local t = type:Create(name, port)
	
	-- Automatically generate a default "keeper" character for this building
	t.characters[1] = { name .. "keep" }
	CreateCharacter(name .. "keep")
end

-- Global wrapper to instantiate a building that has no permanent residents
function EmptyBuilding(name, port, type)
	local buildingType = type or Building
	local t = buildingType:Create(name, port)
	
	-- Setup character table as explicitly empty
	t.characters[1] = {}
	
	-- Carry over type definition if a specific class was passed
	if type then
		t.type = type.type
	end
end

------------------------------------------------------------------------------
-- Ownership & State Accessors
------------------------------------------------------------------------------

function Building:IsOwned()
	return Player.buildingsOwned[self.name] or false
end

function Building:MarkOwned()
	DebugOut("ECONOMY", string.format("Player acquired ownership of building: %s", self.name))
	Player.buildingsOwned[self.name] = true
end

function Building:IsEnabled()
	return self.enabled or Player.buildingsEnabled[self.name]
end

------------------------------------------------------------------------------
-- UI: Rollover Management
------------------------------------------------------------------------------

-- Generates the tooltip dialog when hovering over a building in the port view
function Building:PortRolloverContents()
	local n = GetString(self.name)
	if n == "#####" then n = self.name end
	
	return MakeDialog
	{
		BSGWindow
		{
			x = 0, y = 0, fit = true, color = rolloverColor, frame = "controls/rollover",
			TightText { x = 0, y = 0, label = "#" .. n, font = rolloverInfoFont, flags = kVAlignTop + kHAlignLeft }
		}
	}
end

------------------------------------------------------------------------------
-- Character Population Management
------------------------------------------------------------------------------

-- Assigns a pool of characters to this building.
-- If rank is omitted, defaults to Rank 1 (Base layout)
function Building:SetCharacters(rank, charTable)
	if (not charTable) and type(rank) == "table" then
		charTable = rank
		rank = 1
	end
	
	if type(rank) == "number" and type(charTable) == "table" then
		self.characters[rank] = charTable
	else
		DebugOut("ERROR", string.format("Invalid parameters passed to SetCharacters for building: %s", self.name))
	end
end

-- Appends a single character to a specific rank tier in this building
function Building:AddCharacter(rank, char)
	if type(char) == "table" then char = char.name end
	
	if type(rank) == "number" and type(char) == "string" then
		local temp = self.characters[rank] or {}
		table.insert(temp, char)
		self.characters[rank] = temp
	else
		DebugOut("ERROR", string.format("Invalid parameters passed to AddCharacter for building: %s", self.name))
	end
end

-- Constructs the active character list dynamically based on player rank, quests, and fallbacks.
function Building:GetCharacterList()
	-- 1. Start with the Rank 1 base list, overriding upwards to match the Player's current rank
	local chars = self.characters[1]
	for i = 1, Player.rank do
		chars = self.characters[i] or chars
	end

	-- 2. Create a working copy so we don't accidentally mutate the static definition arrays
	local combinedList = {}
	if chars then
		for _, c in ipairs(chars) do table.insert(combinedList, c) end
	end

	-- 3. Inject Dynamic Quest Characters (Temporary placements assigned by the engine)
	local bt = Player.buildingCharacters[self.name]
	if bt then
		for name, _ in pairs(bt) do
			local c = _AllCharacters[name]
			if c then table.insert(combinedList, c) end
		end
	end
	
	-- 4. Fill Empty Spaces (The "_empty" pool handling)
	-- If the building is completely empty, or if it explicitly includes wanderers
	if (table.getn(combinedList) == 0) or (self.includeEmpty and _empty) then 
		local emptyChars = _empty:GetCharacterList()
		for _, c in ipairs(emptyChars) do
			-- Prevent duplicating a character if they are already naturally populated
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

-- Returns ONLY the true residents and temporary quest placements.
-- Used to prevent the game from accidentally generating delivery quests 
-- for random empty-pool wanderers that will vanish.
function Building:GetResidentCharacterList()
	local chars = self.characters[1]
	for i = 1, Player.rank do
		chars = self.characters[i] or chars
	end

	local bt = Player.buildingCharacters[self.name]
	if bt then
		local t = chars
		chars = {}
		for i, char in ipairs(t) do table.insert(chars, char) end
		for name, _ in pairs(bt) do
			local c = _AllCharacters[name]
			if c then table.insert(chars, c) end
		end
	end
	
	return chars
end

-- Returns a random character from this building who currently has an interaction defined
function Building:RandomActionCharacter()
	local charList = self:GetCharacterList()
	local possible = {}
	
	for _, c in ipairs(charList) do
		if c.actions and (table.getn(c.actions) > 0) then table.insert(possible, c) end
	end
	
	local n = table.getn(possible)
	if n > 1 then n = RandRange(1, n) end
	if n > 0 then return possible[n] else return nil end
end

-- Returns ANY random character currently occupying this building
function Building:RandomCharacter()
	local charList = self:GetCharacterList()
	local n = table.getn(charList)
	
	if n > 1 then n = RandRange(1, n) end
	if n > 0 then return charList[n] else return nil end
end

------------------------------------------------------------------------------
-- Quest Scanning & Querying
------------------------------------------------------------------------------

-- Scans the building to see if anyone inside is the target of an active, ready-to-finish quest
function Building:FindQuestsEnding()
	local quests = nil
	
	-- 1. Check Primary Characters first
	for _, char in ipairs(_PrimaryCharacters) do
		if char.questEnds then
			for _, quest in ipairs(char.questEnds) do
				if quest:IsActive() and quest:IsNotWaiting() then
					quests = quests or {}
					table.insert(quests, { quest = quest, char = char })
				end
			end
		end
	end
	
	-- 2. If no Primary characters have ending quests, check the local building population
	if not quests then
		local charList = self:GetCharacterList()
		for _, char in ipairs(charList) do
			for name, _ in pairs(Player.questsActive) do
				local quest = _AllQuests[name]
				if quest:IsActive() and quest:IsNotWaiting() and quest:CanEnd(char) then
					quests = quests or {}
					table.insert(quests, { quest = quest, char = char })
				end
			end
		end
	end

	return quests
end

-- Scans the building to see if anyone inside is ready to hand out a new quest
function Building:FindQuestsStarting(maxPriority)
	local quests = nil
	
	-- 1. Check Primary Characters first
	for _, char in ipairs(_PrimaryCharacters) do
		if char.questStarts then
			for _, quest in ipairs(char.questStarts) do
				if quest:IsEligible() then
					quests = quests or {}
					table.insert(quests, { quest = quest, char = char })
				end
			end
		end
	end

	-- 2. If no primary character quests, check the local building population
	if not quests then
		local charList = self:GetCharacterList()
		for _, char in ipairs(charList) do
			if char.questStarts then
				for _, quest in ipairs(char.questStarts) do
					if quest:IsEligible() then
						quests = quests or {}
						table.insert(quests, { quest = quest, char = char })
					end
				end
			end
		end
	end
	
	-- 3. Priority Filtering
	-- Sorts all discovered quests and strips out everything except the highest available priority tier.
	if quests and (table.getn(quests) > 0) then
		table.sort(quests, function(a, b) return a.quest.priority < b.quest.priority end)
		
		maxPriority = maxPriority or kDefaultPriority
		if maxPriority > quests[1].quest.priority then 
			maxPriority = quests[1].quest.priority 
		end
		
		for i, qt in ipairs(quests) do
			local q = qt.quest
			if q.priority > maxPriority then
				-- Truncate the list here, dropping all lower-priority quests
				table.setn(quests, i - 1)
				break
			end
		end
	end
	
	if quests and (table.getn(quests) > 0) then return quests else return nil end
end

------------------------------------------------------------------------------
-- Economy & Bankruptcy Defenses
------------------------------------------------------------------------------

-- Evaluates if the player is stuck in a soft-lock state (no money, no ingredients, no assets)
-- If true, it triggers a sequence to inject emergency funds via bail-out quests.
function CheckOutOfMoney()
	-- Threshold for panic mode is twice the base cost of travel
	local targetMoney = BaseTravelPrice() * 2
	local nomoney = false

	DebugOut("ECONOMY", string.format("Bankruptcy Check: Current Money: %s / Safe Threshold: %s", Dollars(Player.money), Dollars(targetMoney)))

	-- The player can only truly lose if they have unlocked the first free market
	if Player.money < targetMoney and not gTravelActive and not Player.buildingsBlocked["zur_market"] then
		nomoney = true
		
		DebugOut("ECONOMY", "Player cash is critically low. Auditing physical assets...")
		
		-- Step 1: Liquid Asset Check
		-- Calculate the total value of all finished products the player could sell immediately in THIS port.
		local shop = _AllPorts[Player.portName].hasShop
		if shop then
			local potentialValue = 0
			local value = 0
			
			for code, count in pairs(Player.products) do
				local prod = _AllProducts[code]
				local category = prod:GetMachinery()
				
				-- Only count the value if the local shop actually BUYS this item category
				if shop.buys[category.name] then 
					value = value + (count * Player.itemPrices[code]) 
				end
			end
			DebugOut("ECONOMY", string.format("Current sellable inventory value in %s: %s", shop.port.name, Dollars(value)))

			if value >= targetMoney then
				nomoney = false
				DebugOut("ECONOMY", "Bankruptcy averted: Player has enough immediate inventory to sell.")
			else
				-- Step 2: Predictive Production Check
				-- Calculate the total value of products the player COULD manufacture right now 
				-- using ingredients already in their inventory.
				DebugOut("ECONOMY", "Liquid assets insufficient. Calculating potential factory production output...")
				
				for name, info in pairs(Player.factories) do
					if info.current then
						-- Calculate maximum possible production yield based on on-hand ingredients
						local produce = info.production or 0
						for ing_name, need in pairs(info.needs) do
							local have = Player.ingredients[ing_name] or 0
							local possible = Floor(have / need)
							if possible < produce then produce = possible end
						end
						
						-- Calculate the local market value of that potential yield
						if produce > 0 then
							local prod = _AllProducts[info.current]
							local category = prod:GetMachinery()
							
							if shop.buys[category.name] then
								local price = Player.itemPrices[prod.code] or 0
								local val = produce * price
								potentialValue = potentialValue + val
								DebugOut("ECONOMY", string.format("Factory %s can yield %s of %s.", name, Dollars(val), prod:GetName()))
							end
						end
					end
				end

				DebugOut("ECONOMY", string.format("Total potential factory output value: %s", Dollars(potentialValue)))

				-- Combine liquid goods and potential manufactured goods
				if (value + potentialValue) >= targetMoney then 
					nomoney = false 
					DebugOut("ECONOMY", "Bankruptcy averted: Manufacturing potential covers the deficit.")
				else
					DebugOut("ECONOMY", "Total physical assets insufficient. Player is functionally bankrupt.")
				end
			end
		else
			DebugOut("ECONOMY", string.format("No shop exists in %s. Player cannot sell assets locally.", Player.portName))
		end
		
		-- Step 3: Trigger Bailout Protocol
		-- If assets are insufficient, queue an emergency loan quest from the Casino keeper.
		if nomoney then
			DebugOut("ECONOMY", "Triggering bankruptcy bailout protocol.")

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
				DebugOut("ECONOMY", string.format("Offering standard bailout quest: %s", q.name))
				nomoney = false
				q:Offer(las_casinokeep, self)
			else
				-- If the player has exhausted all standard loans, give them the final infinite free-cash quest
				q = _AllQuests["nomoney5"]
				if q then
					DebugOut("ECONOMY", string.format("Offering final infinite bailout quest: %s", q.name))
					q:Offer(las_casinokeep, self)
				end
			end
		end
	end
	
	return nomoney
end

------------------------------------------------------------------------------
-- UI Transitions & Event Dispatchers
------------------------------------------------------------------------------

-- Generic visibility toggle
function Building:Show()
	return function()
		EnableWindow("background", true)
		EnableWindow("contents", true)
	end
end

-- Cinematic zoom effect when clicking a building
function Building:TransitionIn(x, y)
	local target_x = x or 150
	local target_y = y or 50
	return function()
		EnableWindow("background", true)
		EnableWindow("contents", false)
		
		Transition { 
			"path", 
			window = "background", 
			time = 150, 
			path = { {self.x, self.y}, {self.x, self.y}, {target_x, target_y}, {target_x, target_y} } 
		}
		
		Transition { 
			"zoomin", 
			window = "background", 
			time = 100,
			onend = function()
				EnableWindow("contents", true)
				Transition { "fadein", window = "contents", time = 50 }
			end 
		}
	end
end

------------------------------------------------------------------------------
-- Building Event Action Handlers
------------------------------------------------------------------------------

-- Processes quest expirations (failures) when entering a building.
function Building:HandleQuestExpiration()
	local somethingHappened = false
	local expired = nil
	
	for name, _ in pairs(Player.questsActive) do
		local quest = _AllQuests[name]
		if quest:IsExpired() then
			expired = quest
			break
		end
	end

	if expired then
		local char = self:RandomCharacter()
		if char then
			DebugOut("QUEST", string.format("Resolving expired quest '%s' via character '%s'.", expired.name, char.name))
			expired:Expire(char, self)
			somethingHappened = true
		end
	end
	
	return somethingHappened
end

-- Processes standard quest completion dialogs when entering a building.
function Building:HandleQuestCompletion(allowIncompletes)
	if allowIncompletes == nil then allowIncompletes = true end
	
	local char = nil
	local quest = nil
	local completed = false
	local incompleted = false
	
	local complete = {}
	local incomplete = {}
	local quests = self:FindQuestsEnding()
	
	if quests and table.getn(quests) > 0 then
		for _, data in ipairs(quests) do
			quest = data.quest
			if quest:AreGoalsMet() and not quest:IsComplete() then 
				table.insert(complete, data)
			elseif allowIncompletes and (not quest:IsComplete()) then 
				table.insert(incomplete, data)
			end
		end
	end
	
	-- Sort chronologically to resolve meta-quests cleanly
	if table.getn(complete) > 0 then
		table.sort(complete, function(q1, q2) return Player.questsActive[q1.quest.name] < Player.questsActive[q2.quest.name] end)
		for _, data in ipairs(complete) do
			char = data.char
			quest = data.quest
			completed = quest:Complete(char, self)
		end
	elseif table.getn(incomplete) > 0 then
		table.sort(incomplete, function(q1, q2) return Player.questsActive[q1.quest.name] < Player.questsActive[q2.quest.name] end)
		for _, data in ipairs(incomplete) do
			char = data.char
			quest = data.quest
			incompleted = quest:Incomplete(char, self)
		end
	end
	
	return char, completed, incompleted
end

-- Handles High-Priority Quest Flow (Ending goals, or offering new core missions).
function Building:HandleQuestCompletionAndRealOffers()
	-- Priority 1: Check for ready-to-finish quests.
	local char, questCompleted, _ = self:HandleQuestCompletion(false)
	if questCompleted then
		return true, char 
	end

	-- Priority 2: Check for new starting quests.
	local allQuests = self:FindQuestsStarting(kDefaultPriority + 1)
	if allQuests and table.getn(allQuests) > 0 then
		
		local realQuests = {}
		for _, data in ipairs(allQuests) do
			if data.quest:IsReal() then
				table.insert(realQuests, data)
			end
		end
		
		if table.getn(realQuests) > 0 then
			local n = 1
			while realQuests[n+1] and realQuests[n+1].quest.priority == realQuests[1].quest.priority do
				n = n + 1
			end
			if n > 1 then n = RandRange(1, n) end
			
			local quest = realQuests[n].quest
			char = realQuests[n].char
			
			DebugOut("QUEST", string.format("Offering high-priority quest: %s", quest.name))
			quest:Offer(char, self)
			return true, char
		end
	end

	return false, nil
end

-- Handles Low-Priority Quest Flow (Flavor dialogs, "I'm not done yet", and tease quests).
function Building:HandleIncompleteAndTeaseOffers()
	local char = nil

	-- Priority 1: Check for incomplete quest status dialogs
	local _, _, questIncompleted = self:HandleQuestCompletion(true)
	if questIncompleted then
		char = self:RandomCharacter() 
		return char 
	end

	-- Priority 2: Offer a "tease" quest (Flavor narrative)
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
			
			DebugOut("QUEST", string.format("Offering flavor/tease quest: %s", quest.name))
			quest:Offer(char, self)
			return char
		end
	end
	
	return nil 
end

------------------------------------------------------------------------------
-- Dynamic Special Orders & Deliveries
------------------------------------------------------------------------------

-- Wrapper for executing an in-person physical delivery quest interaction
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

	-- Handle localized dialogue reactions based on player choice
	local responseKey = nil
	if quest:IsActive() then
		-- Player Accepted
		if building.name == questData.startbuilding then responseKey = "delivery_sender_accept"
		else responseKey = "delivery_recipient_accept"
		end
	elseif quest:IsDeferred() then
		-- Player Deferred
		if building.name == questData.startbuilding then responseKey = "delivery_sender_defer"
		else responseKey = "delivery_recipient_defer"
		end
	elseif quest:IsComplete() then 
		-- Player Rejected (IsComplete flags true upon rejection to clear it)
		if building.name == questData.startbuilding then responseKey = "delivery_sender_reject"
		else responseKey = "delivery_recipient_reject"
		end
	end

	if responseKey then
		local responseText = GetDynamicDeliveryString(responseKey, quest)
		DisplayDialog { "ui/ui_character_generic.lua", char = character, text = "#" .. responseText }
	end

	-- Clean up queue if action was finalized
	if quest:IsActive() or quest:IsComplete() then
		for i, order in ipairs(Player.pendingSpecialOrders) do
			if order.name == questData.name then
				table.remove(Player.pendingSpecialOrders, i)
				break
			end
		end

		-- If rejected, return the NPC safely to the wandering pool
		if not quest:IsActive() and not questData.isResident then
			DebugOut("QUEST", string.format("Player rejected in-person order. Returning NPC '%s' to source pool.", questData.ender))
			if Player.buildingCharacters[questData.endbuilding] then
				Player.buildingCharacters[questData.endbuilding][questData.ender] = nil
			end
			Player.buildingCharacters[questData.sourcePool] = Player.buildingCharacters[questData.sourcePool] or {}
			Player.buildingCharacters[questData.sourcePool][questData.ender] = true
			
			Player.orderBannedChars[questData.ender] = nil
			Player.orderBannedBuildings[questData.endbuilding] = nil
		end
	else
		DebugOut("QUEST", "Player deferred in-person order. Item remains in pending queue.")
	end
end

-- Checks if a pending special order is attached to the building the player just entered
function Building:HandleInPersonSpecialOrders()
	if not Player.pendingSpecialOrders or table.getn(Player.pendingSpecialOrders) == 0 then
		return false
	end

	for i, orderData in ipairs(Player.pendingSpecialOrders) do
		if Player.time < orderData.earlyOfferCutoff then
			
			-- Sender Case
			if self.name == orderData.startbuilding then
				local shopkeeper = self:GetCharacterList()[1]
				
				-- Shim an object to feed into the dynamic string generator
				local tempQuest = {
					product = orderData.product,
					items = orderData.items, 
					ender = _AllCharacters[orderData.ender],
					GetEnder = function(self) return self.ender end,
					startbuilding = orderData.startbuilding,
					endbuilding = orderData.endbuilding,
					price = orderData.price,
					count = orderData.count,
					expires = orderData.expires,
					delivery = true 
				}
				
				local promptText = GetDynamicDeliveryString("delivery_sender_prompt", tempQuest)
				local buttons = GetDeliveryButtonLabels(tempQuest.lastDynamicKey)
				
				local choice = DisplayDialog { 
					"ui/ui_character_yesno.lua", 
					char = shopkeeper, 
					text = "#" .. promptText,
					yes = buttons.yes,
					no = buttons.no,
					yes_length = "long",
					no_length = "long"
				}
				
				if choice == "yes" then
					OfferDeliveryQuestInPerson(orderData, shopkeeper, self)
				end
				return true

			-- Recipient Case
			elseif self.name == orderData.endbuilding then
				local ender = _AllCharacters[orderData.ender]
				OfferDeliveryQuestInPerson(orderData, ender, self)
				return true
			end
		end
	end

	return false
end

-- Replaces standard greeting dialogue with a useful quest hint if applicable
function DeliverRandomEligibleHint(character, building)
	-- Define building types that CANNOT dispense hints.
	local disallowed_types = {
		market = true, farm = true, shop = true, factory = true, kitchen = true, casino = true
	}
	if disallowed_types[building.type] then return false end

	local char = character or building:RandomCharacter()
	if not char then return false end

	-- Prevent antagonists from assisting the player
	if Tips.evilCharacters[char.name] then
		DebugOut("HINT", string.format("Blocked evil character '%s' from dispensing a hint.", char.name))
		return false
	end

	local eligible_hints = {}
	for questName, _ in pairs(Player.questsActive) do
		local quest = _AllQuests[questName]
		if quest and (not quest.delivery) and quest:IsHintEligible() then
			table.insert(eligible_hints, quest)
		end
	end

	local filtered_hints = {}
	for _, quest in ipairs(eligible_hints) do
		local hintText = quest:GetDynamicHintString(char)
		if hintText then
			table.insert(filtered_hints, { quest = quest, text = hintText })
		end
	end

	if table.getn(filtered_hints) > 0 then
		local hint_data = filtered_hints[RandRange(1, table.getn(filtered_hints))]
		
		DebugOut("HINT", string.format("Delivering hint for quest '%s' via character '%s'.", hint_data.quest.name, char.name))
		DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. hint_data.text, building = building }
		
		Player.questHintCooldowns[hint_data.quest.name] = Player.time + 8
		return true
	end
	
	return false 
end

------------------------------------------------------------------------------
-- Main Entry & Interaction Loop
------------------------------------------------------------------------------

-- Dummy stub required by engine
function Building:Open(char, action)
end

-- Master execution loop triggered whenever a player clicks a building on the map
function Building:OnClick()
	DebugOut("BUILDING", string.format("Player clicked building node: %s", self.name))

	if Player then Player:AutoSave() end
	if self.cadikey then SoundEvent(self.cadikey) end
	
	local somethingHappened, char = false, nil
	
	-- -----------------------------------------------------
	-- Priority 1: High-Priority Quests
	-- -----------------------------------------------------
	somethingHappened, char = self:HandleQuestCompletionAndRealOffers()
	
	-- -----------------------------------------------------
	-- Priority 2: Quest Aftermath Dialogues
	-- -----------------------------------------------------
	if not somethingHappened and Player.pendingAftermaths and Player.pendingAftermaths[self.name] and table.getn(Player.pendingAftermaths[self.name]) > 0 then
		local aftermath = table.remove(Player.pendingAftermaths[self.name], 1)
		char = self:GetCharacterList()[1] or self:RandomCharacter()
		
		if char then
			DebugOut("QUEST", string.format("Triggering queued aftermath dialogue in %s", self.name))
			DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. aftermath.text, building = self, mood = aftermath.mood, ok = aftermath.ok_label, ok_length = aftermath.ok_length }
			somethingHappened = true
		end
	end
	
	-- -----------------------------------------------------
	-- Priority 3: Special Order Offers
	-- -----------------------------------------------------
	if not somethingHappened then
		somethingHappened = self:HandleInPersonSpecialOrders()
	end
	
	-- -----------------------------------------------------
	-- Priority 4: Bankruptcy Defenses (Loan Sharks)
	-- -----------------------------------------------------
	if not somethingHappened then
		if CheckOutOfMoney() then
			somethingHappened = true
		end
	end
	
	-- -----------------------------------------------------
	-- Priority 5: Quest Hints
	-- -----------------------------------------------------
	if not somethingHappened then
		somethingHappened = DeliverRandomEligibleHint(char, self)
	end
		
	-- -----------------------------------------------------
	-- Priority 6: Tutorial Tips / Announcements
	-- -----------------------------------------------------
	if not somethingHappened and Player.pendingAnnouncements and table.getn(Player.pendingAnnouncements) > 0 then
		char = char or self:RandomCharacter()
		if char then
			for i, tip_to_announce in ipairs(Player.pendingAnnouncements) do
				if Tips.CanCharacterAnnounceTip(char, self, tip_to_announce) then
					gPendingTip = nil 
					
					local text = Tips.GetDynamicTipString(tip_to_announce, char)
					DebugOut("TIP", string.format("Announcing tip '%s' via character %s", tip_to_announce.key, char.name))
					DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. text }
					somethingHappened = true
					
					table.remove(Player.pendingAnnouncements, i)
					break
				end
			end
		end
	end

	-- -----------------------------------------------------
	-- Priority 7: Low-Priority Quests
	-- -----------------------------------------------------
	if not somethingHappened then
		-- Returns character object without flagging somethingHappened
		char = self:HandleIncompleteAndTeaseOffers()
	end

	-- -----------------------------------------------------
	-- Priority 8: Specific Building UI Launch
	-- -----------------------------------------------------
	-- Opens market/shop/factory panels if applicable
	if (not Player.buildingsBlocked[self.name]) and (self.EnterBuilding) then
		somethingHappened = self:EnterBuilding(char, somethingHappened) or somethingHappened
	end

	-- -----------------------------------------------------
	-- Priority 9: Generic Character Action / Greeting
	-- -----------------------------------------------------
	if not somethingHappened then
		if not char then
			char = self:RandomActionCharacter()
			if not char then char = self:RandomCharacter() end
			
			if char and char.actions then
				char:RandomAction(self)
				somethingHappened = true
			elseif char then
				DisplayDialog { "ui/ui_character_generic.lua", char = char, building = self }
			end
		end
	end
	
	-- On exit, quietly check if the action just performed fulfilled a goal
	self:HandleQuestCompletion(false)

	-- Revert environmental audio
	if self.cadikey then SoundEvent(self.port.cadikey) end
end

------------------------------------------------------------------------------
-- Haggling Mathematics
------------------------------------------------------------------------------

-- Computes the success rate of a haggling attempt based on current market 
-- conditions, character personality, and player difficulty.
function Building:ComputeHaggle(char, good, soft)
	-- R (Reasonableness) scale (0-100)
	-- 100: Prices are incredibly good for the player.
	-- 50:  Prices are average / fair.
	-- 0:   Prices are terrible for the player.
	local R = self:ComputeReasonableness()
	
	-- F (Factor) multiplier based on character personality
	-- Lower values indicate a character who hates haggling.
	local F = char.haggleFactor
	
	-- Behavioral Bonus 1: Alignment with market reality
	-- Take a 10% bump if the player's response matches the market state.
	-- (e.g. Asking nicely when prices are already fair, or playing hardball when prices are bad)
	if (R >= 50 and good) or (R <= 50 and not good) then 
		F = F + 0.1
	else 
		F = F - 0.1
	end
	
	-- Behavioral Bonus 2: Alignment with character preference
	-- Take a 10% bump if the player matched the NPC's preferred communication style.
	if (soft and char.prefersSoft) or (not soft and not char.prefersSoft) then 
		F = F + 0.1
	else 
		F = F - 0.1
	end
	
	-- Multiply Reasonableness by the final Factor modifier
	-- A lower R mathematically means better prices.
	R = R * F
	
	-- Apply Difficulty constraints to the success/failure margins
	local success_threshold = 20 
	local failure_threshold = 30 

	if Player.difficulty == 2 then 
		-- Medium: Success is harder (-25), failure is more likely (+25)
		success_threshold = 25
		failure_threshold = 25
	elseif Player.difficulty == 3 then 
		-- Hard: Success is severely restricted (-30), failure is very common (+20)
		success_threshold = 30
		failure_threshold = 20
	end
	
	-- H (Haggle Roll)
	-- Roll 1-100 against the computed R threshold.
	local H = RandRange(1, 100)
	DebugOut("HAGGLE", string.format("Haggle roll: %d vs target %.2f (Success gap: -%d, Fail gap: +%d)", H, R, success_threshold, failure_threshold))

	-- Result Determination:
	-- If actual price is perfectly fair (R=50):
	-- Roll < 30: Good (Prices drop further)
	-- Roll > 80: Bad (Prices spike)
	-- Roll 30-80: Neutral (Prices remain unchanged)
	local result = "neutral"
	if H < R - success_threshold then 
		result = "good"
	elseif H > R + failure_threshold then 
		result = "bad"
	end
	
	return result
end