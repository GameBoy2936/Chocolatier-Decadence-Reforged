--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Port Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Port" is a destination in the world map. This class handles location 
-- metadata, travel routing, event generation during transit, and pricing.

Port =
{
	-- ==========================================
	-- Core Identity & State
	-- ==========================================
	datafile = nil,			-- Name of the data file containing the original port definition
	name = nil,				-- Internal key name of the port (e.g., "zurich")
	hidden = false,			-- TRUE if this port is normally hidden from the map
	locked = false,			-- TRUE if this port is visible but initially locked
	
	-- ==========================================
	-- Visuals & Geography
	-- ==========================================
	sprites = {},			-- Table of visual sprites rendered when inside the port
	routes = nil,			-- Table of calculated routes to other ports
	
	hemisphere = nil,		-- "north" or "south" - determines seasonal ingredient patterns
	region = nil,    		-- Area in the world, e.g., "europe", "north_america"
	country = nil,    		-- Country of the port, e.g., "switzerland", "indonesia"
	culture = "western",	-- Cultural zone for holiday observance (western, muslim, east_asian, etc.)
}

-- Metamethod for clean debug printing of Port objects
Port.__tostring = function(t) return "{Port:" .. tostring(t.name) .. "}" end

-- Global registry of all initialized ports
_AllPorts = {}

------------------------------------------------------------------------------
-- Player-Specific Accessors
------------------------------------------------------------------------------

-- Returns true if the port is fully accessible to the player
function Port:IsAvailable()
	-- A port is available if its state is neither "locked" nor "hidden"
	return (Player.portsAvailable[self.name] ~= "locked" and Player.portsAvailable[self.name] ~= "hidden")
end

-- Unlocks the port for the player, revealing it on the map and allowing travel
function Port:Unlock()
	if not self:IsAvailable() then
		DebugOut("PORT", string.format("Port unlocked for travel: %s", self.name))
		Player.portsAvailable[self.name] = "new"
	end
end

-- Forcibly locks a port, preventing the player from traveling there
function Port:Lock()
	if self:IsAvailable() then 
		DebugOut("PORT", string.format("Port locked: %s", self.name)) 
	end
	Player.portsAvailable[self.name] = "locked"
end

-- Calculates the cost to travel to this port from the player's current location
function Port:TravelCost()
	-- If the player owns the private plane (quest variable), travel is always free
	if Player.questVariables.ownplane == 1 then 
		return 0
	else 
		return Player.portsCost[self.name] or 0
	end
end

------------------------------------------------------------------------------
-- Creation & Loading Utilities
------------------------------------------------------------------------------

-- Factory method: Creates or redefines a port object
function Port:Create(name)
	local t = nil
	if not name then
		DebugOut("ERROR", "Attempted to create a Port with no name.")
	else
		if _AllPorts[name] then
			DebugOut("LOAD", string.format("Redefining existing port during hot-reload: %s", name))
		elseif _G[name] then
			DebugOut("WARNING", string.format("Global variable conflict: '%s' already exists.", name))
		else
			-- Log the successful initial creation of the port
			DebugOut("LOAD", string.format("Created port definition: %s", name))
		end
		
		t = _AllPorts[name] or {}
		
		-- Bind the Port class metatable
		setmetatable(t, self) 
		self.__index = self
		
		-- Register globally
		_AllPorts[name] = t
		_G[name] = t
		
		-- Initialize default nested tables
		t.name = name
		t.cadikey = t.cadikey or name
		t.buildings = {}
		t.sprites = {}
		
		-- Keep route table persistent when re-defining the port at runtime (for dev reloading)
		t.routes = t.routes or {}
	end
	return t
end

-- Global wrapper for Port:Create
function CreatePort(name) 
	return Port:Create(name) 
end

-- Executes the load sequence for all defined port data files
function LoadPorts()
	DebugOut("LOAD", "Initiating port data payload execution.")
	local t = {}
	
	-- Engine call to populate 't' with a list of valid port script paths
	LoadPortFileList(t)
	
	for _, fileName in ipairs(t) do
		dofile(fileName)
	end
