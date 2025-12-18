--[[---------------------------------------------------------------------------
    Chocolatier Three: Catalogue Port List Panel
    Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Helper function for Lua 5.0 compatible modulo
local function Mod(a, n)
    if n == 0 then return a end
    return a - (n * Floor(a / n))
end

-- This function is called when a port in the list is clicked.
local function SelectPort(port)
    -- We only allow selection of ports that have been unlocked.
    if port and Player.catalogue.unlockedPorts[port.name] then
        if gCatalogueSelection ~= port then
            gCatalogueSelection = port
            DebugOut("UI", "Catalogue selection changed to: " .. port.name)
            
            -- Redraw both panels to update the selection highlight and the detail view
            FillWindow("catalogue_list", "ui/catalogue_port_list.lua")
            FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
        end
    end
end

-------------------------------------------------------------------------------
-- Data Gathering and Sorting

-- Gather all ports from the global table into a list we can sort.
local portList = {}
for name, port in pairs(_AllPorts) do
    -- We will include all ports, even hidden ones, to show them as locked entries.
    table.insert(portList, port)
end

-- Sort the list alphabetically by the port's display name.
table.sort(portList, function(a, b) return GetString(a.name) < GetString(b.name) end)

-------------------------------------------------------------------------------
-- UI Construction

local contents = {}
local layout = {
    x_start = 0, y_start = 0,
    x_spacing = 75, y_spacing = 75,
    items_per_row = 4,
    rows_per_page = 4,
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page

-- Make the layout accessible to the parent container for scrolling logic.
gCatalogueLayout = layout

local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

-- Build the UI for the visible page of ports.
for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
    local port = portList[i]
    if port then
        local tempPort = port
        local isUnlocked = Player.catalogue.unlockedPorts[port.name]

        local label = isUnlocked and GetString(port.name) or GetString("catalogue_locked_title")
        -- NOTE: We will need to create these new thumbnail assets.
        local imagePath = "image/catalogue_thumb_" .. port.name .. ".png"
        
        local portDisplay
        if isUnlocked then
            -- UNLOCKED: Display the full-color port thumbnail.
            portDisplay = Bitmap { image = imagePath }
        else
            -- LOCKED: Display the icon tinted black as a silhouette.
            portDisplay = BitmapTint { image = imagePath, tint = Color(0, 0, 0, 255) }
        end

        -- Create the button. The background changes if the item is selected.
        table.insert(contents,
            Button { x = x, y = y, w = 95, h = 95, graphics = {},
                command = function() SoundEvent("cadi/ui_click.ogg"); SelectPort(tempPort) end,
                
                Bitmap { x = 0, y = 0, image = (gCatalogueSelection == tempPort) and "image/button_recipes_selected" or "image/button_recipes_up" },
                
                -- Container for the port thumbnail image.
                Window { x = 15, y = 15, w = 64, h = 64,
                    portDisplay,
                },

                -- Text label for the port name below the thumbnail.
                Text { x = 0, y = 70, w = 95, h = 20, label = "#"..label, font = { uiFontName, 12, BlackColor }, flags = kVAlignCenter + kHAlignCenter }
            }
        )

        -- Update grid position for the next item.
        items_drawn_this_page = items_drawn_this_page + 1
        x = x + layout.x_spacing
        if Mod(items_drawn_this_page, layout.items_per_row) == 0 then
            x = layout.x_start
            y = y + layout.y_spacing
        end
    end
end

-------------------------------------------------------------------------------

MakeDialog(contents)

-- Tell the parent container whether the scroll buttons should be enabled.
local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(portList)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)