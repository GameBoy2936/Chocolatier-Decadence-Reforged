--[[---------------------------------------------------------------------------
    Chocolatier Three: Development Menu - Debug Console
    Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Configuration & State
-------------------------------------------------------------------------------

local controlHeight = devMenuStyle.font[2] + 4
local logLineHeight = devMenuStyle.font[2] - 2
local w = 780
local padding = 5
local main_window_height = 550

local topLineIndex = 1
local filteredLog = {}

local consoleFont = { devMenuStyle.font[1], logLineHeight, WhiteColor }
local titleFont = { devMenuStyle.font[1], 18, WhiteColor }
local searchBoxFont = { devMenuStyle.font[1], devMenuStyle.font[2], BlackColor }
local filterOnColor = "66FF66"
local filterOffColor = "999999"
local consoleButtonStyle = { parent = devMenuStyle, font = consoleFont }

local categoryColors = {
    DEFAULT     = "FFFFFF", ERROR       = "FF4500", LOAD        = "87CEEB",
    SAVE        = "DBDBFF", UI          = "B0C4DE", SIM         = "DA70D6", 
    QUEST       = "90EE90", PLAYER      = "FFD700", FACTORY     = "C96C3E", 
    CHAR        = "778899", BUILDING    = "778899", HAGGLE      = "FFA07A", 
    RECIPE      = "EB9C49", TIP         = "40E0D0", DEV         = "C8A0DD",
}

local function Ceil(x) return Floor(x + 0.99999) end
local function Max(a, b) if a > b then return a else return b end end
local function Mod(a, n) if n == 0 then return a end return a - (n * Floor(a / n)) end

-------------------------------------------------------------------------------
-- Core Logic Functions
-------------------------------------------------------------------------------

local function PopulateDisplay()
    local linesOnScreen = Max(1, Floor((main_window_height - (4 * controlHeight) - padding) / logLineHeight))
    local linesToDisplay = {}
    for i = 1, linesOnScreen do
        local logIndex = topLineIndex + i - 1
        if filteredLog[logIndex] then
            local entry = filteredLog[logIndex]
            local color = categoryColors[entry.category] or categoryColors.DEFAULT
            local safeMessage = string.gsub(entry.message, "%%", "%%%%")
            table.insert(linesToDisplay, string.format("<font color='%s'>[%d] [%s] %s</font>", color, entry.timestamp, entry.category, safeMessage))
        end
    end
    SetLabel("log_display_area", table.concat(linesToDisplay, "\n"))
    EnableWindow("scrollUp", topLineIndex > 1)
    EnableWindow("scrollDown", topLineIndex + linesOnScreen <= table.getn(filteredLog))
end
local function ApplyFilters()
    filteredLog = {}
    local searchTerm = string.lower(gDebugFilters.searchTerm or "")
    for _, entry in ipairs(gDebugLog) do
        local categoryMatch = gDebugFilters.categories[entry.category] or false
        local searchMatch = (searchTerm == "") or string.find(string.lower(entry.message), searchTerm)
        if categoryMatch and searchMatch then
            table.insert(filteredLog, entry)
        end
    end
    local linesOnScreen = Max(1, Floor((main_window_height - (4 * controlHeight) - padding) / logLineHeight))
    if table.getn(filteredLog) > linesOnScreen then
        topLineIndex = table.getn(filteredLog) - linesOnScreen + 1
    else
        topLineIndex = 1
    end
    PopulateDisplay()
end
local function ScrollUp()
    if topLineIndex > 1 then
        topLineIndex = topLineIndex - 20
        if topLineIndex < 1 then
            topLineIndex = 1
        end
        PopulateDisplay()
    end
end
local function ScrollDown()
    local linesOnScreen = Max(1, Floor((main_window_height - (4 * controlHeight) - padding) / logLineHeight))
    if topLineIndex + linesOnScreen <= table.getn(filteredLog) then
        topLineIndex = topLineIndex + 20
        PopulateDisplay()
    end
end
local function UpdateFilterButtonVisuals(categoryName)
    local buttonName = "#filter_" .. categoryName
    local label
    if gDebugFilters.categories[categoryName] then
        label = string.format("<font color='%s'>%s</font>", filterOnColor, categoryName)
    else
        label = string.format("<font color='%s'>%s</font>", filterOffColor, categoryName)
    end
    SetLabel(buttonName, label)
end
local function ToggleCategoryFilter(categoryName)
    gDebugFilters.categories[categoryName] = not gDebugFilters.categories[categoryName]
    UpdateFilterButtonVisuals(categoryName)
    ApplyFilters()
end
local function UpdateSearchTerm()
    gDebugFilters.searchTerm = GetLabel("search_box")
    ApplyFilters()
end
local function ClearSearch()
    gDebugFilters.searchTerm = ""
    SetLabel("search_box", "")
    ApplyFilters()
end
local function ClearLog()
    gDebugLog = {}
    ApplyFilters()
end
local function SetAllFilters(isEnabled)
    for category, _ in pairs(gDebugFilters.categories) do
        gDebugFilters.categories[category] = isEnabled
        UpdateFilterButtonVisuals(category)
    end
    ApplyFilters()
end

-- Function to handle saving the log to a file.
local function SaveLogToFile()
    -- 1. Get unique data from the game state.
    local playerName = Player.name or "Player"
    local week = Player.time or 0
    local defaultName = string.format("choco3_log_%s_week%d", playerName, week)

    -- 2. Use the existing 'entername' dialog to get a filename from the user.
    local fileName = DisplayDialog { "ui/ui_entername.lua", name = defaultName }

    -- 3. Proceed only if the user entered a name and didn't cancel.
    if fileName and fileName ~= "" then
        -- 4. Append the .txt extension.
        fileName = fileName .. ".txt"

        -- 5. Prepare the content string from the currently filtered log.
        local lines = {}
        for _, entry in ipairs(filteredLog) do
            -- Format each line as plain text, without the color tags.
            local line = string.format("[%d] [%s] %s", entry.timestamp, entry.category, entry.message)
            table.insert(lines, line)
        end
        local contentString = table.concat(lines, "\n")

        -- 6. Use the engine's file writing function.
        WriteToFile(fileName, contentString)

        -- 7. Provide feedback to the user via the console itself.
        DebugOut("DEV", "Log successfully saved to " .. fileName)
        -- We call ApplyFilters again to make sure this new message appears immediately.
        ApplyFilters()
    end
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

-- ... (categories table and filterButtons group remain the same) ...
local categories = {}
for category, _ in pairs(gDebugFilters.categories) do
    table.insert(categories, category)
end
table.sort(categories)
local filter_button_width = 65
local filter_buttons_per_row = Floor((w - 0) / (filter_button_width + padding))
local num_filter_rows = Ceil(table.getn(categories) / filter_buttons_per_row)
local y_search = controlHeight + padding
local y_filters = y_search + controlHeight + padding
local filter_area_height = num_filter_rows * (controlHeight + padding)
local y_log_start = y_filters + filter_area_height + padding
local filterButtons = {}
for i, category in ipairs(categories) do
    local tempCategory = category
    local col = Mod(i - 1, filter_buttons_per_row)
    local row = Floor((i - 1) / filter_buttons_per_row)
    local x_pos = col * (filter_button_width + padding)
    local y_pos = row * (controlHeight + padding)
    table.insert(filterButtons, Button { 
        x = x_pos, y = y_pos, w = filter_button_width, h = controlHeight, 
        name = "#filter_" .. tempCategory, 
        label = tempCategory, 
        type = kPush,
        command = function() ToggleCategoryFilter(tempCategory) end 
    })
end

MakeDialog
{
    name = "dev_console",
    BSGWindow { x = 0, y = 0, w = kScreenWidth, h = kScreenHeight, color = {0.1, 0.1, 0.1, 0.85}, 
        
        Window { x = kCenter, y = kCenter, w = w, h = main_window_height,
            SetStyle(consoleButtonStyle),

            Button { x = 5, y = 0, w = 200, h = controlHeight, label = "#<b>DEBUG CONSOLE</b>", font = titleFont },
            Button { x = w - 60, y = 0, w = 60, h = controlHeight, label = "#<b>CLOSE</b>", font = titleFont, default = true, cancel = true, close = true },
            
            Window { x = 5, y = y_search, w = w - 10, h = controlHeight,
                Bitmap { x = 0, y = 0, w = 155, h = controlHeight, image = "image/textfield",
                    TextEdit { 
                        x = 5, y = 0, w = 145, h = controlHeight, 
                        name = "search_box", 
                        label = (gDebugFilters.searchTerm or ""), 
                        length = 50, 
                        onkey = UpdateSearchTerm,
                        font = searchBoxFont,
                    },
                },
                Button { x = 165, y = 0, w = 25, h = controlHeight, label = "#X", command = ClearSearch },
                Button { x = 220, y = 0, w = 70, h = controlHeight, label = "#CLEAR LOG", command = ClearLog },
                Button { x = 305, y = 0, w = 70, h = controlHeight, label = "#All Filters", command = function() SetAllFilters(true) end },
                Button { x = 380, y = 0, w = 70, h = controlHeight, label = "#No Filters", command = function() SetAllFilters(false) end },
                Button { x = 465, y = 0, w = 70, h = controlHeight, label = "#Save Log", command = SaveLogToFile },
            },

            Window { x = 5, y = y_filters, w = w - 10, h = filter_area_height,
                Group(filterButtons)
            },

            Window {
                x = 5, y = y_log_start, w = w - 10, h = main_window_height - y_log_start - padding,
                Text { 
                    x = 5, y = 0, w = w - 45, h = kMax, 
                    name = "log_display_area", label = "", font = consoleFont,
                    flags = kHAlignLeft + kVAlignTop 
                },
                Button { x = w - 40, y = 0, w = 20, h = controlHeight, label = "#^", font = titleFont, command = ScrollUp, name = "scrollUp" },
                Button { x = w - 40, y = controlHeight + padding, w = 20, h = controlHeight, label = "#v", font = titleFont, command = ScrollDown, name = "scrollDown" },
            },
        }
    },
}

for _, category in ipairs(categories) do
    UpdateFilterButtonVisuals(category)
end
ApplyFilters()