end

------------------------------------------------------------------------------
-- UI: Rollover and Click Management
------------------------------------------------------------------------------

-- Generates the tooltip dialog when hovering over a port on the world map
function Port:MapRolloverPopup()
	-- Suppress tooltips if we are currently mid-flight
	if gTravelActive then return nil end

	local label = {}
	
	if self:IsAvailable() then
		if Player.portName == self.name then 
			table.insert(label, GetString("trip_here"))
		else
			local origin = Player:GetPort()
			if origin then
				-- Display travel duration
				local route = origin:GetRoute(self)
				local time = route.time
				if time == 1 then 
					table.insert(label, GetString("trip_time_single"))
				else 
					table.insert(label, GetText("trip_time", tostring(time)))
				end
			end

			-- Display travel cost
			local cost = self:TravelCost()
			if cost == 0 then
				table.insert(label, GetString("trip_free"))
			else
				table.insert(label, GetText("trip_cost", Dollars(cost)))
				-- Warn the player if they lack the funds
				if Player.money < cost then 
					table.insert(label, GetText("trip_expensive", Dollars(cost))) 
				end
			end
		end
	else
		-- Port is visible but locked
		table.insert(label, GetString("trip_locked"))
	end
	
	label = "#" .. table.concat(label, "\n")
	
	-- Construct and return the dialog UI element
	return MakeDialog
	{
		Bitmap
		{
			x = 0, y = 0, image = "image/traveltag", fit = true,
			Text { x = 0, y = 2, w = kMax, h = 25, label = "#" .. GetString(self.name), font = portNameRolloverFont, flags = kVAlignCenter + kHAlignCenter },
			Text { x = 24, y = 25, w = 201, h = 40, label = label, font = rolloverInfoFont, flags = kVAlignTop + kHAlignCenter }
		}
	}
end

-- Handles the logic for physically entering the port environment
function Port:EnterPort(sting)
	DebugOut("PORT", string.format("Player has entered port: %s", self.name))
	Player:SetPort(self.name)
	ReleaseLedger()
	SwapToModal("ui/portview.lua")
	
	-- Always play the ambient sound associated with the port's main cadikey
	SoundEvent(self.cadikey)

	-- If transitioning from travel, play the musical sting
	if sting then
		local musicEvent
		if self.music_key then
			musicEvent = self.music_key
		else
			musicEvent = self.cadikey .. "_sting"
		end
		
		-- Ensure the event name correctly ends with the "_sting" suffix
		if string.sub(musicEvent, -6) ~= "_sting" then
			musicEvent = musicEvent .. "_sting"
		end
		
		SoundEvent(musicEvent)
	end
end

