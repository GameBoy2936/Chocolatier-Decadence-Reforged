--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Building Selector
	Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local onOkCallback = gDialogTable.onOk
local promptText = gDialogTable.prompt or "Select a Building:"

local h = devMenuStyle.font[2]
local w = 180 -- Width of each column
local y_start = 2 * h
local y_max = 560

local buildingTypeStyles = {
    market =      { name = "MARKET",      color = "3A8E1D" },
    farm =        { name = "PLANTATION",  color = "3A8E1D" },
    shop =        { name = "SHOP",        color = "B324C7" },
    factory =     { name = "FACTORY",     color = "C96C3E" },
    kitchen =     { name = "KITCHEN",     color = "0077BE" },
    casino =      { name = "CASINO",      color = "B8860B" },
    -- Fallback types
    generic =     { name = "NORMAL",      color = "000000" },
    bank =        { name = "NORMAL",      color = "000000" },
    saloon =      { name = "NORMAL",      color = "000000" },
    -- The "empty" style is now used for buildings created with EmptyBuilding()
    empty =       { name = "EMPTY",       color = "777777" }
}

local buildings = {}
for portName, port in pairs(_AllPorts) do
    if port:IsAvailable() and port.buildings then
        for _, building in ipairs(port.buildings) do
            if building.type ~= "special" then
                table.insert(buildings, building)
            end
        end
    end
end
table.sort(buildings, function(a,b) return a.name < b.name end)

local items = {}
local x = 0
local y = y_start
for _, building in ipairs(buildings) do
    if y > y_max then
        x = x + w
        y = y_start
    end
    local tempBuilding = building

    local style
    if table.getn(building.characters[1] or {}) == 0 then
        -- If a building has no characters assigned, it's an "EmptyBuilding".
        style = buildingTypeStyles.empty
    else
        -- Otherwise, look up its type. Fall back to "generic" (NORMAL) if not found.
        style = buildingTypeStyles[building.type] or buildingTypeStyles.generic
    end
    
    local typeLabel = string.format("<font color='%s'>%s</font>", style.color, style.name)
    local portLabel = GetString(building.port.name)
    
    local label = "#" .. GetString(building.name) .. "<br><font size='10'>" .. typeLabel .. " | " .. portLabel .. "</font>"

    table.insert(items, Button { 
        x=x, y=y, w=w, h=h*2, 
        label=label, 
        command=function() 
            if type(onOkCallback) == "function" then onOkCallback(tempBuilding) end
            CloseWindow()
        end 
    })
    y = y + h*2
end

MakeDialog
{
    name="dev_select_building",
    BSGWindow { x=gDialogTable.x, y=gDialogTable.y, w=w*4, h=600, fit=true, color={1,1,1,.9}, SetStyle(devMenuStyle),
        Button { x=0, y=0, w=w, h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
        Text { x=w, y=0, w=w*3, h=h, label="#"..promptText, flags=kVAlignCenter+kHAlignLeft },
        Group(items),
    }
}