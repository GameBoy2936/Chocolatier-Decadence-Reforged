--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A "Port" is a destination in the world

Port =
{
	datafile = nil,			-- Name of data file containing the original port
	name = nil,				-- Name of the port itself
	hidden = false,			-- TRUE if this is a normally-hidden port
	locked = false,			-- TRUE If this port is initially locked
	
	sprites = {},			-- Sprites in the port
	routes = nil,			-- Routes to other ports
	
	hemisphere = nil,		-- Hemisphere in order to determine seasonal patterns, "north" or "south"
	region = nil,    		-- Area in the world, e.g., "europe", "north_america"
	country = nil,    		-- Country of the port, e.g., "switzerland", "indonesia"
	culture = "western",	-- Cultural zone for holiday observance (western, muslim, east_asian, etc.)
}

Port.__tostring = function(t) return "{Port:"..tostring(t.name).."}" end

_AllPorts = {}

------------------------------------------------------------------------------
-- Player-specific accessors

function Port:IsAvailable()
--	if not Player.portsAvailable[self.name] then Player.portsAvailable[self.name] = "locked" end
	return (Player.portsAvailable[self.name] ~= "locked" and Player.portsAvailable[self.name] ~= "hidden")
end

function Port:Unlock()
	if not self:IsAvailable() then
        DebugOut("PLAYER", "Port unlocked: " .. self.name)
        Player.portsAvailable[self.name] = "new"
    end
end

function Port:Lock()
    if self:IsAvailable() then DebugOut("PLAYER", "Port locked: " .. self.name) end
	Player.portsAvailable[self.name] = "locked"
end

function Port:TravelCost()
	if Player.questVariables.ownplane == 1 then return 0
	else return Player.portsCost[self.name] or 0
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Port:Create(name)
	local t = nil
	if not name then
		-- TODO: WARN: No Name given
	else
--		DebugOut("PORT:"..tostring(name))

		if _AllPorts[name] then
			DebugOut("REDEFINING "..tostring(name))
		elseif _G[name] then
			-- TODO: WARN: Variable with this name already exists
		end
		
		t = _AllPorts[name] or {}
		setmetatable(t, self) self.__index = self
		_AllPorts[name] = t
		_G[name] = t
		
		-- Initialize other port values
		t.name = name
		t.cadikey = t.cadikey or name
		t.buildings = {}
		t.sprites = {}
		
		-- BUT keep route table constant when re-defining the port at runtime (for development)
		t.routes = t.routes or {}
	end
	return t
end

function CreatePort(name) return Port:Create(name) end

function LoadPorts()
	-- Get a list of port definition files from the system
	local t = {}
	LoadPortFileList(t)
	
	-- Load each port definition file in the list
	for _,fileName in ipairs(t) do
		dofile(fileName)
	end
end

------------------------------------------------------------------------------
-- Rollover and Click Management

function Port:MapRolloverPopup()
	if gTravelActive then return nil end

	local label = {}
	if self:IsAvailable() then
		if Player.portName == self.name then table.insert(label, GetString("trip_here"))
		else
			local origin = Player:GetPort()
			if origin then
				local route = origin:GetRoute(self)
				local time = route.time
				if time == 1 then table.insert(label, GetString("trip_time_single"))
				else table.insert(label, GetText("trip_time", tostring(time)))
				end
			end

			local cost = self:TravelCost()
			if cost == 0 then
				table.insert(label, GetString("trip_free"))
			else
				table.insert(label, GetText("trip_cost", Dollars(cost)))
				if Player.money < cost then table.insert(label, GetText("trip_expensive", Dollars(cost))) end
			end
		end
	else
		table.insert(label, GetString("trip_locked"))
	end
	label = "#"..table.concat(label,"\n")
	
	return MakeDialog
	{
		Bitmap
		{
			x=0,y=0, image="image/traveltag", fit=true,
			Text { x=0,y=2,w=kMax,h=25, label="#"..GetString(self.name), font=portNameRolloverFont, flags=kVAlignCenter+kHAlignCenter, },
--			Text { x=24,y=25,w=201,h=30, label=label, font=rolloverInfoFont, flags=kVAlignTop+kHAlignCenter, }
			Text { x=24,y=25,w=201,h=40, label=label, font=rolloverInfoFont, flags=kVAlignTop+kHAlignCenter, }
		}
	}
