--[[---------------------------------------------------------------------------
	Chocolatier Three: First Peek Analytics Helpers
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script serves as the wrapper for the "First Peek" telemetry system.
-- It transmits backend states (wealth, production volume, quest clearance) 
-- to a central analytics engine to track player progression over time.

function FirstPeekProgress()
	DebugOut("TELEMETRY", "Transmitting FirstPeek Progress checkpoint.")
	SetState("begin-status", "Progress")
	
	-- Global Player Status
	SetState("add-value", Player.time or 0)
	SetState("add-value", Player.money or 0)
	SetState("add-value", Player.factoriesOwned or 0)
	
	-- Category Completion States
	SetState("add-value", Player.categoryCount["bar"] or 0)
	SetState("add-value", Player.categoryMadeCount["bar"] or 0)
	SetState("add-value", Player.categoryCount["beverage"] or 0)
	SetState("add-value", Player.categoryMadeCount["beverage"] or 0)
	SetState("add-value", Player.categoryCount["infusion"] or 0)
	SetState("add-value", Player.categoryMadeCount["infusion"] or 0)
	SetState("add-value", Player.categoryCount["user"] or 0)
	SetState("add-value", Player.categoryMadeCount["user"] or 0)

	-- Factory Volume Yields
	if Player.factories.zur_factory then SetState("add-value", zur_factory:GetProduction()) else SetState("add-value", 0) end
	if Player.factories.cap_factory then SetState("add-value", cap_factory:GetProduction()) else SetState("add-value", 0) end
	if Player.factories.wel_factory then SetState("add-value", wel_factory:GetProduction()) else SetState("add-value", 0) end

	SetState("end-status", "Progress")
end

function FirstPeekRank()
	DebugOut("TELEMETRY", string.format("Transmitting FirstPeek Promotion checkpoint: Rank %d", Player.rank or 1))
	SetState("begin-status", "Promotion")
	SetState("add-value", Player.time or 0)
	SetState("add-value", Player.rank or 1)
	SetState("end-status", "Promotion")
end

function FirstPeekQuestComplete(q)
	local current = Player.time or 0
	local time_spent = Player.questsActive[q.name] or current
	time_spent = current - time_spent
	
	DebugOut("TELEMETRY", string.format("Transmitting FirstPeek Quest Completion: %s (Time to complete: %d weeks)", q.name, time_spent))
	SetState("begin-status", "QuestComplete")
	SetState("add-value", current)
	SetState("add-value", q.name)
	SetState("add-value", time_spent)
	SetState("end-status", "QuestComplete")
end

function FirstPeekTasteIt(category, ingredients)
	DebugOut("TELEMETRY", string.format("Transmitting FirstPeek Kitchen Evaluation for Category: %s", category))
	SetState("begin-status", "KitchenTasteIt")
	SetState("add-value", Player.time or 0)
	SetState("add-value", category)
	
	-- Pass the names of up to 6 custom ingredients
	for i = 1, 6 do
		if ingredients[i] then SetState("add-value", ingredients[i].name)
		else SetState("add-value", "")
		end
	end
	SetState("end-status", "KitchenTasteIt")
end

function FirstPeekCreate(category, ingredients, name)
	DebugOut("TELEMETRY", string.format("Transmitting FirstPeek Kitchen UGR Creation: %s", name))
	SetState("begin-status", "KitchenCreateIt")
	SetState("add-value", Player.time or 0)
	SetState("add-value", category)
	
	-- Pass the names of up to 6 custom ingredients
	for i = 1, 6 do
		if ingredients[i] then SetState("add-value", ingredients[i].name)
		else SetState("add-value", "")
		end
	end
	
	SetState("add-value", name)
	SetState("end-status", "KitchenCreateIt")
end

function FirstPeekNoMoney(quest, accepted)
	DebugOut("TELEMETRY", string.format("Transmitting FirstPeek Bankruptcy Trigger: %s (Accepted: %s)", quest.name, tostring(accepted)))
	SetState("begin-status", "OutOfMoney")
	SetState("add-value", Player.time or 0)
	SetState("add-value", quest.name)
	SetState("add-value", accepted)
	SetState("end-status", "OutOfMoney")
end