-- Handles the logic when a player clicks a destination port on the world map
function Port:OnClick()
	-- Ignore clicks if we are already traveling
	if gTravelActive then return end

	if self.name == Player.portName then
		-- Clicking the current port just enters it immediately
		self:EnterPort()
	elseif self:IsAvailable() then
		local cost = self:TravelCost()
		if Player.money < cost then
			-- TODO: Play negative error sound or warning animation
			DebugOut("TRAVEL", string.format("Travel to %s rejected: Insufficient funds.", self.name))
		else
			gTravelActive = true
			
			local origin = Player:GetPort()
			local route = origin:GetRoute(self)
		
			DebugOut("TRAVEL", string.format("Travel initiated from %s to %s. Duration: %d week(s). Cost: %s", origin.name, self.name, route.time, Dollars(cost)))

			-- Deduct travel cost and set course
			Player:SubtractMoney(cost)
			Player.destination = self.name
		
			local dest = self
			local path = nil -- TODO: Determine dynamic paths/icons if implementing custom route visuals
			
			-- Real-time duration: 3000ms (3 seconds) per in-game week of travel
			local weeks = (route.time or 1)
			local duration = weeks * 3000
			
			-- Build the queue of events to fire at specific timestamps during the trip
			local events = {}

			-- 1. Schedule simulation ticks (1 tick per week of travel)
			for i = 1, weeks do
				table.insert(events, { 
					time = (i - 1) * 3000 + 1, 
					action = function() 
						PauseTravel() 
						TickSim(1) 
						ResumeTravel() 
					end 
				})
			end

			-- 2. Schedule final arrival event
			table.insert(events, { 
				time = duration, 
				action = function() 
					SoundEvent("Stop_travel_plane")
					dest:EnterPort(true)
					gTravelActive = false 
				end 
			})
			
			-- 3. Interruption Event Generators
			-- Tracking tables to prevent duplicate events firing during a single trip
			local tripScheduledHints = {}
			local tripScheduledTips = {}

			-- Evaluate potential interruptions for each week of the flight
			for i = 1, weeks do
				-- Calculate a random time within this specific week's 3-second animation window
				local eventTime = (i - 1) * 3000 + RandRange(1000, 2500)
				local travelers = _AllBuildings["_travelers"]
				local encounter = false
				local highPriorityEventScheduled = false
				
				-- CHECK A: Timer-forced or random encounters (Bandits, random events, etc.)
				if Player.rank > 1 then
					if Player.encounterTimer <= 1 then
						Player.encounterTimer = 0
						encounter = true
						DebugOut("EVENT", string.format("Encounter forced by timer during travel week %d.", i))
					else
						Player.encounterTimer = Player.encounterTimer - 1
						local encounterRoll = RandRange(1, 100)
						if encounterRoll <= 12 then 
							encounter = true 
							DebugOut("EVENT", string.format("Random travel encounter triggered during travel week %d (Rolled %d/100).", i, encounterRoll))
						end
					end
				end
				
				-- CHECK B: Forced encounters for completed traveler quests
				if not encounter then
					local quests = travelers:FindQuestsEnding()
					if quests and table.getn(quests) > 0 then
						for _, qt in ipairs(quests) do
							if qt.quest:AreGoalsMet() and not qt.quest:IsComplete() then
								-- Verify the quest ender is actually in the travel pool and not placed in a building
								local enderChar = qt.char
								local isPlacedInBuilding = false
								for buildingName, charList in pairs(Player.buildingCharacters) do
									if buildingName ~= "_travelers" and buildingName ~= "_empty" then
										if charList[enderChar.name] then
											isPlacedInBuilding = true
											DebugOut("EVENT", string.format("Skipping encounter for '%s': Ender '%s' is placed in building '%s'.", qt.quest.name, enderChar.name, buildingName))
											break
										end
									end
								end

								if not isPlacedInBuilding then
									encounter = true
									DebugOut("EVENT", string.format("Encounter forced by completed traveler quest during week %d: %s", i, qt.quest.name))
									break
								end
							end
						end
					end
				end
				
				-- CHECK C: Forced encounters for Priority 1 traveler quests
				if not encounter then
					local quests = travelers:FindQuestsStarting(1)
					if quests and table.getn(quests) > 0 then
						encounter = true
						DebugOut("EVENT", string.format("Encounter forced by high-priority traveler quest during week %d: %s", i, quests[1].quest.name))
					end
				end
				
				-- CHECK D: Forced encounters for expired traveler quests (Failure states)
				if not encounter then
					for name, _ in pairs(Player.questsActive) do
						local quest = _AllQuests[name]
						if quest:IsExpired() then
							local enderChar = quest:GetEnder()
							local isPlacedInBuilding = false
							
							if enderChar then
								for buildingName, charList in pairs(Player.buildingCharacters) do
									if buildingName ~= "_travelers" and buildingName ~= "_empty" then
										if charList[enderChar.name] then
											isPlacedInBuilding = true
											DebugOut("EVENT", string.format("Skipping expired quest encounter for '%s': Ender '%s' is placed in building '%s'.", quest.name, enderChar.name, buildingName))
											break
										end
									end
								end
							end

							if not isPlacedInBuilding then
								encounter = true
								DebugOut("EVENT", string.format("Encounter forced by expired quest during week %d: %s", i, name))
								break
							end
						end
					end
				end

				-- ACTION: If an encounter was triggered, schedule it and skip checking lower-priority events for this week
				if encounter then
					-- Reset the timer so we don't get spammed immediately
					Player.encounterTimer = 10
					highPriorityEventScheduled = true
					
					table.insert(events, { 
						time = eventTime, 
						action = function()
							SoundEvent("Stop_travel_plane")
							PauseTravel()
							-- Resolve the encounter. If it was an expiration, HandleQuestExpiration returns true.
							local somethingHappened = travelers:HandleQuestExpiration()
							if not somethingHappened then
								travelers:OnClick()
							end
							ResumeTravel()
							SoundEvent("travel_plane")
						end 
					})
				else
					-- No major encounters. Check secondary events (Medals, Telegrams, Hints, Tips)
					if not highPriorityEventScheduled then
						
						-- Secondary A: Medal Awards
						local medal = Player:CheckMedals()
						if medal then
							table.insert(events, { 
								time = eventTime, 
								action = function()
									SoundEvent("Stop_travel_plane")
									PauseTravel()
									Player:AwardMedal(medal)
									ResumeTravel()
									SoundEvent("travel_plane")
								end 
							})
						else
							-- Secondary B: Special Delivery Telegrams
							local orderQuest = nil
							if Player.pendingSpecialOrders and table.getn(Player.pendingSpecialOrders) > 0 then
								local first_order_data = Player.pendingSpecialOrders[1]
								
								-- Check if the order cutoff time has been breached by this travel week
								if Player.time + i > first_order_data.earlyOfferCutoff then
									first_order_data.forceTelegram = true
									orderQuest = CreateDeliveryQuest(first_order_data, first_order_data.isResident, first_order_data.sourcePool)
									table.remove(Player.pendingSpecialOrders, 1)
								end
							end

							if orderQuest then 
								table.insert(events, { 
									time = eventTime, 
									action = function()
										SoundEvent("Stop_travel_plane")
										PauseTravel()
										orderQuest:Offer()
										ResumeTravel()
										SoundEvent("travel_plane")
									end 
								})
							else
								-- Secondary C: Quest Hints
								local hintToDeliver = nil
								for questName, _ in pairs(Player.questsActive) do
									local quest = _AllQuests[questName]
									
									if quest and quest:IsHintEligible() and not tripScheduledHints[questName] then
										hintToDeliver = quest
										break
									end
								end

								if hintToDeliver then
									tripScheduledHints[hintToDeliver.name] = true
									
									table.insert(events, { 
										time = eventTime, 
										action = function()
											SoundEvent("Stop_travel_plane")
											PauseTravel()
											
											local char = travelers:RandomCharacter()
											local attempts = 0
											
											-- Re-roll up to 10 times to prevent evil characters from delivering helpful hints
											while char and Tips.evilCharacters[char.name] and attempts < 10 do
												char = travelers:RandomCharacter()
												attempts = attempts + 1
											end

											if char and not Tips.evilCharacters[char.name] then
												local hintText = hintToDeliver:GetHint()
												DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. hintText }
												
												-- Set cooldown relative to the exact week the hint was delivered
												Player.questHintCooldowns[hintToDeliver.name] = Player.time + i + 8
											else
												DebugOut("ERROR", "Could not find an eligible traveler to deliver hint for: " .. hintToDeliver.name)
											end

											ResumeTravel()
											SoundEvent("travel_plane")
										end 
									})
								else
									-- Secondary D: Tutorial Tips
									local tipToAnnounce = nil
									local tipIndex = nil
									
									if Player.pendingAnnouncements and table.getn(Player.pendingAnnouncements) > 0 then
										local char = travelers:RandomCharacter()
										if char then
											for j, tip in ipairs(Player.pendingAnnouncements) do
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
										table.insert(events, { 
											time = eventTime, 
											action = function()
												SoundEvent("Stop_travel_plane")
												PauseTravel()
												
												local char = travelers:RandomCharacter()
												local text = Tips.GetDynamicTipString(tipToAnnounce, char)
												
												DebugOut("TIP", string.format("Announcing tip '%s' via traveler %s", tipToAnnounce.key, char.name))
												DisplayDialog { "ui/ui_character_generic.lua", char = char, text = "#" .. text }
												
												table.remove(Player.pendingAnnouncements, tipIndex)
												
												ResumeTravel()
												SoundEvent("travel_plane")
											end 
										})
									else
										-- Secondary E: Automatic "Telegram" Quests (No physical starter NPC required)
										for _, q in ipairs(_NoStarterQuests) do
											if q:IsEligible() then
												local quest = q
												table.insert(events, { 
													time = eventTime, 
													action = function()
														SoundEvent("Stop_travel_plane")
														PauseTravel()
														quest:Offer()
														ResumeTravel()
														SoundEvent("travel_plane")
													end 
												})
												break
											end
										end
									end
								end
							end
						end
					end
				end
			end -- End of per-week event evaluations

			-- Sort the final event queue chronologically
			table.sort(events, function(a, b) return a.time < b.time end)
			
			-- Execute Travel Action
			SoundEvent("travel_plane")
			Player:SetPort(nil)
			InitiateTravel { dest = dest, time = route.time, type = route.type, path = route.path, events = events }
		end
	end
