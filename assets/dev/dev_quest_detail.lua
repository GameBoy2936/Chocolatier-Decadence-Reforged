--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Quest Detail
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local q = gDialogTable.quest

local function DoComplete()
	DebugOut("DEV", "Force completing quest: " .. q.name)
	QueueCommand(function() q:Complete() end)
end

local function DoIncomplete()
	DebugOut("DEV", "Force marking quest as incomplete: " .. q.name)
	QueueCommand(function()
		Player.questsWaiting[q.name] = nil
		Player.questsActive[q.name] = nil
		Player.questStarters[q.name] = nil
		Player.questsComplete[q.name] = nil
        Player.questDifficulty[q.name] = nil -- Also clear the locked difficulty
	end)
end

local function DoActivate()
	DebugOut("DEV", "Force offering quest: " .. q.name)
	QueueCommand(function() q:Offer() end)
end

-------------------------------------------------------------------------------
-- UI Layout Configuration

local h = devMenuStyle.font[2]
local total_width = 800
local total_height = 600
local padding = 10

local col_width_left = 300
local col_width_mid = 240
local col_width_right = 240
local col_x_left = padding
local col_x_mid = col_x_left + col_width_left + padding
local col_x_right = col_x_mid + col_width_mid + padding

local info_area_height = total_height - (3 * h)

-------------------------------------------------------------------------------
-- Helper Functions for Building the UI

local function BuildContentList(list, evaluator_func)
    local content = {}
    if not list or type(list) ~= "table" or table.getn(list) == 0 then
        return "  NONE"
    end

    for _, item in ipairs(list) do
        if item then
            if not evaluator_func and item.Description and string.find(item:Description(q) or "", "Text:") then
                -- This is an AwardText object, we handle its text in the Narrative column
            else
                local desc
                if evaluator_func then
                    local eval = item:Evaluate(q)
                    local color = eval and "20A020" or "A02020"
                    local status = eval and "[YES] " or "[NO]  "
                    local desc_text = item.DebugDescription and item:DebugDescription(q) or (item.Description and item:Description(q) or "[NO DESCRIPTION]")
                    desc = string.format("<font color='%s'>%s</font>%s", color, status, desc_text)
                else
                    desc = "  " .. (item.DebugDescription and item:DebugDescription(q) or (item.Description and item:Description(q) or "[ACTION HAS NO DESCRIPTION]"))
                end
                table.insert(content, desc)
            end
        end
    end
    
    if table.getn(content) == 0 then return "  NONE" end
    return table.concat(content, "<br>")
end

local function GetAwardTextAsString(rewardList)
    local found_texts = {}
    if type(rewardList) == "table" then
        for _, item in ipairs(rewardList) do
            -- Pass 'q' to GetReplacedString to ensure correct difficulty parsing
            local desc_string = item.Description and item:Description(q)
            if desc_string and string.find(desc_string, "Text:") then
                local text_content = GetReplacedString(item.key, q)
                if text_content and text_content ~= "#####" then
                    table.insert(found_texts, text_content)
                end
            end
        end
    end
    if table.getn(found_texts) > 0 then
        return table.concat(found_texts, "<br><br>")
    end
    return nil
end

-------------------------------------------------------------------------------
-- Build the Content Strings for Each Column

-- Get the correct difficulty for the quest being inspected
local difficulty = GetQuestDifficulty(q)

-- Column 1: Narrative
local col1_content = {}
local introText = q:GetIntro()
if introText and introText ~= "#####" then table.insert(col1_content, "<b>INTRO DIALOGUE</b><br>" .. introText) end

-- Select the correct onaccept list for the "EXTRA INTRO" text
local onaccept_list_for_text = q.onaccept
if difficulty == 2 and q.onaccept_medium then onaccept_list_for_text = q.onaccept_medium end
if difficulty == 3 and q.onaccept_hard then onaccept_list_for_text = q.onaccept_hard end
local extraIntroText = GetAwardTextAsString(onaccept_list_for_text)
if extraIntroText then table.insert(col1_content, "<b>EXTRA INTRO DIALOGUE (ON ACCEPT)</b><br>" .. extraIntroText) end