end

function Port:EnterPort(sting)
	Player:SetPort(self.name)
	ReleaseLedger()
	SwapToModal("ui/portview.lua")
	
	-- Always play the ambient sound associated with the port's main cadikey.
	SoundEvent(self.cadikey)

	if sting then
		local musicEvent
		if self.music_key then
			-- If a specific music_key is provided, use it.
			musicEvent = self.music_key
		else
			-- Otherwise, fall back to the original convention.
			musicEvent = self.cadikey .. "_sting"
		end
		
		-- Check if the event name already ends with "_sting". If not, add it.
		-- This handles cases where the base key is the full event name.
		if string.sub(musicEvent, -6) ~= "_sting" then
			musicEvent = musicEvent .. "_sting"
		end
		
		SoundEvent(musicEvent)
	end
end

function Port:OnClick()
	if gTravelActive then return end

	if self.name == Player.portName then
		self:EnterPort()
	elseif self:IsAvailable() then
		local cost = self:TravelCost()
		if Player.money < cost then
			-- TODO: Warn no money
		else
			gTravelActive = true
			
			local origin = Player:GetPort()
			local route = origin:GetRoute(self)
		
            DebugOut("PLAYER", "Travel initiated from " .. origin.name .. " to " .. self.name .. ". Duration: " .. route.time .. " week(s). Cost: " .. Dollars(cost))

			Player:SubtractMoney(cost)
			Player.destination = self.name
		
			-- TODO: Determine path and icon for travel between ports
			local dest = self
			local icon = "image/travel_air"
			local path = nil
			
			-- Three seconds per week of travel
			local weeks = (route.time or 1)
			local duration = weeks * 3000
			
			-- Build the table of events to fire at various points in the trip
			local events = {}

			-- Tick the simulator every day during the trip
			for i=1,weeks do
--				table.insert(events, { time=i * 3000 - 100, action=function() PauseTravel() TickSim(1) ResumeTravel() end })
				table.insert(events, { time=(i-1) * 3000 + 1, action=function() PauseTravel() TickSim(1) ResumeTravel() end })
			end