end

------------------------------------------------------------------------------
-- Sprite Generation
------------------------------------------------------------------------------

-- Legacy wrapper for creating port sprites (Maintained for backwards compatibility)
function OldCreateSprite(port, t)
	table.insert(port.sprites, t)
end

-- Generates and maps a background sprite to a specific port
function CreateSprite(name, port)
	if type(name) == "table" then 
		OldCreateSprite(name, port)
	else
		_G[name] = { image = "ports/" .. port.name .. "/" .. name }
		table.insert(port.sprites, _G[name])
	end
end

------------------------------------------------------------------------------
-- Travel Math & Routes
------------------------------------------------------------------------------

-- Computes the baseline cost of travel, which inflates globally as the game progresses
function BaseTravelPrice()
	local multiplier = Floor(Player.time / 13)
	
	-- Base inflation rate: 10% per quarter, resulting in a ~46% annual increase
	multiplier = Pow(1.1, multiplier)			
	local basePrice = Floor(450 * multiplier)
	
	-- Hard cap at $10,000 to prevent runaway late-game economies
	if basePrice > 10000 then basePrice = 10000 end
	
	-- Apply difficulty modifiers
	if Player.difficulty == 2 then 
		basePrice = Floor(basePrice * 1.5) -- Medium: 50% more expensive
	elseif Player.difficulty == 3 then 
		basePrice = Floor(basePrice * 2.0) -- Hard: 100% more expensive
	end
	
	return basePrice