-- (Similar logic for defer and reject if needed, though less common)
local extraDeferText = GetAwardTextAsString(q.ondefer)
if extraDeferText then table.insert(col1_content, "<b>EXTRA INTRO DIALOGUE (ON DEFER)</b><br>" .. extraDeferText) end
local extraRejectText = GetAwardTextAsString(q.onreject)
if extraRejectText then table.insert(col1_content, "<b>EXTRA INTRO DIALOGUE (ON REJECT)</b><br>" .. extraRejectText) end

local completeText = q:GetCompleteString()
if completeText and completeText ~= "#####" then
    table.insert(col1_content, "<b>COMPLETE DIALOGUE</b><br>" .. completeText)
    local oncomplete_list_for_text = q.oncomplete
    if difficulty == 2 and q.oncomplete_medium then oncomplete_list_for_text = q.oncomplete_medium end
    if difficulty == 3 and q.oncomplete_hard then oncomplete_list_for_text = q.oncomplete_hard end
    local extraCompleteText = GetAwardTextAsString(oncomplete_list_for_text)
    if extraCompleteText then table.insert(col1_content, "<b>EXTRA COMPLETE DIALOGUE</b><br>" .. extraCompleteText) end
end

local incompleteText = q:GetIncompleteString()
if incompleteText and incompleteText ~= "#####" then
    table.insert(col1_content, "<b>INCOMPLETE DIALOGUE</b><br>" .. incompleteText)
    local extraIncompleteText = GetAwardTextAsString(q.onincomplete)
    if extraIncompleteText then table.insert(col1_content, "<b>EXTRA INCOMPLETE DIALOGUE</b><br>" .. extraIncompleteText) end
end

-- Column 2: Summary, Logic & Metadata
local col2_content = {}
local summaryText = q:GetSummary()
if summaryText and summaryText ~= "#####" then table.insert(col2_content, "<b>SUMMARY</b><br>" .. summaryText) end
local hintText = q:GetHint()
if hintText and hintText ~= "#####" then table.insert(col2_content, "<b>HINT DIALOGUE</b><br>" .. hintText) end

local starters = {}
if q.starter and type(q.starter) == "table" and table.getn(q.starter) > 0 then
    for _, s in ipairs(q.starter) do table.insert(starters, s.name) end
elseif q.delivery then
    local startBuilding = _AllBuildings[q.startbuilding]
    if startBuilding then
        local charList = startBuilding:GetCharacterList()
        if charList and charList[1] then
            table.insert(starters, charList[1].name)
        end
    end
end
if table.getn(starters) == 0 then table.insert(starters, "[telegram]") end

local enders = {}
if q.ender and type(q.ender) == "table" then
    for _, e in ipairs(q.ender) do table.insert(enders, e.name) end
end

local followup = q.followup and ("["..q.followup.."]") or "NONE"
table.insert(col2_content, "<b>METADATA</b><br><b>STARTERS:</b> " .. table.concat(starters, ", ") .. "<br><b>ENDERS:</b> " .. table.concat(enders, ", ") .. "<br><b>FOLLOWUP:</b> " .. followup)

-- Select the correct requirement and goal lists based on difficulty
local require_list = q.require
if difficulty == 2 and q.require_medium then require_list = q.require_medium end
if difficulty == 3 and q.require_hard then require_list = q.require_hard end

local goal_list = q.goals
if difficulty == 2 and q.goals_medium then goal_list = q.goals_medium end
if difficulty == 3 and q.goals_hard then goal_list = q.goals_hard end

table.insert(col2_content, "<b>REQUIREMENTS:</b><br>" .. BuildContentList(require_list, function(item) return item:Evaluate(q) end))
table.insert(col2_content, "<b>GOALS:</b><br>" .. BuildContentList(goal_list, function(item) return item:Evaluate(q) end))

-- Column 3: Rewards
local col3_content = {}
-- Select the correct reward lists based on difficulty
local onaccept_list = q.onaccept
if difficulty == 2 and q.onaccept_medium then onaccept_list = q.onaccept_medium end
if difficulty == 3 and q.onaccept_hard then onaccept_list = q.onaccept_hard end

local oncomplete_list = q.oncomplete
if difficulty == 2 and q.oncomplete_medium then oncomplete_list = q.oncomplete_medium end
if difficulty == 3 and q.oncomplete_hard then oncomplete_list = q.oncomplete_hard end

