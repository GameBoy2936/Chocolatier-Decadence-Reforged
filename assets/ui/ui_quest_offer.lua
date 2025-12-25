--[[---------------------------------------------------------------------------
	Chocolatier Three: Quest Offer (Final Polish v2)
	Copyright (c) 2006-2007 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local quest = gDialogTable.quest
local text = quest:GetIntro()
local char = gDialogTable.char or gActiveCharacter
gActiveCharacter = char

if char then
    Player:MeetCharacter(char)
end

local building = gDialogTable.building
if building and not Player.buildingsVisited[building.name] then
	DebugOut("PLAYER", "First visit to generic building: " .. building.name)
	Player.buildingsVisited[building.name] = true
end

local name = nil
local happiness = nil
if char then
	name = char.name
	happiness = 50	--char:GetHappiness()
end

-- Determine if the Accept button should also act as Cancel (ESC key)
local okCancel = false
if quest.defer == "none" and quest.reject == "none" then okCancel=true end

-------------------------------------------------------------------------------
-- DYNAMIC TEXT SIZING
-------------------------------------------------------------------------------

local function SetDynamicDialogueText(text)
    local function Ceil(x) return Floor(x + 0.99999) end
    local font_sizes_to_check = {16, 15, 14, 13, 12}
    local chars_per_line_map = { [16] = 46, [15] = 49, [14] = 52, [13] = 56, [12] = 60 }
    local line_thresholds = { [16] = 10, [15] = 11, [14] = 12, [13] = 13, [12] = 999 }
    local segments = {}
    local current_pos = 1
    if text then
        local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        while start_pos do
            table.insert(segments, string.sub(text, current_pos, start_pos - 1))
            current_pos = end_pos + 1
            start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        end
        table.insert(segments, string.sub(text, current_pos))
    end
    if table.getn(segments) == 0 then segments = { text or "" } end
    local final_font_size = 12
    for _, current_font_size in ipairs(font_sizes_to_check) do
        local chars_per_line = chars_per_line_map[current_font_size]
        local line_threshold = line_thresholds[current_font_size]
        local total_lines = table.getn(segments) - 1
        for _, segment in ipairs(segments) do
            total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
        end
        if total_lines <= line_threshold then
            final_font_size = current_font_size
            break 
        end
    end
    local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
    SetLabel("dialogue_text", formatted_text)
end

-------------------------------------------------------------------------------
-- DYNAMIC BUTTON LAYOUT ENGINE
-------------------------------------------------------------------------------

local windowWidth = 602
local buttonY = 240
local buttonSpacing = 5 -- Pixels between buttons

-- Define the widths for our button sizes (Based on your new asset dimensions)
local buttonWidths = {
    standard = 135,
    medium = 200,
    long = 300,     -- The new intermediate asset
    extralong = 400 -- The original massive asset
}

-- Define the Styles mapping for graphics
local buttonStyles = {
    standard = C3ButtonStyle,
    medium = C3ButtonMediumStyle,
    long = C3ButtonLongStyle,
    extralong = C3ButtonExtraLongStyle
}

-- 1. Identify which buttons are active and collect their config
local activeButtons = {}

-- DEFER Button
if quest.defer ~= "none" then
    table.insert(activeButtons, {
        name = "defer",
        label = quest.defer,
        length = quest.defer_length or "standard",
        command = function() quest:Defer(char); CloseWindow() end,
        cancel = false,
        default = false
    })
end

-- ACCEPT Button (Always present)
table.insert(activeButtons, {
    name = "accept",
    label = quest.accept,
    length = quest.accept_length or "standard",
    command = function() quest:Accept(char); CloseWindow() end,
    cancel = okCancel, 
    default = true
})

-- REJECT Button
if quest.reject ~= "none" then
    table.insert(activeButtons, {
        name = "reject",
        label = quest.reject,
        length = quest.reject_length or "standard",
        command = function() quest:Reject(char); CloseWindow() end,
        cancel = true, 
        default = false
    })
end

-- 2. Calculate Total Width of the button group
local totalGroupWidth = 0
for i, btn in ipairs(activeButtons) do
    local width = buttonWidths[btn.length] or buttonWidths.standard
    totalGroupWidth = totalGroupWidth + width
    
    if i < table.getn(activeButtons) then
        totalGroupWidth = totalGroupWidth + buttonSpacing
    end
end

-- 3. Calculate Starting X to center the group
-- FIX: Added Floor() for integer precision and +1 to nudge it right.
-- This aligns it with the engine's internal kCenter logic.
local currentX = Floor((windowWidth - totalGroupWidth) / 2) + 1

-- 4. Generate the Button Objects
local generatedButtons = {}
for _, btn in ipairs(activeButtons) do
    local style = buttonStyles[btn.length] or buttonStyles.standard
    local width = buttonWidths[btn.length] or buttonWidths.standard
    
    table.insert(generatedButtons, Button {
        x = currentX,
        y = buttonY,
        w = width, 
        h = 50,
        name = btn.name,
        label = "#" .. GetString(btn.label),
        command = btn.command,
        default = btn.default,
        cancel = btn.cancel,
        
        -- Explicitly set the font and alignment flags.
        font = buttonFont, 
        flags = kVAlignCenter + kHAlignCenter,
        
        -- FIX: Apply the calibrated negative Y offset from kCenter.
        ty = kCenter - 3,
        tx = kCenter - 1,
        
        -- Apply graphics from the specific length style
        graphics = style.graphics,
        sound = style.sound,
        type = style.type, 
    })
    
    -- Advance X position for the next button
    currentX = currentX + width + buttonSpacing
end

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=601,h=366, name="quest_offer",
		Bitmap
		{
			x=0,y=49, image="image/popup_back_dialog",
			
			SetStyle(C3CharacterDialogStyle),
			Text { x=241,y=48,w=314,h=172, name="dialogue_text", label="#"..text },
			
			SetStyle(C3CharacterNameStyle),
			Text { x=41,y=201,w=187,h=20, label=name, font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
			
            -- Inject our dynamically generated and styled buttons
			Group(generatedButtons),
		},
		CharWindow { x=49,y=0, name=name, happiness=happiness },
	}
}

OpenBuilding("quest_offer", gDialogTable.building)
SetDynamicDialogueText(text)