--[[
			-- Toward the end of the allotted time, cue the sting
			local stingTime = duration - 1000
			local stingCue = self.name.."_sting"
			table.insert(events, { time=stingTime, action=function() SoundEvent(stingCue) end })
]]--

			-- At the end of the trip, enter the target port
			table.insert(events, { time=duration, action=function() SoundEvent("Stop_travel_plane"); dest:EnterPort(true); gTravelActive=false; end })
			
            -- Create tracking tables to prevent duplicate events during a single trip.
            local tripScheduledHints = {}
            local tripScheduledTips = {}

            -- The entire event-checking block is now inside a per-week loop.
            -- For every week of the trip, check for a potential event.
            for i=1,weeks do
                -- Calculate a random time within this specific week's animation window for the event to occur.
                local eventTime = (i-1) * 3000 + RandRange(1000, 2500)

                -- Encounters happen based on a timer and a random chance.
                local travelers = _AllBuildings["_travelers"]
                local encounter = false
                
                -- Add a flag to prevent multiple major events in the same week.
                local highPriorityEventScheduled = false
                
                if Player.rank > 1 then
                    if Player.encounterTimer <= 1 then
                        Player.encounterTimer = 0
                        encounter = true
                        DebugOut("PLAYER", "Encounter forced by timer during week " .. i)
                    else
                        Player.encounterTimer = Player.encounterTimer - 1
                        local encounterRoll = RandRange(1,100)
                        if encounterRoll <= 12 then 
                            encounter = true 
                            DebugOut("PLAYER", "Random encounter triggered during week " .. i .. " (Rolled " .. encounterRoll .. ")")
                        end
                    end
                end
                
                -- If the player is ending a quest with a traveler, then an encounter should be forced
                if not encounter then
                    local quests = travelers:FindQuestsEnding()
                    if quests and table.getn(quests) > 0 then
                        for _,qt in ipairs(quests) do
                            if qt.quest:AreGoalsMet() and not qt.quest:IsComplete() then
                                -- Check if the quest ender is currently in a specific building.
                                local enderChar = qt.char
                                local isPlacedInBuilding = false
                                for buildingName, charList in pairs(Player.buildingCharacters) do
                                    if buildingName ~= "_travelers" and buildingName ~= "_empty" then
                                        if charList[enderChar.name] then
                                            isPlacedInBuilding = true
                                            DebugOut("PLAYER", "Skipping forced encounter for '" .. qt.quest.name .. "'. Ender '" .. enderChar.name .. "' is currently placed in building '" .. buildingName .. "'.")
                                            break
                                        end
                                    end
                                end

                                if not isPlacedInBuilding then
                                    encounter = true;
                                    DebugOut("PLAYER", "Encounter forced by completed traveler quest during week " .. i .. ": " .. qt.quest.name)
                                    break;
                                end
                            end
                        end
                    end
                end
                
                -- If there is a Priority 1 quest available from a traveler, an encounter should be forced
                if not encounter then
                    local quests = travelers:FindQuestsStarting(1)
                    if quests and table.getn(quests) > 0 then
                        encounter = true
                        DebugOut("PLAYER", "Encounter forced by high-priority traveler quest during week " .. i .. ": " .. quests[1].quest.name)
                    end
                end
                
                -- If there is an expired quest whose ender is a traveler, an encounter should be forced
                if not encounter then
                    for name,_ in pairs(Player.questsActive) do
                        local quest = _AllQuests[name]
                        if quest:IsExpired() then
                            -- Check if the expired quest's ender is a true traveler.
                            local enderChar = quest:GetEnder()
                            local isPlacedInBuilding = false
                            if enderChar then
                                for buildingName, charList in pairs(Player.buildingCharacters) do
                                    if buildingName ~= "_travelers" and buildingName ~= "_empty" then
                                        if charList[enderChar.name] then
                                            isPlacedInBuilding = true
                                            DebugOut("PLAYER", "Skipping forced encounter for expired quest '" .. quest.name .. "'. Ender '" .. enderChar.name .. "' is placed in building '" .. buildingName .. "'.")
                                            break
                                        end
                                    end
                                end
                            end

                            if not isPlacedInBuilding then
                                encounter = true;
                                DebugOut("PLAYER", "Encounter forced by expired quest during week " .. i .. ": " .. name)
                                break;
                            end
                        end
                    end
                end

                -- If an encounter is triggered for this week, schedule it and stop checking for other events for this week.
                if encounter then
                    Player.encounterTimer = 10
                    highPriorityEventScheduled = true
                    table.insert(events, { time=eventTime, action=function()
                            SoundEvent("Stop_travel_plane")
                            PauseTravel()
                            local somethingHappened = travelers:HandleQuestExpiration()
                            if not somethingHappened then
                                travelers:OnClick()
                            end
                            ResumeTravel()
                            SoundEvent("travel_plane")
                        end })
                else
                    -- Wrap the rest of the checks in the safeguard.
                    if not highPriorityEventScheduled then
                        -- Look for medals
                        local medal = Player:CheckMedals()
                        if medal then
                            -- If no encounter needs to be forced, award the medal
                            table.insert(events, { time=eventTime, action=function()
                                    SoundEvent("Stop_travel_plane")
                                    PauseTravel()
                                    Player:AwardMedal(medal)
                                    ResumeTravel()
                                    SoundEvent("travel_plane")
                                end })
                        else
                            -- If no medal, check for pending special orders to deliver via telegram.
                            local orderQuest = nil
                            if Player.pendingSpecialOrders and table.getn(Player.pendingSpecialOrders) > 0 then
                                local first_order_data = Player.pendingSpecialOrders[1]
                                -- Check against the time at the END of the current travel week
                                if Player.time + i > first_order_data.earlyOfferCutoff then
                                    first_order_data.forceTelegram = true
                                    orderQuest = CreateDeliveryQuest(first_order_data, first_order_data.isResident, first_order_data.sourcePool)
                                    table.remove(Player.pendingSpecialOrders, 1)
                                end
                            end

                            if orderQuest then 
                                table.insert(events, { time=eventTime, action=function()
                                        SoundEvent("Stop_travel_plane")
                                        PauseTravel()
                                        orderQuest:Offer()
                                        ResumeTravel()
                                        SoundEvent("travel_plane")
                                    end })
                            else
                                -- If no order, check for any quest hints to deliver
                                local hintToDeliver = nil
                                for questName, _ in pairs(Player.questsActive) do
                                    local quest = _AllQuests[questName]
                                    -- Check if a hint for this quest has already been scheduled for this trip.
                                    if quest and quest:IsHintEligible() and not tripScheduledHints[questName] then
                                        hintToDeliver = quest
                                        break
                                    end
                                end

                                if hintToDeliver then
                                    -- Mark this hint as scheduled for this trip.
                                    tripScheduledHints[hintToDeliver.name] = true
                                    table.insert(events, { time=eventTime, action=function()
                                            SoundEvent("Stop_travel_plane")
                                            PauseTravel()
                                            
                                            local char = travelers:RandomCharacter()
                                            local attempts = 0
                                            -- Re-roll up to 10 times to find a non-evil character.
                                            while char and Tips.evilCharacters[char.name] and attempts < 10 do
                                                char = travelers:RandomCharacter()
                                                attempts = attempts + 1
                                            end

                                            -- Only deliver the hint if we found a suitable (non-evil) character.
                                            if char and not Tips.evilCharacters[char.name] then
                                                local hintText = hintToDeliver:GetHint()
                                                DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..hintText }
                                                -- Set cooldown relative to the week the hint is delivered
                                                Player.questHintCooldowns[hintToDeliver.name] = Player.time + i + 8
                                            else
                                                DebugOut("ERROR", "Could not find an eligible traveler to deliver hint for: " .. hintToDeliver.name)
                                            end

                                            ResumeTravel()
                                            SoundEvent("travel_plane")
                                        end })
                                else
                                    -- If no hint, check for tips to announce
                                    local tipToAnnounce = nil
                                    local tipIndex = nil
                                    if Player.pendingAnnouncements and table.getn(Player.pendingAnnouncements) > 0 then
                                        local char = travelers:RandomCharacter()
                                        if char then
                                            for j, tip in ipairs(Player.pendingAnnouncements) do
                                                -- BUG FIX: Check if this tip has already been scheduled for this trip.
                                                if not tripScheduledTips[tip.key] and Tips.CanCharacterAnnounceTip(char, travelers, tip) then
                                                    tipToAnnounce = tip
                                                    tipIndex = j
                                                    break
                                                end
                                            end
                                        end
                                    end

                                    if tipToAnnounce then
                                        tripScheduledTips[tipToAnnounce.key] = true
                                        table.insert(events, { time=eventTime, action=function()
                                                SoundEvent("Stop_travel_plane")
                                                PauseTravel()
                                                local char = travelers:RandomCharacter()
                                                local text = Tips.GetDynamicTipString(tipToAnnounce, char)
                                                DebugOut("TIP", "Announcing tip '" .. tipToAnnounce.key .. "' via traveler " .. char.name)
                                                DisplayDialog { "ui/ui_character_generic.lua", char=char, text="#"..text }
                                                table.remove(Player.pendingAnnouncements, tipIndex)
                                                ResumeTravel()
                                                SoundEvent("travel_plane")
                                            end })
                                    else
                                        -- If there is no encounter, see if any "telegram" quests are ready
                                        for _,q in ipairs(_NoStarterQuests) do
                                            if q:IsEligible() then
                                                local quest = q
                                                table.insert(events, { time=eventTime, action=function()
                                                        SoundEvent("Stop_travel_plane")
                                                        PauseTravel()
                                                        quest:Offer()
                                                        ResumeTravel()
                                                        SoundEvent("travel_plane")
                                                    end })
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end -- End of the per-week event check

			-- Sort events by occurence time
			table.sort(events, function(a,b) return a.time < b.time end)
			
			-- Do the travel
