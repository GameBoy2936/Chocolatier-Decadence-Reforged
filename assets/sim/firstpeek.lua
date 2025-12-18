--[[---------------------------------------------------------------------------
	Chocolatier Three: First Peek Helpers
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

function FirstPeekProgress()
	SetState("begin-status", "Progress")
	SetState("add-value", Player.time or 0)
	SetState("add-value", Player.money or 0)
	SetState("add-value", Player.factoriesOwned or 0)
	SetState("add-value", Player.categoryCount["bar"] or 0)
	SetState("add-value", Player.categoryMadeCount["bar"] or 0)
	SetState("add-value", Player.categoryCount["beverage"] or 0)
	SetState("add-value", Player.categoryMadeCount["beverage"] or 0)
	SetState("add-value", Player.categoryCount["infusion"] or 0)
	SetState("add-value", Player.categoryMadeCount["infusion"] or 0)
	SetState("add-value", Player.categoryCount["user"] or 0)
	SetState("add-value", Player.categoryMadeCount["user"] or 0)

	if Player.factories.zur_factory then SetState("add-value", zur_factory:GetProduction())
	else SetState("add-value", 0)
	end

	if Player.factories.cap_factory then SetState("add-value", cap_factory:GetProduction())
	else SetState("add-value", 0)
	end

	if Player.factories.wel_factory then SetState("add-value", wel_factory:GetProduction())
	else SetState("add-value", 0)
	end

	SetState("end-status", "Progress")
end

function FirstPeekRank()
	SetState("begin-status", "Promotion")
	SetState("add-value", Player.time or 0)
	SetState("add-value", Player.rank or 1)
	SetState("end-status", "Promotion")
end

function FirstPeekQuestComplete(q)
	local current = Player.time or 0
	local time = Player.questsActive[q.name] or current
	time = current - time
	
	SetState("begin-status", "QuestComplete")
	SetState("add-value", current)
	SetState("add-value", q.name)
	SetState("add-value", time)
	SetState("end-status", "QuestComplete")
end

function FirstPeekTasteIt(category, ingredients)
	SetState("begin-status", "KitchenTasteIt")
	SetState("add-value", Player.time or 0)
	SetState("add-value", category)
	for i=1,6 do
		if ingredients[i] then SetState("add-value", ingredients[i].name)
		else SetState("add-value", "")
		end
	end
	SetState("end-status", "KitchenTasteIt")
end

function FirstPeekCreate(category, ingredients, name)
	SetState("begin-status", "KitchenCreateIt")
	SetState("add-value", Player.time or 0)
	SetState("add-value", category)
	for i=1,6 do
		if ingredients[i] then SetState("add-value", ingredients[i].name)
		else SetState("add-value", "")
		end
	end
	SetState("add-value", name)
	SetState("end-status", "KitchenCreateIt")
end

function FirstPeekNoMoney(quest, accepted)
	SetState("begin-status", "OutOfMoney")
	SetState("add-value", Player.time or 0)
	SetState("add-value", quest.name)
	SetState("add-value", accepted)
	SetState("end-status", "OutOfMoney")
end
