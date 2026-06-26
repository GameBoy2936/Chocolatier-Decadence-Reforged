--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Quest Log Detail View)
	Copyright (c) 2006-2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script renders the right-hand panel of the Quest Log, detailing the
-- specific summary text and required checklist goals.

-------------------------------------------------------------------------------
-- Character Portrait Resolution
-------------------------------------------------------------------------------

local starter = gDetailQuest:GetStarterName()
local ender = gDetailQuest:GetEnderName()

-------------------------------------------------------------------------------
-- Goal List Evaluation
-------------------------------------------------------------------------------

local showEnder = false
local goals = {}
local i = 0

-- Goal Checklists scale dynamically with difficulty.
-- Select the correct table reference based on the quest's locked-in difficulty state.
local difficulty = GetQuestDifficulty(gDetailQuest)
local goal_list = gDetailQuest.goals

if difficulty == 2 and gDetailQuest.goals_medium then
	goal_list = gDetailQuest.goals_medium
elseif difficulty == 3 and gDetailQuest.goals_hard then
	goal_list = gDetailQuest.goals_hard
end

-- Process the resolved goal list
for _, req in ipairs(goal_list) do
	local desc = req.Description and req:Description(gDetailQuest)
	if desc then table.insert(goals, req) end
	
	-- Check if any goal specifically requests displaying the recipient portrait
	if req.showEnder then showEnder = true end
end

-- Failsafe: Don't show the ender if it's identical to the starter (reduces clutter)
if showEnder and starter == ender then showEnder = false end

-------------------------------------------------------------------------------
-- Goal UI Construction
-------------------------------------------------------------------------------

local yTopGoal = 185
local goalDisplay = {}
local w = 417

-- Compress text width if we are rendering the recipient's portrait on the right
if showEnder then w = 317 end

for i, req in ipairs(goals) do
	local y = yTopGoal + (i - 1) * 36 - 15
	local desc = req:Description(gDetailQuest)
	local image = "image/indicatorlight_off"
	
	-- Determine progress indicator light status
	if gDetailQuest:IsComplete() then 
		image = "image/indicatorlight_green"
	elseif req.hint then 
		-- Invisible/hidden goals (used for behind-the-scenes tracking)
		image = "image/indicatorlight_blank"
	elseif req:Evaluate(gDetailQuest) then 
		-- Active goal successfully met
		image = "image/indicatorlight_green"
	end
	
	table.insert(goalDisplay, Bitmap { x = 3, y = y + 2 + 15, image = image })
	table.insert(goalDisplay, Text { x = 38, y = y, w = w, h = 36 + 30, label = "#" .. desc, flags = kVAlignCenter + kHAlignLeft })
end

-------------------------------------------------------------------------------
-- Character Portrait UI Construction
-------------------------------------------------------------------------------

local summaryX = 5
local summaryW = 445
local starterDisplay = {}

-- Retrieve starter identity, checking if it was a telegram (No physical starter)
local starterName = gDetailQuest:GetStarterName()
local isTelegram = gDetailQuest.forceTelegram

-- Only render the starter's portrait if they physically existed. 
-- Telegrams/Special Orders are remote and feature no initial starter avatar.
if starterName and not isTelegram then
	summaryX = 105
	summaryW = 345
	starterDisplay =
	{
		Bitmap { x = 0, y = 30 + 237 * 0.5, image = "image/character_name_badge", scale = 0.5,
			Text { x = 0, y = 0, w = 100, h = 21, label = "#" .. GetString(starterName), font = characterNameSmallFont, flags = kVAlignCenter + kHAlignCenter }
		},
		CharWindow { x = 3, y = 30, name = starterName, scale = 0.5 },
	}
end

local enderDisplay = {}
if showEnder then
	enderDisplay =
	{
		Bitmap { x = 355, y = yTopGoal + 237 * 0.5, image = "image/character_name_badge", scale = 0.5,
			Text { x = 0, y = 0, w = 100, h = 21, label = "#" .. GetString(ender), font = characterNameSmallFont, flags = kVAlignCenter + kHAlignCenter }
		},
		CharWindow { x = 358, y = yTopGoal, name = ender, scale = 0.5 },
	}
end

-------------------------------------------------------------------------------
-- Final Layout
-------------------------------------------------------------------------------

MakeDialog
{
	x = 0, y = 0, w = 455, h = 435,
	
	Group(starterDisplay),
	
	-- Summary Text Box
	SetStyle(C3CharacterDialogStyle),
	Text { x = summaryX, y = 40, w = summaryW, h = 190, name = "quest_summary", flags = kVAlignTop + kHAlignLeft },
	
	Group(enderDisplay),
	Group(goalDisplay),
}

-- ----------------------------------------------------------------------------
-- Final Summary Text Application
-- ----------------------------------------------------------------------------
-- Check if a custom, pre-generated offer text was cached for this quest. 
-- This is primarily used for in-person delivery quests to override the generic telegram format.
if Player.questOfferText[gDetailQuest.name] then
	summaryText = Player.questOfferText[gDetailQuest.name]
	DebugOut("UI", string.format("Quest Detail: Using pre-generated cached offer text for '%s'.", gDetailQuest.name))
else
	-- If no custom text exists, regenerate the intro text from scratch.
	-- This ensures that standard quests accurately reflect their difficulty-locked data.
	summaryText = gDetailQuest:GetIntro()
	DebugOut("UI", string.format("Quest Detail: Dynamically regenerating intro text for '%s'.", gDetailQuest.name))
end

SetLabel("quest_summary", summaryText)