--[[---------------------------------------------------------------------------
    Chocolatier Three: Catalogue UI (History List Panel)
    Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- State Management & Data Gathering
-------------------------------------------------------------------------------

-- A predefined list of all history articles in their intended display order.
local allHistoryArticles = {
    "catalogue_history_founding",
    "catalogue_history_feud",
    "catalogue_history_alex",
    -- Add new history article keys here in the future.
}

-- This table will hold only the articles the player has unlocked.
local unlockedArticles = {}
for _, key in ipairs(allHistoryArticles) do
    if Player.catalogue.unlockedHistory[key] then
        table.insert(unlockedArticles, key)
    end
end

-- Set the initial selection to the first unlocked article, if one exists.
if not gCatalogueSelection and table.getn(unlockedArticles) > 0 then
    gCatalogueSelection = unlockedArticles[1]
end

-------------------------------------------------------------------------------
-- Core UI Functions
-------------------------------------------------------------------------------

-- This function is called when an article title is clicked.
local function SelectArticle(articleKey)
    if gCatalogueSelection ~= articleKey then
        gCatalogueSelection = articleKey
        
        DebugOut("UI", "Catalogue selection changed to history article: " .. articleKey)

        -- Update the visual state of the buttons in the list.
        for _, key in ipairs(unlockedArticles) do
            SetButtonToggleState("article_" .. key, key == gCatalogueSelection)
        end
        
        -- Reload the detail panel with the new selection.
        FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
    end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

local listItems = { BeginGroup() }
local y_pos = 0
local y_increment = 30 -- The vertical space between each list item.

if table.getn(unlockedArticles) > 0 then
    for _, articleKey in ipairs(unlockedArticles) do
        local tempKey = articleKey -- Store key for the closure.
        
        -- Use the QuestSelectButton style for a similar look and feel to the quest log.
        table.insert(listItems, QuestSelectButton { 
            x = 0, y = y_pos, 
            name = "article_" .. tempKey, 
            label = "#" .. GetString(tempKey .. "_title"), 
            command = function() SelectArticle(tempKey) end 
        })
        
        y_pos = y_pos + y_increment
    end
else
    -- Display a message if no history articles have been unlocked yet.
    table.insert(listItems, Text { 
        x = 0, y = 0, w = kMax, h = kMax, 
        label = "#No history entries unlocked.", 
        flags = kVAlignCenter + kHAlignCenter 
    })
end

-- Main dialog layout for this panel.
MakeDialog
{
    -- This is just a container for the list items.
    -- The background is already provided by the main catalogue window.
    Window
    {
        x = 0, y = 0, w = kMax, h = kMax,
        Group(listItems)
    }
}

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Set the initial visual state for the selected button.
if gCatalogueSelection then
    SetButtonToggleState("article_" .. gCatalogueSelection, true)
end