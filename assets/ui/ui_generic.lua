--[[---------------------------------------------------------------------------
	Chocolatier Three Generic Dialog (Dynamic Layout & Translation Fix)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
    MODIFIED (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local ok = gDialogTable.ok or "ok"
local text = gDialogTable.text or "#NOT YET IMPLEMENTED"
local okLength = gDialogTable.ok_length or "standard"

-- Handle the "No Fade" logic
local closeFunction = function() FadeCloseWindow("generic", "ok") end
local windowX = 1000 -- Off-screen start for fade-in
if gDialogTable.noFade then
	windowX = kCenter
	closeFunction = function() CloseWindow("ok") end
end

-------------------------------------------------------------------------------
-- TRANSLATION FIX
-------------------------------------------------------------------------------
if string.sub(text, 1, 1) == "#" then
    text = string.sub(text, 2)
else
    local translated = GetString(text)
    if translated and translated ~= "#####" then
        text = translated
    end
end

-------------------------------------------------------------------------------
-- DYNAMIC TEXT SIZING
-------------------------------------------------------------------------------

local function SetDynamicGenericText(text)
    local function Ceil(x) return Floor(x + 0.99999) end
    
    local font_sizes_to_check = {18, 16, 14, 12}
    local chars_per_line_map = { [18] = 40, [16] = 46, [14] = 52, [12] = 60 }
    local line_thresholds = { [18] = 8, [16] = 9, [14] = 11, [12] = 999 }
    
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
    SetLabel("generic_text", formatted_text)
end

-------------------------------------------------------------------------------
-- DYNAMIC BUTTON LAYOUT
-------------------------------------------------------------------------------

local containerWidth = 499 
local buttonY = 237

local buttonWidths = { standard = 135, medium = 200, long = 300, extralong = 400 }
local buttonStyles = { standard = C3ButtonStyle, medium = C3ButtonMediumStyle, long = C3ButtonLongStyle, extralong = C3ButtonExtraLongStyle }

local width = buttonWidths[okLength] or buttonWidths.standard
local style = buttonStyles[okLength] or buttonStyles.standard

local currentX = Floor((containerWidth - width) / 2) + 1

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="generic",
		x=windowX, y=kCenter, image="image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x=20,y=42,w=459,h=177, name="generic_text", label="", flags=kVAlignCenter+kHAlignCenter },
		
		Button { 
            x=currentX, 
            y=buttonY, 
            w=width, 
            h=50, 
            name="ok", 
            label="#"..GetString(ok), 
            command=closeFunction, 
            default=true, 
            cancel=true,
            
            font = buttonFont, 
            flags = kVAlignCenter + kHAlignCenter,
            ty = kCenter - 3,
            tx = kCenter - 1,
            
            graphics = style.graphics,
            sound = style.sound,
            type = style.type,
        },
	}
}

if gDialogTable.building then OpenBuilding("generic", gDialogTable.building)
elseif not gDialogTable.noFade then CenterFadeIn("generic")
end

SetDynamicGenericText(text)