local onreject_list = q.onreject
if difficulty == 2 and q.onreject_medium then onreject_list = q.onreject_medium end
if difficulty == 3 and q.onreject_hard then onreject_list = q.onreject_hard end

local ondefer_list = q.ondefer
if difficulty == 2 and q.ondefer_medium then ondefer_list = q.ondefer_medium end
if difficulty == 3 and q.ondefer_hard then ondefer_list = q.ondefer_hard end

local onexpire_list = q.onexpire
if difficulty == 2 and q.onexpire_medium then onexpire_list = q.onexpire_medium end
if difficulty == 3 and q.onexpire_hard then onexpire_list = q.onexpire_hard end

table.insert(col3_content, "<b>ON ACCEPT:</b><br>" .. BuildContentList(onaccept_list))
table.insert(col3_content, "<b>ON COMPLETE:</b><br>" .. BuildContentList(oncomplete_list))
table.insert(col3_content, "<b>ON REJECT:</b><br>" .. BuildContentList(onreject_list))
table.insert(col3_content, "<b>ON DEFER:</b><br>" .. BuildContentList(ondefer_list))
table.insert(col3_content, "<b>ON EXPIRE:</b><br>" .. BuildContentList(onexpire_list))

-------------------------------------------------------------------------------
-- Build the Footer and Action Buttons

local footer_y = total_height - (2 * h) - padding
local footer_items = {}

if q:IsActive() then
	local time = "#<b>TIME ACTIVATED: </b>".. (Player.questsActive[q.name] or "N/A")
	table.insert(footer_items, Button { x=padding, y=footer_y, w=160, h=h, label="#<b>[- Mark Complete -]</b>", command=DoComplete, close=true})
	table.insert(footer_items, Text { x=padding+165, y=footer_y, w=200, h=h, label=time })
elseif q:IsComplete() then
	local time = "#<b>TIME COMPLETED: </b>".. (Player.questsComplete[q.name] or "N/A")
	table.insert(footer_items, Button { x=padding, y=footer_y, w=160, h=h, label="#<b>[- Re-Offer Quest -]</b>", command=DoActivate, close=true})
	table.insert(footer_items, Text { x=padding+165, y=footer_y, w=200, h=h, label=time })
	table.insert(footer_items, Button { x=padding+370, y=footer_y, w=160, h=h, label="#<b>[- Mark Incomplete -]</b>", command=DoIncomplete, close=true})
else
	table.insert(footer_items, Button { x=padding, y=footer_y, w=160, h=h, label="#<b>[- Offer Quest -]</b>", command=DoActivate, close=true})
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_quest_detail",
	BSGWindow { x=gDialogTable.x, y=gDialogTable.y, w=total_width, h=total_height, fit=true, color={1,1,1,.9}, SetStyle(devMenuStyle),
		
        -- Header (Row 1, Part 1)
        Text { x=padding, y=0, w=total_width, h=h, label="#<b>["..q.name.."]: "..q:GetTitle().."</b>", flags=kVAlignCenter+kHAlignLeft },
		Button { x=total_width - 150 - padding, y=0, w=150, h=h, label="#<b>BACK TO LIST</b>", default=true, cancel=true, 
            command=function() 
                CloseWindow(); 
                QueueCommand(function() DisplayDialog { "dev/dev_quests.lua", x=gDialogTable.x, y=gDialogTable.y } end)
            end 
        },

        -- Main Content Area (Row 1, Part 2)
        Window { x=0, y=h+padding, w=total_width, h=info_area_height,
            Text { x=col_x_left, y=0, w=col_width_left, h=kMax, label="#"..table.concat(col1_content, "<br><br>"), flags=kVAlignTop+kHAlignLeft },
            Text { x=col_x_mid, y=0, w=col_width_mid, h=kMax, label="#"..table.concat(col2_content, "<br><br>"), flags=kVAlignTop+kHAlignLeft },
            Text { x=col_x_right, y=0, w=col_width_right, h=kMax, label="#"..table.concat(col3_content, "<br><br>"), flags=kVAlignTop+kHAlignLeft },
        },

        -- Footer / Action Area (Row 2)
        Group(footer_items)
	},
}