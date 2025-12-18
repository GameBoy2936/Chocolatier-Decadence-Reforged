--[[---------------------------------------------------------------------------
	Chocolatier Three Quest Log
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

gDetailQuest = nil
local quests = {}
local topQuest = 1
local selectQuest = 1

local function PopulateQuests()
	for i=1,10 do
		local q = quests[topQuest + i - 1]
		if q then
			local button = "quest"..i
			SetLayeredLabel(button, q:GetTitle())
			EnableWindow(button, true)
			SetButtonToggleState(button, q == gDetailQuest)
		else
			EnableWindow("quest"..i, false)
		end
	end
	
	EnableWindow("scrollUp", topQuest > 1)
	EnableWindow("scrollDown", topQuest + 10 < table.getn(quests))
end

local function GatherQuests()
	quests = {}
	topQuest = 1
	
	-- Gather active quests at the top, sorted by least recently accepted
	for name,time in pairs(Player.questsActive) do
		local quest = _AllQuests[name]
		if quest.visible then table.insert(quests, quest) end
	end
	table.sort(quests, function(q1,q2) return Player.questsActive[q1.name] < Player.questsActive[q2.name] end)
	
	-- Gather completed quests below, sorted by most recently completed
	if Player.options.showCompletedQuests then
		local active = quests
		quests = {}
		for name,time in pairs(Player.questsComplete) do
			local quest = _AllQuests[name]
			if not quest then DebugOut("QUEST UNDEFINED - "..tostring(name))
			elseif quest.visible and (not quest.delivery) then table.insert(quests, quest)
			end
		end
		table.sort(quests, function(q1,q2) return Player.questsComplete[q1.name] > Player.questsComplete[q2.name] end)
		
		-- Insert the active quests at the top of the list since it's likely to be the shorter table
		for i=table.getn(active),1,-1 do
			table.insert(quests, 1, active[i])
		end
	end
	
	PopulateQuests()
end

local function ShowQuestDetail()
	if gDetailQuest then FillWindow("quest_detail", "ui/quest_detail.lua")
	else
		FillWindow("quest_detail", "ui/quest_none.lua")
	end
end

-------------------------------------------------------------------------------

local function ScrollUp()
	topQuest = topQuest - 1
	PopulateQuests()
end

local function ScrollDown()
	topQuest = topQuest + 1
	PopulateQuests()
end

local function ToggleCompleted()
	Player.options.showCompletedQuests = not Player.options.showCompletedQuests
	if not Player.options.showCompletedQuests then
		if Player.questPrimary then
			gDetailQuest = _AllQuests[Player.questPrimary]
			ShowQuestDetail()
		end
	end
	GatherQuests()
end

-------------------------------------------------------------------------------

local function SelectQuest(n)
	gDetailQuest = quests[topQuest + n]
	ShowQuestDetail()
	if gDetailQuest:IsActive() then Player:SetPrimaryQuest(gDetailQuest.name) end
end

--local QuestSelectButton = Button
C3QuestSelectButtonStyle =
{
	type=kRadio,
	graphics = {"image/button_quest_title_up","image/button_quest_title_selected","image/button_quest_title_over","image/button_quest_title_selected"},
}

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=9, name="questlog", fit=true,
		Bitmap
		{
			x=5,y=13,image="image/popup_back_quests",
			
			Window
			{
				name="quest_detail", x=309,y=12,w=455,h=435,
			},
			
			BeginGroup(),
			AppendStyle(C3QuestSelectButtonStyle),
			QuestSelectButton { x=0,y=59, name="quest1", label="#quest1", command=function() SelectQuest(0) end },
			QuestSelectButton { x=0,y=89, name="quest2", label="#quest2", command=function() SelectQuest(1) end },
			QuestSelectButton { x=0,y=119, name="quest3", label="#quest3", command=function() SelectQuest(2) end },
			QuestSelectButton { x=0,y=149, name="quest4", label="#quest4", command=function() SelectQuest(3) end },
			QuestSelectButton { x=0,y=179, name="quest5", label="#quest5", command=function() SelectQuest(4) end },
			QuestSelectButton { x=0,y=209, name="quest6", label="#quest6", command=function() SelectQuest(5) end },
			QuestSelectButton { x=0,y=239, name="quest7", label="#quest7", command=function() SelectQuest(6) end },
			QuestSelectButton { x=0,y=269, name="quest8", label="#quest8", command=function() SelectQuest(7) end },
			QuestSelectButton { x=0,y=299, name="quest9", label="#quest9", command=function() SelectQuest(8) end },
			QuestSelectButton { x=0,y=329, name="quest10", label="#quest10", command=function() SelectQuest(9) end },
			
			SetStyle(C3ButtonStyle),
			BeginGroup(),
			Button { x=100,y=19, name="scrollUp", command=ScrollUp, graphics={"image/button_arrow_up_up","image/button_arrow_up_down","image/button_arrow_up_over"} },
			Button { x=100,y=360, name="scrollDown", command=ScrollDown, graphics={"image/button_arrow_down_up","image/button_arrow_down_down","image/button_arrow_down_over"} },

			SetStyle(C3SmallRoundButtonStyle),
			BeginGroup(),
--			Button { x=109,y=334, name="showCompleted", type=kToggle, label="finished_quests", command=ToggleCompleted },
			Button { x=30,y=375, name="showCompleted", type=kToggle, command=ToggleCompleted },
			Text { x=90,y=370,h=85,w=215, label="#"..GetString"finished_quests", flags=kVAlignCenter+kHAlignLeft },
		},
		Bitmap { image="image/popup_nameplate", x=223,y=0,
			Text { x=34,y=10,w=270,h=38, label="#"..GetString"title_quests", font=nameplateFont, flags=kVAlignCenter+kHAlignCenter },
		},
		
		SetStyle(C3RoundButtonStyle),
		Button { x=704,y=426, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("questlog", "ok") end },
		Button { x=734,y=381, name="help", label="#?", command=function() HelpDialog("help_quests") end },
	},
}

if Player.questPrimary then gDetailQuest = _AllQuests[Player.questPrimary] end
GatherQuests()
SetButtonToggleState("showCompleted", Player.options.showCompletedQuests or false)
ShowQuestDetail()
CenterFadeIn("questlog")
