--[[---------------------------------------------------------------------------
	Chocolatier Three: Quest Log Detail
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Determine quest ender

-- TODO: How to deal with multiple enders here??
local starter = gDetailQuest:GetStarterName()
local ender = gDetailQuest:GetEnderName()

-------------------------------------------------------------------------------
-- Collect quest goals
-- Determine whether to show the quest ender if the quest hints at who to
-- find, and the ender is not the starter

local showEnder = false
local goals = {}
local i=0

-- Select the correct goal list based on the quest's locked-in difficulty
local difficulty = GetQuestDifficulty(gDetailQuest)
local goal_list = gDetailQuest.goals
if difficulty == 2 and gDetailQuest.goals_medium then
    goal_list = gDetailQuest.goals_medium
elseif difficulty == 3 and gDetailQuest.goals_hard then
    goal_list = gDetailQuest.goals_hard
end

for _,req in ipairs(goal_list) do
	local desc = req.Description and req:Description(gDetailQuest)
	if desc then table.insert(goals, req) end
	if req.showEnder then showEnder = true end
end
if showEnder and starter == ender then showEnder = false end

local yTopGoal = 185
local goalDisplay = {}
local w = 417
if showEnder then w = 317 end
for i,req in ipairs(goals) do
	local y = yTopGoal + (i - 1) * 36 - 15
	local desc = req:Description(gDetailQuest)
	local image = "image/indicatorlight_off"
	if gDetailQuest:IsComplete() then image = "image/indicatorlight_green"
	elseif req.hint then image = "image/indicatorlight_blank"
	elseif req:Evaluate(gDetailQuest) then image = "image/indicatorlight_green"
	end
	table.insert(goalDisplay, Bitmap { x=3,y=y+2+15, image=image })
	table.insert(goalDisplay, Text { x=38,y=y, w=w,h=36+30, label="#"..desc, flags=kVAlignCenter+kHAlignLeft })
end

local summaryX = 5
local summaryW = 445
local starterDisplay = {}

-- Get the starter name using the proper function, which handles all cases (active, completed, telegram).
local starterName = gDetailQuest:GetStarterName()

if starterName then
    -- If a starter exists, adjust the layout and create the display.
	summaryX = 105
	summaryW = 345
	starterDisplay =
	{
		Bitmap { x=0,y=30+237*.5, image="image/character_name_badge", scale=.5,
			Text { x=0,y=0,w=100,h=21, label="#"..GetString(starterName), font=characterNameSmallFont, flags=kVAlignCenter+kHAlignCenter}
		},
		CharWindow { x=6,y=30, name=starterName, scale=.5 },
	}
end

local enderDisplay = {}
if showEnder then
	enderDisplay =
	{
		Bitmap { x=355,y=yTopGoal+237*.5, image="image/character_name_badge", scale=.5,
			Text { x=0,y=0,w=100,h=21, label="#"..GetString(ender), font=characterNameSmallFont, flags=kVAlignCenter+kHAlignCenter}
		},
		CharWindow { x=360,y=yTopGoal, name=ender, scale=.5 },
	}
end

-------------------------------------------------------------------------------

MakeDialog
{
	x=0,y=0,w=455,h=435,
	
	-- Quest Ender
	Group(starterDisplay),
	
	-- Summary
	SetStyle(C3CharacterDialogStyle),
	Text { x=summaryX,y=40, w=summaryW,h=190, name="quest_summary", flags=kVAlignTop+kHAlignLeft },
	
	-- Goals
	Group(enderDisplay),
	Group(goalDisplay),
}

-- Check if a custom offer text was saved for this quest. This is primarily
-- used for in-person delivery quest offers to override the generic telegram format.
if Player.questOfferText[gDetailQuest.name] then
    -- If it exists, use it. It has already been parsed for difficulty.
    summaryText = Player.questOfferText[gDetailQuest.name]
    DebugOut("UI", "Quest Detail: Using pre-generated offer text for '" .. gDetailQuest.name .. "'.")
else
    -- If no custom text exists, regenerate the intro text from scratch.
    -- This ensures that for all standard quests viewed in the log, the text
    -- is generated using the quest's locked-in difficulty.
    summaryText = gDetailQuest:GetIntro()
    DebugOut("UI", "Quest Detail: Regenerating intro text for '" .. gDetailQuest.name .. "'.")
end

-- Set the label with the determined text.
SetLabel("quest_summary", summaryText)