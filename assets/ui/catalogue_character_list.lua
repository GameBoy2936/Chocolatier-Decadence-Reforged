--[[---------------------------------------------------------------------------
    Chocolatier Three: Decadence by Design Reforged (Character List Panel)
    Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local function SelectCharacter(char)
    if gCatalogueSelection ~= char then
        gCatalogueSelection = char
        DebugOut("UI", string.format("Catalogue selection changed to Character: %s", char.name))
        
        FillWindow("catalogue_list", "ui/catalogue_character_list.lua")
        FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
    end
end

-------------------------------------------------------------------------------
-- Advanced Sorting & Priority Logic
-------------------------------------------------------------------------------
-- Characters are normally parsed arbitrarily by the engine. To create a clean, 
-- story-relevant layout, we assign strict numerical priorities grouping main 
-- characters and villains to the top of the grid.

-- 1. Hardcode hierarchy tiers
local priority_main = {
    "main_alex", "main_sean", "main_feli", "main_deit", "main_evan", "main_jose", "main_elen",
    "main_whit", "main_tedd", "main_zach", "main_chas", "main_loud", "main_sara"
}
local priority_villains = { "evil_wolf", "evil_tyso", "evil_kath", "evil_bian" }
local priority_npc = { "announcer" }

-- 2. Build mathematical priority mapping logic
local priority_map = {}
local offset = 0
for i, name in ipairs(priority_main) do priority_map[name] = i + offset end

offset = offset + table.getn(priority_main)
for i, name in ipairs(priority_villains) do priority_map[name] = i + offset end

offset = offset + table.getn(priority_villains)
for i, name in ipairs(priority_npc) do priority_map[name] = i + offset end

-- 3. Gather all dynamically available characters from the master manifest
local characterList = {}
for name, _ in pairs(CharacterAssetManifest) do
    if _AllCharacters[name] then
        table.insert(characterList, _AllCharacters[name])
    end
end

-- 4. Execute the sort: Prioritize tier scores first, then fall back to alphabetical
table.sort(characterList, function(a, b)
    local rank_a = priority_map[a.name] or 999
    local rank_b = priority_map[b.name] or 999
    
    if rank_a < rank_b then return true
    elseif rank_a > rank_b then return false
    else return GetString(a.name) < GetString(b.name) end
end)

-------------------------------------------------------------------------------
-- UI Construction & Grid Generation
-------------------------------------------------------------------------------

local contents = {}
local layout = {
    x_start = 12, y_start = 2,
    x_spacing = 66, y_spacing = 92,
    items_per_row = 4,
    rows_per_page = 5,
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page

gCatalogueLayout = layout

local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

-- Synthesize grid rendering
for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
    local char = characterList[i]
    if char then
        local tempChar = char
        local charData = Player.catalogue.unlockedCharacters[char.name]
        local isMet = charData and charData.met
        
        -- Asset offsets are manually hardcoded in the manifest due to uneven original engine art
        local assetInfo = CharacterAssetManifest[char.name]
        local portrait_x = assetInfo.x_list or assetInfo.x or 6
        local portrait_y = assetInfo.y_list or assetInfo.y or 12
        local portrait_scale = assetInfo.scale_list or assetInfo.scale or 0.35
        
        local characterDisplay
        
        if isMet then
            -- UNLOCKED: Render full color artwork.
            characterDisplay = CharWindow { 
                x = portrait_x, y = portrait_y - 10, 
                name = char.name, 
                scale = portrait_scale 
            }
        else
            -- LOCKED: Render Silhouette overlay.
            -- Legacy support checks for specific manual masks if a pre-baked silhouette PNG isn't found.
            if assetInfo and assetInfo.silhouette then
                characterDisplay = Bitmap {
                    x = portrait_x, y = portrait_y, scale = portrait_scale,
                    image = "characters/" .. char.name .. ".silhouette.png",
                }
            else
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
                        x = final_x, y = final_y - 8, scale = portrait_scale,
                        image = "characters/" .. char.name .. ".png",
                        tint = Color(0, 0, 0, 255),
                    }
                end
            end
        end

        table.insert(contents,
            Button { 
                x = x, y = y, w = layout.x_spacing, h = layout.y_spacing, graphics = {},
                command = function() SoundEvent("cadi/ui_click.ogg"); SelectCharacter(tempChar) end,
                characterDisplay,
            }
        )

        -- Advance cursor bounds
        items_drawn_this_page = items_drawn_this_page + 1
        x = x + layout.x_spacing
        if Mod(items_drawn_this_page, layout.items_per_row) == 0 then
            x = layout.x_start
            y = y + layout.y_spacing - 10
        end
    end
end

MakeDialog(contents)

local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(characterList)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)