end

-- Caches the travel prices from the current port to all other available ports
function PrepareTravelPrices()
	if Player.questVariables.ownplane == 1 then return end
	
	DebugOut("ECONOMY", "Recalculating global travel route prices.")
	local basePrice = BaseTravelPrice()

	local playerPort = Player:GetPort()
	if playerPort then
		Player.portsCost = {}
		
		for name, port in pairs(_AllPorts) do
			if port == playerPort then continue end
			
			local route = playerPort:GetRoute(port)
			local price = route.time * basePrice
			
			-- Randomize the final cost between 90% and 100% of the computed price
			price = Floor(price * RandRange(900, 1000) / 1000 + 0.5)		
			
			-- Apply a bulk travel discount: 10% off per week of uninterrupted travel length
			if route.time > 1 then 
				price = Floor(price * (1 - route.time * 0.1) + 0.5) 
			end
			
			Player.portsCost[name] = price
		end
	end
end

-- Statically defines a route between two ports (usually invoked by data scripts)
function Port:DefineRoute(t)
	local destination = t[1]
	if type(destination) == "string" then destination = _AllPorts[destination] end
	
	-- Safety check to prevent fatal nil indexing
	if not destination then
		DebugOut("ERROR", string.format("Attempted to define a route to an unknown port: '%s'. Skipping route.", tostring(t[1])))
		return
	end
	
	-- Resolve the via waypoint into an object, if it exists
	local viaPort = t.via
	if type(viaPort) == "string" then viaPort = _AllPorts[viaPort] end
	
	if t.via and not viaPort then
		DebugOut("ERROR", string.format("Route defines an unknown 'via' waypoint: '%s'. Removing waypoint.", tostring(t.via)))
	end

	local route = {
		time = t.time or 1,
		type = t.type or "travel_air",
		via = viaPort, -- Use the resolved object
		path = t.path
	}
	
	if type(route.type) == "string" then 
		route.type = { { 0, route.type } } 
	end
	
	-- If no visual path is supplied, default to a straight line
	if not t.path and not t.via then
		route.path = { 
			{ self.mapx, self.mapy }, { self.mapx, self.mapy }, 
			{ destination.mapx, destination.mapy }, { destination.mapx, destination.mapy } 
		}
	end
	
	self.routes[destination.name] = route