--			SoundEvent("Stop_Music")	-- In preparation for airplane sound and for port sting
			SoundEvent("travel_plane")
			Player:SetPort(nil)
			InitiateTravel { dest=dest, time=route.time, type=route.type, path=route.path, events=events }
		end
	end
end

------------------------------------------------------------------------------
-- Sprites

--function Port:CreateSprite(t) table.insert(self.sprites, t) end

function OldCreateSprite(port, t)
	table.insert(port.sprites, t)
end

function CreateSprite(name, port)
	if type(name) == "table" then OldCreateSprite(name,port)
	else
		_G[name] = { image = "ports/"..port.name.."/"..name }
		table.insert(port.sprites, _G[name])
	end
end

------------------------------------------------------------------------------
-- Travel

function BaseTravelPrice()
	local multiplier = Floor(Player.time / 13)
--	multiplier = Pow(1.06, multiplier)			-- (1.06)^4 = 1.26  <-- 26% annual increase
	multiplier = Pow(1.1, multiplier)			-- (1.10)^4 = 1.46  <-- 46% annual increase
	local basePrice = Floor(450 * multiplier)
	if basePrice > 10000 then basePrice = 10000 end
	if Player.difficulty == 2 then -- Medium
        basePrice = Floor(basePrice * 1.5) -- 50% more expensive
    elseif Player.difficulty == 3 then -- Hard
        basePrice = Floor(basePrice * 2.0) -- 100% more expensive (doubled)
    end
	return basePrice
