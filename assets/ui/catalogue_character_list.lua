--[[---------------------------------------------------------------------------
    Chocolatier Three: Catalogue Character List Panel
    Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local function SelectCharacter(char)
    if gCatalogueSelection ~= char then
        gCatalogueSelection = char
        DebugOut("UI", "Catalogue selection changed to: " .. char.name)
        
        -- Redraw both panels to update the selection highlight and the detail view
        FillWindow("catalogue_list", "ui/catalogue_character_list.lua")
        FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
    end
end

-------------------------------------------------------------------------------

-- 1. Define the priority order for specific characters.
local priority_main = {
    "main_alex", "main_sean", "main_feli", "main_deit", "main_evan", "main_jose", "main_elen",
    "main_whit", "main_tedd", "main_zach", "main_chas", "main_loud", "main_sara"
}
local priority_villains = { "evil_wolf", "evil_tyso", "evil_kath", "evil_bian" }
local priority_npc = { "announcer" }

-- 2. Create lookup maps for efficient sorting.
local priority_map = {}
local offset = 0
for i, name in ipairs(priority_main) do priority_map[name] = i + offset end
offset = offset + table.getn(priority_main)
for i, name in ipairs(priority_villains) do priority_map[name] = i + offset end
offset = offset + table.getn(priority_villains)
for i, name in ipairs(priority_npc) do priority_map[name] = i + offset end

-- 3. Gather all valid characters from the manifest.
local characterList = {}
for name, _ in pairs(CharacterAssetManifest) do
    if _AllCharacters[name] then
        table.insert(characterList, _AllCharacters[name])
    end
end

-- 4. Sort the list using the custom comparison function.
table.sort(characterList, function(a, b)
    local rank_a = priority_map[a.name] or 999
    local rank_b = priority_map[b.name] or 999
    if rank_a < rank_b then return true
    elseif rank_a > rank_b then return false
    else return GetString(a.name) < GetString(b.name) end
end)

-------------------------------------------------------------------------------

local contents = {}
local layout = {
    x_start = 12, y_start = 0,
    x_spacing = 66, y_spacing = 92,
    items_per_row = 4,
    rows_per_page = 4,
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page

-- Make the layout accessible to the parent container
gCatalogueLayout = layout

local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

-- Build the UI for the visible page of characters
for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
    local char = characterList[i]
    if char then
        local tempChar = char
        local charData = Player.catalogue.unlockedCharacters[char.name]
        local isMet = charData and charData.met
        local assetInfo = CharacterAssetManifest[char.name]

        -- Define a single set of positioning variables from the manifest
        local portrait_x = assetInfo.x_list or assetInfo.x or 6
        local portrait_y = assetInfo.y_list or assetInfo.y or 12
        local portrait_scale = assetInfo.scale_list or assetInfo.scale or 0.35
        
        local characterDisplay
        if isMet then
            -- UNLOCKED: Use CharWindow for its perfect, internal alignment logic.
            characterDisplay = CharWindow { 
                x = portrait_x, y = portrait_y-10, 
                name = char.name, 
                scale = portrait_scale 
            }
        else
            -- LOCKED: Check if a custom, pre-aligned silhouette exists.
            if assetInfo and assetInfo.silhouette then
                -- Use the new pre-aligned silhouette PNG via a simple Bitmap.
                -- This achieves the same perfect alignment as CharWindow without manual offsets.
                characterDisplay = Bitmap {
                    x = portrait_x, y = portrait_y, scale = portrait_scale,
                    image = "characters/" .. char.name .. ".silhouette.png",
                }
            else
                -- Fallback to the original BitmapTint method if no silhouette is specified.
                local final_x = portrait_x + (assetInfo.list_x_offset or 0)
                local final_y = portrait_y

                if assetInfo.mask then
                    characterDisplay = BitmapTint {
                        x = final_x, y = final_y, scale = portrait_scale,
                        image = "characters/" .. char.name .. ".jpg",
                        mask = "characters/" .. char.name .. ".mask.png",
                        tint = Color(0, 0, 0, 255),
                    }
                else
                    characterDisplay = BitmapTint {
                        x = final_x, y = final_y-8, scale = portrait_scale,
                        image = "characters/" .. char.name .. ".png",
                        tint = Color(0, 0, 0, 255),
                    }
                end
            end
        end

        table.insert(contents,
            Button { x = x, y = y, w = layout.x_spacing, h = layout.y_spacing, graphics = {},
                command = function() SoundEvent("cadi/ui_click.ogg"); SelectCharacter(tempChar) end,
                
                -- The correctly configured characterDisplay object is placed inside the button
                characterDisplay,
            }
        )

        -- Update grid position
        items_drawn_this_page = items_drawn_this_page + 1
        x = x + layout.x_spacing
        if Mod(items_drawn_this_page, layout.items_per_row) == 0 then
            x = layout.x_start
            y = y + layout.y_spacing-10
        end
    end
end

-------------------------------------------------------------------------------

MakeDialog(contents)

-- Tell the parent container whether the scroll buttons should be enabled
local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(characterList)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)