end

-- Helper: Combines two segments into a single continuous route (e.g., A -> B -> C)
local function MergeRoutes(t, toWaypoint, fromWaypoint)
	t.via = nil
	t.time = toWaypoint.time + fromWaypoint.time
	
	-- TODO: Handle visual merging of different travel modes gracefully
	t.type = toWaypoint.type
	
	-- Splice the coordinate paths together
	t.path = {}
	for i = 1, table.getn(toWaypoint.path) do
		local p = toWaypoint.path[i]
		table.insert(t.path, { p[1], p[2] })
	end
	
	for i = 2, table.getn(fromWaypoint.path) do
		local p = fromWaypoint.path[i]
		table.insert(t.path, { p[1], p[2] })
	end
end

-- Resolves and returns the travel parameters required to reach a target destination
function Port:GetRoute(destination)
	-- VIP overriding: Private plane allows instant 1-week travel anywhere in a straight line
	if Player.questVariables.ownplane == 1 then
		return { 
			time = 1, 
			type = { { 0, "travel_air" } }, 
			path = { 
				{ self.mapx, self.mapy }, { self.mapx, self.mapy }, 
				{ destination.mapx, destination.mapy }, { destination.mapx, destination.mapy } 
			} 
		}
	end

	-- Attempt to load a pre-cached route
	local t = self.routes[destination.name]
	
	if not t then
		-- If a forward route doesn't exist, check if a reverse route exists and invert it
		local tRev = destination:GetRoute(self)
		
		if tRev then
			t = { time = tRev.time }

			-- Physically reverse the path coordinates
			if tRev.path then
				t.path = {}
				for i = table.getn(tRev.path), 1, -1 do
					local p = tRev.path[i]
					table.insert(t.path, { p[1], p[2] })
				end
			end
			
			-- Reverse the animation sequence types
			if tRev.type then
				t.type = {}
				local q = { 1 }
				for i = table.getn(tRev.type), 1, -1 do
					local p = tRev.type[i]
					table.insert(t.type, { 1 - q[1], p[2] })
					q = p
				end
			end
		else
			-- Fallback: If no route exists at all, generate a default straight-line 1-week flight
			t = { 
				time = 1, 
				type = { { 0, "travel_air" } }, 
				path = { 
					{ self.mapx, self.mapy }, { self.mapx, self.mapy }, 
					{ destination.mapx, destination.mapy }, { destination.mapx, destination.mapy } 
				} 
			}
		end
		
		-- Cache the newly resolved route
		self.routes[destination.name] = t
		DebugOut("TRAVEL", string.format("Generated and cached new travel route from %s to %s.", self.name, destination.name))
	end

	-- If this route utilizes a waypoint ("via"), merge the paths on first access
	if t.via then
		local toWaypoint = self:GetRoute(t.via)
		local fromWaypoint = t.via:GetRoute(destination)
		MergeRoutes(t, toWaypoint, fromWaypoint)
		
		-- Update the cache with the fully resolved merged route
		self.routes[destination.name] = t
	end
	
	return t
end