end

function PrepareTravelPrices()
	if Player.questVariables.ownplane == 1 then return end
	local basePrice = BaseTravelPrice()

	local playerPort = Player:GetPort()
	if playerPort then
		Player.portsCost = {}
		for name,port in pairs(_AllPorts) do
			if port == playerPort then continue end
			
			local route = playerPort:GetRoute(port)
			local price = route.time * basePrice
			price = Floor(price * RandRange(900,1000) / 1000 + 0.5)		-- Randomize 90-100% of full cost
			
			-- Give a discount on multi-week trips, 10% per week of travel
			if route.time > 1 then price = Floor(price * (1 - route.time * 0.1) + 0.5) end
			Player.portsCost[name] = price
		end
	end
end

function Port:DefineRoute(t)
	local destination = t[1]
	if type(destination) == "string" then destination = _AllPorts[destination] end
	local route = {
		time=t.time or 1,
		type=t.type or "travel_air",
		via=t.via,
		path=t.path
	}
	
	if type(route.type) == "string" then route.type = { {0,route.type} } end
	
	-- Default path: straight there
	if not t.path and not t.via then
		route.path = { {self.mapx,self.mapy},{self.mapx,self.mapy},{destination.mapx,destination.mapy},{destination.mapx,destination.mapy} }
	end
	
	-- TODO
	
	self.routes[destination.name] = route
end

local function MergeRoutes(t, toWaypoint, fromWaypoint)
	t.via = nil
	
	t.time = toWaypoint.time + fromWaypoint.time
	
	-- TODO: HOW TO MERGE TRAVEL MODES APPROPRIATELY?
	t.type = toWaypoint.type
	
	t.path = {}
	for i=1,table.getn(toWaypoint.path) do
		local p = toWaypoint.path[i]
		table.insert(t.path, {p[1],p[2]} )
	end
	for i=2,table.getn(fromWaypoint.path) do
		local p = fromWaypoint.path[i]
		table.insert(t.path, {p[1],p[2]} )
	end
end

function Port:GetRoute(destination)
	if Player.questVariables.ownplane == 1 then
		return { time=1, type={0,"travel_air"}, path={ {self.mapx,self.mapy},{self.mapx,self.mapy},{destination.mapx,destination.mapy},{destination.mapx,destination.mapy} } }
	end

	local t = self.routes[destination.name]
	if not t then
		local tRev = destination:GetRoute(self)
		if tRev then
			t = { time=tRev.time }

			-- Reverse the path and travel types
			if tRev.path then
				t.path = {}
				for i=table.getn(tRev.path),1,-1 do
					local p = tRev.path[i]
					table.insert(t.path, {p[1],p[2]} )
				end
			end
			if tRev.type then
				t.type = {}
				local q = { 1 }
				for i=table.getn(tRev.type),1,-1 do
					local p = tRev.type[i]
					table.insert(t.type, {1 - q[1],p[2]} )
					q = p
				end
			end
		else
			-- By default: straight-line, one-tick air trip
			t = { time=1, type={0,"travel_air"}, path={ {self.mapx,self.mapy},{self.mapx,self.mapy},{destination.mapx,destination.mapy},{destination.mapx,destination.mapy} } }
		end
		
		-- Cache it
		self.routes[destination.name] = t
	end

	-- Merge "via" routes on first use
	if t.via then
		local toWaypoint = self:GetRoute(t.via)
		local fromWaypoint = t.via:GetRoute(destination)
		MergeRoutes(t, toWaypoint, fromWaypoint)
		self.routes[destination.name] = t
	end
	
	return t
end