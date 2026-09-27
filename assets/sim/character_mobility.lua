--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Living Character Mobility)
	Copyright (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

-- CharacterMobility separates a character's *identity* from their current world
-- location. Local characters are permanently bound to their home port; global
-- travelers alternate between travel and persistent stays at physical buildings.
-- There is deliberately no building capacity limit: any number of travelers may
-- independently settle in the same eligible building.

CharacterMobility = CharacterMobility or {}
CharacterMobility.version = 6

local kDefaultGlobalTravelWeight = 50
local kDefaultMinStay = 3
local kDefaultMaxStay = 7

-- Building profiles now live beside the actual building definitions in
-- assets/ports/*/*.lua. Keep this table as an empty compatibility fallback for
-- external content that may still populate it at runtime.
CharacterMobilityBuildingData = CharacterMobilityBuildingData or {}

local function CopyLocation(t)
	local out = {}
	if t then
		for k, v in pairs(t) do out[k] = v end
	end
	return out
end

local function AddUniqueCharacter(out, seen, char)
	if char and char.name and not seen[char.name] then
		seen[char.name] = true
		table.insert(out, char)
	end
end

function CharacterMobility:GetDefinition(charName)
	local char = _AllCharacters and _AllCharacters[charName]
	return char and char.mobility or nil
end

function CharacterMobility:IsMobile(charName)
	return self:GetDefinition(charName) ~= nil
end

function CharacterMobility:IsEligibleBuilding(building)
	if not building or not building.name or not building.port then return false end
	if string.sub(building.name, 1, 1) == "_" then return false end
	if building.mobilityVisitors == false then return false end
	if building.mobilityVisitors == true then return true end

	local disallowed = {
		factory = true,
		shop = true,
		market = true,
		farm = true,
		kitchen = true,
		casino = true,
	}
	return not disallowed[building.type or "generic"]
end

function CharacterMobility:IsPortAvailable(portName)
	if not Player or not Player.portsAvailable then return true end
	local state = Player.portsAvailable[portName]
	return state ~= "locked" and state ~= "hidden"
end

function CharacterMobility:GetEligibleBuildings(excludePortName, charName)
	local out = {}
	for _, building in pairs(_AllBuildings or {}) do
		if self:IsEligibleBuilding(building)
			and (not charName or self:IsCharacterEligibleForBuilding(charName, building))
			and (not excludePortName or building.port.name ~= excludePortName)
			and self:IsPortAvailable(building.port.name)
			and not (Player and Player.buildingsBlocked and Player.buildingsBlocked[building.name]) then
			table.insert(out, building)
		end
	end

	-- Stable ordering keeps saves/debugging reproducible before the random pick.
	table.sort(out, function(a, b) return a.name < b.name end)
	return out
end

function CharacterMobility:FindScriptedPhysicalPlacement(charName)
	if not Player or not Player.buildingCharacters then return nil end
	for buildingName, chars in pairs(Player.buildingCharacters) do
		if string.sub(tostring(buildingName), 1, 1) ~= "_"
			and chars and chars[charName]
			and _AllBuildings[buildingName] then
			return buildingName
		end
	end
	return nil
end

function CharacterMobility:GetLocation(charName)
	if not Player or not Player.characterLocations then return nil end
	return Player.characterLocations[charName]
end

function CharacterMobility:SetLocation(charName, location)
	if not Player then return end
	Player.characterLocations = Player.characterLocations or {}
	Player.characterLocations[charName] = CopyLocation(location)
end

function CharacterMobility:SnapshotLocation(charName)
	local location = self:GetLocation(charName)
	if location and location.mode then return CopyLocation(location) end

	local def = self:GetDefinition(charName)
	if not def then return nil end
	if def.class == "local" then
		return { mode = "home", port = def.homePort, since = Player and Player.time or 1 }
	end
	return { mode = "travel", since = Player and Player.time or 1 }
end

function CharacterMobility:GetLegacySourcePool(charName, location)
	location = location or self:GetLocation(charName)
	local def = self:GetDefinition(charName)
	if not def or not location then return nil end
	if location.mode == "travel" then return "_travelers" end
	if def.class == "local" and location.mode == "home" then return "_empty" end
	return location.building
end

function CharacterMobility:IsLocked(charName)
	return Player and Player.characterLocks and Player.characterLocks[charName] ~= nil
end

function CharacterMobility:IsAvailableDuringTravel(charName)
	if not self:IsMobile(charName) then return true end
	if self:IsLocked(charName) then return false end
	local location = self:GetLocation(charName)
	return location and location.mode == "travel" or false
end

function CharacterMobility:RemoveScriptedPlacements(charName, exceptBuilding)
	if not Player or not Player.buildingCharacters then return end
	for buildingName, chars in pairs(Player.buildingCharacters) do
		if chars and buildingName ~= exceptBuilding and chars[charName] then
			chars[charName] = nil
		end
	end
end

function CharacterMobility:IsCharacterEligibleForBuilding(charName, building)
	if not building then return false end
	local required = building.mobilityRequireAny
	if not required or table.getn(required) == 0 then return true end

	local def = self:GetDefinition(charName) or {}
	-- Locals at home do not need a detailed biography profile to move naturally
	-- around their own city. Restrictions mainly stop implausible global visitors.
	if def.class == "local" and def.homePort == building.port.name then return true end

	for _, tag in ipairs(required) do
		if def.affinities and tonumber(def.affinities[tag] or 0) > 0 then return true end
	end
	return false
end

function CharacterMobility:RestoreLocation(charName, sourceLocation)
	local def = self:GetDefinition(charName)
	if not def or not Player then return end
	local location = CopyLocation(sourceLocation)

	if location and location.mode == "building" then
		local b = _AllBuildings[location.building]
		if not b or not self:IsEligibleBuilding(b) or not self:IsPortAvailable(b.port.name)
			or (Player.buildingsBlocked and Player.buildingsBlocked[b.name])
			or (def.class == "local" and b.port.name ~= def.homePort) then
			location = nil
		end
	elseif location and location.mode == "home" then
		if def.class ~= "local" or location.port ~= def.homePort then location = nil end
	elseif location and location.mode == "travel" and def.class == "local" then
		location = nil
	end

	if not location or not location.mode then
		location = self:RollNaturalLocation(charName)
	else
		location.since = location.since or Player.time or 1
		-- If the old stay would already have expired while the character was busy,
		-- keep the restored location stable for a short grace period.
		if location.nextMove and location.nextMove <= (Player.time or 1) then
			location.nextMove = (Player.time or 1) + RandRange(1, 3)
		end
	end

	self:SetLocation(charName, location)
	self:SyncCompatibilityPools()
end

-- Resolve which mobile character and physical venue a stay-where-met quest
-- should pin. Direct traveler quests use the place where the player actually
-- met that character. Indirect quests may nominate locationCharacter; in that
-- case the character's current settled venue is used, with fallbackBuilding
-- only when the character is currently traveling/offstage.
function CharacterMobility:ResolveQuestLocation(quest, offerChar, offerBuilding)
	if not quest or not Player then return nil end

	local charName = quest.locationCharacter
	if charName == "ender" then charName = quest:GetEnderName() end
	if charName == "starter" then charName = quest:GetStarterName() end
	if not charName then charName = offerChar and offerChar.name or quest:GetStarterName() end
	if not charName or not self:IsMobile(charName) then return nil end

	local target = nil
	local context = nil

	-- If this is the same mobile character physically giving the quest, the
	-- actual encounter building is authoritative.
	if offerChar and offerChar.name == charName and offerBuilding and offerBuilding.name
		and string.sub(offerBuilding.name, 1, 1) ~= "_"
		and self:IsEligibleBuilding(offerBuilding)
		and self:IsPortAvailable(offerBuilding.port.name) then
		target = offerBuilding
		context = "met"
	else
		-- For an indirect quest (for example Felix sending the player to Rufus),
		-- use the nominated character's real settled location instead of the
		-- quest-giver's building.
		local location = self:GetLocation(charName)
		if location and location.mode == "building" and location.building then
			local current = _AllBuildings[location.building]
			if current and self:IsEligibleBuilding(current)
				and self:IsPortAvailable(current.port.name)
				and not (Player.buildingsBlocked and Player.buildingsBlocked[current.name]) then
				target = current
				context = "current"
			end
		end
	end

	if not target and quest.fallbackBuilding then
		local fallback = _AllBuildings[quest.fallbackBuilding]
		if fallback and self:IsEligibleBuilding(fallback) and self:IsPortAvailable(fallback.port.name) then
			target = fallback
			context = "fallback"
		end
	end

	if not target then return nil end
	local def = self:GetDefinition(charName)
	if def and def.class == "local" and target.port and target.port.name ~= def.homePort then
		DebugOut("WARNING", string.format("Quest '%s' tried to pin local '%s' outside home port '%s'.", tostring(quest.name), charName, tostring(def.homePort)))
		return nil
	end
	return { character=charName, building=target.name, port=target.port.name, context=context }
end

function CharacterMobility:BeginQuestLocation(quest, char, offerBuilding)
	if not quest or not Player then return false end
	local resolved = self:ResolveQuestLocation(quest, char, offerBuilding)
	if not resolved then return false end
	local charName = resolved.character
	local target = _AllBuildings[resolved.building]
	if not charName or not target then return false end

	Player.characterLocks = Player.characterLocks or {}
	Player.questLocations = Player.questLocations or {}
	local existing = Player.characterLocks[charName]
	if existing and existing.owner ~= quest.name then
		DebugOut("WARNING", string.format("Quest '%s' could not pin '%s': character is already locked by '%s'.", quest.name, charName, tostring(existing.owner)))
		return false
	end
	local source = existing and existing.sourceLocation or self:SnapshotLocation(charName)

	self:RemoveScriptedPlacements(charName, target.name)
	Player.buildingCharacters[target.name] = Player.buildingCharacters[target.name] or {}
	Player.buildingCharacters[target.name][charName] = true
	Player.characterLocks[charName] = {
		kind = "quest", owner = quest.name, building = target.name,
		sourceLocation = CopyLocation(source),
	}
	Player.questLocations[quest.name] = {
		character = charName, building = target.name, port = target.port.name,
		context = resolved.context,
	}
	Player.orderBannedChars[charName] = true
	self:SetLocation(charName, { mode="building", port=target.port.name, building=target.name, since=Player.time })
	self:SyncCompatibilityPools()
	DebugOut("CHAR", string.format("Quest '%s' pinned '%s' at '%s'.", quest.name, charName, target.name))
	return true
end

function CharacterMobility:EndQuestLocation(quest, outcome)
	if not quest or not Player then return end
	Player.questLocations = Player.questLocations or {}
	Player.characterLocks = Player.characterLocks or {}
	local qloc = Player.questLocations[quest.name]
	if not qloc then return end

	local charName = qloc.character
	local lock = charName and Player.characterLocks[charName] or nil
	if not charName or (lock and lock.owner ~= quest.name) then return end

	if qloc.building and Player.buildingCharacters[qloc.building] then
		Player.buildingCharacters[qloc.building][charName] = nil
	end
	Player.characterLocks[charName] = nil
	Player.questLocations[quest.name] = nil
	Player.orderBannedChars[charName] = nil

	local b = qloc.building and _AllBuildings[qloc.building] or nil
	local def = self:GetDefinition(charName)
	local canLinger = b and self:IsEligibleBuilding(b) and self:IsPortAvailable(b.port.name)
		and not (def and def.class == "local" and b.port.name ~= def.homePort)
	if canLinger then
		-- Completing or failing the quest does not teleport the character away.
		-- They linger where the player last dealt with them for 1–3 weeks. Locals
		-- may only linger within their own home port.
		self:SetLocation(charName, {
			mode="building", port=b.port.name, building=b.name,
			since=Player.time, nextMove=(Player.time or 1) + RandRange(1, 3),
		})
	elseif lock and lock.sourceLocation then
		self:RestoreLocation(charName, lock.sourceLocation)
	else
		self:SetLocation(charName, self:RollNaturalLocation(charName))
	end

	self:SyncCompatibilityPools()
	DebugOut("CHAR", string.format("Quest '%s' released '%s' after %s.", quest.name, charName, tostring(outcome or "resolution")))
end

function CharacterMobility:BeginOrderPlacement(charName, orderName, targetBuildingName, sourceLocation)
	if not Player or not self:IsMobile(charName) then return false end
	local target = _AllBuildings[targetBuildingName]
	if not target then return false end
	local def = self:GetDefinition(charName)
	if def and def.class == "local" and target.port and target.port.name ~= def.homePort then
		DebugOut("CHAR", string.format("Refusing to move local '%s' outside home port '%s' for Special Order '%s'.", charName, tostring(def.homePort), tostring(orderName)))
		return false
	end

	Player.characterLocks = Player.characterLocks or {}
	local existing = Player.characterLocks[charName]
	if existing and existing.owner ~= orderName then return false end
	local source = sourceLocation or (existing and existing.sourceLocation) or self:SnapshotLocation(charName)

	self:RemoveScriptedPlacements(charName, targetBuildingName)
	Player.buildingCharacters[targetBuildingName] = Player.buildingCharacters[targetBuildingName] or {}
	Player.buildingCharacters[targetBuildingName][charName] = true
	Player.characterLocks[charName] = {
		kind="special_order", owner=orderName, building=targetBuildingName,
		sourceLocation=CopyLocation(source),
	}
	Player.orderBannedChars[charName] = true
	Player.orderBannedBuildings[targetBuildingName] = true
	self:SetLocation(charName, { mode="building", port=target.port.name, building=targetBuildingName, since=Player.time })
	self:SyncCompatibilityPools()
	return true
end

function CharacterMobility:ReleaseOrderPlacement(charName, orderName, targetBuildingName, sourceLocation)
	if not Player then return end
	Player.characterLocks = Player.characterLocks or {}
	local lock = Player.characterLocks[charName]
	if lock and lock.owner ~= orderName then return end

	local target = targetBuildingName or (lock and lock.building)
	if target and Player.buildingCharacters[target] then
		Player.buildingCharacters[target][charName] = nil
	end
	Player.characterLocks[charName] = nil
	Player.orderBannedChars[charName] = nil
	if target then Player.orderBannedBuildings[target] = nil end

	self:RestoreLocation(charName, sourceLocation or (lock and lock.sourceLocation))
end

function CharacterMobility:GetAvailableOrderCandidates(className, destinationPort)
	local out = {}
	local seen = {}
	for charName, char in pairs(_AllCharacters or {}) do
		local def = char.mobility
		local loc = self:GetLocation(charName)
		local localPortMatches = className ~= "local" or not destinationPort or (def and def.homePort == destinationPort)
		if def and def.class == className and localPortMatches and loc and loc.mode ~= "offstage"
			and not self:IsLocked(charName)
			and not (Player.orderBannedChars and Player.orderBannedChars[charName]) then
			table.insert(out, char)
			seen[charName] = true
		end
	end

	-- Script-gated legacy travelers (for example Alex, Tyson, Katherine, Wolf and
	-- the postgame announcer) intentionally have no ambient mobility profile. If a
	-- quest has explicitly placed one in _travelers, retain the old Special Order
	-- behavior without turning that character into an ordinary roaming NPC.
	if className == "global" and Player and Player.buildingCharacters then
		for charName, present in pairs(Player.buildingCharacters._travelers or {}) do
			local char = _AllCharacters and _AllCharacters[charName]
			if present and char and not char.mobility and not seen[charName]
				and not (Player.orderBannedChars and Player.orderBannedChars[charName]) then
				table.insert(out, char)
				seen[charName] = true
			end
		end
	end

	table.sort(out, function(a, b) return a.name < b.name end)
	return out
end

function CharacterMobility:InferLegacySourceLocation(charName, sourcePool)
	local def = self:GetDefinition(charName)
	if not def then return nil end
	if sourcePool == "_travelers" then
		return { mode="travel", since=Player and Player.time or 1 }
	elseif sourcePool == "_empty" and def.class == "local" then
		return { mode="home", port=def.homePort, since=Player and Player.time or 1 }
	elseif sourcePool and _AllBuildings[sourcePool] then
		local b = _AllBuildings[sourcePool]
		return { mode="building", port=b.port and b.port.name or nil, building=b.name, since=Player and Player.time or 1 }
	end
	if def.class == "local" then
		return { mode="home", port=def.homePort, since=Player and Player.time or 1 }
	end
	return { mode="travel", since=Player and Player.time or 1 }
end

function CharacterMobility:MigrateVersion3(player)
	if not player then return end
	player.characterLocks = player.characterLocks or {}
	player.questLocations = player.questLocations or {}

	-- Version 1 could save a stay-where-met character as a direct placement but
	-- had no ownership lock or quest-location record. Rebuild those records so a
	-- pre-v2 active quest can still release the character cleanly.
	for questName, _ in pairs(player.questsActive or {}) do
		local quest = _AllQuests and _AllQuests[questName] or nil
		if quest and quest.locationPolicy == "stay_where_met" then
			local charName = quest.locationCharacter
			if charName == "ender" then charName = quest:GetEnderName() end
			if charName == "starter" then charName = quest:GetStarterName() end
			if not charName then charName = (player.questStarters and player.questStarters[questName]) or quest:GetStarterName() end

			if charName and self:IsMobile(charName) and not player.characterLocks[charName] then
				local buildingName = self:FindScriptedPhysicalPlacement(charName)
				local context = "fallback"
				if buildingName then
					context = (quest.fallbackBuilding and buildingName == quest.fallbackBuilding) and "fallback" or "met"
				else
					buildingName = quest.fallbackBuilding
				end
				local b = buildingName and _AllBuildings[buildingName] or nil
				if b then
					local source = self:InferLegacySourceLocation(charName, self:GetDefinition(charName).class == "local" and "_empty" or "_travelers")
					player.characterLocks[charName] = { kind="quest", owner=questName, building=b.name, sourceLocation=CopyLocation(source) }
					player.questLocations[questName] = { character=charName, building=b.name, port=b.port.name, context=context }
					player.orderBannedChars[charName] = true
					self:SetLocation(charName, { mode="building", port=b.port.name, building=b.name, since=player.time })
				end
			elseif charName and player.characterLocks[charName] and player.characterLocks[charName].owner == questName then
				-- A v2 save may already have a lock but lack the new context marker.
				local qloc = player.questLocations[questName]
				if qloc and not qloc.context then
					qloc.context = (quest.fallbackBuilding and qloc.building == quest.fallbackBuilding) and "fallback" or "met"
				end
			end
		end
	end

	-- Older active delivery quests only remembered _travelers/_empty. Recreate a
	-- canonical sourceLocation and ownership lock without changing their gameplay
	-- destination, so completion/rejection can restore them safely.
	for questName, _ in pairs(player.questsActive or {}) do
		local quest = _AllQuests and _AllQuests[questName] or nil
		local charName = quest and quest.delivery and quest:GetEnderName() or nil
		if quest and quest.delivery and not quest.isResident and charName and self:IsMobile(charName) then
			quest.sourceLocation = quest.sourceLocation or self:InferLegacySourceLocation(charName, quest.sourcePool)
			if not player.characterLocks[charName] then
				self:BeginOrderPlacement(charName, quest.name, quest.endbuilding, quest.sourceLocation)
			end
		end
	end

	-- Pending orders are plain save tables until offered. Give them the same exact
	-- source snapshot and lock that newly generated v2 orders receive.
	for _, order in ipairs(player.pendingSpecialOrders or {}) do
		if not order.isResident and order.ender and self:IsMobile(order.ender) then
			order.sourceLocation = order.sourceLocation or self:InferLegacySourceLocation(order.ender, order.sourcePool)
			order.sourcePool = order.sourcePool or self:GetLegacySourcePool(order.ender, order.sourceLocation)
			if not player.characterLocks[order.ender] then
				self:BeginOrderPlacement(order.ender, order.name, order.endbuilding, order.sourceLocation)
			end
		end
	end
end

function CharacterMobility:ScheduleNextMove(charName, location)
	local def = self:GetDefinition(charName)
	if not def or not Player then return location end
	location = location or {}
	local minStay = tonumber(def.minStay) or kDefaultMinStay
	local maxStay = tonumber(def.maxStay) or kDefaultMaxStay
	if maxStay < minStay then maxStay = minStay end
	location.since = Player.time or 1
	location.nextMove = (Player.time or 1) + RandRange(minStay, maxStay)
	return location
end

function CharacterMobility:GetBuildingWeight(charName, building)
	local def = self:GetDefinition(charName) or {}
	local tags = building.mobilityTags or CharacterMobilityBuildingData[building.name] or {}
	local weight = 1

	for tag, affinity in pairs(def.affinities or {}) do
		if tags[tag] then weight = weight + (tonumber(affinity) or 0) end
	end

	if def.portAffinity and def.portAffinity[building.port.name] then
		weight = weight + (tonumber(def.portAffinity[building.port.name]) or 0)
	end

	if weight < 1 then weight = 1 end
	return weight
end

function CharacterMobility:ChooseBuilding(charName, excludePortName)
	local buildings = self:GetEligibleBuildings(excludePortName, charName)
	if table.getn(buildings) == 0 then return nil end

	local total = 0
	local weighted = {}
	for _, building in ipairs(buildings) do
		local weight = self:GetBuildingWeight(charName, building)
		total = total + weight
		table.insert(weighted, { building=building, upper=total })
	end

	local roll = RandRange(1, total)
	for _, entry in ipairs(weighted) do
		if roll <= entry.upper then return entry.building end
	end
	return buildings[table.getn(buildings)]
end

function CharacterMobility:RollNaturalLocation(charName)
	local def = self:GetDefinition(charName)
	if not def then return nil end

	-- Locals are stable members of their home-port population. They can be
	-- encountered throughout eligible buildings in that port, but ambient
	-- mobility never puts them in travel or in another port.
	if def.class == "local" then
		return { mode = "home", port = def.homePort, since = Player and Player.time or 1 }
	end

	-- Global / legacy travelers divide their time between travel and one
	-- persistent physical building. No capacity check is performed.
	local travelWeight = tonumber(def.travelWeight) or kDefaultGlobalTravelWeight
	local settledWeight = tonumber(def.settledWeight) or (100 - travelWeight)
	local total = travelWeight + settledWeight
	if total <= 0 then total = 1 end
	local roll = RandRange(1, total)

	if roll <= travelWeight then
		return self:ScheduleNextMove(charName, { mode = "travel" })
	end

	local building = self:ChooseBuilding(charName, nil)
	if building then
		return self:ScheduleNextMove(charName, {
			mode = "building",
			port = building.port.name,
			building = building.name,
		})
	end
	return self:ScheduleNextMove(charName, { mode = "travel" })
end

function CharacterMobility:MigrateVersion4(player)
	if not player then return end
	player.characterLocations = player.characterLocations or {}

	-- v3 and earlier allowed locals to travel or settle abroad. Preserve active
	-- quest/order locks for save compatibility, but immediately normalize every
	-- unlocked local back to its home-port population.
	for charName, char in pairs(_AllCharacters or {}) do
		local def = char.mobility
		if def and def.class == "local" and not self:IsLocked(charName)
			and not self:FindScriptedPhysicalPlacement(charName) then
			player.characterLocations[charName] = {
				mode = "home", port = def.homePort, since = player.time or 1,
			}
		end
	end
end

function CharacterMobility:MigrateVersion5(player)
	if not player then return end
	player.buildingCharacters = player.buildingCharacters or {}
	player.buildingCharacters._travelers = player.buildingCharacters._travelers or {}
	player.questsComplete = player.questsComplete or {}
	player.questsActive = player.questsActive or {}
	player.questsAcceptedEver = player.questsAcceptedEver or {}

	local travelers = player.buildingCharacters._travelers
	local function QuestAccepted(name)
		return player.questsAcceptedEver[name] ~= nil
			or player.questsActive[name] ~= nil
			or player.questsComplete[name] ~= nil
	end
	local function HasPhysicalPlacement(charName)
		for buildingName, chars in pairs(player.buildingCharacters or {}) do
			if string.sub(tostring(buildingName), 1, 1) ~= "_"
				and chars and chars[charName] and _AllBuildings and _AllBuildings[buildingName] then
				return true
			end
		end
		return false
	end
	local function RestoreLegacyTraveler(charName)
		local char = _AllCharacters and _AllCharacters[charName]
		if not char or char.mobility then return end
		if HasPhysicalPlacement(charName) then return end
		if player.orderBannedChars and player.orderBannedChars[charName] then return end
		travelers[charName] = true
	end

	-- Alex's Bali reveal deliberately releases the three Schokolade Weltreich
	-- antagonists into the legacy traveler pool. v4 compatibility syncing could
	-- erase them because they intentionally have no ambient mobility definitions.
	if QuestAccepted("open_bali") then
		RestoreLegacyTraveler("evil_tyso")
		RestoreLegacyTraveler("evil_wolf")
		if not QuestAccepted("rank4_kath_bribe") then
			RestoreLegacyTraveler("evil_kath")
		else
			-- Katherine is explicitly removed from travel when the Falklands bribe
			-- quest is accepted, because she becomes a fixed Falklands encounter.
			travelers.evil_kath = nil
		end
	end

	-- Alex is temporarily returned to travel for the Rank 4 promotion, then
	-- removed again. Later, the Katherine-bribe setup returns Alex to travel for
	-- the remainder of the campaign/postgame.
	if QuestAccepted("rank4_kath_bribe_prep") then
		RestoreLegacyTraveler("main_alex")
	elseif QuestAccepted("rank4_promo_prompt") and not QuestAccepted("rank4_promo") then
		RestoreLegacyTraveler("main_alex")
	elseif QuestAccepted("rank4_promo") then
		travelers.main_alex = nil
	end

	-- Rank 5 explicitly enables the announcer's orders and places the announcer
	-- into _travelers. Restore that postgame state on saves damaged by v4 syncing.
	if QuestAccepted("rank5_promo") then
		RestoreLegacyTraveler("announcer")
	end
end

function CharacterMobility:MigrateVersion6(player)
	if not player then return end
	player.characterLocations = player.characterLocations or {}
	player.characterLocks = player.characterLocks or {}
	player.buildingCharacters = player.buildingCharacters or {}
	player.orderBannedChars = player.orderBannedChars or {}
	player.orderBannedBuildings = player.orderBannedBuildings or {}

	-- v5 repaired the scripted Bali-era legacy travelers, but an established save
	-- could still carry damaged ambient mobility state from earlier Reforged builds.
	-- Fresh saves are healthy, so v6 only repairs restored saves once.
	local liveOwners = {}
	for questName, _ in pairs(player.questsActive or {}) do
		liveOwners[questName] = true
	end
	for _, order in ipairs(player.pendingSpecialOrders or {}) do
		if order and order.name then liveOwners[order.name] = true end
	end

	-- Release orphaned quest/order locks left by older mobility builds. A valid
	-- active quest or pending Special Order keeps its lock and exact placement.
	local orphanLocks = 0
	for charName, lock in pairs(player.characterLocks) do
		local managedKind = lock and (lock.kind == "quest" or lock.kind == "special_order")
		local owner = lock and lock.owner or nil
		if managedKind and (not owner or not liveOwners[owner]) then
			local buildingName = lock and lock.building or nil
			if buildingName and player.buildingCharacters[buildingName] then
				player.buildingCharacters[buildingName][charName] = nil
			end
			player.characterLocks[charName] = nil
			player.orderBannedChars[charName] = nil
			if buildingName then player.orderBannedBuildings[buildingName] = nil end
			orphanLocks = orphanLocks + 1
		end
	end

	-- Re-seed ONLY ordinary global mobility characters that are not currently
	-- owned by a quest/order or deliberately placed in a physical building. The
	-- migration uses a balanced split so an upgraded save cannot end up with every
	-- normal traveler simultaneously absent from the travel pool.
	local globals = {}
	local preserved = 0
	for charName, char in pairs(_AllCharacters or {}) do
		local def = char.mobility
		if def and def.class == "global" then
			if player.characterLocks[charName]
				or self:FindScriptedPhysicalPlacement(charName)
				or player.orderBannedChars[charName] then
				preserved = preserved + 1
			else
				table.insert(globals, charName)
			end
		end
	end
	table.sort(globals)

	local total = table.getn(globals)
	local travelTarget = (total + 1) / 2
	local travelCount = 0
	local buildingCount = 0
	for i, charName in ipairs(globals) do
		if i <= travelTarget then
			player.characterLocations[charName] = self:ScheduleNextMove(charName, { mode = "travel" })
			travelCount = travelCount + 1
		else
			local building = self:ChooseBuilding(charName, nil)
			if building then
				player.characterLocations[charName] = self:ScheduleNextMove(charName, {
					mode = "building", port = building.port.name, building = building.name,
				})
				buildingCount = buildingCount + 1
			else
				player.characterLocations[charName] = self:ScheduleNextMove(charName, { mode = "travel" })
				travelCount = travelCount + 1
			end
		end
	end

	-- Keep unlocked locals in their intended home-port population if an old save
	-- left them with stale ambient state. Script/quest-owned locals are untouched.
	for charName, char in pairs(_AllCharacters or {}) do
		local def = char.mobility
		if def and def.class == "local"
			and not player.characterLocks[charName]
			and not self:FindScriptedPhysicalPlacement(charName) then
			player.characterLocations[charName] = {
				mode = "home", port = def.homePort, since = player.time or 1,
			}
		end
	end

	DebugOut("CHAR", string.format(
		"Mobility v6 save repair complete: %d ambient global(s) traveling, %d settled, %d preserved, %d orphan lock(s) cleared.",
		travelCount, buildingCount, preserved, orphanLocks))
end

function CharacterMobility:Initialize(player, restoring)
	if not player then return end
	local previousVersion = tonumber(player.characterMobilityVersion) or 0
	player.characterLocations = player.characterLocations or {}
	player.characterLocks = player.characterLocks or {}
	player.questLocations = player.questLocations or {}

	for charName, char in pairs(_AllCharacters or {}) do
		if char.mobility then
			local location = player.characterLocations[charName]
			if not location or not location.mode then
				local scripted = self:FindScriptedPhysicalPlacement(charName)
				if scripted then
					local b = _AllBuildings[scripted]
					location = self:ScheduleNextMove(charName, {
						mode = "building",
						port = b and b.port and b.port.name or nil,
						building = scripted,
					})
				else
					location = self:RollNaturalLocation(charName)
				end
				player.characterLocations[charName] = location
			end
		end
	end

	if restoring and previousVersion < 3 then
		self:MigrateVersion3(player)
	end
	if restoring and previousVersion < 4 then
		self:MigrateVersion4(player)
	end
	if restoring and previousVersion < 5 then
		self:MigrateVersion5(player)
	end
	if restoring and previousVersion < 6 then
		self:MigrateVersion6(player)
	end
	player.characterMobilityVersion = self.version
	self:SyncCompatibilityPools()
	DebugOut("CHAR", string.format("Living character mobility initialized (v%d).", self.version))
end

function CharacterMobility:Update(player)
	if not player then return end
	player.characterLocations = player.characterLocations or {}

	for charName, char in pairs(_AllCharacters or {}) do
		if char.mobility and not self:IsLocked(charName) then
			local scripted = self:FindScriptedPhysicalPlacement(charName)
			if not scripted then
				local location = player.characterLocations[charName]
				local invalidBuilding = location and location.mode == "building"
					and (not _AllBuildings[location.building]
						or not self:IsEligibleBuilding(_AllBuildings[location.building])
						or not self:IsPortAvailable(_AllBuildings[location.building].port.name)
						or (player.buildingsBlocked and player.buildingsBlocked[location.building]))

				local expiredOffstage = location and location.mode == "offstage"
					and (not location.nextMove or player.time >= location.nextMove)

				if (not location) or invalidBuilding or expiredOffstage
					or (location.nextMove and player.time >= location.nextMove) then
					player.characterLocations[charName] = self:RollNaturalLocation(charName)
				end
			end
		end
	end

	self:SyncCompatibilityPools()
end

function CharacterMobility:SyncCompatibilityPools()
	if not Player then return end
	Player.buildingCharacters = Player.buildingCharacters or {}

	-- _travelers is mostly a generated compatibility view, but several campaign
	-- quests still deliberately place non-mobility characters in it. Preserve
	-- those scripted legacy members while rebuilding the ambient mobility view.
	local scriptedLegacyTravelers = {}
	for charName, present in pairs(Player.buildingCharacters._travelers or {}) do
		local char = _AllCharacters and _AllCharacters[charName]
		if present and char and not char.mobility then
			scriptedLegacyTravelers[charName] = true
		end
	end

	Player.buildingCharacters._travelers = scriptedLegacyTravelers
	Player.buildingCharacters._empty = {}

	for charName, char in pairs(_AllCharacters or {}) do
		local def = char.mobility
		local location = Player.characterLocations and Player.characterLocations[charName]
		if def and location and not self:IsLocked(charName) and not self:FindScriptedPhysicalPlacement(charName) then
			if location.mode == "travel" then
				Player.buildingCharacters._travelers[charName] = true
			elseif def.class == "local" and location.mode == "home" then
				-- Compatibility only. Physical buildings no longer read the old
				-- _empty fallback, but legacy order code may still consult this pool.
				Player.buildingCharacters._empty[charName] = true
			end
		end
	end
end

function CharacterMobility:GetCharactersForBuilding(building)
	local out, seen = {}, {}
	if not self:IsEligibleBuilding(building) or not Player then return out end

	for charName, char in pairs(_AllCharacters or {}) do
		local def = char.mobility
		local location = Player.characterLocations and Player.characterLocations[charName]
		if def and location and not self:IsLocked(charName) and not self:FindScriptedPhysicalPlacement(charName) then
			if def.class == "local" and location.mode == "home"
				and def.homePort == building.port.name
				and self:IsCharacterEligibleForBuilding(charName, building) then
				AddUniqueCharacter(out, seen, char)
			elseif location.mode == "building" and location.building == building.name
				and self:IsCharacterEligibleForBuilding(charName, building) then
				AddUniqueCharacter(out, seen, char)
			end
		end
	end

	table.sort(out, function(a, b) return a.name < b.name end)
	return out
end

function CharacterMobility:OnScriptedPlace(charName, buildingName)
	local def = self:GetDefinition(charName)
	if not def or not Player then return end

	if buildingName == "_travelers" then
		if def.class == "local" then
			self:SetLocation(charName, { mode = "home", port = def.homePort, since = Player.time or 1 })
		else
			self:SetLocation(charName, self:ScheduleNextMove(charName, { mode = "travel" }))
		end
	elseif buildingName == "_empty" then
		if def.class == "local" then
			self:SetLocation(charName, { mode = "home", port = def.homePort, since = Player.time or 1 })
		else
			self:SetLocation(charName, self:ScheduleNextMove(charName, { mode = "travel" }))
		end
	else
		local building = _AllBuildings[buildingName]
		if def.class == "local" and building and building.port and building.port.name ~= def.homePort then
			DebugOut("CHAR", string.format("Ignoring out-of-port scripted placement for local '%s': %s.", charName, buildingName))
			if Player.buildingCharacters[buildingName] then Player.buildingCharacters[buildingName][charName] = nil end
			self:SetLocation(charName, { mode = "home", port = def.homePort, since = Player.time or 1 })
		else
			self:SetLocation(charName, self:ScheduleNextMove(charName, {
				mode = "building",
				port = building and building.port and building.port.name or nil,
				building = buildingName,
			}))
		end
	end

	self:SyncCompatibilityPools()
end

function CharacterMobility:OnScriptedRemove(charName, buildingName)
	local def = self:GetDefinition(charName)
	if not def or not Player then return end
	if self:IsLocked(charName) then return end
	local location = self:GetLocation(charName)
	if buildingName ~= "_travelers" and buildingName ~= "_empty"
		and location and location.mode == "building" and location.building == buildingName then
		-- Most quest scripts immediately follow a remove with a place. Offstage
		-- prevents a one-frame duplicate if they do not.
		self:SetLocation(charName, {
			mode = "offstage",
			since = Player.time or 1,
			nextMove = (Player.time or 1) + 1,
		})
	end
end
