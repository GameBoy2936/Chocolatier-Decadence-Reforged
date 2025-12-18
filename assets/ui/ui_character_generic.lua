--[[---------------------------------------------------------------------------
	Chocolatier Three Generic Character Dialog (Dynamic Layout)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local char = gDialogTable.char or gActiveCharacter
if type(char) == "string" then char = _AllCharacters[char] end
gActiveCharacter = char

if char then
    Player:MeetCharacter(char)
end

local text = gDialogTable.text or ""
if string.sub(text, 1, 1) == "#" then
    text = string.sub(text, 2)
end

-- Read custom button properties from the dialog table
local okLabel = gDialogTable.ok or "ok"
local okLength = gDialogTable.ok_length or "standard"

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
-- DYNAMIC BUTTON CONFIG
-------------------------------------------------------------------------------

local windowWidth = 601
local buttonY = 240

-- Synchronize widths with ui_quest_offer.lua
local buttonWidths = {
    standard = 135,
    medium = 200,
    long = 300,
    extralong = 400
}

local buttonStyles = {
    standard = C3ButtonStyle,
    medium = C3ButtonMediumStyle,
    long = C3ButtonLongStyle,
    extralong = C3ButtonExtraLongStyle
}

-- Calculate properties for the single button
local width = buttonWidths[okLength] or buttonWidths.standard
local style = buttonStyles[okLength] or buttonStyles.standard
local currentX = Floor((windowWidth - width) / 2) + 1

-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x=1000,y=35,w=601,h=366, name="ui_character_generic",
		Bitmap
		{
			x=0,y=49, image="image/popup_back_dialog",
			
			SetStyle(C3CharacterDialogStyle),
			Text { x=241,y=48,w=314,h=172, name="dialogue_text" },
			
			SetStyle(C3CharacterNameStyle),
			Text { x=41,y=201,w=187,h=20, label=char.name, font=characterNameFont, flags=kVAlignCenter+kHAlignCenter },
			
            -- Manual Button Definition to ensure alignment
			Button { 
                x=currentX, 
                y=buttonY, 
                w=width, 
                h=50, 
                
                name="ok", 
                label="#"..GetString(okLabel), 
                default=true, cancel=true, close=true,
                
                -- Visual Alignment Fixes
                font = buttonFont, 
                flags = kVAlignCenter + kHAlignCenter,
                ty = kCenter - 3,
                tx = kCenter - 1,

                -- Style Application
                graphics = style.graphics,
                sound = style.sound,
                type = style.type,
            },
		},
		CharWindow { x=49,y=0, name=char.name, happiness=char:GetHappiness() },
	}
}

OpenBuilding("ui_character_generic", gDialogTable.building)
SetDynamicDialogueText(text)